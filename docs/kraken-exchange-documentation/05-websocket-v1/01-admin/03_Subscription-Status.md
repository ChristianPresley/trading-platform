# Subscription Status (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/subscriptionstatus

## Overview

The `subscriptionStatus` event is a response message confirming subscription, unsubscription, or exchange-initiated unsubscribe actions. It is sent in response to `subscribe` and `unsubscribe` requests.

**Endpoint:** `wss://ws.kraken.com`
**Event:** `subscriptionStatus`

## Authentication

Not required for public channel subscription confirmations. Private channel confirmations (`openOrders`, `ownTrades`) are sent on the authenticated endpoint `wss://ws-auth.kraken.com`.

## Request/Subscription Format

This is a response event, not a request. It is automatically sent in response to `subscribe` and `unsubscribe` requests.

## Response Format

```json
{
  "channelID": 10001,
  "channelName": "ticker",
  "event": "subscriptionStatus",
  "pair": "XBT/EUR",
  "status": "subscribed",
  "subscription": {
    "name": "ticker"
  }
}
```

## Response Fields

| Field | Type | Condition | Description |
|-------|------|-----------|-------------|
| `event` | string | Always | Fixed value: `"subscriptionStatus"` |
| `channelName` | string | Always | Channel type: `book`, `ohlc`, `openOrders`, `ownTrades`, `spread`, `ticker`, `trade`, or `*` |
| `status` | string | Always | Result status (see status values below) |
| `subscription` | object | Always | Contains subscription details (see below) |
| `pair` | string | Public channels | Currency pair (e.g., `"BTC/USD"`). Omitted for authenticated channels |
| `channelID` | integer | Public channels | Channel ID for public subscriptions. **Deprecated** |
| `reqid` | integer | If provided | Client-originated request identifier echoed from the subscribe/unsubscribe request |
| `errorMessage` | string | On error | Error description (present only when `status` is `"error"`) |

## Status Values

| Status | Description |
|--------|-------------|
| `subscribed` | Successful subscription |
| `unsubscribed` | Successful unsubscription |
| `ok` | General confirmation |
| `error` | Operation failed (see `errorMessage` for details) |

## Subscription Object Fields

| Field | Type | Condition | Description |
|-------|------|-----------|-------------|
| `name` | string | Always | Channel name matching `channelName` |
| `depth` | integer | Book channel only | Order book depth level |
| `interval` | integer | OHLC channel only | Candlestick interval in minutes |
| `maxratecount` | integer | If applicable | Rate counter value |
| `token` | string | Authenticated channels only | Authentication token for private channels |

## Example Messages

### Successful Ticker Subscription

```json
{
  "channelID": 10001,
  "channelName": "ticker",
  "event": "subscriptionStatus",
  "pair": "XBT/EUR",
  "status": "subscribed",
  "subscription": {
    "name": "ticker"
  }
}
```

### OHLC Unsubscription

```json
{
  "channelID": 10001,
  "channelName": "ohlc-5",
  "event": "subscriptionStatus",
  "pair": "XBT/EUR",
  "reqid": 42,
  "status": "unsubscribed",
  "subscription": {
    "interval": 5,
    "name": "ohlc"
  }
}
```

### Private Authenticated Subscription

```json
{
  "channelName": "ownTrades",
  "event": "subscriptionStatus",
  "status": "subscribed",
  "subscription": {
    "name": "ownTrades"
  }
}
```

### Error Response

```json
{
  "errorMessage": "Subscription depth not supported",
  "event": "subscriptionStatus",
  "pair": "XBT/USD",
  "status": "error",
  "subscription": {
    "depth": 42,
    "name": "book"
  }
}
```

## Notes

- Public subscriptions include `channelID` and `pair` fields; authenticated subscriptions omit them.
- The `channelID` field is deprecated. Use `channelName` and `pair` for identification.
- The `errorMessage` field is only present when `status` is `"error"`.
- The `subscription` object mirrors the parameters sent in the original subscribe/unsubscribe request, plus any server-added fields like `maxratecount`.
- For OHLC channels, `channelName` includes the interval suffix (e.g., `"ohlc-5"`).
- For book channels, `channelName` includes the depth suffix (e.g., `"book-10"`).
- This is a WebSocket v1 event. Kraken recommends migrating to WebSocket v2 for new implementations.
