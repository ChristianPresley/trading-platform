# Kraken WebSocket API v2

Kraken's WebSocket API v2 is the current-generation real-time streaming interface, replacing v1 with cleaner JSON message formats, unified channels, and improved semantics. **Use v2 for all new development.**

## Connection URLs

| Purpose | URL |
|---------|-----|
| **Public (market data)** | `wss://ws.kraken.com/v2` |
| **Private (authenticated)** | `wss://ws-auth.kraken.com/v2` |

## Authentication

1. Obtain a WebSocket token via REST: `POST https://api.kraken.com/0/private/GetWebSocketsToken` (standard authenticated REST call using API key + secret with nonce/signature).
2. Response contains a `token` string.
3. **Token lifetime**: ~15 minutes from issuance. Request a fresh token before each connection/reconnection.
4. Token is passed in subscription/request message JSON bodies (not as a URL parameter).

## Message Format

All v2 messages use a consistent JSON envelope.

### Client Request

```json
{
  "method": "subscribe",
  "params": {
    "channel": "ticker",
    "symbol": ["BTC/USD"]
  },
  "req_id": 12345
}
```

- **`method`**: Operation — `subscribe`, `unsubscribe`, `add_order`, `cancel_order`, `edit_order`, `batch_add`, `batch_cancel`, etc.
- **`params`**: Method-specific parameters.
- **`req_id`** (optional): Client-chosen integer for request/response correlation. Server echoes it back.

### Server Response

```json
{
  "method": "subscribe",
  "result": {
    "channel": "ticker",
    "symbol": "BTC/USD",
    "snapshot": true
  },
  "success": true,
  "req_id": 12345
}
```

### Data Update

```json
{
  "channel": "ticker",
  "type": "update",
  "data": [ { ... } ]
}
```

- **`type`**: `snapshot` (initial full state) or `update` (incremental change).

### Error Response

```json
{
  "error": "Subscription depth not supported",
  "method": "subscribe",
  "success": false,
  "req_id": 12345
}
```

---

## Public Channels

### Ticker (`ticker`)

Real-time price/volume summary per instrument.

```json
{
  "method": "subscribe",
  "params": {
    "channel": "ticker",
    "symbol": ["BTC/USD", "ETH/USD"]
  }
}
```

**Data includes**: ask price/volume, bid price/volume, last trade price/volume, 24h volume, VWAP, 24h high/low, number of trades, open price.

### OHLC (`ohlc`)

Candlestick data at specified intervals.

```json
{
  "method": "subscribe",
  "params": {
    "channel": "ohlc",
    "symbol": ["BTC/USD"],
    "interval": 5
  }
}
```

**Supported intervals** (minutes): `1`, `5`, `15`, `30`, `60`, `240`, `1440` (1 day), `10080` (1 week), `21600` (15 days).

**Data includes**: open, high, low, close, VWAP, volume, trade count, timestamp.

### Order Book (`book`)

Depth snapshots and incremental updates.

```json
{
  "method": "subscribe",
  "params": {
    "channel": "book",
    "symbol": ["BTC/USD"],
    "depth": 100
  }
}
```

**Supported depth levels**: 10, 25, 100, 500, 1000.

- **Snapshot** (`"type": "snapshot"`): Full book to requested depth on subscription.
- **Updates** (`"type": "update"`): Only changed price levels (quantity = 0 means level removed).
- **Checksum**: CRC32 over top 10 ask/bid levels (price + volume concatenated, decimal points removed). Clients should validate to detect desync.

### Trades (`trade`)

Live trade feed.

```json
{
  "method": "subscribe",
  "params": {
    "channel": "trade",
    "symbol": ["BTC/USD"]
  }
}
```

**Data includes**: price, volume, timestamp, side (buy/sell), order type (market/limit), misc flags. A snapshot of recent trades is sent on subscription.

### Instrument (`instrument`)

Metadata about tradeable pairs and assets.

```json
{
  "method": "subscribe",
  "params": {
    "channel": "instrument",
    "snapshot": true
  }
}
```

**Data includes**: asset pairs, status (online/cancel-only/post-only), tick sizes, lot sizes, margin info, order constraints, fee schedules. Sends updates when instrument status changes.

> **Note**: v1 had a separate `spread` channel — in v2 this data is available through `ticker` and `book` channels.

---

## Private / Authenticated Channels

All private channels require the `token` in params and must connect to `wss://ws-auth.kraken.com/v2`.

### Executions (`executions`)

