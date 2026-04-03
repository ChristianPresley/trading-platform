# Post-Trade Processing

Covers the post-trade processing features found in professional trading desk applications, spanning from trade execution through final settlement, corporate actions, reconciliation, tax reporting, and middle office functions.

## Contents

1. [Trade Confirmation and Clearing/Settlement](01_Trade-Confirmation-And-Clearing-Settlement.md) — Trade matching, electronic confirmations, CCP/bilateral clearing, settlement cycles, and CSD interactions
   - `TradeMatching`, `ElectronicConfirmation`, `matchTrade()`, `CCPClearing`, `novation()`, `calculateInitialMargin()`, `calculateVariationMargin()`, `netSettlementObligations()`, `SettlementCycle`

2. [Trade Allocation and Corporate Actions](02_Trade-Allocation-And-Corporate-Actions.md) — Block trade allocation, step-outs/give-ups, average pricing, and mandatory/voluntary corporate action processing
   - `BlockAllocation`, `allocateBlock()`, `StepOutTrade`, `GiveUpTrade`, `calculateAveragePrice()`, `CorporateAction`, `processDividend()`, `processStockSplit()`, `ElectionManager`, `RecordDateEntitlement`

3. [Reconciliation and Trade Lifecycle Events](03_Reconciliation-And-Trade-Lifecycle-Events.md) — Trade, position, and cash reconciliation, breaks management, and trade amendments/cancellations/corrections
   - `TradeReconciliation`, `PositionReconciliation`, `CashReconciliation`, `BreaksManager`, `categorizeBreak()`, `ageBreak()`, `TradeAmendment`, `TradeCancellation`, `TradeCorrection`, `matchRecords()`

4. [Custody, Asset Servicing, and Tax Reporting](04_Custody-Asset-Servicing-And-Tax-Reporting.md) — Custodian interactions, SWIFT messaging, income collection, wash sale tracking, tax lot accounting, and 1099/W-8BEN reporting
   - `CustodianInterface`, `SWIFTMessage`, `IncomeCollection`, `WashSaleDetector`, `TaxLotAccounting`, `selectTaxLot()`, `calculateCostBasis()`, `generate1099()`, `W8BENValidator`, `WithholdingTaxCalculator`

5. [STP, Exception Management, Middle Office, and Glossary](05_STP-Exception-Management-Middle-Office-And-Glossary.md) — STP rate measurement and enhancement, exception management workflows, trade validation/enrichment/booking, and P&L attribution
   - `STPRateCalculator`, `ExceptionManager`, `routeException()`, `TradeValidator`, `TradeEnrichment`, `enrichSettlementInstructions()`, `TradeBooking`, `bookTrade()`, `PnLAttribution`, `validatePnL()`
