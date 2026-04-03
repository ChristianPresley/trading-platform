const std = @import("std");
const sbe = @import("sbe");

// Helper: build a minimal SBE header + body
// Header: block_length(u16 LE) + template_id(u16 LE) + schema_id(u16 LE) + version(u16 LE)
fn buildSbeMessage(block_length: u16, template_id: u16, body: []const u8, buf: []u8) []u8 {
    std.mem.writeInt(u16, buf[0..2], block_length, .little);
    std.mem.writeInt(u16, buf[2..4], template_id, .little);
    std.mem.writeInt(u16, buf[4..6], 1, .little); // schema_id
    std.mem.writeInt(u16, buf[6..8], 1, .little); // version
    @memcpy(buf[8..8 + body.len], body);
    return buf[0..8 + body.len];
}

test "SBE decode MDIncrementalRefreshTrade (template 1)" {
    // Template 1 layout requires 38 bytes of body:
    //   TransactTime(u64)=8, MatchEventIndicator(u8)=1, SecurityID(i32)=4,
    //   RptSeq(u32)=4, MDEntryPx(decimal=9), MDEntrySize(i32)=4,
    //   NumberOfOrders(i32)=4, TradingReferenceDate(u16)=2,
    //   AggressorSide(u8)=1, MDUpdateAction(u8)=1  => total 38 bytes

    var body_buf = [_]u8{0} ** 38;

    // TransactTime at offset 0: 1000000000 (little-endian u64)
    std.mem.writeInt(u64, body_buf[0..8], 1000000000, .little);
    // MatchEventIndicator at offset 8: 0x01
    body_buf[8] = 0x01;
    // SecurityID at offset 9: -1 as i32 LE
    std.mem.writeInt(i32, body_buf[9..13], -1, .little);
    // RptSeq at offset 13: 42
    std.mem.writeInt(u32, body_buf[13..17], 42, .little);
    // MDEntryPx at offset 17: mantissa=150000 (i64 LE), exponent=-4 (i8)
    std.mem.writeInt(i64, body_buf[17..25], 150000, .little);
    body_buf[25] = @bitCast(@as(i8, -4)); // exponent
    // MDEntrySize at offset 26: 100
    std.mem.writeInt(i32, body_buf[26..30], 100, .little);
    // NumberOfOrders at offset 30: 5
    std.mem.writeInt(i32, body_buf[30..34], 5, .little);
    // TradingReferenceDate at offset 34: 12345
    std.mem.writeInt(u16, body_buf[34..36], 12345, .little);
    // AggressorSide at offset 36: 1
    body_buf[36] = 1;
    // MDUpdateAction at offset 37: 0
    body_buf[37] = 0;

    var raw_buf = [_]u8{0} ** 200;
    const data = buildSbeMessage(38, 1, &body_buf, &raw_buf);

    const allocator = std.testing.allocator;
    var decoder = sbe.SbeDecoder.init(allocator);
    const msg = try decoder.decode(data);
    defer decoder.freeMessage(msg);

    try std.testing.expectEqual(@as(u16, 1), msg.template_id);
    try std.testing.expectEqual(@as(usize, 10), msg.fields.len);

    // Check TransactTime
    try std.testing.expectEqualStrings("TransactTime", msg.fields[0].name);
    try std.testing.expectEqual(@as(u64, 1000000000), msg.fields[0].value.uint64);

    // Check SecurityID
    try std.testing.expectEqualStrings("SecurityID", msg.fields[2].name);
    try std.testing.expectEqual(@as(i32, -1), msg.fields[2].value.int32);

    // Check MDEntryPx (decimal)
    try std.testing.expectEqualStrings("MDEntryPx", msg.fields[4].name);
    try std.testing.expectEqual(@as(i64, 150000), msg.fields[4].value.decimal.mantissa);
    try std.testing.expectEqual(@as(i8, -4), msg.fields[4].value.decimal.exponent);

    // Check RptSeq
    try std.testing.expectEqualStrings("RptSeq", msg.fields[3].name);
    try std.testing.expectEqual(@as(u32, 42), msg.fields[3].value.uint32);
}

