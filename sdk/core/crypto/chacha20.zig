const std = @import("std");

fn quarterRound(a: *u32, b: *u32, c: *u32, d: *u32) void {
    a.* +%= b.*;
    d.* ^= a.*;
    d.* = std.math.rotl(u32, d.*, 16);
    c.* +%= d.*;
    b.* ^= c.*;
    b.* = std.math.rotl(u32, b.*, 12);
    a.* +%= b.*;
    d.* ^= a.*;
    d.* = std.math.rotl(u32, d.*, 8);
    c.* +%= d.*;
    b.* ^= c.*;
    b.* = std.math.rotl(u32, b.*, 7);
}

fn chacha20Block(key: *const [32]u8, counter: u32, nonce: *const [12]u8, out: *[64]u8) void {
    var state: [16]u32 = undefined;
    // Constants "expa nd 32-byte k"
    state[0] = 0x61707865;
    state[1] = 0x3320646e;
    state[2] = 0x79622d32;
    state[3] = 0x6b206574;
    // Key (8 u32 words, little-endian)
    for (0..8) |i| {
        state[4 + i] = std.mem.readInt(u32, key[i * 4 ..][0..4], .little);
    }
    state[12] = counter;
    // Nonce (3 u32 words, little-endian)
    for (0..3) |i| {
        state[13 + i] = std.mem.readInt(u32, nonce[i * 4 ..][0..4], .little);
    }

    var working: [16]u32 = state;
    for (0..10) |_| {
        // Column rounds
        quarterRound(&working[0], &working[4], &working[8], &working[12]);
        quarterRound(&working[1], &working[5], &working[9], &working[13]);
        quarterRound(&working[2], &working[6], &working[10], &working[14]);
        quarterRound(&working[3], &working[7], &working[11], &working[15]);
        // Diagonal rounds
        quarterRound(&working[0], &working[5], &working[10], &working[15]);
        quarterRound(&working[1], &working[6], &working[11], &working[12]);
        quarterRound(&working[2], &working[7], &working[8], &working[13]);
        quarterRound(&working[3], &working[4], &working[9], &working[14]);
    }
    for (0..16) |i| {
        working[i] +%= state[i];
        std.mem.writeInt(u32, out[i * 4 ..][0..4], working[i], .little);
    }
}

