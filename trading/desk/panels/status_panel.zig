const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const Rect = @import("../layout.zig").Rect;
const messages = @import("../messages.zig");
const StatusUpdate = messages.StatusUpdate;

pub fn draw(renderer: *Renderer, rect: Rect, status: *const StatusUpdate, instrument_name: []const u8) void {
    if (rect.w < 20) return;

    // Format time from engine_time_ns
    const ns = status.engine_time_ns;
    const secs = ns / 1_000_000_000;
    const hours = (secs / 3600) % 24;
    const mins = (secs / 60) % 60;
    const sec = secs % 60;

    renderer.drawTextFmt(rect.x + 1, rect.y,
        " {s} | Tick: {d} | {d:0>2}:{d:0>2}:{d:0>2} | Demo Mode | q=quit ",
        .{
            instrument_name,
            status.tick,
            @as(u64, @intCast(hours)),
            @as(u64, @intCast(mins)),
            @as(u64, @intCast(sec)),
        });
}
