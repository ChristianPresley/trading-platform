# Add Order

> Source: https://docs.kraken.com/api/docs/websocket-v2/add_order

## Overview

The Add Order method sends a single new order into the exchange via the authenticated WebSocket v2 endpoint. It supports various order types, time-in-force options, conditional close orders (OTO), iceberg orders, and margin trading.

## Connection

- **Endpoint:** `wss://ws-auth.kraken.com/v2`
- **Method:** `add_order`

## Authentication

**Required.** A session token is required, obtainable via the REST API.

## Request Format

```json
{
  "method": "add_order",
  "params": {
    "order_type": "limit",
    "side": "buy",
    "limit_price": 26500.4,
    "order_qty": 1.2,
    "symbol": "BTC/USD",
    "token": "G38a1tGFzqGiUCmnegBcm8d4nfP3tytiNQz6tkCBYXY"
  },
  "req_id": 123456789
}
```

## Request Fields

### Core Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `add_order` |
| params.token | string | Yes | Session authentication token |
| params.symbol | string | Yes | Currency pair (e.g., "BTC/USD") |
| params.side | string | Yes | `buy` or `sell` |
| params.order_type | string | Yes | Order type (see Order Types table) |
| params.order_qty | float | Yes | Quantity in base asset |
| req_id | integer | No | Client request identifier for acknowledgment |

### Client Identifiers

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| params.order_userref | integer | No | Non-unique numeric identifier (mutually exclusive with `cl_ord_id`) |
| params.cl_ord_id | string | No | Alphanumeric client order ID (mutually exclusive with `order_userref`) |
| params.sender_sub_id | string | No | Sub-account/trader identifier for institutional STP |

Client ID formats (for `cl_ord_id` and `sender_sub_id`):
- Long UUID: `6d1b345e-2821-40e2-ad83-4ecb18a06876`
- Short UUID: `da8e4ad59b78481c93e589746b0cf91f`
- Free text: `arb-20240509-00010` (up to 18 characters)

### Price Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| params.limit_price | float | Conditional | Required for limit order types |
| params.limit_price_type | string | No | Units for limit price: `static`, `pct`, `quote`. Default: `quote` |

### Trigger Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| params.triggers | object | Conditional | Required for stop-loss, take-profit, trailing-stop types |
| params.triggers.reference | string | No | `index` or `last`. Default: `last` |
| params.triggers.price | float | Yes (in triggers) | Trigger price amount |
| params.triggers.price_type | string | No | `static`, `pct`, `quote`. Default: `static` |

Trigger price type examples:
- Static: `price=29000.5, price_type=static` -- triggers at 29000.5 BTC/USD
- Percentage: `price=5, price_type=pct` -- triggers at 5% rise
- Quote offset: `price=-150, price_type=quote` -- triggers at 150 USD drop

### Time-in-Force Options

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| params.time_in_force | string | No | `gtc` (Good Till Canceled, default), `gtd` (Good Till Date), `ioc` (Immediate Or Cancel) |
| params.expire_time | string | Conditional | RFC3339 format. Required for `gtd` orders; up to one month in the future |
| params.effective_time | string | No | RFC3339 scheduled start time |
| params.deadline | string | No | RFC3339 format. Valid offsets from current time: 500ms to 60s. Default: 5 seconds |

### Advanced Options

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| params.margin | boolean | No | Funds order on margin (max leverage 5). Default: `false` |
| params.post_only | boolean | No | Cancels if taking liquidity; limit orders only. Default: `false` |
| params.reduce_only | boolean | No | Closes margin position without opening larger opposite. Default: `false` |
| params.display_qty | float | No | Iceberg order visible quantity (min: 1/15 of order_qty) |
| params.fee_preference | string | No | `base` or `quote` |
| params.validate | boolean | No | Validation-only; does not trade if true. Default: `false` |
| params.stp_type | string | No | Self Trade Prevention: `cancel_newest` (default), `cancel_oldest`, `cancel_both` |
| params.cash_order_qty | float | No | Buy market order volume in quote currency (no margin) |

### Conditional Close Orders (OTO)

The `conditional` object creates secondary close orders on primary fills.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| params.conditional.order_type | string | No | `limit`, `stop-loss`, `stop-loss-limit`, `take-profit`, `take-profit-limit`, `trailing-stop`, `trailing-stop-limit` |
| params.conditional.limit_price | float | Conditional | Required for limit-type secondary orders |
| params.conditional.limit_price_type | string | No | `static`, `pct`, `quote`. Default: `quote` |
| params.conditional.trigger_price | float | No | Trigger price for secondary order |
| params.conditional.trigger_price_type | string | No | `static`, `pct`, `quote`. Default: `static` |

