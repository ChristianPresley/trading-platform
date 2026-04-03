# Equities Trading

Comprehensive reference for equity asset-class features on a professional trading desk. Covers cash equities, derivatives overlays, market structure, and operational workflows relevant to building a trading platform.

## Contents

1. [Cash Equities Trading](01_Cash-Equities-Trading.md) — Instrument types (stocks, ETFs, ADRs, REITs), order type taxonomy, and execution semantics for a professional equity OMS
   - `MarketOrder`, `LimitOrder`, `PeggedOrder`, `ReserveOrder`, `IOC`, `FOK`, `MOC`, `LOC`, `ETFCreationRedemption`, `ADRArbitrage`

2. [Equity Market Structure](02_Equity-Market-Structure.md) — Reg NMS rules, exchange/ECN/dark-pool venues, auction mechanisms (open, close, IPO/halt), and OTC wholesale market making
   - `OrderProtectionRule`, `DarkPool`, `MidpointMatch`, `OpeningAuction`, `ClosingAuction`, `VolatilityAuction`, `NBBO`, `ATSFormN`

3. [IPO Offerings and Short Selling](03_IPO-Offerings-And-Short-Selling.md) — IPO book-building and allocation workflows, secondary offerings, short-locate/borrow mechanics, Reg SHO compliance, and recall risk
   - `IPOAllocation`, `LocateRequest`, `BorrowRate`, `HardToBorrowList`, `ShortInterestRatio`, `RegSHOCircuitBreaker`, `BuyInProcess`

4. [Index Trading, Blocks, and Swaps](04_Index-Trading-Blocks-And-Swaps.md) — Index futures basis/roll, ETF-futures arbitrage, block trading protocols, and equity swap structures (TRS, CFD, portfolio swaps)
   - `IndexFuture`, `FairValueCalc`, `RollSpread`, `IndexArbitrage`, `BlockTrade`, `TotalReturnSwap`, `CFD`, `PortfolioSwap`

5. [Program Trading and Market Making](05_Program-Trading-And-Market-Making.md) — Basket execution and transition management, portfolio rebalancing optimization, and market-maker quoting obligations and inventory management
   - `ProgramTrade`, `BasketExecution`, `RebalanceOptimizer`, `TransitionManager`, `DesignatedMarketMaker`, `InventorySkew`, `AdverseSelection`

6. [Trading Considerations and Data Requirements](06_Trading-Considerations-And-Data-Requirements.md) — Small-cap vs large-cap execution strategies, extended-hours session handling, and key data feeds for an equities platform
   - `SmallCapExecutionStrategy`, `ExtendedHoursSession`, `PreMarketOrder`, `GapRisk`, `MarketDataFeed`, `CorporateActionFeed`, `ShortLocateFeed`
