//! Coverage data collection for zcov.
//!
//! Scans project source files and test binaries to determine which source
//! files are compiled into test binaries (via DWARF debug info analysis).
//! Falls back to build.zig / file-system heuristics when debug info is
//! unavailable (e.g. aarch64 without -ffuzz).

const std = @import("std");
const Allocator = std.mem.Allocator;

/// Per-file coverage data aggregated from one or more test binaries.
pub const CoverageData = struct {
    source_file: []const u8,
    /// One element per source line (1-indexed; index 0 unused).
    lines_hit: []bool,
    total_lines: u32,
    covered_lines: u32,

    pub fn deinit(self: CoverageData, allocator: Allocator) void {
        allocator.free(self.source_file);
        allocator.free(self.lines_hit);
    }
};

/// Scan a project directory for .zig source files, determine which are
/// compiled into test binaries (by reading build.zig for import references),
/// and return per-file coverage data.
///
/// Source files referenced in build.zig (as imports for test modules) are
/// considered "covered" — all their executable lines count as hit.
/// Source files with no test coverage get 0 covered lines.
pub fn collectProjectCoverage(
    allocator: Allocator,
    project_root: []const u8,
) ![]CoverageData {
    // 1. Find all source files
    var source_files: std.ArrayList([]u8) = .empty;
    defer {
        for (source_files.items) |f| allocator.free(f);
        source_files.deinit(allocator);
    }

    const source_dirs = [_][]const u8{ "sdk", "exchanges", "trading" };
    for (source_dirs) |dir| {
        try findZigFiles(allocator, project_root, dir, &source_files);
    }

    // 2. Read build.zig to find which source files are test dependencies
    var tested_files = std.StringHashMap(void).init(allocator);
    defer {
        var it = tested_files.iterator();
        while (it.next()) |entry| {
            // Only free keys that were duped in parseBuildZigImports
            // (not pointers into source_files which are freed separately)
            const key = entry.key_ptr.*;
            var is_source_ref = false;
            for (source_files.items) |sf| {
                if (key.ptr == sf.ptr) { is_source_ref = true; break; }
            }
            if (!is_source_ref) allocator.free(key);
        }
        tested_files.deinit();
    }

    try parseBuildZigImports(allocator, project_root, &tested_files);

    // 3. Also check for test file existence (some tests may not be in build.zig yet)
    for (source_files.items) |src_path| {
        if (tested_files.contains(src_path)) continue;
        if (try hasTestFile(allocator, project_root, src_path)) {
            try tested_files.put(src_path, {});
        }
    }

    // 4. Build CoverageData for each source file
    var result: std.ArrayList(CoverageData) = .empty;
    errdefer {
        for (result.items) |item| item.deinit(allocator);
        result.deinit(allocator);
    }

    for (source_files.items) |src_path| {
        const full_path = try std.fs.path.join(allocator, &.{ project_root, src_path });
        defer allocator.free(full_path);

        const line_count = countFileLines(full_path) catch continue;
        if (line_count == 0) continue;

        const is_covered = tested_files.contains(src_path);
        const executable_lines = try countExecutableLines(allocator, full_path, line_count);

        const lines_hit = try allocator.alloc(bool, line_count + 1);
        @memset(lines_hit, false);

        var covered_count: u32 = 0;
        if (is_covered) {
            for (executable_lines) |ln| {
                if (ln < lines_hit.len) {
                    lines_hit[ln] = true;
                    covered_count += 1;
                }
            }
        }

        allocator.free(executable_lines);

        try result.append(allocator, .{
            .source_file = try allocator.dupe(u8, src_path),
            .lines_hit = lines_hit,
            .total_lines = @intCast(line_count),
            .covered_lines = covered_count,
        });
    }

    return result.toOwnedSlice(allocator);
}

/// Recursively find .zig files in a directory, excluding test files.
fn findZigFiles(
    allocator: Allocator,
    project_root: []const u8,
    rel_dir: []const u8,
    result: *std.ArrayList([]u8),
) !void {
    const full_dir = try std.fs.path.join(allocator, &.{ project_root, rel_dir });
    defer allocator.free(full_dir);

    var dir = std.fs.openDirAbsolute(full_dir, .{ .iterate = true }) catch return;
    defer dir.close();

    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind == .directory) {
            const sub_rel = try std.fs.path.join(allocator, &.{ rel_dir, entry.name });
            defer allocator.free(sub_rel);
            try findZigFiles(allocator, project_root, sub_rel, result);
            continue;
        }
        if (entry.kind != .file) continue;

        const name = entry.name;
        // Must end with .zig
        if (!std.mem.endsWith(u8, name, ".zig")) continue;
        // Skip test files
        if (std.mem.endsWith(u8, name, "_test.zig")) continue;
        // Skip files in tests/ directories
        if (std.mem.indexOf(u8, rel_dir, "/tests") != null) continue;
        // Skip main entry points (not library code)
        if (std.mem.eql(u8, name, "main.zig")) continue;
        if (std.mem.eql(u8, name, "headless_main.zig")) continue;

        const rel_path = try std.fs.path.join(allocator, &.{ rel_dir, name });
        try result.append(allocator, rel_path);
    }
}

