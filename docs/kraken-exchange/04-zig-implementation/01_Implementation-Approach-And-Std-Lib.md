## Official Kraken Libraries

Kraken maintains **minimal official client code** (GitHub org: `payward`). Their approach is to publish thorough API documentation and rely on the community for client libraries. No official Zig client exists. No community Zig client exists for any cryptocurrency exchange.

**This project builds its own Kraken client in pure Zig, using only the Zig standard library.**

---

## Zig Standard Library Coverage

Everything needed to interact with Kraken's API is available in `std`:

| Capability | Module | Notes |
|------------|--------|-------|
| HTTPS requests | `std.http.Client` | Built-in TLS 1.3, no OpenSSL |
| HMAC-SHA512 | `std.crypto.auth.hmac.sha2.HmacSha512` | Kraken private API signing |
| SHA-256 | `std.crypto.hash.sha2.Sha256` | Kraken private API signing |
| SHA-1 | `std.crypto.hash.Sha1` | WebSocket handshake (`Sec-WebSocket-Accept`) |
| Base64 | `std.base64` | API secret decoding, signature encoding |
| JSON | `std.json` | Struct-based and dynamic parsing |
| TCP sockets | `std.net` | WebSocket transport |
| TLS | `std.crypto.tls.Client` | WSS (TLS WebSocket) |
| Random bytes | `std.crypto.random` | WebSocket frame masking keys |
| Threads | `std.Thread` | Concurrent WebSocket connections |
| CRC32 | `std.hash.crc` | Order book checksum validation |
| Timing | `std.time` | Nonce generation, reconnection backoff |

### What Must Be Built

| Component | Scope | Why |
|-----------|-------|-----|
| **WebSocket client** | ~800-1200 lines | No `std.websocket` exists. Implement RFC 6455 framing, masking, ping/pong, close handshake over TLS stream. |
| **Kraken REST wrappers** | ~500-800 lines | Typed endpoint methods around `std.http.Client` with signing. |
| **Kraken WS v2 protocol** | ~400-600 lines | Subscribe/unsubscribe, channel routing, message parsing. |
| **Order book engine** | ~300-500 lines | Snapshot + incremental updates with CRC32 validation. |
| **Rate limiter** | ~150-250 lines | Call counter + matching engine penalty system. |

---

## FIX API

Kraken offers a **FIX 4.2 protocol API** for institutional/low-latency trading.

| Attribute | Details |
|-----------|---------|
| **Protocol** | FIX 4.2 |
| **Target Audience** | Institutional traders, market makers |
| **Access** | Requires application/approval — not open to all |
| **Features** | Order entry, execution reports, market data |
| **Documentation** | Available upon approval at `docs.kraken.com/fix-api/` |
| **Latency** | Lower than REST — suitable for HFT-adjacent strategies |

### Requirements

- Verified Kraken Pro account
- Demonstrated trading volume or institutional status
- Signed FIX API agreement

A FIX 4.2 client can be implemented in pure Zig over TCP. The FIX protocol is tag-value text-based (e.g., `35=D|49=SENDER|...`), simpler to parse than most binary protocols. This would be a separate SDK module (`sdk/net/fix.zig`) if pursued.

---

## Sandbox / Test Environment

### Spot Exchange

**No public sandbox/testnet exists** for Kraken spot trading. Workarounds:

1. **`validate` parameter**: Pass `validate=true` on order REST endpoints to validate parameters without submitting.
2. **Small order sizes**: Use minimal amounts on the live exchange.
3. **Local paper trading**: Simulate order execution locally using market data feeds from the WebSocket API.

### Futures Demo Environment

Kraken **does** offer a Futures testnet:

| Attribute | Details |
|-----------|---------|
| **Web UI** | `https://demo-futures.kraken.com` |
| **API endpoint** | `https://demo-futures.kraken.com` |
| **WebSocket** | `wss://demo-futures.kraken.com/ws/v1` |
| **Features** | Full Futures trading with fake funds |
| **Signup** | Separate account registration on the demo site |

---

# Building a Kraken API Client in Pure Zig

## Design Constraint

**Zero external dependencies.** No C interop, no third-party packages, no `build.zig.zon` dependencies, no `@cImport`, no `linkSystemLibrary`. Everything is built from Zig's standard library and code in this repository.

## Feasibility Summary

