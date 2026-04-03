# Cancel All Orders After X (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/cancelallordersafter

## Overview

The `cancelAllOrdersAfter` method implements a "Dead Man's Switch" mechanism. It sets a countdown timer that automatically cancels all client orders when expired, protecting against network issues or system downtime. The timer must be continuously refreshed or explicitly disabled (by setting timeout to 0).

**Endpoint:** `wss://ws-auth.kraken.com`
**Event:** `cancelAllOrdersAfter`

## Authentication

**Required.** A valid session token must be provided in the `token` field.

## Request Format

```json
{
  "event": "cancelAllOrdersAfter",
  "reqid": 1608543428050,
  "timeout": 60,
  "token": "0000000000000000000000000000000000000000"
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | Yes | Must be `"cancelAllOrdersAfter"` |
| `timeout` | integer | Yes | Countdown duration in seconds. Use `0` to disable the timer |
| `token` | string | Yes | Authenticated session token |
| `reqid` | integer | No | Client-originated request identifier echoed in response |

## Response Format

### Response Fields

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| `event` | string | - | Always `"cancelAllOrdersAfterStatus"` |
| `currentTime` | string | RFC3339 | When the request was processed (second precision, rounded up) |
| `triggerTime` | string | RFC3339 | When all orders will be cancelled unless extended or disabled. Value `"0"` when timer is disabled |
| `status` | string | - | `"ok"` or `"error"` |
| `reqid` | integer | - | Client-originated identifier from request (if provided) |
| `errorMessage` | string | - | Error description (present only when `status` is `"error"`) |

## Example Messages

### Request (Enable Timer - 60 seconds)

```json
{
  "event": "cancelAllOrdersAfter",
  "reqid": 1608543428050,
  "timeout": 60,
  "token": "0000000000000000000000000000000000000000"
}
```

### Success Response (Timer Enabled)

```json
{
  "currentTime": "2020-12-21T09:37:09Z",
  "event": "cancelAllOrdersAfterStatus",
  "reqid": 1608543428050,
  "status": "ok",
  "triggerTime": "2020-12-21T09:38:09Z"
}
```

### Request (Disable Timer)

```json
{
  "event": "cancelAllOrdersAfter",
  "reqid": 1608543428051,
  "timeout": 0,
  "token": "0000000000000000000000000000000000000000"
}
```

### Success Response (Timer Disabled)

```json
{
  "currentTime": "2020-12-21T09:37:09Z",
  "event": "cancelAllOrdersAfterStatus",
  "reqid": 1608543428051,
  "status": "ok",
  "triggerTime": "0"
}
```

## Notes

- **Recommended usage pattern:** Send a call every 15 to 30 seconds with a timeout of 60 seconds. This maintains order protection during brief disconnections while preventing false triggers.
- When the timer expires, all orders are cancelled and the mechanism remains inactive until a new non-zero timeout is provided.
- The timer should be disabled before scheduled maintenance windows.
- Setting `timeout` to `0` explicitly disables the Dead Man's Switch.
- The `triggerTime` value of `"0"` in the response indicates the timer is disabled.
- This is a WebSocket v1 method. Kraken recommends migrating to WebSocket v2 for new implementations.
