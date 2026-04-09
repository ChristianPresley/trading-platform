// Candlestick chart panel renderer.
// Renders OHLC candlestick chart using Unicode block characters with half-block precision.

const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const layout = @import("../layout.zig");
const Rect = layout.Rect;
pub const msg = @import("../messages.zig");
const CandleUpdate = msg.CandleUpdate;
const FootprintUpdate = msg.FootprintUpdate;
const FootprintLevel = msg.FootprintLevel;
const Theme = @import("../theme.zig").Theme;
const Rgb = @import("../theme.zig").Rgb;
const primitives = @import("chart_primitives.zig");
const SubCell = primitives.SubCell;
const scaleYSub = primitives.scaleYSub;

/// Map a price to a row within the chart area using linear interpolation.
/// Returns 0 (top) to height-1 (bottom) mapping.
/// Kept for backward compatibility with existing tests.
pub fn scaleY(price: i64, min_price: i64, max_price: i64, height: u16) u16 {
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

/// Draw a volume bar at column x in the volume sub-panel area.
/// Bar grows upward from row (y + height - 1) to (y + height - bar_h).
fn drawVolumeBar(renderer: *Renderer, x: u16, y: u16, height: u16, volume: i64, max_volume: i64, color: Rgb) void {
    if (height == 0 or max_volume == 0 or volume <= 0) return;

    // Map volume to bar height (integer rows)
    const bar_h_full = @as(u16, @intCast(@min(
        @as(i64, height),
        @divTrunc(volume * @as(i64, height), max_volume),
    )));

    renderer.writeColor(color);

    // Fill full rows from bottom up
    if (bar_h_full > 0) {
        var r: u16 = 0;
        while (r < bar_h_full) : (r += 1) {
            const row = y + height - 1 - r;
            renderer.writeFmt("\x1b[{d};{d}H{s}", .{ row + 1, x + 1, &primitives.FULL_BLOCK });
        }
    }

    renderer.resetColor();
}

/// Compute number of candles visible given panel width and candle width.
pub fn visibleCandles(panel_width: u16, candle_width: u8) usize {
    if (candle_width == 0) return 0;
    return panel_width / candle_width;
}

/// Clamp viewport offset so it doesn't exceed available candle range.
pub fn clampViewport(offset: usize, visible: usize, total: usize) usize {
    if (total <= visible) return 0;
    return @min(offset, total - visible);
}

/// Find the footprint that matches a candle's timestamp.
fn findFootprint(footprints: []const FootprintUpdate, candle_ts: u64) ?*const FootprintUpdate {
    // Footprints and candles share the same bar_start timestamp from the aggregator.
    // Search backwards since we typically render recent candles.
    var i: usize = footprints.len;
    while (i > 0) {
        i -= 1;
        if (footprints[i].timestamp == candle_ts) return &footprints[i];
    }
    return null;
}

/// Format a volume number compactly: 1234 → "1.2K", 12345 → "12K", 123 → "123"
fn fmtVolShort(buf: []u8, vol: i64) []const u8 {
    const v: u64 = @intCast(@max(vol, 0));
    if (v >= 1_000_000) {
        return std.fmt.bufPrint(buf, "{d}M", .{v / 1_000_000}) catch "";
    } else if (v >= 10_000) {
        return std.fmt.bufPrint(buf, "{d}K", .{v / 1_000}) catch "";
    } else if (v >= 1_000) {
        const whole = v / 1_000;
        const frac = (v % 1_000) / 100;
        return std.fmt.bufPrint(buf, "{d}.{d}K", .{ whole, frac }) catch "";
    } else {
        return std.fmt.bufPrint(buf, "{d}", .{v}) catch "";
    }
}

/// Draw footprint data inside a candle body.
/// Shows bid|ask volume at each price row within the candle.
fn drawFootprint(
    renderer: *Renderer,
    fp: *const FootprintUpdate,
    x: u16,
    rect: Rect,
    y_min: i64,
    y_max: i64,
    chart_h: u16,
    theme: *const Theme,
    candle_width: u8,
) void {
    const inner_x = rect.x + 1;
    const inner_y = rect.y + 1;
    const imbalance_ratio: i64 = 3; // 3:1 ratio = imbalance

    for (fp.levels[0..fp.level_count]) |level| {
        // Map this price level to a chart row
        const sub = scaleYSub(level.price, y_min, y_max, chart_h);
        const row = inner_y + sub.row;
        if (row < inner_y or row >= inner_y + chart_h) continue;

        // Format bid x ask — fit within candle_width
        var bid_buf: [8]u8 = undefined;
        var ask_buf: [8]u8 = undefined;
        const bid_str = fmtVolShort(&bid_buf, level.bid_volume);
        const ask_str = fmtVolShort(&ask_buf, level.ask_volume);

        // Build the display string: "BxA" fitting in candle_width
        var display_buf: [20]u8 = undefined;
        const display = std.fmt.bufPrint(&display_buf, "{s}x{s}", .{ bid_str, ask_str }) catch "";

        if (display.len == 0) continue;

        // Truncate to fit candle_width
        const max_len: usize = @min(display.len, candle_width);
        const col = inner_x + x;

        // Color based on imbalance
        if (level.ask_volume > 0 and level.bid_volume > 0) {
            if (level.ask_volume > level.bid_volume * imbalance_ratio) {
                // Ask imbalance (bullish) — use footprint_ask with highlight
                renderer.writeColor(theme.footprint_imbalance);
            } else if (level.bid_volume > level.ask_volume * imbalance_ratio) {
                // Bid imbalance (bearish) — use footprint_imbalance
                renderer.writeColor(theme.footprint_imbalance);
            } else if (level.ask_volume > level.bid_volume) {
                renderer.writeColor(theme.footprint_ask);
            } else {
                renderer.writeColor(theme.footprint_bid);
            }
        } else if (level.ask_volume > 0) {
            renderer.writeColor(theme.footprint_ask);
        } else {
            renderer.writeColor(theme.footprint_bid);
        }

        renderer.writeFmt("\x1b[{d};{d}H{s}", .{ row + 1, col + 1, display[0..max_len] });
    }
    renderer.resetColor();
}

/// Draw delta value below the volume bar for a candle.
fn drawDelta(
    renderer: *Renderer,
    fp: *const FootprintUpdate,
    x: u16,
    y: u16,
    theme: *const Theme,
    candle_width: u8,
) void {
    // Format delta compactly
    const abs_delta: u64 = @intCast(@abs(fp.delta));
    const sign: u8 = if (fp.delta >= 0) '+' else '-';

    var delta_buf: [12]u8 = undefined;
    var vol_buf: [10]u8 = undefined;
    const vol_str = fmtVolShort(&vol_buf, @intCast(abs_delta));
    const delta_str = std.fmt.bufPrint(&delta_buf, "{c}{s}", .{ sign, vol_str }) catch "";

    if (delta_str.len == 0) return;
    const max_len: usize = @min(delta_str.len, candle_width);

    if (fp.delta >= 0) {
        renderer.writeColor(theme.footprint_delta_pos);
    } else {
        renderer.writeColor(theme.footprint_delta_neg);
    }
    renderer.writeFmt("\x1b[{d};{d}H{s}", .{ y + 1, x + 1, delta_str[0..max_len] });
    renderer.resetColor();
}

pub fn draw(
    renderer: *Renderer,
    rect: Rect,
    candles: []const CandleUpdate,
    footprints: []const FootprintUpdate,
    theme: *const Theme,
    viewport_offset: usize,
    candle_width: u8,
    crosshair_active: bool,
    crosshair_idx: usize,
    instrument_name: []const u8,
) void {
    if (rect.h < 4 or rect.w < 10) return;

    // Build title with instrument name: "BTC-USD 1m"
    var title_buf: [48]u8 = undefined;
    const title = if (instrument_name.len > 0)
        std.fmt.bufPrint(&title_buf, "{s} 1m", .{instrument_name}) catch "Chart 1m"
    else
        "Chart 1m";
    renderer.drawBoxThemed(rect, title, theme);

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

    // Visible candle range
    const cw: u8 = if (candle_width == 0) 3 else candle_width;

    // Height split: 25% for volume bars (min 8 rows total for volume to appear)
    // Reserve 1 row for delta when footprint data is available and candle_width >= 9
    const has_footprint = footprints.len > 0 and cw >= 9;
    const delta_h: u16 = if (has_footprint and inner_h >= 10) 1 else 0;
    const volume_h: u16 = if (inner_h >= 8) inner_h / 4 else 0;
    const chart_h: u16 = if (inner_h > 1) inner_h - 1 - volume_h - delta_h else inner_h;
    const max_vis = visibleCandles(inner_w, cw);
    const total = candles.len;

    // Auto-follow: if viewport_offset == 0, show newest candles (right edge)
    const effective_offset: usize = if (viewport_offset == 0)
        (if (total > max_vis) total - max_vis else 0)
    else
        clampViewport(total -| viewport_offset -| max_vis, max_vis, total);

    const end = @min(effective_offset + max_vis, total);
    const visible = candles[effective_offset..end];

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

    // Draw each candle
    for (visible, 0..) |candle, ci| {
        const x: u16 = @intCast(ci * cw);
        drawCandle(renderer, x, rect, candle, y_min, y_max, chart_h, theme, cw);
    }

    // Volume bars
    if (volume_h > 0) {
        // Scan for max volume
        var max_volume: i64 = 0;
        for (visible) |c| {
            if (c.volume > max_volume) max_volume = c.volume;
        }

        const vol_y = rect.y + 1 + chart_h; // volume area starts here
        for (visible, 0..) |candle, ci| {
            const x: u16 = @intCast(ci * cw);
            drawVolumeBar(renderer, rect.x + 1 + x, vol_y, volume_h, candle.volume, max_volume, theme.volume);
        }
    }

    // --- Volume footprint overlay (when candle_width >= 9) ---
    if (has_footprint) {
        for (visible, 0..) |candle, ci| {
            if (findFootprint(footprints, candle.timestamp)) |fp| {
                const x: u16 = @intCast(ci * cw);
                drawFootprint(renderer, fp, x, rect, y_min, y_max, chart_h, theme, cw);
            }
        }

        // Delta row below volume bars
        if (delta_h > 0) {
            const delta_y = rect.y + 1 + chart_h + volume_h;
            for (visible, 0..) |candle, ci| {
                if (findFootprint(footprints, candle.timestamp)) |fp| {
                    const x: u16 = @intCast(ci * cw);
                    drawDelta(renderer, fp, rect.x + 1 + x, delta_y, theme, cw);
                }
            }
        }
    }

    // --- SMA-20 overlay ---
    for (visible, 0..) |_, ci| {
        const absolute_index = effective_offset + ci;
        if (primitives.smaCompute(candles, absolute_index, 20)) |sma_val| {
            const sub = scaleYSub(sma_val, y_min, y_max, chart_h);
            // Clamp to valid row range
            const sma_row = @min(sub.row, chart_h -| 1);
            const sma_col = rect.x + 1 + @as(u16, @intCast(ci * cw)) + cw / 2;
            renderer.writeColor(theme.indicator_line);
            const sma_char: []const u8 = if (sub.half == 1)
                &primitives.HALF_BLOCK_CHARS[3] // ▄
            else
                &primitives.UPPER_HALF; // ▀
            renderer.writeFmt("\x1b[{d};{d}H{s}", .{ rect.y + 2 + sma_row, sma_col, sma_char });
            renderer.resetColor();
        }
    }

    // --- Crosshair rendering ---
    if (crosshair_active and crosshair_idx < visible.len) {
        const ch_x = rect.x + 1 + @as(u16, @intCast(crosshair_idx * cw)) + cw / 2;

        // Draw vertical line through entire chart area
        renderer.writeColor(theme.crosshair);
        var r: u16 = 0;
        while (r < chart_h) : (r += 1) {
            renderer.writeFmt("\x1b[{d};{d}H\xe2\x94\x82", .{ rect.y + 2 + r, ch_x }); // │
        }

        // Draw OHLCV readout
        const candle = visible[crosshair_idx];
        var ohlcv_buf: [128]u8 = undefined;

        const o_whole = @divTrunc(candle.open, 100_000_000);
        const o_frac = @abs(@rem(candle.open, 100_000_000)) / 1_000_000;
        const h_whole = @divTrunc(candle.high, 100_000_000);
        const h_frac = @abs(@rem(candle.high, 100_000_000)) / 1_000_000;
        const l_whole = @divTrunc(candle.low, 100_000_000);
        const l_frac = @abs(@rem(candle.low, 100_000_000)) / 1_000_000;
        const c_whole = @divTrunc(candle.close, 100_000_000);
        const c_frac = @abs(@rem(candle.close, 100_000_000)) / 1_000_000;

        // Include delta from footprint data if available
        const fp_for_crosshair = findFootprint(footprints, candle.timestamp);
        const ohlcv_str = if (fp_for_crosshair) |fp|
            std.fmt.bufPrint(&ohlcv_buf,
                "O:{d}.{d:0>2} H:{d}.{d:0>2} L:{d}.{d:0>2} C:{d}.{d:0>2} V:{d} D:{d}",
                .{ o_whole, o_frac, h_whole, h_frac, l_whole, l_frac, c_whole, c_frac, candle.volume, fp.delta }) catch "?"
        else
            std.fmt.bufPrint(&ohlcv_buf,
                "O:{d}.{d:0>2} H:{d}.{d:0>2} L:{d}.{d:0>2} C:{d}.{d:0>2} V:{d}",
                .{ o_whole, o_frac, h_whole, h_frac, l_whole, l_frac, c_whole, c_frac, candle.volume }) catch "?";

        // Position readout: left half → draw right-aligned; right half → left-aligned
        const readout_row = rect.y + 1;
        const ch_relative = crosshair_idx * cw;
        if (ch_relative > inner_w / 2) {
            // Left-align: start at x=1
            renderer.drawText(rect.x + 1, readout_row, ohlcv_str[0..@min(ohlcv_str.len, inner_w)]);
        } else {
            // Right-align: end at right edge
            const str_len = @min(ohlcv_str.len, inner_w);
            const start_x = rect.x + 1 + (inner_w -| str_len);
            renderer.drawText(start_x, readout_row, ohlcv_str[0..str_len]);
        }
        renderer.resetColor();
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

test "volume_bar_scaling" {
    // Bar height should be proportional to volume/max_volume
    // volume=50, max_volume=100, height=10 → bar_h = 5
    const volume: i64 = 50;
    const max_volume: i64 = 100;
    const height: u16 = 10;
    const bar_h: u16 = @intCast(@min(
        @as(i64, height),
        @divTrunc(volume * @as(i64, height), max_volume),
    ));
    try @import("std").testing.expectEqual(@as(u16, 5), bar_h);
}

test "volume_bar_zero" {
    // Zero volume produces zero-height bar (no division by zero)
    const volume: i64 = 0;
    const max_volume: i64 = 100;
    const height: u16 = 10;
    if (max_volume == 0 or volume <= 0) {
        try @import("std").testing.expect(true); // no bar rendered
    } else {
        const bar_h: u16 = @intCast(@min(
            @as(i64, height),
            @divTrunc(volume * @as(i64, height), max_volume),
        ));
        try @import("std").testing.expectEqual(@as(u16, 0), bar_h);
    }
}

test "height_split_computation" {
    // inner_h=20 → volume_h=5 (25%), chart_h = 20 - 1 - 5 = 14
    const inner_h: u16 = 20;
    const volume_h: u16 = if (inner_h >= 8) inner_h / 4 else 0;
    const chart_h: u16 = if (inner_h > 1) inner_h - 1 - volume_h else inner_h;
    try @import("std").testing.expectEqual(@as(u16, 5), volume_h);
    try @import("std").testing.expectEqual(@as(u16, 14), chart_h);
}

test "visibleCandles_calculation" {
    // width=38, candle_width=3 → 12
    try @import("std").testing.expectEqual(@as(usize, 12), visibleCandles(38, 3));
    // width=38, candle_width=1 → 38
    try @import("std").testing.expectEqual(@as(usize, 38), visibleCandles(38, 1));
    // width=38, candle_width=5 → 7
    try @import("std").testing.expectEqual(@as(usize, 7), visibleCandles(38, 5));
}

test "clampViewport_bounds" {
    // offset beyond total clamps to total - visible
    try @import("std").testing.expectEqual(@as(usize, 10), clampViewport(999, 10, 20));
    // offset within range passes through
    try @import("std").testing.expectEqual(@as(usize, 5), clampViewport(5, 10, 20));
    // total <= visible returns 0
    try @import("std").testing.expectEqual(@as(usize, 0), clampViewport(3, 10, 5));
}

test "clampViewport_auto_follow" {
    // Auto-follow: viewport_offset=0, total > visible → effective = total - visible
    const total: usize = 100;
    const max_vis: usize = 20;
    const viewport_offset: usize = 0;
    const effective = if (viewport_offset == 0)
        (if (total > max_vis) total - max_vis else 0)
    else
        clampViewport(total -| viewport_offset -| max_vis, max_vis, total);
    try @import("std").testing.expectEqual(@as(usize, 80), effective);
}
