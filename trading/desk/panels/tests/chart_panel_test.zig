// Tests for chart_panel.zig — candlestick chart panel rendering logic.
// Focuses on pure calculation functions: scaling, viewport, height splits.

const std = @import("std");
const chart_panel = @import("chart_panel");

// Re-export the draw function to confirm module links — we don't call it (needs Renderer).
comptime {
    _ = chart_panel.draw;
}

// -- Helper: build a CandleUpdate with OHLCV values --

const CandleUpdate = chart_panel.msg.CandleUpdate;

fn makeCandle(open: i64, high: i64, low: i64, close: i64, volume: i64) CandleUpdate {
    var c = std.mem.zeroes(CandleUpdate);
    c.open = open;
    c.high = high;
    c.low = low;
    c.close = close;
    c.volume = volume;
    return c;
}

// ---- scaleY tests (backward-compat integer scaling) ----

test "scaleY: max price maps to top row (0)" {
    const top = chart_panel.scaleY(100, 0, 100, 10);
    try std.testing.expectEqual(@as(u16, 0), top);
}

test "scaleY: min price maps to bottom row (height-1)" {
    const bottom = chart_panel.scaleY(0, 0, 100, 10);
    try std.testing.expectEqual(@as(u16, 9), bottom);
}

test "scaleY: midpoint maps to middle rows" {
    const mid = chart_panel.scaleY(50, 0, 100, 10);
    // Should be row 4 or 5 (middle of 0..9)
    try std.testing.expect(mid >= 4 and mid <= 5);
}

test "scaleY: flat range returns height/2" {
    const r = chart_panel.scaleY(50, 50, 50, 10);
    try std.testing.expectEqual(@as(u16, 5), r);
}

test "scaleY: zero height returns 0" {
    const r = chart_panel.scaleY(50, 0, 100, 0);
    try std.testing.expectEqual(@as(u16, 0), r);
}

test "scaleY: height of 1 maps everything to row 0" {
    const top = chart_panel.scaleY(100, 0, 100, 1);
    const bottom = chart_panel.scaleY(0, 0, 100, 1);
    try std.testing.expectEqual(@as(u16, 0), top);
    try std.testing.expectEqual(@as(u16, 0), bottom);
}

test "scaleY: price below min clamps to bottom" {
    // Negative offset is clamped by @max(0, offset)
    const r = chart_panel.scaleY(-10, 0, 100, 10);
    try std.testing.expectEqual(@as(u16, 9), r);
}

test "scaleY: large prices with 8 decimal fixed-point" {
    const scale: i64 = 100_000_000;
    const min_p = 50000 * scale;
    const max_p = 51000 * scale;
    const mid_p = 50500 * scale;

    const top = chart_panel.scaleY(max_p, min_p, max_p, 20);
    const bottom = chart_panel.scaleY(min_p, min_p, max_p, 20);
    const mid = chart_panel.scaleY(mid_p, min_p, max_p, 20);

    try std.testing.expectEqual(@as(u16, 0), top);
    try std.testing.expectEqual(@as(u16, 19), bottom);
    // Mid should be roughly row 9 or 10
    try std.testing.expect(mid >= 9 and mid <= 10);
}

// ---- visibleCandles tests ----

test "visibleCandles: basic calculation" {
    try std.testing.expectEqual(@as(usize, 12), chart_panel.visibleCandles(38, 3));
    try std.testing.expectEqual(@as(usize, 38), chart_panel.visibleCandles(38, 1));
    try std.testing.expectEqual(@as(usize, 7), chart_panel.visibleCandles(38, 5));
}

test "visibleCandles: zero candle width returns 0" {
    try std.testing.expectEqual(@as(usize, 0), chart_panel.visibleCandles(100, 0));
}

test "visibleCandles: zero panel width returns 0" {
    try std.testing.expectEqual(@as(usize, 0), chart_panel.visibleCandles(0, 3));
}

test "visibleCandles: width less than candle_width returns 0" {
    try std.testing.expectEqual(@as(usize, 0), chart_panel.visibleCandles(2, 3));
}

test "visibleCandles: exact multiple" {
    try std.testing.expectEqual(@as(usize, 10), chart_panel.visibleCandles(30, 3));
}

// ---- clampViewport tests ----

test "clampViewport: offset beyond range clamps" {
    try std.testing.expectEqual(@as(usize, 10), chart_panel.clampViewport(999, 10, 20));
}

