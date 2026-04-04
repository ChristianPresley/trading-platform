// Shared chart rendering primitives.
// Half-block characters, sub-cell scaling, and indicator framework.

const std = @import("std");
const Rgb = @import("../theme.zig").Rgb;
const CandleUpdate = @import("../messages.zig").CandleUpdate;

/// The 8 lower-block Unicode characters ▁▂▃▄▅▆▇█ (U+2581..U+2588).
/// Each is 3 bytes in UTF-8.
pub const HALF_BLOCK_CHARS: [8][3]u8 = .{
    .{ 0xe2, 0x96, 0x81 }, // ▁ U+2581
    .{ 0xe2, 0x96, 0x82 }, // ▂ U+2582
    .{ 0xe2, 0x96, 0x83 }, // ▃ U+2583
    .{ 0xe2, 0x96, 0x84 }, // ▄ U+2584
    .{ 0xe2, 0x96, 0x85 }, // ▅ U+2585
    .{ 0xe2, 0x96, 0x86 }, // ▆ U+2586
    .{ 0xe2, 0x96, 0x87 }, // ▇ U+2587
    .{ 0xe2, 0x96, 0x88 }, // █ U+2588
};

/// Upper-half block ▀ (U+2580).
pub const UPPER_HALF: [3]u8 = .{ 0xe2, 0x96, 0x80 };

/// Full block █ (U+2588).
pub const FULL_BLOCK: [3]u8 = .{ 0xe2, 0x96, 0x88 };

/// A sub-cell position within the chart area.
/// Divides each terminal row into top and bottom halves for 2x vertical resolution.
pub const SubCell = struct {
    row: u16,  // terminal row (0 = top of chart area)
    half: u1,  // 0 = top half, 1 = bottom half
};

/// Map a price to a sub-cell position using 2x vertical resolution.
/// Returns SubCell with row and half (0=top, 1=bottom).
/// price=max_price → SubCell{0, 0} (top); price=min_price → SubCell{height-1, 1} (bottom).
pub fn scaleYSub(price: i64, min_price: i64, max_price: i64, height: u16) SubCell {
    if (height == 0) return SubCell{ .row = 0, .half = 0 };
    const range = max_price - min_price;
    if (range == 0) return SubCell{ .row = height / 2, .half = 0 };

    const total_sub = @as(i64, height) * 2 - 1;
    const offset = price - min_price;
    // sub_pos: 0 = top (max price), total_sub = bottom (min price)
    const sub_pos = total_sub - @divTrunc(offset * total_sub, range);
    const clamped = @min(@max(sub_pos, 0), total_sub);
    return SubCell{
        .row = @intCast(@divTrunc(clamped, 2)),
        .half = @intCast(@mod(clamped, 2)),
    };
}

/// Indicator definition for overlay lines on the price chart.
pub const Indicator = struct {
    name: [16]u8,
    name_len: u8,
    period: u16,
    color: Rgb,
    compute: *const fn (candles: []const CandleUpdate, index: usize, period: u16) ?i64,
};

/// Compute Simple Moving Average of close prices.
/// Returns null if there is insufficient data (index + 1 < period).
pub fn smaCompute(candles: []const CandleUpdate, index: usize, period: u16) ?i64 {
    if (period == 0) return null;
    if (index + 1 < period) return null;
    var sum: i64 = 0;
    for (candles[index + 1 - period .. index + 1]) |c| {
        sum += c.close;
    }
    return @divTrunc(sum, @as(i64, period));
}

// --- Tests ---

test "scaleYSub_boundaries" {
    // Max price → SubCell{0, 0} (top)
    const top = scaleYSub(100, 0, 100, 10);
    try std.testing.expectEqual(@as(u16, 0), top.row);
    try std.testing.expectEqual(@as(u1, 0), top.half);

    // Min price → bottom (row = height-1, half = 1)
    const bottom = scaleYSub(0, 0, 100, 10);
    try std.testing.expectEqual(@as(u16, 9), bottom.row);
    try std.testing.expectEqual(@as(u1, 1), bottom.half);

    // Midpoint → roughly middle
    const mid = scaleYSub(50, 0, 100, 10);
    // total_sub = 19, sub_pos = 19 - 9 = 9 (or 10 depending on rounding), row ~ 4 or 5
    try std.testing.expect(mid.row >= 4 and mid.row <= 5);
}

test "scaleYSub_flat_range" {
    // When range == 0, returns height/2
    const r = scaleYSub(50, 50, 50, 10);
    try std.testing.expectEqual(@as(u16, 5), r.row);
    try std.testing.expectEqual(@as(u1, 0), r.half);
}

test "scaleYSub_zero_height" {
    // height == 0 returns {0, 0}
    const r = scaleYSub(50, 0, 100, 0);
    try std.testing.expectEqual(@as(u16, 0), r.row);
    try std.testing.expectEqual(@as(u1, 0), r.half);
}

test "smaCompute_exact" {
    const msg = @import("../messages.zig");
    // 5 candles with close prices: 10, 20, 30, 40, 50 (stored as fixed-point * 100_000_000)
    const scale: i64 = 100_000_000;
    var candles: [5]msg.CandleUpdate = undefined;
    candles[0] = std.mem.zeroes(msg.CandleUpdate);
    candles[0].close = 10 * scale;
    candles[1] = std.mem.zeroes(msg.CandleUpdate);
    candles[1].close = 20 * scale;
    candles[2] = std.mem.zeroes(msg.CandleUpdate);
    candles[2].close = 30 * scale;
    candles[3] = std.mem.zeroes(msg.CandleUpdate);
    candles[3].close = 40 * scale;
    candles[4] = std.mem.zeroes(msg.CandleUpdate);
    candles[4].close = 50 * scale;

    // SMA(3) at index 4: (30 + 40 + 50) / 3 = 40
    const result = smaCompute(&candles, 4, 3);
    try std.testing.expect(result != null);
    try std.testing.expectEqual(@as(i64, 40 * scale), result.?);
}

test "smaCompute_insufficient" {
    const msg = @import("../messages.zig");
    var candles: [3]msg.CandleUpdate = undefined;
    for (&candles) |*c| c.* = std.mem.zeroes(msg.CandleUpdate);

    // SMA(5) at index 2: 2+1=3 < 5, should return null
    const result = smaCompute(&candles, 2, 5);
    try std.testing.expect(result == null);
}

test "half_block_chars_length" {
    // Verify 8 entries, each 3 bytes
    try std.testing.expectEqual(@as(usize, 8), HALF_BLOCK_CHARS.len);
    for (HALF_BLOCK_CHARS) |ch| {
        try std.testing.expectEqual(@as(usize, 3), ch.len);
    }
}
