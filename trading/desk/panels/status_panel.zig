// Status bar panel renderer.

const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const layout = @import("../layout.zig");
const Rect = layout.Rect;
const msg = @import("../messages.zig");
const StatusUpdate = msg.StatusUpdate;
const theme_mod = @import("../theme.zig");
const Theme = theme_mod.Theme;
const Rgb = theme_mod.Rgb;

/// Linearly interpolate between two colors based on t in [0, max_t].
/// t=0 returns `from`, t=max_t returns `to`.
fn lerpColor(from: Rgb, to: Rgb, t: u32, max_t: u32) Rgb {
    if (max_t == 0 or t >= max_t) return to;
    const tf = @as(u32, t);
    const mf = @as(u32, max_t);
    return Rgb{
        .r = @as(u8, @intCast((@as(u32, from.r) * (mf - tf) + @as(u32, to.r) * tf) / mf)),
        .g = @as(u8, @intCast((@as(u32, from.g) * (mf - tf) + @as(u32, to.g) * tf) / mf)),
        .b = @as(u8, @intCast((@as(u32, from.b) * (mf - tf) + @as(u32, to.b) * tf) / mf)),
    };
}

pub fn draw(renderer: *Renderer, rect: Rect, status: *const StatusUpdate, msg_age_frames: u32, theme: *const Theme) void {
    // No border for status bar — single row
    const tick_sec = status.tick / 10; // rough seconds (10 ticks/sec)
    const h = tick_sec / 3600;
    const m = (tick_sec / 60) % 60;
    const s = tick_sec % 60;

    // Interpolate text color from bright to dim over 45 frames
    const fade_frames: u32 = 45;
    const age = @min(msg_age_frames, fade_frames);
    const text_color = lerpColor(theme.text, theme.text_dim, age, fade_frames);

    renderer.writeColor(text_color);
    renderer.writeFmt("\x1b[{d};{d}HBTC-USD | Tick: {d} | {d:02}:{d:02}:{d:02} | Demo Mode | q=quit | p=positions", .{
        rect.y + 1, rect.x + 1,
        status.tick,
        h, m, s,
    });
    renderer.resetColor();
}
