# Ping/Pong (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/ping

## Overview

The ping/pong mechanism allows clients to verify that the WebSocket connection is alive. The client sends a `ping` event and the server responds with a `pong` event. This is an application-level ping, as opposed to the default ping in the WebSocket standard which is server-initiated.

**Endpoint:** `wss://ws.kraken.com`
**Event:** `ping` / `pong`

## Authentication

Not required. Available on both public and authenticated endpoints.

## Request Format

```json
{
  "event": "ping",
  "reqid": 42
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | Yes | Must be `"ping"` |
| `reqid` | integer | No | Client-originated request identifier echoed in response for correlation |

## Response Format

```json
{
  "event": "pong",
  "reqid": 42
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `event` | string | Always `"pong"` |
| `reqid` | integer | Client-originated identifier from the request (if provided) |

## Example Messages

### Ping Request

```json
{
  "event": "ping",
  "reqid": 42
}
```

### Pong Response

```json
{
  "event": "pong",
  "reqid": 42
}
```

## Notes

- This is an application-level ping/pong, distinct from the WebSocket protocol-level ping/pong frames.
- The `reqid` field is optional in requests but will be echoed back in responses for request/response correlation.
- This is a WebSocket v1 method. Kraken recommends migrating to WebSocket v2 for new implementations.
