const std = @import("std");

// AES S-Box
const SBOX = [256]u8{
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16,
};

// AES round constants
const RCON = [11]u8{ 0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36 };

fn xtime(a: u8) u8 {
    return if (a & 0x80 != 0) ((a << 1) ^ 0x1b) else (a << 1);
}

fn gmul(a: u8, b: u8) u8 {
    var p: u8 = 0;
    var aa = a;
    var bb = b;
    var i: u8 = 0;
    while (i < 8) : (i += 1) {
        if (bb & 1 != 0) p ^= aa;
        const high = aa & 0x80;
        aa <<= 1;
        if (high != 0) aa ^= 0x1b;
        bb >>= 1;
    }
    return p;
}

const AES_BLOCK_SIZE = 16;

pub const Aes128 = struct {
    round_keys: [11][4]u32,

    pub fn init(key: *const [16]u8) Aes128 {
        var self: Aes128 = undefined;
        keyExpand128(key, &self.round_keys);
        return self;
    }

    pub fn encrypt(self: *const Aes128, block: *const [16]u8, out: *[16]u8) void {
        encryptBlock(block, out, &self.round_keys, 10);
    }
};

pub const Aes256 = struct {
    round_keys: [15][4]u32,

    pub fn init(key: *const [32]u8) Aes256 {
        var self: Aes256 = undefined;
        keyExpand256(key, &self.round_keys);
        return self;
    }

    pub fn encrypt(self: *const Aes256, block: *const [16]u8, out: *[16]u8) void {
        encryptBlock(block, out, &self.round_keys, 14);
    }
};

fn subWord(w: u32) u32 {
    return (@as(u32, SBOX[(w >> 24) & 0xff]) << 24) |
        (@as(u32, SBOX[(w >> 16) & 0xff]) << 16) |
        (@as(u32, SBOX[(w >> 8) & 0xff]) << 8) |
        @as(u32, SBOX[w & 0xff]);
}

fn rotWord(w: u32) u32 {
    return (w << 8) | (w >> 24);
}

fn keyExpand128(key: *const [16]u8, rk: *[11][4]u32) void {
    for (0..4) |i| {
        rk[0][i] = (@as(u32, key[i * 4]) << 24) | (@as(u32, key[i * 4 + 1]) << 16) |
            (@as(u32, key[i * 4 + 2]) << 8) | @as(u32, key[i * 4 + 3]);
    }
    var prev: [4]u32 = rk[0];
    for (1..11) |round| {
        var w: [4]u32 = undefined;
        w[0] = prev[0] ^ subWord(rotWord(prev[3])) ^ (@as(u32, RCON[round]) << 24);
        w[1] = prev[1] ^ w[0];
        w[2] = prev[2] ^ w[1];
        w[3] = prev[3] ^ w[2];
        rk[round] = w;
        prev = w;
    }
}

fn keyExpand256(key: *const [32]u8, rk: *[15][4]u32) void {
    for (0..4) |i| {
        rk[0][i] = (@as(u32, key[i * 4]) << 24) | (@as(u32, key[i * 4 + 1]) << 16) |
            (@as(u32, key[i * 4 + 2]) << 8) | @as(u32, key[i * 4 + 3]);
    }
    for (0..4) |i| {
        rk[1][i] = (@as(u32, key[16 + i * 4]) << 24) | (@as(u32, key[16 + i * 4 + 1]) << 16) |
            (@as(u32, key[16 + i * 4 + 2]) << 8) | @as(u32, key[16 + i * 4 + 3]);
    }
    var i: usize = 2;
    while (i < 15) : (i += 1) {
        var w: [4]u32 = undefined;
        if (i % 2 == 0) {
            const rcon = RCON[i / 2];
            w[0] = rk[i - 2][0] ^ subWord(rotWord(rk[i - 1][3])) ^ (@as(u32, rcon) << 24);
        } else {
            w[0] = rk[i - 2][0] ^ subWord(rk[i - 1][3]);
        }
        w[1] = rk[i - 2][1] ^ w[0];
        w[2] = rk[i - 2][2] ^ w[1];
        w[3] = rk[i - 2][3] ^ w[2];
        rk[i] = w;
    }
}

fn wordToBytes(w: u32, out: *[4]u8) void {
    out[0] = @intCast((w >> 24) & 0xff);
    out[1] = @intCast((w >> 16) & 0xff);
    out[2] = @intCast((w >> 8) & 0xff);
    out[3] = @intCast(w & 0xff);
}

