// Positions panel renderer.

const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const layout = @import("../layout.zig");
const Rect = layout.Rect;
const msg = @import("../messages.zig");
const PositionUpdate = msg.PositionUpdate;

pub fn draw(renderer: *Renderer, rect: Rect, positions: []const PositionUpdate) void {
    renderer.drawBox(rect, "Positions");

    if (rect.h < 3 or rect.w < 30) return;

    const inner_x = rect.x + 1;
    const inner_y = rect.y + 1;

    // Header
    renderer.drawTextFmt(inner_x, inner_y, "{s:<12}{s:>8}{s:>12}{s:>12}", .{
        "Instrument", "Qty", "AvgCost", "UnrPNL",
    });

    const max_rows = rect.h -| 3;
    const show = @min(positions.len, max_rows);

    for (0..show) |i| {
        const pos = positions[i];
        const row = inner_y + 1 + @as(u16, @intCast(i));

        var avg_buf: [20]u8 = undefined;
        const avg_whole = @divTrunc(pos.avg_cost, 100_000_000);
        const avg_str = std.fmt.bufPrint(&avg_buf, "{d}", .{avg_whole}) catch "?";

        const pnl_positive = pos.unrealized_pnl >= 0;
        const pnl_color = if (pnl_positive) "\x1b[32m" else "\x1b[31m";
        const pnl_whole = @divTrunc(pos.unrealized_pnl, 100_000_000);

        renderer.writeFmt("\x1b[{d};{d}H{s:<12}{d:>8}{s:>12}{s}{d:>12}\x1b[0m", .{
            row + 1, inner_x + 1,
            pos.instrument.slice(),
            @divTrunc(pos.quantity, 100_000_000),
            avg_str,
            pnl_color,
            pnl_whole,
        });
    }

    if (positions.len == 0) {
        renderer.writeFmt("\x1b[{d};{d}HNo positions", .{ inner_y + 2, inner_x + 1 });
    }
}
