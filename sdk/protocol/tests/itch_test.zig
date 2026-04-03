const std = @import("std");
const itch = @import("itch");

test "ITCH system event message" {
    // Build System Event 'S' message (12 bytes):
    // [0]='S', [1..2] stock_locate=0, [3..4] tracking=0, [5..10] timestamp, [11] event_code='O'
    var buf: [12]u8 = undefined;
    buf[0] = 'S';
    buf[1] = 0; buf[2] = 0; // stock locate
    buf[3] = 0; buf[4] = 0; // tracking number
    // timestamp = 0x000102030405 (u48, big-endian at [5..10])
    buf[5] = 0x00; buf[6] = 0x01; buf[7] = 0x02;
    buf[8] = 0x03; buf[9] = 0x04; buf[10] = 0x05;
    buf[11] = 'O'; // event_code

    var parser = itch.ItchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .system_event);
    try std.testing.expectEqual(@as(u48, 0x000102030405), msg.system_event.timestamp);
    try std.testing.expectEqual(@as(u8, 'O'), msg.system_event.event_code);
}

test "ITCH add order message" {
    // Add Order 'A' (36 bytes):
    // [0]='A', [1..2] sl, [3..4] tn, [5..10] ts(u48), [11..18] order_ref(u64),
    // [19] side, [20..23] shares(u32), [24..31] stock([8]), [32..35] price(u32)
    var buf = [_]u8{0} ** 36;
    buf[0] = 'A';
    // timestamp at [5..10] = 1000000000 (1s in ns) = 0x3B9ACA00
    buf[5] = 0x00; buf[6] = 0x00; buf[7] = 0x3B;
    buf[8] = 0x9A; buf[9] = 0xCA; buf[10] = 0x00;
    // order_ref at [11..18] = 0x0000000000000042 = 66
    buf[18] = 66;
    // side = 'B'
    buf[19] = 'B';
    // shares at [20..23] = 100
    buf[20] = 0; buf[21] = 0; buf[22] = 0; buf[23] = 100;
    // stock at [24..31] = "AAPL    "
    buf[24] = 'A'; buf[25] = 'A'; buf[26] = 'P'; buf[27] = 'L';
    buf[28] = ' '; buf[29] = ' '; buf[30] = ' '; buf[31] = ' ';
    // price at [32..35] = 1500000 (in 1/10000 = $150.00)
    buf[32] = 0x00; buf[33] = 0x16; buf[34] = 0xE3; buf[35] = 0x60;

    var parser = itch.ItchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .add_order);
    const ao = msg.add_order;
    try std.testing.expectEqual(@as(u48, 0x00003B9ACA00), ao.timestamp);
    try std.testing.expectEqual(@as(u64, 66), ao.order_ref);
    try std.testing.expectEqual(@as(u8, 'B'), ao.side);
    try std.testing.expectEqual(@as(u32, 100), ao.shares);
    try std.testing.expectEqualSlices(u8, "AAPL    ", &ao.stock);
    try std.testing.expectEqual(@as(u32, 0x0016E360), ao.price);
}

test "ITCH add order with MPID" {
    var buf = [_]u8{0} ** 40;
    buf[0] = 'F';
    // timestamp
    buf[5] = 0; buf[6] = 0; buf[7] = 0; buf[8] = 0; buf[9] = 0; buf[10] = 1;
    // order_ref at [11..18] = 999
    buf[17] = 0x03; buf[18] = 0xE7;
    buf[19] = 'S'; // side = sell
    // shares = 200
    buf[22] = 0; buf[23] = 200;
    // stock = "TSLA    "
    buf[24] = 'T'; buf[25] = 'S'; buf[26] = 'L'; buf[27] = 'A';
    buf[28] = ' '; buf[29] = ' '; buf[30] = ' '; buf[31] = ' ';
    // price
    buf[32] = 0; buf[33] = 0; buf[34] = 0x27; buf[35] = 0x10;
    // attribution = "GSCO"
    buf[36] = 'G'; buf[37] = 'S'; buf[38] = 'C'; buf[39] = 'O';

    var parser = itch.ItchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .add_order_mpid);
    try std.testing.expectEqual(@as(u8, 'S'), msg.add_order_mpid.side);
    try std.testing.expectEqualSlices(u8, "GSCO", &msg.add_order_mpid.attribution);
}

