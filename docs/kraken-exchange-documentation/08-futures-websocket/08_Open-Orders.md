# Open Orders

> Source: https://docs.kraken.com/api/docs/futures-api/websocket/open_orders

## Overview

This subscription feed publishes information about user open orders. It delivers a snapshot of all current open orders upon subscription, followed by real-time delta updates as orders are placed, filled, or cancelled.

## Connection

- **Endpoint:** `wss://futures.kraken.com/ws/v1`
- **Feed:** `open_orders`

## Authentication

Required. Uses challenge-response authentication:

- `api_key` -- The user API key
- `original_challenge` -- The message received from a challenge request
- `signed_challenge` -- The challenge message signed with user API secret

## Request/Subscription Format

```json
{
  "event": "subscribe",
  "feed": "open_orders",
  "api_key": "CMl2SeSn09Tz+2tWuzPiPUjaXEQRGq6qv5UaexXuQ3SnahDQU/gO3aT+",
  "original_challenge": "226aee50-88fc-4618-a42a-34f7709570b2",
  "signed_challenge": "RE0DVOc7vS6pzcEjGWd/WJRRBWb54RkyvV+AZQSRl4+rap8Rlk64diR+Z9DQILm7qxncswMmJyvP/2vgzqqh+g=="
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| event | string | Yes | `subscribe` or `unsubscribe` |
| feed | string | Yes | The requested subscription feed: `open_orders` |
| api_key | string | Yes | The user API key |
| original_challenge | string | Yes | The message received from a challenge request |
| signed_challenge | string | Yes | The challenge message signed with user API secret |

## Subscription Confirmation

```json
{
  "event": "subscribed",
  "feed": "open_orders",
  "api_key": "CMl2SeSn09Tz+2tWuzPiPUjaXEQRGq6qv5UaexXuQ3SnahDQU/gO3aT+",
  "original_challenge": "226aee50-88fc-4618-a42a-34f7709570b2",
  "signed_challenge": "RE0DVOc7vS6pzcEjGWd/WJRRBWb54RkyvV+AZQSRl4+rap8Rlk64diR+Z9DQILm7qxncswMmJyvP/2vgzqqh+g=="
}
```

## Snapshot Response Format

```json
{
  "feed": "open_orders_snapshot",
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

## Delta Update Format

```json
{
  "feed": "open_orders",
  "order": {
    "instrument": "PI_XBTUSD",
    "time": 1567702877410,
    "last_update_time": 1567702877410,
    "qty": 304.0,
    "filled": 0.0,
    "limit_price": 10640.0,
    "stop_price": 0.0,
    "type": "limit",
    "order_id": "59302619-41d2-4f0b-941f-7e7914760ad3",
    "direction": 1,
    "reduce_only": true
  },
  "is_cancel": false,
  "reason": "new_placed_order_by_user"
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| feed | string | The subscribed feed name |
| account | string | The user account identifier (snapshot only) |
| orders | list | Array of order structures (snapshot only) |
| order | object | Single order structure (delta updates) |
| instrument | string | The instrument (symbol/product_id) of the order |
| time | positive integer | The UTC time in milliseconds |
| last_update_time | positive integer | The UTC time in milliseconds that the order was last updated |
| qty | positive float | The quantity of the order |
| filled | positive float | The total amount of the order that is filled |
| limit_price | positive float | The limit price of the order |
| stop_price | positive float | The stop price of the order |
| type | string | Order type: `limit`, `take_profit`, or `stop` |
| order_id | UUID | The order id |
| cli_ord_id | UUID | The unique client order identifier (optional) |
| direction | integer | `0` for buy, `1` for sell |
| reduce_only | boolean | If true, the order can only reduce open positions |
| triggerSignal | string | `last`, `mark`, or `spot` (conditional orders only) |
| trailing_stop_options | object | Contains `max_deviation` and `unit` for trailing stops |
| max_deviation | double | The maximum distance the trigger price may be away from the trigger signal |
| unit | string | `percent` or `quote_currency` |
| is_cancel | boolean | `false` for new/partial fill, `true` for filled/cancelled/rejected |
| reason | string | Detailed reason for order status change |

## Reason Codes

- `new_placed_order_by_user` -- User submitted a new order
- `liquidation` -- Position liquidated
- `stop_order_triggered` -- Stop order activated
- `limit_order_from_stop` -- Limit order created from triggered stop
- `partial_fill` -- Order partially filled
- `full_fill` -- Order completely filled
- `cancelled_by_user` -- User cancelled the order
- `contract_expired` -- Contract matured
- `not_enough_margin` -- Insufficient margin
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
