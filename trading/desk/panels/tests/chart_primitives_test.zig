// Tests for chart_primitives.zig — shared chart rendering primitives.
// Covers: SubCell, scaleYSub, smaCompute, Unicode block character constants.

const std = @import("std");
const primitives = @import("chart_primitives");

const SubCell = primitives.SubCell;
const CandleUpdate = primitives.msg.CandleUpdate;

// -- Helper --

fn makeCandle(close: i64) CandleUpdate {
    var c = std.mem.zeroes(CandleUpdate);
    c.close = close;
    return c;
}

fn makeCandleFull(open: i64, high: i64, low: i64, close: i64, volume: i64) CandleUpdate {
    var c = std.mem.zeroes(CandleUpdate);
    c.open = open;
    c.high = high;
    c.low = low;
    c.close = close;
    c.volume = volume;
    return c;
}

// ---- SubCell struct ----

test "SubCell: default values" {
    const s = SubCell{ .row = 0, .half = 0 };
    try std.testing.expectEqual(@as(u16, 0), s.row);
    try std.testing.expectEqual(@as(u1, 0), s.half);
}

test "SubCell: half field is 1-bit (0 or 1)" {
    const top = SubCell{ .row = 5, .half = 0 };
    const bottom = SubCell{ .row = 5, .half = 1 };
    try std.testing.expectEqual(@as(u1, 0), top.half);
    try std.testing.expectEqual(@as(u1, 1), bottom.half);
}

// ---- scaleYSub boundary tests ----

test "scaleYSub: max price maps to top (row=0, half=0)" {
    const top = primitives.scaleYSub(100, 0, 100, 10);
    try std.testing.expectEqual(@as(u16, 0), top.row);
    try std.testing.expectEqual(@as(u1, 0), top.half);
}

test "scaleYSub: min price maps to bottom (row=height-1, half=1)" {
    const bottom = primitives.scaleYSub(0, 0, 100, 10);
    try std.testing.expectEqual(@as(u16, 9), bottom.row);
    try std.testing.expectEqual(@as(u1, 1), bottom.half);
}

test "scaleYSub: midpoint maps to roughly middle" {
    const mid = primitives.scaleYSub(50, 0, 100, 10);
    // total_sub = 19, sub_pos = 19 - 9 = 10, row = 5, half = 0
    // Or with rounding: row 4 or 5
    try std.testing.expect(mid.row >= 4 and mid.row <= 5);
}

test "scaleYSub: flat range returns height/2" {
    const r = primitives.scaleYSub(50, 50, 50, 10);
    try std.testing.expectEqual(@as(u16, 5), r.row);
    try std.testing.expectEqual(@as(u1, 0), r.half);
}

test "scaleYSub: zero height returns {0, 0}" {
    const r = primitives.scaleYSub(50, 0, 100, 0);
    try std.testing.expectEqual(@as(u16, 0), r.row);
    try std.testing.expectEqual(@as(u1, 0), r.half);
}

test "scaleYSub: height=1 gives row 0" {
    const top = primitives.scaleYSub(100, 0, 100, 1);
    try std.testing.expectEqual(@as(u16, 0), top.row);
    try std.testing.expectEqual(@as(u1, 0), top.half);

    const bottom = primitives.scaleYSub(0, 0, 100, 1);
    try std.testing.expectEqual(@as(u16, 0), bottom.row);
    try std.testing.expectEqual(@as(u1, 1), bottom.half);
}

test "scaleYSub: quarter price maps to lower quarter of chart" {
    const r = primitives.scaleYSub(25, 0, 100, 20);
    // 25% from min = 75% from top in sub-cells
    // total_sub = 39, offset = 25, sub_pos = 39 - 25*39/100 = 39 - 9 = 29
    // row = 29/2 = 14, half = 29%2 = 1
    try std.testing.expect(r.row >= 13 and r.row <= 16);
}

test "scaleYSub: three-quarter price maps to upper quarter" {
    const r = primitives.scaleYSub(75, 0, 100, 20);
    // 75% from min = 25% from top
    // total_sub = 39, offset = 75, sub_pos = 39 - 75*39/100 = 39 - 29 = 10
    // row = 10/2 = 5, half = 10%2 = 0
    try std.testing.expect(r.row >= 4 and r.row <= 6);
}

