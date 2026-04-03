# Ticker (Level 1)

> Source: https://docs.kraken.com/api/docs/websocket-v2/ticker

## Overview

The ticker channel delivers level 1 market data, i.e. top of the book (best bid/offer) and recent trade data. Updates trigger on trade events and the feed accepts multiple currency pair subscriptions.

## Connection

- **Endpoint:** `wss://ws.kraken.com/v2`
- **Channel:** `ticker`

## Authentication

No authentication required. This is a public market data channel.

## Request/Subscription Format

```json
{
  "method": "subscribe",
  "params": {
    "channel": "ticker",
    "symbol": ["BTC/USD", "MATIC/GBP"],
    "event_trigger": "trades",
    "snapshot": true
  }
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `subscribe` |
| params.channel | string | Yes | Value: `ticker` |
| params.symbol | array of strings | Yes | Currency pairs (e.g., `["BTC/USD", "MATIC/GBP"]`) |
| params.event_trigger | string | No | Trigger type: `bbo` (best-bid-offer changes) or `trades` (default). Default: `trades` |
| params.snapshot | boolean | No | Request snapshot after subscribing. Default: `true` |
| params.req_id | integer | No | Optional client request identifier for acknowledgment |

## Subscribe Acknowledgment

### Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `subscribe` |
| result.channel | string | Value: `ticker` |
| result.symbol | string | Associated currency pair |
| result.snapshot | boolean | Indicates snapshot requested |
| warnings | array of strings | Advisory messages about deprecated fields |
| success | boolean | Request processing status |
| error | string | Error message (if success=false) |
| time_in | string | RFC3339 timestamp when received |
| time_out | string | RFC3339 timestamp when sent |
| req_id | integer | Echo of client request identifier |

### Example

```json
{
  "method": "subscribe",
  "result": {
    "channel": "ticker",
    "snapshot": true,
    "symbol": "ALGO/USD"
  },
  "success": true,
  "time_in": "2023-09-25T09:04:31.742599Z",
  "time_out": "2023-09-25T09:04:31.742648Z"
}
```

## Response/Update Format

Both snapshots and updates share an identical schema. An update message is streamed on a trade event (or BBO change if `event_trigger` is `bbo`).

```json
{
  "channel": "ticker",
  "type": "snapshot",
  "data": [
    {
      "symbol": "ALGO/USD",
      "bid": 0.10025,
      "bid_qty": 740.0,
      "ask": 0.10036,
      "ask_qty": 1361.44813783,
      "last": 0.10035,
      "volume": 997038.98383185,
      "vwap": 0.10148,
      "low": 0.09979,
      "high": 0.10285,
      "change": -0.00017,
      "change_pct": -0.17,
      "timestamp": "2023-09-25T09:04:31.742648Z"
    }
  ]
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| channel | string | Value: `ticker` |
| type | string | `snapshot` or `update` |
| data[0].ask | float | Best ask price |
| data[0].ask_qty | float | Best ask quantity |
| data[0].bid | float | Best bid price |
| data[0].bid_qty | float | Best bid quantity |
| data[0].change | float | 24-hour price change (quote currency) |
| data[0].change_pct | float | 24-hour price change (percentage points) |
| data[0].high | float | 24-hour highest trade price |
| data[0].last | float | Last traded price (guaranteed if traded within 24h) |
| data[0].low | float | 24-hour lowest trade price |
| data[0].symbol | string | Currency pair (e.g., "BTC/USD") |
| data[0].timestamp | string | RFC3339 ticker data timestamp |
| data[0].volume | float | 24-hour volume (base currency terms) |
| data[0].vwap | float | 24-hour volume weighted average price |

## Snapshot vs Update Behavior

- **Snapshot:** When `snapshot: true`, an initial snapshot is delivered immediately after subscription. Contains the full ticker state.
- **Update:** Streamed on each trade event (default) or best-bid-offer change (if `event_trigger: "bbo"`). Contains the same full set of fields as the snapshot.
- The data payload is always a single ticker object in an array (`data[0]`).

## Example Messages

### Subscribe Request

```json
{
  "method": "subscribe",
  "params": {
    "channel": "ticker",
    "symbol": ["ALGO/USD"]
  }
}
```

### Snapshot Response

```json
{
  "channel": "ticker",
  "type": "snapshot",
  "data": [
    {
      "symbol": "ALGO/USD",
      "bid": 0.10025,
      "bid_qty": 740.0,
      "ask": 0.10036,
      "ask_qty": 1361.44813783,
      "last": 0.10035,
      "volume": 997038.98383185,
      "vwap": 0.10148,
      "low": 0.09979,
      "high": 0.10285,
      "change": -0.00017,
      "change_pct": -0.17,
      "timestamp": "2023-09-25T09:04:31.742648Z"
    }
  ]
}
```

### Update Response

```json
{
  "channel": "ticker",
  "type": "update",
  "data": [
    {
      "symbol": "ALGO/USD",
      "bid": 0.10025,
      "bid_qty": 740.0,
      "ask": 0.10035,
      "ask_qty": 740.0,
      "last": 0.10035,
      "volume": 997038.98383185,
      "vwap": 0.10148,
      "low": 0.09979,
      "high": 0.10285,
      "change": -0.00017,
      "change_pct": -0.17,
      "timestamp": "2023-09-25T09:04:31.742648Z"
    }
  ]
}
```

### Unsubscribe Request

```json
{
  "method": "unsubscribe",
  "params": {
    "channel": "ticker",
    "symbol": ["ALGO/USD"]
  }
}
```

### Unsubscribe Acknowledgment

```json
{
  "method": "unsubscribe",
  "result": {
    "channel": "ticker",
    "event_trigger": "trades",
    "symbol": "ALGO/USD"
  },
  "success": true,
  "time_in": "2023-09-25T09:04:31.742599Z",
  "time_out": "2023-09-25T09:04:31.742648Z"
}
```

## Unsubscribe Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `unsubscribe` |
| params.channel | string | Yes | Value: `ticker` |
| params.symbol | array of strings | Yes | Currency pairs to unsubscribe |
| params.event_trigger | string | No | `bbo` or `trades` (default) |
| params.req_id | integer | No | Optional client request identifier |

## Unsubscribe Acknowledgment Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `unsubscribe` |
| result.channel | string | Value: `ticker` |
| result.symbol | string | Currency pair unsubscribed |
| result.event_trigger | string | `bbo` or `trades` |
| success | boolean | Request processing status |
| error | string | Error message (if success=false) |
| time_in | string | RFC3339 timestamp received |
| time_out | string | RFC3339 timestamp sent |
| req_id | integer | Echo of client request identifier |

## Rate Limits

Not explicitly documented for this channel.

## Notes

- By default, updates trigger on every trade; the alternative `bbo` mode triggers only on best-bid-offer price changes.
- Multiple currency pairs can be subscribed in a single request.
- Each symbol receives its own subscribe/unsubscribe acknowledgment.
