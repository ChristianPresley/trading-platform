# Options Trading

Professional trading desk reference covering options order types, strategies, pricing models, Greeks calculation, volatility surfaces, exercise/assignment, market making, listed vs OTC options, exotics, strategy builders, and portfolio margining.

## Contents

1. [Options Order Types and Chain Display](01_Options-Order-Types-And-Chain-Display.md) — Single-leg and multi-leg order types, vertical/horizontal/diagonal spreads, iron condors, butterflies, ratio spreads, collars, and professional options chain display
   - `IronCondor`, `BullCallSpread`, `CalendarSpread`, `RatioBackspread`, `Collar`, `StrikeLadder`, `ExpirationGrid`

2. [Options Pricing Models](02_Options-Pricing-Models.md) — Black-Scholes-Merton, binomial/trinomial trees, Monte Carlo simulation with variance reduction, Dupire local volatility, Heston stochastic volatility, and SABR model
   - `BlackScholes()`, `BinomialTree`, `MonteCarloSimulation()`, `LocalVolatility()`, `HestonModel`, `SABRModel`, `QuasiRandomSequence`

3. [Greeks Calculation and Display](03_Greeks-Calculation-And-Display.md) — First-order Greeks (delta, gamma, theta, vega, rho), second-order Greeks (charm, vanna, volga, speed, color), and professional multi-level Greeks display
   - `Delta`, `Gamma`, `Theta`, `Vega`, `Rho`, `Charm`, `Vanna`, `Volga`, `DollarGamma()`, `ScenarioGreeks`

4. [Volatility Surfaces and Exercise/Assignment](04_Volatility-Surfaces-And-Exercise-Assignment.md) — IV surface construction, SVI/SSVI parameterization, skew and term structure, arbitrage constraints, American/European/Bermudan exercise, auto-exercise, and pin risk
   - `VolSurface`, `SVIFit()`, `ImpliedVolInversion()`, `ArbitrageConstraint`, `AutoExercise`, `PinRisk`, `EarlyExercise()`

5. [Options Market Making and Listed vs OTC](05_Options-Market-Making-And-Listed-Vs-OTC.md) — Delta hedging, gamma scalping, volatility and skew trading, dispersion trades, listed exchange routing, SPX/VIX specifics, and ISDA/CSA OTC documentation
   - `DeltaHedge()`, `GammaScalp()`, `VarianceSwap`, `DispersionTrade`, `ComplexOrderBook`, `ISDAMasterAgreement`, `CreditSupportAnnex`

6. [Exotic Options](06_Exotic-Options.md) — Path-independent exotics (digitals, compound, chooser), path-dependent exotics (Asian, lookback, barrier, quanto, rainbow, basket options), and hedging approaches
   - `AsianOption`, `LookbackOption`, `BarrierOption`, `QuantoAdjustment()`, `RainbowOption`, `BasketOption`, `CompoundOption`

7. [Strategy Builders and Portfolio Margining](07_Strategy-Builders-And-Portfolio-Margining.md) — Visual strategy construction, payoff diagrams, probability/scenario analysis, SPAN margining, OCC portfolio margin, Reg-T vs portfolio margin comparison, and cross-margining
   - `PayoffDiagram`, `ProbabilityOfProfit()`, `ScenarioGrid`, `SPANMargin()`, `PortfolioMargin`, `CrossMargin`, `MarginCall`
