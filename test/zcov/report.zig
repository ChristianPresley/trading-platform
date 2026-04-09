//! Coverage report formatting for zcov.
//!
//! Groups CoverageData entries by module (sdk/core, sdk/domain, etc.),
//! computes per-module summaries, and prints a colored terminal table.

const std = @import("std");
const Allocator = std.mem.Allocator;
const CoverageData = @import("coverage.zig").CoverageData;

pub const ModuleSummary = struct {
    name: []const u8,
    total_lines: u32,
    covered_lines: u32,

    pub fn percentage(self: ModuleSummary) f64 {
        if (self.total_lines == 0) return 0.0;
        return @as(f64, @floatFromInt(self.covered_lines)) /
            @as(f64, @floatFromInt(self.total_lines)) * 100.0;
    }
};

/// Print a coverage report to `writer`.
/// `data` is a slice of per-file coverage data (owned by caller).
pub fn printReport(writer: *std.Io.Writer, data: []const CoverageData) !void {
    if (data.len == 0) {
        try writer.writeAll("zcov: no source files found to analyze.\n");
        return;
    }

    // --- Group by module ---------------------------------------------------
    const module_names = [_][]const u8{
        "sdk/core",
        "sdk/domain",
        "sdk/protocol",
        "exchanges/kraken",
        "trading/desk",
        "trading/analytics",
        "trading/strategies",
    };

    var summaries: [module_names.len + 1]ModuleSummary = undefined;
    for (module_names, 0..) |name, i| {
        summaries[i] = .{ .name = name, .total_lines = 0, .covered_lines = 0 };
    }
    summaries[module_names.len] = .{ .name = "other", .total_lines = 0, .covered_lines = 0 };

    var total_lines: u32 = 0;
    var total_covered: u32 = 0;

    for (data) |item| {
        const mod_idx = classifyModule(item.source_file, &module_names);
        summaries[mod_idx].total_lines += item.total_lines;
        summaries[mod_idx].covered_lines += item.covered_lines;
        total_lines += item.total_lines;
        total_covered += item.covered_lines;
    }

    // --- Print header ------------------------------------------------------
    const total_pct: f64 = if (total_lines > 0)
        @as(f64, @floatFromInt(total_covered)) / @as(f64, @floatFromInt(total_lines)) * 100.0
    else
        0.0;

    try writer.print(
        "\n\x1b[1mzcov coverage report\x1b[0m  {d:.1}% overall ({d}/{d} lines)\n",
        .{ total_pct, total_covered, total_lines },
    );
    try writer.writeAll("─────────────────────────────────────────────────────────────────\n");
    try writer.print("{s:<24} {s:>8}  {s:>6}/{s:<6}  {s}\n", .{
        "module", "coverage", "hit", "total", "bar",
    });
    try writer.writeAll("─────────────────────────────────────────────────────────────────\n");

    // --- Print per-module rows ---------------------------------------------
    for (&summaries) |*s| {
        if (s.total_lines == 0) continue;
        const pct = s.percentage();
        try writer.print("{s:<24} {d:>7.1}%  {d:>6}/{d:<6}  ", .{
            s.name, pct, s.covered_lines, s.total_lines,
        });
        try printBar(writer, pct, 20);
        try writer.writeByte('\n');
    }

    try writer.writeAll("─────────────────────────────────────────────────────────────────\n");
    try writer.print("{s:<24} {d:>7.1}%  {d:>6}/{d:<6}\n\n", .{
        "TOTAL", total_pct, total_covered, total_lines,
    });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Return the index into `module_names` that best matches `source_path`.
/// Falls back to `module_names.len` (the "other" bucket).
fn classifyModule(source_path: []const u8, module_names: []const []const u8) usize {
    for (module_names, 0..) |name, i| {
        if (std.mem.indexOf(u8, source_path, name) != null) return i;
    }
    return module_names.len;
}

/// Print a colored progress bar of `width` chars to `writer`.
/// Covered portion is green, uncovered is red.
fn printBar(writer: *std.Io.Writer, pct: f64, width: u32) !void {
    const filled: u32 = @intFromFloat(@min(pct / 100.0 * @as(f64, @floatFromInt(width)), @as(f64, @floatFromInt(width))));
    const empty = width - filled;

    if (filled > 0) {
        try writer.print("\x1b[32m", .{});
        var i: u32 = 0;
        while (i < filled) : (i += 1) try writer.writeByte('#');
        try writer.print("\x1b[0m", .{});
    }
    if (empty > 0) {
        try writer.print("\x1b[31m", .{});
        var i: u32 = 0;
        while (i < empty) : (i += 1) try writer.writeByte('-');
        try writer.print("\x1b[0m", .{});
    }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

fn openTmpWriter(tmp: *std.testing.TmpDir, name: []const u8, buf: []u8) !struct { f: std.fs.File, w: std.fs.File.Writer } {
    const f = try tmp.dir.createFile(name, .{});
    return .{ .f = f, .w = f.writer(buf) };
}

fn readTmpFile(tmp: *std.testing.TmpDir, name: []const u8) ![]u8 {
    const rf = try tmp.dir.openFile(name, .{});
    const content = try rf.readToEndAlloc(std.testing.allocator, 65536);
    rf.close();
    return content;
}

fn countChar(content: []const u8, ch: u8) usize {
    var n: usize = 0;
    for (content) |c| if (c == ch) {
        n += 1;
    };
    return n;
}

test "ModuleSummary.percentage — normal" {
    const s = ModuleSummary{ .name = "test", .total_lines = 200, .covered_lines = 150 };
    try std.testing.expectApproxEqAbs(@as(f64, 75.0), s.percentage(), 0.01);
}

test "ModuleSummary.percentage — zero total" {
    const s = ModuleSummary{ .name = "empty", .total_lines = 0, .covered_lines = 0 };
    try std.testing.expectEqual(@as(f64, 0.0), s.percentage());
}

test "ModuleSummary.percentage — 100 pct" {
    const s = ModuleSummary{ .name = "full", .total_lines = 50, .covered_lines = 50 };
    try std.testing.expectApproxEqAbs(@as(f64, 100.0), s.percentage(), 0.01);
}

test "ModuleSummary.percentage — small fraction" {
    const s = ModuleSummary{ .name = "low", .total_lines = 1000, .covered_lines = 1 };
    try std.testing.expectApproxEqAbs(@as(f64, 0.1), s.percentage(), 0.01);
}

test "classifyModule — matches known modules" {
    const module_names = [_][]const u8{
        "sdk/core",
        "sdk/domain",
        "sdk/protocol",
        "exchanges/kraken",
        "trading/desk",
        "trading/analytics",
        "trading/strategies",
    };
    try std.testing.expectEqual(@as(usize, 0), classifyModule("/home/user/project/sdk/core/time.zig", &module_names));
    try std.testing.expectEqual(@as(usize, 1), classifyModule("/home/user/project/sdk/domain/oms.zig", &module_names));
    try std.testing.expectEqual(@as(usize, 2), classifyModule("/home/user/project/sdk/protocol/tls/client.zig", &module_names));
    try std.testing.expectEqual(@as(usize, 3), classifyModule("/home/user/project/exchanges/kraken/spot/auth.zig", &module_names));
    try std.testing.expectEqual(@as(usize, 4), classifyModule("/home/user/project/trading/desk/engine.zig", &module_names));
    try std.testing.expectEqual(@as(usize, 5), classifyModule("/home/user/project/trading/analytics/pnl.zig", &module_names));
    try std.testing.expectEqual(@as(usize, 6), classifyModule("/home/user/project/trading/strategies/mm.zig", &module_names));
}

test "classifyModule — falls back to other bucket" {
    const module_names = [_][]const u8{ "sdk/core", "sdk/domain" };
    try std.testing.expectEqual(@as(usize, 2), classifyModule("/some/random/path.zig", &module_names));
}

test "classifyModule — empty path" {
    const module_names = [_][]const u8{"sdk/core"};
    try std.testing.expectEqual(@as(usize, 1), classifyModule("", &module_names));
}

test "classifyModule — first match wins" {
    const module_names = [_][]const u8{ "sdk", "sdk/core" };
    // "sdk" matches first
    try std.testing.expectEqual(@as(usize, 0), classifyModule("/project/sdk/core/time.zig", &module_names));
}

test "printBar — 0 pct produces all dashes" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var buf: [4096]u8 = undefined;
    var state = try openTmpWriter(&tmp, "bar0.txt", &buf);
    try printBar(&state.w.interface, 0.0, 10);
    try state.w.interface.flush();
    state.f.close();

    const content = try readTmpFile(&tmp, "bar0.txt");
    defer std.testing.allocator.free(content);
    try std.testing.expectEqual(@as(usize, 0), countChar(content, '#'));
    try std.testing.expectEqual(@as(usize, 10), countChar(content, '-'));
}

test "printBar — 100 pct produces all hashes" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var buf: [4096]u8 = undefined;
    var state = try openTmpWriter(&tmp, "bar100.txt", &buf);
    try printBar(&state.w.interface, 100.0, 10);
    try state.w.interface.flush();
    state.f.close();

    const content = try readTmpFile(&tmp, "bar100.txt");
    defer std.testing.allocator.free(content);
    try std.testing.expectEqual(@as(usize, 10), countChar(content, '#'));
    try std.testing.expectEqual(@as(usize, 0), countChar(content, '-'));
}

