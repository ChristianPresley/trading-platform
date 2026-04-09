// Theme system for Trading Desk TUI.
// Defines RGB color types and pre-built theme instances.

const std = @import("std");

pub const Rgb = struct {
    r: u8,
    g: u8,
    b: u8,
};

pub const Theme = struct {
    bid: Rgb,
    ask: Rgb,
    spread: Rgb,
    border: Rgb,
    title: Rgb,
    text: Rgb,
    text_dim: Rgb,
    active_field: Rgb,
    status_ok: Rgb,
    status_error: Rgb,
    candle_bull: Rgb,
    candle_bear: Rgb,
    background: Rgb,
    volume: Rgb,
    indicator_line: Rgb,
    crosshair: Rgb,
    grid: Rgb,
    footprint_bid: Rgb,
    footprint_ask: Rgb,
    footprint_imbalance: Rgb,
    footprint_delta_pos: Rgb,
    footprint_delta_neg: Rgb,
};

/// Dark theme: green bid, red ask, gray border, white text.
pub const dark = Theme{
    .bid = .{ .r = 0x00, .g = 0xC8, .b = 0x53 }, // #00C853 green
    .ask = .{ .r = 0xFF, .g = 0x17, .b = 0x44 }, // #FF1744 red
    .spread = .{ .r = 0xFF, .g = 0xD7, .b = 0x00 }, // #FFD700 gold
    .border = .{ .r = 0x42, .g = 0x42, .b = 0x42 }, // #424242 dark gray
    .title = .{ .r = 0xE0, .g = 0xE0, .b = 0xE0 }, // #E0E0E0 light gray
    .text = .{ .r = 0xE0, .g = 0xE0, .b = 0xE0 }, // #E0E0E0 light gray
    .text_dim = .{ .r = 0x75, .g = 0x75, .b = 0x75 }, // #757575 medium gray
    .active_field = .{ .r = 0x1A, .g = 0x73, .b = 0xE8 }, // #1A73E8 blue
    .status_ok = .{ .r = 0x00, .g = 0xC8, .b = 0x53 }, // #00C853 green
    .status_error = .{ .r = 0xFF, .g = 0x17, .b = 0x44 }, // #FF1744 red
    .candle_bull = .{ .r = 0x00, .g = 0xC8, .b = 0x53 }, // #00C853 green
    .candle_bear = .{ .r = 0xFF, .g = 0x17, .b = 0x44 }, // #FF1744 red
    .background = .{ .r = 0x12, .g = 0x12, .b = 0x12 }, // #121212 near-black
    .volume = .{ .r = 0x42, .g = 0x9E, .b = 0xF5 }, // #429EF5 blue
    .indicator_line = .{ .r = 0xFF, .g = 0xAB, .b = 0x00 }, // #FFAB00 amber
    .crosshair = .{ .r = 0xAA, .g = 0xAA, .b = 0xAA }, // #AAAAAA light gray
    .grid = .{ .r = 0x30, .g = 0x30, .b = 0x30 }, // #303030 dark gray
    .footprint_bid = .{ .r = 0xEF, .g = 0x53, .b = 0x50 }, // #EF5350 red
    .footprint_ask = .{ .r = 0x26, .g = 0xA6, .b = 0x9A }, // #26A69A teal
    .footprint_imbalance = .{ .r = 0xFF, .g = 0xD7, .b = 0x40 }, // #FFD740 amber
    .footprint_delta_pos = .{ .r = 0x00, .g = 0xC8, .b = 0x53 }, // #00C853 green
    .footprint_delta_neg = .{ .r = 0xFF, .g = 0x17, .b = 0x44 }, // #FF1744 red
};

