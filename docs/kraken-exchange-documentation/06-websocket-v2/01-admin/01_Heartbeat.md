# Heartbeat

> Source: https://docs.kraken.com/api/docs/websocket-v2/heartbeat

## Overview

The heartbeat channel serves as a connection verification mechanism. Heartbeat messages are sent approximately once every second in the absence of any other channel updates.

## Connection

- **Endpoint:** `wss://ws.kraken.com/v2`
- **Channel:** `heartbeat`

## Authentication

No authentication required. Heartbeats are automatic.

## Request/Subscription Format

There is no option to directly request a heartbeat subscription. Heartbeats are automatically generated on subscription to any channel.

## Response/Update Format

```json
{
  "channel": "heartbeat"
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| channel | string | Value: `heartbeat` |

## Snapshot vs Update Behavior

Not applicable. Heartbeat messages have no snapshot/update distinction -- they are simple connection health check signals.

## Example Messages

### Heartbeat Message

```json
{
  "channel": "heartbeat"
}
```

## Rate Limits

Not applicable. Messages are server-initiated.

## Notes

- Heartbeats serve as a simple connection health check.
- No additional payload data accompanies the channel identifier -- the message is just `{"channel": "heartbeat"}`.
- Messages transmit automatically when subscribing to any channel.
- Frequency is approximately one message per second, but only when no other channel activity occurs. If other channels are actively sending data, heartbeats may not be sent.
- Use heartbeats to detect stale connections. If no heartbeat (or any other message) is received for an extended period, the connection may be dead and should be reconnected.
