# Dashboard and Analytics

Comprehensive reference for dashboards, analytics, reporting, data visualization, custom scripting, and compliance views found on professional trading desks.

## Contents

1. [Real-Time Dashboards](01_Real-Time-Dashboards.md) — Live P&L, risk metrics, execution quality monitoring, and market overview dashboards
   - `PnLDashboard`, `RiskDashboard`, `VaR`, `CVaR`, `ExecutionDashboard`, `VWAPSlippage`, `ScenarioAnalysis`, `GreeksSurface`, `RiskLimitMonitor`

2. [Portfolio Analytics](02_Portfolio-Analytics.md) — Portfolio composition, sector and geographic allocation, factor exposure, and risk decomposition
   - `HoldingsTable`, `SectorAllocation`, `GeographicExposure`, `FactorExposure`, `MarginalContributionToVaR`, `ActiveWeight`, `CurrencyExposure`

3. [Performance Attribution](03_Performance-Attribution.md) — Brinson-Fachler return attribution, factor attribution, and transaction cost analysis
   - `BrinsonAttribution`, `AllocationEffect()`, `SelectionEffect()`, `InteractionEffect()`, `FactorAttribution`, `ImplementationShortfall`, `TCABenchmark`

4. [Reporting](04_Reporting.md) — End-of-day reports, trade confirmations, regulatory filings, and client-facing reports
   - `DailyPnLReport`, `TradeConfirmation`, `RegulatoryReport`, `Form13F`, `CATReport`, `MiFIDTransactionReport`, `ClientFactsheet`, `CapitalAccountStatement`

5. [Data Visualization](05_Data-Visualization.md) — Heat maps, treemaps, scatter plots, correlation matrices, yield curves, and volatility surfaces
   - `PositionHeatMap`, `CorrelationMatrix`, `Treemap`, `ScatterPlot`, `YieldCurve`, `ForwardCurve`, `VolatilitySurface`, `VolSmileSkew`, `DendrogramCluster`

6. [Custom Analytics and Scripting](06_Custom-Analytics-And-Scripting.md) — User-defined formula columns, custom chart indicators, screening/scanning, and backtesting
   - `FormulaColumn`, `CustomIndicator`, `Scanner`, `BacktestFramework`, `EquityCurve`, `SharpeRatio`, `ProfitFactor`, `AlertIntegration`

7. [Audit and Compliance Views](07_Audit-And-Compliance-Views.md) — Trade surveillance, pattern detection, communication monitoring, and regulatory compliance dashboards
   - `SurveillanceDashboard`, `SpoofingDetection`, `WashTradeDetection`, `FrontRunningAlert`, `CommunicationMonitor`, `RestrictedList`, `WatchList`, `ComplianceCase`

8. [Dashboard Design Principles](08_Dashboard-Design-Principles.md) — Layout hierarchy, refresh/latency targets, interactivity standards, and data quality indicators
   - `LayoutHierarchy`, `RefreshRate`, `CrossFiltering`, `DrillDown`, `StaleDataWarning`, `ReconciliationStatus`, `ExportCapability`
