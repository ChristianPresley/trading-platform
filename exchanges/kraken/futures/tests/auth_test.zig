// Tests for Kraken futures API authentication

const std = @import("std");
const auth_mod = @import("futures_auth");
const base64_mod = @import("base64");
const hmac_mod = @import("hmac");

test "futures sign produces 88-char base64" {
    const api_secret = "kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg==";
    var a = try auth_mod.FuturesAuth.init("futures_key", api_secret);
    var sig_buf: [88]u8 = undefined;
    const sig = a.sign("/derivatives/api/v3/sendorder", 1616492376594, "orderType=lmt&symbol=PI_XBTUSD&side=buy&size=1&limitPrice=37500", &sig_buf);
    try std.testing.expectEqual(@as(usize, 88), sig.len);
    // All chars should be valid base64
    for (sig) |c| {
        const valid = (c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z') or
            (c >= '0' and c <= '9') or c == '+' or c == '/' or c == '=';
        try std.testing.expect(valid);
    }
}

test "futures sign: different nonces produce different signatures" {
    const api_secret = "kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg==";
    var a = try auth_mod.FuturesAuth.init("key", api_secret);
    var buf1: [88]u8 = undefined;
    var buf2: [88]u8 = undefined;
    const sig1 = a.sign("/derivatives/api/v3/accounts", 1000, "", &buf1);
    const sig2 = a.sign("/derivatives/api/v3/accounts", 2000, "", &buf2);
    try std.testing.expect(!std.mem.eql(u8, sig1, sig2));
}

test "futures sign: different paths produce different signatures" {
    const api_secret = "kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg==";
    var a = try auth_mod.FuturesAuth.init("key", api_secret);
    var buf1: [88]u8 = undefined;
    var buf2: [88]u8 = undefined;
    const sig1 = a.sign("/derivatives/api/v3/accounts", 1000, "", &buf1);
    const sig2 = a.sign("/derivatives/api/v3/sendorder", 1000, "", &buf2);
    try std.testing.expect(!std.mem.eql(u8, sig1, sig2));
}

test "futures nextNonce is monotonically increasing" {
    var a = try auth_mod.FuturesAuth.init("key", "kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg==");
    const n1 = a.nextNonce();
    const n2 = a.nextNonce();
    const n3 = a.nextNonce();
    try std.testing.expect(n2 > n1);
    try std.testing.expect(n3 > n2);
}

test "futures sign: empty post data works" {
    const api_secret = "kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg==";
    var a = try auth_mod.FuturesAuth.init("key", api_secret);
    var buf: [88]u8 = undefined;
    const sig = a.sign("/derivatives/api/v3/accounts", 99999, "", &buf);
    try std.testing.expectEqual(@as(usize, 88), sig.len);
}

test "futures sign: known computation correctness" {
    // Verify the algorithm steps manually:
    // message = post_data + nonce_str + endpoint_path
    // sha256_hash = SHA256(message)
    // mac = HMAC-SHA512(base64_decode(secret), sha256_hash)
    // signature = base64(mac)
    const api_secret = "kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg==";
    const nonce: u64 = 1616492376594;
    const post_data = "";
    const endpoint_path = "/derivatives/api/v3/accounts";

    // Decode secret
    var secret_decoded: [96]u8 = undefined;
    const decoded_len = base64_mod.decodedLen(api_secret.len);
    const decoded = try base64_mod.decode(secret_decoded[0..decoded_len], api_secret);

    // Build message
    var nonce_str: [20]u8 = undefined;
    const nonce_s = try std.fmt.bufPrint(&nonce_str, "{d}", .{nonce});
    var msg_buf: [256]u8 = undefined;
    var pos: usize = 0;
    @memcpy(msg_buf[pos..][0..post_data.len], post_data);
    pos += post_data.len;
    @memcpy(msg_buf[pos..][0..nonce_s.len], nonce_s);
    pos += nonce_s.len;
    @memcpy(msg_buf[pos..][0..endpoint_path.len], endpoint_path);
    pos += endpoint_path.len;

    // SHA256
    var sha256_out: [32]u8 = undefined;
    hmac_mod.sha256(msg_buf[0..pos], &sha256_out);

    // HMAC-SHA512
    var mac: [64]u8 = undefined;
    hmac_mod.hmacSha512(decoded, &sha256_out, &mac);

    // Base64
    var sig_expected_buf: [88]u8 = undefined;
    const sig_expected = base64_mod.encode(&sig_expected_buf, &mac);

    // Now compare with auth.sign
    var a = try auth_mod.FuturesAuth.init("key", api_secret);
    var sig_buf: [88]u8 = undefined;
    const sig = a.sign(endpoint_path, nonce, post_data, &sig_buf);

    try std.testing.expectEqualSlices(u8, sig_expected, sig);
}
