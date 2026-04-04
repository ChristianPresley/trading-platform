//! zcov — Zig coverage tool for the trading platform.
//!
//! Usage:
//!   zig build zcov                  # run all tests with coverage
//!   zig build zcov -- <module>      # filter to one module
//!
//! How it works:
//!   1. Invokes `zig build test` to compile test binaries.
//!   2. Runs each compiled test binary with `--cache-dir=<path>` so the
//!      fuzzer runtime (when compiled with -ffuzz) writes SeenPcsHeader
//!      coverage files into .zig-cache/v/.
//!   3. Reads those files with coverage.zig, resolving PCs → source lines via
//!      DWARF debug info.
//!   4. Prints a per-module report with report.zig.

const std = @import("std");
const coverage = @import("coverage.zig");
const report = @import("report.zig");

pub fn main() !void {
    var gpa_state = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_state.deinit();
    const gpa = gpa_state.allocator();

    // --- Parse CLI args -----------------------------------------------------
    var args = try std.process.argsWithAllocator(gpa);
    defer args.deinit();
    _ = args.next(); // skip argv[0]

    var module_filter: ?[]const u8 = null;
    if (args.next()) |filter| module_filter = filter;

    // --- Resolve project root -----------------------------------------------
    const project_root = try std.fs.realpathAlloc(gpa, ".");
    defer gpa.free(project_root);

    const cache_dir_path = try std.fs.path.join(gpa, &.{ project_root, ".zig-cache" });
    defer gpa.free(cache_dir_path);

    // In Zig 0.15, stderr/stdout are accessed via std.fs.File.stderr()/stdout().
    // File.writer(buf) returns a File.Writer whose .interface is std.Io.Writer.
    const stderr_file = std.fs.File.stderr();
    const stdout_file = std.fs.File.stdout();
    var stderr_buf: [4096]u8 = undefined;
    var stdout_buf: [65536]u8 = undefined;
    var stderr_w = stderr_file.writer(&stderr_buf);
    var stdout_w = stdout_file.writer(&stdout_buf);

    // --- Step 1: compile tests ----------------------------------------------
    try stderr_w.interface.writeAll("zcov: compiling tests...\n");
    try stderr_w.interface.flush();

    {
        var child = std.process.Child.init(
            &.{ "zig", "build", "test", "-Doptimize=Debug" },
            gpa,
        );
        child.cwd = project_root;
        child.stdin_behavior = .Ignore;
        child.stdout_behavior = .Inherit;
        child.stderr_behavior = .Inherit;

        try child.spawn();
        const term = try child.wait();
        switch (term) {
            .Exited => |code| if (code != 0) {
                try stderr_w.interface.writeAll("zcov: test build failed — cannot collect coverage\n");
                try stderr_w.interface.flush();
                std.process.exit(1);
            },
            else => {
                try stderr_w.interface.writeAll("zcov: test build terminated abnormally\n");
                try stderr_w.interface.flush();
                std.process.exit(1);
            },
        }
    }

    // --- Step 2: discover compiled test binaries ----------------------------
    try stderr_w.interface.writeAll("zcov: discovering test binaries...\n");
    try stderr_w.interface.flush();

    const test_binaries = try findTestBinaries(gpa, project_root);
    defer {
        for (test_binaries) |b| gpa.free(b);
        gpa.free(test_binaries);
    }

    if (test_binaries.len == 0) {
        try stderr_w.interface.writeAll("zcov: no test binaries found in .zig-cache/\n");
        try stderr_w.interface.flush();
        std.process.exit(1);
    }

    // --- Step 3: run each test binary with --cache-dir ----------------------
    try stderr_w.interface.print("zcov: running {d} test binaries to collect coverage...\n", .{test_binaries.len});
    try stderr_w.interface.flush();

    for (test_binaries) |bin_path| {
        runTestBinaryForCoverage(gpa, bin_path, cache_dir_path) catch |err| {
            try stderr_w.interface.print("zcov: warning: could not run '{s}': {s}\n", .{ bin_path, @errorName(err) });
            try stderr_w.interface.flush();
        };
    }

    // --- Step 4: collect and aggregate coverage data -------------------------
    try stderr_w.interface.writeAll("zcov: collecting coverage data...\n");
    try stderr_w.interface.flush();

    // In Zig 0.15, ArrayList is the new Aligned struct: no init(allocator),
    // instead use .empty and pass gpa per-operation.
    var all_data: std.ArrayList(coverage.CoverageData) = .empty;
    defer {
        for (all_data.items) |item| item.deinit(gpa);
        all_data.deinit(gpa);
    }

    for (test_binaries) |bin_path| {
        const data = coverage.collectCoverage(gpa, bin_path, cache_dir_path) catch |err| {
            try stderr_w.interface.print("zcov: warning: coverage collection failed for '{s}': {s}\n", .{ bin_path, @errorName(err) });
            try stderr_w.interface.flush();
            continue;
        };
        defer gpa.free(data);

        for (data) |item| {
            if (module_filter) |filter| {
                if (std.mem.indexOf(u8, item.source_file, filter) == null) {
                    item.deinit(gpa);
                    continue;
                }
            }
            try all_data.append(gpa, item);
        }
    }

    // --- Step 5: print report -----------------------------------------------
    try report.printReport(&stdout_w.interface, all_data.items);
    try stdout_w.interface.flush();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Walk `.zig-cache/o/` and collect paths to ELF test binaries.
fn findTestBinaries(allocator: std.mem.Allocator, project_root: []const u8) ![][]u8 {
    var results: std.ArrayList([]u8) = .empty;
    errdefer {
        for (results.items) |p| allocator.free(p);
        results.deinit(allocator);
    }

    const cache_o = try std.fs.path.join(allocator, &.{ project_root, ".zig-cache", "o" });
    defer allocator.free(cache_o);

    var dir = std.fs.openDirAbsolute(cache_o, .{ .iterate = true }) catch return results.toOwnedSlice(allocator);
    defer dir.close();

    var iter = dir.iterate();
    while (try iter.next()) |hash_entry| {
        if (hash_entry.kind != .directory) continue;

        var sub_dir = dir.openDir(hash_entry.name, .{ .iterate = true }) catch continue;
        defer sub_dir.close();

        var sub_iter = sub_dir.iterate();
        while (try sub_iter.next()) |file_entry| {
            if (file_entry.kind != .file) continue;
            const name = file_entry.name;
            // Heuristic: test binaries have 'test' in their name and no extension.
            if (std.mem.indexOf(u8, name, "test") == null) continue;
            if (std.mem.lastIndexOfScalar(u8, name, '.') != null) continue;

            const full_path = try std.fs.path.join(allocator, &.{ cache_o, hash_entry.name, name });
            errdefer allocator.free(full_path);

            _ = sub_dir.statFile(name) catch {
                allocator.free(full_path);
                continue;
            };
            try results.append(allocator, full_path);
        }
    }

    return results.toOwnedSlice(allocator);
}

/// Run a single test binary passing `--cache-dir=<path>`.
fn runTestBinaryForCoverage(
    allocator: std.mem.Allocator,
    bin_path: []const u8,
    cache_dir_path: []const u8,
) !void {
    const cache_arg = try std.fmt.allocPrint(allocator, "--cache-dir={s}", .{cache_dir_path});
    defer allocator.free(cache_arg);

    var child = std.process.Child.init(&.{ bin_path, cache_arg }, allocator);
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Ignore;

    try child.spawn();
    _ = try child.wait();
}