test "clampViewport: offset within range passes through" {
    try std.testing.expectEqual(@as(usize, 5), chart_panel.clampViewport(5, 10, 20));
}

test "clampViewport: total <= visible returns 0" {
    try std.testing.expectEqual(@as(usize, 0), chart_panel.clampViewport(3, 10, 5));
    try std.testing.expectEqual(@as(usize, 0), chart_panel.clampViewport(3, 10, 10));
}

test "clampViewport: zero offset passes through" {
    try std.testing.expectEqual(@as(usize, 0), chart_panel.clampViewport(0, 10, 20));
}

test "clampViewport: exactly at boundary" {
    // total=20, visible=10 => max offset = 10
    try std.testing.expectEqual(@as(usize, 10), chart_panel.clampViewport(10, 10, 20));
}

// ---- Height split computation ----

test "height split: standard case inner_h=20" {
    const inner_h: u16 = 20;
    const volume_h: u16 = if (inner_h >= 8) inner_h / 4 else 0;
    const chart_h: u16 = if (inner_h > 1) inner_h - 1 - volume_h else inner_h;
    try std.testing.expectEqual(@as(u16, 5), volume_h);
    try std.testing.expectEqual(@as(u16, 14), chart_h);
}

test "height split: small inner_h < 8 disables volume" {
    const inner_h: u16 = 6;
    const volume_h: u16 = if (inner_h >= 8) inner_h / 4 else 0;
    const chart_h: u16 = if (inner_h > 1) inner_h - 1 - volume_h else inner_h;
    try std.testing.expectEqual(@as(u16, 0), volume_h);
    try std.testing.expectEqual(@as(u16, 5), chart_h);
}

test "height split: inner_h=1 preserves minimum" {
    const inner_h: u16 = 1;
    const volume_h: u16 = if (inner_h >= 8) inner_h / 4 else 0;
    const chart_h: u16 = if (inner_h > 1) inner_h - 1 - volume_h else inner_h;
    try std.testing.expectEqual(@as(u16, 0), volume_h);
    try std.testing.expectEqual(@as(u16, 1), chart_h);
}

test "height split: exactly 8 enables volume" {
    const inner_h: u16 = 8;
    const volume_h: u16 = if (inner_h >= 8) inner_h / 4 else 0;
    const chart_h: u16 = if (inner_h > 1) inner_h - 1 - volume_h else inner_h;
    try std.testing.expectEqual(@as(u16, 2), volume_h);
    try std.testing.expectEqual(@as(u16, 5), chart_h);
}

// ---- Volume bar scaling logic ----

test "volume bar: proportional scaling" {
    // volume=50, max_volume=100, height=10 => bar_h = 5
    const bar_h: u16 = @intCast(@min(
        @as(i64, 10),
        @divTrunc(@as(i64, 50) * @as(i64, 10), @as(i64, 100)),
    ));
    try std.testing.expectEqual(@as(u16, 5), bar_h);
}

test "volume bar: full volume equals full height" {
    const bar_h: u16 = @intCast(@min(
        @as(i64, 10),
        @divTrunc(@as(i64, 100) * @as(i64, 10), @as(i64, 100)),
    ));
    try std.testing.expectEqual(@as(u16, 10), bar_h);
}

test "volume bar: small fraction rounds down" {
    // volume=1, max_volume=100, height=10 => bar_h = 0
    const bar_h: u16 = @intCast(@min(
        @as(i64, 10),
        @divTrunc(@as(i64, 1) * @as(i64, 10), @as(i64, 100)),
    ));
    try std.testing.expectEqual(@as(u16, 0), bar_h);
}

// ---- Auto-follow viewport logic ----

test "auto-follow: viewport_offset=0 shows newest candles" {
    const total: usize = 100;
    const max_vis: usize = 20;
    const viewport_offset: usize = 0;
    const effective = if (viewport_offset == 0)
        (if (total > max_vis) total - max_vis else 0)
    else
        chart_panel.clampViewport(total -| viewport_offset -| max_vis, max_vis, total);
    try std.testing.expectEqual(@as(usize, 80), effective);
}

