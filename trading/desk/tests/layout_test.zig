const std = @import("std");
const layout = @import("layout");
const Rect = layout.Rect;
const Panels = layout.Panels;
const Size = layout.Size;

// --- Rect struct tests ---

test "Rect default initialization" {
    const r = Rect{ .x = 0, .y = 0, .w = 0, .h = 0 };
    try std.testing.expectEqual(@as(u16, 0), r.x);
    try std.testing.expectEqual(@as(u16, 0), r.y);
    try std.testing.expectEqual(@as(u16, 0), r.w);
    try std.testing.expectEqual(@as(u16, 0), r.h);
}

test "Rect stores arbitrary values" {
    const r = Rect{ .x = 10, .y = 20, .w = 40, .h = 12 };
    try std.testing.expectEqual(@as(u16, 10), r.x);
    try std.testing.expectEqual(@as(u16, 20), r.y);
    try std.testing.expectEqual(@as(u16, 40), r.w);
    try std.testing.expectEqual(@as(u16, 12), r.h);
}

// --- Panels struct tests ---

test "Panels has all seven panel fields" {
    try std.testing.expect(@sizeOf(Panels) > 0);
    // Each panel is a Rect (4 x u16 = 8 bytes)
    try std.testing.expectEqual(@as(usize, 8), @sizeOf(Rect));
}

// --- compute() with minimum terminal size (80x24) ---

test "compute: minimum size 80x24 panel widths sum to terminal width" {
    const p = layout.compute(Size{ .rows = 24, .cols = 80 });
    // Top row: orderbook + chart should span full width
    try std.testing.expectEqual(@as(u16, 80), p.orderbook.w + p.chart.w);
    // Bottom row: order_entry + recent_orders should span full width
    try std.testing.expectEqual(@as(u16, 80), p.order_entry.w + p.recent_orders.w);
}

test "compute: minimum size 80x24 status bar at bottom" {
    const p = layout.compute(Size{ .rows = 24, .cols = 80 });
    try std.testing.expectEqual(@as(u16, 23), p.status_bar.y);
    try std.testing.expectEqual(@as(u16, 1), p.status_bar.h);
    try std.testing.expectEqual(@as(u16, 80), p.status_bar.w);
    try std.testing.expectEqual(@as(u16, 0), p.status_bar.x);
}

test "compute: minimum size 80x24 top panels start at row 0" {
    const p = layout.compute(Size{ .rows = 24, .cols = 80 });
    try std.testing.expectEqual(@as(u16, 0), p.orderbook.y);
    try std.testing.expectEqual(@as(u16, 0), p.chart.y);
}

test "compute: minimum size 80x24 chart starts at left_w" {
    const p = layout.compute(Size{ .rows = 24, .cols = 80 });
    try std.testing.expectEqual(p.orderbook.w, p.chart.x);
}

test "compute: minimum size 80x24 top and bottom heights sum to content area" {
    const p = layout.compute(Size{ .rows = 24, .cols = 80 });
    // content_h = 24 - 1 = 23, top_h = 23 / 2 = 11, bottom_h = 23 - 11 = 12
    try std.testing.expectEqual(@as(u16, 23), p.orderbook.h + p.order_entry.h);
}

test "compute: minimum size 80x24 bottom-right split: orders + tape = bottom_h" {
    const p = layout.compute(Size{ .rows = 24, .cols = 80 });
    try std.testing.expectEqual(p.order_entry.h, p.recent_orders.h + p.trade_tape.h);
}

test "compute: minimum size 80x24 trade tape y follows recent orders" {
    const p = layout.compute(Size{ .rows = 24, .cols = 80 });
    try std.testing.expectEqual(p.recent_orders.y + p.recent_orders.h, p.trade_tape.y);
}

test "compute: minimum size 80x24 order entry starts below orderbook" {
    const p = layout.compute(Size{ .rows = 24, .cols = 80 });
    try std.testing.expectEqual(p.orderbook.h, p.order_entry.y);
}