// Poly1305 MAC
const Poly1305 = struct {
    r: [5]u64,
    s: [4]u32,
    h: [5]u64,

    fn init(key: *const [32]u8) Poly1305 {
        var self: Poly1305 = undefined;
        // r = key[0..16] clamped
        const r0 = std.mem.readInt(u32, key[0..4], .little);
        const r1 = std.mem.readInt(u32, key[4..8], .little);
        const r2 = std.mem.readInt(u32, key[8..12], .little);
        const r3 = std.mem.readInt(u32, key[12..16], .little);
        // Clamp
        self.r[0] = r0 & 0x3ffffff;
        self.r[1] = (((@as(u64, r1) << 32) | r0) >> 26) & 0x3ffff03;
        self.r[2] = (((@as(u64, r2) << 32) | r1) >> 20) & 0x3ffc0ff;
        self.r[3] = (((@as(u64, r3) << 32) | r2) >> 14) & 0x3f03fff;
        self.r[4] = (r3 >> 8) & 0x00fffff;

        self.s[0] = std.mem.readInt(u32, key[16..20], .little);
        self.s[1] = std.mem.readInt(u32, key[20..24], .little);
        self.s[2] = std.mem.readInt(u32, key[24..28], .little);
        self.s[3] = std.mem.readInt(u32, key[28..32], .little);
        self.h = [_]u64{0} ** 5;
        return self;
    }

    fn processBlock(self: *Poly1305, block: []const u8, final: bool) void {
        var n: [5]u64 = undefined;
        const hibit: u64 = if (final) 0 else (1 << 24);

        // Read block as little-endian integer with hi bit set
        var tmp: [17]u8 = [_]u8{0} ** 17;
        @memcpy(tmp[0..block.len], block);
        if (!final) tmp[block.len] = 1;

        n[0] = (std.mem.readInt(u32, tmp[0..4], .little)) & 0x3ffffff;
        n[1] = ((std.mem.readInt(u64, tmp[3..11], .little) >> 2)) & 0x3ffffff;
        n[2] = ((std.mem.readInt(u64, tmp[6..14], .little) >> 4)) & 0x3ffffff;
        n[3] = ((std.mem.readInt(u64, tmp[9..17], .little) >> 6)) & 0x3ffffff;
        n[4] = ((std.mem.readInt(u32, tmp[12..16], .little) >> 0) >> 8) | hibit;

        // h += n
        for (0..5) |i| {
            self.h[i] += n[i];
        }

        // h *= r
        const r0 = self.r[0];
        const r1 = self.r[1];
        const r2 = self.r[2];
        const r3 = self.r[3];
        const r4 = self.r[4];

        const h0 = self.h[0];
        const h1 = self.h[1];
        const h2 = self.h[2];
        const h3 = self.h[3];
        const h4 = self.h[4];

        const d0 = h0 * r0 + h1 * (5 * r4) + h2 * (5 * r3) + h3 * (5 * r2) + h4 * (5 * r1);
        const d1 = h0 * r1 + h1 * r0 + h2 * (5 * r4) + h3 * (5 * r3) + h4 * (5 * r2);
        const d2 = h0 * r2 + h1 * r1 + h2 * r0 + h3 * (5 * r4) + h4 * (5 * r3);
        const d3 = h0 * r3 + h1 * r2 + h2 * r1 + h3 * r0 + h4 * (5 * r4);
        const d4 = h0 * r4 + h1 * r3 + h2 * r2 + h3 * r1 + h4 * r0;

        // Partial reduce
        var hh0 = d0 & 0x3ffffff;
        var hh1 = d1 + (d0 >> 26);
        var hh2 = d2 + (hh1 >> 26);
        hh1 &= 0x3ffffff;
        var hh3 = d3 + (hh2 >> 26);
        hh2 &= 0x3ffffff;
        var hh4 = d4 + (hh3 >> 26);
        hh3 &= 0x3ffffff;
        hh0 += (hh4 >> 26) * 5;
        hh4 &= 0x3ffffff;
        hh1 += hh0 >> 26;
        hh0 &= 0x3ffffff;

        self.h = .{ hh0, hh1, hh2, hh3, hh4 };
    }

    fn finalize(self: *Poly1305, tag: *[16]u8) void {
        // Fully reduce h mod 2^130-5
        var h0 = self.h[0];
        var h1 = self.h[1];
        var h2 = self.h[2];
        var h3 = self.h[3];
        var h4 = self.h[4];

        h2 += h1 >> 26;
        h1 &= 0x3ffffff;
        h3 += h2 >> 26;
        h2 &= 0x3ffffff;
        h4 += h3 >> 26;
        h3 &= 0x3ffffff;
        h0 += (h4 >> 26) * 5;
        h4 &= 0x3ffffff;
        h1 += h0 >> 26;
        h0 &= 0x3ffffff;

        // Compute h + -p = h - (2^130 - 5)
        var g0 = h0 + 5;
        var g1 = h1 + (g0 >> 26);
        g0 &= 0x3ffffff;
        var g2 = h2 + (g1 >> 26);
        g1 &= 0x3ffffff;
        var g3 = h3 + (g2 >> 26);
        g2 &= 0x3ffffff;
        const g4 = h4 + (g3 >> 26);
        g3 &= 0x3ffffff;
        // Select h if h < p, else h - p
        const mask: u64 = if ((g4 >> 26) != 0) 0xffffffffffffffff else 0;
        h0 = (h0 & ~mask) | (g0 & mask);
        h1 = (h1 & ~mask) | (g1 & mask);
        h2 = (h2 & ~mask) | (g2 & mask);
        h3 = (h3 & ~mask) | (g3 & mask);
        h4 = (h4 & ~mask) | (g4 & mask);

        // Convert from 26-bit limbs to u128
        const h_full: u128 = h0 | (@as(u128, h1) << 26) | (@as(u128, h2) << 52) | (@as(u128, h3) << 78) | (@as(u128, h4) << 104);

        // Add s
        const s_full: u128 = @as(u128, self.s[0]) |
            (@as(u128, self.s[1]) << 32) |
            (@as(u128, self.s[2]) << 64) |
            (@as(u128, self.s[3]) << 96);

        const t = h_full +% s_full;
        std.mem.writeInt(u128, tag, t, .little);
    }
};

