# Momentum and Trend Following

Strategies that exploit the tendency of assets to continue moving in the direction of their recent trend. Momentum is one of the most robust and well-documented anomalies in financial economics, observed across equities, bonds, commodities, currencies, and cryptocurrencies. These strategies range from simple moving average rules to sophisticated factor-model-based approaches, and span from the foundational work of Jegadeesh and Titman (1993) to modern crypto-native seasonal patterns.

## Contents

1. [Price Momentum](01_Price-Momentum.md) — Classic Jegadeesh & Titman cross-sectional momentum: buy past winners, sell past losers over 3-12 month horizons `[Backtested]` `[Whitepaper]` — **Rating: 4/5**
   - `CrossSectionalRanking`, `FormationHoldingPeriods`, `SkipMonthConvention`, `MomentumCrashRisk`

2. [Earnings Momentum](02_Earnings-Momentum.md) — Post-Earnings Announcement Drift (PEAD): trade stocks based on earnings surprise direction `[Backtested]` `[Whitepaper]` — **Rating: 4/5**
   - `EarningsSurprise`, `StandardizedUnexpectedEarnings`, `AnalystConsensus`, `EventDriven`

3. [Time-Series Momentum](03_Time-Series-Momentum.md) — Moskowitz, Ooi & Pedersen (2012): long/short assets based on their own past returns `[Backtested]` `[Whitepaper]` `[Crypto]` — **Rating: 4/5**
   - `AbsoluteMomentum`, `VolatilityScaling`, `FuturesContracts`, `CrisisAlpha`

4. [Asset Class Trend Following](04_Asset-Class-Trend-Following.md) — Apply trend signals (moving average or past return) across equities, bonds, commodities, REITs `[Backtested]` `[Whitepaper]` `[Crypto]` — **Rating: 5/5**
   - `TacticalAssetAllocation`, `MovingAverageFilter`, `DrawdownReduction`, `ETFImplementation`

5. [Sector Momentum Rotation](05_Sector-Momentum-Rotation.md) — Rotate into top-performing sectors, avoid worst performers `[Backtested]` `[Whitepaper]` `[Crypto]` — **Rating: 4/5**
   - `SectorETFs`, `RelativeStrength`, `BusinessCycleRotation`, `IndustryMomentum`

6. [Dual Momentum](06_Dual-Momentum.md) — Gary Antonacci's approach combining absolute + relative momentum for asset selection `[Backtested]` `[Whitepaper]` `[Crypto]` — **Rating: 4/5**
   - `RelativeMomentum`, `AbsoluteMomentum`, `GlobalEquitiesMomentum`, `DownsideProtection`

7. [Residual Momentum](07_Residual-Momentum.md) — Momentum in stock-specific (idiosyncratic) returns after removing factor exposures `[Backtested]` `[Whitepaper]` `[Crypto]` — **Rating: 3/5**
   - `FactorModelRegression`, `IdiosyncraticReturns`, `CrashResilience`, `AlphaOrthogonality`

8. [Consistent Momentum](08_Consistent-Momentum.md) — Select stocks with the most consistent positive returns over the lookback period `[Backtested]` `[Whitepaper]` `[Crypto]` — **Rating: 3/5**
   - `ReturnConsistency`, `PercentPositiveMonths`, `LowVolatilityOverlap`, `QualityFilter`

9. [52-Week High Effect](09_52-Week-High-Effect.md) — Stocks near their 52-week high tend to outperform due to anchoring bias `[Backtested]` `[Whitepaper]` `[Crypto]` — **Rating: 3/5**
   - `AnchoringBias`, `PriceNearness`, `PsychologicalReferencePoint`, `BreakoutEnhancement`

10. [Trend Following with Moving Averages](10_Trend-Following-With-Moving-Averages.md) — Multiple MA crossover systems (single, dual, triple) across all asset classes `[Backtested]` `[Whitepaper]` `[Crypto]` — **Rating: 4/5**
    - `GoldenCross`, `DeathCross`, `SMA`, `EMA`, `WhipsawFiltering`

11. [Overnight Seasonality in Bitcoin](11_Overnight-Seasonality-In-Bitcoin.md) — Exploit intraday return patterns in Bitcoin across geographic trading sessions `[Backtested]` `[Crypto]` — **Rating: 4/5**
    - `IntradaySeasonality`, `GeographicTradingFlows`, `TimeOfDayEffect`, `AutomationRequired`