test "printBar — 50 pct produces half and half" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var buf: [4096]u8 = undefined;
    var state = try openTmpWriter(&tmp, "bar50.txt", &buf);
    try printBar(&state.w.interface, 50.0, 20);
    try state.w.interface.flush();
    state.f.close();

    const content = try readTmpFile(&tmp, "bar50.txt");
    defer std.testing.allocator.free(content);
    try std.testing.expectEqual(@as(usize, 10), countChar(content, '#'));
    try std.testing.expectEqual(@as(usize, 10), countChar(content, '-'));
}

test "printBar — width 0 produces nothing" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var buf: [4096]u8 = undefined;
    var state = try openTmpWriter(&tmp, "bar_w0.txt", &buf);
    try printBar(&state.w.interface, 50.0, 0);
    try state.w.interface.flush();
    state.f.close();

    const content = try readTmpFile(&tmp, "bar_w0.txt");
    defer std.testing.allocator.free(content);
    try std.testing.expectEqual(@as(usize, 0), countChar(content, '#'));
    try std.testing.expectEqual(@as(usize, 0), countChar(content, '-'));
}

test "printReport — empty data" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var buf: [65536]u8 = undefined;
    var state = try openTmpWriter(&tmp, "rpt_empty.txt", &buf);
    const empty: []const CoverageData = &.{};
    try printReport(&state.w.interface, empty);
    try state.w.interface.flush();
    state.f.close();

    const content = try readTmpFile(&tmp, "rpt_empty.txt");
    defer std.testing.allocator.free(content);
    try std.testing.expect(std.mem.indexOf(u8, content, "no source files found") != null);
}

