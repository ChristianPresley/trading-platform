// Tests for Kraken spot API authentication
// Verifies HMAC-SHA512 signature computation.

const std = @import("std");
const auth_mod = @import("spot_auth");
const base64_mod = @import("base64");
const hmac_mod = @import("hmac");

// Verify the sign function produces a consistent, deterministic output
// by computing the expected value from scratch using the same primitives.
test "sign is deterministic and matches manual computation" {
    const api_secret = "kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg==";
    const api_key = "EXkbIqs-1AxnoIG0e3WT3Uh5a14WrA7EvYvE8Wt6ZB5j7DU93k0Qa4FuRm7Vw";
    const nonce: u64 = 1616492376594;
    const post_data = "nonce=1616492376594&ordertype=limit&pair=XBTUSD&price=37500&type=buy&volume=1.25";
    const uri_path = "/0/private/AddOrder";

    // Manual computation step-by-step
    // 1. Decode secret
    var secret_decoded: [96]u8 = undefined;
    const decoded_len = base64_mod.decodedLen(api_secret.len);
    const decoded_secret = try base64_mod.decode(secret_decoded[0..decoded_len], api_secret);

    // 2. nonce_str = "1616492376594"
    var nonce_str: [20]u8 = undefined;
    const nonce_s = try std.fmt.bufPrint(&nonce_str, "{d}", .{nonce});

    // 3. SHA256(nonce_str + post_data)
    var msg_buf: [512]u8 = undefined;
    @memcpy(msg_buf[0..nonce_s.len], nonce_s);
    @memcpy(msg_buf[nonce_s.len..][0..post_data.len], post_data);
    var sha256_out: [32]u8 = undefined;
    hmac_mod.sha256(msg_buf[0 .. nonce_s.len + post_data.len], &sha256_out);

    // 4. HMAC-SHA512(decoded_secret, uri_path + sha256_out)
    var hmac_input: [256]u8 = undefined;
    @memcpy(hmac_input[0..uri_path.len], uri_path);
    @memcpy(hmac_input[uri_path.len..][0..32], &sha256_out);
    var mac: [64]u8 = undefined;
    hmac_mod.hmacSha512(decoded_secret, hmac_input[0 .. uri_path.len + 32], &mac);

    // 5. base64(mac)
    var sig_expected_buf: [88]u8 = undefined;
    const sig_expected = base64_mod.encode(&sig_expected_buf, &mac);

    // Now verify auth.sign produces the same result
    var a = try auth_mod.SpotAuth.init(api_key, api_secret);
    var sig_buf: [88]u8 = undefined;
    const sig = a.sign(uri_path, nonce, post_data, &sig_buf);

    try std.testing.expectEqualSlices(u8, sig_expected, sig);
}

test "sign output is 88 bytes of valid base64" {
    var a = try auth_mod.SpotAuth.init("key", "kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg==");
    var sig_buf: [88]u8 = undefined;
    const sig = a.sign("/0/private/AddOrder", 1616492376594, "nonce=1616492376594&ordertype=limit&pair=XBTUSD", &sig_buf);
    // base64 of 64-byte HMAC = 88 chars
    try std.testing.expectEqual(@as(usize, 88), sig.len);
    // All chars should be valid base64
    for (sig) |c| {
        const valid = (c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z') or
            (c >= '0' and c <= '9') or c == '+' or c == '/' or c == '=';
        try std.testing.expect(valid);
    }
}

test "nextNonce is monotonically increasing" {
    var a = try auth_mod.SpotAuth.init("key", "kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg==");
    const n1 = a.nextNonce();
    const n2 = a.nextNonce();
    const n3 = a.nextNonce();
    try std.testing.expect(n2 > n1);
    try std.testing.expect(n3 > n2);
}

test "different nonces produce different signatures" {
    var a = try auth_mod.SpotAuth.init("key", "kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg==");
    var sig_buf1: [88]u8 = undefined;
    var sig_buf2: [88]u8 = undefined;
    const sig1 = a.sign("/0/private/Balance", 1000, "nonce=1000", &sig_buf1);
    const sig2 = a.sign("/0/private/Balance", 2000, "nonce=2000", &sig_buf2);
    try std.testing.expect(!std.mem.eql(u8, sig1, sig2));
}

test "sign: empty post_data" {
    var a = try auth_mod.SpotAuth.init("key", "kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg==");
    var sig_buf: [88]u8 = undefined;
    const sig = a.sign("/0/private/Balance", 99999, "", &sig_buf);
    try std.testing.expectEqual(@as(usize, 88), sig.len);
}

test "different paths produce different signatures" {
    var a = try auth_mod.SpotAuth.init("key", "kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg==");
    var buf1: [88]u8 = undefined;
    var buf2: [88]u8 = undefined;
    const sig1 = a.sign("/0/private/Balance", 1000, "nonce=1000", &buf1);
    const sig2 = a.sign("/0/private/AddOrder", 1000, "nonce=1000", &buf2);
    try std.testing.expect(!std.mem.eql(u8, sig1, sig2));
}
