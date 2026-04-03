# Cancel Order

> Source: https://docs.kraken.com/api/docs/websocket-v2/cancel_order

## Overview

The cancel_order method removes one or more open orders via a single authenticated WebSocket request. The orders to be cancelled can be identified by a range of client or Kraken identifiers.

## Connection

- **Endpoint:** `wss://ws-auth.kraken.com/v2`
- **Method:** `cancel_order`

## Authentication

**Required.** Session token must be generated via REST API.

## Request Format

```json
{
  "method": "cancel_order",
  "params": {
    "order_id": ["OM5CRX-N2HAL-GFGWE9", "OLUMT4-UTEGU-ZYM7E9"],
    "token": "zGXT1dUQQjJjy5VmGXMegdDQngXXehNo5qbMBVolwEQ"
  },
  "req_id": 123456789
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `cancel_order` |
| params.token | string | Yes | Authenticated session token |
| params.order_id | array of strings | No | List of Kraken order identifiers |
| params.cl_ord_id | array of strings | No | List of client order identifiers |
| params.order_userref | array of integers | No | List of client order reference identifiers |
| req_id | integer | No | Client-originated request identifier |

At least one of `order_id`, `cl_ord_id`, or `order_userref` must be provided.

## Response Format

A separate response is sent for each cancelled order.

### Success Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `cancel_order` |
| success | boolean | `true` |
| result.order_id | string | Kraken identifier of cancelled order |
| result.cl_ord_id | string | Client identifier of cancelled order (optional) |
| warnings | array of strings | Advisory messages about deprecated fields (optional) |
| req_id | integer | Client request identifier echoed back (optional) |
| time_in | string | RFC3339 request receipt timestamp |
| time_out | string | RFC3339 response transmission timestamp |

### Error Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `cancel_order` |
| success | boolean | `false` |
| error | string | Error message for rejected request |
| req_id | integer | Client request identifier echoed back (optional) |
| time_in | string | RFC3339 request receipt timestamp |
| time_out | string | RFC3339 response transmission timestamp |

## Snapshot vs Update Behavior

Not applicable. This is a request/response method, not a subscription channel.

## Example Messages

### Cancel Request (multiple orders)

```json
{
  "method": "cancel_order",
  "params": {
    "order_id": ["OM5CRX-N2HAL-GFGWE9", "OLUMT4-UTEGU-ZYM7E9"],
    "token": "zGXT1dUQQjJjy5VmGXMegdDQngXXehNo5qbMBVolwEQ"
  },
  "req_id": 123456789
}
```

### Success Response (per order)

```json
{
  "method": "cancel_order",
  "req_id": 123456789,
  "result": {
    "order_id": "OLUMT4-UTEGU-ZYM7E9"
  },
  "success": true,
  "time_in": "2023-09-21T14:36:57.428972Z",
  "time_out": "2023-09-21T14:36:57.437952Z"
}
```

## Rate Limits

Not explicitly documented on this page.

## Notes

- Multiple orders can be cancelled in a single request using arrays of identifiers.
- Each cancelled order generates its own individual response message.
- Orders can be identified by Kraken order ID, client order ID, or user reference number.
- Individual cancelled order details also stream via the `executions` channel.