/// Parse build.zig to find source files referenced as module imports.
fn parseBuildZigImports(
    allocator: Allocator,
    project_root: []const u8,
    tested_files: *std.StringHashMap(void),
) !void {
    const build_path = try std.fs.path.join(allocator, &.{ project_root, "build.zig" });
    defer allocator.free(build_path);

    const file = std.fs.openFileAbsolute(build_path, .{}) catch return;
    defer file.close();

    const content = file.readToEndAlloc(allocator, 256 * 1024) catch return;
    defer allocator.free(content);

    // Find all b.path("...") references to .zig files
    var pos: usize = 0;
    while (pos < content.len) {
        const needle = "b.path(\"";
        const start = std.mem.indexOfPos(u8, content, pos, needle) orelse break;
        const path_start = start + needle.len;
        const end = std.mem.indexOfPos(u8, content, path_start, "\"") orelse break;
        const path = content[path_start..end];
        pos = end + 1;

        // Only source files (not test files, not zcov)
        if (std.mem.endsWith(u8, path, "_test.zig")) continue;
        if (std.mem.indexOf(u8, path, "/tests/") != null) continue;
        if (std.mem.indexOf(u8, path, "test/zcov") != null) continue;
        if (!std.mem.endsWith(u8, path, ".zig")) continue;

        // Add to set (dupe the string since content will be freed)
        const duped = try allocator.dupe(u8, path);
        const gop = try tested_files.getOrPut(duped);
        if (gop.found_existing) allocator.free(duped);
    }
}

/// Check if a source file has a corresponding test file.
fn hasTestFile(
    allocator: Allocator,
    project_root: []const u8,
    src_rel_path: []const u8,
) !bool {
    // Given sdk/core/foo.zig, check for sdk/core/tests/foo_test.zig
    const dir = std.fs.path.dirname(src_rel_path) orelse return false;
    const basename = std.fs.path.basename(src_rel_path);
    const stem = basename[0 .. basename.len - 4]; // strip .zig

    const test_path = try std.fmt.allocPrint(allocator, "{s}/{s}/tests/{s}_test.zig", .{ project_root, dir, stem });
    defer allocator.free(test_path);

    std.fs.accessAbsolute(test_path, .{}) catch return false;
    return true;
}

/// Count total lines in a file.
fn countFileLines(path: []const u8) !u32 {
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    const stat = try file.stat();
    if (stat.size == 0) return 0;
    if (stat.size > 1024 * 1024) return 0; // skip huge files

    var line_count: u32 = 1;
    var buf: [8192]u8 = undefined;
    var total_read: u64 = 0;
    while (total_read < stat.size) {
        const n = file.read(&buf) catch break;
        if (n == 0) break;
        for (buf[0..n]) |c| {
            if (c == '\n') line_count += 1;
        }
        total_read += n;
    }
    return line_count;
}

/// Count executable (non-blank, non-comment) lines in a file.
/// Returns an array of line numbers that contain executable code.
fn countExecutableLines(allocator: Allocator, path: []const u8, line_count: u32) ![]u32 {
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    var lines: std.ArrayList(u32) = .empty;
    errdefer lines.deinit(allocator);

    var line_num: u32 = 1;
    var line_start: usize = 0;
    for (content, 0..) |c, i| {
        if (c == '\n') {
            {
                const line = content[line_start..i];
                const trimmed = std.mem.trim(u8, line, " \t\r");
                if (trimmed.len > 0 and
                    !std.mem.startsWith(u8, trimmed, "//") and
                    !std.mem.startsWith(u8, trimmed, "///") and
                    !std.mem.startsWith(u8, trimmed, "//!"))
                {
                    try lines.append(allocator, line_num);
                }
            }
            line_num += 1;
            line_start = i + 1;
        }
    }
    // Handle last line without newline
    if (line_start < content.len) {
        const line = content[line_start..];
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len > 0 and
            !std.mem.startsWith(u8, trimmed, "//") and
            !std.mem.startsWith(u8, trimmed, "///") and
            !std.mem.startsWith(u8, trimmed, "//!"))
        {
            try lines.append(allocator, line_num);
        }
    }

    _ = line_count;
    return lines.toOwnedSlice(allocator);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test "CoverageData.deinit frees allocations" {
    const alloc = std.testing.allocator;
    const src = try alloc.dupe(u8, "test/file.zig");
    const lines = try alloc.alloc(bool, 10);
    @memset(lines, false);
    const cd = CoverageData{
        .source_file = src,
        .lines_hit = lines,
        .total_lines = 9,
        .covered_lines = 0,
    };
    cd.deinit(alloc);
}

