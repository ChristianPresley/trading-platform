# Trade Execution and Algorithmic Trading

Covers execution algorithms, smart order routing, direct market access, dark pools, execution quality measurement, and related topics as implemented in professional trading desk applications.

## Contents

1. [Execution Algorithms (Part 1)](01_Execution-Algorithms-Part-1.md) — VWAP, TWAP, POV/participation rate, and implementation shortfall (arrival price) algorithms with volume profile construction and cost model optimization
   - `VWAPAlgo`, `TWAPAlgo`, `POVAlgo`, `ImplementationShortfall`, `VolumeProfile`, `SliceScheduler`, `AdaptiveVWAP`

2. [Execution Algorithms (Part 2)](02_Execution-Algorithms-Part-2.md) — MOC/close algorithms, iceberg/reserve management, sniper/liquidity-seeking, dark pool algorithms, and pairs trading execution
   - `CloseAlgo`, `IcebergAlgo`, `SniperAlgo`, `DarkPoolAlgo`, `PairsTradingAlgo`, `LiquidityDetection`, `DarkPoolPing`

3. [Algorithm Parameters and Customization](03_Algorithm-Parameters-And-Customization.md) — Universal parameters, urgency levels, price limit/peg configuration, venue controls, sizing controls, and FIXatdl strategy parameter encoding
   - `Urgency`, `LimitPrice`, `WouldPrice`, `PegType`, `DarkPoolInclusion`, `SliceSize`, `FIXatdl`, `StrategyParameterGrp`

4. [Smart Order Routing](04_Smart-Order-Routing.md) — Venue landscape analysis, fill probability models, maker-taker/inverted fee optimization, routing table configuration, order type compatibility matrix, and SOR decision flow
   - `SmartOrderRouter`, `RoutingTable`, `FeeOptimizer`, `FillProbabilityModel`, `VenueCapabilityMatrix`, `SweepMode`

5. [Direct Market Access](05_Direct-Market-Access.md) — Sponsored access, co-location, proximity hosting, DMA risk controls (SEC 15c3-5), and latency budget breakdown for co-located order flow
   - `SponsoredAccess`, `CoLocation`, `DMAGateway`, `RiskGateway`, `KillSwitch`, `PriceCollar`, `RateLimit`

6. [Dark Pools and Alternative Trading Systems](06_Dark-Pools-And-Alternative-Trading-Systems.md) — Dark pool types (exchange, broker, independent), matching mechanisms (midpoint, periodic auction, conditional), IOIs, and Reg ATS/MiFID II dark pool regulation
   - `DarkPool`, `MidpointMatch`, `PeriodicAuction`, `ConditionalOrder`, `IOI`, `RegATS`, `FormATS_N`, `DoubleVolumeCap`

7. [Execution Quality Measurement](07_Execution-Quality-Measurement.md) — Transaction cost analysis (TCA) with explicit/implicit cost decomposition, benchmarks (arrival, VWAP, close), implementation shortfall framework, and pre/real-time/post-trade TCA reporting
   - `TCA`, `ArrivalSlippage`, `VWAPSlippage`, `SpreadCapture`, `ImplementationShortfallDecomp`, `MarketImpact`, `TimingCost`, `OpportunityCost`

8. [Execution Venue Analysis](08_Execution-Venue-Analysis.md) — Fill rate analysis, adverse selection measurement, information leakage detection, venue toxicity metrics (VPIN), and composite venue scoring models
   - `FillRateAnalysis`, `AdverseSelection`, `InformationLeakage`, `VPIN`, `VenueScore`, `PhantomLiquidity`, `SpreadDecomposition`

9. [High-Frequency Trading Considerations](09_High-Frequency-Trading-Considerations.md) — Tick-to-trade latency breakdown, co-location facilities, FPGA/ASIC hardware acceleration, kernel bypass (OpenOnload, DPDK), and time synchronization (PTP)
   - `TickToTrade`, `FPGA`, `KernelBypass`, `OpenOnload`, `DPDK`, `PTP`, `HardwareTimestamp`, `NICSolarflare`

10. [Market Microstructure](10_Market-Microstructure.md) — Bid-ask spread dynamics, order book event processing (add/modify/cancel/execute), market maker behavior (DMM, electronic), price discovery, and queue priority rules (FIFO, pro-rata)
    - `BidAskSpread`, `OrderBookEvent`, `DesignatedMarketMaker`, `PriceDiscovery`, `QueuePriority`, `BookImbalance`, `DepthAnalysis`

11. [Best Execution Obligations](11_Best-Execution-Obligations.md) — US Reg NMS (Rules 611, 610, 612), FINRA 5310, MiFID II best execution (Article 27), RTS 27/28 reporting, and best execution policy implementation
    - `RegNMS`, `OrderProtectionRule`, `SubPennyRule`, `MiFIDBestExecution`, `RTS28Report`, `Rule606`, `BestExecutionPolicy`

12. [Basket and Portfolio Trading](12_Basket-And-Portfolio-Trading.md) — List/program trading, index rebalancing execution, transition management, basket risk management (net exposure, sector/factor neutrality), and cash management
    - `BasketOrder`, `ProgramTrade`, `IndexRebalance`, `TransitionManager`, `NetExposureMonitor`, `CrossTrade`, `TrackingError`

13. [Appendices](13_Appendices.md) — FIX protocol tags for algorithmic trading, US equity venue MIC code reference, and key academic references (Almgren-Chriss, Kyle, Perold)
    - `StrategyParameterName`, `StrategyParameterValue`, `MICCode`, `AlmgrenChriss`, `VPIN`
