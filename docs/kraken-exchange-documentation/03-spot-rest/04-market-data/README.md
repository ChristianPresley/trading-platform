# Market Data

Public and private endpoints for retrieving market data including asset info, order books, OHLC, trades, spreads, tickers, and system status.

## Contents

1. [Get Asset Info](01_Get-Asset-Info.md) — Get information about assets available for deposit, withdrawal, trading, and earn.
   - `GET /0/public/Assets`
2. [Get Grouped Order Book](02_Get-Grouped-Order-Book.md) — Get order book volume aggregated over a specified tick range.
   - `GET /0/public/GroupedBook`
3. [Get Level 3 Order Book](03_Get-Level-3-Order-Book.md) — Retrieve L3 order book with individual order IDs and timestamps.
   - `POST /0/private/Level3`
4. [Get OHLC Data](04_Get-Ohlc-Data.md) — Retrieve OHLC candlestick market data (up to 720 entries).
   - `GET /0/public/OHLC`
5. [Get Order Book](05_Get-Order-Book.md) — Get L2 order book with aggregated quantities at each price level.
   - `GET /0/public/Depth`
6. [Get Recent Spreads](06_Get-Recent-Spreads.md) — Get the last ~200 top-of-book spreads for a given pair.
   - `GET /0/public/Spread`
7. [Get Recent Trades](07_Get-Recent-Trades.md) — Get the last 1000 trades by default for a given pair.
   - `GET /0/public/Trades`
8. [Get Server Time](08_Get-Server-Time.md) — Get the server's current time.
   - `GET /0/public/Time`
9. [Get System Status](09_Get-System-Status.md) — Get the current system status or trading mode.
   - `GET /0/public/SystemStatus`
10. [Get Ticker Information](10_Get-Ticker-Information.md) — Get ticker information for all or requested markets.
    - `GET /0/public/Ticker`
11. [Get Tradable Asset Pairs](11_Get-Tradable-Asset-Pairs.md) — Get tradable asset pairs and their parameters.
    - `GET /0/public/AssetPairs`
