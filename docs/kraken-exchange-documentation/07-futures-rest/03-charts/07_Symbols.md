# Markets (Symbols)

Source: [https://docs.kraken.com/api/docs/futures-api/charts/symbols](https://docs.kraken.com/api/docs/futures-api/charts/symbols)

## Endpoint

```
GET /api/charts/v1/{tick_type}
```

**Full URL:** `https://futures.kraken.com/api/charts/v1/{tick_type}`

## Description

Returns all markets (trading pairs) available for a specified tick type. Use this endpoint to discover which futures contracts have chart data available for a given tick type category.

## Authentication

This is a **public** endpoint. No authentication is required.

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tick_type` | string | Yes | The kind of price data. Values: `mark`, `spot`, `trade`. Available values can be retrieved from the [Tick Types](tick-types.md) endpoint. |

## Response Fields

### 200 - Markets List

The response is a JSON array of strings representing the available market symbols for the specified tick type.

| Field | Type | Description |
|-------|------|-------------|
| (root) | array[string] | List of available market/contract symbols |

## Example

**Request:**

```
GET https://futures.kraken.com/api/charts/v1/trade
```

**Response:**

```json
["PI_XBTUSD", "PF_XBTUSD", "PF_SOLUSD", "PF_ETHUSD", ...]
```

## Notes

- Symbol naming conventions:
  - `PI_` prefix: Inverse perpetual contracts (e.g., `PI_XBTUSD`)
  - `PF_` prefix: Linear (vanilla) perpetual contracts (e.g., `PF_XBTUSD`, `PF_SOLUSD`)
  - `FI_` prefix: Inverse fixed maturity contracts
  - `FF_` prefix: Linear fixed maturity contracts
- Not all symbols may be available for every tick type. Query each tick type separately to get the correct list.
- Use the returned symbols as input to the [Resolutions](resolutions.md) endpoint to discover available time intervals.
- The data flow for retrieving candles is: Tick Types -> **Markets** -> Resolutions -> Candles.
