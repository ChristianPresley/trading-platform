// Trade tape (time & sales) panel renderer.
// Shows recent market trades from fake traders with color-coded buy/sell.

const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const layout = @import("../layout.zig");
const Rect = layout.Rect;
const msg = @import("../messages.zig");
const TradeUpdate = msg.TradeUpdate;
const Theme = @import("../theme.zig").Theme;

pub const MAX_TAPE_ENTRIES = 128;

const SIDE_NAMES = [_][]const u8{ "BUY", "SELL" };

pub fn draw(renderer: *Renderer, rect: Rect, tape: []const TradeUpdate, tape_count: usize, theme: *const Theme) void {
    renderer.drawBoxThemed(rect, "Trade Tape", theme);

    if (rect.h < 3 or rect.w < 30) return;

    const inner_x = rect.x + 1;
    const inner_y = rect.y + 1;

    // Header
    renderer.drawTextFmt(inner_x, inner_y, "{s:<10}{s:<6}{s:>12}{s:>10}{s:>6}", .{
        "Instr", "Side", "Price", "Qty", "Type",
    });

    const max_rows = rect.h -| 3;
    const total = @min(tape_count, MAX_TAPE_ENTRIES);
    const show = @min(total, max_rows);

    // Show most recent first
    var i: usize = 0;
    while (i < show) : (i += 1) {
        const idx = if (total > i) total - 1 - i else 0;
        const trade = &tape[idx];
        const row = inner_y + 1 + @as(u16, @intCast(i));

        const side_str = if (trade.side < SIDE_NAMES.len) SIDE_NAMES[trade.side] else "?";
        const price_whole = @divTrunc(trade.price, 100_000_000);
        const price_frac = @abs(@rem(trade.price, 100_000_000)) / 1_000_000;
        const qty_whole = @divTrunc(trade.quantity, 100_000_000);
        const qty_frac = @abs(@rem(trade.quantity, 100_000_000)) / 1_000_000;
        const tag_slice = trade.trader_tag[0..trade.trader_tag_len];

        // Color: green for buy, red for sell
        renderer.writeFmt("\x1b[{d};{d}H", .{ row + 1, inner_x + 1 });
        if (trade.side == 0) {
            renderer.writeColor(theme.bid);
        } else {
            renderer.writeColor(theme.ask);
        }
        renderer.writeFmt("{s:<10}{s:<6}{d:>8}.{d:02}{d:>7}.{d:02}{s:>6}", .{
            trade.instrument.slice(),
            side_str,
            price_whole,
            price_frac,
            qty_whole,
            qty_frac,
            tag_slice,
        });
        renderer.resetColor();
    }

    if (total == 0) {
        renderer.writeFmt("\x1b[{d};{d}HNo trades", .{ inner_y + 2, inner_x + 1 });
    }
}
