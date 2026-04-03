# Own Trades (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/owntrades

## Overview

The `ownTrades` channel provides trade execution data for the authenticated account. On subscription, a snapshot of the last 50 trades is delivered, followed by real-time updates for any new trade executions.

**Endpoint:** `wss://ws-auth.kraken.com`
**Channel Name:** `ownTrades`

## Authentication

**Required.** A valid session token must be provided in the subscription request. The token is obtained via the REST API `GetWebSocketsToken` endpoint.

## Subscription Format

```json
{
  "event": "subscribe",
  "subscription": {
    "name": "ownTrades",
    "token": "WW91ciBhdXRoZW50aWNhdGlvbiB0b2tlbiBnb2VzIGhlcmUu"
  }
}
```

## Subscription Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `event` | string | Yes | - | Must be `"subscribe"` |
| `subscription.name` | string | Yes | - | Must be `"ownTrades"` |
| `subscription.token` | string | Yes | - | Authenticated session token |
| `subscription.snapshot` | boolean | No | `true` | If `true`, includes initial snapshot of historical data (last 50 trades) |
| `subscription.consolidate_taker` | boolean | No | `true` | If `true`, fills are consolidated by taker; otherwise all individual fills are shown |
| `subscription.rebased` | boolean | No | `true` | For xstocks only: `true` displays in terms of underlying equity, `false` in terms of SPV tokens |
| `reqid` | string | No | - | Client-originated request identifier for acknowledgment |

## Response/Update Format

Responses are arrays with three elements:

```
[trades_array, channel_name, feed_detail_object]
```

### Array Elements

| Position | Field | Type | Description |
|----------|-------|------|-------------|
| 0 | `trades_array` | array | Array of trade objects keyed by Kraken trade identifier |
| 1 | `channel_name` | string | Always `"ownTrades"` |
| 2 | `feed_detail` | object | Contains `sequence` (integer) for subscription sequencing |

## Trade Object Fields

| Field | Type | Condition | Description |
|-------|------|-----------|-------------|
| `ordertxid` | string | - | Order identifier associated with this trade |
| `postxid` | integer | - | Position identifier |
| `pair` | string | - | Asset pair (e.g., `"XBT/EUR"`) |
| `time` | string | - | Unix timestamp of trade execution |
| `type` | string | - | Side of order: `"buy"` or `"sell"` |
| `ordertype` | string | - | Order type classification (e.g., `"limit"`, `"market"`) |
| `price` | string | - | Average price order was filled at (quote currency) |
| `cost` | string | - | Total cost of order (quote currency) |
| `fee` | string | - | Total fees (quote currency) |
| `vol` | string | - | Volume in base currency |
| `margin` | string | - | Initial margin (quote currency) |
| `margin_borrow` | boolean | Update messages only | Indicates if an execution is on margin |
| `cl_ord_id` | string | Update messages only | Optional client identifier |
| `ext_exec_id` | string (UUID) | - | Optional external partner execution identifier |
| `userref` | integer | Update messages only | Optional numeric identifier |

## Snapshot vs Update Behavior

**Initial Snapshot:**
- Delivers the last 50 trades for the account
- Can be disabled by setting `snapshot: false` in the subscription
- All trade fields are fully populated

**Subsequent Updates:**
- Real-time updates for any new trade executions
- Additional fields (`margin_borrow`, `cl_ord_id`, `userref`) may appear only in update messages

**Consolidation:**
- When `consolidate_taker: true` (default), fills for the same taker order are merged into a single trade record
- When `consolidate_taker: false`, each individual fill is reported separately

## Example Messages

### Subscription Request

```json
{
  "event": "subscribe",
  "subscription": {
    "name": "ownTrades",
    "token": "WW91ciBhdXRoZW50aWNhdGlvbiB0b2tlbiBnb2VzIGhlcmUu"
  }
}
```

### Trade Snapshot/Update

```json
[
  [
    {
      "TDLH43-DVQXD-2KHVYY": {
        "cost": "1000000.00000",
        "fee": "1600.00000",
        "margin": "0.00000",
        "ordertxid": "TDLH43-DVQXD-2KHVYY",
        "ordertype": "limit",
        "pair": "XBT/EUR",
        "postxid": "OGTT3Y-C6I3P-XRI6HX",
        "price": "100000.00000",
        "time": "1560516023.070651",
        "type": "sell",
        "vol": "1000000000.00000000"
      }
    }
  ],
  "ownTrades",
  {
    "sequence": 2948
  }
]
```

## Notes

- Authentication is mandatory via a session token obtained from the REST API.
- The snapshot provides the last 50 trades by default; set `snapshot: false` to skip the snapshot and receive only new trades.
- The `consolidate_taker` parameter controls whether fills are merged by taker or shown individually.
- The `sequence` field can be used for consistency verification and gap detection.
- The `rebased` parameter only applies to xstocks products.
- This is a WebSocket v1 channel. Kraken recommends migrating to WebSocket v2 for new implementations.
