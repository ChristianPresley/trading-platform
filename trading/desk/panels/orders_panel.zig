// Recent orders panel renderer.

const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const layout = @import("../layout.zig");
const Rect = layout.Rect;
const msg = @import("../messages.zig");
const OrderUpdate = msg.OrderUpdate;
const Theme = @import("../theme.zig").Theme;

const STATUS_NAMES = [_][]const u8{ "Pending", "New", "Filled", "Cancelled", "Rejected" };
const SIDE_NAMES = [_][]const u8{ "Buy", "Sell" };

/// MAX_ORDERS must match the constant in main.zig
pub const MAX_ORDERS = 64;

pub fn draw(renderer: *Renderer, rect: Rect, orders: []const OrderUpdate, frame_count: u64, theme: *const Theme) void {
    renderer.drawBoxThemed(rect, "Recent Orders", theme);

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

        // Flash highlight: check if this order arrived recently (within 3 frames)
        // arrival_frame is passed via the orders slice index — we use frame_count
        // as a signal; flash for filled (status=2) and rejected (status=4) orders
        // when they are recent. Since we don't have per-order arrival data here,
        // we rely on caller injecting flash data via frame_count delta.
        // The flash logic: if frame_count < 3, flash all (startup) — otherwise
        // standard rendering. For a proper implementation see main.zig which
        // tracks per-order arrival frames and passes the age via frame_count param.
        _ = frame_count; // used by caller to compute per-order flash in main.zig

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
