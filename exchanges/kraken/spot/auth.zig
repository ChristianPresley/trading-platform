// Kraken spot API authentication
// Signature scheme: SHA256(nonce + post_data) then HMAC-SHA512(base64_decode(secret), uri_path + sha256_hash)
// Output: base64-encoded HMAC result

const std = @import("std");
const hmac_mod = @import("hmac");
const base64_mod = @import("base64");

pub const SpotAuth = struct {
    api_key: []const u8,
    // base64-decoded secret (up to 64 bytes)
    secret_decoded: [96]u8, // up to 72 decoded bytes (96 base64 chars)
    secret_len: usize,
    nonce_counter: u64,

    /// Init with api_key and base64-encoded api_secret.
    /// Decodes the secret immediately.
    pub fn init(api_key: []const u8, api_secret: []const u8) !SpotAuth {
        var decoded: [96]u8 = undefined;
        const decoded_len = base64_mod.decodedLen(api_secret.len);
        if (decoded_len > 96) return error.SecretTooLong;
        const result = try base64_mod.decode(decoded[0..decoded_len], api_secret);
        var self = SpotAuth{
            .api_key = api_key,
            .secret_decoded = undefined,
            .secret_len = result.len,
            .nonce_counter = 0,
        };
        @memcpy(self.secret_decoded[0..result.len], result);
        return self;
    }

    /// Returns a monotonically increasing nonce based on microsecond timestamp.
    pub fn nextNonce(self: *SpotAuth) u64 {
        const ts = std.time.microTimestamp();
        const ts_u: u64 = @intCast(@max(0, ts));
        // Ensure monotonicity
        if (ts_u > self.nonce_counter) {
            self.nonce_counter = ts_u;
        } else {
            self.nonce_counter += 1;
        }
        return self.nonce_counter;
    }

    /// Compute the Kraken API signature.
    /// Algorithm:
    ///   1. nonce_str = decimal string of nonce
    ///   2. message = nonce_str + post_data
    ///   3. hash = SHA256(message)   [32 bytes]
    ///   4. hmac_input = uri_path (bytes) + hash (32 bytes)
    ///   5. mac = HMAC-SHA512(base64_decode(secret), hmac_input)
    ///   6. signature = base64(mac)  [88 chars]
    /// out must be at least 88 bytes.
    pub fn sign(self: *SpotAuth, uri_path: []const u8, nonce: u64, post_data: []const u8, out: *[88]u8) []const u8 {
        // Step 1+2: nonce_str + post_data
        var nonce_str: [20]u8 = undefined;
        const nonce_s = std.fmt.bufPrint(&nonce_str, "{d}", .{nonce}) catch unreachable;

        // Step 3: SHA256(nonce_str + post_data)
        var sha256_out: [32]u8 = undefined;
        {
            // Concatenate nonce_str and post_data into a buffer
            var msg_buf: [4096]u8 = undefined;
            const total = nonce_s.len + post_data.len;
            if (total <= msg_buf.len) {
                @memcpy(msg_buf[0..nonce_s.len], nonce_s);
                @memcpy(msg_buf[nonce_s.len..][0..post_data.len], post_data);
                hmac_mod.sha256(msg_buf[0..total], &sha256_out);
            } else {
                // Fallback: allocate
                const buf = std.heap.page_allocator.alloc(u8, total) catch unreachable;
                defer std.heap.page_allocator.free(buf);
                @memcpy(buf[0..nonce_s.len], nonce_s);
                @memcpy(buf[nonce_s.len..], post_data);
                hmac_mod.sha256(buf, &sha256_out);
            }
        }

        // Step 4: hmac_input = uri_path + sha256_out
        var hmac_input_buf: [512]u8 = undefined;
        const hmac_input_len = uri_path.len + 32;
        var hmac_input: []const u8 = undefined;
        if (hmac_input_len <= hmac_input_buf.len) {
            @memcpy(hmac_input_buf[0..uri_path.len], uri_path);
            @memcpy(hmac_input_buf[uri_path.len..][0..32], &sha256_out);
            hmac_input = hmac_input_buf[0..hmac_input_len];
        } else {
            const tmp = std.heap.page_allocator.alloc(u8, hmac_input_len) catch unreachable;
            defer std.heap.page_allocator.free(tmp);
            @memcpy(tmp[0..uri_path.len], uri_path);
            @memcpy(tmp[uri_path.len..], &sha256_out);
            hmac_input = tmp;
        }

        // Step 5: HMAC-SHA512(secret_decoded, hmac_input)
        var mac: [64]u8 = undefined;
        hmac_mod.hmacSha512(self.secret_decoded[0..self.secret_len], hmac_input, &mac);

        // Step 6: base64(mac) = 88 chars
        const encoded = base64_mod.encode(out, &mac);
        return encoded;
    }
};

/// Standalone nonce function for use without an auth instance.
pub fn nextNonce() u64 {
    const ts = std.time.microTimestamp();
    return @intCast(@max(0, ts));
}
