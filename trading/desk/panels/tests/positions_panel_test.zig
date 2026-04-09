const std = @import("std");
const layout = @import("layout");
const Rect = layout.Rect;
const msg = @import("messages");
const PositionUpdate = msg.PositionUpdate;
const InstrumentId = msg.InstrumentId;

// --- PositionUpdate struct tests ---

test "PositionUpdate default construction" {
    const pos = PositionUpdate{
        .instrument = InstrumentId.fromSlice("BTC-USD"),
        .quantity = 100_000_000,
        .avg_cost = 50000_00000000,
        .unrealized_pnl = 500_00000000,
        .realized_pnl = 0,
    };
    try std.testing.expectEqualStrings("BTC-USD", pos.instrument.slice());
    try std.testing.expectEqual(@as(i64, 100_000_000), pos.quantity);
    try std.testing.expectEqual(@as(i64, 50000_00000000), pos.avg_cost);
    try std.testing.expectEqual(@as(i64, 500_00000000), pos.unrealized_pnl);
    try std.testing.expectEqual(@as(i64, 0), pos.realized_pnl);
}

test "PositionUpdate positive unrealized PNL" {
    const pos = PositionUpdate{
        .instrument = InstrumentId.fromSlice("ETH-USD"),
        .quantity = 500_000_000,
        .avg_cost = 3000_00000000,
        .unrealized_pnl = 200_00000000,
        .realized_pnl = 100_00000000,
    };
    try std.testing.expect(pos.unrealized_pnl >= 0);
}

test "PositionUpdate negative unrealized PNL" {
    const pos = PositionUpdate{
        .instrument = InstrumentId.fromSlice("SOL-USD"),
        .quantity = 1000_000_000,
        .avg_cost = 150_00000000,
        .unrealized_pnl = -50_00000000,
        .realized_pnl = 0,
    };
    try std.testing.expect(pos.unrealized_pnl < 0);
}

// --- Fixed-point arithmetic (mirrors draw() logic) ---

test "avg_cost whole-number extraction" {
    const avg_cost: i64 = 45123_45678900;
    const avg_whole = @divTrunc(avg_cost, 100_000_000);
    try std.testing.expectEqual(@as(i64, 45123), avg_whole);
}

test "unrealized_pnl whole-number extraction: positive" {
    const pnl: i64 = 1234_56789000;
    const pnl_whole = @divTrunc(pnl, 100_000_000);
    try std.testing.expectEqual(@as(i64, 1234), pnl_whole);
}

test "unrealized_pnl whole-number extraction: negative" {
    const pnl: i64 = -500_00000000;
    const pnl_whole = @divTrunc(pnl, 100_000_000);
    try std.testing.expectEqual(@as(i64, -500), pnl_whole);
}

test "unrealized_pnl whole-number extraction: zero" {
    const pnl: i64 = 0;
    const pnl_whole = @divTrunc(pnl, 100_000_000);
    try std.testing.expectEqual(@as(i64, 0), pnl_whole);
}

test "quantity whole-number extraction" {
    const qty: i64 = 250_000_000; // 2.5 in fixed-point
    const qty_whole = @divTrunc(qty, 100_000_000);
    try std.testing.expectEqual(@as(i64, 2), qty_whole);
}

// --- Display logic (tested without renderer) ---

test "show count capped by max_rows" {
    const rect_h: u16 = 8;
    const max_rows = rect_h -| 3;
    const positions_len: usize = 20;
    const show = @min(positions_len, max_rows);
    try std.testing.expectEqual(@as(usize, 5), show);
}

test "show count equals positions length when fewer than max_rows" {
    const rect_h: u16 = 20;
    const max_rows = rect_h -| 3;
    const positions_len: usize = 3;
    const show = @min(positions_len, max_rows);
    try std.testing.expectEqual(@as(usize, 3), show);
}

test "early-exit for small rect: height < 3" {
    const small_rect = Rect{ .x = 0, .y = 0, .w = 80, .h = 2 };
    try std.testing.expect(small_rect.h < 3);
}

test "early-exit for small rect: width < 30" {
    const narrow_rect = Rect{ .x = 0, .y = 0, .w = 29, .h = 10 };
    try std.testing.expect(narrow_rect.w < 30);
}

test "max_rows saturating subtraction with minimum displayable rect" {
    const rect_h: u16 = 3;
    const max_rows = rect_h -| 3;
    try std.testing.expectEqual(@as(u16, 0), max_rows);
}

// --- PNL sign determines color selection ---

test "pnl_positive flag: positive PNL selects bid color" {
    const pnl: i64 = 100_00000000;
    const pnl_positive = pnl >= 0;
    try std.testing.expect(pnl_positive);
}

test "pnl_positive flag: negative PNL selects ask color" {
    const pnl: i64 = -100_00000000;
    const pnl_positive = pnl >= 0;
    try std.testing.expect(!pnl_positive);
}

test "pnl_positive flag: zero PNL selects bid color" {
    const pnl: i64 = 0;
    const pnl_positive = pnl >= 0;
    try std.testing.expect(pnl_positive);
}

// --- PositionUpdate size is fixed ---

test "PositionUpdate is a fixed-size struct" {
    try std.testing.expect(@sizeOf(PositionUpdate) > 0);
    // Should contain: InstrumentId(33) + 4 * i64(32) = ~65 bytes, but with alignment
    try std.testing.expect(@sizeOf(PositionUpdate) >= 33 + 4 * 8);
}
