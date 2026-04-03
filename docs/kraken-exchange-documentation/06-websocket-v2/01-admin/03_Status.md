# Status

> Source: https://docs.kraken.com/api/docs/websocket-v2/status

## Overview

The Status channel provides a mechanism to verify exchange status and successful initial connection. Status updates are automatically generated upon successful WebSocket connection and when the trading engine status changes. There is no option to directly request a status update or subscribe to this channel -- it is automatic.

## Connection

- **Endpoint:** `wss://ws.kraken.com/v2`
- **Channel:** `status`

## Authentication

No authentication required. Status messages are sent automatically on connection.

## Request/Subscription Format

There is no subscription request for this channel. Status updates are automatically sent upon connection and when the engine status changes.

## Response/Update Format

```json
{
  "channel": "status",
  "type": "update",
  "data": [
    {
      "api_version": "v2",
      "connection_id": 13834774380200032777,
      "system": "online",
      "version": "2.0.0"
    }
  ]
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| channel | string | Value: `status` |
| type | string | Value: `update` |
| data[0].system | string | Trading engine operational state (see System States table) |
| data[0].api_version | string | Value: `v2` |
| data[0].connection_id | integer | Unique connection identifier for debugging |
| data[0].version | string | WebSocket service version number |

## System States

| State | Description |
|-------|-------------|
| `online` | Markets are operating normally. All order types may be submitted and order matching can occur. |
| `maintenance` | Markets are offline for scheduled maintenance. New orders cannot be placed and existing orders cannot be cancelled. |
| `cancel_only` | Orders can be cancelled but new orders cannot be placed. No order matching will occur. |
| `post_only` | Only limit orders using the `post_only` option can be submitted. |

## Snapshot vs Update Behavior

- The initial status message is sent automatically upon WebSocket connection.
- Subsequent messages are sent when the trading engine status changes.
- All messages have `type: "update"` -- there is no snapshot type for this channel.

## Example Messages

### Status Update (Online)

```json
{
  "channel": "status",
  "data": [
    {
      "api_version": "v2",
      "connection_id": 13834774380200032777,
      "system": "online",
      "version": "2.0.0"
    }
  ],
  "type": "update"
}
```

## Rate Limits

Not applicable. Messages are server-initiated.

## Notes

- This channel cannot be subscribed to or unsubscribed from -- it is always active.
- The `connection_id` is useful for debugging and support communication.
- The first message received on any new WebSocket connection will be a status message.
- Monitor `system` state transitions to adjust trading behavior (e.g., stop submitting orders during `maintenance` or `cancel_only`).