/// Light theme: dark green bid, dark red ask, light gray border, black text.
pub const light = Theme{
    .bid = .{ .r = 0x00, .g = 0x7E, .b = 0x33 }, // #007E33 dark green
    .ask = .{ .r = 0xCC, .g = 0x00, .b = 0x00 }, // #CC0000 dark red
    .spread = .{ .r = 0x99, .g = 0x66, .b = 0x00 }, // #996600 dark gold
    .border = .{ .r = 0xBD, .g = 0xBD, .b = 0xBD }, // #BDBDBD light gray
    .title = .{ .r = 0x21, .g = 0x21, .b = 0x21 }, // #212121 near-black
    .text = .{ .r = 0x21, .g = 0x21, .b = 0x21 }, // #212121 near-black
    .text_dim = .{ .r = 0x75, .g = 0x75, .b = 0x75 }, // #757575 medium gray
    .active_field = .{ .r = 0x18, .g = 0x56, .b = 0x9E }, // #18569E blue
    .status_ok = .{ .r = 0x00, .g = 0x7E, .b = 0x33 }, // #007E33 dark green
    .status_error = .{ .r = 0xCC, .g = 0x00, .b = 0x00 }, // #CC0000 dark red
    .candle_bull = .{ .r = 0x00, .g = 0x7E, .b = 0x33 }, // #007E33 dark green
    .candle_bear = .{ .r = 0xCC, .g = 0x00, .b = 0x00 }, // #CC0000 dark red
    .background = .{ .r = 0xFF, .g = 0xFF, .b = 0xFF }, // #FFFFFF white
    .volume = .{ .r = 0x18, .g = 0x56, .b = 0x9E }, // #18569E dark blue
    .indicator_line = .{ .r = 0xE6, .g = 0x8A, .b = 0x00 }, // #E68A00 dark amber
    .crosshair = .{ .r = 0x61, .g = 0x61, .b = 0x61 }, // #616161 medium gray
    .grid = .{ .r = 0xE0, .g = 0xE0, .b = 0xE0 }, // #E0E0E0 light gray
    .footprint_bid = .{ .r = 0xC6, .g = 0x28, .b = 0x28 }, // #C62828 dark red
    .footprint_ask = .{ .r = 0x00, .g = 0x79, .b = 0x5E }, // #00795E dark teal
    .footprint_imbalance = .{ .r = 0xFF, .g = 0x8F, .b = 0x00 }, // #FF8F00 amber
    .footprint_delta_pos = .{ .r = 0x00, .g = 0x7E, .b = 0x33 }, // #007E33 dark green
    .footprint_delta_neg = .{ .r = 0xCC, .g = 0x00, .b = 0x00 }, // #CC0000 dark red
};

/// Classic green terminal theme: phosphor-green palette.
pub const classic_green = Theme{
    .bid = .{ .r = 0x00, .g = 0xFF, .b = 0x00 }, // #00FF00 bright green
    .ask = .{ .r = 0x00, .g = 0xCC, .b = 0x00 }, // #00CC00 medium green
    .spread = .{ .r = 0x00, .g = 0xAA, .b = 0x00 }, // #00AA00 dim green
    .border = .{ .r = 0x00, .g = 0x88, .b = 0x00 }, // #008800 dark green
    .title = .{ .r = 0x00, .g = 0xFF, .b = 0x00 }, // #00FF00 bright green
    .text = .{ .r = 0x00, .g = 0xCC, .b = 0x00 }, // #00CC00 medium green
    .text_dim = .{ .r = 0x00, .g = 0x66, .b = 0x00 }, // #006600 very dim green
    .active_field = .{ .r = 0x00, .g = 0xFF, .b = 0x00 }, // #00FF00 bright green
    .status_ok = .{ .r = 0x00, .g = 0xFF, .b = 0x00 }, // #00FF00 bright green
    .status_error = .{ .r = 0x00, .g = 0x88, .b = 0x00 }, // #008800 dark green (no red)
    .candle_bull = .{ .r = 0x00, .g = 0xFF, .b = 0x00 }, // #00FF00 bright green
    .candle_bear = .{ .r = 0x00, .g = 0x88, .b = 0x00 }, // #008800 dark green
    .background = .{ .r = 0x00, .g = 0x0A, .b = 0x00 }, // #000A00 near-black green
    .volume = .{ .r = 0x00, .g = 0xAA, .b = 0x00 }, // #00AA00 dim green
    .indicator_line = .{ .r = 0x00, .g = 0xDD, .b = 0x00 }, // #00DD00 medium green
    .crosshair = .{ .r = 0x00, .g = 0x99, .b = 0x00 }, // #009900 green
    .grid = .{ .r = 0x00, .g = 0x33, .b = 0x00 }, // #003300 very dim green
    .footprint_bid = .{ .r = 0x00, .g = 0x88, .b = 0x00 }, // #008800 dark green
    .footprint_ask = .{ .r = 0x00, .g = 0xFF, .b = 0x00 }, // #00FF00 bright green
    .footprint_imbalance = .{ .r = 0x00, .g = 0xDD, .b = 0x00 }, // #00DD00 medium green
    .footprint_delta_pos = .{ .r = 0x00, .g = 0xFF, .b = 0x00 }, // #00FF00 bright green
    .footprint_delta_neg = .{ .r = 0x00, .g = 0x66, .b = 0x00 }, // #006600 dim green
};

test "theme_field_access" {
    // dark theme bid is green: r=0, g>0, b>0
    try std.testing.expect(dark.bid.r == 0x00);
    try std.testing.expect(dark.bid.g == 0xC8);
    try std.testing.expect(dark.bid.b == 0x53);

    // dark theme ask is red: r>0
    try std.testing.expect(dark.ask.r == 0xFF);
    try std.testing.expect(dark.ask.g == 0x17);

    // light theme has non-zero bid green component
    try std.testing.expect(light.bid.g > 0);

    // classic_green theme bid is pure green
    try std.testing.expect(classic_green.bid.r == 0x00);
    try std.testing.expect(classic_green.bid.g == 0xFF);
    try std.testing.expect(classic_green.bid.b == 0x00);
}
