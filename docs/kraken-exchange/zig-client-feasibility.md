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

---

## WebSocket Client — Pure Zig Implementation

This is the one component that must be built from scratch. The scope is well-defined by RFC 6455.

### Architecture

```
┌──────────────────────────────────────┐
│         WebSocket Client             │
│                                      │
│  ┌────────────┐   ┌──────────────┐   │
│  │  Handshake │   │   Framing    │   │
│  │  (HTTP     │   │  (RFC 6455)  │   │
│  │   Upgrade) │   │              │   │
│  └─────┬──────┘   └──────┬───────┘   │
│        │                 │           │
│  ┌─────▼─────────────────▼───────┐   │
│  │     TLS Stream                │   │
│  │  (std.crypto.tls.Client)      │   │
│  └─────────────┬─────────────────┘   │
│                │                     │
│  ┌─────────────▼─────────────────┐   │
│  │     TCP Stream                │   │
│  │  (std.net.Stream)             │   │
│  └───────────────────────────────┘   │
└──────────────────────────────────────┘
```

### What RFC 6455 Requires

#### 1. Opening Handshake (HTTP Upgrade)

Client sends an HTTP/1.1 upgrade request over the TLS stream:

```
GET /v2 HTTP/1.1
Host: ws.kraken.com
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
Sec-WebSocket-Version: 13
```

Server responds with `101 Switching Protocols`. After this, the connection switches to the WebSocket binary framing protocol. The `Sec-WebSocket-Key` is 16 random bytes, base64-encoded. The server's `Sec-WebSocket-Accept` must equal `SHA-1(key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")` base64-encoded — `std.crypto.hash.Sha1` covers this.

#### 2. Frame Format

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-------+-+-------------+-------------------------------+
|F|R|R|R| opcode|M| Payload len |    Extended payload length    |
|I|S|S|S|  (4)  |A|     (7)     |           (16/64)             |
|N|V|V|V|       |S|             |   (if payload len==126/127)   |
| |1|2|3|       |K|             |                               |
+-+-+-+-+-------+-+-------------+-------------------------------+
|                   Masking-key (if MASK set)                    |
+-------------------------------+-------------------------------+
|                        Payload Data                           |
+---------------------------------------------------------------+
```

**Opcodes**:

| Opcode | Meaning |
|--------|---------|
| `0x1` | Text frame (Kraken sends JSON as text) |
| `0x2` | Binary frame |
| `0x8` | Close |
| `0x9` | Ping |
| `0xA` | Pong |

**Client frames must be masked** (4-byte random masking key, XOR'd with payload). Server frames are unmasked.

#### 3. What to Implement

| Component | Lines (est.) | std lib used |
|-----------|-------------|--------------|
| TLS connection setup | ~30 | `std.crypto.tls.Client`, `std.net` |
| HTTP upgrade handshake | ~80 | Raw write/read on TLS stream, `std.crypto.hash.Sha1`, `std.base64` |
| Frame writer (with masking) | ~100 | `std.crypto.random` for mask key |
| Frame reader (unmask, reassemble) | ~150 | — |
| Ping/pong handler | ~30 | — |
| Close handshake | ~40 | — |
| Reconnection logic | ~100 | `std.Thread.sleep`, `std.time` |
| Public API surface | ~80 | — |
| **Total** | **~600-800** | |

### Conceptual API

```zig
const WebSocketClient = struct {
    tcp_stream: std.net.Stream,
    tls_client: std.crypto.tls.Client,
    allocator: std.mem.Allocator,
    read_buf: [4096]u8,

    pub const Message = struct {
        opcode: Opcode,
        payload: []const u8,
    };

    pub const Opcode = enum(u4) {
        text = 0x1,
        binary = 0x2,
        close = 0x8,
        ping = 0x9,
        pong = 0xA,
    };

    /// Connect to wss:// endpoint, perform TLS handshake + HTTP upgrade
    pub fn connect(
        allocator: std.mem.Allocator,
        host: []const u8,
        path: []const u8,
    ) !WebSocketClient { ... }

    /// Send a text frame (auto-masked per RFC 6455)
    pub fn sendText(self: *WebSocketClient, data: []const u8) !void { ... }

    /// Read next message (handles ping/pong internally, returns text/binary/close)
    pub fn receive(self: *WebSocketClient) !Message { ... }

    /// Send close frame and wait for server close
    pub fn close(self: *WebSocketClient) void { ... }
};
```

### Usage Pattern for Kraken

```zig
// Public market data
var ws = try WebSocketClient.connect(allocator, "ws.kraken.com", "/v2");
defer ws.close();

// Subscribe to BTC/USD ticker
try ws.sendText(
    \\{"method":"subscribe","params":{"channel":"ticker","symbol":["BTC/USD"]},"req_id":1}
);

// Read messages in a loop
while (true) {
    const msg = try ws.receive();
    switch (msg.opcode) {
        .text => {
            // Parse JSON, dispatch to handler
            const parsed = try std.json.parseFromSlice(
                std.json.Value, allocator, msg.payload, .{}
            );
            defer parsed.deinit();
            // ... handle ticker update
        },
        .close => break,
        else => {},
    }
}
```

---

## Concurrency Model

No async/await in current Zig. Available options (all in std):

| Approach | Best For | Module |
|----------|----------|--------|
| Thread per connection | Few feeds (our case) | `std.Thread` |
| epoll (Linux) | Many connections, single thread | `std.posix.epoll` |
| io_uring (Linux) | Maximum throughput | `std.os.linux.IoUring` |

**Recommended for this project**: Thread per connection — simple, sufficient for a handful of Kraken feeds.

```zig
// One thread for public market data
const market_thread = try std.Thread.spawn(.{}, handleMarketData, .{&shared_state});

