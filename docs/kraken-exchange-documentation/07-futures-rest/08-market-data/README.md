# Market Data

Public market data endpoints -- trade history, order book snapshots, and ticker information.

## Contents

1. [Get Trade History](01_Get-History.md) -- Return the most recent 100 trades for a contract (up to 7 days back).
   - `GET /derivatives/api/v3/history`
2. [Get Orderbook](02_Get-Orderbook.md) -- Return the full non-cumulative order book for listed futures contracts.
   - `GET /derivatives/api/v3/orderbook`
3. [Get Ticker](03_Get-Ticker.md) -- Return market data for a single contract or index by symbol.
   - `GET /derivatives/api/v3/tickers/{symbol}`
4. [Get Tickers](04_Get-Tickers.md) -- Return current market data for all listed futures contracts and indices.
   - `GET /derivatives/api/v3/tickers`
