# Charts

Public chart and analytics endpoints -- OHLC candle data, market analytics, and liquidity pool statistics.

## Contents

1. [Analytics](01_Analytics.md) -- Overview of analytics endpoints for market analytics and liquidity pool data.
   - `GET /analytics/liquidity-pool`, `GET /analytics/{symbol}/{analytics_type}`
2. [Candles](02_Candles.md) -- Retrieve OHLC candle data for a given tick type, market symbol, and resolution.
   - `GET /api/charts/v1/{tick_type}/{symbol}/{resolution}`
3. [Charts](03_Charts.md) -- Overview of all chart candle and analytics endpoints with base URL.
   - `GET /api/charts/v1/...`
4. [Liquidity Pool Stats](04_Liquidity-Pool-Stats.md) -- Retrieve liquidity pool statistics including USD value.
   - `GET /analytics/liquidity-pool`
5. [Market Analytics](05_Market-Analytics.md) -- Retrieve analytics data divided into time buckets for a market symbol.
   - `GET /analytics/{symbol}/{analytics_type}`
6. [Resolutions](06_Resolutions.md) -- Return available candle resolutions for a given tick type and market symbol.
   - `GET /api/charts/v1/{tick_type}/{symbol}`
7. [Symbols](07_Symbols.md) -- Return available markets (trading pairs) for a given tick type.
   - `GET /api/charts/v1/{tick_type}`
8. [Tick Types](08_Tick-Types.md) -- Return all available tick types for charting.
   - `GET /api/charts/v1/`
