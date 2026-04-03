const std = @import("std");
const pitch = @import("pitch");

fn makeSymbol6(s: []const u8) [6]u8 {
    var sym = [_]u8{' '} ** 6;
    const len = @min(s.len, 6);
    @memcpy(sym[0..len], s[0..len]);
    return sym;
}

test "PITCH AddOrderLong message" {
    // Add Order Long (0x21): 34 bytes
    // [0] type=0x21, [1..4] timestamp(u32), [5..12] order_id(u64), [13] side,
    // [14..17] shares(u32), [18..23] symbol([6]), [24..31] price(u64), [32] display, [33] reserved
    var buf = [_]u8{0} ** 34;
    buf[0] = 0x21;
    // timestamp = 1234567890
    std.mem.writeInt(u32, buf[1..5], 1234567890, .big);
    // order_id = 9876543210
    std.mem.writeInt(u64, buf[5..13], 9876543210, .big);
    // side = 'B'
    buf[13] = 'B';
    // shares = 1000
    std.mem.writeInt(u32, buf[14..18], 1000, .big);
    // symbol = "NVDA  "
    const sym = makeSymbol6("NVDA");
    @memcpy(buf[18..24], &sym);
    // price = 5000000 (in 1/10000 = $500.00)
    std.mem.writeInt(u64, buf[24..32], 5000000, .big);
    // display = 'Y'
    buf[32] = 'Y';
    buf[33] = 0;

    var parser = pitch.PitchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .add_order_long);
    const ao = msg.add_order_long;
    try std.testing.expectEqual(@as(u32, 1234567890), ao.timestamp);
    try std.testing.expectEqual(@as(u64, 9876543210), ao.order_id);
    try std.testing.expectEqual(@as(u8, 'B'), ao.side);
    try std.testing.expectEqual(@as(u32, 1000), ao.shares);
    try std.testing.expectEqualSlices(u8, &sym, &ao.symbol);
    try std.testing.expectEqual(@as(u64, 5000000), ao.price);
    try std.testing.expectEqual(@as(u8, 'Y'), ao.display);
}

test "PITCH AddOrderShort message" {
    // Add Order Short (0x22): 26 bytes
    // [0] type=0x22, [1..4] timestamp, [5..12] order_id, [13] side, [14..15] shares(u16),
    // [16..21] symbol(6), [22..23] price(u16), [24] display, [25] reserved
    var buf = [_]u8{0} ** 26;
    buf[0] = 0x22;
    std.mem.writeInt(u32, buf[1..5], 555555, .big);
    std.mem.writeInt(u64, buf[5..13], 111222333, .big);
    buf[13] = 'S';
    std.mem.writeInt(u16, buf[14..16], 200, .big);
    const sym = makeSymbol6("MSFT");
    @memcpy(buf[16..22], &sym);
    std.mem.writeInt(u16, buf[22..24], 3750, .big); // $37.50 in 1/100
    buf[24] = 'Y';
    buf[25] = 0;

    var parser = pitch.PitchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .add_order_short);
    const ao = msg.add_order_short;
    try std.testing.expectEqual(@as(u32, 555555), ao.timestamp);
    try std.testing.expectEqual(@as(u64, 111222333), ao.order_id);
    try std.testing.expectEqual(@as(u8, 'S'), ao.side);
    try std.testing.expectEqual(@as(u16, 200), ao.shares);
    try std.testing.expectEqualSlices(u8, &sym, &ao.symbol);
    try std.testing.expectEqual(@as(u16, 3750), ao.price);
}

test "PITCH Execute message" {
    // Order Execute (0x23): 25 bytes
    // [0]=0x23, [1..4] ts, [5..12] order_id, [13..16] executed_shares, [17..24] execution_id
    var buf = [_]u8{0} ** 25;
    buf[0] = 0x23;
    std.mem.writeInt(u32, buf[1..5], 99999, .big);
    std.mem.writeInt(u64, buf[5..13], 777888999, .big);
    std.mem.writeInt(u32, buf[13..17], 500, .big);
    std.mem.writeInt(u64, buf[17..25], 123456789012345, .big);

    var parser = pitch.PitchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .execute);
    try std.testing.expectEqual(@as(u32, 500), msg.execute.executed_shares);
    try std.testing.expectEqual(@as(u64, 123456789012345), msg.execute.execution_id);
}

