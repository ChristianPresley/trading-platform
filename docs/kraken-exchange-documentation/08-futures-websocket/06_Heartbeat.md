# Heartbeat

> Source: https://docs.kraken.com/api/docs/futures-api/websocket/heartbeat

## Overview

The heartbeat feed publishes a heartbeat message at timed intervals. This can be used to monitor connection health and detect disconnections.

## Connection

- **Endpoint:** `wss://futures.kraken.com/ws/v1`
- **Feed:** `heartbeat`

## Authentication

No authentication required. This is a public channel.

## Request/Subscription Format

```json
{
  "event": "subscribe",
  "feed": "heartbeat"
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| event | string | Yes | `subscribe` or `unsubscribe` |
| feed | string | Yes | The requested subscription feed: `heartbeat` |

## Subscription Confirmation

```json
{
  "event": "subscribed",
  "feed": "heartbeat"
}
```

## Response/Update Format

```json
{
  "feed": "heartbeat",
  "time": 1534262350627
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| feed | string | The subscribed feed: `heartbeat` |
| time | positive integer | The UTC time of the server in milliseconds |

## Error Response

```json
{
  "event": "error",
  "message": "Json Error"
}
```

### Error Messages

- `Invalid feed`
- `Json Error`
