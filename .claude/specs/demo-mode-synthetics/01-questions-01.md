---
phase: 1
iteration: 01
generated: 2026-04-04
---

# Research Questions: Complete and Extensive Synthetics for Demo Mode

Source issue: User request — "complete and extensive synthetics for demo mode"
Feature slug: demo-mode-synthetics

## Questions

1. How does the current `trading/desk/synthetic.zig` generate market data today — what instruments does it cover, what price dynamics does it model (random walk parameters, tick frequency, spread behavior), and how does it produce L2 orderbook snapshots and incremental updates?

2. How does `trading/desk/engine.zig` consume synthetic data and route it to the TUI — what are the stub functions (`riskValidateStub`, `storeAppendStub`), how does it integrate with the OMS (`sdk/domain/oms.zig`), and what code paths are skipped or stubbed in demo mode vs. what a live mode would need?

3. What is the full set of message types in `trading/desk/messages.zig` (EngineEvent variants, UserCommand variants), and which of those message types currently receive synthetic data vs. which are only populated with placeholder/zero values?

4. What instruments are defined in `sdk/domain/market_data.zig` (spot pairs, futures contracts), and how do the symbol translation tables in `exchanges/kraken/common/symbol_translator.zig` map between exchange-native and canonical names — what is the full list of tradeable symbols the platform knows about?

5. How does the Order Management System (`sdk/domain/oms.zig`) handle order lifecycle transitions — what are all the `OrdStatus` and `ExecType` states, how does `OrderStateMachine` enforce valid transitions, and how do the exchange executors (`exchanges/kraken/spot/executor.zig`, `futures/executor.zig`) produce fill and reject events including the mock response injection path?

6. How does the position tracking system (`sdk/domain/positions.zig`) compute position state from fills — what fields does a `Position` carry, how do the cost basis methods (FIFO, LIFO, average_cost) work, and what does a `Fill` event look like that drives position updates?

7. What data do the execution algorithms in `sdk/domain/algos/` (TWAP, VWAP, Iceberg, POV, Implementation Shortfall, Sniper) require as inputs, and what events or state do they produce — are there any existing test harnesses or fixtures that feed them synthetic market conditions?

8. How do the pre-trade risk checks (`sdk/domain/risk/pre_trade.zig`) validate orders — what is the full `RiskConfig` structure, what are all the check types (size, notional, position, rate, price band, dedup), and how does the function-pointer integration with `OrderManager` work?

9. How does the tick store (`sdk/domain/tick_store.zig`) persist and query tick data — what is the `Tick` struct layout, how does date-partitioned file naming work, and how does the bar aggregator (`sdk/domain/bar_aggregator.zig`) consume ticks to produce OHLCV candles?

10. What do the post-trade modules (`sdk/domain/post_trade/eod.zig`, `reconciliation.zig`, `allocation.zig`) expect as inputs — what data structures do they operate on, and what reporting or settlement outputs do they produce?

11. How do the trading strategies (`trading/strategies/` — basis, funding arb, market making, pairs trade) consume market data and emit order signals — what interfaces do they expect, and what market conditions (spreads, funding rates, correlation) do they need to function meaningfully?

12. What do the analytics modules (`trading/analytics/` — TCA, attribution, VPIN) require as historical input data, and what are their output structures — how much historical depth (number of ticks, candles, or trades) do they need to produce meaningful results?
