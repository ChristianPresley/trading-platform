# Ping (WebSocket)

## Endpoint

```
wss://wss.prime.kraken.com/ws/v1
```

## Description

Allows clients to optionally send ping messages to the server. The server responds with a pong message. Ping messages are **not required** to keep the session alive.

## Request Message (Ping)

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `reqid` | number | Yes | A unique number that identifies this ping request |
| `type` | string | Yes | Must be `Ping` |
| `ts` | string | Yes | ISO-8601 UTC timestamp. Format: `2019-02-13T05:17:32.000000Z` |
| `data` | array | No | Optional list of objects that will be forwarded in the response |

### Example Request

```json
{
  "reqid": 2,
  "type": "Ping",
  "ts": "2024-01-13T05:17:32.000000Z"
}
```

## Response Message (Pong)

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `reqid` | number | Yes | The request ID from the ping request |
| `type` | string | Yes | `Pong` |
| `seqNum` | number | Yes | Sequence number. Always `0` for ping/pong messages. |
| `ts` | string | Yes | ISO-8601 UTC timestamp. Format: `2019-02-13T05:17:32.000000Z` |
| `data` | array | No | Forwarded data from the ping request, if provided |

### Example Response

```json
{
  "reqid": 2,
  "type": "Pong",
  "seqNum": 0,
  "ts": "2024-01-13T05:17:32.002500Z"
}
```

## Notes

- Ping/pong is optional and is **not required** to keep the WebSocket session alive.
- The `seqNum` for ping/pong messages is always `0`.
- Any `data` array sent in the ping request will be forwarded back in the pong response.
- The timestamp difference between ping request `ts` and pong response `ts` can be used to measure round-trip latency.

## Source

- [Kraken API Documentation - Ping (WebSocket)](https://docs.kraken.com/api/docs/prime-api/websocket/ping)
