// Orderbook panel renderer.

const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const layout = @import("../layout.zig");
const Rect = layout.Rect;
const msg = @import("../messages.zig");
const OrderbookSnapshot = msg.OrderbookSnapshot;
const Theme = @import("../theme.zig").Theme;

/// Format a fixed-point i64 price (8 decimal places) as decimal with 2 decimal places.
/// e.g., 5_000_000_000_000 -> "50000.00"
fn fmtPrice(buf: *[32]u8, price: i64) []const u8 {
    const whole = @divTrunc(price, 100_000_000);
    const frac = @abs(@rem(price, 100_000_000));
    const frac2 = frac / 1_000_000; // 2 decimal places
    return std.fmt.bufPrint(buf, "{d}.{d:02}", .{ whole, frac2 }) catch "?";
}

/// Format a quantity (also stored with 8 decimal places) in simplified form.
fn fmtQty(buf: *[24]u8, qty: i64) []const u8 {
    const whole = @divTrunc(qty, 100_000_000);
    return std.fmt.bufPrint(buf, "{d}", .{whole}) catch "?";
}

pub fn draw(renderer: *Renderer, rect: Rect, snapshot: *const OrderbookSnapshot, theme: *const Theme) void {
    if (rect.h < 4 or rect.w < 20) return;

    renderer.drawBoxThemed(rect, snapshot.instrument.slice(), theme);

    const inner_x = rect.x + 1;
    const inner_y = rect.y + 1;
    const inner_h = rect.h -| 2;
    const inner_w = rect.w -| 2;

    // Header
    renderer.drawTextFmt(inner_x, inner_y, "{s:<16}{s:>10}", .{ "Price", "Qty" });

    const half = (inner_h -| 1) / 2;

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
        const line_len = inner_w;
        _ = line_len;
        renderer.writeFmt("\x1b[{d};{d}H", .{ row + 1, inner_x + 1 });
        renderer.writeColor(theme.ask);
        renderer.writeFmt("{s:<16}{s:>10}", .{ ps, qs });
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
        renderer.resetColor();
        row += 1;
    }
}
