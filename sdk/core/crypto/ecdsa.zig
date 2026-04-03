const std = @import("std");

/// ECDSA signature verification over P-256 and P-384.

// P-256 order n
const P256_N = [32]u8{
    0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xbc, 0xe6, 0xfa, 0xad, 0xa7, 0x17, 0x9e, 0x84,
    0xf3, 0xb9, 0xca, 0xc2, 0xfc, 0x63, 0x25, 0x51,
};

pub const P256Point = struct {
    x: [32]u8,
    y: [32]u8,
};

pub const P384Point = struct {
    x: [48]u8,
    y: [48]u8,
};

fn bytesLt(a: []const u8, b: []const u8) bool {
    std.debug.assert(a.len == b.len);
    for (0..a.len) |i| {
        if (a[i] < b[i]) return true;
        if (a[i] > b[i]) return false;
    }
    return false;
}

fn bytesIsZero(a: []const u8) bool {
    for (a) |b| if (b != 0) return false;
    return true;
}

/// ECDSA-P256 signature verification.
/// Validates structural constraints. Full point multiplication not implemented.
pub fn verifyP256(
    public_key: P256Point,
    message_hash: *const [32]u8,
    sig_r: *const [32]u8,
    sig_s: *const [32]u8,
) !void {
    // Basic validation: r and s must be in [1, n-1]
    if (bytesIsZero(sig_r) or bytesIsZero(sig_s)) return error.InvalidSignature;
    if (!bytesLt(sig_r, &P256_N) or !bytesLt(sig_s, &P256_N)) return error.InvalidSignature;
    if (bytesIsZero(&public_key.x) and bytesIsZero(&public_key.y)) return error.InvalidPublicKey;
    // message_hash used for full verification (placeholder)
    _ = message_hash;
}

/// ECDSA-P384 signature verification (placeholder).
pub fn verifyP384(
    public_key: P384Point,
    message_hash: *const [48]u8,
    sig_r: *const [48]u8,
    sig_s: *const [48]u8,
) !void {
    _ = public_key;
    _ = message_hash;
    _ = sig_r;
    _ = sig_s;
}
