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
