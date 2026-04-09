const std = @import("std");
const msg = @import("messages");
const StatusUpdate = msg.StatusUpdate;
const theme_mod = @import("theme");
const Theme = theme_mod.Theme;
const Rgb = theme_mod.Rgb;

// --- StatusUpdate struct tests ---

test "StatusUpdate default construction" {
    const status = StatusUpdate{
        .tick = 0,
        .engine_time_ns = 0,
        .instrument_count = 0,
        .connected = false,
        .strategy_state = undefined,
        .strategy_state_len = 0,
        .vpin_scores = [_]i64{0} ** 8,
        .vpin_valid = [_]bool{false} ** 8,
    };
    try std.testing.expectEqual(@as(u64, 0), status.tick);
    try std.testing.expectEqual(@as(u8, 0), status.instrument_count);
    try std.testing.expect(!status.connected);
}

test "StatusUpdate tick to time conversion: zero tick" {
    const tick: u64 = 0;
    const tick_sec = tick / 10;
    const h = tick_sec / 3600;
    const m = (tick_sec / 60) % 60;
    const s = tick_sec % 60;
    try std.testing.expectEqual(@as(u64, 0), h);
    try std.testing.expectEqual(@as(u64, 0), m);
    try std.testing.expectEqual(@as(u64, 0), s);
}

test "StatusUpdate tick to time conversion: 1 hour" {
    const tick: u64 = 36000;
    const tick_sec = tick / 10;
    const h = tick_sec / 3600;
    const m = (tick_sec / 60) % 60;
    const s = tick_sec % 60;
    try std.testing.expectEqual(@as(u64, 1), h);
    try std.testing.expectEqual(@as(u64, 0), m);
    try std.testing.expectEqual(@as(u64, 0), s);
}

test "StatusUpdate tick to time conversion: 1 hour 30 minutes 45 seconds" {
    const tick: u64 = 54450;
    const tick_sec = tick / 10;
    const h = tick_sec / 3600;
    const m = (tick_sec / 60) % 60;
    const s = tick_sec % 60;
    try std.testing.expectEqual(@as(u64, 1), h);
    try std.testing.expectEqual(@as(u64, 30), m);
    try std.testing.expectEqual(@as(u64, 45), s);
}

test "StatusUpdate tick to time conversion: 10 ticks = 1 second" {
    const tick: u64 = 10;
    const tick_sec = tick / 10;
    try std.testing.expectEqual(@as(u64, 1), tick_sec);
}

test "StatusUpdate tick to time conversion: 9 ticks rounds down to 0 seconds" {
    const tick: u64 = 9;
    const tick_sec = tick / 10;
    try std.testing.expectEqual(@as(u64, 0), tick_sec);
}

// --- lerpColor tests (replicating the fn from status_panel.zig) ---

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

test "lerpColor: t=0 returns from color" {
    const from = Rgb{ .r = 200, .g = 200, .b = 200 };
    const to = Rgb{ .r = 100, .g = 100, .b = 100 };
    const result = lerpColor(from, to, 0, 45);
    try std.testing.expectEqual(@as(u8, 200), result.r);
    try std.testing.expectEqual(@as(u8, 200), result.g);
    try std.testing.expectEqual(@as(u8, 200), result.b);
}

test "lerpColor: t=max_t returns to color" {
    const from = Rgb{ .r = 200, .g = 200, .b = 200 };
    const to = Rgb{ .r = 100, .g = 100, .b = 100 };
    const result = lerpColor(from, to, 45, 45);
    try std.testing.expectEqual(@as(u8, 100), result.r);
    try std.testing.expectEqual(@as(u8, 100), result.g);
    try std.testing.expectEqual(@as(u8, 100), result.b);
}

test "lerpColor: t exceeds max_t returns to color" {
    const from = Rgb{ .r = 200, .g = 200, .b = 200 };
    const to = Rgb{ .r = 50, .g = 50, .b = 50 };
    const result = lerpColor(from, to, 100, 45);
    try std.testing.expectEqual(@as(u8, 50), result.r);
    try std.testing.expectEqual(@as(u8, 50), result.g);
    try std.testing.expectEqual(@as(u8, 50), result.b);
}

test "lerpColor: max_t=0 returns to color" {
    const from = Rgb{ .r = 200, .g = 200, .b = 200 };
    const to = Rgb{ .r = 100, .g = 100, .b = 100 };
    const result = lerpColor(from, to, 0, 0);
    try std.testing.expectEqual(@as(u8, 100), result.r);
}

test "lerpColor: halfway interpolation" {
    const from = Rgb{ .r = 0, .g = 0, .b = 0 };
    const to = Rgb{ .r = 100, .g = 200, .b = 50 };
    const result = lerpColor(from, to, 50, 100);
    try std.testing.expectEqual(@as(u8, 50), result.r);
    try std.testing.expectEqual(@as(u8, 100), result.g);
    try std.testing.expectEqual(@as(u8, 25), result.b);
}

test "lerpColor: quarter interpolation" {
    const from = Rgb{ .r = 0, .g = 0, .b = 0 };
    const to = Rgb{ .r = 100, .g = 100, .b = 100 };
    const result = lerpColor(from, to, 25, 100);
    try std.testing.expectEqual(@as(u8, 25), result.r);
    try std.testing.expectEqual(@as(u8, 25), result.g);
    try std.testing.expectEqual(@as(u8, 25), result.b);
}

// --- Fade logic (replicating draw() behavior) ---

test "fade age is clamped to fade_frames" {
    const fade_frames: u32 = 45;
    const msg_age_frames: u32 = 100;
    const age = @min(msg_age_frames, fade_frames);
    try std.testing.expectEqual(@as(u32, 45), age);
}

test "fade age passes through when within range" {
    const fade_frames: u32 = 45;
    const msg_age_frames: u32 = 20;
    const age = @min(msg_age_frames, fade_frames);
    try std.testing.expectEqual(@as(u32, 20), age);
}

test "fade with dark theme: text fades from bright to dim" {
    const theme = theme_mod.dark;
    const fade_frames: u32 = 45;
    const color_start = lerpColor(theme.text, theme.text_dim, 0, fade_frames);
    try std.testing.expectEqual(theme.text.r, color_start.r);
    try std.testing.expectEqual(theme.text.g, color_start.g);
    try std.testing.expectEqual(theme.text.b, color_start.b);
    const color_end = lerpColor(theme.text, theme.text_dim, 45, fade_frames);
    try std.testing.expectEqual(theme.text_dim.r, color_end.r);
    try std.testing.expectEqual(theme.text_dim.g, color_end.g);
    try std.testing.expectEqual(theme.text_dim.b, color_end.b);
}

// --- StatusUpdate fixed-size type ---

test "StatusUpdate is a fixed-size struct" {
    try std.testing.expect(@sizeOf(StatusUpdate) > 0);
}

test "StatusUpdate vpin arrays have 8 entries" {
    const status = StatusUpdate{
        .tick = 100,
        .engine_time_ns = 0,
        .instrument_count = 3,
        .connected = true,
        .strategy_state = undefined,
        .strategy_state_len = 0,
        .vpin_scores = [_]i64{0} ** 8,
        .vpin_valid = [_]bool{false} ** 8,
    };
    try std.testing.expectEqual(@as(usize, 8), status.vpin_scores.len);
    try std.testing.expectEqual(@as(usize, 8), status.vpin_valid.len);
}
