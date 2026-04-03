# Ticker (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/ticker

## Overview

The Ticker channel provides Level 1 ticker information on currency pairs. It streams real-time price, volume, and trade statistics for subscribed pairs.

**Endpoint:** `wss://ws.kraken.com`
**Channel Name:** `ticker`

## Authentication

Not required. This is a public market data channel.

## Subscription Format

```json
{
  "event": "subscribe",
  "pair": ["XBT/EUR"],
  "subscription": {
    "name": "ticker"
  }
}
```

## Subscription Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | Yes | Must be `"subscribe"` |
| `pair` | array of strings | Yes | Currency pairs to subscribe to (e.g., `["BTC/USD", "MATIC/GBP"]`) |
| `subscription.name` | string | Yes | Must be `"ticker"` |
| `reqid` | string | No | Client-originated request identifier echoed in acknowledgment response |

## Response/Update Format

Responses are arrays with four elements:

```
[channel_id, ticker_object, channel_name, pair]
```

### Array Elements

| Position | Field | Type | Description |
|----------|-------|------|-------------|
| 0 | `channel_id` | integer | **Deprecated.** Use `channel_name` and `pair` instead |
| 1 | `ticker` | object | Ticker data object (see fields below) |
| 2 | `channel_name` | string | Always `"ticker"` |
| 3 | `pair` | string | Currency pair symbol (e.g., `"XBT/USD"`) |

### Ticker Object Fields

| Field | Type | Description |
|-------|------|-------------|
| `a` | array | Best Ask: `[price, whole_lot_volume, lot_volume]` |
| `b` | array | Best Bid: `[price, whole_lot_volume, lot_volume]` |
| `c` | array | Last Trade Close: `[price, lot_volume]` |
| `v` | array | Volume: `[value_today, value_last_24_hours]` |
| `p` | array | Volume Weighted Average Price (VWAP): `[today, last_24_hours]` |
| `t` | array | Number of Trades: `[today, last_24_hours]` |
| `l` | array | Low Price: `[today, last_24_hours]` |
| `h` | array | High Price: `[today, last_24_hours]` |
| `o` | array | Open Price: `[today, last_24_hours]` |

## Example Messages

### Subscribe Request

```json
{
  "event": "subscribe",
  "pair": ["XBT/EUR"],
  "subscription": {
    "name": "ticker"
  }
}
```

### Ticker Update

```json
[
  0,
  {
    "a": ["5525.40000", 1, "1.000"],
    "b": ["5525.10000", 1, "1.000"],
    "c": ["5525.10000", "0.00398963"],
    "h": ["5783.00000", "5783.00000"],
    "l": ["5505.00000", "5505.00000"],
    "o": ["5760.70000", "5763.40000"],
    "p": ["5631.44067", "5653.78939"],
    "t": [11493, 16267],
    "v": ["2634.11501494", "3591.17907851"]
  },
  "ticker",
  "XBT/USD"
]
```

## Notes

- The `channel_id` (position 0) is deprecated. Use `channel_name` and `pair` for channel identification.
- All price and volume values are returned as strings.
- The `today` and `last_24_hours` values in array fields (`v`, `p`, `t`, `l`, `h`, `o`) represent rolling windows.
- This is a WebSocket v1 channel. Kraken recommends migrating to WebSocket v2 for new implementations.
