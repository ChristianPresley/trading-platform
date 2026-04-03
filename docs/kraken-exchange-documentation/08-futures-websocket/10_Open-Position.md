# Open Positions

> Source: https://docs.kraken.com/api/docs/futures-api/websocket/open_position

## Overview

This subscription feed publishes the open positions of the user account. It delivers a full snapshot of all open positions upon subscription, with real-time updates as positions change.

## Connection

- **Endpoint:** `wss://futures.kraken.com/ws/v1`
- **Feed:** `open_positions`

## Authentication

Required. Uses challenge-response authentication:

- `api_key` -- The user API key
- `original_challenge` -- The message received from a challenge request
- `signed_challenge` -- The challenge message signed with user API secret

## Request/Subscription Format

```json
{
  "event": "subscribe",
  "feed": "open_positions",
  "api_key": "CMl2SeSn09Tz+2tWuzPiPUjaXEQRGq6qv5UaexXuQ3SnahDQU/gO3aT+",
  "original_challenge": "226aee50-88fc-4618-a42a-34f7709570b2",
  "signed_challenge": "RE0DVOc7vS6pzcEjGWd/WJRRBWb54RkyvV+AZQSRl4+rap8Rlk64diR+Z9DQILm7qxncswMmJyvP/2vgzqqh+g=="
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| event | string | Yes | `subscribe` or `unsubscribe` |
| feed | string | Yes | The requested subscription feed: `open_positions` |
| api_key | string | Yes | The user API key |
| original_challenge | string | Yes | Message received from challenge request |
| signed_challenge | string | Yes | Challenge message signed with user API secret |

## Subscription Confirmation

```json
{
  "event": "subscribed",
  "feed": "open_positions",
  "api_key": "CMl2SeSn09Tz+2tWuzPiPUjaXEQRGq6qv5UaexXuQ3SnahDQU/gO3aT+",
  "original_challenge": "226aee50-88fc-4618-a42a-34f7709570b2",
  "signed_challenge": "RE0DVOc7vS6pzcEjGWd/WJRRBWb54RkyvV+AZQSRl4+rap8Rlk64diR+Z9DQILm7qxncswMmJyvP/2vgzqqh+g=="
}
```

## Response/Update Format

```json
{
  "feed": "open_positions",
  "account": "DemoUser",
  "positions": [
    {
      "instrument": "PI_XRPUSD",
      "balance": 500.0,
      "pnl": -239.6506683474764,
      "entry_price": 0.3985,
      "mark_price": 0.4925844,
      "index_price": 0.49756,
      "liquidation_threshold": 0.0,
      "effective_leverage": 0.17404676894304316,
      "return_on_equity": -2.3609636135508127,
      "initial_margin": 101.5054475943615,
      "initial_margin_with_orders": 101.5054475943615,
      "maintenance_margin": 50.75272379718075
    }
  ],
  "seq": 4,
  "timestamp": 1687383625330
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| feed | string | The subscribed feed identifier |
| account | string | The user account name |
| positions | list | Array of open position structures |
| seq | positive integer | Message sequence number |
| timestamp | positive integer | Timestamp of the update in milliseconds |

### Position Fields

| Field | Type | Description |
|-------|------|-------------|
| instrument | string | The instrument/symbol/product_id |
| balance | float | Size of the position |
| entry_price | float | Average entry price of the instrument |
| mark_price | float | Market price of position instrument |
| index_price | float | Index price of position instrument |
| pnl | float | Profit and loss of the position |
| liquidation_threshold | float | Mark price at which position liquidates |
| return_on_equity | float | Percentage gain/loss relative to initial margin (PnL/IM) |
| unrealized_funding | float | Unrealised funding from funding rate |
| effective_leverage | float | Net position leverage in margin account (Position Value at Market / Portfolio Value) |
| initial_margin | float | Initial margin for open position |
| initial_margin_with_orders | float | Initial margin for position and open orders |
| maintenance_margin | float | Maintenance margin for open position |
| pnl_currency | float | Profit currency for position (not returned for inverse) |

### Options Position Fields (Additional)

| Field | Type | Description |
|-------|------|-------------|
| iv | float | Option's implied volatility |
| delta | float | Option sensitivity to underlying price change |
| theta | float | Option sensitivity to passage of time |
| gamma | float | Delta's sensitivity to underlying price change |
| vega | float | Option sensitivity to volatility change |
| rho | float | Option sensitivity to interest rate |

## Error Response

```json
{
  "event": "error",
  "message": "Invalid product id"
}
```

### Error Messages

- `Invalid product id`
- `Invalid feed`
- `Json Error`
