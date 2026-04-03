const std = @import("std");

// SHA-256 constants (first 32 bits of fractional parts of cube roots of first 64 primes)
const SHA256_K = [64]u32{
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
};

// SHA-256 initial hash values
const SHA256_H0 = [8]u32{
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
};

fn rotr32(x: u32, n: u5) u32 {
    return std.math.rotr(u32, x, @as(u32, n));
}

fn sha256Block(h: *[8]u32, block: *const [64]u8) void {
    var w: [64]u32 = undefined;
    for (0..16) |i| {
        w[i] = (@as(u32, block[i * 4]) << 24) |
            (@as(u32, block[i * 4 + 1]) << 16) |
            (@as(u32, block[i * 4 + 2]) << 8) |
            @as(u32, block[i * 4 + 3]);
    }
    for (16..64) |i| {
        const s0 = rotr32(w[i - 15], 7) ^ rotr32(w[i - 15], 18) ^ (w[i - 15] >> 3);
        const s1 = rotr32(w[i - 2], 17) ^ rotr32(w[i - 2], 19) ^ (w[i - 2] >> 10);
        w[i] = w[i - 16] +% s0 +% w[i - 7] +% s1;
    }

    var a = h[0];
    var b = h[1];
    var c = h[2];
    var d = h[3];
    var e = h[4];
    var f = h[5];
    var g = h[6];
    var hh = h[7];

    for (0..64) |i| {
        const S1 = rotr32(e, 6) ^ rotr32(e, 11) ^ rotr32(e, 25);
        const ch = (e & f) ^ (~e & g);
        const temp1 = hh +% S1 +% ch +% SHA256_K[i] +% w[i];
        const S0 = rotr32(a, 2) ^ rotr32(a, 13) ^ rotr32(a, 22);
        const maj = (a & b) ^ (a & c) ^ (b & c);
        const temp2 = S0 +% maj;

        hh = g;
        g = f;
        f = e;
        e = d +% temp1;
        d = c;
        c = b;
        b = a;
        a = temp1 +% temp2;
    }

    h[0] +%= a;
    h[1] +%= b;
    h[2] +%= c;
    h[3] +%= d;
    h[4] +%= e;
    h[5] +%= f;
    h[6] +%= g;
    h[7] +%= hh;
}

/// SHA-256 hash per FIPS 180-4.
pub fn sha256(data: []const u8, out: *[32]u8) void {
    var h: [8]u32 = SHA256_H0;
    var block: [64]u8 = undefined;
    var block_len: usize = 0;
    var total_bits: u64 = @intCast(data.len);
    total_bits *= 8;

    var pos: usize = 0;
    while (pos < data.len) {
        const remaining = data.len - pos;
        const space = 64 - block_len;
        const copy = @min(remaining, space);
        @memcpy(block[block_len..][0..copy], data[pos..][0..copy]);
        block_len += copy;
        pos += copy;
        if (block_len == 64) {
            sha256Block(&h, &block);
            block_len = 0;
        }
    }

    // Padding
    block[block_len] = 0x80;
    block_len += 1;
    if (block_len > 56) {
        @memset(block[block_len..64], 0);
        sha256Block(&h, &block);
        block_len = 0;
    }
    @memset(block[block_len..56], 0);
    // Append total bit length as big-endian u64
    block[56] = @intCast((total_bits >> 56) & 0xff);
    block[57] = @intCast((total_bits >> 48) & 0xff);
    block[58] = @intCast((total_bits >> 40) & 0xff);
    block[59] = @intCast((total_bits >> 32) & 0xff);
    block[60] = @intCast((total_bits >> 24) & 0xff);
    block[61] = @intCast((total_bits >> 16) & 0xff);
    block[62] = @intCast((total_bits >> 8) & 0xff);
    block[63] = @intCast(total_bits & 0xff);
    sha256Block(&h, &block);

    for (0..8) |i| {
        out[i * 4] = @intCast((h[i] >> 24) & 0xff);
        out[i * 4 + 1] = @intCast((h[i] >> 16) & 0xff);
        out[i * 4 + 2] = @intCast((h[i] >> 8) & 0xff);
        out[i * 4 + 3] = @intCast(h[i] & 0xff);
    }
}

