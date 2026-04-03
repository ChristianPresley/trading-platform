const std = @import("std");

/// X25519 Diffie-Hellman key exchange per RFC 7748.
/// Uses std.crypto.dh.X25519 for the field arithmetic.

/// X25519 key exchange: compute shared secret from secret_key and peer's public_key.
pub fn keyExchange(secret_key: *const [32]u8, public_key: *const [32]u8, out: *[32]u8) void {
    out.* = std.crypto.dh.X25519.scalarmult(secret_key.*, public_key.*) catch unreachable;
}

/// Derive public key from secret key (multiply by base point u=9).
pub fn publicKey(secret_key: *const [32]u8) [32]u8 {
    const base: [32]u8 = .{9} ++ .{0} ** 31;
    return std.crypto.dh.X25519.scalarmult(secret_key.*, base) catch unreachable;
}
