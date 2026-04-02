# Kraken Exchange — Integration Guide

Kraken is a US-headquartered cryptocurrency exchange (operated by Payward, Inc.) serving 190+ countries with 200+ assets and 600+ trading pairs. It offers strong fiat support (USD, EUR, GBP, CAD, AUD, JPY, CHF), institutional-grade API infrastructure, and a comprehensive set of order types suitable for algorithmic trading.

This documentation covers everything needed to integrate Kraken into this trading platform for live, near-realtime programmatic trading. The platform is built in pure Zig with zero external dependencies.

## Documentation

| # | Document | Contents |
|---|----------|----------|
| 1 | [REST API](01-rest-api/) | Authentication/signing, WS token, reference data, account queries, rate limits — no trading endpoints (use WebSocket) |
| 2 | [WebSocket API](02-websocket-api/) | WebSocket v2 protocol (public & private channels), real-time market data, order execution, connection management, dead man's switch |
| 3 | [Trading and Accounts](03-trading-and-accounts/) | Account tiers, fee structure, order types, margin/leverage, futures, staking, deposits/withdrawals, security, regulatory compliance |
| 4 | [Zig Implementation](04-zig-implementation/) | Pure Zig approach — std lib coverage, WebSocket implementation, SDK architecture, module structure, effort estimates |

---

## Architecture

### Connectivity Model

```text
┌──────────────────────────────────────────────┐
│              Trading Platform (Zig)           │
├──────────────────────────────────────────────┤
│                trading/                       │
│         Strategy execution, risk mgmt         │
├──────────────────────────────────────────────┤
│              exchanges/kraken/                │
│     Auth, REST endpoints, WS v2 channels      │
├──────────────────────────────────────────────┤
│                  sdk/                         │
│   WebSocket (RFC 6455), HTTP, order book,     │
│   rate limiting, exchange interface            │
├──────────────────────────────────────────────┤
│              Zig std lib                      │
│  std.http.Client, std.crypto, std.json,       │
│  std.net, std.crypto.tls, std.Thread          │
└──────────────────────────────────────────────┘
```

### Approach

1. **SDK layer** (`src/sdk/`) — exchange-agnostic infrastructure built once:
   - RFC 6455 WebSocket client over `std.crypto.tls` + `std.net`
   - HTTP helpers wrapping `std.http.Client`
   - Order book engine (snapshot + incremental updates + CRC32 checksum)
   - Rate limiter (token-bucket / call-counter)
   - Common exchange interface contracts

2. **Kraken adapter** (`src/exchanges/kraken/`) — Kraken-specific logic:
   - HMAC-SHA512 request signing via `std.crypto`
   - REST wrappers for auth, reference data, and account queries
   - WebSocket v2 channel subscriptions and order execution
   - Connection management, reconnection, dead man's switch

3. **WebSocket for all real-time operations** (primary path):
   - Subscribe to `book`, `trade`, `ticker` channels for market data
   - Subscribe to `executions` and `balances` for account state
   - Place/cancel/edit orders via WebSocket for lower latency
   - Use `cancel_all_orders_after` (dead man's switch) for safety

4. **REST for bootstrap and queries only**:
   - WS token generation (required before authenticated WebSocket)
   - Reference data at startup (Assets, AssetPairs, SystemStatus)
   - Historical queries (closed orders, trade history, ledgers)
   - Report generation and export

### Key Integration Considerations

| Concern | Approach |
|---------|----------|
| **Rate limiting** | SDK rate limiter implements Kraken's call-counter and matching-engine penalty systems |
| **Reconnection** | SDK WebSocket client handles reconnection with exponential backoff; Kraken adapter reconciles order state via `executions` snapshot |
| **Testing** | Use `validate=true` on order endpoints for dry-run validation; Futures demo at `demo-futures.kraken.com` |
| **Safety** | Always enable dead man's switch; use IP-whitelisted API keys with minimal permissions |
| **Pair naming** | WebSocket v2 uses clean names (`BTC/USD`); REST uses legacy names (`XXBTZUSD`) — adapter normalizes both |
| **US restrictions** | No margin, no staking, no futures for US users; check state availability |

---

## Key Facts at a Glance

| Item | Value |
|------|-------|
| REST Base URL | `https://api.kraken.com/0/` |
| WebSocket Public | `wss://ws.kraken.com/v2` |
| WebSocket Private | `wss://ws-auth.kraken.com/v2` |
| Authentication | HMAC-SHA512 signed requests (`std.crypto`) |
| WS Token Endpoint | `POST /0/private/GetWebSocketsToken` |
| WS Token Lifetime | ~15 minutes |
| Max Batch Orders | 15 per batch |
| Maker Fee (lowest) | 0.00% ($10M+ 30d volume) |
| Taker Fee (lowest) | 0.10% ($10M+ 30d volume) |
| Spot Leverage | Up to 5x (not available in US) |
| Futures Leverage | Up to 50x (separate API) |
| Assets | 200+ |
| Trading Pairs | 600+ |
| Fiat Currencies | USD, EUR, GBP, CAD, AUD, JPY, CHF |
| FIX API | Available by application (FIX 4.2) |
| Spot Sandbox | None (use `validate=true`) |
| Futures Sandbox | `demo-futures.kraken.com` |
| Implementation | Pure Zig, zero external dependencies |
