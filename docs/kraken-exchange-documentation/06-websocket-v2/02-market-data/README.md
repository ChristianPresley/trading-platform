# Market Data

Real-time public market data channels for order book, instrument reference, OHLC, ticker, and trade data.

## Contents

1. [Book](01_Book.md) -- Level 2 order book with aggregated quantities at each price level, snapshots and incremental updates.
   - Channel: `book`
2. [Instrument](02_Instrument.md) -- Reference data stream for all active assets and tradeable pairs including symbols, precisions, and trading parameters.
   - Channel: `instrument`
3. [Level 3](03_Level3.md) -- Granular individual order visibility in the order book (requires authentication, separate endpoint).
   - Channel: `level3`
4. [OHLC](04_Ohlc.md) -- Open/High/Low/Close candlestick data for configurable interval periods, updated on trade events.
   - Channel: `ohlc`
5. [Ticker](05_Ticker.md) -- Level 1 top-of-book and recent trade data, updated on trade events.
   - Channel: `ticker`
6. [Trade](06_Trade.md) -- Real-time matched trade events, potentially batched in a single message.
   - Channel: `trade`
