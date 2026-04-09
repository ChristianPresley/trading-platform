const std = @import("std");
const theme = @import("theme");

// ---------------------------------------------------------------------------
// Rgb struct
// ---------------------------------------------------------------------------

test "Rgb: struct creation with explicit values" {
    const c = theme.Rgb{ .r = 0xFF, .g = 0x80, .b = 0x00 };
    try std.testing.expectEqual(@as(u8, 0xFF), c.r);
    try std.testing.expectEqual(@as(u8, 0x80), c.g);
    try std.testing.expectEqual(@as(u8, 0x00), c.b);
}

test "Rgb: black is all zeros" {
    const black = theme.Rgb{ .r = 0, .g = 0, .b = 0 };
    try std.testing.expectEqual(@as(u8, 0), black.r);
    try std.testing.expectEqual(@as(u8, 0), black.g);
    try std.testing.expectEqual(@as(u8, 0), black.b);
}

test "Rgb: white is all 0xFF" {
    const white = theme.Rgb{ .r = 0xFF, .g = 0xFF, .b = 0xFF };
    try std.testing.expectEqual(@as(u8, 0xFF), white.r);
    try std.testing.expectEqual(@as(u8, 0xFF), white.g);
    try std.testing.expectEqual(@as(u8, 0xFF), white.b);
}

test "Rgb: size is 3 bytes" {
    try std.testing.expectEqual(@as(usize, 3), @sizeOf(theme.Rgb));
}

// ---------------------------------------------------------------------------
// Theme struct — field count
// ---------------------------------------------------------------------------

test "Theme: has 17 Rgb fields" {
    const fields = @typeInfo(theme.Theme).@"struct".fields;
    try std.testing.expectEqual(@as(usize, 22), fields.len);
    // Every field should be Rgb
    inline for (fields) |f| {
        try std.testing.expect(f.type == theme.Rgb);
    }
}

// ---------------------------------------------------------------------------
// Dark theme
// ---------------------------------------------------------------------------

test "dark theme: bid is green (#00C853)" {
    try std.testing.expectEqual(@as(u8, 0x00), theme.dark.bid.r);
    try std.testing.expectEqual(@as(u8, 0xC8), theme.dark.bid.g);
    try std.testing.expectEqual(@as(u8, 0x53), theme.dark.bid.b);
}

test "dark theme: ask is red (#FF1744)" {
    try std.testing.expectEqual(@as(u8, 0xFF), theme.dark.ask.r);
    try std.testing.expectEqual(@as(u8, 0x17), theme.dark.ask.g);
    try std.testing.expectEqual(@as(u8, 0x44), theme.dark.ask.b);
}

test "dark theme: spread is gold (#FFD700)" {
    try std.testing.expectEqual(@as(u8, 0xFF), theme.dark.spread.r);
    try std.testing.expectEqual(@as(u8, 0xD7), theme.dark.spread.g);
    try std.testing.expectEqual(@as(u8, 0x00), theme.dark.spread.b);
}

test "dark theme: border is dark gray (#424242)" {
    try std.testing.expectEqual(@as(u8, 0x42), theme.dark.border.r);
    try std.testing.expectEqual(@as(u8, 0x42), theme.dark.border.g);
    try std.testing.expectEqual(@as(u8, 0x42), theme.dark.border.b);
}

test "dark theme: title is light gray (#E0E0E0)" {
    try std.testing.expectEqual(@as(u8, 0xE0), theme.dark.title.r);
    try std.testing.expectEqual(@as(u8, 0xE0), theme.dark.title.g);
    try std.testing.expectEqual(@as(u8, 0xE0), theme.dark.title.b);
}

test "dark theme: text matches title" {
    try std.testing.expectEqual(theme.dark.title.r, theme.dark.text.r);
    try std.testing.expectEqual(theme.dark.title.g, theme.dark.text.g);
    try std.testing.expectEqual(theme.dark.title.b, theme.dark.text.b);
}

