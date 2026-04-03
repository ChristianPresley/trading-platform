# FX and Commodities Trading

Comprehensive reference for foreign exchange and commodities asset-class features on a professional trading desk. Covers spot, forwards, swaps, options, market structure, and commodity-specific considerations.

## Contents

1. [FX Spot, Forwards, and Swaps](01_FX-Spot-Forwards-And-Swaps.md) — Spot FX trading mechanics, currency pair classification, settlement via CLS, forward rate calculation, NDFs, FX swaps, and cross-currency basis swaps
   - `ForwardRate()`, `NDFSettlement()`, `CurrencyPair`, `SwapPoints`, `CrossCurrencyBasis`, `TomNextRoll()`

2. [FX Options and Market Structure](02_FX-Options-And-Market-Structure.md) — Vanilla and barrier FX options, digital/binary options, accumulators, ECN/SDP market structure, last-look mechanics, and price aggregation
   - `BarrierOption`, `KnockInKnockOut`, `DigitalOption`, `RiskReversal`, `Butterfly`, `VolSurface`, `PriceAggregator`

3. [FX Prime Brokerage, Fixing, and Algo Execution](03_FX-Prime-Brokerage-Fixing-And-Algo-Execution.md) — FXPB give-up mechanics, credit intermediation, WM/Reuters and Tokyo fixing rates, and FX algo strategies (TWAP, VWAP, IS, pegged, fixing-targeted)
   - `GiveUp()`, `FixingRate`, `TWAP`, `VWAP`, `ImplementationShortfall`, `AlgoTCA`, `SpreadCapture`

4. [Energy and Metals Trading](04_Energy-And-Metals-Trading.md) — Crude oil (WTI/Brent), natural gas, power/electricity, emissions trading, precious metals (gold/silver), and base metals on the LME
   - `CrackSpread`, `SparkSpread`, `ContangoBackwardation`, `LBMAGoldPrice`, `LMEPromptDate`, `CheapestToDeliver`

5. [Agricultural Commodities, Futures, and Physical Trading](05_Agricultural-Commodities-Futures-And-Physical-Trading.md) — Grains, softs, livestock futures, commodity options (Asian, spread), swaps (fixed-for-floating, basis), and physical vs financial trading convergence
   - `CommoditySwap`, `AsianOption`, `SpreadOption`, `ExchangeForPhysical()`, `PositionLimit`, `BasisRisk`

6. [Commodity Risk and Data Requirements](06_Commodity-Risk-And-Data-Requirements.md) — Storage and carry cost modeling, delivery logistics, weather risk, seasonality, geopolitical/regulatory risk, and key data feeds for an FX/commodities platform
   - `CostOfCarry()`, `ConvenienceYield`, `WeatherDerivative`, `SeasonalSpread`, `Incoterms`, `CalendarSpread`
