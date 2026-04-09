// Kraken futures API authentication
// Different scheme from spot:
//   message = SHA256(post_data + nonce_str + endpoint_path)
//   signature = base64(HMAC-SHA512(base64_decode(secret), sha256_message))
// Headers: APIKey, Nonce, Authent

const std = @import("std");
const hmac_mod = @import("hmac");
const base64_mod = @import("base64");

pub const FuturesAuth = struct {
    api_key: []const u8,
    secret_decoded: [96]u8,
    secret_len: usize,
    nonce_counter: u64,

    pub fn init(api_key: []const u8, api_secret: []const u8) !FuturesAuth {
        var decoded: [96]u8 = undefined;
        const decoded_len = base64_mod.decodedLen(api_secret.len);
        if (decoded_len > 96) return error.SecretTooLong;
        const result = try base64_mod.decode(decoded[0..decoded_len], api_secret);
        var self = FuturesAuth{
            .api_key = api_key,
            .secret_decoded = undefined,
            .secret_len = result.len,
            .nonce_counter = 0,
        };
        @memcpy(self.secret_decoded[0..result.len], result);
        return self;
    }

    pub fn nextNonce(self: *FuturesAuth) u64 {
        const ts = blk: {
            var ts_: std.os.linux.timespec = undefined;
            _ = std.os.linux.clock_gettime(.REALTIME, &ts_);
            break :blk @as(i64, ts_.sec) * 1_000_000 + @divTrunc(@as(i64, ts_.nsec), 1_000);
        };
        const ts_u: u64 = @intCast(@max(0, ts));
        if (ts_u > self.nonce_counter) {
            self.nonce_counter = ts_u;
        } else {
            self.nonce_counter += 1;
        }
        return self.nonce_counter;
    }

    /// Compute Kraken futures signature.
    /// Algorithm:
    ///   1. nonce_str = decimal(nonce)
    ///   2. message = SHA256(post_data + nonce_str + endpoint_path)
    ///   3. mac = HMAC-SHA512(base64_decode(secret), message)
    ///   4. signature = base64(mac)
    /// out must be at least 88 bytes.
    pub fn sign(self: *FuturesAuth, endpoint_path: []const u8, nonce: u64, post_data: []const u8, out: *[88]u8) []const u8 {
        var nonce_str: [20]u8 = undefined;
        const nonce_s = std.fmt.bufPrint(&nonce_str, "{d}", .{nonce}) catch unreachable;

        // Concatenate: post_data + nonce_str + endpoint_path
        const total_len = post_data.len + nonce_s.len + endpoint_path.len;
        var sha256_out: [32]u8 = undefined;
        {
            var msg_buf: [4096]u8 = undefined;
            if (total_len <= msg_buf.len) {
                var pos: usize = 0;
                @memcpy(msg_buf[pos..][0..post_data.len], post_data);
                pos += post_data.len;
                @memcpy(msg_buf[pos..][0..nonce_s.len], nonce_s);
                pos += nonce_s.len;
                @memcpy(msg_buf[pos..][0..endpoint_path.len], endpoint_path);
                pos += endpoint_path.len;
                hmac_mod.sha256(msg_buf[0..pos], &sha256_out);
            } else {
                const buf = std.heap.page_allocator.alloc(u8, total_len) catch unreachable;
                defer std.heap.page_allocator.free(buf);
                var pos: usize = 0;
                @memcpy(buf[pos..][0..post_data.len], post_data);
                pos += post_data.len;
                @memcpy(buf[pos..][0..nonce_s.len], nonce_s);
                pos += nonce_s.len;
                @memcpy(buf[pos..][0..endpoint_path.len], endpoint_path);
                hmac_mod.sha256(buf, &sha256_out);
            }
        }

        // HMAC-SHA512(secret_decoded, sha256_out)
        var mac: [64]u8 = undefined;
        hmac_mod.hmacSha512(self.secret_decoded[0..self.secret_len], &sha256_out, &mac);

        // base64(mac)
        const encoded = base64_mod.encode(out, &mac);
        return encoded;
    }
};
