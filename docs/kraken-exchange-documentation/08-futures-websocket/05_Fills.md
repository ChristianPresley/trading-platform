# Fills

> Source: https://docs.kraken.com/api/docs/futures-api/websocket/fills

## Overview

This subscription feed publishes fills information. It delivers a snapshot of recent fills upon subscription, followed by real-time updates as new fills occur.

## Connection

- **Endpoint:** `wss://futures.kraken.com/ws/v1`
- **Feed:** `fills`

## Authentication

Required. Uses challenge-response authentication:

- `api_key` -- The user API key
- `original_challenge` -- The message received from a challenge request
- `signed_challenge` -- The challenge message signed with user API secret

## Request/Subscription Format

```json
{
  "event": "subscribe",
  "feed": "fills",
  "product_ids": ["FI_XBTUSD_200925"],
  "api_key": "CMl2SeSn09Tz+2tWuzPiPUjaXEQRGq6qv5UaexXuQ3SnahDQU/gO3aT+",
  "original_challenge": "226aee50-88fc-4618-a42a-34f7709570b2",
  "signed_challenge": "RE0DVOc7vS6pzcEjGWd/WJRRBWb54RkyvV+AZQSRl4+rap8Rlk64diR+Z9DQILm7qxncswMmJyvP/2vgzqqh+g=="
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| event | string | Yes | `subscribe` or `unsubscribe` |
| feed | string | Yes | The requested subscription feed: `fills` |
| product_ids | list of strings | No | Subscribe only to specific products (optional filter) |
| api_key | string | Yes | User API key |
| original_challenge | string | Yes | Message received from challenge request |
| signed_challenge | string | Yes | Challenge signed with API secret |

## Subscription Confirmation

```json
{
  "event": "subscribed",
  "feed": "fills",
  "product_ids": ["FI_XBTUSD_200925"],
  "api_key": "CMl2SeSn09Tz+2tWuzPiPUjaXEQRGq6qv5UaexXuQ3SnahDQU/gO3aT+",
  "original_challenge": "226aee50-88fc-4618-a42a-34f7709570b2",
  "signed_challenge": "RE0DVOc7vS6pzcEjGWd/WJRRBWb54RkyvV+AZQSRl4+rap8Rlk64diR+Z9DQILm7qxncswMmJyvP/2vgzqqh+g=="
}
```

## Snapshot Response Format

```json
{
  "feed": "fills_snapshot",
  "account": "DemoUser",
  "fills": [
    {
      "instrument": "FI_XBTUSD_200925",
      "time": 1600256910739,
      "price": 10937.5,
      "seq": 36,
      "buy": true,
      "qty": 5000.0,
      "remaining_order_qty": 0.0,
      "order_id": "9e30258b-5a98-4002-968a-5b0e149bcfbf",
      "fill_id": "cad76f07-814e-4dc6-8478-7867407b6bff",
      "fill_type": "maker",
      "fee_paid": -0.00009142857,
      "fee_currency": "BTC",
      "taker_order_type": "ioc",
      "order_type": "limit"
    }
  ]
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| feed | string | The subscribed feed identifier (`fills_snapshot` or `fills`) |
| account | string | The user account name |
| fills | list | Array of fill structures |
| instrument | string | Fill instrument (symbol/product_id) |
| time | positive integer | Server UTC timestamp in milliseconds |
| price | positive float | Price at which order was filled |
| seq | positive integer | Subscription message sequence number |
| buy | boolean | Flag indicating if filled order was a buy |
| qty | positive float | Quantity that was filled |
| remaining_order_qty | positive float | Unfilled quantity remaining in order |
| order_id | UUID | Order identifier that was filled |
| cli_ord_id | UUID | Unique client order identifier (optional) |
| fill_id | UUID | Unique fill identifier |
| fill_type | string | Classification (see below) |
| fee_paid | float | Fee charged on fill |
| fee_currency | string | Currency of fee charge |
| taker_order_type | string | Taker execution order type |
| order_type | string | Order type associated with fill |

## Fill Types

- `maker` -- Resting order that was matched
- `taker` -- Incoming order that matched resting orders
- `liquidation` -- Fill from a liquidation event
- `assignee` -- Assignment fill (options)
- `assignor` -- Assignor fill (options)
- `unwindBankrupt` -- Bankrupt unwind fill
- `unwindCounterparty` -- Counterparty unwind fill
- `takerAfterEdit` -- Taker fill after order edit

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
