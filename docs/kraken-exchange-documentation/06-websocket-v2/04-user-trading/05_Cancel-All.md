# Cancel All Orders

> Source: https://docs.kraken.com/api/docs/websocket-v2/cancel_all

## Overview

The cancel_all method cancels all open orders, including untriggered orders and orders resting in the book. Individual cancelled order details stream via the `executions` channel.

## Connection

- **Endpoint:** `wss://ws-auth.kraken.com/v2`
- **Method:** `cancel_all`

## Authentication

**Required.** A session token must be obtained through REST API.

## Request Format

```json
{
  "method": "cancel_all",
  "params": {
    "token": "weeBxllys/7kHy/zHpkATSDIS42BvDgWS2b04ZSZHZ5"
  },
  "req_id": 1234567890
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `cancel_all` |
| params.token | string | Yes | Authenticated session token |
| req_id | integer | No | Client-originated request identifier |

## Response Format

### Success Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `cancel_all` |
| success | boolean | `true` |
| result.count | integer | Number of orders cancelled |
| result.warnings | array | Advisory messages about deprecated fields (optional) |
| req_id | integer | Echoed request identifier |
| time_in | string | RFC3339 request receipt timestamp |
| time_out | string | RFC3339 response transmission timestamp |

### Error Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `cancel_all` |
| success | boolean | `false` |
| error | string | Rejection reason |
| req_id | integer | Echoed request identifier |
| time_in | string | RFC3339 request receipt timestamp |
| time_out | string | RFC3339 response transmission timestamp |

## Snapshot vs Update Behavior

Not applicable. This is a request/response method, not a subscription channel.

## Example Messages

### Request

```json
{
  "method": "cancel_all",
  "params": {
    "token": "weeBxllys/7kHy/zHpkATSDIS42BvDgWS2b04ZSZHZ5"
  },
  "req_id": 1234567890
}
```

### Success Response

```json
{
  "method": "cancel_all",
  "req_id": 1234567890,
  "result": {
    "count": 1
  },
  "success": true,
  "time_in": "2023-09-26T13:09:48.463201Z",
  "time_out": "2023-09-26T13:09:48.471419Z"
}
```

## Rate Limits

Not explicitly documented on this page.

## Notes

- Cancels all open orders including untriggered stop/take-profit orders and orders resting in the book.
- Individual cancelled order details are streamed via the `executions` channel.
- The `result.count` field indicates how many orders were cancelled.