Unified channel combining own trades and order lifecycle events (replaces v1's separate `ownTrades` and `openOrders` channels).

```json
{
  "method": "subscribe",
  "params": {
    "channel": "executions",
    "token": "your-ws-token",
    "snap_orders": true,
    "snap_trades": true
  }
}
```

- **`snap_orders: true`**: Snapshot of all open orders on subscription.
- **`snap_trades: true`**: Snapshot of recent trade history (~last 50 trades).
- **Updates include**: order creation, status changes (pending → open → closed/canceled/expired), partial fills, full fills with execution details.
- **Fields**: `order_id`, `order_status`, `exec_type` (`new`, `filled`, `canceled`, `trade`), `side`, `symbol`, `order_type`, `limit_price`, `qty`, `filled_qty`, `avg_price`, `fee`, timestamps.

### Balances (`balances`)

Real-time balance and ledger updates.

```json
{
  "method": "subscribe",
  "params": {
    "channel": "balances",
    "token": "your-ws-token",
    "snap_balances": true
  }
}
```

- Snapshot of all asset balances on subscription.
- Updates when balances change (trades, deposits, withdrawals, staking).
- **Fields**: asset name, balance, wallets/hold amounts.

---

## WebSocket Trading

Kraken v2 WebSocket supports **full trading operations** on the authenticated endpoint — you can build a complete trading system without REST API calls for order management.

### Add Order

```json
{
  "method": "add_order",
  "params": {
    "order_type": "limit",
    "side": "buy",
    "symbol": "BTC/USD",
    "limit_price": 25000.00,
    "order_qty": 0.01,
    "token": "your-ws-token",
    "time_in_force": "GTC",
    "post_only": false,
    "reduce_only": false,
    "cl_ord_id": "my-client-id-123"
  },
  "req_id": 1
}
```

**Supported order types**: `limit`, `market`, `stop-loss`, `take-profit`, `stop-loss-limit`, `take-profit-limit`, `trailing-stop`, `trailing-stop-limit`, `settle-position`, `iceberg`.

**Key parameters**:

| Parameter | Description |
|-----------|-------------|
| `time_in_force` | `GTC` (good till cancelled), `IOC` (immediate or cancel), `GTD` (good till date) |
| `post_only` | Ensures limit order is maker only |
| `reduce_only` | Only reduce existing position |
| `cl_ord_id` | Client-assigned order ID for tracking (up to 18 chars) |
| `deadline` | RFC3339 timestamp — reject if not processed by this time (latency-sensitive strategies) |
| `conditional` | Attached stop-loss / take-profit parameters |
| `fee_preference` | Pay fee in base or quote currency |

### Cancel Order

```json
{
  "method": "cancel_order",
  "params": {
    "order_id": ["OXXXX-XXXXX-XXXXXX"],
    "token": "your-ws-token"
  },
  "req_id": 2
}
```

Can cancel by `order_id` (array) or `cl_ord_id` (client order IDs).

### Cancel All Orders

```json
{
  "method": "cancel_all",
  "params": {
    "token": "your-ws-token"
  },
  "req_id": 3
}
```

### Dead Man's Switch (Cancel All Orders After)

```json
{
  "method": "cancel_all_orders_after",
  "params": {
    "timeout": 60,
    "token": "your-ws-token"
  },
  "req_id": 4
}
```

Sets a countdown timer (seconds). If not refreshed before expiry, all open orders are cancelled. Set `timeout: 0` to disable. **Critical for automated trading** — protects against connectivity loss.

### Edit Order

```json
{
  "method": "edit_order",
  "params": {
    "order_id": "OXXXX-XXXXX-XXXXXX",
    "symbol": "BTC/USD",
    "limit_price": 25500.00,
    "order_qty": 0.02,
    "token": "your-ws-token"
  },
  "req_id": 5
}
```

Edits are **atomic** (cancel + replace under the hood, but guaranteed atomic on the matching engine).

### Batch Add Orders

```json
{
  "method": "batch_add",
  "params": {
    "symbol": "BTC/USD",
    "token": "your-ws-token",
    "orders": [
      {
        "order_type": "limit",
        "side": "buy",
        "limit_price": 24000.00,
        "order_qty": 0.01
      },
      {
        "order_type": "limit",
        "side": "buy",
        "limit_price": 23500.00,
        "order_qty": 0.01
      }
    ]
  },
  "req_id": 6
}
```

- Up to **15 orders** per batch.
- All orders must be for the **same symbol**.
- `batch_cancel` also available.
- Batch operations count as a **single rate-limit event**.

---

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
