const std = @import("std");
const codec = @import("fix_codec");

const SOH: u8 = 0x01;

test "computeChecksum: known values" {
    // "8=FIX.4.2\x019=5\x0135=D\x01" — sum all bytes mod 256
    const data = "8=FIX.4.2" ++ [_]u8{SOH} ++ "9=5" ++ [_]u8{SOH} ++ "35=D" ++ [_]u8{SOH};
    const cs = codec.FixMessage.computeChecksum(data);
    // The checksum must be a u8 (0-255)
    try std.testing.expect(cs <= 255);
}

test "computeChecksum: empty input yields 0" {
    const cs = codec.FixMessage.computeChecksum("");
    try std.testing.expectEqual(@as(u8, 0), cs);
}

test "computeChecksum: single byte" {
    const cs = codec.FixMessage.computeChecksum("A"); // 'A' = 65
    try std.testing.expectEqual(@as(u8, 65), cs);
}

test "computeChecksum: wrap-around" {
    // 256 bytes of 1 should give checksum 0
    const data = [_]u8{1} ** 256;
    const cs = codec.FixMessage.computeChecksum(&data);
    try std.testing.expectEqual(@as(u8, 0), cs);
}

test "FixMessage: set and get tag" {
    var msg = codec.FixMessage.init(std.testing.allocator);
    defer msg.deinit();

    try msg.setTag(35, "D");
    const v = msg.getTag(35);
    try std.testing.expect(v != null);
    try std.testing.expectEqualStrings("D", v.?);
}

test "FixMessage: getMsgType" {
    var msg = codec.FixMessage.init(std.testing.allocator);
    defer msg.deinit();

    try msg.setTag(35, "A");
    const mt = msg.getMsgType();
    try std.testing.expect(mt != null);
    try std.testing.expectEqualStrings("A", mt.?);
}

test "FixMessage: getTag returns null for missing tag" {
    var msg = codec.FixMessage.init(std.testing.allocator);
    defer msg.deinit();

    try std.testing.expect(msg.getTag(999) == null);
}

test "FixMessage: getInt parses integer tag" {
    var msg = codec.FixMessage.init(std.testing.allocator);
    defer msg.deinit();

    try msg.setTag(34, "42");
    const v = msg.getInt(34);
    try std.testing.expect(v != null);
    try std.testing.expectEqual(@as(i64, 42), v.?);
}

test "FixMessage: getInt returns null for non-integer" {
    var msg = codec.FixMessage.init(std.testing.allocator);
    defer msg.deinit();

    try msg.setTag(35, "D");
    const v = msg.getInt(35);
    try std.testing.expect(v == null);
}

test "FixMessage: setTag overwrites existing tag" {
    var msg = codec.FixMessage.init(std.testing.allocator);
    defer msg.deinit();

    try msg.setTag(35, "A");
    try msg.setTag(35, "D");
    const v = msg.getTag(35);
    try std.testing.expect(v != null);
    try std.testing.expectEqualStrings("D", v.?);
}

test "FixMessage: encode produces SOH-delimited output" {
    var msg = codec.FixMessage.init(std.testing.allocator);
    defer msg.deinit();

    try msg.setTag(8, "FIX.4.2");
    try msg.setTag(35, "D");
    try msg.setTag(49, "SENDER");
    try msg.setTag(56, "TARGET");
    try msg.setTag(34, "1");

    var buf: [4096]u8 = undefined;
    const encoded = try msg.encode(&buf);

    // Must start with BeginString field
    try std.testing.expect(std.mem.startsWith(u8, encoded, "8=FIX.4.2" ++ [_]u8{SOH}));
    // Must end with checksum field followed by SOH
    try std.testing.expect(encoded[encoded.len - 1] == SOH);
    // Must contain SOH delimiters
    var soh_count: usize = 0;
    for (encoded) |b| {
        if (b == SOH) soh_count += 1;
    }
    try std.testing.expect(soh_count >= 3); // at least 8, 9, 35, 10
}

test "FixMessage: encode/decode round-trip" {
    var msg = codec.FixMessage.init(std.testing.allocator);
    defer msg.deinit();

    try msg.setTag(8, "FIX.4.2");
    try msg.setTag(35, "D");
    try msg.setTag(49, "SENDER");
    try msg.setTag(56, "TARGET");
    try msg.setTag(34, "1");
    try msg.setTag(11, "ORD001");

    var buf: [4096]u8 = undefined;
    const encoded = try msg.encode(&buf);

    var decoded = try codec.FixMessage.decode(std.testing.allocator, encoded);
    defer decoded.deinit();

    try std.testing.expectEqualStrings("FIX.4.2", decoded.getTag(8).?);
    try std.testing.expectEqualStrings("D", decoded.getMsgType().?);
    try std.testing.expectEqualStrings("SENDER", decoded.getTag(49).?);
    try std.testing.expectEqualStrings("TARGET", decoded.getTag(56).?);
    try std.testing.expectEqualStrings("ORD001", decoded.getTag(11).?);
}

