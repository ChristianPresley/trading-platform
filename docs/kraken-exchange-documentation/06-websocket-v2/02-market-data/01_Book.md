# Book (Level 2)

> Source: https://docs.kraken.com/api/docs/websocket-v2/book

## Overview

The book channel streams level 2 (L2) order book data. It describes the individual price levels in the book with aggregated order quantities at each level. Clients can subscribe to multiple currency pairs simultaneously.

## Connection

- **Endpoint:** `wss://ws.kraken.com/v2`
- **Channel:** `book`

## Authentication

No authentication required. This is a public market data channel.

## Request/Subscription Format

```json
{
  "method": "subscribe",
  "params": {
    "channel": "book",
    "symbol": ["BTC/USD", "MATIC/GBP"],
    "depth": 10,
    "snapshot": true
  }
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `subscribe` |
| params.channel | string | Yes | Value: `book` |
| params.symbol | array of strings | Yes | Currency pairs (e.g., `["BTC/USD", "MATIC/GBP"]`) |
| params.depth | integer | No | Number of price levels per side. Values: `10`, `25`, `100`, `500`, `1000`. Default: `10` |
| params.snapshot | boolean | No | Request snapshot after subscribing. Default: `true` |
| params.req_id | integer | No | Client-originated request identifier |

## Subscribe Acknowledgment

### Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `subscribe` |
| result.channel | string | Value: `book` |
| result.symbol | string | Currency pair |
| result.depth | integer | Number of price levels per side |
| result.snapshot | boolean | Whether snapshot was requested |
| success | boolean | Processing status |
| error | string | Present only if `success` is `false` |
| time_in | string | RFC3339 wire reception time |
| time_out | string | RFC3339 wire transmission time |
| req_id | integer | Echo of client request ID |
| warnings | array of strings | Advisory messages about deprecated fields |

### Example

```json
{
  "method": "subscribe",
  "result": {
    "channel": "book",
    "depth": 10,
    "snapshot": true,
    "symbol": "ALGO/USD"
  },
  "success": true,
  "time_in": "2023-10-06T17:35:55.219022Z",
  "time_out": "2023-10-06T17:35:55.219067Z"
}
```

Note: Separate acknowledgments are sent for each symbol in the subscription list.

## Response/Update Format

### Snapshot

```json
{
  "channel": "book",
  "type": "snapshot",
  "data": [
    {
      "symbol": "MATIC/USD",
      "bids": [
        {"price": 0.5666, "qty": 4831.75496356},
        {"price": 0.5665, "qty": 6658.22734739}
      ],
      "asks": [
        {"price": 0.5668, "qty": 4410.79769741},
        {"price": 0.5669, "qty": 4655.40412487}
      ],
      "checksum": 2439117997,
      "timestamp": "2023-10-06T17:35:55.440295Z"
    }
  ]
}
```

### Update

Updates contain only modified price levels. A quantity of `0` means the price level should be removed.

```json
{
  "channel": "book",
  "type": "update",
  "data": [
    {
      "symbol": "MATIC/USD",
      "bids": [
        {"price": 0.5657, "qty": 1098.3947558}
      ],
      "asks": [],
      "checksum": 2114181697,
      "timestamp": "2023-10-06T17:35:55.440295Z"
    }
  ]
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| channel | string | Value: `book` |
| type | string | `snapshot` or `update` |
| data[0].symbol | string | Currency pair identifier |
| data[0].bids | array | Array of bid level objects |
| data[0].bids[].price | float | Bid price level |
| data[0].bids[].qty | float | Aggregated quantity at this bid price |
| data[0].asks | array | Array of ask level objects |
| data[0].asks[].price | float | Ask price level |
| data[0].asks[].qty | float | Aggregated quantity at this ask price |
| data[0].checksum | integer | CRC32 checksum of top 10 bids and asks |
| data[0].timestamp | string | RFC3339 formatted timestamp |

## Snapshot vs Update Behavior

- **Snapshot:** Delivered once after subscription (if `snapshot: true`). Contains all price levels up to the subscribed depth for both bids and asks.
- **Update:** Contains only modified price levels. A `qty` of `0` indicates a price level has been removed.
- It is possible to have multiple updates to the same price level in a single update message. Updates should always be processed in sequence.
- The `checksum` field covers the top 10 bids and asks regardless of the requested depth.

## Checksum Calculation

The checksum is a CRC32 value computed over the top 10 bids and asks. For complete details on maintaining the order book and generating the checksum, see the [Kraken spot WebSocket book v2 guide](https://docs.kraken.com/api/docs/guides/spot-ws-book-v2).

## Example Messages

### Subscribe Request

```json
{
  "method": "subscribe",
  "params": {
    "channel": "book",
    "symbol": ["ALGO/USD", "MATIC/USD"]
  }
}
```

### Subscribe Acknowledgment (per symbol)

```json
{
  "method": "subscribe",
  "result": {
    "channel": "book",
    "depth": 10,
    "snapshot": true,
    "symbol": "MATIC/USD"
  },
  "success": true,
  "time_in": "2023-10-06T17:35:55.219022Z",
  "time_out": "2023-10-06T17:35:55.219067Z"
}
```

### Snapshot Response

```json
{
  "channel": "book",
  "type": "snapshot",
  "data": [
    {
      "symbol": "MATIC/USD",
      "bids": [
        {"price": 0.5666, "qty": 4831.75496356},
        {"price": 0.5665, "qty": 6658.22734739},
        {"price": 0.5664, "qty": 18724.91513344},
        {"price": 0.5663, "qty": 11563.92544914},
        {"price": 0.5662, "qty": 14006.65365711},
        {"price": 0.5661, "qty": 17454.85679807},
        {"price": 0.566, "qty": 18097.1547},
        {"price": 0.5659, "qty": 33644.89175666},
        {"price": 0.5658, "qty": 148.3464},
        {"price": 0.5657, "qty": 606.70854372}
      ],
      "asks": [
        {"price": 0.5668, "qty": 4410.79769741},
        {"price": 0.5669, "qty": 4655.40412487},
        {"price": 0.567, "qty": 49844.89424998},
        {"price": 0.5671, "qty": 24306.41678},
        {"price": 0.5672, "qty": 29783.25223475},
        {"price": 0.5673, "qty": 57234.71239278},
        {"price": 0.5674, "qty": 45065.04744},
        {"price": 0.5675, "qty": 5912.76380354},
        {"price": 0.5676, "qty": 42514.92434778},
        {"price": 0.5677, "qty": 36304.0847022}
      ],
      "checksum": 2439117997,
      "timestamp": "2023-10-06T17:35:55.440295Z"
    }
  ]
}
```

### Update Response

```json
{
  "channel": "book",
  "type": "update",
  "data": [
    {
      "symbol": "MATIC/USD",
      "bids": [
        {"price": 0.5657, "qty": 1098.3947558}
      ],
      "asks": [],
      "checksum": 2114181697,
      "timestamp": "2023-10-06T17:35:55.440295Z"
    }
  ]
}
```

### Unsubscribe Request

```json
{
  "method": "unsubscribe",
  "params": {
    "channel": "book",
    "symbol": ["ALGO/USD", "MATIC/USD"]
  }
}
```

### Unsubscribe Acknowledgment

```json
{
  "method": "unsubscribe",
  "result": {
    "channel": "book",
    "depth": 10,
    "snapshot": true,
    "symbol": "ALGO/USD"
  },
  "success": true,
  "time_in": "2023-10-06T17:35:55.219022Z",
  "time_out": "2023-10-06T17:35:55.219067Z"
}
```

## Unsubscribe Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `unsubscribe` |
| params.channel | string | Yes | Value: `book` |
| params.symbol | array of strings | Yes | Currency pairs to unsubscribe |
| params.depth | integer | No | Specific depth to unsubscribe |
| params.req_id | integer | No | Client request identifier |

## Rate Limits

Not explicitly documented for this channel.

## Notes

- Separate acknowledgments are sent for each symbol in subscription/unsubscription lists.
- Depth options are: 10, 25, 100, 500, or 1000 price levels per side.
- The checksum covers the top 10 bids and asks regardless of requested depth.
- Updates should always be processed in sequence within a single message.
- For complete order book maintenance guidance, see the [Kraken spot WebSocket book v2 guide](https://docs.kraken.com/api/docs/guides/spot-ws-book-v2).