// SHA-512 constants (first 64 bits of fractional parts of cube roots of first 80 primes)
const SHA512_K = [80]u64{
    0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc,
    0x3956c25bf348b538, 0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118,
    0xd807aa98a3030242, 0x12835b0145706fbe, 0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2,
    0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235, 0xc19bf174cf692694,
    0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65,
    0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5,
    0x983e5152ee66dfab, 0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4,
    0xc6e00bf33da88fc2, 0xd5a79147930aa725, 0x06ca6351e003826f, 0x142929670a0e6e70,
    0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed, 0x53380d139d95b3df,
    0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b,
    0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30,
    0xd192e819d6ef5218, 0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8,
    0x19a4c116b8d2d0c8, 0x1e376c085141ab53, 0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8,
    0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373, 0x682e6ff3d6b2b8a3,
    0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec,
    0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b,
    0xca273eceea26619c, 0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178,
    0x06f067aa72176fba, 0x0a637dc5a2c898a6, 0x113f9804bef90dae, 0x1b710b35131c471b,
    0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc, 0x431d67c49c100d4c,
    0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817,
};

const SHA512_H0 = [8]u64{
    0x6a09e667f3bcc908, 0xbb67ae8584caa73b, 0x3c6ef372fe94f82b, 0xa54ff53a5f1d36f1,
    0x510e527fade682d1, 0x9b05688c2b3e6c1f, 0x1f83d9abfb41bd6b, 0x5be0cd19137e2179,
};

fn rotr64(x: u64, n: u6) u64 {
    return std.math.rotr(u64, x, @as(u64, n));
}

fn sha512Block(h: *[8]u64, block: *const [128]u8) void {
    var w: [80]u64 = undefined;
    for (0..16) |i| {
        w[i] = (@as(u64, block[i * 8]) << 56) |
            (@as(u64, block[i * 8 + 1]) << 48) |
            (@as(u64, block[i * 8 + 2]) << 40) |
            (@as(u64, block[i * 8 + 3]) << 32) |
            (@as(u64, block[i * 8 + 4]) << 24) |
            (@as(u64, block[i * 8 + 5]) << 16) |
            (@as(u64, block[i * 8 + 6]) << 8) |
            @as(u64, block[i * 8 + 7]);
    }
    for (16..80) |i| {
        const s0 = rotr64(w[i - 15], 1) ^ rotr64(w[i - 15], 8) ^ (w[i - 15] >> 7);
        const s1 = rotr64(w[i - 2], 19) ^ rotr64(w[i - 2], 61) ^ (w[i - 2] >> 6);
        w[i] = w[i - 16] +% s0 +% w[i - 7] +% s1;
    }

    var a = h[0];
    var b = h[1];
    var c = h[2];
    var d = h[3];
    var e = h[4];
    var f = h[5];
    var g = h[6];
    var hh = h[7];

    for (0..80) |i| {
        const S1 = rotr64(e, 14) ^ rotr64(e, 18) ^ rotr64(e, 41);
        const ch = (e & f) ^ (~e & g);
        const temp1 = hh +% S1 +% ch +% SHA512_K[i] +% w[i];
        const S0 = rotr64(a, 28) ^ rotr64(a, 34) ^ rotr64(a, 39);
        const maj = (a & b) ^ (a & c) ^ (b & c);
        const temp2 = S0 +% maj;

        hh = g;
        g = f;
        f = e;
        e = d +% temp1;
        d = c;
        c = b;
        b = a;
        a = temp1 +% temp2;
    }

    h[0] +%= a;
    h[1] +%= b;
    h[2] +%= c;
    h[3] +%= d;
    h[4] +%= e;
    h[5] +%= f;
    h[6] +%= g;
    h[7] +%= hh;
}

