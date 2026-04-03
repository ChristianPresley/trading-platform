# Balances

> Source: https://docs.kraken.com/api/docs/futures-api/websocket/balances

## Overview

This feed returns balance information for holding wallets, single collateral wallets, and multi-collateral wallets. It delivers a snapshot upon subscription, followed by delta updates as balances change.

## Connection

- **Endpoint:** `wss://futures.kraken.com/ws/v1`
- **Feed:** `balances`

## Authentication

Required. Uses challenge-response authentication:

- `api_key` -- The user API key
- `original_challenge` -- The message received from a challenge request
- `signed_challenge` -- The challenge message signed with user API secret

## Request/Subscription Format

```json
{
  "event": "subscribe",
  "feed": "balances",
  "api_key": "drUfSSmBbDpcIpwpqK0OBTcGLdAYZJU+NlPIsHaKspu/8feT2YSKl+Jw",
  "original_challenge": "c094497e-9b5f-40da-a122-3751c39b107f",
  "signed_challenge": "Ds0wtsHaXlAby/Vnoil59Q+yJIrJwZGUlgECD3+qEvFcTFfacJi2LrSRzAoqwBAeZk4pGXSmyyIW0uDymZ3olw=="
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| event | string | Yes | `subscribe` or `unsubscribe` |
| feed | string | Yes | The requested subscription feed: `balances` |
| api_key | string | Yes | User API key |
| original_challenge | string | Yes | Message received from challenge request |
| signed_challenge | string | Yes | Challenge message signed with user API secret |

## Subscription Confirmation

```json
{
  "event": "subscribed",
  "feed": "balances"
}
```

## Response/Update Format

The response contains three wallet types: holding, single collateral (futures), and multi-collateral (flex_futures).

## Response Fields -- Holding Wallet

| Field | Type | Description |
|-------|------|-------------|
| feed | string | The subscribed feed |
| account | string | The user account identifier |
| timestamp | positive integer | Unix timestamp in milliseconds |
| seq | positive integer | Subscription message sequence number |
| holding | map of floats | Currency names mapped to balance quantities |

## Response Fields -- Single Collateral Wallet (futures)

| Field | Type | Description |
|-------|------|-------------|
| name | string | Account name |
| pair | string | Wallet currency pair (e.g., `XBT/USD`) |
| unit | string | Settlement unit |
| portfolio_value | float | Balance with haircuts and unrealized margin |
| balance | float | Balance in settlement units |
| maintenance_margin | positive float | Maintenance margin for open positions |
| initial_margin | float | Initial margin for positions and orders |
| available | float | Portfolio value minus initial margin |
| unrealized_funding | positive float | Total unrealized funding |
| pnl | positive float | Total profit and loss |
| cash_value | float | USD cash value |

## Response Fields -- Multi-Collateral Wallet (flex_futures)

| Field | Type | Description |
|-------|------|-------------|
| balance_value | float | Current USD balance |
| portfolio_value | float | Collateral value with unrealized margin |
| collateral_value | float | USD balance with haircuts applied |
| initial_margin | float | Total initial margin for positions/orders |
| initial_margin_without_orders | float | Initial margin for positions only |
| maintenance_margin | float | Total maintenance margin |
| pnl | float | Total profit and loss |
| unrealized_funding | float | Total unrealized funding |
| total_unrealized | float | Unrealized funding plus PnL |
| total_unrealized_as_margin | float | Total unrealized in USD |
| margin_equity | float | Collateral value plus unrealized margin |
| available_margin | float | Margin equity minus initial margin |
| effective_leverage | float | Position size to margin equity ratio |
| total_position_size | float | Sum of position sizes in USD |
| unified_balances | boolean | Whether unified balances are enabled |
| currencies | map of structures | Collateral currencies with quantity, value, haircut |
| isolated | map of structures | Isolated position margin information |
| cross | map of structures | Cross position margin information |
| portfolio_margin_breakdown | map of structures | Market risk, delta, maintenance margin components |

## Notes

- Two types of data messages are sent: snapshot (initial) and delta (updates)
- Holding wallet represents spot balances
- Single collateral wallets are futures-specific, one per trading pair
- Multi-collateral supports multiple currency collateral with haircuts
- Sequence numbers track message ordering
- Timestamps use millisecond unix precision

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
