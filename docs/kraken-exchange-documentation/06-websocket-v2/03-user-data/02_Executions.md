# Executions

> Source: https://docs.kraken.com/api/docs/websocket-v2/executions

## Overview

The executions channel streams order status and execution events for authenticated accounts. It combines functionality from WebSocket v1's `openOrders` and `ownTrades` channels, requiring authentication via session token.

## Connection

- **Endpoint:** `wss://ws-auth.kraken.com/v2`
- **Channel:** `executions`

## Authentication

**Required.** This channel contains account-specific data. An authentication token is required in the request. Token generation requires accessing the REST API.

## Request/Subscription Format

```json
{
  "method": "subscribe",
  "params": {
    "channel": "executions",
    "token": "G38a1tGFzqGiUCmnegBcm8d4nfP3tytiNQz6tkCBYXY",
    "snap_orders": true,
    "snap_trades": true
  }
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `subscribe` |
| params.channel | string | Yes | Value: `executions` |
| params.token | string | Yes | Authentication session token |
| params.snap_trades | boolean | No | If `true`, the last 50 order fills will be included in snapshot. Default: `false` |
| params.snap_orders | boolean | No | If `true`, open orders will be included in snapshot. Default: `true` |
| params.order_status | boolean | No | If `true`, all possible status transitions will be sent. Otherwise, only open/close transitions will be streamed. Default: `true` |
| params.ratecounter | boolean | No | Includes rate-limit counter in stream when enabled. Default: `false` |
| params.rebased | boolean | No | Display xstocks in underlying equity terms (true) vs SPV tokens (false). Default: `true` |
| params.users | string | No | Master account only; value `"all"` streams master and subaccount events |
| params.req_id | integer | No | Optional client-originated request identifier |

### Deprecated Request Fields

| Field | Type | Description |
|-------|------|-------------|
| params.snapshot_trades | boolean | **Deprecated.** Use `snap_trades` instead. |
| params.snapshot | boolean | **Deprecated.** Use `snap_orders` or `snap_trades` instead. |

## Subscribe Acknowledgment

### Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `subscribe` |
| success | boolean | Request processing status |
| result.channel | string | Value: `executions` |
| result.snap_orders | boolean | Confirms snapshot orders requested |
| result.snap_trades | boolean | Confirms snapshot trades requested |
| result.maxratecount | integer | Max rate counter per user tier |
| time_in | string | RFC3339 wire receipt timestamp |
| time_out | string | RFC3339 acknowledgment transmit timestamp |
| warnings | array | Advisory messages on deprecated fields |
| error | string | Present when success=false (conditional) |
| req_id | integer | Echo of client request identifier (optional) |

### Example

```json
{
  "method": "subscribe",
  "result": {
    "channel": "executions",
    "maxratecount": 125,
    "snap_orders": true,
    "snap_trades": true
  },
  "success": true,
  "time_in": "2023-10-16T13:18:35.303171Z",
  "time_out": "2023-10-16T13:18:35.318297Z"
}
```

## Response/Update Format

The snapshot and update stream share the same data schema. The fields included in the message depend on the `exec_type`.

### Message Envelope

| Field | Type | Description |
|-------|------|-------------|
| channel | string | Value: `executions` |
| type | string | `snapshot` or `update` |
| data | array | List of execution report objects |
| sequence | integer | Subscription message sequence number |

## Response Fields (Execution Report)

### Order Identification

| Field | Type | Description |
|-------|------|-------------|
| order_id | string | Kraken-generated unique identifier |
| order_userref | integer | Optional numeric client identifier |
| cl_ord_id | string | Optional client-supplied order ID |
| ext_ord_id | string (UUID) | Optional external partner order identifier |

### Order Specification

| Field | Type | Description |
|-------|------|-------------|
| symbol | string | Currency pair (e.g., "BTC/USD") |
| side | string | `buy` or `sell` |
| order_type | string | `limit`, `market`, `iceberg`, `stop-loss`, `stop-loss-limit`, `take-profit`, `take-profit-limit`, `trailing-stop`, `trailing-stop-limit`, `settle-position` |
| order_qty | float | Client order quantity |
| order_status | string | `pending_new`, `new`, `partially_filled`, `filled`, `canceled`, `expired` |
| limit_price | float | Limit price restriction |
| post_only | boolean | Indicates post-only order |
| reduce_only | boolean | Indicates reduce-only order |
| margin | boolean | Order eligible for margin funding |
| no_mpp | boolean | Market price protection status |
| cash_order_qty | float | Order volume in quote currency if specified |

### Execution Details

| Field | Type | Description |
|-------|------|-------------|
| exec_type | string | Event type (see Execution Types table below) |
| exec_id | string | Execution identifier (trade events only) |
| trade_id | integer | Trade identifier |
| ext_exec_id | string (UUID) | External partner execution identifier (trade events only) |

### Fill Information

| Field | Type | Description |
|-------|------|-------------|
| cum_qty | float | Order cumulative executed quantity |
| cum_cost | float | Order cumulative value executed |
| avg_price | float | Order average fill price |
| last_qty | float | Quantity filled in this trade (trade events only) |
| last_price | float | Average price in this trade event (trade events only) |
| cost | float | Value of individual execution (trade events only) |

### Fee Structure

| Field | Type | Description |
|-------|------|-------------|
| fees | array | Fee objects with `asset` (string) and `qty` (float) fields (trade events only) |
| fee_ccy_pref | string | `fcib` (base currency) or `fciq` (quote currency) |
| fee_usd_equiv | float | Total fee in USD equivalent |

### Timing

| Field | Type | Description |
|-------|------|-------------|
| timestamp | string | RFC3339 event time |
| time_in_force | string | `GTC` (Good Till Canceled), `GTD` (Good Till Date), `IOC` (Immediate Or Cancel) |
| effective_time | string | RFC3339 scheduled start time |
| expire_time | string | RFC3339 scheduled expiration time |

### Trigger Configuration (for triggered order types)

| Field | Type | Description |
|-------|------|-------------|
| triggers.reference | string | `index` or `last` |
| triggers.price | float | Trigger price amount |
| triggers.price_type | string | `static`, `pct` (percentage offset), `quote` (notional offset) |
| triggers.actual_price | float | Current effective trigger price value |
| triggers.peak_price | float | Peak/trough on trailing orders |
| triggers.last_price | float | Reference price at activation |
| triggers.status | string | `triggered` or `untriggered` |
| triggers.timestamp | string | RFC3339 trigger event timestamp |

### Contingent Orders

| Field | Type | Description |
|-------|------|-------------|
| contingent.order_type | string | Secondary order type |
| contingent.trigger_price | float | Secondary trigger price (conditional) |
| contingent.trigger_price_type | string | `static`, `pct`, `quote` (conditional) |
| contingent.limit_price | float | Secondary limit price (conditional) |
| contingent.limit_price_type | string | `static`, `pct`, `quote` (conditional) |

### Iceberg Orders

| Field | Type | Description |
|-------|------|-------------|
| display_qty | float | Display quantity for iceberg orders |
| display_qty_remain | float | Next display quantity (conditional) |

### Position and Liquidation

| Field | Type | Description |
|-------|------|-------------|
| position_status | string | `opened`, `closing`, `closed` |
| liquidated | boolean | Liquidation status |
| margin_borrow | boolean | Margin execution indicator |
| liquidity_ind | string | `m` (maker) or `t` (taker) |

### Additional Fields

| Field | Type | Description |
|-------|------|-------------|
| amended | boolean | Present in snapshots and amended/restated events |
| reason | string | Associated event reason |
| sender_sub_id | string | Institutional sub-account/trader for STP |
| ord_ref_id | string | Referral order transaction ID |
| user | string | Kraken identifier for user/sub-account when `users=all` (conditional) |

### Deprecated Response Fields

| Field | Type | Description |
|-------|------|-------------|
| cancel_reason | string | **Deprecated.** Use `reason` instead. |
| stop_price | float | **Deprecated.** Use `triggers` object instead. |
| trigger | string | **Deprecated.** Use `triggers` object instead. |
| triggered_price | float | **Deprecated.** Use `triggers` object instead. |

## Execution Types

| Type | Description |
|------|-------------|
| `pending_new` | Order request received and validated, not yet live |
| `new` | Order created and live in engine |
| `trade` | Order received a fill |
| `filled` | Order fully filled |
| `iceberg_refill` | Iceberg order refill |
| `canceled` | Order cancelled |
| `expired` | Order expired |
| `amended` | User-initiated amendment (e.g., limit price change) |
| `restated` | Engine-initiated amendment for position/book maintenance |
| `status` | Order status update (e.g., trigger price updated) |

## Snapshot vs Update Behavior

By default, snapshots contain all open orders and the latest 50 trades. Snapshot content adjusts based on subscription parameters:

- When `snap_orders=true`: Initial message includes all open orders.
- When `snap_trades=true`: Initial message includes latest 50 fills.
- Subsequent messages are update-type events reflecting new status changes or fills.
- The `sequence` field increments with each message for ordering.

## Example Messages

### Pending New Status

```json
{
  "channel": "executions",
  "type": "update",
  "data": [
    {
      "order_id": "OK4GJX-KSTLS-7DZZO5",
      "order_userref": 3,
      "symbol": "BTC/USD",
      "order_qty": 0.005,
      "cum_cost": 0.0,
      "time_in_force": "GTC",
      "exec_type": "pending_new",
      "side": "sell",
      "order_type": "limit",
      "limit_price_type": "static",
      "limit_price": 26500.0,
      "stop_price": 0.0,
      "order_status": "pending_new",
      "fee_usd_equiv": 0.0,
      "fee_ccy_pref": "fciq",
      "timestamp": "2023-09-22T10:33:05.709950Z"
    }
  ],
  "sequence": 8
}
```

### Live Order (New)

```json
{
  "channel": "executions",
  "type": "update",
  "data": [
    {
      "timestamp": "2023-09-22T10:33:05.709982Z",
      "order_status": "new",
      "exec_type": "new",
      "order_userref": 3,
      "order_id": "OK4GJX-KSTLS-7DZZO5"
    }
  ],
  "sequence": 9
}
```

### Trade Execution

```json
{
  "channel": "executions",
  "type": "update",
  "data": [
    {
      "order_id": "OK4GJX-KSTLS-7DZZO5",
      "order_userref": 3,
      "exec_id": "TGBB7L-HT5LX-J3BZ4A",
      "exec_type": "trade",
      "trade_id": 62887576,
      "symbol": "BTC/USD",
      "side": "sell",
      "last_qty": 0.005,
      "last_price": 26599.9,
      "liquidity_ind": "t",
      "cost": 132.9995,
      "order_type": "limit",
      "timestamp": "2023-09-22T10:33:05.709993Z",
      "order_status": "partially_filled",
      "cum_qty": 0.005,
      "cum_cost": 132.9995,
      "avg_price": 26599.9,
      "fee_usd_equiv": 0.3458,
      "fees": [
        {
          "asset": "USD",
          "qty": 0.3458
        }
      ]
    }
  ],
  "sequence": 10
}
```

## Unsubscribe

### Request

```json
{
  "method": "unsubscribe",
  "params": {
    "channel": "executions",
    "token": "G38a1tGFzqGiUCmnegBcm8d4nfP3tytiNQz6tkCBYXY"
  }
}
```

### Acknowledgment

```json
{
  "method": "unsubscribe",
  "result": {
    "channel": "executions"
  },
  "success": true,
  "time_in": "2023-10-16T13:18:35.303171Z",
  "time_out": "2023-10-16T13:18:35.318297Z"
}
```

### Unsubscribe Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `unsubscribe` |
| params.channel | string | Yes | Value: `executions` |
| params.token | string | Yes | Authentication session token |
| params.req_id | integer | No | Optional client-originated request identifier |

### Unsubscribe Acknowledgment Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `unsubscribe` |
| success | boolean | Unsubscription status |
| result.channel | string | Value: `executions` |
| time_in | string | RFC3339 wire receipt timestamp |
| time_out | string | RFC3339 acknowledgment transmit timestamp |
| error | string | Present when success=false (conditional) |
| req_id | integer | Echo of client request identifier (optional) |

## Rate Limits

The `maxratecount` field in the subscribe acknowledgment indicates the maximum rate counter value based on user tier. Enable `ratecounter=true` in subscription to receive rate-limit counter updates within the stream.

## Notes

- This channel replaces the v1 `openOrders` and `ownTrades` channels.
- The fields included in each message depend on the `exec_type` -- not all fields are present in every message.
- The `sequence` field provides message ordering within the subscription.
- Master accounts can use `users: "all"` to receive events for all subaccounts.