test "ITCH order executed message" {
    var buf = [_]u8{0} ** 31;
    buf[0] = 'E';
    // timestamp = 42
    buf[10] = 42;
    // order_ref at [11..18] = 77
    buf[18] = 77;
    // executed_shares at [19..22] = 50
    buf[22] = 50;
    // match_number at [23..30] = 12345
    buf[29] = 0x30; buf[30] = 0x39;

    var parser = itch.ItchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .execute);
    try std.testing.expectEqual(@as(u32, 50), msg.execute.executed_shares);
    try std.testing.expectEqual(@as(u64, 0x3039), msg.execute.match_number);
}

test "ITCH order cancel message" {
    var buf = [_]u8{0} ** 23;
    buf[0] = 'X';
    // order_ref = 88
    buf[18] = 88;
    // canceled_shares = 25
    buf[22] = 25;

    var parser = itch.ItchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .cancel);
    try std.testing.expectEqual(@as(u32, 25), msg.cancel.canceled_shares);
}

test "ITCH order delete message" {
    var buf = [_]u8{0} ** 19;
    buf[0] = 'D';
    buf[18] = 123; // order_ref low byte

    var parser = itch.ItchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .delete);
    try std.testing.expectEqual(@as(u64, 123), msg.delete.order_ref);
}

test "ITCH order replace message" {
    var buf = [_]u8{0} ** 35;
    buf[0] = 'U';
    // orig order ref at [11..18] = 10
    buf[18] = 10;
    // new order ref at [19..26] = 20
    buf[26] = 20;
    // shares at [27..30] = 500
    buf[29] = 0x01; buf[30] = 0xF4;
    // price at [31..34] = 10000
    buf[33] = 0x27; buf[34] = 0x10;

    var parser = itch.ItchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .replace);
    try std.testing.expectEqual(@as(u64, 10), msg.replace.original_order_ref);
    try std.testing.expectEqual(@as(u64, 20), msg.replace.new_order_ref);
    try std.testing.expectEqual(@as(u32, 0x01F4), msg.replace.shares);
    try std.testing.expectEqual(@as(u32, 0x2710), msg.replace.price);
}

test "ITCH broken trade message" {
    var buf = [_]u8{0} ** 19;
    buf[0] = 'B';
    // match_number at [11..18] = 9999
    buf[17] = 0x27; buf[18] = 0x0F;

    var parser = itch.ItchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .broken_trade);
    try std.testing.expectEqual(@as(u64, 0x270F), msg.broken_trade.match_number);
}

test "ITCH unknown message type returns error" {
    var buf = [_]u8{0} ** 10;
    buf[0] = 'Z'; // unknown

    var parser = itch.ItchParser.init();
    const result = parser.parse(&buf);
    try std.testing.expectError(itch.ItchError.UnknownMessageType, result);
}

test "ITCH buffer too short returns error" {
    var buf = [_]u8{'A'};
    var parser = itch.ItchParser.init();
    const result = parser.parse(&buf);
    try std.testing.expectError(itch.ItchError.BufferTooShort, result);
}

test "ITCH timestamp midnight rollover (u48 wraparound)" {
    // u48 max = 0xFFFFFFFFFFFF; after rollover we just get the lower 48 bits
    // This tests that we correctly handle values near max u48
    var buf = [_]u8{0} ** 12;
    buf[0] = 'S';
    // timestamp = max u48
    buf[5] = 0xFF; buf[6] = 0xFF; buf[7] = 0xFF;
    buf[8] = 0xFF; buf[9] = 0xFF; buf[10] = 0xFF;
    buf[11] = 'C';

    var parser = itch.ItchParser.init();
    const msg = try parser.parse(&buf);
    try std.testing.expect(msg == .system_event);
    try std.testing.expectEqual(@as(u48, 0xFFFFFFFFFFFF), msg.system_event.timestamp);
}