test "dark theme: text_dim is medium gray (#757575)" {
    try std.testing.expectEqual(@as(u8, 0x75), theme.dark.text_dim.r);
    try std.testing.expectEqual(@as(u8, 0x75), theme.dark.text_dim.g);
    try std.testing.expectEqual(@as(u8, 0x75), theme.dark.text_dim.b);
}

test "dark theme: active_field is blue (#1A73E8)" {
    try std.testing.expectEqual(@as(u8, 0x1A), theme.dark.active_field.r);
    try std.testing.expectEqual(@as(u8, 0x73), theme.dark.active_field.g);
    try std.testing.expectEqual(@as(u8, 0xE8), theme.dark.active_field.b);
}

test "dark theme: status_ok matches bid (green)" {
    try std.testing.expectEqual(theme.dark.bid.r, theme.dark.status_ok.r);
    try std.testing.expectEqual(theme.dark.bid.g, theme.dark.status_ok.g);
    try std.testing.expectEqual(theme.dark.bid.b, theme.dark.status_ok.b);
}

test "dark theme: status_error matches ask (red)" {
    try std.testing.expectEqual(theme.dark.ask.r, theme.dark.status_error.r);
    try std.testing.expectEqual(theme.dark.ask.g, theme.dark.status_error.g);
    try std.testing.expectEqual(theme.dark.ask.b, theme.dark.status_error.b);
}

test "dark theme: candle_bull matches bid, candle_bear matches ask" {
    try std.testing.expectEqual(theme.dark.bid.r, theme.dark.candle_bull.r);
    try std.testing.expectEqual(theme.dark.bid.g, theme.dark.candle_bull.g);
    try std.testing.expectEqual(theme.dark.bid.b, theme.dark.candle_bull.b);
    try std.testing.expectEqual(theme.dark.ask.r, theme.dark.candle_bear.r);
    try std.testing.expectEqual(theme.dark.ask.g, theme.dark.candle_bear.g);
    try std.testing.expectEqual(theme.dark.ask.b, theme.dark.candle_bear.b);
}

test "dark theme: background is near-black (#121212)" {
    try std.testing.expectEqual(@as(u8, 0x12), theme.dark.background.r);
    try std.testing.expectEqual(@as(u8, 0x12), theme.dark.background.g);
    try std.testing.expectEqual(@as(u8, 0x12), theme.dark.background.b);
}

test "dark theme: volume is blue (#429EF5)" {
    try std.testing.expectEqual(@as(u8, 0x42), theme.dark.volume.r);
    try std.testing.expectEqual(@as(u8, 0x9E), theme.dark.volume.g);
    try std.testing.expectEqual(@as(u8, 0xF5), theme.dark.volume.b);
}

test "dark theme: indicator_line is amber (#FFAB00)" {
    try std.testing.expectEqual(@as(u8, 0xFF), theme.dark.indicator_line.r);
    try std.testing.expectEqual(@as(u8, 0xAB), theme.dark.indicator_line.g);
    try std.testing.expectEqual(@as(u8, 0x00), theme.dark.indicator_line.b);
}

test "dark theme: crosshair is light gray (#AAAAAA)" {
    try std.testing.expectEqual(@as(u8, 0xAA), theme.dark.crosshair.r);
    try std.testing.expectEqual(@as(u8, 0xAA), theme.dark.crosshair.g);
    try std.testing.expectEqual(@as(u8, 0xAA), theme.dark.crosshair.b);
}

test "dark theme: grid is dark gray (#303030)" {
    try std.testing.expectEqual(@as(u8, 0x30), theme.dark.grid.r);
    try std.testing.expectEqual(@as(u8, 0x30), theme.dark.grid.g);
    try std.testing.expectEqual(@as(u8, 0x30), theme.dark.grid.b);
}

// ---------------------------------------------------------------------------
// Light theme
// ---------------------------------------------------------------------------

test "light theme: bid is dark green (#007E33)" {
    try std.testing.expectEqual(@as(u8, 0x00), theme.light.bid.r);
    try std.testing.expectEqual(@as(u8, 0x7E), theme.light.bid.g);
    try std.testing.expectEqual(@as(u8, 0x33), theme.light.bid.b);
}

