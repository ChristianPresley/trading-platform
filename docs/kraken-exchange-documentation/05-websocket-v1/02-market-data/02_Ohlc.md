# OHLC (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/ohlc

## Overview

The OHLC channel provides Open High Low Close (Candle) feed for a currency pair and interval period. When subscribing, a snapshot of the most recent valid candle (irrespective of end time) is sent first, followed by updates to the active candle regardless of trade activity.

**Endpoint:** `wss://ws.kraken.com`
**Channel Name:** `ohlc`

## Authentication

Not required. This is a public market data channel.

## Subscription Format

```json
{
  "event": "subscribe",
  "pair": ["XBT/EUR"],
  "subscription": {
    "interval": 5,
    "name": "ohlc"
  }
}
```

## Subscription Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | Yes | Must be `"subscribe"` |
| `pair` | array of strings | Yes | Currency pairs to subscribe to (e.g., `["BTC/USD", "MATIC/GBP"]`) |
| `subscription.name` | string | Yes | Must be `"ohlc"` |
| `subscription.interval` | integer | No | Candle interval in minutes. Default: `1` |
| `reqid` | string | No | Client-originated request identifier echoed in acknowledgment response |

### Supported Intervals (in minutes)

| Value | Period |
|-------|--------|
| `1` | 1 minute (default) |
| `5` | 5 minutes |
| `15` | 15 minutes |
| `30` | 30 minutes |
| `60` | 1 hour |
| `240` | 4 hours |
| `1440` | 1 day |
| `10080` | 1 week |
| `21600` | 15 days |

## Response/Update Format

Responses are arrays with four elements:

```
[channel_id, ohlc_array, channel_name, pair]
```

### Array Elements

| Position | Field | Type | Description |
|----------|-------|------|-------------|
| 0 | `channel_id` | integer | **Deprecated.** Use `channel_name` and `pair` instead |
| 1 | `ohlc` | array | Candle data array with 9 elements (see below) |
| 2 | `channel_name` | string | Format: `"ohlc-[interval]"` (e.g., `"ohlc-5"`) |
| 3 | `pair` | string | Currency pair symbol (e.g., `"XBT/USD"`) |

### OHLC Data Array (Position 1)

| Index | Field | Type | Description |
|-------|-------|------|-------------|
| 0 | `epoc_last` | string | Last update time in epoch seconds |
| 1 | `epoc_end` | string | Interval end time in epoch seconds |
| 2 | `open` | string | Opening price for the interval |
| 3 | `high` | string | Highest price during the interval |
| 4 | `low` | string | Lowest price during the interval |
| 5 | `close` | string | Closing (most recent) price |
| 6 | `vwap` | string | Volume weighted average price |
| 7 | `volume` | string | Accumulated volume during the interval |
| 8 | `count` | string | Number of trades during the interval |

## Example Messages

### Subscribe Request

```json
{
  "event": "subscribe",
  "pair": ["XBT/EUR"],
  "subscription": {
    "interval": 5,
    "name": "ohlc"
  }
}
```

### OHLC Update

```json
[
  42,
  [
    "1542057314.748456",
    "1542057360.435743",
    "3586.70000",
    "3586.70000",
    "3586.60000",
    "3586.60000",
    "3586.68894",
    "0.03373000",
    2
  ],
  "ohlc-5",
  "XBT/USD"
]
```

## Notes

- A snapshot of the last valid candle (irrespective of end time) is sent upon subscription, ensuring subscribers receive historical context even during low-activity periods.
- After the snapshot, updates to the currently active candle are streamed in real time.
- The `channel_id` (position 0) is deprecated. Use `channel_name` and `pair` for channel identification.
- The `channel_name` includes the interval suffix (e.g., `ohlc-1`, `ohlc-5`, `ohlc-60`).
- All numeric values in the OHLC array are returned as strings.
- This is a WebSocket v1 channel. Kraken recommends migrating to WebSocket v2 for new implementations.
