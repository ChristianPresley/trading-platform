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
