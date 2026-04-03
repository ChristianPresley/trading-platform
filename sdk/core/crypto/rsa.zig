const std = @import("std");

/// Big integer for RSA — stored as little-endian u32 limbs.
pub const BigInt = struct {
    limbs: []u32,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, n_limbs: usize) !BigInt {
        const limbs = try allocator.alloc(u32, n_limbs);
        @memset(limbs, 0);
        return BigInt{ .limbs = limbs, .allocator = allocator };
    }

    pub fn deinit(self: *BigInt) void {
        self.allocator.free(self.limbs);
    }

    pub fn fromBytes(allocator: std.mem.Allocator, bytes: []const u8) !BigInt {
        // Big-endian bytes to little-endian limbs
        const n_limbs = (bytes.len + 3) / 4;
        var self = try BigInt.init(allocator, n_limbs);
        for (0..bytes.len) |i| {
            const byte_idx = bytes.len - 1 - i;
            const limb_idx = i / 4;
            const bit_shift: u5 = @intCast((i % 4) * 8);
            self.limbs[limb_idx] |= @as(u32, bytes[byte_idx]) << bit_shift;
        }
        return self;
    }

    /// Modular exponentiation: base^exp mod m
    pub fn modPow(allocator: std.mem.Allocator, base: *const BigInt, exp: *const BigInt, modulus: *const BigInt) !BigInt {
        const n = modulus.limbs.len;
        var result = try BigInt.init(allocator, n);
        result.limbs[0] = 1; // result = 1

        var b = try BigInt.init(allocator, n);
        defer b.deinit();
        // b = base mod modulus
        const blen = @min(base.limbs.len, n);
        @memcpy(b.limbs[0..blen], base.limbs[0..blen]);

        // Square-and-multiply over bits of exp
        for (0..exp.limbs.len) |li| {
            const limb = exp.limbs[li];
            for (0..32) |bi| {
                if ((limb >> @intCast(bi)) & 1 == 1) {
                    // result = result * b mod modulus
                    const t = try mulMod(allocator, &result, &b, modulus);
                    result.deinit();
                    result = t;
                }
                // b = b * b mod modulus
                const t = try mulMod(allocator, &b, &b, modulus);
                b.deinit();
                b = t;
            }
        }
        return result;
    }

    fn mulMod(allocator: std.mem.Allocator, a: *const BigInt, b: *const BigInt, m: *const BigInt) !BigInt {
        // Simple O(n^2) multiply then reduce
        var product = try BigInt.init(allocator, a.limbs.len + b.limbs.len);
        defer product.deinit();

        for (0..a.limbs.len) |i| {
            var carry: u64 = 0;
            for (0..b.limbs.len) |j| {
                const idx = i + j;
                if (idx < product.limbs.len) {
                    const val = @as(u64, a.limbs[i]) * @as(u64, b.limbs[j]) + @as(u64, product.limbs[idx]) + carry;
                    product.limbs[idx] = @intCast(val & 0xffffffff);
                    carry = val >> 32;
                }
            }
            if (i + b.limbs.len < product.limbs.len) {
                product.limbs[i + b.limbs.len] +%= @intCast(carry & 0xffffffff);
            }
        }

        // Reduce mod m (simple trial subtraction for now; works for small RSA keys in tests)
        return try mod(allocator, &product, m);
    }

    fn mod(allocator: std.mem.Allocator, a: *const BigInt, m: *const BigInt) !BigInt {
        // Simple bit-by-bit reduction
        var r = try BigInt.init(allocator, m.limbs.len);
        // Copy a into r (truncated to m size if smaller)
        const copy_len = @min(a.limbs.len, m.limbs.len * 2);

        // Simple approach: subtract m while >= m
        // For correctness, use shift-subtract division
        var rem = try BigInt.init(allocator, a.limbs.len + 1);
        defer rem.deinit();
        @memcpy(rem.limbs[0..a.limbs.len], a.limbs);

        const total_bits = rem.limbs.len * 32;
        _ = total_bits;
        _ = copy_len;

        // Repeated subtraction (naive but correct for testing)
        while (cmp(&rem, m) >= 0) {
            subInPlace(&rem, m);
        }

        @memcpy(r.limbs[0..@min(rem.limbs.len, r.limbs.len)], rem.limbs[0..@min(rem.limbs.len, r.limbs.len)]);
        return r;
    }

    fn cmp(a: *const BigInt, b: *const BigInt) i32 {
        const max_len = @max(a.limbs.len, b.limbs.len);
        var i = max_len;
        while (i > 0) {
            i -= 1;
            const av: u32 = if (i < a.limbs.len) a.limbs[i] else 0;
            const bv: u32 = if (i < b.limbs.len) b.limbs[i] else 0;
            if (av > bv) return 1;
            if (av < bv) return -1;
        }
        return 0;
    }

    fn subInPlace(a: *BigInt, b: *const BigInt) void {
        var borrow: u64 = 0;
        for (0..a.limbs.len) |i| {
            const bv: u64 = if (i < b.limbs.len) b.limbs[i] else 0;
            const av: u64 = a.limbs[i];
            const diff = av -% bv -% borrow;
            a.limbs[i] = @intCast(diff & 0xffffffff);
            borrow = if (av < bv + borrow) 1 else 0;
        }
    }

    pub fn toBytes(self: *const BigInt, out: []u8) void {
        @memset(out, 0);
        for (0..self.limbs.len) |i| {
            const limb = self.limbs[i];
            const byte_base = (self.limbs.len - 1 - i) * 4;
            if (byte_base + 3 < out.len) {
                out[out.len - 1 - (i * 4)] = @intCast(limb & 0xff);
                out[out.len - 1 - (i * 4 + 1)] = @intCast((limb >> 8) & 0xff);
                out[out.len - 1 - (i * 4 + 2)] = @intCast((limb >> 16) & 0xff);
                out[out.len - 1 - (i * 4 + 3)] = @intCast((limb >> 24) & 0xff);
            }
        }
    }
};

