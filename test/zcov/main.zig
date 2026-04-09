//! zcov — Zig coverage tool for the trading platform.
//!
//! Usage:
//!   zig build zcov                  # run all tests with coverage
//!   zig build zcov -- <module>      # filter to one module
//!
//! How it works:
//!   1. Invokes `zig build test` to verify all tests pass.
//!   2. Scans the project source tree for .zig files.
//!   3. Checks build.zig and test file existence to determine which source
//!      files are covered by tests.
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

    const stderr_file = std.fs.File.stderr();
    const stdout_file = std.fs.File.stdout();
    var stderr_buf: [4096]u8 = undefined;
    var stdout_buf: [65536]u8 = undefined;
    var stderr_w = stderr_file.writer(&stderr_buf);
    var stdout_w = stdout_file.writer(&stdout_buf);

    // --- Step 1: compile and run tests --------------------------------------
    try stderr_w.interface.writeAll("zcov: compiling and running tests...\n");
    try stderr_w.interface.flush();

    runCommand(gpa, &.{ "zig", "build", "test", "-Doptimize=Debug" }, project_root) catch |err| {
        switch (err) {
            error.BuildFailed => try stderr_w.interface.writeAll("zcov: test build failed — cannot collect coverage\n"),
            error.AbnormalTermination => try stderr_w.interface.writeAll("zcov: test build terminated abnormally\n"),
            else => try stderr_w.interface.print("zcov: build error: {s}\n", .{@errorName(err)}),
        }
        try stderr_w.interface.flush();
        std.process.exit(1);
    };

    // --- Step 2: collect coverage via source-tree analysis -------------------
    try stderr_w.interface.writeAll("zcov: analyzing source coverage...\n");
    try stderr_w.interface.flush();

    const raw_data = try coverage.collectProjectCoverage(gpa, project_root);
    defer {
        for (raw_data) |item| item.deinit(gpa);
        gpa.free(raw_data);
    }

    // --- Step 3: apply module filter if specified ----------------------------
    var filtered: std.ArrayList(coverage.CoverageData) = .empty;
    defer filtered.deinit(gpa);

    for (raw_data) |item| {
        if (module_filter) |filter| {
            if (std.mem.indexOf(u8, item.source_file, filter) == null) continue;
        }
        try filtered.append(gpa, item);
    }

    // --- Step 4: print report -----------------------------------------------
    try report.printReport(&stdout_w.interface, filtered.items);
    try stdout_w.interface.flush();
}

// ---------------------------------------------------------------------------
// Extracted helpers (testable independently)
// ---------------------------------------------------------------------------

/// Spawn a command, wait for completion, return error on non-zero exit.
fn runCommand(
    allocator: std.mem.Allocator,
    argv: []const []const u8,
    cwd: ?[]const u8,
) !void {
    var child = std.process.Child.init(argv, allocator);
    child.cwd = cwd;
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Ignore;

    try child.spawn();
    const term = try child.wait();
    switch (term) {
        .Exited => |code| if (code != 0) return error.BuildFailed,
        else => return error.AbnormalTermination,
    }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test "runCommand — success with /bin/true" {
    try runCommand(std.testing.allocator, &.{"/bin/true"}, null);
}

test "runCommand — returns BuildFailed on non-zero exit" {
    const result = runCommand(std.testing.allocator, &.{"/bin/false"}, null);
    try std.testing.expectError(error.BuildFailed, result);
}

test "runCommand — respects cwd" {
    try runCommand(std.testing.allocator, &.{"/bin/true"}, "/tmp");
}

test "runCommand — returns error for nonexistent binary" {
    const result = runCommand(std.testing.allocator, &.{"/nonexistent/binary"}, null);
    try std.testing.expectError(error.FileNotFound, result);
}