test "SBE decode MDIncrementalRefreshBook (template 2)" {
    // Template 2 requires 28 bytes of body:
    //   TransactTime(u64)=8, MatchEventIndicator(u8)=1, SecurityID(i32)=4,
    //   MDEntryPx(decimal=9), MDEntrySize(i32)=4, MDEntryType(u8)=1, MDUpdateAction(u8)=1
    //   total = 28 bytes

    var body_buf = [_]u8{0} ** 28;
    std.mem.writeInt(u64, body_buf[0..8], 9999999999, .little);
    body_buf[8] = 0x03;
    std.mem.writeInt(i32, body_buf[9..13], 1234567, .little);
    std.mem.writeInt(i64, body_buf[13..21], 250000, .little);
    body_buf[21] = @bitCast(@as(i8, -4));
    std.mem.writeInt(i32, body_buf[22..26], 50, .little);
    body_buf[26] = '0'; // MDEntryType = bid
    body_buf[27] = 0;   // MDUpdateAction = new

    var raw_buf = [_]u8{0} ** 200;
    const data = buildSbeMessage(28, 2, &body_buf, &raw_buf);

    const allocator = std.testing.allocator;
    var decoder = sbe.SbeDecoder.init(allocator);
    const msg = try decoder.decode(data);
    defer decoder.freeMessage(msg);

    try std.testing.expectEqual(@as(u16, 2), msg.template_id);
    try std.testing.expectEqual(@as(usize, 7), msg.fields.len);

    try std.testing.expectEqual(@as(u64, 9999999999), msg.fields[0].value.uint64);
    try std.testing.expectEqual(@as(i32, 1234567), msg.fields[2].value.int32);
    try std.testing.expectEqual(@as(i64, 250000), msg.fields[3].value.decimal.mantissa);
}

test "SBE unknown template returns error" {
    var raw_buf = [_]u8{0} ** 20;
    // template_id = 999 (unknown)
    std.mem.writeInt(u16, raw_buf[2..4], 999, .little);

    const allocator = std.testing.allocator;
    var decoder = sbe.SbeDecoder.init(allocator);
    const result = decoder.decode(&raw_buf);
    try std.testing.expectError(sbe.SbeError.UnknownTemplateId, result);
}

test "SBE buffer too short for header" {
    var raw_buf = [_]u8{0} ** 4; // need 8 bytes minimum

    const allocator = std.testing.allocator;
    var decoder = sbe.SbeDecoder.init(allocator);
    const result = decoder.decode(&raw_buf);
    try std.testing.expectError(sbe.SbeError.InvalidMessageHeader, result);
}

test "SBE null sentinel uint32 detection" {
    // NULL_U32 = 0xFFFFFFFF — verify constant is accessible
    try std.testing.expectEqual(@as(u32, 0xFFFF_FFFF), sbe.NULL_U32);
    try std.testing.expectEqual(@as(u16, 0xFFFF), sbe.NULL_U16);
    try std.testing.expectEqual(@as(u8, 0xFF), sbe.NULL_U8);
}

test "SBE optional fields: field value can be null sentinel" {
    // Construct a template 1 message where TradingReferenceDate = NULL_U16
    var body_buf = [_]u8{0} ** 38;
    std.mem.writeInt(u64, body_buf[0..8], 500, .little);
    std.mem.writeInt(i64, body_buf[17..25], 0, .little);
    // TradingReferenceDate at offset 34 = NULL_U16
    std.mem.writeInt(u16, body_buf[34..36], sbe.NULL_U16, .little);

    var raw_buf = [_]u8{0} ** 200;
    const data = buildSbeMessage(38, 1, &body_buf, &raw_buf);

    const allocator = std.testing.allocator;
    var decoder = sbe.SbeDecoder.init(allocator);
    const msg = try decoder.decode(data);
    defer decoder.freeMessage(msg);

    // Field index 7 = TradingReferenceDate
    const trd = msg.fields[7];
    try std.testing.expectEqualStrings("TradingReferenceDate", trd.name);
    try std.testing.expectEqual(sbe.NULL_U16, trd.value.uint16);
}
