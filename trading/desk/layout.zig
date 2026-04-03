// Layout engine for Trading Desk TUI.
// Divides terminal into five panels.

const terminal_mod = @import("terminal.zig");
const Size = terminal_mod.Size;

pub const Rect = struct {
    x: u16,
    y: u16,
    w: u16,
    h: u16,
};

pub const Panels = struct {
    orderbook: Rect,
    chart: Rect,
    order_entry: Rect,
    recent_orders: Rect,
    status_bar: Rect,
    positions_overlay: Rect,
};

/// Compute panel layout from terminal size.
/// Minimum terminal size is 80x24; clamps to that if smaller.
pub fn compute(size: Size) Panels {
    const rows = if (size.rows < 24) @as(u16, 24) else size.rows;
    const cols = if (size.cols < 80) @as(u16, 80) else size.cols;

    // Bottom row is status bar
    const status_h: u16 = 1;
    const content_h = rows - status_h;

    // Top half: orderbook (left 50%) + positions (right 50%)
    const top_h = content_h / 2;
    const left_w = cols / 2;
    const right_w = cols - left_w;

    // Bottom half (minus status): order entry (left 50%) + recent orders (right 50%)
    const bottom_h = content_h - top_h;

    // Positions overlay: centered, half the terminal width, most of the height
    const overlay_w = cols / 2;
    const overlay_x = cols / 4;
    const overlay_y: u16 = 2;
    const overlay_h: u16 = if (rows > 6) rows - 4 else 2;

    return Panels{
        .orderbook = Rect{ .x = 0, .y = 0, .w = left_w, .h = top_h },
        .chart = Rect{ .x = left_w, .y = 0, .w = right_w, .h = top_h },
        .order_entry = Rect{ .x = 0, .y = top_h, .w = left_w, .h = bottom_h },
        .recent_orders = Rect{ .x = left_w, .y = top_h, .w = right_w, .h = bottom_h },
        .status_bar = Rect{ .x = 0, .y = rows - status_h, .w = cols, .h = status_h },
        .positions_overlay = Rect{ .x = overlay_x, .y = overlay_y, .w = overlay_w, .h = overlay_h },
    };
}

test "layout_compute_basic" {
    const std = @import("std");
    const s = Size{ .rows = 24, .cols = 80 };
    const p = compute(s);
    // Basic sanity: panels cover the terminal
    try std.testing.expect(p.orderbook.w + p.chart.w == 80);
    try std.testing.expect(p.status_bar.y == 23);
    try std.testing.expect(p.status_bar.h == 1);
}
