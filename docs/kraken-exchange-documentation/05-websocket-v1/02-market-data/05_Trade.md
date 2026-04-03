# Trade (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/trade

## Overview

The Trade channel provides a real-time trade feed for currency pairs. Each message contains one or more trade executions that occurred on the exchange.

**Endpoint:** `wss://ws.kraken.com`
**Channel Name:** `trade`

## Authentication

Not required. This is a public market data channel.

## Subscription Format

```json
{
  "event": "subscribe",
  "pair": ["XBT/EUR"],
  "subscription": {
    "name": "trade"
  }
}
```

## Subscription Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | Yes | Must be `"subscribe"` |
| `pair` | array of strings | Yes | Currency pairs to subscribe to (e.g., `["BTC/USD", "MATIC/GBP"]`) |
| `subscription.name` | string | Yes | Must be `"trade"` |
| `reqid` | string | No | Client-originated request identifier echoed in acknowledgment response |

## Response/Update Format

Responses are arrays with four elements:

```
[channel_id, trades_array, channel_name, pair]
```

### Array Elements

| Position | Field | Type | Description |
|----------|-------|------|-------------|
| 0 | `channel_id` | integer | **Deprecated.** Use `channel_name` and `pair` instead |
| 1 | `trades` | array | Array of trade records (see below) |
| 2 | `channel_name` | string | Always `"trade"` |
| 3 | `pair` | string | Currency pair symbol (e.g., `"XBT/USD"`) |

### Trade Record Array (each element in Position 1)

| Index | Field | Type | Description |
|-------|-------|------|-------------|
| 0 | `price` | string | Trade execution price |
| 1 | `volume` | string | Trade volume |
| 2 | `time` | string | Trade timestamp in seconds since epoch with microsecond precision |
| 3 | `side` | string | Taker side: `"b"` (buy) or `"s"` (sell) |
| 4 | `order_type` | string | Taker order type: `"m"` (market) or `"l"` (limit) |
| 5 | `misc` | string | Miscellaneous field (typically empty string) |

## Example Messages

### Subscribe Request

```json
{
  "event": "subscribe",
  "pair": ["XBT/EUR"],
  "subscription": {
    "name": "trade"
  }
}
```

### Trade Update

```json
[
  0,
  [
    [
      "5541.20000",
      "0.15850568",
      "1534614057.321597",
      "s",
      "l",
      ""
    ],
    [
      "6060.00000",
      "0.02455000",
      "1534614057.324998",
      "b",
      "l",
      ""
    ]
  ],
  "trade",
  "XBT/USD"
]
```

## Notes

- Multiple trades can be included in a single message (the trades array at position 1 may contain more than one trade record).
- The `side` field uses single-character abbreviations: `"b"` for buy, `"s"` for sell.
- The `order_type` field uses single-character abbreviations: `"m"` for market, `"l"` for limit.
- The `channel_id` (position 0) is deprecated. Use `channel_name` and `pair` for channel identification.
- All price, volume, and timestamp values are returned as strings.
- This is a WebSocket v1 channel. Kraken recommends migrating to WebSocket v2 for new implementations.
