# Batch Cancel Orders

> Source: https://docs.kraken.com/api/docs/websocket-v2/batch_cancel

## Overview

The batch_cancel method allows cancellation of multiple orders in a single request by a range of identifiers. Minimum of 2 and maximum of 50 orders per batch.

## Connection

- **Endpoint:** `wss://ws-auth.kraken.com/v2`
- **Method:** `batch_cancel`

## Authentication

**Required.** A session token must be provided via REST API authentication.

## Request Format

```json
{
  "method": "batch_cancel",
  "params": {
    "orders": ["1", "2", "ORDERX-IDXXX-XXXXX3"],
    "token": "TxxxxxxxxxOxxxxxxxxxxKxxxxxxxExxxxxxxxN"
  },
  "req_id": 1234567890
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `batch_cancel` |
| params.orders | array of strings | Yes | List of client `order_userref` or Kraken `order_id` identifiers. Min 2, max 50. |
| params.token | string | Yes | Authenticated session token |
| params.cl_ord_id | array of strings | No | List of client order identifiers |
| req_id | integer | No | Client-originated request identifier |

## Response Format

### Success Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `batch_cancel` |
| success | boolean | `true` |
| result.count | integer | Number of orders cancelled |
| result.warnings | array of strings | Advisory messages about deprecated fields (optional) |
| req_id | integer | Echo of request identifier |
| time_in | string | RFC3339 request receipt timestamp |
| time_out | string | RFC3339 response transmission timestamp |

### Error Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `batch_cancel` |
| success | boolean | `false` |
| error | string | Error message for rejected request |
| req_id | integer | Echo of request identifier |
| time_in | string | RFC3339 request receipt timestamp |
| time_out | string | RFC3339 response transmission timestamp |

## Snapshot vs Update Behavior

Not applicable. This is a request/response method, not a subscription channel.

## Example Messages

### Batch Cancel Request

```json
{
  "method": "batch_cancel",
  "params": {
    "orders": ["1", "2", "ORDERX-IDXXX-XXXXX3"],
    "token": "TxxxxxxxxxOxxxxxxxxxxKxxxxxxxExxxxxxxxN"
  },
  "req_id": 1234567890
}
```

### Success Response

```json
{
  "method": "batch_cancel",
  "req_id": 1234567890,
  "result": {
    "count": 3
  },
  "success": true,
  "time_in": "2022-06-13T08:09:10.123456Z",
  "time_out": "2022-06-13T08:09:10.7890123"
}
```

## Rate Limits

Not explicitly documented on this page.

## Notes

- **Batch size:** Minimum 2, maximum 50 orders per request.
- The `orders` array can contain a mix of Kraken `order_id` values and client `order_userref` values.
- The `result.count` field indicates how many orders were successfully cancelled.
- Individual cancelled order details also stream via the `executions` channel.
