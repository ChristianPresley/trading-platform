## Historical Market Data

### End-of-Day (EOD) Data

EOD data provides daily summary statistics for each instrument:

- **Official closing price**: The exchange-determined closing price (often from a closing auction).
- **Adjusted close**: Closing price adjusted for corporate actions (splits, dividends). Critical for long-term return analysis.
- **OHLCV**: Open, high, low, close, volume for the session.
- **Settlement price**: For futures and options, the daily settlement price used for margin calculations (may differ from the last trade price; often calculated by the exchange using a methodology involving trades in the final minutes).

EOD data providers: Bloomberg, Refinitiv, FactSet, S&P Capital IQ, Quandl (Nasdaq), Yahoo Finance (limited), exchange direct (via FTP or API).

### Intraday History

Intraday historical data provides sub-daily granularity:

- **Tick-level**: Every trade and quote change, timestamped to nanosecond precision.
- **Bar-level**: Pre-aggregated OHLCV bars at standard intervals (1m, 5m, 15m, 1h).
- **Depth-of-book snapshots**: Periodic snapshots of the full order book at regular intervals (e.g., every second or every 100ms).

Intraday history is essential for:
- Backtesting intraday trading strategies.
- Transaction cost analysis (TCA).
- Regulatory surveillance and reconstruction.
- Model training for machine learning strategies.

### Replay Capabilities

Market data replay reconstructs the exact sequence of market events as they occurred:

- **Full-fidelity replay**: Replays raw exchange messages at their original timestamps. Used for strategy backtesting with realistic fill simulation.
- **Time-scaled replay**: Replay at faster or slower than real time. Useful for development and debugging.
- **Filtered replay**: Replay only specific instruments or message types. Reduces data volume for focused analysis.
- **Multi-venue synchronized replay**: Replay data from multiple exchanges simultaneously, maintaining correct temporal ordering across venues. Essential for strategies that trade across venues.

Implementation considerations:

- **Timestamp precision**: Replay timestamps should preserve the original exchange timestamps (nanosecond precision) separately from the receipt timestamps (when the firm's feed handler received the message) and the replay timestamp.
- **Gap handling**: Replay systems must handle and flag gaps in the original data.
- **Message rate smoothing**: During replay, burst periods may produce message rates that overwhelm consumers if replayed at full speed. Rate governors may be needed.

### Backtesting Data Requirements

Realistic backtesting requires:

- **Survivorship-bias-free universes**: Include delisted, merged, and bankrupt instruments. Point-in-time constituent lists for indices.
- **Point-in-time data**: Corporate action adjustments must be applied as they were known at the time, not retroactively. Split-adjusted vs unadjusted prices.
- **Accurate trade conditions**: Filter trades by condition code (regular vs off-exchange, block, etc.) as appropriate for the strategy.
- **Bid-ask spread data**: For realistic fill simulation, trade prices alone are insufficient; bid-ask data is needed to model slippage.
- **Depth-of-book data**: For market-impact-aware backtesting of strategies that trade significant volume relative to displayed liquidity.

### Major Historical Data Providers

| Provider | Coverage |
|----------|----------|
| **Bloomberg** | Comprehensive global coverage, tick + bar + EOD, via Terminal or B-PIPE historical |
| **Refinitiv Tick History (RTH)** | One of the deepest tick-level archives, covering global equities, derivatives, FX. Petabytes of data going back to 1996+ |
| **Kibot** | US equities and futures, intraday and daily, lower cost |
| **Polygon.io** | US equities, options, FX, crypto. REST and WebSocket APIs. Tick-level and aggregated. |
| **Databento** | Normalized historical and real-time market data, high performance, modern API |
| **Algoseek** | US equities and options, TAQ-equivalent data |
| **TickData (NovusNorth)** | Clean, corporate-action-adjusted tick data, global coverage |
| **Quandl (Nasdaq Data Link)** | EOD and alternative data, wide variety of datasets |
| **FirstRate Data** | US equities and ETFs, intraday |

---

## Market Data Entitlements and Licensing

### Exchange Data Licensing

Exchanges are significant revenue generators from market data licensing. Each exchange has its own fee schedule and usage policies. Firms must execute data agreements with each exchange whose data they consume.

#### Fee Structures

| Fee Type | Description |
|----------|-------------|
| **Access fee** | Monthly fee for the right to connect to and receive the feed. Applies per connection or per data center. |
| **Per-user fee (professional)** | Monthly fee per individual who can view real-time data. Ranges from $5-$150+/user/month depending on the exchange and data level. |
| **Per-user fee (non-professional)** | Reduced rate for individual retail investors. Typically $1-$20/month. Strict criteria define non-professional status. |
| **Enterprise license** | Flat fee for unlimited professional users within a legal entity. Expensive (tens of thousands to millions per year per exchange) but economical at scale. |
| **Non-display fee** | Fee for using data in automated/programmatic applications (algo trading, risk engines, pricing models) where no human views the data directly. Often usage-based or per-platform. |
| **Derived data fee** | Fee for creating and distributing data that is derived from exchange data (indices, analytics, VWAP benchmarks). Policies vary significantly by exchange. |
| **Redistribution fee** | Fee for distributing exchange data to third parties (data vendors, clients). Requires explicit redistribution agreements. |
| **Device fee** | Some exchanges charge per device (terminal, screen, application instance) rather than per user. |

#### Display vs Non-Display Usage

The distinction between display and non-display usage is critical for licensing:

- **Display usage**: A human views real-time market data on a screen. Subject to per-user or enterprise display fees.
- **Non-display usage**: Data is consumed by an automated process (trading algorithm, risk engine, smart order router, pricing model, surveillance system) without direct human viewing. Subject to non-display use fees, which can be significantly higher than display fees. Categories often include:
  - **Trading**: Automated and semi-automated order generation.
  - **Valuation/risk**: Portfolio valuation, risk calculations, margin.
  - **Surveillance**: Market abuse monitoring, compliance.

Major exchanges (NYSE, NASDAQ, CME, OPRA) have detailed non-display use policies with fee schedules that distinguish between these categories.

### Entitlement Management

A professional trading desk requires a robust entitlement management system:

- **User-level permissions**: Which users can see which exchanges' data, at which level (L1, L2, delayed, real-time).
- **Application-level permissions**: Which applications can consume which data feeds.
- **Audit trail**: Complete record of who accessed what data and when, for exchange audit compliance.
- **Vendor-of-record reporting**: Monthly reporting to exchanges of user counts, device counts, and usage categories.
- **Delayed data**: Exchanges typically allow free or low-cost distribution of data delayed by 15-20 minutes. Entitlement systems must enforce the delay.
- **Controlled distribution**: Ensuring data does not leak beyond entitled users/applications (e.g., via screen sharing, email, or data export).

Exchange audits are a real operational risk. Exchanges (particularly NYSE, NASDAQ, and CME) conduct periodic audits of data subscribers to verify compliance with licensing terms. Under-reporting user counts or misclassifying non-display usage can result in significant back-billing and penalties.

### Regulatory Considerations

- **Reg NMS (US)**: Requires that brokers protect the NBBO and route orders to venues displaying the best price. This creates a de facto mandate to consume real-time data from all NMS exchanges.
- **MiFID II/MiFIR (EU)**: Requires best execution, consolidated reporting, and transparent pre/post-trade data publication. Exchange data must be available on a "reasonable commercial basis" (RCB).
- **Market data revenue regulation**: The SEC has been examining exchange market data pricing and has proposed reforms to increase competition and reduce costs. The competing consolidator model is part of this effort.
