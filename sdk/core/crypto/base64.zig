const std = @import("std");

const TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

pub fn encodedLen(source_len: usize) usize {
    return ((source_len + 2) / 3) * 4;
}

pub fn decodedLen(source_len: usize) usize {
    if (source_len == 0) return 0;
    return (source_len / 4) * 3;
}

/// Standard Base64 encoding per RFC 4648.
pub fn encode(dest: []u8, source: []const u8) []const u8 {
    var di: usize = 0;
    var si: usize = 0;
    while (si + 2 < source.len) {
        const b0 = source[si];
        const b1 = source[si + 1];
        const b2 = source[si + 2];
        dest[di] = TABLE[(b0 >> 2) & 0x3f];
        dest[di + 1] = TABLE[((b0 & 0x3) << 4) | ((b1 >> 4) & 0xf)];
        dest[di + 2] = TABLE[((b1 & 0xf) << 2) | ((b2 >> 6) & 0x3)];
        dest[di + 3] = TABLE[b2 & 0x3f];
        si += 3;
        di += 4;
    }
    const rem = source.len - si;
    if (rem == 1) {
        const b0 = source[si];
        dest[di] = TABLE[(b0 >> 2) & 0x3f];
        dest[di + 1] = TABLE[(b0 & 0x3) << 4];
        dest[di + 2] = '=';
        dest[di + 3] = '=';
        di += 4;
    } else if (rem == 2) {
        const b0 = source[si];
        const b1 = source[si + 1];
        dest[di] = TABLE[(b0 >> 2) & 0x3f];
        dest[di + 1] = TABLE[((b0 & 0x3) << 4) | ((b1 >> 4) & 0xf)];
        dest[di + 2] = TABLE[(b1 & 0xf) << 2];
        dest[di + 3] = '=';
        di += 4;
    }
    return dest[0..di];
}

fn decodeChar(c: u8) !u8 {
    return switch (c) {
        'A'...'Z' => c - 'A',
        'a'...'z' => c - 'a' + 26,
        '0'...'9' => c - '0' + 52,
        '+' => 62,
        '/' => 63,
        else => error.InvalidChar,
    };
}

/// Base64 decode per RFC 4648. Returns error on invalid input.
pub fn decode(dest: []u8, source: []const u8) ![]const u8 {
    if (source.len % 4 != 0) return error.InvalidLength;
    var di: usize = 0;
    var si: usize = 0;
    while (si < source.len) {
        const b0 = try decodeChar(source[si]);
        const b1 = try decodeChar(source[si + 1]);
        dest[di] = (b0 << 2) | (b1 >> 4);
        di += 1;
        if (source[si + 2] != '=') {
            const b2 = try decodeChar(source[si + 2]);
            dest[di] = ((b1 & 0xf) << 4) | (b2 >> 2);
            di += 1;
            if (source[si + 3] != '=') {
                const b3 = try decodeChar(source[si + 3]);
                dest[di] = ((b2 & 0x3) << 6) | b3;
                di += 1;
            }
        }
        si += 4;
    }
    return dest[0..di];
}
