# Resolutions

Source: [https://docs.kraken.com/api/docs/futures-api/charts/resolutions](https://docs.kraken.com/api/docs/futures-api/charts/resolutions)

## Endpoint

```
GET /api/charts/v1/{tick_type}/{symbol}
```

**Full URL:** `https://futures.kraken.com/api/charts/v1/{tick_type}/{symbol}`

## Description

Returns all candle resolutions available for a specified tick type and market. Use this endpoint to discover which time intervals are supported for a given tick type and trading pair combination before requesting candle data.

## Authentication

This is a **public** endpoint. No authentication is required.

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tick_type` | string | Yes | The kind of price data. Values: `mark`, `spot`, `trade`. Available values can be retrieved from the [Tick Types](tick-types.md) endpoint. |
| `symbol` | string | Yes | The trading pair / contract symbol (e.g., `PI_XBTUSD`). Available values can be retrieved from the [Markets](symbols.md) endpoint. |

## Response Fields

### 200 - Resolutions List

The response is a JSON array of strings representing the available candle resolutions.

| Field | Type | Description |
|-------|------|-------------|
| (root) | array[string] | List of available resolution identifiers |

## Available Resolutions

| Resolution | Description |
|------------|-------------|
| `1m` | 1 minute |
| `5m` | 5 minutes |
| `15m` | 15 minutes |
| `30m` | 30 minutes |
| `1h` | 1 hour |
| `4h` | 4 hours |
| `12h` | 12 hours |
| `1d` | 1 day |
| `1w` | 1 week |

## Example

**Request:**

```
GET https://futures.kraken.com/api/charts/v1/mark/PI_XBTUSD
```

**Response:**

```json
["1h", "12h", "1w", "15m", "1d", "5m", "30m", "4h", "1m"]
```

## Notes

- Not all resolutions may be available for every tick type and symbol combination.
- The order of resolutions in the response is not guaranteed to be sorted.
- Use the returned resolutions as the final path component when requesting [Market Candles](candles.md).
- The data flow for retrieving candles is: Tick Types -> Markets -> **Resolutions** -> Candles.