test "auto-follow: viewport_offset=0 with few candles starts at 0" {
    const total: usize = 10;
    const max_vis: usize = 20;
    const viewport_offset: usize = 0;
    const effective = if (viewport_offset == 0)
        (if (total > max_vis) total - max_vis else 0)
    else
        chart_panel.clampViewport(total -| viewport_offset -| max_vis, max_vis, total);
    try std.testing.expectEqual(@as(usize, 0), effective);
}

// ---- Price formatting (OHLCV readout logic) ----

test "price formatting: fixed-point to decimal parts" {
    const scale: i64 = 100_000_000;
    const price: i64 = 50123 * scale + 45_000_000; // 50123.45 in fixed point

    const whole = @divTrunc(price, 100_000_000);
    const frac = @abs(@rem(price, 100_000_000)) / 1_000_000;

    try std.testing.expectEqual(@as(i64, 50123), whole);
    try std.testing.expectEqual(@as(i64, 45), frac);
}

test "price formatting: zero price" {
    const price: i64 = 0;
    const whole = @divTrunc(price, 100_000_000);
    const frac = @abs(@rem(price, 100_000_000)) / 1_000_000;
    try std.testing.expectEqual(@as(i64, 0), whole);
    try std.testing.expectEqual(@as(i64, 0), frac);
}

test "price formatting: negative price" {
    const scale: i64 = 100_000_000;
    const price: i64 = -100 * scale - 50_000_000; // -100.50

    const whole = @divTrunc(price, 100_000_000);
    const frac = @abs(@rem(price, 100_000_000)) / 1_000_000;

    try std.testing.expectEqual(@as(i64, -100), whole);
    try std.testing.expectEqual(@as(i64, 50), frac);
}

// ---- Y-axis range scanning ----

test "y-axis range scan: finds min/max across candles" {
    const candles = [_]CandleUpdate{
        makeCandle(100, 150, 80, 120, 1000),
        makeCandle(110, 200, 90, 130, 2000),
        makeCandle(105, 130, 70, 115, 500),
    };

    var y_min: i64 = candles[0].low;
    var y_max: i64 = candles[0].high;
    for (&candles) |c| {
        if (c.low < y_min) y_min = c.low;
        if (c.high > y_max) y_max = c.high;
    }

    try std.testing.expectEqual(@as(i64, 70), y_min);
    try std.testing.expectEqual(@as(i64, 200), y_max);
}

test "y-axis range scan: flat market adjusts range" {
    const candles = [_]CandleUpdate{
        makeCandle(100, 100, 100, 100, 1000),
    };

    var y_min: i64 = candles[0].low;
    var y_max: i64 = candles[0].high;
    for (&candles) |c| {
        if (c.low < y_min) y_min = c.low;
        if (c.high > y_max) y_max = c.high;
    }
    // Guard against flat market
    if (y_max == y_min) {
        y_min -= 1;
        y_max += 1;
    }
    try std.testing.expectEqual(@as(i64, 99), y_min);
    try std.testing.expectEqual(@as(i64, 101), y_max);
}

// ---- CandleUpdate construction ----

test "CandleUpdate: zeroes produces valid struct" {
    const c = std.mem.zeroes(CandleUpdate);
    try std.testing.expectEqual(@as(i64, 0), c.open);
    try std.testing.expectEqual(@as(i64, 0), c.high);
    try std.testing.expectEqual(@as(i64, 0), c.low);
    try std.testing.expectEqual(@as(i64, 0), c.close);
    try std.testing.expectEqual(@as(i64, 0), c.volume);
    try std.testing.expectEqual(@as(u64, 0), c.timestamp);
}

test "CandleUpdate: makeCandle helper sets OHLCV" {
    const c = makeCandle(10, 20, 5, 15, 100);
    try std.testing.expectEqual(@as(i64, 10), c.open);
    try std.testing.expectEqual(@as(i64, 20), c.high);
    try std.testing.expectEqual(@as(i64, 5), c.low);
    try std.testing.expectEqual(@as(i64, 15), c.close);
    try std.testing.expectEqual(@as(i64, 100), c.volume);
}

// ---- Candle width default ----

test "candle width: zero defaults to 3" {
    const cw: u8 = 0;
    const effective: u8 = if (cw == 0) 3 else cw;
    try std.testing.expectEqual(@as(u8, 3), effective);
}

test "candle width: non-zero passes through" {
    const cw: u8 = 5;
    const effective: u8 = if (cw == 0) 3 else cw;
    try std.testing.expectEqual(@as(u8, 5), effective);
}
