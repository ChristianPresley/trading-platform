const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const Rect = @import("../layout.zig").Rect;
const messages = @import("../messages.zig");
const OrderUpdate = messages.OrderUpdate;

fn formatPrice(buf: []u8, price: i64) []const u8 {
    const abs_price: u64 = if (price < 0) @intCast(-price) else @intCast(price);
    const whole = abs_price / 100_000_000;
    const frac = (abs_price % 100_000_000) / 1_000_000;
    const sign: []const u8 = if (price < 0) "-" else "";
    return std.fmt.bufPrint(buf, "{s}{d}.{d:0>2}", .{ sign, whole, frac }) catch "???";
}

const status_names = [_][]const u8{
    "PendNew", "New", "PartFill", "Filled", "Cancel",
    "Replace", "PendCxl", "Reject", "Suspend", "PendRpl",
    "Expired", "Staged", "Valid", "RoutePnd",
};

fn statusName(status: u8) []const u8 {
    if (status < status_names.len) return status_names[status];
    return "???";
}

pub fn draw(renderer: *Renderer, rect: Rect, orders: []const OrderUpdate) void {
    if (rect.h < 4 or rect.w < 20) return;

    const inner_x = rect.x + 1;
    const inner_y = rect.y + 1;

    // Header
    renderer.drawText(inner_x + 1, inner_y, "\x1b[1mID   Side  Qty    Price    Status\x1b[0m");

    const max_rows = rect.h - 3;
    var row: u16 = 0;
    // Show most recent first
    var i = orders.len;
    while (i > 0 and row < max_rows) {
        i -= 1;
        const order = orders[i];
        const side_str: []const u8 = if (order.side == 0) "BUY " else "SELL";
        var pbuf: [32]u8 = undefined;
        const price_str = formatPrice(&pbuf, order.price);
        const status = statusName(order.status);

        renderer.drawTextFmt(inner_x + 1, inner_y + 1 + row,
            "{d: <4} {s}  {d: >5} {s: >8} {s}",
            .{ order.id, side_str, order.quantity, price_str, status });
        row += 1;
    }

    if (orders.len == 0) {
        renderer.drawText(inner_x + 1, inner_y + 1, "(no orders)");
    }
}