test "light theme: ask is dark red (#CC0000)" {
    try std.testing.expectEqual(@as(u8, 0xCC), theme.light.ask.r);
    try std.testing.expectEqual(@as(u8, 0x00), theme.light.ask.g);
    try std.testing.expectEqual(@as(u8, 0x00), theme.light.ask.b);
}

test "light theme: spread is dark gold (#996600)" {
    try std.testing.expectEqual(@as(u8, 0x99), theme.light.spread.r);
    try std.testing.expectEqual(@as(u8, 0x66), theme.light.spread.g);
    try std.testing.expectEqual(@as(u8, 0x00), theme.light.spread.b);
}

test "light theme: border is light gray (#BDBDBD)" {
    try std.testing.expectEqual(@as(u8, 0xBD), theme.light.border.r);
    try std.testing.expectEqual(@as(u8, 0xBD), theme.light.border.g);
    try std.testing.expectEqual(@as(u8, 0xBD), theme.light.border.b);
}

test "light theme: title is near-black (#212121)" {
    try std.testing.expectEqual(@as(u8, 0x21), theme.light.title.r);
    try std.testing.expectEqual(@as(u8, 0x21), theme.light.title.g);
    try std.testing.expectEqual(@as(u8, 0x21), theme.light.title.b);
}

test "light theme: text matches title" {
    try std.testing.expectEqual(theme.light.title.r, theme.light.text.r);
    try std.testing.expectEqual(theme.light.title.g, theme.light.text.g);
    try std.testing.expectEqual(theme.light.title.b, theme.light.text.b);
}

test "light theme: text_dim matches dark theme text_dim (#757575)" {
    try std.testing.expectEqual(theme.dark.text_dim.r, theme.light.text_dim.r);
    try std.testing.expectEqual(theme.dark.text_dim.g, theme.light.text_dim.g);
    try std.testing.expectEqual(theme.dark.text_dim.b, theme.light.text_dim.b);
}

test "light theme: background is white (#FFFFFF)" {
    try std.testing.expectEqual(@as(u8, 0xFF), theme.light.background.r);
    try std.testing.expectEqual(@as(u8, 0xFF), theme.light.background.g);
    try std.testing.expectEqual(@as(u8, 0xFF), theme.light.background.b);
}

test "light theme: status_ok matches bid, status_error matches ask" {
    try std.testing.expectEqual(theme.light.bid.r, theme.light.status_ok.r);
    try std.testing.expectEqual(theme.light.bid.g, theme.light.status_ok.g);
    try std.testing.expectEqual(theme.light.bid.b, theme.light.status_ok.b);
    try std.testing.expectEqual(theme.light.ask.r, theme.light.status_error.r);
    try std.testing.expectEqual(theme.light.ask.g, theme.light.status_error.g);
    try std.testing.expectEqual(theme.light.ask.b, theme.light.status_error.b);
}

test "light theme: candle_bull matches bid, candle_bear matches ask" {
    try std.testing.expectEqual(theme.light.bid.r, theme.light.candle_bull.r);
    try std.testing.expectEqual(theme.light.bid.g, theme.light.candle_bull.g);
    try std.testing.expectEqual(theme.light.bid.b, theme.light.candle_bull.b);
    try std.testing.expectEqual(theme.light.ask.r, theme.light.candle_bear.r);
    try std.testing.expectEqual(theme.light.ask.g, theme.light.candle_bear.g);
    try std.testing.expectEqual(theme.light.ask.b, theme.light.candle_bear.b);
}

// ---------------------------------------------------------------------------
// Classic green theme
// ---------------------------------------------------------------------------

test "classic_green theme: bid is pure bright green (#00FF00)" {
    try std.testing.expectEqual(@as(u8, 0x00), theme.classic_green.bid.r);
    try std.testing.expectEqual(@as(u8, 0xFF), theme.classic_green.bid.g);
    try std.testing.expectEqual(@as(u8, 0x00), theme.classic_green.bid.b);
}

