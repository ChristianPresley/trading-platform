const Terminal = @import("terminal.zig");

pub const Rect = struct {
    x: u16,
    y: u16,
    w: u16,
    h: u16,
};

pub const Panels = struct {
    orderbook: Rect,
    positions: Rect,
    order_entry: Rect,
    recent_orders: Rect,
    status_bar: Rect,
};

/// Compute panel layout for the given terminal size.
/// Layout: top half split 50/50 (orderbook left, positions right),
/// bottom half minus status bar split 50/50 (order entry left, recent orders right),
/// bottom row is status bar.
pub fn compute(size: Terminal.Size) Panels {
    const cols = if (size.cols < 80) 80 else size.cols;
    const rows = if (size.rows < 24) 24 else size.rows;

    const half_w = cols / 2;
    const top_h = rows / 2;
    const bot_h = rows - top_h - 1; // -1 for status bar

    return Panels{
        .orderbook = .{
            .x = 0,
            .y = 0,
            .w = half_w,
            .h = top_h,
        },
        .positions = .{
            .x = half_w,
            .y = 0,
            .w = cols - half_w,
            .h = top_h,
        },
        .order_entry = .{
            .x = 0,
            .y = top_h,
            .w = half_w,
            .h = bot_h,
        },
        .recent_orders = .{
            .x = half_w,
            .y = top_h,
            .w = cols - half_w,
            .h = bot_h,
        },
        .status_bar = .{
            .x = 0,
            .y = rows - 1,
            .w = cols,
            .h = 1,
        },
    };
}

const std = @import("std");

test "layout_compute_80x24" {
    const panels = compute(.{ .rows = 24, .cols = 80 });
    // Orderbook: top-left
    try std.testing.expectEqual(@as(u16, 0), panels.orderbook.x);
    try std.testing.expectEqual(@as(u16, 0), panels.orderbook.y);
    try std.testing.expectEqual(@as(u16, 40), panels.orderbook.w);
    // Positions: top-right
    try std.testing.expectEqual(@as(u16, 40), panels.positions.x);
    try std.testing.expectEqual(@as(u16, 0), panels.positions.y);
    // Status bar: bottom row
    try std.testing.expectEqual(@as(u16, 23), panels.status_bar.y);
    try std.testing.expectEqual(@as(u16, 80), panels.status_bar.w);
    try std.testing.expectEqual(@as(u16, 1), panels.status_bar.h);
}
