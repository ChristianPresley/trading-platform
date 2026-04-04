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
        try writer.writeAll("zcov: no coverage data found.\n");
        try writer.writeAll("      Run: zig build test -- (tests must be compiled with -ffuzz)\n");
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
