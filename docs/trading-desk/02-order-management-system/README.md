# Order Management System (OMS)

Reference documentation covering the design, behavior, and integration concerns of a professional trading desk Order Management System.

## Contents

1. [Order Types](01_Order-Types.md) — Market, limit, stop, trailing stop, iceberg, pegged, and auction order types with time-in-force variants and FIX tag mappings
   - `MarketOrder`, `LimitOrder`, `StopOrder`, `TrailingStop`, `IcebergOrder`, `PeggedOrder`, `TimeInForce`, `MaxFloor`

2. [Order Lifecycle and State Machine](02_Order-Lifecycle-And-State-Machine.md) — FIX-standard order states (PendingNew through Expired), valid transitions, race conditions, internal OMS states, and order versioning
   - `OrdStatus`, `OrderStateMachine`, `FillBeforeCancel`, `UnsolicitedCancel`, `OrderVersion`, `StagedOrder`, `AlgoWorking`

3. [Order Routing and Smart Order Routing](03_Order-Routing-And-Smart-Order-Routing.md) — DMA routing, SOR decision logic with venue scoring, broker algo routing (VWAP, TWAP, IS, POV), and venue connectivity management
   - `SmartOrderRouter`, `DMARoute()`, `VenueScore`, `BrokerAlgoRoute()`, `FIXSession`, `ExDestination`

4. [Order Validation and Pre-Trade Checks](04_Order-Validation-And-Pre-Trade-Checks.md) — Sequential validation pipeline: schema validation, fat-finger checks, restricted lists, position limits, credit/buying power, short sale rules, and SEC 15c3-5 compliance
   - `ValidationPipeline`, `FatFingerCheck`, `PositionLimitCheck`, `CreditCheck`, `RestrictedListCheck`, `ShortSaleLocate`, `MarketAccessControl`

5. [Amendments, Cancellations, and Parent/Child Orders](05_Amendments-Cancellations-And-Parent-Child-Orders.md) — Cancel and cancel/replace request handling, mass cancel, cancel-on-disconnect, parent/child algo decomposition, bracket orders, and OCO logic
   - `OrderCancelRequest`, `CancelReplaceRequest`, `MassCancel`, `CancelOnDisconnect`, `ParentChildOrder`, `BracketOrder`, `OCO`, `ContingentOrder`

6. [Order Book Management](06_Order-Book-Management.md) — Blotter views (working orders, fills, audit trail), real-time position tracking with P&L, and multi-venue order aggregation
   - `WorkingOrderBlotter`, `ExecutionBlotter`, `PositionView`, `UnrealizedPnL`, `RealizedPnL`, `OrderBookAggregation`

7. [Multi-Asset Order Management](07_Multi-Asset-Order-Management.md) — Asset-class-specific order handling for equities, fixed income (RFQ), FX (streaming prices), listed derivatives, and commodities with unified API architecture
   - `EquityOrderHandler`, `FixedIncomeRFQ`, `FXStreamingPrice`, `DerivativesHandler`, `UnifiedOrderAPI`, `PriceFormatNormalize`

8. [FIX Protocol Integration](08_FIX-Protocol-Integration.md) — FIX session management (logon, heartbeat, sequence numbers, gap-fill recovery), core order messages (NewOrderSingle, ExecutionReport, CancelRequest), and party identification
   - `FIXSession`, `NewOrderSingle`, `ExecutionReport`, `OrderCancelRequest`, `SequenceNumberManager`, `ResendRequest`, `GapFill`

9. [Drop Copy, Audit Trails, and Care vs DMA Orders](09_Drop-Copy-Audit-Trails-And-Care-Vs-DMA-Orders.md) — Drop copy architecture for independent risk/compliance monitoring, regulatory audit trails (CAT, MiFID II), and care order vs. DMA order workflow distinctions
   - `DropCopySession`, `AuditTrail`, `CATReporting`, `CareOrder`, `DMAOrder`, `HandlInst`, `NotHeld`

10. [Allocation and Post-Trade Order Splitting](10_Allocation-And-Post-Trade-Order-Splitting.md) — Block order allocation methods (pro-rata, rotational, minimum dispersion), average price processing, FIX allocation messages, step-out/give-up, and post-trade booking workflow
    - `BlockAllocation`, `ProRataAlloc`, `AveragePriceCalc`, `AllocationInstruction`, `AllocationReport`, `StepOut`, `GiveUp`, `TradeBooking`

11. [Appendices](11_Appendices.md) — FIX tag reference tables, OrdRejReason values, and ExecRestatementReason codes
    - `FIXTagReference`, `OrdRejReason`, `ExecRestatementReason`, `CxlRejReason`