test "scaleYSub: large fixed-point prices" {
    const scale: i64 = 100_000_000;
    const min_p = 50000 * scale;
    const max_p = 51000 * scale;

    const top = primitives.scaleYSub(max_p, min_p, max_p, 30);
    try std.testing.expectEqual(@as(u16, 0), top.row);
    try std.testing.expectEqual(@as(u1, 0), top.half);

    const bottom = primitives.scaleYSub(min_p, min_p, max_p, 30);
    try std.testing.expectEqual(@as(u16, 29), bottom.row);
    try std.testing.expectEqual(@as(u1, 1), bottom.half);
}

test "scaleYSub: negative prices" {
    const r_top = primitives.scaleYSub(0, -100, 0, 10);
    try std.testing.expectEqual(@as(u16, 0), r_top.row);

    const r_bot = primitives.scaleYSub(-100, -100, 0, 10);
    try std.testing.expectEqual(@as(u16, 9), r_bot.row);
    try std.testing.expectEqual(@as(u1, 1), r_bot.half);
}

test "scaleYSub: monotonicity — higher price never below lower price" {
    const height: u16 = 50;
    const min_p: i64 = 0;
    const max_p: i64 = 1000;

    var prev_sub: i64 = -1;
    var p: i64 = max_p;
    while (p >= min_p) : (p -= 50) {
        const s = primitives.scaleYSub(p, min_p, max_p, height);
        const sub_pos = @as(i64, s.row) * 2 + @as(i64, s.half);
        // As price decreases, sub_pos should increase (or stay same)
        try std.testing.expect(sub_pos >= prev_sub);
        prev_sub = sub_pos;
    }
}

// ---- smaCompute tests ----

test "smaCompute: exact 3-period average" {
    const scale: i64 = 100_000_000;
    const candles = [_]CandleUpdate{
        makeCandle(10 * scale),
        makeCandle(20 * scale),
        makeCandle(30 * scale),
        makeCandle(40 * scale),
        makeCandle(50 * scale),
    };

    // SMA(3) at index 4: (30 + 40 + 50) / 3 = 40
    const result = primitives.smaCompute(&candles, 4, 3);
    try std.testing.expect(result != null);
    try std.testing.expectEqual(@as(i64, 40 * scale), result.?);
}

test "smaCompute: period=1 returns the close price itself" {
    const scale: i64 = 100_000_000;
    const candles = [_]CandleUpdate{
        makeCandle(42 * scale),
    };

    const result = primitives.smaCompute(&candles, 0, 1);
    try std.testing.expect(result != null);
    try std.testing.expectEqual(@as(i64, 42 * scale), result.?);
}

test "smaCompute: full period equals simple mean" {
    const candles = [_]CandleUpdate{
        makeCandle(100),
        makeCandle(200),
        makeCandle(300),
        makeCandle(400),
    };

    // SMA(4) at index 3: (100 + 200 + 300 + 400) / 4 = 250
    const result = primitives.smaCompute(&candles, 3, 4);
    try std.testing.expect(result != null);
    try std.testing.expectEqual(@as(i64, 250), result.?);
}

test "smaCompute: insufficient data returns null" {
    var candles: [3]CandleUpdate = undefined;
    for (&candles) |*c| c.* = std.mem.zeroes(CandleUpdate);

    // SMA(5) at index 2: need 5 candles, only have 3 relevant
    const result = primitives.smaCompute(&candles, 2, 5);
    try std.testing.expect(result == null);
}

test "smaCompute: period=0 returns null" {
    const candles = [_]CandleUpdate{makeCandle(100)};
    const result = primitives.smaCompute(&candles, 0, 0);
    try std.testing.expect(result == null);
}

test "smaCompute: index=0, period=1 is valid" {
    const candles = [_]CandleUpdate{makeCandle(500)};
    const result = primitives.smaCompute(&candles, 0, 1);
    try std.testing.expect(result != null);
    try std.testing.expectEqual(@as(i64, 500), result.?);
}

test "smaCompute: index=0, period=2 is insufficient" {
    const candles = [_]CandleUpdate{makeCandle(500), makeCandle(600)};
    // index + 1 = 1 < period = 2
    const result = primitives.smaCompute(&candles, 0, 2);
    try std.testing.expect(result == null);
}

