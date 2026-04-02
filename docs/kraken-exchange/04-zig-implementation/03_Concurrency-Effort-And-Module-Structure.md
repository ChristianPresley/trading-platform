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
