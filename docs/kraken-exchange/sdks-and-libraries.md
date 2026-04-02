# Kraken API — Implementation Approach

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