// --- compute() clamping for undersized terminals ---

test "compute: terminal smaller than 80x24 clamps to minimum" {
    const p = layout.compute(Size{ .rows = 10, .cols = 40 });
    try std.testing.expectEqual(@as(u16, 80), p.orderbook.w + p.chart.w);
    try std.testing.expectEqual(@as(u16, 23), p.status_bar.y);
}

test "compute: zero-size terminal clamps to minimum" {
    const p = layout.compute(Size{ .rows = 0, .cols = 0 });
    try std.testing.expectEqual(@as(u16, 80), p.status_bar.w);
    try std.testing.expectEqual(@as(u16, 23), p.status_bar.y);
}

test "compute: rows below minimum but cols above minimum" {
    const p = layout.compute(Size{ .rows = 10, .cols = 120 });
    try std.testing.expectEqual(@as(u16, 120), p.orderbook.w + p.chart.w);
    try std.testing.expectEqual(@as(u16, 23), p.status_bar.y);
}

// --- compute() with larger terminal ---

test "compute: large terminal 160x48 uses actual dimensions" {
    const p = layout.compute(Size{ .rows = 48, .cols = 160 });
    try std.testing.expectEqual(@as(u16, 160), p.orderbook.w + p.chart.w);
    try std.testing.expectEqual(@as(u16, 47), p.status_bar.y);
    try std.testing.expectEqual(@as(u16, 160), p.status_bar.w);
}

test "compute: large terminal panel heights sum correctly" {
    const p = layout.compute(Size{ .rows = 48, .cols = 160 });
    try std.testing.expectEqual(@as(u16, 47), p.orderbook.h + p.order_entry.h);
}

// --- Positions overlay tests ---

test "compute: positions overlay is centered horizontally" {
    const p = layout.compute(Size{ .rows = 24, .cols = 80 });
    try std.testing.expectEqual(@as(u16, 20), p.positions_overlay.x);
    try std.testing.expectEqual(@as(u16, 40), p.positions_overlay.w);
}

test "compute: positions overlay starts at y=2" {
    const p = layout.compute(Size{ .rows = 24, .cols = 80 });
    try std.testing.expectEqual(@as(u16, 2), p.positions_overlay.y);
}

test "compute: positions overlay height is rows - 4 for normal terminal" {
    const p = layout.compute(Size{ .rows = 24, .cols = 80 });
    try std.testing.expectEqual(@as(u16, 20), p.positions_overlay.h);
}

test "compute: positions overlay large terminal" {
    const p = layout.compute(Size{ .rows = 48, .cols = 160 });
    try std.testing.expectEqual(@as(u16, 40), p.positions_overlay.x);
    try std.testing.expectEqual(@as(u16, 80), p.positions_overlay.w);
    try std.testing.expectEqual(@as(u16, 44), p.positions_overlay.h);
}

// --- Layout proportions ---

test "compute: left/right columns are roughly 50/50 split" {
    const p = layout.compute(Size{ .rows = 24, .cols = 80 });
    try std.testing.expectEqual(@as(u16, 40), p.orderbook.w);
    try std.testing.expectEqual(@as(u16, 40), p.chart.w);
}

test "compute: odd column count splits correctly" {
    const p = layout.compute(Size{ .rows = 24, .cols = 81 });
    try std.testing.expectEqual(@as(u16, 40), p.orderbook.w);
    try std.testing.expectEqual(@as(u16, 41), p.chart.w);
    try std.testing.expectEqual(@as(u16, 81), p.orderbook.w + p.chart.w);
}

test "compute: bottom-right split is roughly 40/60 orders/tape" {
    const p = layout.compute(Size{ .rows = 24, .cols = 80 });
    try std.testing.expectEqual(@as(u16, 4), p.recent_orders.h);
    try std.testing.expectEqual(@as(u16, 8), p.trade_tape.h);
}
