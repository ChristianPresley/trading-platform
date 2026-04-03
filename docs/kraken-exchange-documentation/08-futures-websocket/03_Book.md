# Book

> Source: https://docs.kraken.com/api/docs/futures-api/websocket/book

## Overview

The book feed returns information about the order book. Upon subscription, a full order book snapshot is delivered, followed by incremental delta updates as the order book changes.

## Connection

- **Endpoint:** `wss://futures.kraken.com/ws/v1`
- **Feed:** `book`

## Authentication

No authentication required. This is a public market data channel.

## Request/Subscription Format

```json
{
  "event": "subscribe",
  "feed": "book",
  "product_ids": ["PI_XBTUSD"]
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| event | string | Yes | `subscribe` or `unsubscribe` |
| feed | string | Yes | The requested subscription feed: `book` |
| product_ids | list of strings | Yes | List of product identifiers for receiving information |

## Subscription Confirmation

```json
{
  "event": "subscribed",
  "feed": "book",
  "product_ids": ["PI_XBTUSD"]
}
```

| Field | Type | Description |
|-------|------|-------------|
| event | string | Result: `subscribed`, `subscribed_failed`, `unsubscribed`, or `unsubscribed_failed` |
| feed | string | The subscribed feed name |
| product_ids | list of strings | Products subscribed to |

## Snapshot Response Format

Upon subscription, a full snapshot of the order book is delivered:

```json
{
  "feed": "book_snapshot",
  "product_id": "PI_XBTUSD",
  "timestamp": 1612269825817,
  "seq": 326072249,
  "tickSize": null,
  "bids": [
    {"price": 34892.5, "qty": 6385},
    {"price": 34892, "qty": 10924}
  ],
  "asks": [
    {"price": 34911.5, "qty": 20598},
    {"price": 34912, "qty": 2300}
  ]
}
```

### Snapshot Fields

| Field | Type | Description |
|-------|------|-------------|
| feed | string | The feed name (`book_snapshot`) |
| product_id | string | The subscribed product/instrument/symbol |
| seq | positive integer | Subscription message sequence number |
| timestamp | positive integer | Timestamp in milliseconds |
| tickSize | string | Always null |
| bids | list of objects | Bid entries with `price` and `qty` |
| asks | list of objects | Ask entries with `price` and `qty` |

## Delta Update Format

After the snapshot, incremental updates are sent for each order book change:

```json
{
  "feed": "book",
  "product_id": "PI_XBTUSD",
  "side": "sell",
  "seq": 326094134,
  "price": 34981,
  "qty": 0,
  "timestamp": 1612269953629
}
```

### Delta Fields

| Field | Type | Description |
|-------|------|-------------|
| feed | string | The feed name (`book`) |
| product_id | string | The subscribed product |
| seq | positive integer | Subscription message sequence number |
| timestamp | positive integer | Timestamp in milliseconds |
| side | string | Entry side: `buy` or `sell` |
| price | positive float | Entry price |
| qty | positive float | Entry quantity (0 means price level removed) |

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
