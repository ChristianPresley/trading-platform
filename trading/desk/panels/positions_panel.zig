const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const Rect = @import("../layout.zig").Rect;
const messages = @import("../messages.zig");
const PositionUpdate = messages.PositionUpdate;

fn formatPrice(buf: []u8, price: i64) []const u8 {
    const abs_price: u64 = if (price < 0) @intCast(-price) else @intCast(price);
    const whole = abs_price / 100_000_000;
    const frac = (abs_price % 100_000_000) / 1_000_000;
    const sign: []const u8 = if (price < 0) "-" else "";
    return std.fmt.bufPrint(buf, "{s}{d}.{d:0>2}", .{ sign, whole, frac }) catch "???";
}

pub fn draw(renderer: *Renderer, rect: Rect, positions: []const PositionUpdate) void {
    if (rect.h < 4 or rect.w < 20) return;

    const inner_x = rect.x + 1;
    const inner_y = rect.y + 1;

    // Header
    renderer.drawText(inner_x + 1, inner_y, "\x1b[1mInstr    Qty   AvgCost  UnrlPnL\x1b[0m");

    const max_rows = rect.h - 3;
    var row: u16 = 0;
    for (positions) |pos| {
        if (row >= max_rows) break;
        var pbuf: [32]u8 = undefined;
        var ubuf: [32]u8 = undefined;
        const cost_str = formatPrice(&pbuf, pos.avg_cost);
        const pnl_str = formatPrice(&ubuf, pos.unrealized_pnl);
        const color: []const u8 = if (pos.unrealized_pnl >= 0) "\x1b[32m" else "\x1b[31m";

        renderer.drawTextFmt(inner_x + 1, inner_y + 1 + row,
            "{s: <8} {d: >5} {s: >8} {s}{s: >8}\x1b[0m",
            .{ pos.instrument.asSlice(), pos.quantity, cost_str, color, pnl_str });
        row += 1;
    }

    if (positions.len == 0) {
        renderer.drawText(inner_x + 1, inner_y + 1, "(no positions)");
    }
}
