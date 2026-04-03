// WebSocket frame encoding/decoding per RFC 6455

const std = @import("std");

pub const Opcode = enum(u4) {
    continuation = 0,
    text = 1,
    binary = 2,
    close = 8,
    ping = 9,
    pong = 10,
    _,
};

pub const Frame = struct {
    fin: bool,
    opcode: Opcode,
    payload: []const u8,
    mask_key: ?[4]u8,
};

/// Encode a WebSocket frame into buf.
/// Returns the slice of buf that was written.
/// If mask=true, a random mask key is NOT generated here — caller provides mask_key.
/// For client->server, mask=true is required by RFC 6455.
pub fn encodeFrame(buf: []u8, opcode: Opcode, payload: []const u8, mask: bool) ![]const u8 {
    return encodeFrameWithKey(buf, opcode, payload, mask, [4]u8{ 0x37, 0xfa, 0x21, 0x3d });
}

pub fn encodeFrameWithKey(buf: []u8, opcode: Opcode, payload: []const u8, mask: bool, mask_key: [4]u8) ![]const u8 {
    const payload_len = payload.len;

    // Calculate header size
    var header_size: usize = 2;
    if (payload_len > 65535) {
        header_size += 8;
    } else if (payload_len > 125) {
        header_size += 2;
    }
    if (mask) header_size += 4;

    const total_size = header_size + payload_len;
    if (buf.len < total_size) return error.BufferTooSmall;

    var pos: usize = 0;

    // Byte 0: FIN=1, RSV=0, opcode
    buf[pos] = 0x80 | @as(u8, @intFromEnum(opcode));
    pos += 1;

    // Byte 1: MASK bit + payload length
    const mask_bit: u8 = if (mask) 0x80 else 0x00;
    if (payload_len <= 125) {
        buf[pos] = mask_bit | @as(u8, @intCast(payload_len));
        pos += 1;
    } else if (payload_len <= 65535) {
        buf[pos] = mask_bit | 126;
        pos += 1;
        buf[pos] = @intCast((payload_len >> 8) & 0xff);
        buf[pos + 1] = @intCast(payload_len & 0xff);
        pos += 2;
    } else {
        buf[pos] = mask_bit | 127;
        pos += 1;
        buf[pos] = @intCast((payload_len >> 56) & 0xff);
        buf[pos + 1] = @intCast((payload_len >> 48) & 0xff);
        buf[pos + 2] = @intCast((payload_len >> 40) & 0xff);
        buf[pos + 3] = @intCast((payload_len >> 32) & 0xff);
        buf[pos + 4] = @intCast((payload_len >> 24) & 0xff);
        buf[pos + 5] = @intCast((payload_len >> 16) & 0xff);
        buf[pos + 6] = @intCast((payload_len >> 8) & 0xff);
        buf[pos + 7] = @intCast(payload_len & 0xff);
        pos += 8;
    }

    if (mask) {
        buf[pos] = mask_key[0];
        buf[pos + 1] = mask_key[1];
        buf[pos + 2] = mask_key[2];
        buf[pos + 3] = mask_key[3];
        pos += 4;

        for (payload, 0..) |b, i| {
            buf[pos + i] = b ^ mask_key[i % 4];
        }
    } else {
        @memcpy(buf[pos..][0..payload_len], payload);
    }
    pos += payload_len;

    return buf[0..pos];
}

/// Decode a WebSocket frame from data.
/// The returned Frame.payload points into data (unmasked in place if masked).
/// NOTE: if the frame is masked, data must be mutable — pass a mutable slice.
pub fn decodeFrame(data: []const u8) !Frame {
    if (data.len < 2) return error.FrameTooShort;

    const byte0 = data[0];
    const byte1 = data[1];

    const fin = (byte0 & 0x80) != 0;
    const opcode_raw: u4 = @intCast(byte0 & 0x0f);
    const opcode: Opcode = @enumFromInt(opcode_raw);
    const is_masked = (byte1 & 0x80) != 0;
    const len_raw: u8 = byte1 & 0x7f;

    var pos: usize = 2;
    var payload_len: usize = 0;

    if (len_raw <= 125) {
        payload_len = len_raw;
    } else if (len_raw == 126) {
        if (data.len < 4) return error.FrameTooShort;
        payload_len = (@as(usize, data[pos]) << 8) | @as(usize, data[pos + 1]);
        pos += 2;
    } else { // 127
        if (data.len < 10) return error.FrameTooShort;
        payload_len = (@as(usize, data[pos]) << 56) |
            (@as(usize, data[pos + 1]) << 48) |
            (@as(usize, data[pos + 2]) << 40) |
            (@as(usize, data[pos + 3]) << 32) |
            (@as(usize, data[pos + 4]) << 24) |
            (@as(usize, data[pos + 5]) << 16) |
            (@as(usize, data[pos + 6]) << 8) |
            @as(usize, data[pos + 7]);
        pos += 8;
    }

    var mask_key: ?[4]u8 = null;
    if (is_masked) {
        if (data.len < pos + 4) return error.FrameTooShort;
        mask_key = [4]u8{ data[pos], data[pos + 1], data[pos + 2], data[pos + 3] };
        pos += 4;
    }

    if (data.len < pos + payload_len) return error.FrameTooShort;
    const payload = data[pos .. pos + payload_len];

    return Frame{
        .fin = fin,
        .opcode = opcode,
        .payload = payload,
        .mask_key = mask_key,
    };
}

/// Unmask payload in place. Call after decodeFrame if mask_key is present.
pub fn unmaskPayload(payload: []u8, mask_key: [4]u8) void {
    for (payload, 0..) |*b, i| {
        b.* ^= mask_key[i % 4];
    }
}

/// Returns the total frame size in bytes (header + payload), useful for advancing a buffer cursor.
pub fn frameSize(data: []const u8) !usize {
    if (data.len < 2) return error.FrameTooShort;
    const byte1 = data[1];
    const is_masked = (byte1 & 0x80) != 0;
    const len_raw: u8 = byte1 & 0x7f;

    var header_size: usize = 2;
    var payload_len: usize = 0;

    if (len_raw <= 125) {
        payload_len = len_raw;
    } else if (len_raw == 126) {
        if (data.len < 4) return error.FrameTooShort;
        payload_len = (@as(usize, data[2]) << 8) | @as(usize, data[3]);
        header_size += 2;
    } else {
        if (data.len < 10) return error.FrameTooShort;
        payload_len = (@as(usize, data[2]) << 56) |
            (@as(usize, data[3]) << 48) |
            (@as(usize, data[4]) << 40) |
            (@as(usize, data[5]) << 32) |
            (@as(usize, data[6]) << 24) |
            (@as(usize, data[7]) << 16) |
            (@as(usize, data[8]) << 8) |
            @as(usize, data[9]);
        header_size += 8;
    }
    if (is_masked) header_size += 4;

    return header_size + payload_len;
}
