# Trade

> Source: https://docs.kraken.com/api/docs/websocket-v2/trade

## Overview

The trade channel generates events when orders match in the book. Multiple trades may be batched in a single message, but that does not mean that these trades resulted from a single taker order. The feed accepts multiple symbols for subscription.

## Connection

- **Endpoint:** `wss://ws.kraken.com/v2`
- **Channel:** `trade`

## Authentication

No authentication required. This is a public market data channel.

## Request/Subscription Format

```json
{
  "method": "subscribe",
  "params": {
    "channel": "trade",
    "symbol": ["BTC/USD", "MATIC/GBP"],
    "snapshot": true
  }
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `subscribe` |
| params.channel | string | Yes | Value: `trade` |
| params.symbol | array of strings | Yes | Currency pairs (e.g., `["BTC/USD", "MATIC/GBP"]`) |
| params.snapshot | boolean | No | Request snapshot after subscribing. Default: `false` |
| params.req_id | integer | No | Client-originated request identifier |

## Subscribe Acknowledgment

### Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `subscribe` |
| result.channel | string | Value: `trade` |
| result.symbol | string | Currency pair associated with subscription |
| result.snapshot | boolean | Indicates if snapshot was requested |
| success | boolean | Indicates successful processing |
| warnings | array of strings | Advisory messages about deprecated fields or upcoming changes (optional) |
| error | string | Error message if success is false (conditional) |
| time_in | string | RFC3339 timestamp when subscription received |
| time_out | string | RFC3339 timestamp when acknowledgment sent |
| req_id | integer | Client-originated request identifier (optional) |

### Example

```json
{
  "method": "subscribe",
  "result": {
    "channel": "trade",
    "snapshot": true,
    "symbol": "MATIC/USD"
  },
  "success": true,
  "time_in": "2023-09-25T09:21:10.428340Z",
  "time_out": "2023-09-25T09:21:10.428375Z"
}
```

## Response/Update Format

Both snapshot and update responses share the same schema.

```json
{
  "channel": "trade",
  "type": "update",
  "data": [
    {
      "symbol": "MATIC/USD",
      "side": "sell",
      "price": 0.5117,
      "qty": 40.0,
      "ord_type": "market",
      "trade_id": 4665906,
      "timestamp": "2023-09-25T07:49:37.708706Z"
    }
  ]
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| channel | string | Value: `trade` |
| type | string | `snapshot` or `update` |
| data[].symbol | string | Currency pair (e.g., "BTC/USD") |
| data[].side | string | Taker order side: `buy` or `sell` |
| data[].qty | float | Trade size |
| data[].price | float | Average trade price |
| data[].ord_type | string | Order type: `limit` or `market` |
| data[].trade_id | integer | Sequence number, unique per book |
| data[].timestamp | string | RFC3339 book order update timestamp |

## Snapshot vs Update Behavior

- **Snapshot:** Returned when `snapshot: true` is set in the subscribe request. Contains the most recent 50 trades for the subscribed symbol. Default for snapshot is `false`.
- **Update:** Streamed continuously as trade events occur. Contains only newly executed trades since the last message.
- Multiple trades may appear in the `data` array of a single message.

## Example Messages

### Subscribe Request

```json
{
  "method": "subscribe",
  "params": {
    "channel": "trade",
    "symbol": ["MATIC/USD"],
    "snapshot": true
  }
}
```

### Snapshot Response

```json
{
  "channel": "trade",
  "type": "snapshot",
  "data": [
    {
      "symbol": "MATIC/USD",
      "side": "buy",
      "price": 0.5147,
      "qty": 6423.46326,
      "ord_type": "limit",
      "trade_id": 4665846,
      "timestamp": "2023-09-25T07:48:36.925533Z"
    },
    {
      "symbol": "MATIC/USD",
      "side": "buy",
      "price": 0.5147,
      "qty": 1136.19677815,
      "ord_type": "limit",
      "trade_id": 4665847,
      "timestamp": "2023-09-25T07:49:36.925603Z"
    }
  ]
}
```

### Update Response

```json
{
  "channel": "trade",
  "type": "update",
  "data": [
    {
      "symbol": "MATIC/USD",
      "side": "sell",
      "price": 0.5117,
      "qty": 40.0,
      "ord_type": "market",
      "trade_id": 4665906,
      "timestamp": "2023-09-25T07:49:37.708706Z"
    }
  ]
}
```

### Unsubscribe Request

```json
{
  "method": "unsubscribe",
  "params": {
    "channel": "trade",
    "symbol": ["MATIC/USD"]
  }
}
```

### Unsubscribe Acknowledgment

```json
{
  "method": "unsubscribe",
  "result": {
    "channel": "trade",
    "symbol": "MATIC/USD"
  },
  "success": true,
  "time_in": "2023-09-25T09:21:10.428340Z",
  "time_out": "2023-09-25T09:21:10.428375Z"
}
```

## Unsubscribe Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `unsubscribe` |
| params.channel | string | Yes | Value: `trade` |
| params.symbol | array of strings | Yes | Currency pairs to unsubscribe |
| params.req_id | integer | No | Client request identifier |

## Rate Limits

Not explicitly documented for this channel.

## Notes

- Multiple trades may be batched in a single message, but they do not necessarily result from a single taker order.
- The snapshot default is `false` (unlike most other channels which default to `true`).
- The `trade_id` is a sequence number unique per book (per trading pair).
