# Instrument

> Source: https://docs.kraken.com/api/docs/websocket-v2/instrument

## Overview

The instrument channel provides a stream of reference data of all active assets and tradeable pairs. It delivers symbol identifiers, precisions, trading parameters and rules.

## Connection

- **Endpoint:** `wss://ws.kraken.com/v2`
- **Channel:** `instrument`

## Authentication

No authentication required. This is a public reference data channel.

## Request/Subscription Format

```json
{
  "method": "subscribe",
  "params": {
    "channel": "instrument",
    "snapshot": true
  },
  "req_id": 79
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `subscribe` |
| params.channel | string | Yes | Value: `instrument` |
| params.include_tokenized_assets | boolean | No | When true, includes xStocks; otherwise crypto spot pairs only. Default: `false` |
| params.snapshot | boolean | No | Request snapshot after subscribing. Default: `true` |
| params.req_id | integer | No | Client-originated request identifier |

## Subscribe Acknowledgment

### Fields

| Field | Type | Description |
|-------|------|-------------|
| method | string | Value: `subscribe` |
| result.channel | string | Value: `instrument` |
| result.snapshot | boolean | Indicates if snapshot requested |
| result.warnings | array of strings | Advisory messages about deprecated fields |
| success | boolean | Whether request processed successfully |
| error | string | Error message if success is false (conditional) |
| time_in | string | RFC3339 subscription receipt timestamp |
| time_out | string | RFC3339 acknowledgment transmission timestamp |
| req_id | integer | Echoed from request |

### Example

```json
{
  "method": "subscribe",
  "req_id": 79,
  "result": {
    "channel": "instrument",
    "snapshot": true,
    "warnings": ["tick_size is deprecated, use price_increment"]
  },
  "success": true,
  "time_in": "2023-09-26T16:49:20.962586Z",
  "time_out": "2023-09-26T16:49:20.962630Z"
}
```

## Response/Update Format

The data object contains two arrays: `assets` and `pairs`.

### Snapshot Example

```json
{
  "channel": "instrument",
  "type": "snapshot",
  "data": {
    "assets": [
      {
        "id": "USD",
        "status": "enabled",
        "precision": 4,
        "precision_display": 2,
        "borrowable": true,
        "collateral_value": 1.0,
        "margin_rate": 0.015
      },
      {
        "id": "BTC",
        "status": "enabled",
        "precision": 10,
        "precision_display": 5,
        "borrowable": true,
        "collateral_value": 1.0,
        "margin_rate": 0.01
      }
    ],
    "pairs": [
      {
        "symbol": "BTC/USD",
        "base": "BTC",
        "quote": "USD",
        "status": "online",
        "qty_precision": 8,
        "qty_increment": 1e-08,
        "price_precision": 1,
        "cost_precision": 5,
        "marginable": true,
        "has_index": true,
        "cost_min": "0.5",
        "margin_initial": 0.2,
        "position_limit_long": 250,
        "position_limit_short": 200,
        "tick_size": 0.1,
        "price_increment": 0.1,
        "qty_min": 0.0001
      }
    ]
  }
}
```

## Response Fields

### Asset Fields

| Field | Type | Description |
|-------|------|-------------|
| id | string | Asset identifier (e.g., "BTC", "USD") |
| status | string | Asset status: `depositonly`, `disabled`, `enabled`, `fundingtemporarilydisabled`, `withdrawalonly`, `workinprogress` |
| precision | integer | Maximum precision for asset ledger/balances |
| precision_display | integer | Recommended display precision |
| borrowable | boolean | Whether asset is borrowable |
| collateral_value | float | Valuation as margin collateral |
| margin_rate | float | Interest rate to borrow asset |
| multiplier | float | Multiplier of tokenized asset |

### Pair Fields

| Field | Type | Description |
|-------|------|-------------|
| symbol | string | Currency pair symbol (e.g., "BTC/USD") |
| base | string | Base currency asset identifier |
| quote | string | Quote currency asset identifier |
| status | string | Pair status: `cancel_only`, `delisted`, `limit_only`, `maintenance`, `online`, `post_only`, `reduce_only`, `work_in_progress` |
| qty_precision | integer | Maximum precision for order quantities |
| qty_increment | float | Minimum quantity increment for orders |
| qty_min | float | Minimum quantity in base currency for orders |
| price_precision | integer | Maximum precision for order prices |
| price_increment | float | Minimum price increment for orders |
| cost_precision | integer | Maximum precision for cost prices |
| cost_min | string | Minimum cost (price x quantity) for orders |
| marginable | boolean | Whether pair is tradeable on margin |
| has_index | boolean | Whether pair has index for stop-loss triggers |
| margin_initial | float | Initial margin requirement percentage (conditional on marginable pairs) |
| position_limit_long | integer | Long position limit (conditional on marginable pairs) |
| position_limit_short | integer | Short position limit (conditional on marginable pairs) |
| tick_size | float | **Deprecated.** Use `price_increment` instead. |

### Container Fields

| Field | Type | Description |
|-------|------|-------------|
| channel | string | Value: `instrument` |
| type | string | `snapshot` or `update` |
| data.assets | array | Array of asset objects |
| data.pairs | array | Array of pair objects |

## Snapshot vs Update Behavior

- **Snapshot:** Delivered once after subscription (if `snapshot: true`). Contains all active assets and tradeable pairs.
- **Update:** Contains only changes to asset or pair configurations. May have empty arrays if nothing changed for that category (e.g., `"pairs": []`).

### Update Example

```json
{
  "channel": "instrument",
  "type": "update",
  "data": {
    "assets": [
      {
        "id": "BTC",
        "status": "enabled",
        "precision": 10,
        "precision_display": 5,
        "borrowable": true,
        "collateral_value": 1.0,
        "margin_rate": 0.01
      }
    ],
    "pairs": []
  }
}
```

## Example Messages

### Subscribe Request

```json
{
  "method": "subscribe",
  "params": {
    "channel": "instrument"
  },
  "req_id": 79
}
```

### Unsubscribe Request

```json
{
  "method": "unsubscribe",
  "params": {
    "channel": "instrument"
  },
  "req_id": 79
}
```

### Unsubscribe Acknowledgment

```json
{
  "method": "unsubscribe",
  "req_id": 79,
  "result": {
    "channel": "instrument"
  },
  "success": true,
  "time_in": "2023-09-26T16:49:20.962586Z",
  "time_out": "2023-09-26T16:49:20.962630Z"
}
```

## Unsubscribe Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| method | string | Yes | Value: `unsubscribe` |
| params.channel | string | Yes | Value: `instrument` |
| params.req_id | integer | No | Client-originated request identifier |

## Rate Limits

Not explicitly documented for this channel.

## Notes

- The `tick_size` field is deprecated; use `price_increment` instead.
- Subscribe acknowledgment may include warnings about deprecated fields.
- No `symbol` parameter is needed for subscription -- the instrument channel covers all assets and pairs.
- The `include_tokenized_assets` parameter controls whether xStocks (tokenized equities) are included.
