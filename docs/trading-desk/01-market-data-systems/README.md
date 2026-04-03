# Market Data Systems

Market data systems form the nervous system of any professional trading desk. Responsible for the ingestion, normalization, distribution, storage, and entitlement management of financial instrument pricing information across all asset classes.

## Contents

1. [Overview and Real-Time Market Data Feeds](01_Overview-And-Real-Time-Market-Data-Feeds.md) — Core responsibilities of market data systems and Level 1/2/3 feed structures including top-of-book, depth-of-book, and order-level data
   - `BBO`, `NBBO`, `MarketByPrice`, `MarketByOrder`, `QuoteConditionCode`, `ImpliedBook`

2. [Market Data Sources and Exchanges](02_Market-Data-Sources-And-Exchanges.md) — Global exchange landscape (equities, derivatives), consolidated vs. direct feeds, and third-party vendor integrations
   - `SIP`, `CTA`, `UTP`, `DirectFeed`, `ConsolidatedTape`, `ExchangeFeedSubscription`

3. [Data Normalization and Market Data Protocols](03_Data-Normalization-And-Market-Data-Protocols.md) — Symbology mapping (ISIN, CUSIP, SEDOL, FIGI), price/quantity normalization, and binary protocols (ITCH, PITCH, SBE, FAST)
   - `SymbologyMap`, `PriceScaling`, `TimestampNormalize()`, `ITCH`, `OUCH`, `PITCH`, `SBE`, `FAST`, `FIXMessage`

4. [Tick Data Storage and Conflation](04_Tick-Data-Storage-And-Conflation.md) — Tick-level storage architectures, time-series databases, bar aggregation (OHLCV), VWAP calculation, and conflation strategies
   - `TickStore`, `OHLCV`, `VWAP`, `Conflation`, `BarAggregation`, `PartitionByDate`, `RDB`, `Tickerplant`

5. [Reference Data and Static Data](05_Reference-Data-And-Static-Data.md) — Instrument master (security master), corporate actions handling, holiday calendars, trading hours, tick size tables, and lot sizes
   - `InstrumentMaster`, `CorporateAction`, `HolidayCalendar`, `TradingHours`, `TickSizeTable`, `LotSize`

6. [Historical Market Data and Entitlements](06_Historical-Market-Data-And-Entitlements.md) — EOD data, intraday history, replay capabilities, backtesting data requirements, and exchange data licensing and entitlement management
   - `EODData`, `ReplayEngine`, `BacktestUniverse`, `EntitlementManager`, `DisplayUsage`, `NonDisplayUsage`, `VendorOfRecordReport`

7. [Market Data Infrastructure](07_Market-Data-Infrastructure.md) — Feed handler architecture (software, FPGA), ticker plants, pub/sub distribution, network topology, and latency measurement
   - `FeedHandler`, `TickerPlant`, `PubSub`, `TopicHierarchy`, `LatencyMeasurement`, `KernelBypass`, `HardwareTimestamp`

8. [Alternative Data and Appendices](08_Alternative-Data-And-Appendices.md) — News feeds, social sentiment, economic indicators, weather data, satellite imagery, and key metrics/benchmarks/glossary
   - `MachineReadableNews`, `SentimentScore`, `EconomicIndicator`, `AlternativeDataPipeline`, `PointInTimeIntegrity`