/// SHA-512 hash per FIPS 180-4.
pub fn sha512(data: []const u8, out: *[64]u8) void {
    var h: [8]u64 = SHA512_H0;
    var block: [128]u8 = undefined;
    var block_len: usize = 0;
    // Total bit length as u128
    const total_bits: u128 = @as(u128, data.len) * 8;

    var pos: usize = 0;
    while (pos < data.len) {
        const remaining = data.len - pos;
        const space = 128 - block_len;
        const copy = @min(remaining, space);
        @memcpy(block[block_len..][0..copy], data[pos..][0..copy]);
        block_len += copy;
        pos += copy;
        if (block_len == 128) {
            sha512Block(&h, &block);
            block_len = 0;
        }
    }

    // Padding
    block[block_len] = 0x80;
    block_len += 1;
    if (block_len > 112) {
        @memset(block[block_len..128], 0);
        sha512Block(&h, &block);
        block_len = 0;
    }
    @memset(block[block_len..112], 0);
    // Append total bit length as big-endian u128 (16 bytes)
    var i: usize = 0;
    while (i < 16) : (i += 1) {
        block[112 + i] = @intCast((total_bits >> @intCast((15 - i) * 8)) & 0xff);
    }
    sha512Block(&h, &block);

    for (0..8) |j| {
        out[j * 8] = @intCast((h[j] >> 56) & 0xff);
        out[j * 8 + 1] = @intCast((h[j] >> 48) & 0xff);
        out[j * 8 + 2] = @intCast((h[j] >> 40) & 0xff);
        out[j * 8 + 3] = @intCast((h[j] >> 32) & 0xff);
        out[j * 8 + 4] = @intCast((h[j] >> 24) & 0xff);
        out[j * 8 + 5] = @intCast((h[j] >> 16) & 0xff);
        out[j * 8 + 6] = @intCast((h[j] >> 8) & 0xff);
        out[j * 8 + 7] = @intCast(h[j] & 0xff);
    }
}

const HMAC_BLOCK_SIZE_SHA512: usize = 128;

/// HMAC-SHA-512 per RFC 2104.
pub fn hmacSha512(key: []const u8, data: []const u8, out: *[64]u8) void {
    var k_ipad: [HMAC_BLOCK_SIZE_SHA512]u8 = [_]u8{0x36} ** HMAC_BLOCK_SIZE_SHA512;
    var k_opad: [HMAC_BLOCK_SIZE_SHA512]u8 = [_]u8{0x5c} ** HMAC_BLOCK_SIZE_SHA512;

    var effective_key: [64]u8 = undefined;
    const key_slice: []const u8 = if (key.len > HMAC_BLOCK_SIZE_SHA512) blk: {
        sha512(key, &effective_key);
        break :blk effective_key[0..64];
    } else key;

    for (key_slice, 0..) |b, i| {
        k_ipad[i] ^= b;
        k_opad[i] ^= b;
    }

    // inner = SHA512(ipad || data)
    var inner_hash: [64]u8 = undefined;
    var inner_data_buf: [HMAC_BLOCK_SIZE_SHA512 + 2048]u8 = undefined;
    if (data.len <= 2048) {
        @memcpy(inner_data_buf[0..HMAC_BLOCK_SIZE_SHA512], &k_ipad);
        @memcpy(inner_data_buf[HMAC_BLOCK_SIZE_SHA512..][0..data.len], data);
        sha512(inner_data_buf[0 .. HMAC_BLOCK_SIZE_SHA512 + data.len], &inner_hash);
    } else {
        // For large data, use incremental approach via allocated buffer
        var inner_alloc_buf = std.heap.page_allocator.alloc(u8, HMAC_BLOCK_SIZE_SHA512 + data.len) catch unreachable;
        defer std.heap.page_allocator.free(inner_alloc_buf);
        @memcpy(inner_alloc_buf[0..HMAC_BLOCK_SIZE_SHA512], &k_ipad);
        @memcpy(inner_alloc_buf[HMAC_BLOCK_SIZE_SHA512..], data);
        sha512(inner_alloc_buf, &inner_hash);
    }

    // outer = SHA512(opad || inner_hash)
    var outer_data: [HMAC_BLOCK_SIZE_SHA512 + 64]u8 = undefined;
    @memcpy(outer_data[0..HMAC_BLOCK_SIZE_SHA512], &k_opad);
    @memcpy(outer_data[HMAC_BLOCK_SIZE_SHA512..], &inner_hash);
    sha512(&outer_data, out);
}
