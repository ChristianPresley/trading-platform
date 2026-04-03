# Futures and Listed Derivatives

Professional trading desk reference covering futures trading, market structure, roll management, spreads, clearing, margining, settlement, ETFs/ETNs, structured products, cryptocurrency derivatives, cross-margining, and basis trading.

## Contents

1. [Futures Trading and Market Structure](01_Futures-Trading-And-Market-Structure.md) — Contract specifications, tick value and P&L calculation, margin requirements, daily mark-to-market settlement, and exchange structure (CME Group, ICE, Eurex, SGX)
   - `ContractSpec`, `TickValue()`, `InitialMargin`, `MaintenanceMargin`, `MarkToMarket()`, `SettlementPrice`, `ImpliedOrder`

2. [Futures Roll Management and Spreads](02_Futures-Roll-Management-And-Spreads.md) — Roll scheduling, volume/OI crossover detection, continuous contract construction (back-adjusted, ratio-adjusted), roll yield, and inter-commodity spreads (crack, crush, spark, NOB)
   - `CalendarSpread`, `RollYield()`, `ContinuousContract`, `CrackSpread`, `CrushSpread`, `SparkSpread`, `FlySpread`

3. [Clearing, Margining, and Settlement](03_Clearing-Margining-And-Settlement.md) — CCP clearing mechanics, SPAN/PRISMA/PAIRS margin models, variation margin, default waterfall, physical delivery process, cash settlement, and cheapest-to-deliver bond logic
   - `CentralCounterparty`, `SPANMargin()`, `VariationMargin`, `DefaultWaterfall`, `PhysicalDelivery`, `CashSettlement`, `CheapestToDeliver()`

4. [ETFs, ETNs, and Structured Products](04_ETFs-ETNs-And-Structured-Products.md) — ETF creation/redemption and NAV tracking, ETN credit risk, warrants, structured certificates (bonus, discount, express), turbo knock-out warrants, and CFDs
   - `CreationRedemption()`, `AuthorizedParticipant`, `IndicativeNAV`, `TurboWarrant`, `StructuredCertificate`, `CFD`, `KnockOutBarrier`

5. [Cryptocurrency Derivatives](05_Cryptocurrency-Derivatives.md) — CME Bitcoin/Ether futures and options, perpetual swap funding rate mechanism, liquidation engine, mark price, and Deribit options ecosystem
   - `PerpetualSwap`, `FundingRate()`, `LiquidationEngine`, `MarkPrice`, `BitcoinFutures`, `MicroContract`, `InsuranceFund`

6. [Cross-Margining and Basis Trading](06_Cross-Margining-And-Basis-Trading.md) — CME-OCC and CME-LCH cross-margin programs, Eurex PRISMA, futures basis and fair value calculation, cash-and-carry arbitrage, index arbitrage, and bond basis trading
   - `CrossMargin`, `BasisTrade`, `FairValue()`, `CashAndCarryArbitrage()`, `IndexArbitrage`, `BondBasis`, `ConversionFactor`
