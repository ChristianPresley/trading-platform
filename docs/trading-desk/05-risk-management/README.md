# Risk Management

Comprehensive reference for risk management as implemented in professional trading desk applications. Covers market risk, credit risk, liquidity risk, operational risk, pre-trade controls, real-time Greeks, risk limits, stress testing, regulatory requirements, and risk attribution.

## Contents

1. [Market Risk](01_Market-Risk.md) — Value at Risk (historical, parametric, Monte Carlo), Expected Shortfall, stress testing fundamentals, and confidence level / time horizon conventions
   - `HistoricalVaR()`, `ParametricVaR()`, `MonteCarloVaR()`, `ExpectedShortfall()`, `CovarianceMatrix`, `CholeskyDecomposition`, `sigma_portfolio`

2. [Credit Risk](02_Credit-Risk.md) — Counterparty exposure (current, potential future, expected positive), credit limits, CVA/DVA pricing, ISDA netting agreements, and CSA collateral management
   - `CurrentExposure`, `PotentialFutureExposure()`, `ExpectedPositiveExposure`, `CVA`, `DVA`, `NettingBenefit`, `CreditLimit`, `CollateralHaircut`

3. [Liquidity and Operational Risk](03_Liquidity-And-Operational-Risk.md) — Bid-ask spread cost, market depth/impact models, liquidation horizon, liquidity-adjusted VaR, concentration risk metrics, and operational risk controls for trade errors and fat-finger prevention
   - `SpreadCost`, `MarketImpact()`, `LiquidationHorizon`, `LiquidityAdjustedVaR`, `LCR`, `NSFR`, `FatFingerCheck`, `DuplicateDetection`

4. [Pre-Trade Risk Controls](04_Pre-Trade-Risk-Controls.md) — Synchronous order validation pipeline: price reasonability, size limits, position limits, credit/margin checks, concentration checks, message rate throttling, and duplicate detection
   - `OrderValidation`, `PriceReasonabilityCheck()`, `PositionLimitCheck()`, `NotionalLimit`, `MessageRateThrottle`, `DuplicateCheck`, `OrderToTradeRatio`

5. [Real-Time Risk Calculations: Options Greeks](05_Real-Time-Risk-Calculations-Options-Greeks.md) — Black-Scholes Greeks (delta, gamma, vega, theta, rho), portfolio-level aggregation, dollar gamma, gamma P&L, and vega surface matrices
   - `Delta`, `Gamma`, `Vega`, `Theta`, `Rho`, `PortfolioDelta`, `DollarGamma`, `GammaPnL`, `VegaMatrix`

6. [Real-Time Risk Calculations: Fixed Income and Architecture](06_Real-Time-Risk-Calculations-Fixed-Income-And-Architecture.md) — DV01/PV01, key rate DV01s, credit spread duration (CS01), convexity, beta exposure, and the real-time risk calculation architecture with latency targets
   - `DV01`, `PV01`, `KeyRateDV01`, `CS01`, `SpreadDuration`, `Convexity`, `PortfolioBeta`, `RiskAggregationEngine`

7. [Risk Limits and Breaches](07_Risk-Limits-And-Breaches.md) — Limit hierarchy (board to trader), hard vs. soft limits, utilization monitoring, breach classification (active/passive/technical), escalation workflows, stop-loss limits, and limit dashboards
   - `LimitHierarchy`, `LimitUtilization`, `BreachEscalation`, `ActiveBreach`, `PassiveBreach`, `StopLossLimit`, `LimitDashboard`

8. [Stress Testing and Scenario Analysis](08_Stress-Testing-And-Scenario-Analysis.md) — Historical and hypothetical stress scenarios, reverse stress testing, sensitivity analysis (bump-and-reprice), and stress testing governance
   - `HistoricalScenario`, `HypotheticalScenario`, `ReverseStressTest()`, `BumpAndReprice()`, `SensitivityGrid`, `StressLossLimit`

9. [Regulatory Risk Requirements](09_Regulatory-Risk-Requirements.md) — Basel III/IV capital framework, FRTB standardized and internal models approaches, P&L attribution test, ISDA SIMM for non-cleared derivative initial margin, and risk-weighted assets
   - `CET1`, `RiskWeightedAssets`, `FRTB_SA`, `FRTB_IMA`, `ExpectedShortfall`, `DefaultRiskCharge`, `PLAttributionTest`, `ISDA_SIMM`

10. [Risk Attribution and Factor Models](10_Risk-Attribution-Factor-Models.md) — Factor-based risk decomposition (Barra/MSCI style factors, fixed income factors), sector/country/style risk attribution, and systematic vs. idiosyncratic risk
    - `FactorModel`, `FactorExposure`, `FactorCovariance`, `IdiosyncraticRisk`, `SectorDecomposition`, `CountryDecomposition`, `StyleDecomposition`

11. [Risk Attribution: Marginal and Component](11_Risk-Attribution-Marginal-And-Component.md) — Marginal VaR, component VaR, incremental VaR, risk attribution over time (day-over-day VaR change), and the risk reporting hierarchy
    - `MarginalVaR`, `ComponentVaR`, `IncrementalVaR`, `VaRChangeAttribution`, `RiskReportingHierarchy`

12. [Appendices](12_Appendices.md) — VaR backtesting methodology (Kupiec POF test, Christoffersen independence test, Basel traffic light system) and key formulas reference
    - `Backtest`, `KupiecPOF`, `ChristoffersenIndependence`, `BaselTrafficLight`, `FormulaReference`
