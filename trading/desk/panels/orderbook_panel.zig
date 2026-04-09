// Orderbook panel renderer.

const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const layout = @import("../layout.zig");
const Rect = layout.Rect;
pub const msg = @import("../messages.zig");
const OrderbookSnapshot = msg.OrderbookSnapshot;
const Theme = @import("../theme.zig").Theme;

/// Format a fixed-point i64 price (8 decimal places) as decimal with 2 decimal places.
/// e.g., 5_000_000_000_000 -> "50000.00"
pub fn fmtPrice(buf: *[32]u8, price: i64) []const u8 {
    const whole = @divTrunc(price, 100_000_000);
    const frac = @abs(@rem(price, 100_000_000));
    const frac2 = frac / 1_000_000; // 2 decimal places
    return std.fmt.bufPrint(buf, "{d}.{d:02}", .{ whole, frac2 }) catch "?";
}

/// Format a quantity (stored with 8 decimal places) as decimal with 2 fractional digits.
pub fn fmtQty(buf: *[24]u8, qty: i64) []const u8 {
    const whole = @divTrunc(qty, 100_000_000);
    const frac = @abs(@rem(qty, 100_000_000)) / 1_000_000;
    return std.fmt.bufPrint(buf, "{d}.{d:02}", .{ whole, frac }) catch "?";
}

/// Sparkline block characters: ▁▂▃▄▅▆▇█ (each 3 bytes UTF-8)
const SPARKLINE_CHARS = [8][3]u8{
    .{ 0xe2, 0x96, 0x81 }, // ▁ U+2581
    .{ 0xe2, 0x96, 0x82 }, // ▂ U+2582
    .{ 0xe2, 0x96, 0x83 }, // ▃ U+2583
    .{ 0xe2, 0x96, 0x84 }, // ▄ U+2584
    .{ 0xe2, 0x96, 0x85 }, // ▅ U+2585
    .{ 0xe2, 0x96, 0x86 }, // ▆ U+2586
    .{ 0xe2, 0x96, 0x87 }, // ▇ U+2587
    .{ 0xe2, 0x96, 0x88 }, // █ U+2588
};

/// Depth bar characters: ░▒▓█
const DEPTH_CHARS = [4][3]u8{
    .{ 0xe2, 0x96, 0x91 }, // ░ U+2591
    .{ 0xe2, 0x96, 0x92 }, // ▒ U+2592
    .{ 0xe2, 0x96, 0x93 }, // ▓ U+2593
    .{ 0xe2, 0x96, 0x88 }, // █ U+2588
};

/// Build a sparkline into buf from the provided values.
/// Returns a slice of buf containing the UTF-8 characters.
/// Each character is 3 bytes (Unicode block chars).
pub fn sparkline(values: []const i64, width: u16, buf: []u8) []const u8 {
    if (values.len == 0 or width == 0) return buf[0..0];

    // Find min/max
    var min_v: i64 = values[0];
    var max_v: i64 = values[0];
    for (values) |v| {
        if (v < min_v) min_v = v;
        if (v > max_v) max_v = v;
    }
    const range = max_v - min_v;

    // Number of values to show: take most recent `width` values
    const start = if (values.len > width) values.len - width else 0;
    const visible = values[start..];
    const count = @min(visible.len, width);

    var pos: usize = 0;
    for (visible[0..count]) |v| {
        var level: usize = 3; // middle level when flat
        if (range > 0) {
            const offset = v - min_v;
            level = @as(usize, @intCast(@min(7, @as(u64, @intCast(@max(0, offset))) * 7 / @as(u64, @intCast(range)))));
        }
        if (pos + 3 > buf.len) break;
        buf[pos] = SPARKLINE_CHARS[level][0];
        buf[pos + 1] = SPARKLINE_CHARS[level][1];
        buf[pos + 2] = SPARKLINE_CHARS[level][2];
        pos += 3;
    }
    return buf[0..pos];
}

/// Build a depth bar into buf.
/// Returns a slice of buf.
pub fn depthBar(quantity: i64, max_quantity: i64, width: u16, buf: []u8) []const u8 {
    if (max_quantity <= 0 or width == 0) return buf[0..0];

    const ratio = @as(u64, @intCast(@max(0, quantity))) * @as(u64, width) / @as(u64, @intCast(@max(1, max_quantity)));
    const filled_cols = @min(ratio, width);

    var pos: usize = 0;
    var col: u64 = 0;
    while (col < filled_cols) : (col += 1) {
        const char_idx: usize = 3; // full block █
        if (pos + 3 > buf.len) break;
        buf[pos] = DEPTH_CHARS[char_idx][0];
        buf[pos + 1] = DEPTH_CHARS[char_idx][1];
        buf[pos + 2] = DEPTH_CHARS[char_idx][2];
        pos += 3;
    }
    return buf[0..pos];
}