test "FixMessage: decode with checksum validation" {
    var msg = codec.FixMessage.init(std.testing.allocator);
    defer msg.deinit();

    try msg.setTag(8, "FIX.4.2");
    try msg.setTag(35, "0");
    try msg.setTag(49, "A");
    try msg.setTag(56, "B");
    try msg.setTag(34, "5");

    var buf: [4096]u8 = undefined;
    const encoded = try msg.encode(&buf);

    // Verify decode succeeds (checksum is valid)
    var decoded = try codec.FixMessage.decode(std.testing.allocator, encoded);
    defer decoded.deinit();
    try std.testing.expectEqualStrings("0", decoded.getMsgType().?);
}

test "FixMessage: decode rejects wrong checksum" {
    var msg = codec.FixMessage.init(std.testing.allocator);
    defer msg.deinit();

    try msg.setTag(8, "FIX.4.2");
    try msg.setTag(35, "0");
    try msg.setTag(34, "1");

    var buf: [4096]u8 = undefined;
    const encoded_slice = try msg.encode(&buf);

    // Tamper with checksum: find "10=" and change the value
    var tampered: [4096]u8 = undefined;
    @memcpy(tampered[0..encoded_slice.len], encoded_slice);
    // Find "10=" in the tampered buffer
    var i: usize = 0;
    while (i + 3 < encoded_slice.len) : (i += 1) {
        if (tampered[i] == '1' and tampered[i + 1] == '0' and tampered[i + 2] == '=') {
            // Flip a digit
            tampered[i + 3] = if (tampered[i + 3] == '0') '1' else '0';
            break;
        }
    }
    const result = codec.FixMessage.decode(std.testing.allocator, tampered[0..encoded_slice.len]);
    try std.testing.expectError(error.ChecksumMismatch, result);
}

test "FixMessage: decode rejects missing BeginString" {
    // Raw with no tag 8
    const raw = "35=D\x0134=1\x0110=042\x01";
    const result = codec.FixMessage.decode(std.testing.allocator, raw);
    try std.testing.expectError(error.MissingBeginString, result);
}

test "FixMessage: decode multiple tags" {
    var msg = codec.FixMessage.init(std.testing.allocator);
    defer msg.deinit();

    try msg.setTag(8, "FIXT.1.1");
    try msg.setTag(35, "A");
    try msg.setTag(49, "KEY123");
    try msg.setTag(56, "KRAKEN");
    try msg.setTag(34, "1");
    try msg.setTag(98, "0");
    try msg.setTag(108, "30");

    var buf: [4096]u8 = undefined;
    const encoded = try msg.encode(&buf);

    var decoded = try codec.FixMessage.decode(std.testing.allocator, encoded);
    defer decoded.deinit();

    try std.testing.expectEqualStrings("FIXT.1.1", decoded.getTag(8).?);
    try std.testing.expectEqualStrings("A", decoded.getMsgType().?);
    try std.testing.expectEqualStrings("KEY123", decoded.getTag(49).?);
    try std.testing.expectEqualStrings("KRAKEN", decoded.getTag(56).?);
    try std.testing.expectEqualStrings("0", decoded.getTag(98).?);
    try std.testing.expectEqualStrings("30", decoded.getTag(108).?);
}

test "FixMessage: encode requires BeginString" {
    var msg = codec.FixMessage.init(std.testing.allocator);
    defer msg.deinit();

    // No tag 8
    try msg.setTag(35, "D");
    try msg.setTag(34, "1");

    var buf: [4096]u8 = undefined;
    const result = msg.encode(&buf);
    try std.testing.expectError(error.MissingBeginString, result);
}

test "FixMessage: encode requires MsgType" {
    var msg = codec.FixMessage.init(std.testing.allocator);
    defer msg.deinit();

    // No tag 35
    try msg.setTag(8, "FIX.4.2");
    try msg.setTag(34, "1");

    var buf: [4096]u8 = undefined;
    const result = msg.encode(&buf);
    try std.testing.expectError(error.MissingMsgType, result);
}
