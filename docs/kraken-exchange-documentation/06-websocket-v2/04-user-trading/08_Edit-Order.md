# Edit Order

> Source: https://docs.kraken.com/api/docs/websocket-v2/edit_order

## Overview

The edit_order method enables modification of live order parameters via WebSocket v2. When an order has been successfully modified, the original order will be cancelled and a new order will be created with the adjusted parameters -- a new `order_id` will be returned.

**Important:** The newer `amend_order` endpoint is recommended as it resolves the caveats listed below and has additional performance gains.

## Limitations

- Triggered stop-loss or take-profit orders are not supported.
- Orders with conditional close terms are not supported.
- Rejection occurs if executed volume is greater than the newly supplied volume.
- `cl_ord_id` parameter is not supported.
- Existing executions remain associated with the original order.
- Queue position is not maintained (order is cancelled and recreated).

## Connection

- **Endpoint:** `wss://ws-auth.kraken.com/v2`
- **Method:** `edit_order`

## Authentication

**Required.** Session token must be generated through REST API.

## Request Format

```json
{
  "method": "edit_order",
  "params": {
    "order_id": "ORDERX-IDXXX-XXXXX1",
    "order_qty": 0.2123456789,
    "symbol": "BTC/USD",
    "token": "TxxxxxxxxxOxxxxxxxxxxKxxxxxxxExxxxxxxxN"
  },
  "req_id": 1234567890
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `edit_order` |
| params.token | string | Yes | Authenticated session token |
| params.order_id | string | Yes | Kraken order identifier (e.g., OFGKYQ-FHPCQ-HUQFEK) |
| params.symbol | string | Yes | Pair identifier (e.g., "BTC/USD"); cannot be changed |
| params.order_qty | float | No | Order quantity in base asset terms |
| params.limit_price | float | No | Limit price for applicable order types |
| params.deadline | string | No | RFC3339 format. Valid range: 500ms to 60s from current time. Default: 5s |
| params.display_qty | float | No | Iceberg orders only; quantity shown in book. Minimum 1/15 of `order_qty` |
| params.fee_preference | string | No | `base` or `quote` |
| params.post_only | boolean | No | Limit orders only. Default: `false`. Cancels if taking liquidity |
| params.reduce_only | boolean | No | Default: `false`. Restricts margin position sizing |
| params.order_userref | integer | No | User-defined reference (does not identify order to amend) |
| params.validate | boolean | No | Default: `false`. Validates only without trading if `true` |
| params.triggers | object | No | Trigger condition parameters (for triggered order types) |
| params.triggers.price | float | - | Trigger amount |
| params.triggers.price_type | string | - | `static` (default), `pct`, `quote` |
| params.triggers.reference | string | - | `index` (broader market) or `last` (Kraken book). Default: `last` |
| req_id | integer | No | Client-originated request identifier |

### Deprecated Request Fields

| Field | Description |
|-------|-------------|
| params.no_mpp | Accepted but ignored |
| params.price | Use `limit_price` instead |
| params.trigger | Use `triggers.reference` instead |
| params.stop_price | Use `triggers.price` instead |

### Trigger Price Examples

- Static: `price=29000.5, price_type=static` -- triggers at exact price
- Percentage: `price=5, price_type=pct` -- triggers at 5% rise
- Quote offset: `price=-150, price_type=quote` -- triggers at 150 USD drop
- For trailing orders, price represents reversion from peak (positive offset)

## Response Format

### Success Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `edit_order` |
| success | boolean | `true` |
| result.order_id | string | New unique order identifier |
| result.original_order_id | string | ID of the edited (cancelled) order |
| result.warnings | array | Advisory messages on deprecated fields |
| req_id | integer | Echoes client request identifier |
| time_in | string | RFC3339 timestamp when received |
| time_out | string | RFC3339 timestamp when sent |

### Error Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `edit_order` |
| success | boolean | `false` |
| error | string | Error message for rejected request |
| req_id | integer | Echoes client request identifier |
| time_in | string | RFC3339 timestamp when received |
| time_out | string | RFC3339 timestamp when sent |

## Snapshot vs Update Behavior

Not applicable. This is a request/response method, not a subscription channel.

## Example Messages

### Edit Request

```json
{
  "method": "edit_order",
  "params": {
    "order_id": "ORDERX-IDXXX-XXXXX1",
    "order_qty": 0.2123456789,
    "symbol": "BTC/USD",
    "token": "TxxxxxxxxxOxxxxxxxxxxKxxxxxxxExxxxxxxxN"
  },
  "req_id": 1234567890
}
```

### Success Response

```json
{
  "method": "edit_order",
  "req_id": 1234567890,
  "result": {
    "order_id": "ORDERX-IDXXX-XXXXX2",
    "original_order_id": "ORDERX-IDXXX-XXXXX1"
  },
  "success": true,
  "time_in": "2022-07-15T12:56:09.876488Z",
  "time_out": "2022-07-15T12:56:09.923422Z"
}
```

## Rate Limits

Not explicitly documented on this page.

## Notes

- **Prefer `amend_order`:** The `amend_order` endpoint is newer and recommended. It resolves the caveats of `edit_order` and has additional performance gains.
- **Cancel-and-replace behavior:** Unlike `amend_order`, this method cancels the original order and creates a new one, resulting in a new `order_id` and loss of queue position.
- The `symbol` field is required but cannot be changed -- it must match the original order's pair.
- The response includes both `order_id` (the new order) and `original_order_id` (the cancelled order).
- Existing executions remain associated with the original order, not the new one.
