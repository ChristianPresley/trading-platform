# Balances

> Source: https://docs.kraken.com/api/docs/websocket-v2/balances

## Overview

The balances channel streams client asset balances and transactions from the account ledger. This authenticated channel requires a session token and streams both snapshot and update data.

## Connection

- **Endpoint:** `wss://ws-auth.kraken.com/v2`
- **Channel:** `balances`

## Authentication

**Required.** A session token is required. See Kraken REST API guides on how to generate a token.

## Request/Subscription Format

```json
{
  "method": "subscribe",
  "params": {
    "channel": "balances",
    "token": "G38a1tGFzqGiUCmnegBcm8d4nfP3tytiNQz6tkCBYXY"
  }
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `subscribe` |
| params.channel | string | Yes | Value: `balances` |
| params.token | string | Yes | Authenticated session token |
| params.snapshot | boolean | No | Request snapshot post-subscription. Default: `true` |
| params.rebased | boolean | No | For xstocks only. Default: `true` |
| params.users | string | No | Master accounts only; value `"all"` streams events for master and subaccounts |
| params.req_id | integer | No | Client-originated request identifier |

## Subscribe Acknowledgment

### Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `subscribe` |
| result.channel | string | Value: `balances` |
| result.snapshot | boolean | Indicates if snapshot requested |
| success | boolean | Request processing status |
| error | string | Present if success is false (conditional) |
| time_in | string | RFC3339 wire receipt timestamp |
| time_out | string | RFC3339 transmission timestamp |
| req_id | integer | Echo of client request ID (optional) |
| warnings | array | Advisory messages about deprecated fields |

### Example

```json
{
  "method": "subscribe",
  "result": {
    "channel": "balances",
    "snapshot": true
  },
  "success": true,
  "time_in": "2023-10-16T13:29:13.111530Z",
  "time_out": "2023-10-16T13:29:13.111775Z"
}
```

## Snapshot Response Format

The snapshot provides the value of each asset held in the account. Delivered once upon subscription (if requested).

```json
{
  "channel": "balances",
  "type": "snapshot",
  "data": [
    {
      "asset": "BTC",
      "asset_class": "currency",
      "balance": 1.2,
      "wallets": [
        {
          "type": "spot",
          "id": "main",
          "balance": 1.2
        }
      ]
    }
  ],
  "sequence": 1
}
```

### Snapshot Fields

| Field | Type | Description |
|-------|------|-------------|
| channel | string | Value: `balances` |
| type | string | Value: `snapshot` |
| sequence | integer | Subscription message sequence number |
| data[].asset | string | Asset symbol code |
| data[].asset_class | string | Value: `currency` (placeholder for expansion) |
| data[].balance | float | Total asset amount across wallet types |
| data[].wallets | array | Wallet breakdown |
| data[].wallets[].type | string | `spot` or `earn` |
| data[].wallets[].id | string | `main`, `flex`, `bonded`, `flexible`, `liquid`, `locked`, or `closed` |
| data[].wallets[].balance | float | Asset amount in specific wallet |

## Update Response Format

Streamed per completed transaction.

```json
{
  "channel": "balances",
  "type": "update",
  "data": [
    {
      "ledger_id": "ADKKFF-WEA5A-CNUBHG",
      "ref_id": "AGBWUJRU-LAREZ-W3UFAN",
      "timestamp": "2023-09-22T10:23:42.925034Z",
      "type": "deposit",
      "asset": "BTC",
      "asset_class": "currency",
      "category": "deposit",
      "wallet_type": "spot",
      "wallet_id": "main",
      "amount": 0.01,
      "fee": 0.0,
      "balance": 0.02
    }
  ],
  "sequence": 2
}
```

### Update Fields

| Field | Type | Description |
|-------|------|-------------|
| channel | string | Value: `balances` |
| type | string | Value: `update` |
| sequence | integer | Message sequence number |
| data[].asset | string | Asset symbol |
| data[].asset_class | string | Value: `currency` |
| data[].amount | float | Asset change amount |
| data[].balance | float | Total asset held post-transaction |
| data[].fee | float | Transaction fee |
| data[].ledger_id | string | Account ledger entry identifier |
| data[].ref_id | string | Reference identifier (e.g., trade_id for trades) |
| data[].timestamp | string | RFC3339 balance change time |
| data[].type | string | Transaction type (see table below) |
| data[].subtype | string | Transaction subtype (optional, see table below) |
| data[].category | string | Transaction category (see table below) |
| data[].wallet_type | string | `spot` or `earn` |
| data[].wallet_id | string | `main`, `bonded`, `flexible`, `liquid`, or `locked` |
| data[].user | string | Kraken user identifier when `users=all` (conditional) |

### Transaction Types

`deposit`, `withdrawal`, `trade`, `margin`, `adjustment`, `rollover`, `credit`, `transfer`, `settled`, `staking`, `sale`, `reserve`, `conversion`, `dividend`, `reward`, `creator_fee`

### Transaction Subtypes

`spotfromfutures`, `spottofutures`, `stakingfromspot`, `spotfromstaking`, `stakingtospot`, `spottostaking`

### Transaction Categories

`deposit`, `withdrawal`, `trade`, `margin-trade`, `margin-settle`, `margin-conversion`, `conversion`, `credit`, `marginrollover`, `staking-rewards`, `instant`, `equity-trade`, `airdrop`, `equity-dividend`, `reward-bonus`, `nft`, `block-trade`

## Snapshot vs Update Behavior

- **Snapshot:** Represents the complete account state at subscription time. Contains every asset with its total balance and wallet breakdown.
- **Update:** Streamed individually after each transaction completion. Multiple updates may reference the same transaction via shared `ref_id` (e.g., both sides of a trade appear as separate balance updates).

## Example Messages

### Subscribe Request

```json
{
  "method": "subscribe",
  "params": {
    "channel": "balances",
    "token": "G38a1tGFzqGiUCmnegBcm8d4nfP3tytiNQz6tkCBYXY"
  }
}
```

### Snapshot Response

```json
{
  "channel": "balances",
  "data": [
    {
      "asset": "BTC",
      "asset_class": "currency",
      "balance": 1.2,
      "wallets": [
        {
          "type": "spot",
          "id": "main",
          "balance": 1.2
        }
      ]
    },
    {
      "asset": "MATIC",
      "asset_class": "currency",
      "balance": 500,
      "wallets": [
        {"type": "spot", "id": "main", "balance": 300},
        {"type": "earn", "id": "flex", "balance": 200}
      ]
    }
  ],
  "type": "snapshot",
  "sequence": 1
}
```

### Update Response (Deposit)

```json
{
  "channel": "balances",
  "type": "update",
  "data": [
    {
      "ledger_id": "ADKKFF-WEA5A-CNUBHG",
      "ref_id": "AGBWUJRU-LAREZ-W3UFAN",
      "timestamp": "2023-09-22T10:23:42.925034Z",
      "type": "deposit",
      "asset": "BTC",
      "asset_class": "currency",
      "category": "deposit",
      "wallet_type": "spot",
      "wallet_id": "main",
      "amount": 0.01,
      "fee": 0.0,
      "balance": 0.02
    }
  ],
  "sequence": 2
}
```

### Update Response (Trade -- BTC side)

```json
{
  "channel": "balances",
  "type": "update",
  "data": [
    {
      "ledger_id": "AAICKV-NMQSR-ZO5IJD",
      "ref_id": "AGBB7L-HT5LX-J3BB4A",
      "timestamp": "2023-09-22T10:33:05.710082Z",
      "type": "trade",
      "asset": "BTC",
      "asset_class": "currency",
      "category": "trade",
      "wallet_type": "spot",
      "wallet_id": "main",
      "amount": -0.005,
      "fee": 0.0,
      "balance": 0.005
    }
  ],
  "sequence": 9
}
```

### Update Response (Trade -- USD side)

```json
{
  "channel": "balances",
  "type": "update",
  "data": [
    {
      "ledger_id": "A5KS77-LQRMP-SMMN4B",
      "ref_id": "AGBB7L-HT5LX-J3BB4A",
      "timestamp": "2023-09-22T10:33:05.710082Z",
      "type": "trade",
      "asset": "USD",
      "asset_class": "currency",
      "category": "trade",
      "wallet_type": "spot",
      "wallet_id": "main",
      "amount": 132.9995,
      "fee": 0.3458,
      "balance": 500
    }
  ],
  "sequence": 10
}
```

### Unsubscribe Request

```json
{
  "method": "unsubscribe",
  "params": {
    "channel": "balances",
    "token": "G38a1tGFzqGiUCmnegBcm8d4nfP3tytiNQz6tkCBYXY"
  }
}
```

### Unsubscribe Acknowledgment

```json
{
  "method": "unsubscribe",
  "result": {
    "channel": "balances"
  },
  "success": true,
  "time_in": "2023-10-16T13:29:13.111530Z",
  "time_out": "2023-10-16T13:29:13.111775Z"
}
```

## Unsubscribe Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `unsubscribe` |
| params.channel | string | Yes | Value: `balances` |
| params.token | string | Yes | Authenticated session token |
| params.req_id | integer | No | Client request identifier |

## Rate Limits

Not explicitly documented for this channel.

## Notes

- Both sides of a trade appear as separate balance updates sharing the same `ref_id`.
- The `sequence` field provides message ordering within the subscription.
- Master accounts can use `users: "all"` to receive events for all subaccounts.
- The wallet breakdown in snapshots shows how balances are distributed across spot and earn wallets.
