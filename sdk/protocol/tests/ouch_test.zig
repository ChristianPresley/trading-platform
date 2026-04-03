const std = @import("std");
const ouch = @import("ouch");

fn makeToken(s: []const u8) [14]u8 {
    var token = [_]u8{' '} ** 14;
    const len = @min(s.len, 14);
    @memcpy(token[0..len], s[0..len]);
    return token;
}

fn makeSymbol(s: []const u8) [8]u8 {
    var sym = [_]u8{' '} ** 8;
    const len = @min(s.len, 8);
    @memcpy(sym[0..len], s[0..len]);
    return sym;
}

fn makeFirm(s: []const u8) [4]u8 {
    var firm = [_]u8{' '} ** 4;
    const len = @min(s.len, 4);
    @memcpy(firm[0..len], s[0..len]);
    return firm;
}

test "OUCH encode EnterOrder type byte" {
    const order = ouch.EnterOrder{
        .token = makeToken("ORDER001      "),
        .side = 'B',
        .shares = 100,
        .symbol = makeSymbol("AAPL"),
        .price = 1500000,
        .tif = 99999,
        .firm = makeFirm("TEST"),
    };
    var buf = [_]u8{0} ** ouch.ENTER_ORDER_SIZE;
    const encoded = try ouch.OuchEncoder.encodeEnterOrder(order, &buf);
    try std.testing.expectEqual(@as(u8, 'O'), encoded[0]);
    try std.testing.expectEqual(ouch.ENTER_ORDER_SIZE, encoded.len);
}

test "OUCH encode EnterOrder binary layout" {
    const token = makeToken("MYORDER1234567");
    const symbol = makeSymbol("TSLA");
    const firm = makeFirm("GSCO");
    const order = ouch.EnterOrder{
        .token = token,
        .side = 'S',
        .shares = 500,
        .symbol = symbol,
        .price = 2500000,
        .tif = 99998, // IOC
        .firm = firm,
    };
    var buf = [_]u8{0} ** ouch.ENTER_ORDER_SIZE;
    const encoded = try ouch.OuchEncoder.encodeEnterOrder(order, &buf);

    // Verify type byte
    try std.testing.expectEqual(@as(u8, 'O'), encoded[0]);
    // Verify token at [1..14]
    try std.testing.expectEqualSlices(u8, &token, encoded[1..15]);
    // Verify side at [15]
    try std.testing.expectEqual(@as(u8, 'S'), encoded[15]);
    // Verify shares at [16..19] big-endian = 500 = 0x000001F4
    try std.testing.expectEqual(@as(u8, 0x00), encoded[16]);
    try std.testing.expectEqual(@as(u8, 0x00), encoded[17]);
    try std.testing.expectEqual(@as(u8, 0x01), encoded[18]);
    try std.testing.expectEqual(@as(u8, 0xF4), encoded[19]);
    // Verify symbol at [20..27]
    try std.testing.expectEqualSlices(u8, &symbol, encoded[20..28]);
    // Verify price at [28..31] big-endian: 2500000 = 0x00262140
    const price_be = std.mem.readInt(u32, encoded[28..32], .big);
    try std.testing.expectEqual(@as(u32, 2500000), price_be);
    // Verify tif at [32..35] big-endian: 99998
    const tif_be = std.mem.readInt(u32, encoded[32..36], .big);
    try std.testing.expectEqual(@as(u32, 99998), tif_be);
    // Verify firm at [36..39]
    try std.testing.expectEqualSlices(u8, &firm, encoded[36..40]);
}

