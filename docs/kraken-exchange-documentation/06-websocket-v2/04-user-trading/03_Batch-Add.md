# Batch Add Orders

> Source: https://docs.kraken.com/api/docs/websocket-v2/batch_add

## Overview

The batch_add method submits a collection of orders (minimum of 2, maximum 15) to the Kraken exchange via the authenticated WebSocket connection. All orders in a batch are limited to a single pair.

## Connection

- **Endpoint:** `wss://ws-auth.kraken.com/v2`
- **Method:** `batch_add`

## Authentication

**Required.** Session token must be provided via the `token` parameter.

## Validation and Processing

- **Pre-submission validation:** Validation is performed on the whole batch prior to submission to the engine. If an order fails validation, the whole batch will be rejected.
- **Engine processing:** On submission to the engine, if an order fails pre-match checks (i.e. funding), then the individual order will be rejected and the remainder of the batch will be processed.

## Request Format

```json
{
  "method": "batch_add",
  "params": {
    "symbol": "BTC/USD",
    "orders": [
      {
        "limit_price": 1010.10,
        "order_qty": 0.123456789,
        "order_type": "limit",
        "order_userref": 1,
        "side": "buy"
      },
      {
        "limit_price": 2020.20,
        "order_qty": 0.987654321,
        "order_type": "limit",
        "order_userref": 2,
        "side": "sell",
        "stp_type": "cancel_both"
      }
    ],
    "token": "TxxxxxxxxxOxxxxxxxxxxKxxxxxxxExxxxxxxxN",
    "validate": false
  },
  "req_id": 1234567890
}
```

## Request Fields

### Top-Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `batch_add` |
| params.symbol | string | Yes | Currency pair (e.g., "BTC/USD"). All orders must use this pair. |
| params.orders | array | Yes | List of order objects (2-15 items) |
| params.token | string | Yes | Session token for authentication |
| params.deadline | string | No | RFC3339 format. Range: 500ms to 60s from current time. Default: 5 seconds |
| params.validate | boolean | No | If true, validates only without trading. Default: `false` |
| req_id | integer | No | Client-originated request identifier |

### Order Object Fields

#### Core Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| order_qty | float | Yes | Quantity in base asset terms |
| order_type | string | Yes | `limit`, `market`, `iceberg`, `stop-loss`, `stop-loss-limit`, `take-profit`, `take-profit-limit`, `trailing-stop`, `trailing-stop-limit`, `settle-position` |
| side | string | Yes | `buy` or `sell` |
| limit_price | float | Conditional | Required for order types supporting limit price restriction |

#### Client Identifiers

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| cl_ord_id | string | No | Alphanumeric client order ID. Mutually exclusive with `order_userref`. Formats: Long UUID, Short UUID, or free text (max 18 chars) |
| order_userref | integer | No | Non-unique numeric identifier. Mutually exclusive with `cl_ord_id` |
| sender_sub_id | string | No | For institutional accounts with enhanced STP. Same format options as `cl_ord_id` |

#### Price and Trigger Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| limit_price_type | string | No | For trailing-stop orders. Values: `static`, `pct`, `quote`. Default: `quote` |
| triggers | object | Conditional | Required for triggered order types |
| triggers.reference | string | No | `index` or `last`. Default: `last` |
| triggers.price | float | Yes (in triggers) | Trigger amount |
| triggers.price_type | string | No | `static` (default), `pct`, `quote` |

Trigger price type examples:
- `static`: Direct market price (e.g., 29000.5 for BTC/USD)
- `pct`: Percentage offset from reference (e.g., -10%)
- `quote`: Notional offset in quote currency (e.g., -150 USD)

#### Conditional Close Order Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| conditional | object | No | Template for secondary close orders on fills |
| conditional.order_type | string | No | Secondary order type |
| conditional.limit_price | float | Conditional | Secondary limit price |
| conditional.limit_price_type | string | No | `static`, `pct`, `quote` |
| conditional.trigger_price | float | No | Secondary trigger price |
| conditional.trigger_price_type | string | No | `static`, `pct`, `quote` |