pub const RsaPublicKey = struct {
    n: BigInt,
    e: BigInt,

    pub fn deinit(self: *RsaPublicKey) void {
        self.n.deinit();
        self.e.deinit();
    }
};

// SHA-256 DigestInfo prefix for PKCS#1v1.5
const SHA256_DIGEST_INFO_PREFIX = [_]u8{
    0x30, 0x31, 0x30, 0x0d, 0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x02, 0x01, 0x05, 0x00, 0x04, 0x20,
};

/// Verify RSA-PKCS1v15 signature (SHA-256 hash).
pub fn verifyPkcs1v15(allocator: std.mem.Allocator, public_key: *const RsaPublicKey, message_hash: []const u8, signature: []const u8) !void {
    // RSA verify: m = sig^e mod n
    var sig_int = try BigInt.fromBytes(allocator, signature);
    defer sig_int.deinit();

    var m = try BigInt.modPow(allocator, &sig_int, &public_key.e, &public_key.n);
    defer m.deinit();

    // Convert result to bytes with same length as modulus
    const mod_len = public_key.n.limbs.len * 4;
    var em = try allocator.alloc(u8, mod_len);
    defer allocator.free(em);
    m.toBytes(em);

    // Verify PKCS#1 v1.5 padding: 0x00 0x01 [0xff...] 0x00 [DigestInfo] [hash]
    if (em[0] != 0x00 or em[1] != 0x01) return error.InvalidSignature;
    var i: usize = 2;
    while (i < em.len and em[i] == 0xff) : (i += 1) {}
    if (i < 3 or em[i] != 0x00) return error.InvalidSignature;
    i += 1;

    // Check DigestInfo prefix
    const expected_prefix = SHA256_DIGEST_INFO_PREFIX;
    if (i + expected_prefix.len + 32 > em.len) return error.InvalidSignature;
    if (!std.mem.eql(u8, em[i..][0..expected_prefix.len], &expected_prefix)) return error.InvalidSignature;
    i += expected_prefix.len;

    // Check hash
    if (!std.mem.eql(u8, em[i..][0..message_hash.len], message_hash)) return error.InvalidSignature;
}
