# Add Order (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/addorder

## Overview

The `addOrder` method sends a single new order to the exchange via the authenticated WebSocket endpoint. It supports various order types, time-in-force options, margin trading, self-trade prevention, and One-Triggers-Other (OTO) orders.

**Endpoint:** `wss://ws-auth.kraken.com`
**Event:** `addOrder`

## Authentication

**Required.** A valid session token must be provided in the `token` field.

## Request Format

```json
{
  "event": "addOrder",
  "ordertype": "limit",
  "pair": "XBT/USD",
  "price": "9000",
  "token": "0000000000000000000000000000000000000000",
  "type": "buy",
  "volume": "10.123"
}
```

## Request Fields

### Core Required Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | Yes | Must be `"addOrder"` |
| `ordertype` | string | Yes | Order type (see supported types below) |
| `type` | string | Yes | `"buy"` or `"sell"` |
| `pair` | string | Yes | Currency pair (e.g., `"BTC/USD"`) |
| `volume` | string | Yes | Order size in base currency |
| `token` | string | Yes | Authenticated session token |

### Supported Order Types

| Order Type | Description |
|------------|-------------|
| `limit` | Limit order |
| `market` | Market order |
| `stop-loss` | Stop loss order |
| `stop-loss-limit` | Stop loss limit order |
| `take-profit` | Take profit order |
| `take-profit-limit` | Take profit limit order |
| `trailing-stop` | Trailing stop order |
| `trailing-stop-limit` | Trailing stop limit order |
| `settle-position` | Settle position order |

### Price Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `price` | string | Conditional | Limit price for limit orders, or trigger price for stop/take-profit orders. Supports relative pricing: `+` (add to last price), `-` (subtract from last price), `#` (add/subtract based on direction). Can use `%` suffix for percentage-based pricing. Required for trailing stops to use relative prices |
| `price2` | string | No | Limit price for stop-loss-limit, take-profit-limit, and trailing-stop-limit orders. Supports `+`/`-` prefixes and `%` suffix. For trailing stops, represents offset from triggered price |

### Margin and Leverage Parameters

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `leverage` | string | No | - | Leverage amount: `"2"`, `"3"`, `"4"`, or `"5"` for margin-funded orders |
| `margin` | boolean | No | `false` | Set to `true` to fund with maximum available leverage (max 5) |
| `reduce_only` | boolean | No | `false` | For margin orders only: if `true`, order only reduces an existing position |

### Order Flags

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `oflags` | string | No | Comma-delimited list of order flags |

**Available Order Flags:**

| Flag | Description |
|------|-------------|
| `fcib` | Prefer fee in base currency |
| `fciq` | Prefer fee in quote currency |
| `nompp` | No market price protection (deprecated) |
| `post` | Post-only order (available for limit orders) |
| `viqc` | Volume in quote currency (for buy market orders) |

### Timing Parameters

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `starttm` | string | No | - | Scheduled start time: `"0"` for immediate, `"+n"` for n seconds from now, or Unix timestamp |
| `expiretm` | string | No | - | Expiration time: `"0"` for no expiration, `"+n"` for n seconds from now, or Unix timestamp. GTD orders can expire up to one month in the future |
| `deadline` | string (RFC3339) | No | 5 seconds | Deadline for order matching (e.g., `"2022-12-25T09:30:59.123Z"`). Valid range: 500 milliseconds to 60 seconds. Prevents matching after specified time |
| `timeinforce` | string | No | `"GTC"` | Time-in-force: `"GTC"` (Good Till Canceled), `"GTD"` (Good Till Date), `"IOC"` (Immediate Or Cancel) |

### Identifier Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `cl_ord_id` | string | No | Alphanumeric client order identifier. Mutually exclusive with `userref`. Formats: Long UUID (32 hex chars with 4 dashes), Short UUID (32 hex chars no dashes), Free text (ASCII, up to 18 characters) |
| `userref` | string | No | Non-unique numeric identifier for grouping orders (e.g., `"123456789"`). Mutually exclusive with `cl_ord_id` |
| `sender_sub_id` | string | Conditional | For institutional accounts with enhanced STP. Same format options as `cl_ord_id` |
| `reqid` | integer | No | Client-originated request identifier echoed in response |

### Self-Trade Prevention

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `stp_type` | string | No | `"cancel_newest"` | Self-trade prevention type: `"cancel_newest"` (arriving order canceled), `"cancel_oldest"` (resting order canceled), `"cancel_both"` (both canceled) |

### One-Triggers-Other (OTO) Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `close[ordertype]` | string | No | Secondary OTO order type |
| `close[price]` | string | No | Secondary order price |
| `close[price2]` | string | No | Secondary order limit price |

### Validation

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `validate` | string | No | Validate inputs only without submitting the order |

## Response Format

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `event` | string | `"addOrderStatus"` |
| `status` | string | `"ok"` or `"error"` |
| `txid` | string | Kraken order identifier for the new order (on success) |
| `cl_ord_id` | string | Client-specified alphanumeric identifier (if provided in request) |
| `descr` | string | Descriptive summary of the order |
| `reqid` | integer | Client-originated request identifier (if provided in request) |
| `errorMessage` | string | Error description (present when `status` is `"error"`) |

## Example Messages

### Request

```json
{
  "event": "addOrder",
  "ordertype": "limit",
  "pair": "XBT/USD",
  "price": "9000",
  "token": "0000000000000000000000000000000000000000",
  "type": "buy",
  "volume": "10.123"
}
```

### Success Response

```json
{
  "descr": "buy 0.01770000 XBTUSD @ limit 4000",
  "event": "addOrderStatus",
  "status": "ok",
  "txid": "ONPNXH-KMKMU-F4MR5V"
}
```

### Error Response

```json
{
  "errorMessage": "EOrder:Order minimum not met",
  "event": "addOrderStatus",
  "status": "error"
}
```

## Notes

- Supports advanced order types including trailing stops, take-profit orders, and stop-loss orders.
- Margin trading with configurable leverage (2x through 5x).
- Relative pricing allows specifying prices as offsets from the last trade price, with optional percentage notation.
- Post-only order protection ensures limit orders are only placed as maker orders.
- Self-trade prevention (STP) automatically handles situations where a user's orders would match against each other.
- One-Triggers-Other (OTO) allows attaching a conditional close order that activates when the primary order fills.
- The `validate` parameter allows testing order parameters without actually submitting.
- Multiple identifier formats are supported for order tracking (`cl_ord_id`, `userref`).
- This is a WebSocket v1 method. Kraken recommends migrating to WebSocket v2 for new implementations.
