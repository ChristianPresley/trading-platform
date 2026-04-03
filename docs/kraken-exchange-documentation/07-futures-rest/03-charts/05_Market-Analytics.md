# Market Analytics

Source: [https://docs.kraken.com/api/docs/futures-api/charts/market-analytics](https://docs.kraken.com/api/docs/futures-api/charts/market-analytics)

## Endpoint

```
GET /analytics/{symbol}/{analytics_type}
```

**Full URL:** `https://futures.kraken.com/analytics/{symbol}/{analytics_type}`

## Description

Retrieves analytics data divided into time buckets for a specified market symbol and analytics type. This endpoint provides historical analytics data for analyzing market conditions over time.

## Authentication

This is a **public** endpoint. No authentication is required.

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `symbol` | string | Yes | The trading pair / contract symbol (e.g., `PI_XBTUSD`, `PF_SOLUSD`) |
| `analytics_type` | string | Yes | The type of analytics data to retrieve |

## Response Fields

### 200 - Success

Returns analytics data organized into time-based buckets for the specified symbol and analytics type.

| Field | Type | Description |
|-------|------|-------------|
| (varies) | object | Analytics data divided into time buckets |

## Error Responses

| Code | Description |
|------|-------------|
| 400 | Query has invalid arguments |
| 404 | Symbol or analytics type could not be found |

### Error Response Object

| Field | Type | Description |
|-------|------|-------------|
| `error` | string | Error description |
| `result` | string | `error` |

## Example

**Request:**

```
GET https://futures.kraken.com/analytics/PI_XBTUSD/volume
```

## Notes

- Analytics data is organized into time buckets for historical analysis.
- The available analytics types and their specific response schemas depend on the market and data available.
- If the specified symbol or analytics type does not exist, a 404 error is returned.
- See also [Liquidity Pool Stats](liquidity-pool-stats.md) for liquidity-specific analytics.