#### Additional Order Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| cash_order_qty | float | No | Market orders only; volume in quote currency |
| display_qty | float | No | Iceberg orders only; minimum 1/15 of order_qty |
| effective_time | string | No | RFC3339 scheduled start time |
| expire_time | string | Conditional | GTD orders only; RFC3339 format; up to one month in the future |
| time_in_force | string | No | `gtc` (default), `gtd`, `ioc` |
| post_only | boolean | No | Limit orders only; cancels if takes liquidity. Default: `false` |
| margin | boolean | No | Uses maximum leverage (max 5). Default: `false` |
| reduce_only | boolean | No | Reduces margin position without opening opposite. Default: `false` |
| stp_type | string | No | Self Trade Prevention: `cancel_newest` (default), `cancel_oldest`, `cancel_both` |
| fee_preference | string | No | `base` or `quote`. Quote default for buys, base for sells |

#### Deprecated Fields

| Field | Description |
|-------|-------------|
| stop_price | Use `triggers` object instead |
| trigger | Use `triggers` object instead |
| no_mpp | Accepted but ignored |

## Response Format

### Success Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `batch_add` |
| success | boolean | `true` |
| result | array | Array of order result objects |
| req_id | integer | Echo of client request identifier |
| time_in | string | RFC3339 timestamp when request received |
| time_out | string | RFC3339 timestamp when response sent |
| warnings | array | Advisory messages about deprecated fields |

### Result Object Fields (per order)

| Field | Type | Description |
|-------|------|-------------|
| order_id | string | Unique order identifier generated by Kraken |
| cl_ord_id | string | Client-specified alphanumeric identifier (if provided) |
| order_userref | integer | Client-specified numeric identifier (if provided) |
| warnings | array | Advisory messages per order |

### Error Response Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `batch_add` |
| success | boolean | `false` |
| error | string | Error message |
| req_id | integer | Echo of client request identifier |
| time_in | string | RFC3339 timestamp when request received |
| time_out | string | RFC3339 timestamp when response sent |

## Snapshot vs Update Behavior

Not applicable. This is a request/response method, not a subscription channel.

## Example Messages

### Batch Add Request

```json
{
  "method": "batch_add",
  "params": {
    "deadline": "2022-06-13T08:09:10.123456Z",
    "orders": [
      {
        "limit_price": 1010.10,
        "order_qty": 0.123456789,
        "order_type": "limit",
        "order_userref": 1,
        "side": "buy"
      },
      {
        "limit_price": 2020.20,
        "order_qty": 0.987654321,
        "order_type": "limit",
        "order_userref": 2,
        "side": "sell",
        "stp_type": "cancel_both"
      }
    ],
    "symbol": "BTC/USD",
    "token": "TxxxxxxxxxOxxxxxxxxxxKxxxxxxxExxxxxxxxN",
    "validate": false
  },
  "req_id": 1234567890
}
```

### Success Response

```json
{
  "method": "batch_add",
  "req_id": 1234567890,
  "result": [
    {
      "order_id": "ORDERX-IDXXX-XXXXX1",
      "order_userref": 1
    },
    {
      "order_id": "ORDERX-IDXXX-XXXXX2",
      "order_userref": 2
    }
  ],
  "success": true,
  "time_in": "2022-06-13T08:09:10.123456Z",
  "time_out": "2022-06-13T08:09:10.7890123"
}
```

## Rate Limits

Not explicitly documented on this page.

## Notes

- **Batch size:** Minimum 2, maximum 15 orders per request.
- **Single pair:** All orders in a batch must be for the same currency pair.
- **Order of results:** The order of returned order IDs in the response array matches the order of the order list sent in the request.
- **Validation vs. engine failure:** Validation failures reject the entire batch; engine failures (e.g., insufficient funds) reject only the individual order.
- **Deadline precision:** Extends to milliseconds; default is 5 seconds from current time.
- **Market Price Protection (MPP):** Protects market orders from bad pricing due to slippage.
- For trailing-stop orders, the price parameter represents the reversion from the peak as a positive offset.
