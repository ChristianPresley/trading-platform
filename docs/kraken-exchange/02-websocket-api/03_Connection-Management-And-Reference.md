## Connection Management

### Heartbeat

- Server sends periodic heartbeat messages (~every 1 second when no other data flows):
  ```json
  { "channel": "heartbeat" }
  ```
- Clients can also send standard WebSocket protocol-level **ping frames** (server responds with pong).
- If no message received for ~10+ seconds, consider the connection stale and reconnect.

### Reconnection Strategy

1. Detect disconnection (heartbeat timeout, WebSocket close event, error).
2. Request a **fresh WebSocket token** via REST (old token may have expired).
3. Reconnect with **exponential backoff**: start ~1s, double up to max ~60s.
4. Re-subscribe to all channels after reconnection.
5. For `book` channel: fresh snapshot received — rebuild local order book.
6. For `executions`: use `snap_orders: true` to reconcile order state.

### Rate Limits

| Category | Details |
|----------|---------|
| **Subscriptions** | ~1 subscribe message/second safe; bursting may cause throttling |
| **Trading** | Shares REST API matching engine rate limit pool; token-bucket per pair (~60 tokens, ~1/sec replenish, varies by tier) |
| **Cancel orders** | More generous limits than adds |
| **Batch operations** | Count as single rate-limit event (significantly more efficient) |
| **Connections** | ~10 concurrent WebSocket connections per IP/API key |

### Connection Lifetime

- **No hard timeout** — connections can stay open indefinitely as long as heartbeats flow.
- WebSocket token expires (~15 min), but an already-authenticated connection does **not** drop when the token expires.
- Fresh token needed only for new connections or new subscription requests.

---

## v1 vs v2 Comparison

| Aspect | v1 | v2 |
|--------|----|----|
| **URL** | `wss://ws.kraken.com` | `wss://ws.kraken.com/v2` |
| **Message format** | Array-based, positional | JSON objects with named fields |
| **Public channels** | `ticker`, `ohlc`, `book`, `trade`, `spread` | `ticker`, `ohlc`, `book`, `trade`, `instrument` |
| **Private channels** | `ownTrades`, `openOrders` | `executions`, `balances` |
| **Spread channel** | Dedicated | Removed (use `ticker`/`book`) |
| **Balance channel** | Not available | Added |
| **Instrument metadata** | Not available | Added |
| **Pair naming** | `XBT/USD` prefixes | `BTC/USD` (cleaner) |
| **Status** | Deprecated (still operational) | **Current, actively maintained** |

---

## Quick Reference

| Item | Value |
|------|-------|
| Public WS URL | `wss://ws.kraken.com/v2` |
| Private WS URL | `wss://ws-auth.kraken.com/v2` |
| Token endpoint | `POST /0/private/GetWebSocketsToken` |
| Token lifetime | ~15 minutes |
| Book depths | 10, 25, 100, 500, 1000 |
| OHLC intervals (min) | 1, 5, 15, 30, 60, 240, 1440, 10080, 21600 |
| Max batch orders | 15 per batch |
| Dead man's switch | `cancel_all_orders_after` (timeout in seconds) |
| Book checksum | CRC32 over top 10 bid/ask levels |
| Public channels | `ticker`, `ohlc`, `book`, `trade`, `instrument` |
| Private channels | `executions`, `balances` |
