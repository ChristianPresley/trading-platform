# Tick Types

Source: [https://docs.kraken.com/api/docs/futures-api/charts/tick-types](https://docs.kraken.com/api/docs/futures-api/charts/tick-types)

## Endpoint

```
GET /api/charts/v1/
```

**Full URL:** `https://futures.kraken.com/api/charts/v1/`

## Description

Returns all available tick types that can be used with the [Markets](symbols.md), [Resolutions](resolutions.md), and [Market Candles](candles.md) endpoints. Tick types represent the different categories of price data available for charting.

## Authentication

This is a **public** endpoint. No authentication is required.

## Request Parameters

This endpoint takes no parameters.

## Response Fields

### 200 - Tick Types List

The response is a JSON array of strings representing the available tick types.

| Field | Type | Description |
|-------|------|-------------|
| (root) | array[string] | List of available tick type identifiers |

## Available Tick Types

| Tick Type | Description |
|-----------|-------------|
| `mark` | Mark price - calculated from order book and external index prices, used for margin calculations and liquidations |
| `spot` | Spot/index price - the underlying spot market price |
| `trade` | Trade price - based on actual executed trades |

## Example

**Request:**

```
GET https://futures.kraken.com/api/charts/v1/
```

**Response:**

```json
["mark", "spot", "trade"]
```

## Notes

- The tick type is the first path component when building candle data requests.
- Use the returned tick types as input to the [Markets](symbols.md) endpoint to discover which trading pairs are available for each tick type.
- The data flow for retrieving candles is: Tick Types -> Markets -> Resolutions -> Candles.
