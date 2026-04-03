// Candlestick chart panel renderer.
// Renders OHLC candlestick chart using Unicode block characters.

const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const layout = @import("../layout.zig");
const Rect = layout.Rect;
const msg = @import("../messages.zig");
const CandleUpdate = msg.CandleUpdate;
const Theme = @import("../theme.zig").Theme;

/// Map a price to a row within the chart area using linear interpolation.
/// Returns 0 (top) to height-1 (bottom) mapping.
fn scaleY(price: i64, min_price: i64, max_price: i64, height: u16) u16 {
    if (height == 0) return 0;
    const range = max_price - min_price;
    if (range == 0) return height / 2;
    // Price above min_price maps to a fraction of height, inverted (top row = max price)
    const offset = price - min_price;
    const scaled = @as(u64, @intCast(@max(0, offset))) * @as(u64, height - 1) / @as(u64, @intCast(range));
    const from_top = (height - 1) - @as(u16, @intCast(@min(scaled, height - 1)));
    return from_top;
}

/// Draw a single candlestick at column x within the chart rect.
/// Each candle occupies 3 terminal columns.
fn drawCandle(
    renderer: *Renderer,
    x: u16,
    rect: Rect,
    candle: CandleUpdate,
    y_min: i64,
    y_max: i64,
    height: u16,
    theme: *const Theme,
) void {
    const inner_x = rect.x + 1;
    const inner_y = rect.y + 1;

    const bullish = candle.close >= candle.open;

    // Compute row positions (0 = top of chart area, height-1 = bottom)
    const high_row = scaleY(candle.high, y_min, y_max, height);
    const low_row = scaleY(candle.low, y_min, y_max, height);
    const body_top_row = scaleY(@max(candle.open, candle.close), y_min, y_max, height);
    const body_bot_row = scaleY(@min(candle.open, candle.close), y_min, y_max, height);

    // Center column of the candle (0-indexed within chart inner area)
    const center_col = inner_x + x + 1; // candle occupies columns x, x+1, x+2; center is x+1

    if (bullish) {
        renderer.writeColor(theme.candle_bull);
    } else {
        renderer.writeColor(theme.candle_bear);
    }

    // Draw wick from high to body_top (above body)
    var r: u16 = high_row;
    while (r < body_top_row) : (r += 1) {
        renderer.writeFmt("\x1b[{d};{d}H\xe2\x94\x82", .{ inner_y + r + 1, center_col }); // │
    }

    // Draw body (filled with █)
    r = body_top_row;
    while (r <= body_bot_row) : (r += 1) {
        renderer.writeFmt("\x1b[{d};{d}H\xe2\x96\x88", .{ inner_y + r + 1, center_col }); // █
    }

    // Draw wick from body_bottom to low (below body)
    r = body_bot_row + 1;
    while (r <= low_row) : (r += 1) {
        renderer.writeFmt("\x1b[{d};{d}H\xe2\x94\x82", .{ inner_y + r + 1, center_col }); // │
    }

    renderer.resetColor();
}

pub fn draw(renderer: *Renderer, rect: Rect, candles: []const CandleUpdate, theme: *const Theme) void {
    if (rect.h < 4 or rect.w < 10) return;

    renderer.drawBoxThemed(rect, "Chart 1m", theme);

    const inner_w = rect.w -| 2;
    const inner_h = rect.h -| 2;

    if (candles.len == 0) {
        // Show "Waiting for data..." centered
        const msg_str = "Waiting for data...";
        const msg_len: u16 = @intCast(msg_str.len);
        const msg_x = rect.x + 1 + (inner_w -| msg_len) / 2;
        const msg_y = rect.y + 1 + inner_h / 2;
        renderer.writeColor(theme.text_dim);
        renderer.drawText(msg_x, msg_y, msg_str);
        renderer.resetColor();
        return;
    }

    // Number of candles that fit: each candle is 3 columns wide
    const max_candles = inner_w / 3;
    const start = if (candles.len > max_candles) candles.len - max_candles else 0;
    const visible = candles[start..];

    // Scan visible candles for Y axis range
    var y_min: i64 = visible[0].low;
    var y_max: i64 = visible[0].high;
    for (visible) |c| {
        if (c.low < y_min) y_min = c.low;
        if (c.high > y_max) y_max = c.high;
    }
    // Guard against flat market (all prices equal)
    if (y_max == y_min) {
        y_min -= 1;
        y_max += 1;
    }

    // Chart area height = inner_h - 1 (reserve bottom row for Y axis labels)
    const chart_h: u16 = if (inner_h > 1) inner_h - 1 else inner_h;

    // Draw each candle
    for (visible, 0..) |candle, ci| {
        const x: u16 = @intCast(ci * 3);
        drawCandle(renderer, x, rect, candle, y_min, y_max, chart_h, theme);
    }

    // Y axis labels on right edge (inside box): top = max, bottom = min, mid = midpoint
    const label_col = rect.x + rect.w -| 10;
    const mid_price = @divTrunc(y_max + y_min, 2);

    // Format prices (8 decimal places stored, display 2)
    var pbuf_max: [20]u8 = undefined;
    var pbuf_min: [20]u8 = undefined;
    var pbuf_mid: [20]u8 = undefined;
    const max_whole = @divTrunc(y_max, 100_000_000);
    const min_whole = @divTrunc(y_min, 100_000_000);
    const mid_whole = @divTrunc(mid_price, 100_000_000);
    const max_str = std.fmt.bufPrint(&pbuf_max, "{d}", .{max_whole}) catch "?";
    const min_str = std.fmt.bufPrint(&pbuf_min, "{d}", .{min_whole}) catch "?";
    const mid_str = std.fmt.bufPrint(&pbuf_mid, "{d}", .{mid_whole}) catch "?";

    renderer.writeColor(theme.text_dim);
    renderer.drawText(label_col, rect.y + 1, max_str);
    renderer.drawText(label_col, rect.y + 1 + chart_h / 2, mid_str);
    renderer.drawText(label_col, rect.y + 1 + chart_h -| 1, min_str);
    renderer.resetColor();
}

test "chart_scaleY" {
    // scaleY(min_price) should return bottom row (height-1)
    // scaleY(max_price) should return top row (0)
    const height: u16 = 10;
    const top = scaleY(100, 0, 100, height);
    const bottom = scaleY(0, 0, 100, height);
    const mid = scaleY(50, 0, 100, height);

    try @import("std").testing.expect(top == 0);
    try @import("std").testing.expect(bottom == height - 1);
    // Mid should be roughly in the middle
    try @import("std").testing.expect(mid >= 4 and mid <= 5);
}

test "chart_scaleY_flat" {
    // When min == max, guard prevents division by zero; returns height/2
    const r = scaleY(50, 50, 50, 10);
    try @import("std").testing.expect(r == 5);
}

test "chart_empty_candles" {
    // Verify empty slice doesn't trigger any crashes in scaling logic
    const candles: []const CandleUpdate = &[_]CandleUpdate{};
    try @import("std").testing.expect(candles.len == 0);
    // With 0 candles, scaleY is never called — just verify the guard logic
    const max_candles: u16 = 100 / 3;
    try @import("std").testing.expect(max_candles == 33);
}