test "smaCompute: sliding window moves correctly" {
    const candles = [_]CandleUpdate{
        makeCandle(10),
        makeCandle(20),
        makeCandle(30),
        makeCandle(40),
        makeCandle(50),
    };

    // SMA(3) at index 2: (10 + 20 + 30) / 3 = 20
    const r2 = primitives.smaCompute(&candles, 2, 3);
    try std.testing.expect(r2 != null);
    try std.testing.expectEqual(@as(i64, 20), r2.?);

    // SMA(3) at index 3: (20 + 30 + 40) / 3 = 30
    const r3 = primitives.smaCompute(&candles, 3, 3);
    try std.testing.expect(r3 != null);
    try std.testing.expectEqual(@as(i64, 30), r3.?);

    // SMA(3) at index 4: (30 + 40 + 50) / 3 = 40
    const r4 = primitives.smaCompute(&candles, 4, 3);
    try std.testing.expect(r4 != null);
    try std.testing.expectEqual(@as(i64, 40), r4.?);
}

test "smaCompute: all same values returns that value" {
    const candles = [_]CandleUpdate{
        makeCandle(100),
        makeCandle(100),
        makeCandle(100),
    };
    const result = primitives.smaCompute(&candles, 2, 3);
    try std.testing.expect(result != null);
    try std.testing.expectEqual(@as(i64, 100), result.?);
}

// ---- Unicode block character constants ----

test "HALF_BLOCK_CHARS: 8 entries, each 3 bytes" {
    try std.testing.expectEqual(@as(usize, 8), primitives.HALF_BLOCK_CHARS.len);
    for (primitives.HALF_BLOCK_CHARS) |ch| {
        try std.testing.expectEqual(@as(usize, 3), ch.len);
        // All should start with 0xe2 (UTF-8 3-byte prefix for U+2xxx)
        try std.testing.expectEqual(@as(u8, 0xe2), ch[0]);
        try std.testing.expectEqual(@as(u8, 0x96), ch[1]);
    }
}

test "HALF_BLOCK_CHARS: sequential from U+2581 to U+2588" {
    // Third byte should go from 0x81 to 0x88
    for (primitives.HALF_BLOCK_CHARS, 0..) |ch, i| {
        try std.testing.expectEqual(@as(u8, 0x81 + @as(u8, @intCast(i))), ch[2]);
    }
}

test "UPPER_HALF: is U+2580 (3 bytes)" {
    try std.testing.expectEqual(@as(usize, 3), primitives.UPPER_HALF.len);
    try std.testing.expectEqual(@as(u8, 0xe2), primitives.UPPER_HALF[0]);
    try std.testing.expectEqual(@as(u8, 0x96), primitives.UPPER_HALF[1]);
    try std.testing.expectEqual(@as(u8, 0x80), primitives.UPPER_HALF[2]);
}

test "FULL_BLOCK: is U+2588 (same as HALF_BLOCK_CHARS[7])" {
    try std.testing.expectEqual(@as(usize, 3), primitives.FULL_BLOCK.len);
    try std.testing.expectEqual(primitives.HALF_BLOCK_CHARS[7][0], primitives.FULL_BLOCK[0]);
    try std.testing.expectEqual(primitives.HALF_BLOCK_CHARS[7][1], primitives.FULL_BLOCK[1]);
    try std.testing.expectEqual(primitives.HALF_BLOCK_CHARS[7][2], primitives.FULL_BLOCK[2]);
}

// ---- Indicator struct ----

test "Indicator: struct has expected fields" {
    const indicator = primitives.Indicator{
        .name = "SMA-20\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".*,
        .name_len = 6,
        .period = 20,
        .color = .{ .r = 0xFF, .g = 0xAB, .b = 0x00 },
        .compute = &primitives.smaCompute,
    };
    try std.testing.expectEqual(@as(u16, 20), indicator.period);
    try std.testing.expectEqual(@as(u8, 6), indicator.name_len);
    try std.testing.expectEqualStrings("SMA-20", indicator.name[0..indicator.name_len]);
}

test "Indicator: compute function pointer is callable" {
    const candles = [_]CandleUpdate{
        makeCandle(10),
        makeCandle(20),
        makeCandle(30),
    };

    const indicator = primitives.Indicator{
        .name = "SMA\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".*,
        .name_len = 3,
        .period = 2,
        .color = .{ .r = 0, .g = 0, .b = 0 },
        .compute = &primitives.smaCompute,
    };

    // Call through the function pointer
    const result = indicator.compute(&candles, 2, indicator.period);
    try std.testing.expect(result != null);
    // SMA(2) at index 2: (20 + 30) / 2 = 25
    try std.testing.expectEqual(@as(i64, 25), result.?);
}
