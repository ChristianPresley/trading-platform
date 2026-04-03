# OHLC (Open, High, Low, Close)

> Source: https://docs.kraken.com/api/docs/websocket-v2/ohlc

## Overview

The OHLC channel streams Open, High, Low and Close (OHLC) data for a specific interval period. Updates occur on trade events, and the channel accepts multiple symbols simultaneously.

## Connection

- **Endpoint:** `wss://ws.kraken.com/v2`
- **Channel:** `ohlc`

## Authentication

No authentication required. This is a public market data channel.

## Request/Subscription Format

```json
{
  "method": "subscribe",
  "params": {
    "channel": "ohlc",
    "symbol": ["ALGO/USD", "MATIC/USD"],
    "interval": 5,
    "snapshot": true
  }
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `subscribe` |
| params.channel | string | Yes | Value: `ohlc` |
| params.symbol | array of strings | Yes | Currency pairs (e.g., `["BTC/USD", "MATIC/GBP"]`) |
| params.interval | integer | No | Timeframe in minutes. Allowed values: `1`, `5`, `15`, `30`, `60`, `240`, `1440`, `10080`, `21600` |
| params.snapshot | boolean | No | Request snapshot after subscribing. Default: `true` |
| params.req_id | integer | No | Client-originated request identifier |

## Interval Options (in minutes)

| Value | Duration |
|-------|----------|
| 1 | 1 minute |
| 5 | 5 minutes |
| 15 | 15 minutes |
| 30 | 30 minutes |
| 60 | 1 hour |
| 240 | 4 hours |
| 1440 | 1 day |
| 10080 | 1 week |
| 21600 | 15 days |

## Subscribe Acknowledgment

### Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `subscribe` |
| result.channel | string | Value: `ohlc` |
| result.symbol | string | Currency pair |
| result.snapshot | boolean | Indicates if snapshot requested |
| result.interval | integer | Timeframe confirmation |
| result.warnings | array of strings | Advisory messages (e.g., deprecated fields) |
| success | boolean | Processing status |
| error | string | Error message if `success` is `false` |
| time_in | string | RFC3339 timestamp when received |
| time_out | string | RFC3339 timestamp when sent |
| req_id | integer | Echo of client request ID |

### Example

```json
{
  "method": "subscribe",
  "result": {
    "channel": "ohlc",
    "interval": 5,
    "snapshot": true,
    "symbol": "ALGO/USD",
    "warnings": ["timestamp is deprecated, use interval_begin"]
  },
  "success": true,
  "time_in": "2023-10-04T16:26:01.802708Z",
  "time_out": "2023-10-04T16:26:01.802791Z"
}
```

## Response/Update Format

Both snapshot and update messages share an identical schema.

```json
{
  "channel": "ohlc",
  "type": "snapshot",
  "timestamp": "2023-10-04T16:26:01.806315597Z",
  "data": [
    {
      "symbol": "ALGO/USD",
      "open": 0.09875,
      "high": 0.09875,
      "low": 0.09875,
      "close": 0.09875,
      "trades": 1,
      "volume": 201.86015,
      "vwap": 0.09875,
      "interval_begin": "2023-10-04T15:25:00.000000000Z",
      "interval": 5,
      "timestamp": "2023-10-04T15:30:00.000000Z"
    }
  ]
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| channel | string | Value: `ohlc` |
| type | string | `snapshot` or `update` |
| timestamp | string | RFC3339 message timestamp |
| data[0].symbol | string | Currency pair identifier (e.g., "BTC/USD") |
| data[0].open | float | Opening trade price within interval |
| data[0].high | float | Highest trade price within interval |
| data[0].low | float | Lowest trade price within interval |
| data[0].close | float | Last trade price within interval |
| data[0].vwap | float | Volume weighted average trade price within the interval |
| data[0].trades | float | Count of trades within interval |
| data[0].volume | float | Total traded volume (in base currency terms) within the interval |
| data[0].interval_begin | string | RFC3339 timestamp marking interval start |
| data[0].interval | integer | Timeframe in minutes |
| data[0].timestamp | string | **Deprecated.** Use `interval_begin` instead. RFC3339 timestamp. |

## Snapshot vs Update Behavior

- **Snapshot:** Delivered once after subscription (if `snapshot: true`), containing historical candle data for the current interval.
- **Update:** Streamed subsequently on each trade event, reflecting real-time candle modifications for the current interval.
- Both share the same schema -- the only difference is the `type` field.

## Example Messages

### Subscribe Request

```json
{
  "method": "subscribe",
  "params": {
    "channel": "ohlc",
    "symbol": ["ALGO/USD", "MATIC/USD"],
    "interval": 5
  }
}
```

### Snapshot Response

```json
{
  "channel": "ohlc",
  "type": "snapshot",
  "timestamp": "2023-10-04T16:26:01.806315597Z",
  "data": [
    {
      "symbol": "ALGO/USD",
      "open": 0.09875,
      "high": 0.09875,
      "low": 0.09875,
      "close": 0.09875,
      "trades": 1,
      "volume": 201.86015,
      "vwap": 0.09875,
      "interval_begin": "2023-10-04T15:25:00.000000000Z",
      "interval": 5,
      "timestamp": "2023-10-04T15:30:00.000000Z"
    }
  ]
}
```

### Update Response

```json
{
  "channel": "ohlc",
  "type": "update",
  "timestamp": "2023-10-04T16:26:30.524394914Z",
  "data": [
    {
      "symbol": "MATIC/USD",
      "open": 0.5624,
      "high": 0.5628,
      "low": 0.5622,
      "close": 0.5627,
      "trades": 12,
      "volume": 30927.68066226,
      "vwap": 0.5626,
      "interval_begin": "2023-10-04T16:25:00.000000000Z",
      "interval": 5,
      "timestamp": "2023-10-04T16:30:00.000000Z"
    }
  ]
}
```

### Unsubscribe Request

```json
{
  "method": "unsubscribe",
  "params": {
    "channel": "ohlc",
    "symbol": ["ALGO/USD", "MATIC/USD"],
    "interval": 5
  }
}
```

### Unsubscribe Acknowledgment

```json
{
  "method": "unsubscribe",
  "result": {
    "channel": "ohlc",
    "interval": 5,
    "symbol": "ALGO/USD"
  },
  "success": true,
  "time_in": "2023-10-04T16:26:01.802708Z",
  "time_out": "2023-10-04T16:26:01.802791Z"
}
```

## Unsubscribe Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `unsubscribe` |
| params.channel | string | Yes | Value: `ohlc` |
| params.symbol | array of strings | Yes | Currency pairs to unsubscribe |
| params.interval | integer | No | Timeframe in minutes (matches subscription interval) |
| params.req_id | integer | No | Client request identifier |

## Rate Limits

Not explicitly documented for this channel.

## Notes

- The `timestamp` field inside the data object is deprecated; use `interval_begin` instead.
- Each symbol receives its own subscribe/unsubscribe acknowledgment.
- The subscribe acknowledgment may include warnings about deprecated fields.