test "OUCH encode ReplaceOrder" {
    const existing = makeToken("EXISTING123456");
    const replacement = makeToken("REPLACED123456");
    const replace = ouch.ReplaceOrder{
        .existing_token = existing,
        .replacement_token = replacement,
        .shares = 200,
        .price = 1800000,
        .tif = 99999,
    };
    var buf = [_]u8{0} ** ouch.REPLACE_ORDER_SIZE;
    const encoded = try ouch.OuchEncoder.encodeReplaceOrder(replace, &buf);

    try std.testing.expectEqual(@as(u8, 'U'), encoded[0]);
    try std.testing.expectEqual(ouch.REPLACE_ORDER_SIZE, encoded.len);
    try std.testing.expectEqualSlices(u8, &existing, encoded[1..15]);
    try std.testing.expectEqualSlices(u8, &replacement, encoded[15..29]);
    const shares_be = std.mem.readInt(u32, encoded[29..33], .big);
    try std.testing.expectEqual(@as(u32, 200), shares_be);
    const price_be = std.mem.readInt(u32, encoded[33..37], .big);
    try std.testing.expectEqual(@as(u32, 1800000), price_be);
}

test "OUCH encode CancelOrder" {
    const token = makeToken("CANCEL1234    ");
    var buf = [_]u8{0} ** ouch.CANCEL_ORDER_SIZE;
    const encoded = try ouch.OuchEncoder.encodeCancelOrder(token, &buf);

    try std.testing.expectEqual(@as(u8, 'X'), encoded[0]);
    try std.testing.expectEqual(ouch.CANCEL_ORDER_SIZE, encoded.len);
    try std.testing.expectEqualSlices(u8, &token, encoded[1..15]);
}

test "OUCH decode Accepted message" {
    // Build Accepted response (48 bytes):
    // [0]='A', [1..14] token, [15] side, [16..19] shares, [20..27] symbol,
    // [28..31] price, [32..35] tif, [36..39] firm, [40..47] order_ref
    var buf = [_]u8{0} ** 48;
    buf[0] = 'A';
    const token = makeToken("MYORDER001    ");
    @memcpy(buf[1..15], &token);
    buf[15] = 'B';
    std.mem.writeInt(u32, buf[16..20], 100, .big);
    const symbol = makeSymbol("AAPL");
    @memcpy(buf[20..28], &symbol);
    std.mem.writeInt(u32, buf[28..32], 1500000, .big);
    std.mem.writeInt(u32, buf[32..36], 99999, .big);
    const firm = makeFirm("TEST");
    @memcpy(buf[36..40], &firm);
    std.mem.writeInt(u64, buf[40..48], 987654321, .big);

    const msg = try ouch.OuchDecoder.decode(&buf);
    try std.testing.expect(msg == .accepted);
    const acc = msg.accepted;
    try std.testing.expectEqualSlices(u8, &token, &acc.token);
    try std.testing.expectEqual(@as(u8, 'B'), acc.side);
    try std.testing.expectEqual(@as(u32, 100), acc.shares);
    try std.testing.expectEqualSlices(u8, &symbol, &acc.symbol);
    try std.testing.expectEqual(@as(u32, 1500000), acc.price);
    try std.testing.expectEqual(@as(u64, 987654321), acc.order_reference_number);
}

test "OUCH decode Canceled message" {
    // [0]='C', [1..14] token, [15..18] shares, [19] reason
    var buf = [_]u8{0} ** 20;
    buf[0] = 'C';
    const token = makeToken("CANCEL001     ");
    @memcpy(buf[1..15], &token);
    std.mem.writeInt(u32, buf[15..19], 75, .big);
    buf[19] = 'D'; // reason = Duplicate

    const msg = try ouch.OuchDecoder.decode(&buf);
    try std.testing.expect(msg == .canceled);
    try std.testing.expectEqual(@as(u32, 75), msg.canceled.shares);
    try std.testing.expectEqual(@as(u8, 'D'), msg.canceled.reason);
}

