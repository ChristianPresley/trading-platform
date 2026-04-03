# Position Management

Comprehensive reference for position management as implemented in professional trading desk applications. Covers real-time tracking, aggregation, multi-currency handling, reconciliation, corporate actions, cost basis, and limit monitoring.

## Contents

1. [Real-Time Position Tracking](01_Real-Time-Position-Tracking.md) — Core position records, intraday/realized/unrealized P&L, mark-to-market, P&L attribution, and hierarchical position views
   - `PositionKey`, `IntradayPnL`, `RealizedPnL`, `UnrealizedPnL`, `TotalPnL`, `Notional`, `AverageCost`, `MarketPrice`, `ContractMultiplier`

2. [Multi-Currency Positions](02_Multi-Currency-Positions.md) — Base currency conversion, FX exposure calculation, cross-currency P&L decomposition, multi-currency cash balances, buying power, and margin requirements
   - `FxExposure()`, `PositionValue_Base`, `LocalPnL`, `FxPnL`, `BuyingPower`, `MarginExcess`, `SPANMargin`

3. [Position Reconciliation](03_Position-Reconciliation.md) — Trade date vs. settlement date positions, street-side vs. house-side reconciliation, break categories, matching workflows, and tolerances
   - `ReconciliationWorkflow`, `BreakDetection`, `NormalizeInstrumentId()`, `MatchByPositionKey()`, `BreakCategory`, `ReconciliationTolerance`

4. [Corporate Actions Impact on Positions](04_Corporate-Actions-Impact-On-Positions.md) — Stock splits, dividends, mergers, spin-offs, tender offers, rights issues, and derivative adjustments from corporate events
   - `SplitRatio`, `CashDividend`, `StockDividend`, `MergerPrice`, `ExchangeRatio`, `SpinOffAllocation`, `TenderOffer`, `RightsIssue`

5. [Average Cost and Tax Lot Tracking](05_Average-Cost-And-Tax-Lot-Tracking.md) — Tax lot management, FIFO/LIFO/specific lot/average cost methods, wash sale rules, and multi-currency tax lots
   - `TaxLot`, `FIFO`, `LIFO`, `SpecificLotIdentification`, `AverageCost`, `WashSaleAdjustment`, `CostBasis`, `FxRateAtPurchase`

6. [Position Limits and Monitoring](06_Position-Limits-And-Monitoring.md) — Multi-layer limit types, limit metrics, monitoring architecture, utilization thresholds, hard vs. soft limits, regulatory position limits, and concentration risk
   - `PositionLimit`, `LimitUtilization`, `PreTradeLimitCheck`, `HHI`, `ConcentrationLimit`, `RegulatoryLimit`, `StopLoss`

7. [SOD Positions and Data Model](07_SOD-Positions-And-Data-Model.md) — Start-of-day position build process, SOD attributes, position break detection and aging, and the core data model for positions, tax lots, and limits
   - `SODPosition`, `SODQuantity`, `SODAverageCost`, `BreakDetection`, `BreakEscalation`, `Position`, `TaxLot`, `CorporateActionAdjustment`, `PositionLimit`