test "classic_green theme: all colors have r=0 (monochrome green)" {
    const fields = @typeInfo(theme.Theme).@"struct".fields;
    inline for (fields) |f| {
        const color = @field(theme.classic_green, f.name);
        try std.testing.expectEqual(@as(u8, 0), color.r);
        try std.testing.expectEqual(@as(u8, 0), color.b);
    }
}

test "classic_green theme: ask is medium green (#00CC00)" {
    try std.testing.expectEqual(@as(u8, 0xCC), theme.classic_green.ask.g);
}

test "classic_green theme: spread is dim green (#00AA00)" {
    try std.testing.expectEqual(@as(u8, 0xAA), theme.classic_green.spread.g);
}

test "classic_green theme: border is dark green (#008800)" {
    try std.testing.expectEqual(@as(u8, 0x88), theme.classic_green.border.g);
}

test "classic_green theme: title matches bid (bright green)" {
    try std.testing.expectEqual(theme.classic_green.bid.g, theme.classic_green.title.g);
}

test "classic_green theme: text is medium green (#00CC00)" {
    try std.testing.expectEqual(@as(u8, 0xCC), theme.classic_green.text.g);
}

test "classic_green theme: text_dim is very dim (#006600)" {
    try std.testing.expectEqual(@as(u8, 0x66), theme.classic_green.text_dim.g);
}

test "classic_green theme: background is near-black green (#000A00)" {
    try std.testing.expectEqual(@as(u8, 0x00), theme.classic_green.background.r);
    try std.testing.expectEqual(@as(u8, 0x0A), theme.classic_green.background.g);
    try std.testing.expectEqual(@as(u8, 0x00), theme.classic_green.background.b);
}

test "classic_green theme: grid is very dim green (#003300)" {
    try std.testing.expectEqual(@as(u8, 0x33), theme.classic_green.grid.g);
}

// ---------------------------------------------------------------------------
// Cross-theme invariants
// ---------------------------------------------------------------------------

test "dark theme background is darker than light theme background" {
    // Sum of RGB channels as a simple brightness proxy
    const dark_brightness = @as(u16, theme.dark.background.r) +
        @as(u16, theme.dark.background.g) +
        @as(u16, theme.dark.background.b);
    const light_brightness = @as(u16, theme.light.background.r) +
        @as(u16, theme.light.background.g) +
        @as(u16, theme.light.background.b);
    try std.testing.expect(dark_brightness < light_brightness);
}

test "dark theme text is brighter than dark theme background" {
    const text_brightness = @as(u16, theme.dark.text.r) +
        @as(u16, theme.dark.text.g) +
        @as(u16, theme.dark.text.b);
    const bg_brightness = @as(u16, theme.dark.background.r) +
        @as(u16, theme.dark.background.g) +
        @as(u16, theme.dark.background.b);
    try std.testing.expect(text_brightness > bg_brightness);
}

test "light theme text is darker than light theme background" {
    const text_brightness = @as(u16, theme.light.text.r) +
        @as(u16, theme.light.text.g) +
        @as(u16, theme.light.text.b);
    const bg_brightness = @as(u16, theme.light.background.r) +
        @as(u16, theme.light.background.g) +
        @as(u16, theme.light.background.b);
    try std.testing.expect(text_brightness < bg_brightness);
}

test "all three theme constants are distinct" {
    // Compare background colors to verify themes are distinct
    try std.testing.expect(theme.dark.background.r != theme.light.background.r or
        theme.dark.background.g != theme.light.background.g or
        theme.dark.background.b != theme.light.background.b);
    try std.testing.expect(theme.dark.background.r != theme.classic_green.background.r or
        theme.dark.background.g != theme.classic_green.background.g or
        theme.dark.background.b != theme.classic_green.background.b);
    try std.testing.expect(theme.light.background.r != theme.classic_green.background.r or
        theme.light.background.g != theme.classic_green.background.g or
        theme.light.background.b != theme.classic_green.background.b);
}