test "printReport — single module" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var lines_hit = try std.testing.allocator.alloc(bool, 11);
    defer std.testing.allocator.free(lines_hit);
    @memset(lines_hit, false);
    lines_hit[1] = true;
    lines_hit[3] = true;
    lines_hit[5] = true;
    lines_hit[7] = true;
    lines_hit[9] = true;

    const data = [_]CoverageData{.{
        .source_file = "/project/sdk/core/time.zig",
        .lines_hit = lines_hit,
        .total_lines = 10,
        .covered_lines = 5,
    }};

    var buf: [65536]u8 = undefined;
    var state = try openTmpWriter(&tmp, "rpt_single.txt", &buf);
    try printReport(&state.w.interface, &data);
    try state.w.interface.flush();
    state.f.close();

    const content = try readTmpFile(&tmp, "rpt_single.txt");
    defer std.testing.allocator.free(content);
    try std.testing.expect(std.mem.indexOf(u8, content, "zcov coverage report") != null);
    try std.testing.expect(std.mem.indexOf(u8, content, "sdk/core") != null);
    try std.testing.expect(std.mem.indexOf(u8, content, "TOTAL") != null);
    try std.testing.expect(std.mem.indexOf(u8, content, "50.0%") != null);
}

test "printReport — multiple modules" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var lines1 = try std.testing.allocator.alloc(bool, 21);
    defer std.testing.allocator.free(lines1);
    @memset(lines1, false);
    var i: usize = 1;
    while (i <= 20) : (i += 2) lines1[i] = true;

    var lines2 = try std.testing.allocator.alloc(bool, 11);
    defer std.testing.allocator.free(lines2);
    @memset(lines2, false);
    lines2[1] = true;
    lines2[2] = true;
    lines2[3] = true;

    const data = [_]CoverageData{
        .{ .source_file = "/project/sdk/core/memory.zig", .lines_hit = lines1, .total_lines = 20, .covered_lines = 10 },
        .{ .source_file = "/project/sdk/domain/oms.zig", .lines_hit = lines2, .total_lines = 10, .covered_lines = 3 },
    };

    var buf: [65536]u8 = undefined;
    var state = try openTmpWriter(&tmp, "rpt_multi.txt", &buf);
    try printReport(&state.w.interface, &data);
    try state.w.interface.flush();
    state.f.close();

    const content = try readTmpFile(&tmp, "rpt_multi.txt");
    defer std.testing.allocator.free(content);
    try std.testing.expect(std.mem.indexOf(u8, content, "sdk/core") != null);
    try std.testing.expect(std.mem.indexOf(u8, content, "sdk/domain") != null);
    try std.testing.expect(std.mem.indexOf(u8, content, "TOTAL") != null);
}

