# System Status (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/systemstatus

## Overview

The `systemStatus` event provides information about the current state of Kraken's trading engine. It is sent automatically on connection and whenever the system status changes. This is a server-initiated event -- no subscription is required.

**Endpoint:** `wss://ws.kraken.com`
**Event:** `systemStatus`

## Authentication

Not required. This event is sent automatically on all connections.

## Request/Subscription Format

No subscription is needed. The `systemStatus` event is sent automatically on connection and on system status changes.

## Response Format

```json
{
  "connectionID": 8628615390848610000,
  "event": "systemStatus",
  "status": "online",
  "version": "1.9.1"
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `event` | string | Always `"systemStatus"` |
| `status` | string | Current operational state of the trading engine (see status values below) |
| `version` | string | Version identifier of the WebSocket service |
| `connectionID` | integer | Unique connection identifier for debugging purposes |

## Status Values

| Status | Description |
|--------|-------------|
| `online` | Markets operating normally. All order types accepted and order matching occurs |
| `maintenance` | Markets offline for scheduled maintenance. New orders blocked, cancellations blocked |
| `cancel_only` | Order cancellations permitted. New orders blocked, no matching occurs |
| `post_only` | Only limit orders with `post_only` option accepted. Cancellations permitted, no matching occurs |

## Example Messages

### System Online

```json
{
  "connectionID": 8628615390848610000,
  "event": "systemStatus",
  "status": "online",
  "version": "1.9.1"
}
```

## Notes

- The `systemStatus` event is sent immediately upon WebSocket connection, providing the current state.
- Subsequent `systemStatus` events are sent only when the trading engine status transitions (e.g., from `online` to `maintenance`).
- The `connectionID` can be used for debugging and support requests.
- During `maintenance` status, both new orders and cancellations are blocked.
- During `cancel_only` status, only cancellations are processed.
- During `post_only` status, only post-only limit orders are accepted.
- This is a WebSocket v1 event. Kraken recommends migrating to WebSocket v2 for new implementations.