pub const ChaCha20Poly1305 = struct {
    pub fn encrypt(
        key: *const [32]u8,
        nonce: *const [12]u8,
        plaintext: []const u8,
        aad: []const u8,
        ciphertext: []u8,
        tag: *[16]u8,
    ) void {
        std.debug.assert(ciphertext.len >= plaintext.len);
        // Generate Poly1305 key from block 0
        var poly_key: [64]u8 = undefined;
        chacha20Block(key, 0, nonce, &poly_key);

        // Encrypt plaintext starting from counter=1
        var counter: u32 = 1;
        var pos: usize = 0;
        while (pos < plaintext.len) {
            var block: [64]u8 = undefined;
            chacha20Block(key, counter, nonce, &block);
            counter += 1;
            const len = @min(64, plaintext.len - pos);
            for (0..len) |i| {
                ciphertext[pos + i] = plaintext[pos + i] ^ block[i];
            }
            pos += len;
        }

        // Compute Poly1305 MAC over: aad || pad(aad) || ciphertext || pad(ct) || len(aad) || len(ct)
        computeTag(&poly_key, aad, ciphertext[0..plaintext.len], tag);
    }

    pub fn decrypt(
        key: *const [32]u8,
        nonce: *const [12]u8,
        ciphertext: []const u8,
        aad: []const u8,
        tag: *const [16]u8,
        plaintext: []u8,
    ) !void {
        std.debug.assert(plaintext.len >= ciphertext.len);
        // Generate Poly1305 key
        var poly_key: [64]u8 = undefined;
        chacha20Block(key, 0, nonce, &poly_key);

        // Verify tag
        var expected_tag: [16]u8 = undefined;
        computeTag(&poly_key, aad, ciphertext, &expected_tag);

        var diff: u8 = 0;
        for (0..16) |i| {
            diff |= expected_tag[i] ^ tag[i];
        }
        if (diff != 0) return error.AuthenticationFailed;

        // Decrypt
        var counter: u32 = 1;
        var pos: usize = 0;
        while (pos < ciphertext.len) {
            var block: [64]u8 = undefined;
            chacha20Block(key, counter, nonce, &block);
            counter += 1;
            const len = @min(64, ciphertext.len - pos);
            for (0..len) |i| {
                plaintext[pos + i] = ciphertext[pos + i] ^ block[i];
            }
            pos += len;
        }
    }

    fn computeTag(poly_key: *const [64]u8, aad: []const u8, ct: []const u8, tag: *[16]u8) void {
        var mac = Poly1305.init(poly_key[0..32]);
        computeMac(&mac, aad, ct, tag);
    }

    fn computeMac(mac: *Poly1305, aad: []const u8, ct: []const u8, tag: *[16]u8) void {
        // Process AAD
        var pos: usize = 0;
        while (pos + 16 <= aad.len) : (pos += 16) {
            mac.processBlock(aad[pos..][0..16], false);
        }
        if (pos < aad.len) {
            mac.processBlock(aad[pos..], false);
        }
        // Pad AAD to 16 bytes
        const aad_pad = (16 - aad.len % 16) % 16;
        if (aad_pad > 0) {
            var zero_pad = [_]u8{0} ** 16;
            mac.processBlock(zero_pad[0..aad_pad], false);
        }

        // Process ciphertext
        pos = 0;
        while (pos + 16 <= ct.len) : (pos += 16) {
            mac.processBlock(ct[pos..][0..16], false);
        }
        if (pos < ct.len) {
            mac.processBlock(ct[pos..], false);
        }
        // Pad CT
        const ct_pad = (16 - ct.len % 16) % 16;
        if (ct_pad > 0) {
            var zero_pad = [_]u8{0} ** 16;
            mac.processBlock(zero_pad[0..ct_pad], false);
        }

        // Lengths as u64 LE
        var len_block: [16]u8 = undefined;
        std.mem.writeInt(u64, len_block[0..8], @intCast(aad.len), .little);
        std.mem.writeInt(u64, len_block[8..16], @intCast(ct.len), .little);
        mac.processBlock(&len_block, false);

        mac.finalize(tag);
    }
};
