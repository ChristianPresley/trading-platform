# Heartbeat (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/heartbeat

## Overview

The heartbeat is a server-originated keepalive event sent when there is no subscription traffic within approximately 1 second. It maintains connection liveness and prevents timeout disconnections.

**Endpoint:** `wss://ws.kraken.com`
**Event:** `heartbeat`

## Authentication

Not required. Heartbeats are sent automatically on all connections.

## Request/Subscription Format

No subscription is needed. Heartbeats are sent automatically by the server.

## Response Format

```json
{
  "event": "heartbeat"
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `event` | string | Always `"heartbeat"` |

## Example Messages

### Heartbeat Event

```json
{
  "event": "heartbeat"
}
```

## Notes

- **Frequency:** Approximately every 1 second when no subscription traffic is occurring.
- **Direction:** Server-to-client only. No client response is required.
- **Purpose:** Maintains connection liveness and prevents timeout disconnections during periods of inactivity.
- Heartbeats are only sent when there is no other subscription data flowing. If active market data or other events are being delivered, heartbeats are suppressed.
- This is a WebSocket v1 event. Kraken recommends migrating to WebSocket v2 for new implementations.
