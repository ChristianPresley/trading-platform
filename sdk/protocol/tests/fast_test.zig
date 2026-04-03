const std = @import("std");
const fast = @import("fast");

test "FAST stop-bit decode single byte" {
    // Single byte with stop bit set: 0x81 = value 1 (7 bits = 0000001, stop bit set)
    const data = [_]u8{0x81};
    const result = try fast.decodeStopBit(&data);
    try std.testing.expectEqual(@as(u64, 1), result.value);
    try std.testing.expectEqual(@as(usize, 1), result.bytes_consumed);
}

test "FAST stop-bit decode zero" {
    // 0x80 = value 0 with stop bit
    const data = [_]u8{0x80};
    const result = try fast.decodeStopBit(&data);
    try std.testing.expectEqual(@as(u64, 0), result.value);
    try std.testing.expectEqual(@as(usize, 1), result.bytes_consumed);
}

test "FAST stop-bit decode two bytes" {
    // Two bytes: 0x01 (no stop, bits = 0000001), 0x80 (stop, bits = 0000000)
    // value = (1 << 7) | 0 = 128
    const data = [_]u8{ 0x01, 0x80 };
    const result = try fast.decodeStopBit(&data);
    try std.testing.expectEqual(@as(u64, 128), result.value);
    try std.testing.expectEqual(@as(usize, 2), result.bytes_consumed);
}

test "FAST stop-bit decode large value" {
    // Encode 0x3FFF (16383) in two 7-bit chunks:
    // 16383 = 0b11_1111_1111_1111
    // chunk0 = 0b111_1111 = 0x7F (no stop)
    // chunk1 = 0b111_1111 | 0x80 = 0xFF (stop)
    const data = [_]u8{ 0x7F, 0xFF };
    const result = try fast.decodeStopBit(&data);
    try std.testing.expectEqual(@as(u64, 16383), result.value);
    try std.testing.expectEqual(@as(usize, 2), result.bytes_consumed);
}

test "FAST stop-bit decode max 1-byte (127)" {
    // 0xFF = 0b1111_1111 → stop bit set, value = 0b111_1111 = 127
    const data = [_]u8{0xFF};
    const result = try fast.decodeStopBit(&data);
    try std.testing.expectEqual(@as(u64, 127), result.value);
    try std.testing.expectEqual(@as(usize, 1), result.bytes_consumed);
}

test "FAST stop-bit decode missing stop bit returns error" {
    // No stop bit in any byte → error
    const data = [_]u8{ 0x01, 0x02, 0x03 }; // none have MSB set
    const result = fast.decodeStopBit(&data);
    try std.testing.expectError(fast.FastError.InvalidStopBit, result);
}

test "FAST stop-bit buffer empty returns error" {
    const data = [_]u8{};
    const result = fast.decodeStopBit(&data);
    try std.testing.expectError(fast.FastError.BufferTooShort, result);
}

test "FAST presence map single byte (stop bit set)" {
    // PMAP byte 0x82 = 0b1000_0010 → stop bit set, 7 pmap bits = 0b000_0010
    // bit 0 (MSB of 7 bits) = 0, bit 1 = 0, bit 2 = 0, bit 3 = 0, bit 4 = 0, bit 5 = 1, bit 6 = 0
    const data = [_]u8{0x82};
    const pmap = try fast.decodePmap(&data);
    // bits = 0b0000010 = 2, bit_count = 7
    // isSet(5) → bit at position 5 from MSB in 7-bit field
    // MSB first: bit 0 = (bits >> 6) & 1, bit 5 = (bits >> 1) & 1
    try std.testing.expectEqual(true, pmap.isSet(5));
    try std.testing.expectEqual(false, pmap.isSet(0));
    try std.testing.expectEqual(false, pmap.isSet(6));
}

test "FAST presence map all bits set" {
    // 0xFF = stop bit + all 7 pmap bits set
    const data = [_]u8{0xFF};
    const pmap = try fast.decodePmap(&data);
    // All 7 bits are 1
    var i: u6 = 0;
    while (i < 7) : (i += 1) {
        try std.testing.expectEqual(true, pmap.isSet(i));
    }
}

test "FAST presence map two bytes" {
    // byte0 = 0x02 (no stop, 7 bits = 0000010), byte1 = 0xFE (stop, 7 bits = 1111110)
    // total bits = 0b0000010_1111110 (14 bits)
    const data = [_]u8{ 0x02, 0xFE };
    const pmap = try fast.decodePmap(&data);
    // bit_count = 14
    // The first 7 bits: 0000010, next 7: 1111110
    // From MSB: bit0=0,1=0,2=0,3=0,4=0,5=1,6=0, bit7=1,8=1,9=1,10=1,11=1,12=1,13=0
    try std.testing.expectEqual(false, pmap.isSet(0));
    try std.testing.expectEqual(true, pmap.isSet(5));
    try std.testing.expectEqual(true, pmap.isSet(7));
    try std.testing.expectEqual(true, pmap.isSet(12));
    try std.testing.expectEqual(false, pmap.isSet(13));
}

