const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const Rect = @import("../layout.zig").Rect;
const messages = @import("../messages.zig");
const OrderbookSnapshot = messages.OrderbookSnapshot;

/// Format a fixed-point i64 price (8 decimal places) as a human-readable string with 2 decimals.
fn formatPrice(buf: []u8, price: i64) []const u8 {
    const abs_price: u64 = if (price < 0) @intCast(-price) else @intCast(price);
    const whole = abs_price / 100_000_000;
    const frac = (abs_price % 100_000_000) / 1_000_000; // 2 decimal places
    const sign: []const u8 = if (price < 0) "-" else "";
    return std.fmt.bufPrint(buf, "{s}{d}.{d:0>2}", .{ sign, whole, frac }) catch "???";
}

fn formatQty(buf: []u8, qty: i64) []const u8 {
    const abs_qty: u64 = if (qty < 0) @intCast(-qty) else @intCast(qty);
    const whole = abs_qty / 100_000_000;
    const frac = (abs_qty % 100_000_000) / 10_000_000; // 1 decimal
    return std.fmt.bufPrint(buf, "{d}.{d}", .{ whole, frac }) catch "???";
}

pub fn draw(renderer: *Renderer, rect: Rect, snapshot: *const OrderbookSnapshot) void {
    if (rect.h < 4 or rect.w < 20) return;

    const inner_x = rect.x + 1;
    const inner_w = rect.w - 2;
    _ = inner_w;
    const inner_y = rect.y + 1;
    const inner_h = rect.h - 2;

    // Header
    renderer.drawText(inner_x + 1, inner_y, "\x1b[1mPrice       Qty\x1b[0m");

    // Calculate how many levels we can show per side
    const half_rows = (inner_h - 1) / 2; // -1 for header

    // Asks (top section, red) — show in reverse so best ask is at bottom
    const ask_count = @min(snapshot.ask_count, @as(u8, @intCast(half_rows)));
    var i: u8 = 0;
    while (i < ask_count) : (i += 1) {
        const display_idx = ask_count - 1 - i;
        const level = snapshot.asks[display_idx];
        var pbuf: [32]u8 = undefined;
        var qbuf: [32]u8 = undefined;
        const price_str = formatPrice(&pbuf, level.price);
        const qty_str = formatQty(&qbuf, level.quantity);
        renderer.drawTextFmt(inner_x + 1, inner_y + 1 + i, "\x1b[31m{s: >10} {s: >8}\x1b[0m", .{ price_str, qty_str });
    }

    // Spread line
    const spread_row = inner_y + 1 + half_rows;
    if (spread_row < rect.y + rect.h - 1) {
        renderer.drawText(inner_x + 1, @intCast(spread_row), "----------+--------");
    }

    // Bids (bottom section, green)
    const bid_count = @min(snapshot.bid_count, @as(u8, @intCast(half_rows)));
    i = 0;
    while (i < bid_count) : (i += 1) {
        const level = snapshot.bids[i];
        var pbuf: [32]u8 = undefined;
        var qbuf: [32]u8 = undefined;
        const price_str = formatPrice(&pbuf, level.price);
        const qty_str = formatQty(&qbuf, level.quantity);
        const row = spread_row + 1 + i;
        if (row < rect.y + rect.h - 1) {
            renderer.drawTextFmt(inner_x + 1, @intCast(row), "\x1b[32m{s: >10} {s: >8}\x1b[0m", .{ price_str, qty_str });
        }
    }
}