// One thread for private (executions, balances, trading)
const private_thread = try std.Thread.spawn(.{}, handlePrivateStream, .{&shared_state});

// Main thread: REST operations, strategy logic, coordination
```

For inter-thread communication, use `std.Thread.Mutex` + `std.Thread.Condition` or lock-free ring buffers (implementable in std).

---

## Zig Version and TLS Considerations

| Item | Status |
|------|--------|
| Latest stable | **0.13.0** (June 2024) |
| TLS support | TLS 1.3 only (pure Zig, no OpenSSL) |
| Kraken TLS | Supports TLS 1.3 — compatible |
| Pin version | Yes — avoid nightly churn |

The built-in TLS 1.3 implementation is battle-tested (the Zig package manager uses it for all HTTPS fetches). Kraken's servers support TLS 1.3. No compatibility concern.

---

## Estimated Effort (Pure Zig, Zero Dependencies)

### SDK Layer (exchange-agnostic, built once)

| Component | Effort |
|-----------|--------|
| WebSocket client (RFC 6455 + WSS) | ~5-7 days |
| HTTP client helpers | ~1 day |
| Order book engine (snapshot + incremental + checksum) | ~2-3 days |
| Rate limiter (token-bucket / call-counter) | ~1-2 days |
| Exchange interface / common models | ~1 day |
| **SDK subtotal** | **~10-14 days** |

### Kraken Adapter (first exchange)

| Component | Effort |
|-----------|--------|
| Authentication / signing (HMAC-SHA512) | ~0.5 days |
| REST public endpoints | ~1-2 days |
| REST private + trading endpoints | ~2-3 days |
| JSON response models | ~2-3 days |
| WebSocket v2 subscriptions (public channels) | ~2-3 days |
| WebSocket trading (private, order mgmt) | ~2-3 days |
| Connection management / reconnect / dead man's switch | ~2-3 days |
| **Kraken subtotal** | **~12-18 days** |

### Totals

| Scope | Effort |
|-------|--------|
| **SDK + Kraken (first exchange)** | **~22-32 days** |
| **Second exchange adapter** | **~5-7 days** (SDK already exists) |

---

## Project Module Structure (Monorepo with SDK Layer)

```
src/
├── main.zig
├── sdk/                            # Exchange-agnostic infrastructure
│   ├── net/
│   │   ├── websocket.zig           # RFC 6455 WebSocket client (pure Zig)
│   │   └── http.zig                # HTTP helpers (wraps std.http.Client)
│   ├── book/
│   │   └── order_book.zig          # Order book engine (snapshot + incremental)
│   ├── rate/
│   │   └── limiter.zig             # Token-bucket / call-counter rate limiter
│   ├── exchange.zig                # Common exchange interface/contracts
│   └── models.zig                  # Shared types (Side, OrderType, TimeInForce, etc.)
├── exchanges/
│   └── kraken/
│       ├── client.zig              # Top-level Kraken client (REST + WS)
│       ├── auth.zig                # HMAC-SHA512 signing, nonce generation
│       ├── rest/
│       │   ├── public.zig          # Public REST endpoints
│       │   ├── private.zig         # Private REST endpoints
│       │   └── types.zig           # Kraken-specific request/response structs
│       ├── ws/
│       │   ├── connection.zig      # Kraken WS v2 connection (uses sdk/net/websocket)
│       │   ├── channels.zig        # Channel subscription management
│       │   ├── trading.zig         # WebSocket order placement/cancel/edit
│       │   └── types.zig           # Kraken WS message structs
│       └── models/
│           ├── order.zig           # Kraken order types, flags
│           ├── ticker.zig          # Ticker data
│           ├── book.zig            # Kraken book snapshots/updates → sdk order book
│           ├── trade.zig           # Trade data
│           └── account.zig         # Balance, positions, ledger
└── trading/
    ├── engine.zig                  # Strategy execution, order management
    └── risk.zig                    # Risk controls, position limits
```

**Import discipline**: `exchanges/kraken/` imports from `sdk/`. `trading/` imports from `sdk/` and `exchanges/`. `sdk/` never imports from `exchanges/` or `trading/`. This gives the same decoupling as separate repos without any external dependencies.

The SDK layer (`sdk/`) is fully exchange-agnostic. Adding a second exchange (e.g., Binance) means adding `exchanges/binance/` that implements the same `sdk/exchange.zig` interface — all the WebSocket, order book, and rate limiting infrastructure is already built.

---

## Advantages of This Approach

| Advantage | Detail |
|-----------|--------|
| **Zero supply chain risk** | No dependencies to audit, update, or worry about |
| **Total control** | Every allocation, every syscall, every byte on the wire is yours |
| **Deterministic performance** | No GC, no JIT warmup, no runtime surprises |
| **Minimal binary** | Single static binary, ~1-3 MB |
| **Debuggability** | No opaque library internals — step through everything |
| **Portability** | Cross-compile to any target Zig supports |
| **Long-running stability** | No memory fragmentation from GC, no hidden allocations |
