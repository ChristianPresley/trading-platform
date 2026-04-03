# Ping / Pong

> Source: https://docs.kraken.com/api/docs/websocket-v2/ping

## Overview

The ping method allows clients to verify an active connection. The server responds with a pong message. This is an application-level ping, separate from the protocol-level WebSocket standard ping/pong frames.

## Connection

- **Endpoint:** `wss://ws.kraken.com/v2`
- **Method:** `ping` / `pong`

## Authentication

No authentication required. Ping/pong works on both public and authenticated endpoints.

## Request Format

```json
{
  "method": "ping",
  "req_id": 101
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `ping` |
| req_id | integer | No | Client-originated request identifier that will be echoed in the response |

## Response Format

```json
{
  "method": "pong",
  "req_id": 101,
  "time_in": "2023-09-24T14:10:23.799685Z",
  "time_out": "2023-09-24T14:10:23.799703Z"
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `pong` |
| req_id | integer | Echoes the client's request identifier if provided |
| success | boolean | Indicates if the request processed successfully |
| result | object | Present only on successful requests |
| warnings | array of strings | Advisory messages about deprecated fields or upcoming changes |
| error | string | Error message present only on unsuccessful requests |
| time_in | string | RFC3339 timestamp when the request arrived on the wire |
| time_out | string | RFC3339 timestamp when the response was sent on the wire |

## Snapshot vs Update Behavior

Not applicable. This is a request/response method, not a subscription channel.

## Example Messages

### Ping Request

```json
{
  "method": "ping",
  "req_id": 101
}
```

### Pong Response

```json
{
  "method": "pong",
  "req_id": 101,
  "time_in": "2023-09-24T14:10:23.799685Z",
  "time_out": "2023-09-24T14:10:23.799703Z"
}
```

## Rate Limits

Not explicitly documented for this method.

## Notes

- This is an application-level ping, distinct from the WebSocket protocol-level ping/pong frames.
- The `time_in` and `time_out` fields can be used to measure round-trip latency to the server.
- Use this in conjunction with heartbeats to maintain and verify connection health.
- The `req_id` field is optional but useful for correlating requests and responses when multiple pings are in-flight.
