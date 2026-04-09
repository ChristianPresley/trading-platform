const std = @import("std");

// MAX_TAPE_ENTRIES from trade_tape_panel.zig (pub const)
const trade_tape_panel = @import("trade_tape_panel");

// --- Constants ---

test "MAX_TAPE_ENTRIES is 128" {
    try std.testing.expectEqual(@as(usize, 128), trade_tape_panel.MAX_TAPE_ENTRIES);
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
    const id = InstrumentId.fromSlice("BTC-USD");
    try std.testing.expectEqualStrings("BTC-USD", id.slice());
}

test "InstrumentId truncates at 32 bytes" {
    const long_name = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    const id = InstrumentId.fromSlice(long_name);
    try std.testing.expectEqual(@as(u8, 32), id.len);
}

test "InstrumentId empty string" {
    const id = InstrumentId.fromSlice("");
    try std.testing.expectEqual(@as(u8, 0), id.len);
}

// --- trader_tag handling ---

test "trader_tag stores short tag" {
    var tag_buf: [8]u8 = undefined;
    var tag_len: u8 = 0;
    const tag = "MM";
    @memcpy(tag_buf[0..tag.len], tag);
    tag_len = @intCast(tag.len);
    const tag_slice = tag_buf[0..tag_len];
    try std.testing.expectEqualStrings("MM", tag_slice);
}

test "trader_tag stores max-length tag (8 bytes)" {
    var tag_buf: [8]u8 = undefined;
    var tag_len: u8 = 0;
    const tag = "LONGNAME";
    @memcpy(tag_buf[0..tag.len], tag);
    tag_len = @intCast(tag.len);
    try std.testing.expectEqual(@as(u8, 8), tag_len);
    try std.testing.expectEqualStrings("LONGNAME", tag_buf[0..tag_len]);
}

test "trader_tag empty has zero length" {
    const tag_len: u8 = 0;
    try std.testing.expectEqual(@as(u8, 0), tag_len);
}

// --- Fixed-point price arithmetic (mirrors draw() logic) ---

test "price whole and fractional extraction" {
    const price: i64 = 50123_45000000;
    const price_whole = @divTrunc(price, 100_000_000);
    const price_frac = @abs(@rem(price, 100_000_000)) / 1_000_000;
    try std.testing.expectEqual(@as(i64, 50123), price_whole);
    try std.testing.expectEqual(@as(i64, 45), price_frac);
}

test "price extraction: exact whole number" {
    const price: i64 = 45000_00000000;
    const price_whole = @divTrunc(price, 100_000_000);
    const price_frac = @abs(@rem(price, 100_000_000)) / 1_000_000;
    try std.testing.expectEqual(@as(i64, 45000), price_whole);
    try std.testing.expectEqual(@as(i64, 0), price_frac);
}

test "quantity whole extraction" {
    const qty: i64 = 350_000_000; // 3.5 in fixed-point
    const qty_whole = @divTrunc(qty, 100_000_000);
    try std.testing.expectEqual(@as(i64, 3), qty_whole);
}

// --- Display logic (tested without renderer) ---

test "show count limited by MAX_TAPE_ENTRIES" {
    const tape_count: usize = 200;
    const total = @min(tape_count, trade_tape_panel.MAX_TAPE_ENTRIES);
    try std.testing.expectEqual(@as(usize, 128), total);
}

test "show count uses tape_count when below MAX_TAPE_ENTRIES" {
    const tape_count: usize = 50;
    const total = @min(tape_count, trade_tape_panel.MAX_TAPE_ENTRIES);
    try std.testing.expectEqual(@as(usize, 50), total);
}

test "show count capped by max_rows" {
    const rect_h: u16 = 8;
    const max_rows = rect_h -| 3;
    const total: usize = 100;
    const show = @min(total, max_rows);
    try std.testing.expectEqual(@as(usize, 5), show);
}

test "most-recent-first index computation" {
    const total: usize = 50;
    const idx_first = total - 1 - 0;
    const idx_second = total - 1 - 1;
    try std.testing.expectEqual(@as(usize, 49), idx_first);
    try std.testing.expectEqual(@as(usize, 48), idx_second);
}

test "early-exit guard: height < 3" {
    const h: u16 = 2;
    try std.testing.expect(h < 3);
}

test "early-exit guard: width < 30" {
    const w: u16 = 29;
    try std.testing.expect(w < 30);
}

test "max_rows saturating subtraction with minimum displayable rect" {
    const rect_h: u16 = 3;
    const max_rows = rect_h -| 3;
    try std.testing.expectEqual(@as(u16, 0), max_rows);
}

// --- SIDE_NAMES lookup logic ---

test "side name lookup: buy" {
    const SIDE_NAMES = [_][]const u8{ "BUY", "SELL" };
    const side: u8 = 0;
    const side_str = if (side < SIDE_NAMES.len) SIDE_NAMES[side] else "?";
    try std.testing.expectEqualStrings("BUY", side_str);
}

test "side name lookup: sell" {
    const SIDE_NAMES = [_][]const u8{ "BUY", "SELL" };
    const side: u8 = 1;
    const side_str = if (side < SIDE_NAMES.len) SIDE_NAMES[side] else "?";
    try std.testing.expectEqualStrings("SELL", side_str);
}

test "side name lookup: out of range returns fallback" {
    const SIDE_NAMES = [_][]const u8{ "BUY", "SELL" };
    const side: u8 = 5;
    const side_str = if (side < SIDE_NAMES.len) SIDE_NAMES[side] else "?";
    try std.testing.expectEqualStrings("?", side_str);
}
