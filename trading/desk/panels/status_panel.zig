// Status bar panel renderer.

const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const layout = @import("../layout.zig");
const Rect = layout.Rect;
const msg = @import("../messages.zig");
const StatusUpdate = msg.StatusUpdate;
const Theme = @import("../theme.zig").Theme;

pub fn draw(renderer: *Renderer, rect: Rect, status: *const StatusUpdate, theme: *const Theme) void {
    // No border for status bar — single row
    const tick_sec = status.tick / 10; // rough seconds (10 ticks/sec)
    const h = tick_sec / 3600;
    const m = (tick_sec / 60) % 60;
    const s = tick_sec % 60;

    // Use status_ok color for normal rendering
    renderer.writeColor(theme.status_ok);
    renderer.writeFmt("\x1b[{d};{d}HBTC-USD | Tick: {d} | {d:02}:{d:02}:{d:02} | Demo Mode | q=quit", .{
        rect.y + 1, rect.x + 1,
        status.tick,
        h, m, s,
    });
    renderer.resetColor();
}
