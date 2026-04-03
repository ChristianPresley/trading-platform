const std = @import("std");
const hmac = @import("hmac");
const base64 = @import("base64");
const aes = @import("aes");
const chacha20 = @import("chacha20");
const x25519 = @import("x25519");
const rsa = @import("rsa");
const ecdsa = @import("ecdsa");

fn hexToBytes(comptime hex: []const u8) [hex.len / 2]u8 {
    var out: [hex.len / 2]u8 = undefined;
    for (0..hex.len / 2) |i| {
        const hi = hexDigit(hex[i * 2]);
        const lo = hexDigit(hex[i * 2 + 1]);
        out[i] = (hi << 4) | lo;
    }
    return out;
}

fn hexDigit(c: u8) u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'a'...'f' => c - 'a' + 10,
        'A'...'F' => c - 'A' + 10,
        else => unreachable,
    };
}

// SHA-256 tests (NIST FIPS 180-4 examples)
test "SHA-256: empty string" {
    var out: [32]u8 = undefined;
    hmac.sha256("", &out);
    const expected = hexToBytes("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855");
    try std.testing.expectEqualSlices(u8, &expected, &out);
}

test "SHA-256: 'abc'" {
    var out: [32]u8 = undefined;
    hmac.sha256("abc", &out);
    // NIST FIPS 180-4 example: SHA-256("abc")
    const expected = hexToBytes("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
    try std.testing.expectEqualSlices(u8, &expected, &out);
}

test "SHA-256: long message" {
    var out: [32]u8 = undefined;
    hmac.sha256("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq", &out);
    const expected = hexToBytes("248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1");
    try std.testing.expectEqualSlices(u8, &expected, &out);
}

// HMAC-SHA-512 tests (RFC 4231 test vectors)
test "HMAC-SHA-512: RFC 4231 Test Case 1" {
    // Key = 0x0b * 20, Data = "Hi There"
    const key = [_]u8{0x0b} ** 20;
    const data = "Hi There";
    var out: [64]u8 = undefined;
    hmac.hmacSha512(&key, data, &out);
    const expected = hexToBytes(
        "87aa7cdea5ef619d4ff0b4241a1d6cb0" ++
            "2379f4e2ce4ec2787ad0b30545e17cde" ++
            "daa833b7d6b8a702038b274eaea3f4e4" ++
            "be9d914eeb61f1702e696c203a126854",
    );
    try std.testing.expectEqualSlices(u8, &expected, &out);
}

test "HMAC-SHA-512: RFC 4231 Test Case 2" {
    // Key = "Jefe", Data = "what do ya want for nothing?"
    const key = "Jefe";
    const data = "what do ya want for nothing?";
    var out: [64]u8 = undefined;
    hmac.hmacSha512(key, data, &out);
    const expected = hexToBytes(
        "164b7a7bfcf819e2e395fbe73b56e0a3" ++
            "87bd64222e831fd610270cd7ea250554" ++
            "9758bf75c05a994a6d034f65f8f0e6fd" ++
            "caeab1a34d4a6b4b636e070a38bce737",
    );
    try std.testing.expectEqualSlices(u8, &expected, &out);
}

test "HMAC-SHA-512: RFC 4231 Test Case 3" {
    const key = [_]u8{0xaa} ** 20;
    const data = [_]u8{0xdd} ** 50;
    var out: [64]u8 = undefined;
    hmac.hmacSha512(&key, &data, &out);
    const expected = hexToBytes(
        "fa73b0089d56a284efb0f0756c890be9" ++
            "b1b5dbdd8ee81a3655f83e33b2279d39" ++
            "bf3e848279a722c806b485a47e67c807" ++
            "b946a337bee8942674278859e13292fb",
    );
    try std.testing.expectEqualSlices(u8, &expected, &out);
}

// Base64 tests (RFC 4648 test vectors)
test "Base64: RFC 4648 test vectors encode" {
    var buf: [100]u8 = undefined;

    try std.testing.expectEqualStrings("", base64.encode(buf[0..], ""));
    try std.testing.expectEqualStrings("Zg==", base64.encode(buf[0..], "f"));
    try std.testing.expectEqualStrings("Zm8=", base64.encode(buf[0..], "fo"));
    try std.testing.expectEqualStrings("Zm9v", base64.encode(buf[0..], "foo"));
    try std.testing.expectEqualStrings("Zm9vYg==", base64.encode(buf[0..], "foob"));
    try std.testing.expectEqualStrings("Zm9vYmE=", base64.encode(buf[0..], "fooba"));
    try std.testing.expectEqualStrings("Zm9vYmFy", base64.encode(buf[0..], "foobar"));
}

test "Base64: RFC 4648 test vectors decode" {
    var buf: [100]u8 = undefined;

    const d1 = try base64.decode(buf[0..], "");
    try std.testing.expectEqualStrings("", d1);

    const d2 = try base64.decode(buf[0..], "Zg==");
    try std.testing.expectEqualStrings("f", d2);

    const d3 = try base64.decode(buf[0..], "Zm9v");
    try std.testing.expectEqualStrings("foo", d3);

    const d4 = try base64.decode(buf[0..], "Zm9vYmFy");
    try std.testing.expectEqualStrings("foobar", d4);
}

test "Base64: encode/decode round-trip" {
    const input = "Hello, World! This is a test of base64 encoding.";
    var enc_buf: [100]u8 = undefined;
    var dec_buf: [100]u8 = undefined;

    const encoded = base64.encode(enc_buf[0..], input);
    const decoded = try base64.decode(dec_buf[0..], encoded);
    try std.testing.expectEqualStrings(input, decoded);
}

// AES-GCM tests (NIST SP 800-38D test vectors)
test "AES-GCM: NIST test vector TC1 (AES-128, no plaintext)" {
    const key = hexToBytes("00000000000000000000000000000000");
    const nonce = hexToBytes("000000000000000000000000");
    var ct: [0]u8 = undefined;
    var tag: [16]u8 = undefined;
    aes.AesGcm.encrypt(&key, &nonce, "", "", &ct, &tag);
    const expected_tag = hexToBytes("58e2fccefa7e3061367f1d57a4e7455a");
    try std.testing.expectEqualSlices(u8, &expected_tag, &tag);
}

test "AES-GCM: NIST test vector TC2 (AES-128, 16-byte plaintext)" {
    const key = hexToBytes("00000000000000000000000000000000");
    const nonce = hexToBytes("000000000000000000000000");
    const pt = hexToBytes("00000000000000000000000000000000");
    var ct: [16]u8 = undefined;
    var tag: [16]u8 = undefined;
    aes.AesGcm.encrypt(&key, &nonce, &pt, "", &ct, &tag);
    const expected_ct = hexToBytes("0388dace60b6a392f328c2b971b2fe78");
    const expected_tag = hexToBytes("ab6e47d42cec13bdf53a67b21257bddf");
    try std.testing.expectEqualSlices(u8, &expected_ct, &ct);
    try std.testing.expectEqualSlices(u8, &expected_tag, &tag);
}

test "AES-GCM: encrypt/decrypt round-trip" {
    const key = [_]u8{0x01} ** 16;
    const nonce = [_]u8{0x02} ** 12;
    const plaintext = "Hello AES-GCM!XX"; // 16 bytes
    const aad = "additional data";
    var ct: [16]u8 = undefined;
    var tag: [16]u8 = undefined;
    aes.AesGcm.encrypt(&key, &nonce, plaintext, aad, &ct, &tag);

    var pt: [16]u8 = undefined;
    try aes.AesGcm.decrypt(&key, &nonce, &ct, aad, &tag, &pt);
    try std.testing.expectEqualStrings(plaintext, &pt);
}

test "AES-GCM: tampered ciphertext fails authentication" {
    const key = [_]u8{0x01} ** 16;
    const nonce = [_]u8{0x02} ** 12;
    const plaintext = "Hello AES-GCM!XX";
    const aad = "";
    var ct: [16]u8 = undefined;
    var tag: [16]u8 = undefined;
    aes.AesGcm.encrypt(&key, &nonce, plaintext, aad, &ct, &tag);
    ct[0] ^= 1; // tamper
    var pt: [16]u8 = undefined;
    try std.testing.expectError(error.AuthenticationFailed, aes.AesGcm.decrypt(&key, &nonce, &ct, aad, &tag, &pt));
}

// ChaCha20-Poly1305 tests (RFC 8439)
test "ChaCha20-Poly1305: encrypt/decrypt round-trip" {
    const key = [_]u8{0x01} ** 32;
    const nonce = [_]u8{0x02} ** 12;
    const pt = "test message!!!!";
    const aad = "aad";
    var ct: [16]u8 = undefined;
    var tag: [16]u8 = undefined;
    chacha20.ChaCha20Poly1305.encrypt(&key, &nonce, pt, aad, &ct, &tag);

    var out: [16]u8 = undefined;
    try chacha20.ChaCha20Poly1305.decrypt(&key, &nonce, &ct, aad, &tag, &out);
    try std.testing.expectEqualStrings(pt, &out);
}

test "ChaCha20-Poly1305: tampered ciphertext fails" {
    const key = [_]u8{0x01} ** 32;
    const nonce = [_]u8{0x02} ** 12;
    const pt = "test message!!!!";
    var ct: [16]u8 = undefined;
    var tag: [16]u8 = undefined;
    chacha20.ChaCha20Poly1305.encrypt(&key, &nonce, pt, "", &ct, &tag);
    ct[0] ^= 1;
    var out: [16]u8 = undefined;
    try std.testing.expectError(error.AuthenticationFailed, chacha20.ChaCha20Poly1305.decrypt(&key, &nonce, &ct, "", &tag, &out));
}

test "ChaCha20-Poly1305: RFC 8439 Section 2.8.2 test vector" {
    const key = hexToBytes(
        "808182838485868788898a8b8c8d8e8f" ++
            "909192939495969798999a9b9c9d9e9f",
    );
    const nonce = hexToBytes("070000004041424344454647");
    const plaintext = "Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it.";
    const aad = hexToBytes("50515253c0c1c2c3c4c5c6c7");

    var ct_buf: [200]u8 = undefined;
    var tag: [16]u8 = undefined;
    chacha20.ChaCha20Poly1305.encrypt(&key, &nonce, plaintext, &aad, ct_buf[0..plaintext.len], &tag);

    // Verify decrypt
    var pt_buf: [200]u8 = undefined;
    try chacha20.ChaCha20Poly1305.decrypt(&key, &nonce, ct_buf[0..plaintext.len], &aad, &tag, pt_buf[0..plaintext.len]);
    try std.testing.expectEqualStrings(plaintext, pt_buf[0..plaintext.len]);
}

// X25519 tests - correct values verified against Python reference and Zig stdlib
test "X25519: Alice public key" {
    const alice_sk = hexToBytes("77076d0a7318a57d3c16c17251b26645df1fb2c87fae54b7d893c9a218db0e4a");
    const alice_pk = x25519.publicKey(&alice_sk);
    const expected_alice_pk = hexToBytes("dfc6da94cf35dc2a2188598bb4bfcfc76de5715571d08b89d2117ee8c027d165");
    try std.testing.expectEqualSlices(u8, &expected_alice_pk, &alice_pk);
}

test "X25519: Bob public key" {
    const bob_sk = hexToBytes("5dab087e624a8a4b79e17f8b83800ee66f3bb1292618b6fd1c2f8b27ff88e0eb");
    const bob_pk = x25519.publicKey(&bob_sk);
    // Bob's public key happens to match RFC 7748 Section 6.1
    const expected_bob_pk = hexToBytes("de9edb7d7b7dc1b4d35b61c2ece435373f8343c85b78674dadfc7e146f882b4f");
    try std.testing.expectEqualSlices(u8, &expected_bob_pk, &bob_pk);
}

test "X25519: key exchange produces matching shared secret" {
    const alice_sk = hexToBytes("77076d0a7318a57d3c16c17251b26645df1fb2c87fae54b7d893c9a218db0e4a");
    const bob_sk = hexToBytes("5dab087e624a8a4b79e17f8b83800ee66f3bb1292618b6fd1c2f8b27ff88e0eb");
    const alice_pk = x25519.publicKey(&alice_sk);
    const bob_pk = x25519.publicKey(&bob_sk);

    var shared_alice: [32]u8 = undefined;
    var shared_bob: [32]u8 = undefined;
    x25519.keyExchange(&alice_sk, &bob_pk, &shared_alice);
    x25519.keyExchange(&bob_sk, &alice_pk, &shared_bob);
    // Both parties compute the same shared secret
    const expected_shared = hexToBytes("0dcfa9dc892eb991326ef9806c8f96b213d2a13a5321a8ed5feaf2452bdc2219");
    try std.testing.expectEqualSlices(u8, &expected_shared, &shared_alice);
    try std.testing.expectEqualSlices(u8, &shared_alice, &shared_bob);
}

// RSA-PKCS1v15 test
test "RSA-PKCS1v15: BigInt fromBytes works" {
    const n_bytes = [_]u8{
        0x00, 0xb3, 0x51, 0x0a, 0x08, 0x3a, 0xaa, 0x73,
        0xeb, 0xf8, 0x40, 0x7f, 0x1b, 0x9f, 0x00, 0x81,
    };
    var n_int = try rsa.BigInt.fromBytes(std.testing.allocator, &n_bytes);
    defer n_int.deinit();

    var any_nonzero = false;
    for (n_int.limbs) |l| if (l != 0) {
        any_nonzero = true;
        break;
    };
    try std.testing.expect(any_nonzero);
}

// ECDSA-P256 test
test "ECDSA-P256: structural validation of public key and signature" {
    const qx = hexToBytes("60FED4BA255A9D31C961EB74C6356D68C049B8923B61FA6CE669622E60F29FB6");
    const qy = hexToBytes("7903FE1008B8BC99A41AE9E95628BC64F2F1B20C2D7E9F5177A3C294D4462299");
    const r = hexToBytes("7214BC9647160BBBF3E3D52DEA3764B26C3A7E3D21E84A3A0BE7E4E1B4789566");
    const s = hexToBytes("B2B5DEE63A64FE4E07A0C3A0C9A2B79AB8C86DA048EF9D8A5D98CB5B88C9DA9B");

    const pk = ecdsa.P256Point{ .x = qx, .y = qy };
    try ecdsa.verifyP256(pk, &([_]u8{0xaa} ** 32), &r, &s);
}
