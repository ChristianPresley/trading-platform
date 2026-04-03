# Amend Order

> Source: https://docs.kraken.com/api/docs/websocket-v2/amend_order

## Overview

The amend request modifies order parameters without canceling and recreating the order. The order identifiers assigned by Kraken and/or client will stay the same, and queue priority in the order book will be maintained where possible.

## Connection

- **Endpoint:** `wss://ws-auth.kraken.com/v2`
- **Method:** `amend_order`

## Authentication

**Required.** Session token must be provided, generated via REST endpoint.

## Request Format

```json
{
  "method": "amend_order",
  "params": {
    "order_id": "OAIYAU-LGI3M-PFM5VW",
    "limit_price": 61031.3,
    "order_qty": 1.2,
    "token": "PM5Qm0MDrS54l657aQAtb7AhrwN30e2LBg1nUYOd6vU"
  }
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `amend_order` |
| params.token | string | Yes | Authenticated session token |
| params.order_qty | float | Yes | New order quantity in base asset terms |
| params.order_id | string | Conditional | Kraken order identifier (e.g., OFGKYQ-FHPCQ-HUQFEK). Required if `cl_ord_id` not provided |
| params.cl_ord_id | string | Conditional | Client order identifier (UUID format). Required if `order_id` not provided |
| params.limit_price | float | No | For limit-capable order types |
| params.limit_price_type | string | No | `static`, `pct`, or `quote`. Default: `static` |
| params.display_qty | float | No | For iceberg orders; minimum 1/15 of remaining quantity |
| params.post_only | boolean | No | Rejects if limit price would take liquidity immediately. Default: `false` |
| params.trigger_price | float | No | For triggered order types |
| params.trigger_price_type | string | No | `static`, `pct`, or `quote`. Default: `static` |
| params.symbol | string | No | Required for non-crypto pairs (e.g., TSLAx/USD) |
| params.deadline | string | No | RFC3339 format. Range: 500ms to 60s from current time. Default: 5 seconds |
| req_id | integer | No | Client-originated request identifier |

## Response Format

### Success Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `amend_order` |
| success | boolean | `true` |
| result.amend_id | string | Unique Kraken identifier for the amendment transaction |
| result.order_id | string | Kraken order identifier (if populated in request) |
| result.cl_ord_id | string | Client order identifier (if populated in request) |
| warnings | array of strings | Advisory messages |
| req_id | integer | Echo of request identifier |
| time_in | string | RFC3339 received timestamp |
| time_out | string | RFC3339 response sent timestamp |

### Error Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `amend_order` |
| success | boolean | `false` |
| error | string | Error message for rejected request |
| req_id | integer | Echo of request identifier |
| time_in | string | RFC3339 received timestamp |
| time_out | string | RFC3339 response sent timestamp |

## Example Messages

### Basic Amend Request

```json
{
  "method": "amend_order",
  "params": {
    "cl_ord_id": "2c6be801-1f53-4f79-a0bb-4ea1c95dfae9",
    "limit_price": 490795,
    "order_qty": 1.2,
    "token": "PM5Qm0MDrS54l657aQAtb7AhrwN30e2LBg1nUYOd6vU"
  }
}
```

### Advanced Amend Request (with deadline and post_only)

```json
{
  "method": "amend_order",
  "params": {
    "order_id": "OAIYAU-LGI3M-PFM5VW",
    "limit_price": 61031.3,
    "deadline": "2024-07-21T09:53:59.050Z",
    "post_only": true,
    "token": "DGB00LiKlPlLI/amQaSKUUr8niqXDb+1zwvtjp34nzk"
  }
}
```

### Success Response

```json
{
  "method": "amend_order",
  "result": {
    "amend_id": "TTW6PD-RC36L-ZZSWNU",
    "cl_ord_id": "2c6be801-1f53-4f79-a0bb-4ea1c95dfae9"
  },
  "success": true,
  "time_in": "2024-07-26T13:39:04.922699Z",
  "time_out": "2024-07-26T13:39:04.924912Z"
}
```

## Snapshot vs Update Behavior

Not applicable. This is a request/response method, not a subscription channel.

## Rate Limits

Not explicitly documented on this page.

## Notes

- If an amend request would reduce the order quantity below the existing filled quantity, the remaining quantity will be cancelled.
- For trailing-stop-limit orders, default `limit_price_type` is `quote`.
- The `deadline` parameter provides protection against latency on time-sensitive orders.
- Queue priority in the order book is maintained where possible (unlike `edit_order` which cancels and recreates).
- The order identifiers (both Kraken and client) stay the same after amendment.
- This method is preferred over `edit_order` for modifying orders.
