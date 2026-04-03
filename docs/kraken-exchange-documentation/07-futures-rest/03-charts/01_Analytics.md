# Analytics

Source: [https://docs.kraken.com/api/docs/futures-api/charts/analytics](https://docs.kraken.com/api/docs/futures-api/charts/analytics)

## Overview

The Analytics section provides public APIs for accessing market analytics and liquidity pool statistics for Kraken Futures markets. Analytics data is divided into time buckets for historical analysis.

## Available Endpoints

| Endpoint | Method | Path | Description |
|----------|--------|------|-------------|
| [Liquidity Pool Stats](liquidity-pool-stats.md) | GET | `/analytics/liquidity-pool` | Get liquidity pool statistics including USD value |
| [Market Analytics](market-analytics.md) | GET | `/analytics/{symbol}/{analytics_type}` | Analytics data divided into time buckets |

## Authentication

Analytics endpoints are **public** and do not require authentication.

## Error Responses

Analytics endpoints return standard HTTP error codes:

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Query has invalid arguments |
| 404 | Symbol or analytics type could not be found |