test "OUCH decode Executed message" {
    // [0]='E', [1..14] token, [15..18] executed_shares, [19..22] execution_price,
    // [23] liquidity_flag, [24..31] match_number
    var buf = [_]u8{0} ** 32;
    buf[0] = 'E';
    const token = makeToken("EXEC001       ");
    @memcpy(buf[1..15], &token);
    std.mem.writeInt(u32, buf[15..19], 100, .big);
    std.mem.writeInt(u32, buf[19..23], 1500000, .big);
    buf[23] = 'A'; // liquidity added
    std.mem.writeInt(u64, buf[24..32], 111222333, .big);

    const msg = try ouch.OuchDecoder.decode(&buf);
    try std.testing.expect(msg == .executed);
    const ex = msg.executed;
    try std.testing.expectEqual(@as(u32, 100), ex.executed_shares);
    try std.testing.expectEqual(@as(u32, 1500000), ex.execution_price);
    try std.testing.expectEqual(@as(u8, 'A'), ex.liquidity_flag);
    try std.testing.expectEqual(@as(u64, 111222333), ex.match_number);
}

test "OUCH decode Rejected message" {
    // [0]='J', [1..14] token, [15] reason
    var buf = [_]u8{0} ** 16;
    buf[0] = 'J';
    const token = makeToken("REJECT001     ");
    @memcpy(buf[1..15], &token);
    buf[15] = 'Q'; // reason = Quote unavailable

    const msg = try ouch.OuchDecoder.decode(&buf);
    try std.testing.expect(msg == .rejected);
    try std.testing.expectEqual(@as(u8, 'Q'), msg.rejected.reason);
}

test "OUCH decode unknown message type returns error" {
    const buf = [_]u8{'Z'} ++ [_]u8{0} ** 20;
    const result = ouch.OuchDecoder.decode(&buf);
    try std.testing.expectError(ouch.OuchError.UnknownMessageType, result);
}

test "OUCH encode buffer too short returns error" {
    const order = ouch.EnterOrder{
        .token = makeToken("X"),
        .side = 'B',
        .shares = 1,
        .symbol = makeSymbol("A"),
        .price = 1,
        .tif = 1,
        .firm = makeFirm("A"),
    };
    var small_buf = [_]u8{0} ** 5; // too small
    const result = ouch.OuchEncoder.encodeEnterOrder(order, &small_buf);
    try std.testing.expectError(ouch.OuchError.BufferTooShort, result);
}

test "OUCH token is exactly 14 bytes" {
    // Verify layout constant
    try std.testing.expectEqual(@as(usize, 40), ouch.ENTER_ORDER_SIZE);
    try std.testing.expectEqual(@as(usize, 41), ouch.REPLACE_ORDER_SIZE);
    try std.testing.expectEqual(@as(usize, 15), ouch.CANCEL_ORDER_SIZE);
}

test "OUCH encode-decode round trip EnterOrder token preserved" {
    const token = makeToken("ROUNDTRIP12345");
    const order = ouch.EnterOrder{
        .token = token,
        .side = 'B',
        .shares = 1000,
        .symbol = makeSymbol("NVDA"),
        .price = 5000000,
        .tif = 99999,
        .firm = makeFirm("FIRM"),
    };

    var enc_buf = [_]u8{0} ** ouch.ENTER_ORDER_SIZE;
    const encoded = try ouch.OuchEncoder.encodeEnterOrder(order, &enc_buf);
    // Token at [1..15]
    try std.testing.expectEqualSlices(u8, &token, encoded[1..15]);

    // Now simulate server response Accepted with same token
    var resp_buf = [_]u8{0} ** 48;
    resp_buf[0] = 'A';
    @memcpy(resp_buf[1..15], &token);
    resp_buf[15] = 'B';
    std.mem.writeInt(u32, resp_buf[16..20], 1000, .big);
    @memcpy(resp_buf[20..28], &makeSymbol("NVDA"));
    std.mem.writeInt(u32, resp_buf[28..32], 5000000, .big);
    std.mem.writeInt(u32, resp_buf[32..36], 99999, .big);
    @memcpy(resp_buf[36..40], &makeFirm("FIRM"));
    std.mem.writeInt(u64, resp_buf[40..48], 42, .big);

    const resp = try ouch.OuchDecoder.decode(&resp_buf);
    try std.testing.expect(resp == .accepted);
    try std.testing.expectEqualSlices(u8, &token, &resp.accepted.token);
}
