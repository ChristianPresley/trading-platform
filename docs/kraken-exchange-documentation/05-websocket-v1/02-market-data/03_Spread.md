# Spread (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/spread

## Overview

The Spread channel provides real-time best bid/ask spread data for currency pairs, including bid and ask volumes.

**Endpoint:** `wss://ws.kraken.com`
**Channel Name:** `spread`

## Authentication

Not required. This is a public market data channel.

## Subscription Format

```json
{
  "event": "subscribe",
  "pair": ["XBT/EUR"],
  "subscription": {
    "name": "spread"
  }
}
```

## Subscription Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | Yes | Must be `"subscribe"` |
| `pair` | array of strings | Yes | Currency pairs to subscribe to (e.g., `["BTC/USD", "MATIC/GBP"]`) |
| `subscription.name` | string | Yes | Must be `"spread"` |
| `reqid` | string | No | Client-originated request identifier echoed in acknowledgment response |

## Response/Update Format

Responses are arrays with four elements:

```
[channel_id, spread_array, channel_name, pair]
```

### Array Elements

| Position | Field | Type | Description |
|----------|-------|------|-------------|
| 0 | `channel_id` | integer | **Deprecated.** Use `channel_name` and `pair` instead |
| 1 | `spread` | array | Spread data array with 5 elements (see below) |
| 2 | `channel_name` | string | Always `"spread"` |
| 3 | `pair` | string | Currency pair symbol (e.g., `"XBT/USD"`) |

### Spread Data Array (Position 1)

| Index | Field | Type | Description |
|-------|-------|------|-------------|
| 0 | `bid` | string | Best bid price |
| 1 | `ask` | string | Best ask price |
| 2 | `timestamp` | string | Unix epoch timestamp in seconds with microsecond precision |
| 3 | `bid_volume` | string | Bid volume at best bid |
| 4 | `ask_volume` | string | Ask volume at best ask |

## Example Messages

### Subscribe Request

```json
{
  "event": "subscribe",
  "pair": ["XBT/EUR"],
  "subscription": {
    "name": "spread"
  }
}
```

### Spread Update

```json
[
  0,
  [
    "5698.40000",
    "5700.00000",
    "1542057299.545897",
    "1.01234567",
    "0.98765432"
  ],
  "spread",
  "XBT/USD"
]
```

## Notes

- The `channel_id` (position 0) is deprecated. Use `channel_name` and `pair` for channel identification.
- All price, volume, and timestamp values are returned as strings.
- This is a WebSocket v1 channel. Kraken recommends migrating to WebSocket v2 for new implementations.