test "PITCH ExecuteAtPrice message" {
    // Order Execute at Price (0x24): 37 bytes
    // [0]=0x24, [1..4] ts, [5..12] order_id, [13..16] executed_shares,
    // [17..20] remaining_shares, [21..28] execution_id, [29..36] price
    var buf = [_]u8{0} ** 37;
    buf[0] = 0x24;
    std.mem.writeInt(u32, buf[1..5], 12345, .big);
    std.mem.writeInt(u64, buf[5..13], 55555, .big);
    std.mem.writeInt(u32, buf[13..17], 300, .big);
    std.mem.writeInt(u32, buf[17..21], 200, .big);
    std.mem.writeInt(u64, buf[21..29], 99998877, .big);
    std.mem.writeInt(u64, buf[29..37], 4500000, .big);

    var parser = pitch.PitchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .execute_at_price);
    try std.testing.expectEqual(@as(u32, 300), msg.execute_at_price.executed_shares);
    try std.testing.expectEqual(@as(u32, 200), msg.execute_at_price.remaining_shares);
    try std.testing.expectEqual(@as(u64, 4500000), msg.execute_at_price.price);
}

test "PITCH Cancel message" {
    // Order Cancel (0x27): 17 bytes
    // [0]=0x27, [1..4] ts, [5..12] order_id, [13..16] canceled_shares
    var buf = [_]u8{0} ** 17;
    buf[0] = 0x27;
    std.mem.writeInt(u32, buf[1..5], 77777, .big);
    std.mem.writeInt(u64, buf[5..13], 44444, .big);
    std.mem.writeInt(u32, buf[13..17], 150, .big);

    var parser = pitch.PitchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .cancel);
    try std.testing.expectEqual(@as(u32, 150), msg.cancel.canceled_shares);
    try std.testing.expectEqual(@as(u64, 44444), msg.cancel.order_id);
}

test "PITCH TradeLong message" {
    // Trade Long (0x2A): 40 bytes
    // [0]=0x2A, [1..4] ts, [5..12] order_id, [13] side, [14..17] shares,
    // [18..23] symbol(6), [24..31] price(u64), [32..39] execution_id
    var buf = [_]u8{0} ** 40;
    buf[0] = 0x2A;
    std.mem.writeInt(u32, buf[1..5], 33333, .big);
    std.mem.writeInt(u64, buf[5..13], 66666, .big);
    buf[13] = 'B';
    std.mem.writeInt(u32, buf[14..18], 750, .big);
    const sym = makeSymbol6("AMZN");
    @memcpy(buf[18..24], &sym);
    std.mem.writeInt(u64, buf[24..32], 1200000, .big);
    std.mem.writeInt(u64, buf[32..40], 99887766, .big);

    var parser = pitch.PitchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .trade_long);
    const tl = msg.trade_long;
    try std.testing.expectEqual(@as(u32, 750), tl.shares);
    try std.testing.expectEqualSlices(u8, &sym, &tl.symbol);
    try std.testing.expectEqual(@as(u64, 1200000), tl.price);
    try std.testing.expectEqual(@as(u64, 99887766), tl.execution_id);
}

test "PITCH TradeShort message" {
    // Trade Short (0x2B): 32 bytes
    // [0]=0x2B, [1..4] ts, [5..12] order_id, [13] side, [14..15] shares(u16),
    // [16..21] symbol(6), [22..23] price(u16), [24..31] execution_id
    var buf = [_]u8{0} ** 32;
    buf[0] = 0x2B;
    std.mem.writeInt(u32, buf[1..5], 11111, .big);
    std.mem.writeInt(u64, buf[5..13], 22222, .big);
    buf[13] = 'S';
    std.mem.writeInt(u16, buf[14..16], 400, .big);
    const sym = makeSymbol6("GOOG");
    @memcpy(buf[16..22], &sym);
    std.mem.writeInt(u16, buf[22..24], 1450, .big); // $14.50 in 1/100
    std.mem.writeInt(u64, buf[24..32], 55443322, .big);

    var parser = pitch.PitchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .trade_short);
    const ts = msg.trade_short;
    try std.testing.expectEqual(@as(u16, 400), ts.shares);
    try std.testing.expectEqual(@as(u16, 1450), ts.price);
    try std.testing.expectEqual(@as(u64, 55443322), ts.execution_id);
}

test "PITCH unknown message type returns error" {
    const buf = [_]u8{0xFF} ++ [_]u8{0} ** 10;
    var parser = pitch.PitchParser.init();
    const result = parser.parse(&buf);
    try std.testing.expectError(pitch.PitchError.UnknownMessageType, result);
}

test "PITCH buffer too short returns error" {
    const buf = [_]u8{0x21}; // AddOrderLong needs 34 bytes
    var parser = pitch.PitchParser.init();
    const result = parser.parse(&buf);
    try std.testing.expectError(pitch.PitchError.BufferTooShort, result);
}

test "PITCH message length validation: cancel buffer edge case" {
    // Exactly minimum size for Cancel (17 bytes) → should succeed
    var buf = [_]u8{0} ** 17;
    buf[0] = 0x27;
    var parser = pitch.PitchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .cancel);
}