### Deprecated Fields

| Field | Description |
|-------|-------------|
| params.no_mpp | Accepted but ignored |
| params.conditional.stop_price | Use `trigger_price` instead |

## Order Types

| Type | Description |
|------|-------------|
| `market` | Full quantity executes immediately at best available price |
| `limit` | Full quantity placed with limit price restriction |
| `iceberg` | Hides the full order size by only showing chosen display size in the book |
| `stop-loss` | Market order triggered when price reaches stop (unfavorable direction) |
| `stop-loss-limit` | Limit order triggered on stop price (unfavorable direction) |
| `take-profit` | Market order triggered when price reaches stop (favorable direction) |
| `take-profit-limit` | Limit order triggered on stop price (favorable direction) |
| `trailing-stop` | Market order triggered on specified distance reversion from peak |
| `trailing-stop-limit` | Limit order triggered on distance reversion from peak |
| `settle-position` | Position settlement order |

## Response Format

### Success Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `add_order` |
| success | boolean | `true` |
| result.order_id | string | Unique Kraken-generated order ID |
| result.cl_ord_id | string | Client-specified order ID if provided (optional) |
| result.order_userref | integer | Client-specified numeric reference (optional) |
| result.warnings | array | Advisory messages about deprecated fields (optional) |
| req_id | integer | Echoed client request identifier (optional) |
| time_in | string | RFC3339 timestamp when request received |
| time_out | string | RFC3339 timestamp when response sent |

### Error Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `add_order` |
| success | boolean | `false` |
| error | string | Error message for rejected request |
| req_id | integer | Echoed client request identifier (optional) |
| time_in | string | RFC3339 timestamp when request received |
| time_out | string | RFC3339 timestamp when response sent |

## Example Messages

### Simple Limit Buy Order

```json
{
  "method": "add_order",
  "params": {
    "order_type": "limit",
    "side": "buy",
    "limit_price": 26500.4,
    "order_userref": 100054,
    "order_qty": 1.2,
    "symbol": "BTC/USD",
    "token": "G38a1tGFzqGiUCmnegBcm8d4nfP3tytiNQz6tkCBYXY"
  },
  "req_id": 123456789
}
```

### Stop-Loss Order (2% Drop)

```json
{
  "method": "add_order",
  "params": {
    "order_type": "stop-loss",
    "side": "sell",
    "order_qty": 100,
    "symbol": "MATIC/USD",
    "triggers": {
      "reference": "last",
      "price": -2.0,
      "price_type": "pct"
    },
    "token": "G38a1tGFzqGiUCmnegBcm8d4nfP3tytiNQz6tkCBYXY"
  }
}
```

### One-Triggers-Other (OTO) Order

```json
{
  "method": "add_order",
  "params": {
    "order_type": "limit",
    "side": "buy",
    "order_qty": 1.2,
    "symbol": "BTC/USD",
    "limit_price": 28440,
    "conditional": {
      "order_type": "stop-loss-limit",
      "trigger_price": 28410,
      "limit_price": 28400
    },
    "token": "G38a1tGFzqGiUCmnegBcm8d4nfP3tytiNQz6tkCBYXY"
  }
}
```

### Success Response

```json
{
  "method": "add_order",
  "req_id": 123456789,
  "result": {
    "order_id": "AA5JGQ-SBMRC-SCJ7J7",
    "order_userref": 100054
  },
  "success": true,
  "time_in": "2023-09-21T14:15:07.197274Z",
  "time_out": "2023-09-21T14:15:07.205301Z"
}
```

## Rate Limits

Not explicitly documented on this page. Rate limits are managed via the `maxratecount` field available on the executions channel.

## Notes

- The `deadline` parameter provides protection against latency on time-sensitive orders. Valid range is 500ms to 60 seconds from current time; default is 5 seconds.
- GTD (Good Till Date) orders can extend up to one month in the future.
- `cl_ord_id` and `order_userref` are mutually exclusive identifiers.
- Market Price Protection (MPP) protects market orders from bad pricing due to slippage.
- For trailing-stop orders, the price parameter represents the reversion from the peak as a positive offset.
