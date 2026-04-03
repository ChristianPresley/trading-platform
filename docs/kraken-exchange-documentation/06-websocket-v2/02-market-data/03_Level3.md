# Level 3 (Individual Orders)

> Source: https://docs.kraken.com/api/docs/websocket-v2/level3

## Overview

The level3 channel offers granular visibility into individual orders within the order book. It displays resting orders without crossing (no overlapping buy/sell orders) and excludes in-flight orders, unmatched market orders, untriggered stop orders, and iceberg hidden quantities.

## Connection

- **Endpoint:** `wss://ws-l3.kraken.com/v2` (note: different from standard endpoint)
- **Channel:** `level3`

## Authentication

**Required.** This channel requires authentication via API token. A session token must be provided in the subscription request.

## Connection and Rate Limits

- Maximum 200 symbols per WebSocket connection
- Rate limits:
  - Standard tier: 200/sec
  - Pro tier: 500/sec
- Rate counter increases per depth:
  - Depth 10: +5
  - Depth 100: +25
  - Depth 1000: +100
- Only one subscription per depth level per symbol is permitted.

## Request/Subscription Format

```json
{
  "method": "subscribe",
  "params": {
    "channel": "level3",
    "symbol": ["BTC/USD"],
    "token": "session-token-here",
    "depth": 10,
    "snapshot": true
  }
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `subscribe` |
| params.channel | string | Yes | Value: `level3` |
| params.symbol | array of strings | Yes | Currency pairs to subscribe |
| params.token | string | Yes | Session authentication token |
| params.depth | integer | No | Values: `10`, `100`, `1000`. Default: `10` |
| params.snapshot | boolean | No | Request snapshot after subscribing. Default: `true` |
| req_id | integer | No | Client request identifier |

## Subscribe Acknowledgment

### Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `subscribe` |
| result.channel | string | Value: `level3` |
| result.symbol | string | Currency pair |
| result.depth | integer | Subscribed depth levels |
| result.snapshot | boolean | Snapshot requested |
| success | boolean | Request status |
| error | string | Error message if unsuccessful (conditional) |
| warnings | array of strings | Deprecated field alerts |
| time_in | string | RFC3339 timestamp received |
| time_out | string | RFC3339 timestamp sent |
| req_id | integer | Request identifier echo (optional) |

## Response/Update Format

### Snapshot

The snapshot contains all resting orders at the subscribed depth.

```json
{
  "channel": "level3",
  "type": "snapshot",
  "data": [
    {
      "symbol": "BTC/USD",
      "bids": [
        {
          "order_id": "OXXXX1-XXXXX-XXXXXX",
          "limit_price": 26500.0,
          "order_qty": 1.5,
          "timestamp": "2023-09-25T09:00:00.000000Z"
        }
      ],
      "asks": [
        {
          "order_id": "OXXXX2-XXXXX-XXXXXX",
          "limit_price": 26510.0,
          "order_qty": 0.5,
          "timestamp": "2023-09-25T09:00:01.000000Z"
        }
      ],
      "checksum": 1234567890,
      "timestamp": "2023-09-25T09:00:02.000000Z"
    }
  ]
}
```

### Update

Updates are streamed in real-time and contain order events.

```json
{
  "channel": "level3",
  "type": "update",
  "data": [
    {
      "symbol": "BTC/USD",
      "bids": [
        {
          "event": "add",
          "order_id": "OXXXX3-XXXXX-XXXXXX",
          "limit_price": 26499.0,
          "order_qty": 2.0,
          "timestamp": "2023-09-25T09:01:00.000000Z"
        }
      ],
      "asks": [],
      "checksum": 1234567891,
      "timestamp": "2023-09-25T09:01:00.000000Z"
    }
  ]
}
```

## Response Fields

### Snapshot Fields (per order)

| Field | Type | Description |
|-------|------|-------------|
| order_id | string | Kraken order identifier |
| limit_price | float | Order price |
| order_qty | float | Visible order quantity |
| timestamp | string | RFC3339 insertion/amendment time |

### Update Fields (per order)

| Field | Type | Description |
|-------|------|-------------|
| event | string | Order event: `add`, `modify`, or `delete` |
| order_id | string | Kraken order identifier |
| limit_price | float | Order price |
| order_qty | float | Visible order quantity |
| timestamp | string | RFC3339 event time |

### Container Fields

| Field | Type | Description |
|-------|------|-------------|
| channel | string | Value: `level3` |
| type | string | `snapshot` or `update` |
| data[0].symbol | string | Currency pair |
| data[0].bids | array | Bid order objects |
| data[0].asks | array | Ask order objects |
| data[0].checksum | integer | CRC32 checksum for top 10 levels |
| data[0].timestamp | string | RFC3339 message generation time |

## Snapshot vs Update Behavior

- **Snapshot:** Contains all resting orders at the subscribed depth, delivered once after subscription (if `snapshot: true`).
- **Update:** Streamed in real-time. Each order event includes an `event` field:
  - `add` - New order inserted into the book
  - `modify` - Order quantity changed
  - `delete` - Order removed from the book
- When the subscribed depth is exceeded, the worst price level automatically truncates without generating delete events.
- Updates are streamed real-time without sequencing.

## Unsubscribe

### Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `unsubscribe` |
| params.channel | string | Yes | Value: `level3` |
| params.symbol | array of strings | Yes | Currency pairs to unsubscribe |
| params.token | string | Yes | Session token |
| params.depth | integer | No | Depth to unsubscribe (10, 100, or 1000) |
| req_id | integer | No | Client request identifier |

Unsubscribe acknowledgments mirror subscribe acknowledgments with `method: "unsubscribe"`.

## Rate Limits

- Standard tier: 200 requests/sec
- Pro tier: 500 requests/sec
- Rate counter cost scales with depth (10 = +5, 100 = +25, 1000 = +100)

## Notes

- Uses a different WebSocket endpoint than other channels: `wss://ws-l3.kraken.com/v2`
- Maximum 200 symbols per connection.
- Only one subscription per depth level per symbol is permitted.
- Orders displayed are resting orders only -- excludes in-flight orders, unmatched market orders, untriggered stop orders, and hidden iceberg quantities.
- No crossing orders are shown (buy/sell orders do not overlap).
