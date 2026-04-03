# Trade

> Source: https://docs.kraken.com/api/docs/futures-api/websocket/trade

## Overview

The trade feed returns information about executed trades. Upon subscription, a snapshot of recent trades is delivered, followed by real-time delta updates for each new trade.

## Connection

- **Endpoint:** `wss://futures.kraken.com/ws/v1`
- **Feed:** `trade`

## Authentication

No authentication required. This is a public market data channel.

## Request/Subscription Format

```json
{
  "event": "subscribe",
  "feed": "trade",
  "product_ids": ["PI_XBTUSD"]
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| event | string | Yes | `subscribe` or `unsubscribe` |
| feed | string | Yes | The requested subscription feed: `trade` |
| product_ids | list of strings | Yes | Product identifiers for subscriptions |

## Subscription Confirmation

```json
{
  "event": "subscribed",
  "feed": "trade",
  "product_ids": ["PI_XBTUSD"]
}
```

## Snapshot Response Format

```json
{
  "feed": "trade_snapshot",
  "product_id": "PI_XBTUSD",
  "trades": [
    {
      "uid": "caa9c653-420b-4c24-a9f1-462a054d86f1",
      "side": "sell",
      "type": "fill",
      "seq": 655508,
      "time": 1612269657781,
      "qty": 440,
      "price": 34893
    }
  ]
}
```

## Delta Update Format

```json
{
  "feed": "trade",
  "product_id": "PI_XBTUSD",
  "uid": "05af78ac-a774-478c-a50c-8b9c234e071e",
  "side": "sell",
  "type": "fill",
  "seq": 653355,
  "time": 1612266317519,
  "qty": 15000,
  "price": 34969.5
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| feed | string | Feed identifier (`trade_snapshot` or `trade`) |
| product_id | string | Instrument/symbol identifier |
| trades | list | Array of trade objects (snapshot only) |
| uid | string | Unique trade identifier |
| side | string | Taker classification: `buy` or `sell` |
| type | string | Trade classification: `fill`, `liquidation`, `termination`, or `block` |
| seq | positive integer | Subscription message sequence number |
| time | positive integer | UTC/GMT timestamp in milliseconds |
| qty | positive float | Traded quantity |
| price | positive float | Trade price |

## Error Response

```json
{
  "event": "error",
  "message": "Invalid product id"
}
```

### Error Messages

- `Invalid product id`
- `Invalid feed`
- `Json Error`