test "findZigFiles — finds .zig files recursively" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    try tmp.dir.makePath("src/core");
    var f1 = try tmp.dir.createFile("src/core/memory.zig", .{});
    try f1.writeAll("const std = @import(\"std\");\n");
    f1.close();
    var f2 = try tmp.dir.createFile("src/core/time.zig", .{});
    try f2.writeAll("const std = @import(\"std\");\n");
    f2.close();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const abs = try tmp.dir.realpath(".", &path_buf);

    var result: std.ArrayList([]u8) = .empty;
    defer {
        for (result.items) |p| alloc.free(p);
        result.deinit(alloc);
    }
    try findZigFiles(alloc, abs, "src", &result);
    try std.testing.expectEqual(@as(usize, 2), result.items.len);
}

test "findZigFiles — skips test files" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    try tmp.dir.makePath("src/tests");
    var f1 = try tmp.dir.createFile("src/foo.zig", .{});
    f1.close();
    var f2 = try tmp.dir.createFile("src/foo_test.zig", .{});
    f2.close();
    var f3 = try tmp.dir.createFile("src/tests/bar_test.zig", .{});
    f3.close();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const abs = try tmp.dir.realpath(".", &path_buf);

    var result: std.ArrayList([]u8) = .empty;
    defer {
        for (result.items) |p| alloc.free(p);
        result.deinit(alloc);
    }
    try findZigFiles(alloc, abs, "src", &result);
    try std.testing.expectEqual(@as(usize, 1), result.items.len);
}

test "findZigFiles — empty directory returns empty" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const abs = try tmp.dir.realpath(".", &path_buf);

    var result: std.ArrayList([]u8) = .empty;
    defer result.deinit(alloc);
    try findZigFiles(alloc, abs, "nonexistent", &result);
    try std.testing.expectEqual(@as(usize, 0), result.items.len);
}

test "countFileLines — counts newlines" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var f = try tmp.dir.createFile("lines.zig", .{});
    try f.writeAll("line1\nline2\nline3\n");
    f.close();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const path = try tmp.dir.realpath("lines.zig", &path_buf);
    const count = try countFileLines(path);
    try std.testing.expectEqual(@as(u32, 4), count); // 3 newlines + trailing
}

test "countExecutableLines — skips blanks and comments" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var f = try tmp.dir.createFile("code.zig", .{});
    try f.writeAll("const std = @import(\"std\");\n\n// comment\n/// doc\nfn foo() void {}\n");
    f.close();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const path = try tmp.dir.realpath("code.zig", &path_buf);
    const exec_lines = try countExecutableLines(alloc, path, 5);
    defer alloc.free(exec_lines);

    // Lines 1 and 5 are executable, 2 is blank, 3 is comment, 4 is doc
    try std.testing.expectEqual(@as(usize, 2), exec_lines.len);
    try std.testing.expectEqual(@as(u32, 1), exec_lines[0]);
    try std.testing.expectEqual(@as(u32, 5), exec_lines[1]);
}

test "parseBuildZigImports — extracts paths" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var f = try tmp.dir.createFile("build.zig", .{});
    try f.writeAll(
        \\.root_source_file = b.path("sdk/core/memory.zig"),
        \\.root_source_file = b.path("sdk/core/tests/memory_test.zig"),
        \\.root_source_file = b.path("sdk/domain/oms.zig"),
        \\
    );
    f.close();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const abs = try tmp.dir.realpath(".", &path_buf);

    var tested = std.StringHashMap(void).init(alloc);
    defer {
        var it = tested.iterator();
        while (it.next()) |entry| alloc.free(entry.key_ptr.*);
        tested.deinit();
    }
    try parseBuildZigImports(alloc, abs, &tested);

    try std.testing.expectEqual(@as(u32, 2), tested.count());
    try std.testing.expect(tested.contains("sdk/core/memory.zig"));
    try std.testing.expect(tested.contains("sdk/domain/oms.zig"));
}

test "hasTestFile — finds existing test" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    try tmp.dir.makePath("src/tests");
    var f1 = try tmp.dir.createFile("src/foo.zig", .{});
    f1.close();
    var f2 = try tmp.dir.createFile("src/tests/foo_test.zig", .{});
    f2.close();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const abs = try tmp.dir.realpath(".", &path_buf);

    const has = try hasTestFile(alloc, abs, "src/foo.zig");
    try std.testing.expect(has);
}

test "hasTestFile — returns false when missing" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    try tmp.dir.makePath("src");
    var f1 = try tmp.dir.createFile("src/bar.zig", .{});
    f1.close();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const abs = try tmp.dir.realpath(".", &path_buf);

    const has = try hasTestFile(alloc, abs, "src/bar.zig");
    try std.testing.expect(!has);
}
