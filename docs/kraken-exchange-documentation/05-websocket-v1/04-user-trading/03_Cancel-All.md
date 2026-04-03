# Cancel All Orders (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/cancelall

## Overview

The `cancelAll` method cancels all open orders on the authenticated WebSocket connection, including partially-filled orders.

**Endpoint:** `wss://ws-auth.kraken.com`
**Event:** `cancelAll`

## Authentication

**Required.** A valid session token must be provided in the `token` field.

## Request Format

```json
{
  "event": "cancelAll",
  "token": "0000000000000000000000000000000000000000"
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | Yes | Must be `"cancelAll"` |
| `token` | string | Yes | Authenticated session token |
| `reqid` | integer | No | Client-originated request identifier echoed in response |

## Response Format

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `event` | string | `"cancelAllStatus"` |
| `count` | string | Number of orders cancelled |
| `status` | string | `"ok"` or `"error"` |
| `reqid` | integer | Client-originated identifier from request (if provided) |
| `errorMessage` | string | Error description (present only when `status` is `"error"`) |

## Example Messages

### Request

```json
{
  "event": "cancelAll",
  "token": "0000000000000000000000000000000000000000"
}
```

### Success Response

```json
{
  "count": 2,
  "event": "cancelAllStatus",
  "status": "ok"
}
```

## Notes

- This cancels all open orders for the account, including partially-filled orders.
- The `count` field in the response indicates how many orders were cancelled.
- This is a WebSocket v1 method. Kraken recommends migrating to WebSocket v2 for new implementations.