fn encryptBlock(block: *const [16]u8, out: *[16]u8, rk: []const [4]u32, nr: usize) void {
    // State as 4x4 bytes (column-major)
    var state: [4][4]u8 = undefined;
    for (0..4) |c| {
        for (0..4) |r| {
            state[c][r] = block[c * 4 + r];
        }
    }

    // AddRoundKey with round 0
    for (0..4) |c| {
        const rk_bytes: [4]u8 = .{
            @intCast((rk[0][c] >> 24) & 0xff),
            @intCast((rk[0][c] >> 16) & 0xff),
            @intCast((rk[0][c] >> 8) & 0xff),
            @intCast(rk[0][c] & 0xff),
        };
        for (0..4) |r| {
            state[c][r] ^= rk_bytes[r];
        }
    }

    for (1..nr + 1) |round| {
        // SubBytes
        for (0..4) |c| {
            for (0..4) |r| {
                state[c][r] = SBOX[state[c][r]];
            }
        }
        // ShiftRows
        var tmp: u8 = undefined;
        // Row 1: shift left 1
        tmp = state[0][1];
        state[0][1] = state[1][1];
        state[1][1] = state[2][1];
        state[2][1] = state[3][1];
        state[3][1] = tmp;
        // Row 2: shift left 2
        tmp = state[0][2];
        state[0][2] = state[2][2];
        state[2][2] = tmp;
        tmp = state[1][2];
        state[1][2] = state[3][2];
        state[3][2] = tmp;
        // Row 3: shift left 3
        tmp = state[3][3];
        state[3][3] = state[2][3];
        state[2][3] = state[1][3];
        state[1][3] = state[0][3];
        state[0][3] = tmp;

        // MixColumns (skip on last round)
        if (round < nr) {
            for (0..4) |c| {
                const s0 = state[c][0];
                const s1 = state[c][1];
                const s2 = state[c][2];
                const s3 = state[c][3];
                state[c][0] = gmul(0x02, s0) ^ gmul(0x03, s1) ^ s2 ^ s3;
                state[c][1] = s0 ^ gmul(0x02, s1) ^ gmul(0x03, s2) ^ s3;
                state[c][2] = s0 ^ s1 ^ gmul(0x02, s2) ^ gmul(0x03, s3);
                state[c][3] = gmul(0x03, s0) ^ s1 ^ s2 ^ gmul(0x02, s3);
            }
        }

        // AddRoundKey
        for (0..4) |c| {
            const rk_bytes: [4]u8 = .{
                @intCast((rk[round][c] >> 24) & 0xff),
                @intCast((rk[round][c] >> 16) & 0xff),
                @intCast((rk[round][c] >> 8) & 0xff),
                @intCast(rk[round][c] & 0xff),
            };
            for (0..4) |r| {
                state[c][r] ^= rk_bytes[r];
            }
        }
    }

    for (0..4) |c| {
        for (0..4) |r| {
            out[c * 4 + r] = state[c][r];
        }
    }
}

// GCM Helper: GHASH
fn ghashUpdate(h: *const [16]u8, x: *[16]u8, block: *const [16]u8) void {
    // x ^= block
    for (0..16) |i| {
        x[i] ^= block[i];
    }
    // Multiply x by H in GF(2^128)
    ghashMul(x, h);
}

fn ghashMul(x: *[16]u8, h: *const [16]u8) void {
    var v: [16]u8 = h.*;
    var z: [16]u8 = [_]u8{0} ** 16;

    for (0..128) |i| {
        // If bit i of x is set, z ^= v
        const byte_idx = i / 8;
        const bit_idx: u3 = @intCast(7 - (i % 8));
        if ((x[byte_idx] >> bit_idx) & 1 != 0) {
            for (0..16) |j| {
                z[j] ^= v[j];
            }
        }
        // v = v >> 1 in GF(2^128), with reduction x^128 + x^7 + x^2 + x + 1
        const carry = v[15] & 1;
        var j: usize = 15;
        while (j > 0) : (j -= 1) {
            v[j] = (v[j] >> 1) | ((v[j - 1] & 1) << 7);
        }
        v[0] >>= 1;
        if (carry != 0) v[0] ^= 0xe1;
    }
    x.* = z;
}

fn inc32(ctr: *[16]u8) void {
    var i: usize = 16;
    while (i > 12) {
        i -= 1;
        ctr[i] +%= 1;
        if (ctr[i] != 0) break;
    }
}