pub fn draw(renderer: *Renderer, rect: Rect, snapshot: *const OrderbookSnapshot, history: []const i64, theme: *const Theme) void {
    if (rect.h < 4 or rect.w < 20) return;

    renderer.drawBoxThemed(rect, snapshot.instrument.slice(), theme);

    const inner_x = rect.x + 1;
    var inner_y = rect.y + 1;
    const inner_h = rect.h -| 2;
    const inner_w = rect.w -| 2;

    // Sparkline row (BBO midpoint history) — 1 row above header
    if (history.len > 0 and inner_h > 2) {
        const spark_width = inner_w;
        // Buffer: each char is 3 bytes
        var spark_buf: [512]u8 = undefined;
        const spark_str = sparkline(history, spark_width, &spark_buf);
        renderer.writeFmt("\x1b[{d};{d}H", .{ inner_y + 1, inner_x + 1 });
        renderer.writeColor(theme.spread);
        renderer.writeRawPub(spark_str);
        renderer.resetColor();
        inner_y += 1;
    }

    // Header
    renderer.drawTextFmt(inner_x, inner_y, "{s:<16}{s:>10}", .{ "Price", "Qty" });

    const remaining_h = inner_h -| (inner_y -| (rect.y + 1)) -| 1;
    const half = remaining_h / 2;

    // Find max quantity in visible snapshot for depth bar scaling
    var max_qty: i64 = 1;
    for (0..snapshot.ask_count) |ai| {
        if (snapshot.asks[ai].quantity > max_qty) max_qty = snapshot.asks[ai].quantity;
    }
    for (0..snapshot.bid_count) |bi| {
        if (snapshot.bids[bi].quantity > max_qty) max_qty = snapshot.bids[bi].quantity;
    }

    // Depth bar column width (right portion of inner width after price+qty)
    const price_qty_w: u16 = 26; // 16 price + 10 qty
    const bar_w: u16 = if (inner_w > price_qty_w + 2) inner_w - price_qty_w - 2 else 0;

    // Asks (top half, red): display from bottom (best ask first at center)
    var ask_idx: usize = 0;
    const num_asks = @min(snapshot.ask_count, half);
    var row: u16 = inner_y + 1 + (half -| num_asks);
    while (ask_idx < num_asks) : (ask_idx += 1) {
        const level = snapshot.asks[ask_idx];
        var pbuf: [32]u8 = undefined;
        var qbuf: [24]u8 = undefined;
        const ps = fmtPrice(&pbuf, level.price);
        const qs = fmtQty(&qbuf, level.quantity);
        renderer.writeFmt("\x1b[{d};{d}H", .{ row + 1, inner_x + 1 });
        renderer.writeColor(theme.ask);
        renderer.writeFmt("{s:<16}{s:>10}", .{ ps, qs });
        // Depth bar for ask
        if (bar_w > 0) {
            var depth_buf: [256]u8 = undefined;
            const bar_str = depthBar(level.quantity, max_qty, bar_w, &depth_buf);
            renderer.writeRawPub(bar_str);
        }
        renderer.resetColor();
        row += 1;
    }

    // Spread line
    const spread_row = inner_y + 1 + half;
    if (snapshot.bid_count > 0 and snapshot.ask_count > 0) {
        const spread = snapshot.asks[0].price - snapshot.bids[0].price;
        var pbuf: [32]u8 = undefined;
        const ss = fmtPrice(&pbuf, spread);
        renderer.writeFmt("\x1b[{d};{d}H", .{ spread_row + 1, inner_x + 1 });
        renderer.writeColor(theme.spread);
        renderer.writeFmt("--- Spread: {s} ---", .{ss});
        renderer.resetColor();
    }

    // Bids (bottom half, green): best bid first after spread
    var bid_idx: usize = 0;
    const num_bids = @min(snapshot.bid_count, half);
    row = spread_row + 1;
    while (bid_idx < num_bids) : (bid_idx += 1) {
        const level = snapshot.bids[bid_idx];
        var pbuf: [32]u8 = undefined;
        var qbuf: [24]u8 = undefined;
        const ps = fmtPrice(&pbuf, level.price);
        const qs = fmtQty(&qbuf, level.quantity);
        renderer.writeFmt("\x1b[{d};{d}H", .{ row + 1, inner_x + 1 });
        renderer.writeColor(theme.bid);
        renderer.writeFmt("{s:<16}{s:>10}", .{ ps, qs });
        // Depth bar for bid
        if (bar_w > 0) {
            var depth_buf: [256]u8 = undefined;
            const bar_str = depthBar(level.quantity, max_qty, bar_w, &depth_buf);
            renderer.writeRawPub(bar_str);
        }
        renderer.resetColor();
        row += 1;
    }
}

test "sparkline_quantization" {
    // Feed [0, 25, 50, 75, 100] — scaled min=0, max=100
    // Expect levels: 0, 1 (25/100*7≈1), 3 (50/100*7≈3), 5 (75/100*7≈5), 7
    var buf: [64]u8 = undefined;
    const values = [_]i64{ 0, 25, 50, 75, 100 };
    const result = sparkline(&values, 5, &buf);
    // Should produce 5 * 3 = 15 bytes
    try std.testing.expect(result.len == 15);
    // First char should be level 0 (▁ = 0xe2 0x96 0x81)
    try std.testing.expect(result[0] == 0xe2);
    try std.testing.expect(result[1] == 0x96);
    try std.testing.expect(result[2] == 0x81);
    // Last char should be level 7 (█ = 0xe2 0x96 0x88)
    try std.testing.expect(result[12] == 0xe2);
    try std.testing.expect(result[13] == 0x96);
    try std.testing.expect(result[14] == 0x88);
}

test "depth_bar_scaling" {
    var buf: [64]u8 = undefined;
    // Max quantity maps to full width
    const full = depthBar(100, 100, 4, &buf);
    try std.testing.expect(full.len == 12); // 4 chars * 3 bytes each

    // Half quantity maps to half width (2 chars)
    var buf2: [64]u8 = undefined;
    const half = depthBar(50, 100, 4, &buf2);
    try std.testing.expect(half.len == 6); // 2 chars * 3 bytes each

    // Zero quantity maps to empty
    var buf3: [64]u8 = undefined;
    const zero = depthBar(0, 100, 4, &buf3);
    try std.testing.expect(zero.len == 0);
}