test "FAST decoder copy operator (field present)" {
    var decoder = fast.FastDecoder.init();

    // Template: one field with copy operator
    const template = [_]fast.FastFieldDef{
        .{ .name = "Price", .operator = .copy, .is_optional = false, .initial_value = 0 },
    };

    // PMAP: bit 0 set (field present in stream) → pmap byte 0xC0 (stop=1, bit0=1, rest=0)
    // ... but we decode pmap separately and pass it in
    // Encode value 42 as stop-bit: 0xAA = 0b10101010 → stop bit set, value = 0b010_1010 = 42
    const data = [_]u8{0xAA};
    var pmap_data = [_]u8{0xC0}; // stop bit set, bit0=1
    const pmap = try fast.decodePmap(&pmap_data);

    var out: [4]fast.FastFieldValue = undefined;
    const count = try decoder.decode(&data, pmap, &template, &out);
    try std.testing.expectEqual(@as(usize, 1), count);
    try std.testing.expectEqual(@as(u64, 42), out[0].unsigned);
}

test "FAST decoder copy operator (field absent, uses previous)" {
    var decoder = fast.FastDecoder.init();
    // Manually set prev value
    decoder.prev_values[0] = 999;

    const template = [_]fast.FastFieldDef{
        .{ .name = "Price", .operator = .copy, .is_optional = false, .initial_value = 0 },
    };

    // PMAP: bit 0 NOT set (field absent)
    var pmap_data = [_]u8{0x80}; // stop bit, all pmap bits = 0
    const pmap = try fast.decodePmap(&pmap_data);

    const data = [_]u8{}; // no bytes needed since field is absent
    var out: [4]fast.FastFieldValue = undefined;
    const count = try decoder.decode(&data, pmap, &template, &out);
    try std.testing.expectEqual(@as(usize, 1), count);
    try std.testing.expectEqual(@as(u64, 999), out[0].unsigned); // previous value
}

test "FAST decoder increment operator (field absent, increments previous)" {
    var decoder = fast.FastDecoder.init();
    decoder.prev_values[0] = 100;

    const template = [_]fast.FastFieldDef{
        .{ .name = "SeqNum", .operator = .increment, .is_optional = false, .initial_value = 0 },
    };

    var pmap_data = [_]u8{0x80}; // bit 0 not set
    const pmap = try fast.decodePmap(&pmap_data);

    const data = [_]u8{};
    var out: [4]fast.FastFieldValue = undefined;
    _ = try decoder.decode(&data, pmap, &template, &out);
    try std.testing.expectEqual(@as(u64, 101), out[0].unsigned); // incremented
}

test "FAST decoder delta operator" {
    var decoder = fast.FastDecoder.init();
    decoder.prev_values[0] = @bitCast(@as(i64, 1000));

    const template = [_]fast.FastFieldDef{
        .{ .name = "Price", .operator = .delta, .is_optional = false, .initial_value = 0 },
    };

    // bit 0 set → field is present with delta value
    var pmap_data = [_]u8{0xC0};
    const pmap = try fast.decodePmap(&pmap_data);

    // Encode delta = +5 as signed stop-bit: 0x85 = 0b10000101 → stop bit, value bits = 0000101 = 5
    const data = [_]u8{0x85};
    var out: [4]fast.FastFieldValue = undefined;
    _ = try decoder.decode(&data, pmap, &template, &out);
    try std.testing.expectEqual(@as(u64, 1005), out[0].unsigned); // 1000 + 5
}

test "FAST decoder constant operator" {
    var decoder = fast.FastDecoder.init();

    const template = [_]fast.FastFieldDef{
        .{ .name = "Constant", .operator = .constant, .is_optional = false, .initial_value = 42 },
    };

    var pmap_data = [_]u8{0x80};
    const pmap = try fast.decodePmap(&pmap_data);

    const data = [_]u8{};
    var out: [4]fast.FastFieldValue = undefined;
    _ = try decoder.decode(&data, pmap, &template, &out);
    try std.testing.expectEqual(@as(u64, 42), out[0].unsigned);
}

test "FAST decoder default operator (absent uses initial)" {
    var decoder = fast.FastDecoder.init();

    const template = [_]fast.FastFieldDef{
        .{ .name = "Side", .operator = .default, .is_optional = true, .initial_value = 'B' },
    };

    var pmap_data = [_]u8{0x80}; // bit 0 not set → use default
    const pmap = try fast.decodePmap(&pmap_data);

    const data = [_]u8{};
    var out: [4]fast.FastFieldValue = undefined;
    _ = try decoder.decode(&data, pmap, &template, &out);
    try std.testing.expectEqual(@as(u64, 'B'), out[0].unsigned);
}
