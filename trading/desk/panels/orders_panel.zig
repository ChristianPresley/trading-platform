// Recent orders panel renderer.

const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const layout = @import("../layout.zig");
const Rect = layout.Rect;
const msg = @import("../messages.zig");
const OrderUpdate = msg.OrderUpdate;

const STATUS_NAMES = [_][]const u8{ "Pending", "New", "Filled", "Cancelled", "Rejected" };
const SIDE_NAMES = [_][]const u8{ "Buy", "Sell" };

pub fn draw(renderer: *Renderer, rect: Rect, orders: []const OrderUpdate) void {
    renderer.drawBox(rect, "Recent Orders");

    if (rect.h < 3 or rect.w < 30) return;

    const inner_x = rect.x + 1;
    const inner_y = rect.y + 1;

    // Header
    renderer.drawTextFmt(inner_x, inner_y, "{s:<6}{s:<10}{s:<6}{s:>8}{s:>10}{s:>10}", .{
        "ID", "Instr", "Side", "Qty", "Price", "Status",
    });

    const max_rows = rect.h -| 3;
    const show = @min(orders.len, max_rows);

    // Show most recent first
    var i: usize = 0;
    while (i < show) : (i += 1) {
        const idx = if (orders.len > i) orders.len - 1 - i else 0;
        const ord = orders[idx];
        const row = inner_y + 1 + @as(u16, @intCast(i));

        const side_str = if (ord.side < SIDE_NAMES.len) SIDE_NAMES[ord.side] else "?";
        const status_str = if (ord.status < STATUS_NAMES.len) STATUS_NAMES[ord.status] else "?";
        const price_whole = @divTrunc(ord.price, 100_000_000);
        const qty_whole = @divTrunc(ord.quantity, 100_000_000);

        renderer.writeFmt("\x1b[{d};{d}H{d:<6}{s:<10}{s:<6}{d:>8}{d:>10}{s:>10}", .{
            row + 1, inner_x + 1,
            ord.id,
            ord.instrument.slice(),
            side_str,
            qty_whole,
            price_whole,
            status_str,
        });
    }

    if (orders.len == 0) {
        renderer.writeFmt("\x1b[{d};{d}HNo orders", .{ inner_y + 2, inner_x + 1 });
    }
}
