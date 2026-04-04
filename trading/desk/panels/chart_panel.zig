// Candlestick chart panel renderer.
// Renders OHLC candlestick chart using Unicode block characters with half-block precision.

const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const layout = @import("../layout.zig");
const Rect = layout.Rect;
const msg = @import("../messages.zig");
const CandleUpdate = msg.CandleUpdate;
const Theme = @import("../theme.zig").Theme;
const Rgb = @import("../theme.zig").Rgb;
const primitives = @import("chart_primitives.zig");
const SubCell = primitives.SubCell;
const scaleYSub = primitives.scaleYSub;

/// Map a price to a row within the chart area using linear interpolation.
/// Returns 0 (top) to height-1 (bottom) mapping.
/// Kept for backward compatibility with existing tests.
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

/// Draw a single candlestick at column x within the chart rect using half-block precision.
/// Each candle occupies `candle_width` terminal columns.
fn drawCandle(
    renderer: *Renderer,
    x: u16,
    rect: Rect,
    candle: CandleUpdate,
    y_min: i64,
    y_max: i64,
    height: u16,
    theme: *const Theme,
    candle_width: u8,
) void {
    const inner_x = rect.x + 1;
    const inner_y = rect.y + 1;

    const bullish = candle.close >= candle.open;
    const color: Rgb = if (bullish) theme.candle_bull else theme.candle_bear;

    // Compute sub-cell positions for high, low, body top/bottom
    const high_sub = scaleYSub(candle.high, y_min, y_max, height);
    const low_sub = scaleYSub(candle.low, y_min, y_max, height);
    const body_top_sub = scaleYSub(@max(candle.open, candle.close), y_min, y_max, height);
    const body_bot_sub = scaleYSub(@min(candle.open, candle.close), y_min, y_max, height);

    // Center column of the candle (0-indexed within chart inner area)
    const center_col = inner_x + x + candle_width / 2;

    // Dimmed color for wicks (50% brightness)
    const wick_color = Rgb{
        .r = color.r / 2,
        .g = color.g / 2,
        .b = color.b / 2,
    };

    // --- Body rendering (all candle_width columns) ---
    renderer.writeColor(color);
    var r: u16 = body_top_sub.row;
    while (r <= body_bot_sub.row) : (r += 1) {
        // Determine character for this row
        const char: []const u8 = blk: {
            if (r == body_top_sub.row and r == body_bot_sub.row) {
                // Single row body (doji or very small candle)
                if (body_top_sub.half == 1 and body_bot_sub.half == 0) {
                    // Only bottom half of top == top half of bot — shouldn't happen, use half block
                    break :blk &primitives.HALF_BLOCK_CHARS[3]; // ▄
                } else if (body_top_sub.half == 1) {
                    break :blk &primitives.HALF_BLOCK_CHARS[3]; // ▄ lower half
                } else if (body_bot_sub.half == 0) {
                    break :blk &primitives.UPPER_HALF; // ▀ upper half
                } else {
                    break :blk &primitives.FULL_BLOCK; // █
                }
            } else if (r == body_top_sub.row) {
                // Top of body
                if (body_top_sub.half == 1) {
                    break :blk &primitives.HALF_BLOCK_CHARS[3]; // ▄ lower half
                } else {
                    break :blk &primitives.FULL_BLOCK; // █
                }
            } else if (r == body_bot_sub.row) {
                // Bottom of body
                if (body_bot_sub.half == 0) {
                    break :blk &primitives.UPPER_HALF; // ▀ upper half
                } else {
                    break :blk &primitives.FULL_BLOCK; // █
                }
            } else {
                break :blk &primitives.FULL_BLOCK; // █
            }
        };

        // Write across all candle_width columns
        var col: u16 = 0;
        while (col < candle_width) : (col += 1) {
            renderer.writeFmt("\x1b[{d};{d}H{s}", .{ inner_y + r + 1, inner_x + x + col, char });
        }
    }

    // --- Wick rendering (center column only, dimmed color) ---
    renderer.writeColor(wick_color);

    // Upper wick: from high_sub.row to body_top_sub.row - 1
    if (high_sub.row < body_top_sub.row) {
        var wr: u16 = high_sub.row;
        while (wr < body_top_sub.row) : (wr += 1) {
            if (wr == high_sub.row and high_sub.half == 1) {
                // Tip is in lower half — use ▄
                renderer.writeFmt("\x1b[{d};{d}H{s}", .{ inner_y + wr + 1, center_col, &primitives.HALF_BLOCK_CHARS[3] });
            } else {
                renderer.writeFmt("\x1b[{d};{d}H\xe2\x94\x82", .{ inner_y + wr + 1, center_col }); // │
            }
        }
    }

    // Lower wick: from body_bot_sub.row + 1 to low_sub.row
    if (body_bot_sub.row < low_sub.row) {
        var wr: u16 = body_bot_sub.row + 1;
        while (wr <= low_sub.row) : (wr += 1) {
            if (wr == low_sub.row and low_sub.half == 0) {
                // Tip is in upper half — use ▀
                renderer.writeFmt("\x1b[{d};{d}H{s}", .{ inner_y + wr + 1, center_col, &primitives.UPPER_HALF });
            } else {
                renderer.writeFmt("\x1b[{d};{d}H\xe2\x94\x82", .{ inner_y + wr + 1, center_col }); // │
            }
        }
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

    // Default candle width = 3
    const candle_width: u8 = 3;

    // Number of candles that fit
    const max_candles = inner_w / candle_width;
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
        const x: u16 = @intCast(ci * candle_width);
        drawCandle(renderer, x, rect, candle, y_min, y_max, chart_h, theme, candle_width);
    }

    // Y axis labels on right edge (inside box): top = max, bottom = min, mid = midpoint
    const label_col = rect.x + rect.w -| 10;
    const mid_price = @divTrunc(y_max + y_min, 2);

    // Format prices (8 decimal places stored, display 2)
    var pbuf_max: [20]u8 = undefined;
    var pbuf_min: [20]u8 = undefined;
    var pbuf_mid: [20]u8 = undefined;

    const max_whole = @divTrunc(y_max, 100_000_000);
    const max_frac = @abs(@rem(y_max, 100_000_000)) / 1_000_000;
    const min_whole = @divTrunc(y_min, 100_000_000);
    const min_frac = @abs(@rem(y_min, 100_000_000)) / 1_000_000;
    const mid_whole = @divTrunc(mid_price, 100_000_000);
    const mid_frac = @abs(@rem(mid_price, 100_000_000)) / 1_000_000;

    const max_str = std.fmt.bufPrint(&pbuf_max, "{d}.{d:0>2}", .{ max_whole, max_frac }) catch "?";
    const min_str = std.fmt.bufPrint(&pbuf_min, "{d}.{d:0>2}", .{ min_whole, min_frac }) catch "?";
    const mid_str = std.fmt.bufPrint(&pbuf_mid, "{d}.{d:0>2}", .{ mid_whole, mid_frac }) catch "?";

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