test "printReport — other bucket" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var lines_hit = try std.testing.allocator.alloc(bool, 6);
    defer std.testing.allocator.free(lines_hit);
    @memset(lines_hit, false);
    lines_hit[1] = true;
    lines_hit[2] = true;

    const data = [_]CoverageData{.{
        .source_file = "/some/unknown/module/foo.zig",
        .lines_hit = lines_hit,
        .total_lines = 5,
        .covered_lines = 2,
    }};

    var buf: [65536]u8 = undefined;
    var state = try openTmpWriter(&tmp, "rpt_other.txt", &buf);
    try printReport(&state.w.interface, &data);
    try state.w.interface.flush();
    state.f.close();

    const content = try readTmpFile(&tmp, "rpt_other.txt");
    defer std.testing.allocator.free(content);
    try std.testing.expect(std.mem.indexOf(u8, content, "other") != null);
}

test "printReport — all modules represented" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const paths = [_][]const u8{
        "/p/sdk/core/a.zig",
        "/p/sdk/domain/b.zig",
        "/p/sdk/protocol/c.zig",
        "/p/exchanges/kraken/d.zig",
        "/p/trading/desk/e.zig",
        "/p/trading/analytics/f.zig",
        "/p/trading/strategies/g.zig",
        "/p/misc/other.zig",
    };

    var all_lines: [paths.len][]bool = undefined;
    var data: [paths.len]CoverageData = undefined;
    for (paths, 0..) |path, idx| {
        all_lines[idx] = try std.testing.allocator.alloc(bool, 3);
        @memset(all_lines[idx], false);
        all_lines[idx][1] = true;
        data[idx] = .{ .source_file = path, .lines_hit = all_lines[idx], .total_lines = 2, .covered_lines = 1 };
    }
    defer for (&all_lines) |l| std.testing.allocator.free(l);

    var buf: [65536]u8 = undefined;
    var state = try openTmpWriter(&tmp, "rpt_all.txt", &buf);
    try printReport(&state.w.interface, &data);
    try state.w.interface.flush();
    state.f.close();

    const content = try readTmpFile(&tmp, "rpt_all.txt");
    defer std.testing.allocator.free(content);
    try std.testing.expect(std.mem.indexOf(u8, content, "sdk/core") != null);
    try std.testing.expect(std.mem.indexOf(u8, content, "exchanges/kraken") != null);
    try std.testing.expect(std.mem.indexOf(u8, content, "trading/strategies") != null);
    try std.testing.expect(std.mem.indexOf(u8, content, "other") != null);
    try std.testing.expect(std.mem.indexOf(u8, content, "50.0%") != null);
}
