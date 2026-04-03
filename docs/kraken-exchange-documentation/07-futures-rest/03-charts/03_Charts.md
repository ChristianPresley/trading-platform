# Charts

Source: [https://docs.kraken.com/api/docs/futures-api/charts/charts](https://docs.kraken.com/api/docs/futures-api/charts/charts)

## Overview

The Charts section provides public APIs for accessing chart candle data and analytics for Kraken Futures markets. These endpoints allow retrieval of OHLC (Open, High, Low, Close) candle data across various tick types, symbols, and resolutions.

## Base URL

```
https://futures.kraken.com/api/charts/v1
```

## Available Endpoints

### Candles

| Endpoint | Method | Path | Description |
|----------|--------|------|-------------|
| [Tick Types](tick-types.md) | GET | `/api/charts/v1/` | Returns all available tick types |
| [Markets (Symbols)](symbols.md) | GET | `/api/charts/v1/{tick_type}` | Returns markets available for a tick type |
| [Resolutions](resolutions.md) | GET | `/api/charts/v1/{tick_type}/{symbol}` | Returns available candle resolutions for a tick type and market |
| [Market Candles](candles.md) | GET | `/api/charts/v1/{tick_type}/{symbol}/{resolution}` | Returns OHLC candle data |

### Analytics

| Endpoint | Method | Path | Description |
|----------|--------|------|-------------|
| [Liquidity Pool Stats](liquidity-pool-stats.md) | GET | `/analytics/liquidity-pool` | Get liquidity pool statistics including USD value |
| [Market Analytics](market-analytics.md) | GET | `/analytics/{symbol}/{analytics_type}` | Analytics data divided into time buckets |

## Authentication

All Charts endpoints are **public** and do not require authentication.

## Candle Data Flow

To retrieve candle data, follow this sequence:

1. **Get Tick Types** - Discover available data categories (`mark`, `spot`, `trade`)
2. **Get Markets** - For a given tick type, discover available trading pairs
3. **Get Resolutions** - For a given tick type and market, discover available time intervals
4. **Get Candles** - Retrieve OHLC data for the specific tick type, market, and resolution

## Available Tick Types

| Tick Type | Description |
|-----------|-------------|
| `mark` | Mark price data |
| `spot` | Spot price data |
| `trade` | Trade price data |

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