pub const AesGcm = struct {
    /// AES-GCM encrypt. Key must be 16 or 32 bytes.
    pub fn encrypt(
        key: []const u8,
        nonce: *const [12]u8,
        plaintext: []const u8,
        aad: []const u8,
        ciphertext: []u8,
        tag: *[16]u8,
    ) void {
        std.debug.assert(ciphertext.len >= plaintext.len);
        std.debug.assert(key.len == 16 or key.len == 32);

        // Build CTR0 = nonce || 0x00000001
        var ctr0: [16]u8 = [_]u8{0} ** 16;
        @memcpy(ctr0[0..12], nonce);
        ctr0[15] = 1;

        var ctr: [16]u8 = ctr0;
        inc32(&ctr);

        // Encrypt H block for GHASH
        var h: [16]u8 = [_]u8{0} ** 16;
        encryptKeyBlock(key, &h, &h);

        var ghash_state: [16]u8 = [_]u8{0} ** 16;

        // GHASH over AAD
        var aad_pos: usize = 0;
        while (aad_pos + 16 <= aad.len) : (aad_pos += 16) {
            ghashUpdate(&h, &ghash_state, aad[aad_pos..][0..16]);
        }
        if (aad_pos < aad.len) {
            var pad_block: [16]u8 = [_]u8{0} ** 16;
            @memcpy(pad_block[0 .. aad.len - aad_pos], aad[aad_pos..]);
            ghashUpdate(&h, &ghash_state, &pad_block);
        }

        // Encrypt plaintext with CTR mode + GHASH
        var pt_pos: usize = 0;
        while (pt_pos < plaintext.len) {
            var keystream: [16]u8 = ctr;
            encryptKeyBlock(key, &keystream, &keystream);
            inc32(&ctr);

            const block_len = @min(16, plaintext.len - pt_pos);
            for (0..block_len) |i| {
                ciphertext[pt_pos + i] = plaintext[pt_pos + i] ^ keystream[i];
            }

            // GHASH over ciphertext block
            if (block_len == 16) {
                ghashUpdate(&h, &ghash_state, ciphertext[pt_pos..][0..16]);
            } else {
                var pad_block: [16]u8 = [_]u8{0} ** 16;
                @memcpy(pad_block[0..block_len], ciphertext[pt_pos..][0..block_len]);
                ghashUpdate(&h, &ghash_state, &pad_block);
            }
            pt_pos += block_len;
        }

        // GHASH final block: len(AAD) || len(CT) in bits as u64 big-endian each
        var len_block: [16]u8 = undefined;
        const aad_bits: u64 = @intCast(aad.len * 8);
        const ct_bits: u64 = @intCast(plaintext.len * 8);
        len_block[0] = @intCast((aad_bits >> 56) & 0xff);
        len_block[1] = @intCast((aad_bits >> 48) & 0xff);
        len_block[2] = @intCast((aad_bits >> 40) & 0xff);
        len_block[3] = @intCast((aad_bits >> 32) & 0xff);
        len_block[4] = @intCast((aad_bits >> 24) & 0xff);
        len_block[5] = @intCast((aad_bits >> 16) & 0xff);
        len_block[6] = @intCast((aad_bits >> 8) & 0xff);
        len_block[7] = @intCast(aad_bits & 0xff);
        len_block[8] = @intCast((ct_bits >> 56) & 0xff);
        len_block[9] = @intCast((ct_bits >> 48) & 0xff);
        len_block[10] = @intCast((ct_bits >> 40) & 0xff);
        len_block[11] = @intCast((ct_bits >> 32) & 0xff);
        len_block[12] = @intCast((ct_bits >> 24) & 0xff);
        len_block[13] = @intCast((ct_bits >> 16) & 0xff);
        len_block[14] = @intCast((ct_bits >> 8) & 0xff);
        len_block[15] = @intCast(ct_bits & 0xff);
        ghashUpdate(&h, &ghash_state, &len_block);

        // Tag = E(K, CTR0) ^ GHASH
        var e_ctr0: [16]u8 = ctr0;
        encryptKeyBlock(key, &e_ctr0, &e_ctr0);
        for (0..16) |i| {
            tag[i] = e_ctr0[i] ^ ghash_state[i];
        }
    }

    /// AES-GCM decrypt. Returns error.AuthenticationFailed if tag mismatch.
    pub fn decrypt(
        key: []const u8,
        nonce: *const [12]u8,
        ciphertext: []const u8,
        aad: []const u8,
        tag: *const [16]u8,
        plaintext: []u8,
    ) !void {
        std.debug.assert(plaintext.len >= ciphertext.len);
        std.debug.assert(key.len == 16 or key.len == 32);

        // Compute expected tag by re-encrypting with GHASH
        var ctr0: [16]u8 = [_]u8{0} ** 16;
        @memcpy(ctr0[0..12], nonce);
        ctr0[15] = 1;

        var h: [16]u8 = [_]u8{0} ** 16;
        encryptKeyBlock(key, &h, &h);

        var ghash_state: [16]u8 = [_]u8{0} ** 16;

        var aad_pos: usize = 0;
        while (aad_pos + 16 <= aad.len) : (aad_pos += 16) {
            ghashUpdate(&h, &ghash_state, aad[aad_pos..][0..16]);
        }
        if (aad_pos < aad.len) {
            var pad_block: [16]u8 = [_]u8{0} ** 16;
            @memcpy(pad_block[0 .. aad.len - aad_pos], aad[aad_pos..]);
            ghashUpdate(&h, &ghash_state, &pad_block);
        }

        var ct_pos: usize = 0;
        while (ct_pos < ciphertext.len) {
            const block_len = @min(16, ciphertext.len - ct_pos);
            if (block_len == 16) {
                ghashUpdate(&h, &ghash_state, ciphertext[ct_pos..][0..16]);
            } else {
                var pad_block: [16]u8 = [_]u8{0} ** 16;
                @memcpy(pad_block[0..block_len], ciphertext[ct_pos..][0..block_len]);
                ghashUpdate(&h, &ghash_state, &pad_block);
            }
            ct_pos += block_len;
        }

        var len_block: [16]u8 = undefined;
        const aad_bits: u64 = @intCast(aad.len * 8);
        const ct_bits: u64 = @intCast(ciphertext.len * 8);
        len_block[0] = @intCast((aad_bits >> 56) & 0xff);
        len_block[1] = @intCast((aad_bits >> 48) & 0xff);
        len_block[2] = @intCast((aad_bits >> 40) & 0xff);
        len_block[3] = @intCast((aad_bits >> 32) & 0xff);
        len_block[4] = @intCast((aad_bits >> 24) & 0xff);
        len_block[5] = @intCast((aad_bits >> 16) & 0xff);
        len_block[6] = @intCast((aad_bits >> 8) & 0xff);
        len_block[7] = @intCast(aad_bits & 0xff);
        len_block[8] = @intCast((ct_bits >> 56) & 0xff);
        len_block[9] = @intCast((ct_bits >> 48) & 0xff);
        len_block[10] = @intCast((ct_bits >> 40) & 0xff);
        len_block[11] = @intCast((ct_bits >> 32) & 0xff);
        len_block[12] = @intCast((ct_bits >> 24) & 0xff);
        len_block[13] = @intCast((ct_bits >> 16) & 0xff);
        len_block[14] = @intCast((ct_bits >> 8) & 0xff);
        len_block[15] = @intCast(ct_bits & 0xff);
        ghashUpdate(&h, &ghash_state, &len_block);

        var e_ctr0: [16]u8 = ctr0;
        encryptKeyBlock(key, &e_ctr0, &e_ctr0);
        var expected_tag: [16]u8 = undefined;
        for (0..16) |i| {
            expected_tag[i] = e_ctr0[i] ^ ghash_state[i];
        }

        // Constant-time tag comparison
        var diff: u8 = 0;
        for (0..16) |i| {
            diff |= expected_tag[i] ^ tag[i];
        }
        if (diff != 0) return error.AuthenticationFailed;

        // Decrypt
        var ctr: [16]u8 = ctr0;
        inc32(&ctr);
        var pos: usize = 0;
        while (pos < ciphertext.len) {
            var keystream: [16]u8 = ctr;
            encryptKeyBlock(key, &keystream, &keystream);
            inc32(&ctr);
            const block_len = @min(16, ciphertext.len - pos);
            for (0..block_len) |i| {
                plaintext[pos + i] = ciphertext[pos + i] ^ keystream[i];
            }
            pos += block_len;
        }
    }
};

fn encryptKeyBlock(key: []const u8, block_in: *const [16]u8, block_out: *[16]u8) void {
    if (key.len == 16) {
        const aes = Aes128.init(key[0..16]);
        aes.encrypt(block_in, block_out);
    } else {
        const aes = Aes256.init(key[0..32]);
        aes.encrypt(block_in, block_out);
    }
}
