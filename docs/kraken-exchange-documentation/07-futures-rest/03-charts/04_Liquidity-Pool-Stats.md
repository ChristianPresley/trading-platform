# Get Liquidity Pool Statistic

Source: [https://docs.kraken.com/api/docs/futures-api/charts/liquidity-pool-stats](https://docs.kraken.com/api/docs/futures-api/charts/liquidity-pool-stats)

## Endpoint

```
GET /analytics/liquidity-pool
```

**Full URL:** `https://futures.kraken.com/analytics/liquidity-pool`

## Description

Retrieves liquidity pool statistics including USD value. This endpoint provides analytics data about the liquidity pool state for Kraken Futures markets.

## Authentication

This is a **public** endpoint. No authentication is required.

## Request Parameters

This endpoint takes no documented request parameters.

## Response Fields

### 200 - Success

Returns available analytics by type and symbol, including liquidity pool statistics with USD valuations.

| Field | Type | Description |
|-------|------|-------------|
| (varies) | object | Liquidity pool statistics including USD value |

## Error Responses

| Code | Description |
|------|-------------|
| 400 | Query has invalid arguments |
| 404 | Symbol or analytics type could not be found |

## Example

**Request:**

```
GET https://futures.kraken.com/analytics/liquidity-pool
```

## Notes

- This endpoint is part of the Analytics subsection within the Charts API group.
- The analytics data provides insight into market liquidity conditions.
- See also [Market Analytics](market-analytics.md) for time-bucketed analytics data.