| Capability | Status | Approach |
|------------|--------|----------|
| REST API (HTTPS) | Ready | `std.http.Client` (built-in TLS 1.3) |
| Authentication (HMAC-SHA512, SHA-256, Base64) | Ready | `std.crypto` + `std.base64` |
| JSON parsing/serialization | Ready | `std.json` (struct-based or dynamic) |
| WebSocket client (RFC 6455) | Build from scratch | Frame protocol over `std.net.Stream` |
| WSS (TLS WebSocket) | Build from scratch | `std.crypto.tls.Client` wrapping TCP stream |
| Concurrency | Ready | `std.Thread`, `std.posix.epoll`, `std.os.linux.IoUring` |

**Everything needed is in `std`.** The WebSocket client is the only substantial component to build — HTTP upgrade handshake, RFC 6455 framing, masking, ping/pong, close handshake, layered over TLS. This is well-scoped (~800-1200 lines for a production-quality client).

---

## std lib Coverage

### HTTP Client — `std.http.Client`

Full HTTP/1.1 client with built-in pure-Zig TLS 1.3. No OpenSSL. Used by the Zig package manager itself.

```zig
var client = std.http.Client{ .allocator = allocator };
defer client.deinit();

const uri = try std.Uri.parse("https://api.kraken.com/0/public/Ticker?pair=XBTUSD");
var req = try client.open(.GET, uri, .{
    .extra_headers = &.{
        .{ .name = "API-Key", .value = api_key },
        .{ .name = "API-Sign", .value = signature },
    },
});
defer req.deinit();
try req.send();
try req.wait();

const body = try req.reader().readAllAlloc(allocator, 1024 * 1024);
defer allocator.free(body);
```

### Cryptography — `std.crypto`

Everything for Kraken's HMAC-SHA512 request signing:

| Primitive | Module |
|-----------|--------|
| HMAC-SHA512 | `std.crypto.auth.hmac.sha2.HmacSha512` |
| HMAC-SHA256 | `std.crypto.auth.hmac.sha2.HmacSha256` |
| SHA-256 | `std.crypto.hash.sha2.Sha256` |
| SHA-512 | `std.crypto.hash.sha2.Sha512` |
| Base64 | `std.base64` |
| Random bytes | `std.crypto.random` (for WebSocket masking key) |

#### Kraken API Signing

```zig
const std = @import("std");
const HmacSha512 = std.crypto.auth.hmac.sha2.HmacSha512;
const Sha256 = std.crypto.hash.sha2.Sha256;
const base64 = std.base64.standard;

fn signRequest(
    api_secret_b64: []const u8,
    uri_path: []const u8,
    nonce: []const u8,
    post_data: []const u8,
) ![HmacSha512.mac_length]u8 {
    // 1. Decode base64 API secret
    var secret_decoded: [64]u8 = undefined;
    const decoded_len = try base64.Decoder.decode(&secret_decoded, api_secret_b64);

    // 2. SHA-256(nonce + post_data)
    var sha256_hash: [Sha256.digest_length]u8 = undefined;
    var sha = Sha256.init(.{});
    sha.update(nonce);
    sha.update(post_data);
    sha.final(&sha256_hash);

    // 3. HMAC-SHA512(decoded_secret, uri_path + sha256_hash)
    var hmac_out: [HmacSha512.mac_length]u8 = undefined;
    var hmac = HmacSha512.init(secret_decoded[0..decoded_len]);
    hmac.update(uri_path);
    hmac.update(&sha256_hash);
    hmac.final(&hmac_out);

    return hmac_out;
    // 4. Base64-encode hmac_out for the API-Sign header
}
```

### JSON — `std.json`

**Struct-based parsing (preferred)**:

```zig
const TickerData = struct {
    a: [3][]const u8, // ask [price, whole lot vol, lot vol]
    b: [3][]const u8, // bid
    c: [2][]const u8, // last trade
    v: [2][]const u8, // volume [today, 24h]
    p: [2][]const u8, // vwap
    t: [2]u64,        // trade count
    l: [2][]const u8, // low
    h: [2][]const u8, // high
    o: []const u8,    // open
};

const KrakenResponse = struct {
    @"error": []const []const u8,
    result: ?std.json.Value, // dynamic for varying pair keys
};

const parsed = try std.json.parseFromSlice(
    KrakenResponse, allocator, response_body, .{}
);
defer parsed.deinit();
```

**Dynamic parsing (for variable-key responses)**:

```zig
const parsed = try std.json.parseFromSlice(
    std.json.Value, allocator, response_body, .{}
);
defer parsed.deinit();

const result = parsed.value.object.get("result") orelse return error.NoResult;
const ticker = result.object.get("XXBTZUSD") orelse return error.NoPair;
const ask_price = ticker.object.get("a").?.array.items[0].string;
```
