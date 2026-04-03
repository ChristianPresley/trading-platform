# Unsubscribe (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/unsubscribe

## Overview

The `unsubscribe` method terminates subscriptions to WebSocket channels. It supports unsubscribing from specific currency pairs or using a wildcard (`*`) to unsubscribe from all channels.

**Endpoint:** `wss://ws.kraken.com`
**Event:** `unsubscribe`

## Authentication

Not required for public channels. For private channels (`openOrders`, `ownTrades`), the token must have been provided at subscription time.

## Request Format

```json
{
  "event": "unsubscribe",
  "pair": ["XBT/EUR", "XBT/USD"],
  "subscription": {
    "name": "ticker"
  }
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | Yes | Must be `"unsubscribe"` |
| `subscription.name` | string | Yes | Channel name to unsubscribe from: `book`, `ohlc`, `openOrders`, `ownTrades`, `spread`, `ticker`, `trade`, or `*` (wildcard for all) |
| `pair` | array of strings | Conditional | Currency pair symbols (e.g., `["BTC/USD", "MATIC/GBP"]`). Required for channels that support pair subscriptions |
| `subscription.depth` | integer | Conditional | Order book depth level. Required when unsubscribing from a specific `book` depth |
| `subscription.interval` | integer | Conditional | OHLC interval in minutes. Required when unsubscribing from a specific `ohlc` interval |
| `reqid` | string | No | Client-originated request identifier echoed in acknowledgment response |

## Response Format

The response to an unsubscribe request is a `subscriptionStatus` event with `status: "unsubscribed"`. See the [Subscription Status](../admin/subscription-status.md) documentation for full response details.

## Example Messages

### Unsubscribe from Ticker

```json
{
  "event": "unsubscribe",
  "pair": ["XBT/EUR", "XBT/USD"],
  "subscription": {
    "name": "ticker"
  }
}
```

### Unsubscribe from Book (Specific Depth)

```json
{
  "event": "unsubscribe",
  "pair": ["XBT/USD"],
  "subscription": {
    "name": "book",
    "depth": 10
  }
}
```

### Unsubscribe from OHLC (Specific Interval)

```json
{
  "event": "unsubscribe",
  "pair": ["XBT/USD"],
  "subscription": {
    "name": "ohlc",
    "interval": 5
  }
}
```

### Unsubscribe from All Channels (Wildcard)

```json
{
  "event": "unsubscribe",
  "subscription": {
    "name": "*"
  }
}
```

## Notes

- The wildcard `*` for `subscription.name` unsubscribes from all active channels.
- When unsubscribing from the `book` channel, specify the `depth` if you subscribed with a specific depth.
- When unsubscribing from the `ohlc` channel, specify the `interval` if you subscribed with a specific interval.
- The response is delivered as a `subscriptionStatus` event (not a dedicated unsubscribe response event).
- This is a WebSocket v1 method. Kraken recommends migrating to WebSocket v2 for new implementations.
