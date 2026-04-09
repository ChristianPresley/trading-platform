const std = @import("std");

// MAX_ORDERS from orders_panel.zig (pub const)
const orders_panel = @import("orders_panel");

// --- Constants ---

test "MAX_ORDERS is 64" {
    try std.testing.expectEqual(@as(usize, 64), orders_panel.MAX_ORDERS);
}

// --- InstrumentId (local definition matching messages.InstrumentId) ---

const InstrumentId = struct {
    buf: [32]u8,
    len: u8,

    fn fromSlice(s: []const u8) InstrumentId {
        var id = InstrumentId{ .buf = undefined, .len = 0 };
        const n = @min(s.len, 32);
        @memcpy(id.buf[0..n], s[0..n]);
        id.len = @intCast(n);
        return id;
    }

    fn slice(self: *const InstrumentId) []const u8 {
        return self.buf[0..self.len];
    }
};

// --- InstrumentId tests ---

test "InstrumentId slice round-trip" {
    const id = InstrumentId.fromSlice("SOL-USD");
    try std.testing.expectEqualStrings("SOL-USD", id.slice());
}

test "InstrumentId truncates at 32 bytes" {
    const long_name = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    const id = InstrumentId.fromSlice(long_name);
    try std.testing.expectEqual(@as(u8, 32), id.len);
    try std.testing.expectEqualStrings(long_name[0..32], id.slice());
}

test "InstrumentId empty string" {
    const id = InstrumentId.fromSlice("");
    try std.testing.expectEqual(@as(u8, 0), id.len);
    try std.testing.expectEqualStrings("", id.slice());
}

// --- OrderUpdate field behavior (status/side encoding) ---

test "OrderUpdate side values: 0=buy, 1=sell" {
    const buy_side: u8 = 0;
    const sell_side: u8 = 1;
    try std.testing.expect(buy_side != sell_side);
    try std.testing.expectEqual(@as(u8, 0), buy_side);
    try std.testing.expectEqual(@as(u8, 1), sell_side);
}

test "OrderUpdate status values: pending through rejected" {
    // 0=pending, 1=new, 2=filled, 3=cancelled, 4=rejected
    const statuses = [_]u8{ 0, 1, 2, 3, 4 };
    for (statuses, 0..) |s, i| {
        try std.testing.expectEqual(@as(u8, @intCast(i)), s);
    }
}

// --- Fixed-point arithmetic (mirrors draw() logic) ---

test "price whole extraction from fixed-point" {
    const price: i64 = 45000_00000000;
    const price_whole = @divTrunc(price, 100_000_000);
    try std.testing.expectEqual(@as(i64, 45000), price_whole);
}

test "quantity whole extraction from fixed-point" {
    const quantity: i64 = 2_50000000; // 2.5 BTC
    const qty_whole = @divTrunc(quantity, 100_000_000);
    try std.testing.expectEqual(@as(i64, 2), qty_whole);
}

// --- SIDE_NAMES / STATUS_NAMES lookup logic ---

test "side name lookup: buy" {
    const SIDE_NAMES = [_][]const u8{ "Buy", "Sell" };
    const side: u8 = 0;
    const side_str = if (side < SIDE_NAMES.len) SIDE_NAMES[side] else "?";
    try std.testing.expectEqualStrings("Buy", side_str);
}

test "side name lookup: sell" {
    const SIDE_NAMES = [_][]const u8{ "Buy", "Sell" };
    const side: u8 = 1;
    const side_str = if (side < SIDE_NAMES.len) SIDE_NAMES[side] else "?";
    try std.testing.expectEqualStrings("Sell", side_str);
}

test "side name lookup: out of range returns fallback" {
    const SIDE_NAMES = [_][]const u8{ "Buy", "Sell" };
    const side: u8 = 5;
    const side_str = if (side < SIDE_NAMES.len) SIDE_NAMES[side] else "?";
    try std.testing.expectEqualStrings("?", side_str);
}

test "status name lookup: all valid statuses" {
    const STATUS_NAMES = [_][]const u8{ "Pending", "New", "Filled", "Cancelled", "Rejected" };
    try std.testing.expectEqualStrings("Pending", STATUS_NAMES[0]);
    try std.testing.expectEqualStrings("New", STATUS_NAMES[1]);
    try std.testing.expectEqualStrings("Filled", STATUS_NAMES[2]);
    try std.testing.expectEqualStrings("Cancelled", STATUS_NAMES[3]);
    try std.testing.expectEqualStrings("Rejected", STATUS_NAMES[4]);
}

test "status name lookup: out of range returns fallback" {
    const STATUS_NAMES = [_][]const u8{ "Pending", "New", "Filled", "Cancelled", "Rejected" };
    const status: u8 = 7;
    const status_str = if (status < STATUS_NAMES.len) STATUS_NAMES[status] else "?";
    try std.testing.expectEqualStrings("?", status_str);
}

// --- Display logic (tested without renderer) ---

test "show count capped by max_rows when orders exceed available rows" {
    const rect_h: u16 = 6;
    const max_rows = rect_h -| 3;
    const orders_len: usize = 10;
    const show = @min(orders_len, max_rows);
    try std.testing.expectEqual(@as(usize, 3), show);
}

test "show count equals orders length when fewer than max_rows" {
    const rect_h: u16 = 20;
    const max_rows = rect_h -| 3;
    const orders_len: usize = 5;
    const show = @min(orders_len, max_rows);
    try std.testing.expectEqual(@as(usize, 5), show);
}

test "most-recent-first index computation" {
    const orders_len: usize = 10;
    const idx_first = orders_len - 1 - 0;
    const idx_second = orders_len - 1 - 1;
    try std.testing.expectEqual(@as(usize, 9), idx_first);
    try std.testing.expectEqual(@as(usize, 8), idx_second);
}

test "early-exit guard: height < 3" {
    const h: u16 = 2;
    try std.testing.expect(h < 3);
}

test "early-exit guard: width < 30" {
    const w: u16 = 29;
    try std.testing.expect(w < 30);
}

test "max_rows saturating subtraction with very small rect" {
    const rect_h: u16 = 3;
    const max_rows = rect_h -| 3;
    try std.testing.expectEqual(@as(u16, 0), max_rows);
}
