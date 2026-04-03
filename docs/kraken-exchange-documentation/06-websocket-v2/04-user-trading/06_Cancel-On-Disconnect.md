# Cancel on Disconnect (Dead Man's Switch)

> Source: https://docs.kraken.com/api/docs/websocket-v2/cancel_after

## Overview

This feature implements a "Dead Man's Switch" mechanism protecting against network failures, extreme latency, or matching engine downtime by automatically cancelling all client orders if a timer expires. The client must continuously send requests to reset the trigger time or deactivate the timer.

## Connection

- **Endpoint:** `wss://ws-auth.kraken.com/v2`
- **Method:** `cancel_all_orders_after`

## Authentication

**Required.** Authenticated channel requiring a session token generated via REST API.

## Request Format

```json
{
  "method": "cancel_all_orders_after",
  "params": {
    "timeout": 100,
    "token": "zwpdzWUe18Bn6h4TAMorh26+QbcMeST2B5tamfe+pgQ"
  },
  "req_id": 1234567890
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `cancel_all_orders_after` |
| params.timeout | integer | Yes | Duration in seconds to set/extend timer. Must be less than 86400 seconds (24 hours). Set to `0` to deactivate. |
| params.token | string | Yes | Authenticated session token |
| req_id | integer | No | Optional client-originated request identifier |

## Response Format

### Success Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `cancel_all_orders_after` |
| success | boolean | `true` |
| result.currentTime | string | RFC3339 current engine time |
| result.triggerTime | string | RFC3339 time when orders will expire |
| warnings | array | Advisory messages about deprecated fields (optional) |
| req_id | integer | Client identifier from request (when provided) |
| time_in | string | RFC3339 request received timestamp |
| time_out | string | RFC3339 response sent timestamp |

### Error Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `cancel_all_orders_after` |
| success | boolean | `false` |
| error | string | Error message for rejected request |
| req_id | integer | Client identifier from request (when provided) |
| time_in | string | RFC3339 request received timestamp |
| time_out | string | RFC3339 response sent timestamp |

## Snapshot vs Update Behavior

Not applicable. This is a request/response method, not a subscription channel.

## Example Messages

### Set Timer Request

```json
{
  "method": "cancel_all_orders_after",
  "params": {
    "timeout": 100,
    "token": "zwpdzWUe18Bn6h4TAMorh26+QbcMeST2B5tamfe+pgQ"
  },
  "req_id": 1234567890
}
```

### Success Response

```json
{
  "method": "cancel_all_orders_after",
  "req_id": 1234567890,
  "result": {
    "currentTime": "2023-09-21T15:49:29Z",
    "triggerTime": "2023-09-21T15:51:09Z"
  },
  "success": true,
  "time_in": "2023-09-21T15:49:28.627900Z",
  "time_out": "2023-09-21T15:49:28.649057Z"
}
```

### Disable Timer Request

```json
{
  "method": "cancel_all_orders_after",
  "params": {
    "timeout": 0,
    "token": "zwpdzWUe18Bn6h4TAMorh26+QbcMeST2B5tamfe+pgQ"
  }
}
```

## Rate Limits

Not explicitly documented on this page.

## Notes

- **Operational pattern:** Client sends a request specifying the timeout duration to activate the countdown timer.
- **Keep-alive:** Client must continuously send new requests to reset the trigger time. Sending a new request extends the timer.
- **Deactivate:** Send a timeout of `0` to disable the timer.
- **Timer expiration:** Upon timer expiration, all account orders cancel automatically and the feature disables itself.
- **Recommended usage:** Send calls every 15-30 seconds with a 60-second timeout for brief disconnection protection.
- **Maintenance warning:** Disable timer before scheduled maintenance to prevent unintended order cancellations.
- **Maximum timeout:** Must be less than 86400 seconds (24 hours).
