# Open Orders (Verbose)

> Source: https://docs.kraken.com/api/docs/futures-api/websocket/open_orders_verbose

## Overview

This subscription feed publishes information about user open orders. This feed adds extra information about all the post-only orders that failed to cross the book, compared to the standard `open_orders` feed.

## Connection

- **Endpoint:** `wss://futures.kraken.com/ws/v1`
- **Feed:** `open_orders_verbose`

## Authentication

Required. Uses challenge-response authentication:

- `api_key` -- The user API key
- `original_challenge` -- The message received from a challenge request
- `signed_challenge` -- The challenge message signed with user API secret

## Request/Subscription Format

```json
{
  "event": "subscribe",
  "feed": "open_orders_verbose",
  "api_key": "CMl2SeSn09Tz+2tWuzPiPUjaXEQRGq6qv5UaexXuQ3SnahDQU/gO3aT+",
  "original_challenge": "226aee50-88fc-4618-a42a-34f7709570b2",
  "signed_challenge": "RE0DVOc7vS6pzcEjGWd/WJRRBWb54RkyvV+AZQSRl4+rap8Rlk64diR+Z9DQILm7qxncswMmJyvP/2vgzqqh+g=="
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| event | string | Yes | `subscribe` or `unsubscribe` |
| feed | string | Yes | The requested subscription feed: `open_orders_verbose` |
| api_key | string | Yes | User API key for authentication |
| original_challenge | string | Yes | Challenge message received from challenge request |
| signed_challenge | string | Yes | Challenge signed with user API secret |

## Subscription Confirmation

```json
{
  "event": "subscribed",
  "feed": "open_orders_verbose",
  "api_key": "CMl2SeSn09Tz+2tWuzPiPUjaXEQRGq6qv5UaexXuQ3SnahDQU/gO3aT+",
  "original_challenge": "226aee50-88fc-4618-a42a-34f7709570b2",
  "signed_challenge": "RE0DVOc7vS6pzcEjGWd/WJRRBWb54RkyvV+AZQSRl4+rap8Rlk64diR+Z9DQILm7qxncswMmJyvP/2vgzqqh+g=="
}
```

## Snapshot Response Format

```json
{
  "feed": "open_orders_verbose_snapshot",
  "account": "e258dba9-4dd4-4da5-bfef-75beb91c098e",
  "orders": [
    {
      "instrument": "PI_XBTUSD",
      "time": 1612275024153,
      "last_update_time": 1612275024153,
      "qty": 1000,
      "filled": 0,
      "limit_price": 34900,
      "stop_price": 13789,
      "type": "stop",
      "order_id": "723ba95f-13b7-418b-8fcf-ab7ba6620555",
      "direction": 1,
      "reduce_only": false,
      "triggerSignal": "last"
    }
  ]
}
```

### Snapshot Fields

| Field | Type | Description |
|-------|------|-------------|
| feed | string | Feed identifier: `open_orders_verbose_snapshot` |
| account | string | User account UUID |
| orders | list | Array of order structures |
| instrument | string | Symbol/product ID (e.g., `PI_XBTUSD`) |
| time | positive integer | UTC time in milliseconds when order created |
| last_update_time | positive integer | UTC time in milliseconds of last update |
| qty | positive float | Order quantity |
| filled | positive float | Amount filled |
| limit_price | positive float | Limit price for order |
| stop_price | positive float | Stop price for conditional orders |
| type | string | Order type: `limit`, `take_profit`, or `stop` |
| order_id | UUID | Unique order identifier |
| cli_ord_id | UUID | Client-provided order ID (optional) |
| direction | integer | `0` for buy, `1` for sell |
| reduce_only | boolean | If true, can only reduce positions |
| triggerSignal | string | For conditional orders: `last`, `mark`, or `spot` |

## Delta Update Format

```json
{
  "feed": "open_orders_verbose",
  "order": {
    "instrument": "PI_XBTUSD",
    "time": 1567597581495,
    "last_update_time": 1567597581495,
    "qty": 102.0,
    "filled": 0.0,
    "limit_price": 10601.0,
    "stop_price": 0.0,
    "type": "limit",
    "order_id": "fa9806c9-cba9-4661-9f31-8c5fd045a95d",
    "direction": 0,
    "reduce_only": false
  },
  "is_cancel": true,
  "reason": "post_order_failed_because_it_would_be_filled"
}
```

### Delta Fields

| Field | Type | Description |
|-------|------|-------------|
| feed | string | Feed identifier: `open_orders_verbose` |
| order | object | Order structure (same fields as snapshot) |
| is_cancel | boolean | If `true`, order removed; if `false`, order placed or partially filled |
| reason | string | Reason code for the update |

## Reason Codes

- `new_placed_order_by_user` -- User submitted new order
- `liquidation` -- Position liquidated
- `stop_order_triggered` -- Stop order activated
- `limit_order_from_stop` -- Limit created from triggered stop
- `partial_fill` -- Order partially filled
- `full_fill` -- Order completely filled
- `cancelled_by_user` -- User cancelled order
- `contract_expired` -- Contract matured
- `not_enough_margin` -- Insufficient collateral
- `market_inactive` -- Market closed
- `cancelled_by_admin` -- Administrator action
- `dead_man_switch` -- Automated protection triggered
- `ioc_order_failed_because_it_would_not_be_executed` -- IOC rejected due to liquidity
- `post_order_failed_because_it_would_filled` -- Post-only order rejected as it crosses spread
- `would_execute_self` -- Would match own orders
- `would_not_reduce_position` -- Reduce-only constraint violated
- `order_for_edit_not_found` -- Edit rejected; order not found

## Error Response

```json
{
  "event": "error",
  "message": "Invalid feed"
}
```

### Error Messages

- `Invalid feed`
- `Json Error`
