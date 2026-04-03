// Tests for WebSocket frame encoding/decoding per RFC 6455

const std = @import("std");
const frame_mod = @import("frame");

test "encode/decode text frame round-trip" {
    const payload = "Hello, WebSocket!";
    var buf: [256]u8 = undefined;
    const encoded = try frame_mod.encodeFrame(&buf, .text, payload, false);

    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expect(frm.fin);
    try std.testing.expectEqual(frame_mod.Opcode.text, frm.opcode);
    try std.testing.expectEqualSlices(u8, payload, frm.payload);
    try std.testing.expectEqual(@as(?[4]u8, null), frm.mask_key);
}

test "encode/decode binary frame round-trip" {
    const payload = [_]u8{ 0x01, 0x02, 0x03, 0xfe, 0xff };
    var buf: [256]u8 = undefined;
    const encoded = try frame_mod.encodeFrame(&buf, .binary, &payload, false);

    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expect(frm.fin);
    try std.testing.expectEqual(frame_mod.Opcode.binary, frm.opcode);
    try std.testing.expectEqualSlices(u8, &payload, frm.payload);
}

test "encode/decode with masking" {
    const payload = "masked payload";
    var buf: [256]u8 = undefined;
    const mask_key = [4]u8{ 0x12, 0x34, 0x56, 0x78 };
    const encoded = try frame_mod.encodeFrameWithKey(&buf, .text, payload, true, mask_key);

    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expect(frm.fin);
    try std.testing.expectEqual(frame_mod.Opcode.text, frm.opcode);
    try std.testing.expect(frm.mask_key != null);
    try std.testing.expectEqual(mask_key, frm.mask_key.?);

    // Unmask and verify
    var payload_copy: [64]u8 = undefined;
    @memcpy(payload_copy[0..frm.payload.len], frm.payload);
    frame_mod.unmaskPayload(payload_copy[0..frm.payload.len], frm.mask_key.?);
    try std.testing.expectEqualSlices(u8, payload, payload_copy[0..frm.payload.len]);
}

test "ping frame" {
    const payload = "ping!";
    var buf: [64]u8 = undefined;
    const encoded = try frame_mod.encodeFrame(&buf, .ping, payload, false);

    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expectEqual(frame_mod.Opcode.ping, frm.opcode);
    try std.testing.expectEqualSlices(u8, payload, frm.payload);
}

test "pong frame" {
    const payload = "pong!";
    var buf: [64]u8 = undefined;
    const encoded = try frame_mod.encodeFrame(&buf, .pong, payload, false);

    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expectEqual(frame_mod.Opcode.pong, frm.opcode);
    try std.testing.expectEqualSlices(u8, payload, frm.payload);
}

test "close frame" {
    var buf: [16]u8 = undefined;
    const encoded = try frame_mod.encodeFrame(&buf, .close, &.{}, false);

    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expectEqual(frame_mod.Opcode.close, frm.opcode);
    try std.testing.expectEqual(@as(usize, 0), frm.payload.len);
}

test "empty payload frame" {
    var buf: [16]u8 = undefined;
    const encoded = try frame_mod.encodeFrame(&buf, .text, &.{}, false);

    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expectEqual(@as(usize, 0), frm.payload.len);
}

test "16-bit length payload" {
    // Payload larger than 125 bytes requires 16-bit length field
    var payload: [200]u8 = undefined;
    @memset(&payload, 'A');

    var buf: [300]u8 = undefined;
    const encoded = try frame_mod.encodeFrame(&buf, .binary, &payload, false);

    // Verify the 126 extended length indicator
    try std.testing.expectEqual(@as(u8, 126), encoded[1] & 0x7f);

    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expectEqual(@as(usize, 200), frm.payload.len);
    try std.testing.expectEqualSlices(u8, &payload, frm.payload);
}

test "64-bit length payload" {
    // Payload larger than 65535 bytes requires 64-bit length field
    const payload = try std.testing.allocator.alloc(u8, 70000);
    defer std.testing.allocator.free(payload);
    @memset(payload, 'B');

    const buf = try std.testing.allocator.alloc(u8, 70100);
    defer std.testing.allocator.free(buf);

    const encoded = try frame_mod.encodeFrame(buf, .binary, payload, false);

    // Verify the 127 extended length indicator
    try std.testing.expectEqual(@as(u8, 127), encoded[1] & 0x7f);

    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expectEqual(@as(usize, 70000), frm.payload.len);
    try std.testing.expectEqualSlices(u8, payload, frm.payload);
}

test "frameSize matches encoded length" {
    const payload = "size test";
    var buf: [64]u8 = undefined;
    const encoded = try frame_mod.encodeFrame(&buf, .text, payload, false);

    const sz = try frame_mod.frameSize(encoded);
    try std.testing.expectEqual(encoded.len, sz);
}

test "decodeFrame returns error on truncated data" {
    // Only 1 byte — too short
    const data = [_]u8{0x81};
    const result = frame_mod.decodeFrame(&data);
    try std.testing.expectError(error.FrameTooShort, result);
}

test "masking is XOR invertible" {
    const payload = "test masking XOR";
    const mask_key = [4]u8{ 0xAB, 0xCD, 0xEF, 0x01 };

    var buf1: [64]u8 = undefined;
    @memcpy(buf1[0..payload.len], payload);
    frame_mod.unmaskPayload(buf1[0..payload.len], mask_key);

    // XOR again to get back original
    frame_mod.unmaskPayload(buf1[0..payload.len], mask_key);
    try std.testing.expectEqualSlices(u8, payload, buf1[0..payload.len]);
}

test "continuation frame opcode" {
    var buf: [32]u8 = undefined;
    const encoded = try frame_mod.encodeFrame(&buf, .continuation, "frag", false);
    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expectEqual(frame_mod.Opcode.continuation, frm.opcode);
}
