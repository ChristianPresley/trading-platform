# Operational Workflows

Covers operational workflows in professional trading desk applications including start-of-day/end-of-day procedures, trade booking, break management, batch processing, market event handling, and disaster recovery.

## Contents

1. [Start-of-Day Procedures](01_Start-of-Day-Procedures.md) — SOD position loading, system health checks, market data validation, risk limit loading, and reference data verification
   - `SODPositionLoader`, `loadPositions()`, `SystemHealthCheck`, `MarketDataValidator`, `checkStaleness()`, `crossSourceValidation()`, `RiskLimitLoader`, `loadLimits()`, `ReferenceDataValidator`, `SODSignOff`

2. [End-of-Day Procedures](02_End-of-Day-Procedures.md) — EOD P&L calculation, position reconciliation, trade matching, reporting generation, and NAV calculation
   - `EODPnLCalculator`, `calculateRealizedPnL()`, `calculateUnrealizedPnL()`, `PositionReconciler`, `TradeMatchEngine`, `ReportGenerator`, `NAVCalculator`, `calculateNAV()`, `swingPricing()`, `PnLSignOff`

3. [Trade Booking Workflows](03_Trade-Booking-Workflows.md) — Trade capture data model, trade enrichment rules, validation checks, and booking to books and accounts
   - `Trade`, `TradeCaptureEngine`, `captureTrade()`, `TradeEnrichmentEngine`, `enrichSettlementDate()`, `enrichSSI()`, `TradeValidator`, `validatePrice()`, `validateDuplicate()`, `bookToLedger()`, `BookingStatus`

4. [Break Management and Exception Handling](04_Break-Management-and-Exception-Handling.md) — Position/trade/cash break types, investigation workflows, resolution SLAs, aging escalation, failed trades, and rejected orders
   - `BreakDetector`, `BreakInvestigator`, `categorizeBreak()`, `assignBreak()`, `BreakResolution`, `BreakAgingEscalator`, `FailedTradeHandler`, `RejectedOrderHandler`, `SettlementFailureWorkflow`, `CSDRPenaltyTracker`

5. [Batch Processing](05_Batch-Processing.md) — Overnight batch sequencing (COB, settlement, corporate actions, reporting, system prep), settlement instruction generation, and data loads
   - `BatchOrchestrator`, `COBProcessing`, `SettlementInstructionGenerator`, `generateSWIFTMessage()`, `NetSettlement`, `CorporateActionProcessor`, `RegulatoryReportGenerator`, `DataLoadValidator`, `BatchMonitor`, `batchFailureRecovery()`

6. [Market Event Handling](06_Market-Event-Handling.md) — Trading halt detection and response, circuit breaker handling, exchange outage procedures, and early close management
   - `TradingHaltHandler`, `detectHalt()`, `CircuitBreakerHandler`, `ExchangeOutageHandler`, `redirectSmartOrderRouter()`, `EarlyCloseManager`, `MarketCalendar`, `AlgoEndTimeAdjuster`, `OrderFreezeManager`

7. [Manual Intervention Workflows](07_Manual-Intervention-Workflows.md) — Manual trade entry with four-eyes approval, trade amendments, off-market trade handling, and voice trade workflows
   - `ManualTradeEntry`, `FourEyesApproval`, `TradeAmendmentWorkflow`, `OffMarketTradeDetector`, `VoiceTradeWorkflow`, `linkCallRecording()`, `AmendmentCutOff`, `OffMarketReasonCode`, `ComplianceReviewFlag`

8. [Client Onboarding for Trading](08_Client-Onboarding-for-Trading.md) — Multi-phase client onboarding (CDD, legal docs, credit setup, operational setup, go-live), credit limit management, and margin agreements
   - `ClientOnboarding`, `KYCCheck`, `SanctionsScreening`, `CreditLimitStructure`, `setCreditLimit()`, `MonitorCreditUtilization`, `MarginAgreement`, `calculateMarginCall()`, `CollateralManager`, `SSISetup`

9. [Disaster Recovery Procedures](09_Disaster-Recovery-Procedures.md) — DR architecture (active-active/warm/cold), failover testing, backup site activation, and communication protocols
   - `DisasterRecoveryPlan`, `RecoveryTimeObjective`, `RecoveryPointObjective`, `FailoverTest`, `executeSiteFailover()`, `validateDataConsistency()`, `BackupActivation`, `CommunicationPlan`, `IncidentEscalation`, `failback()`

10. [Intraday Monitoring and Operational Dashboards](10_Intraday-Monitoring-and-Operational-Dashboards.md) — Pre-market through post-close monitoring checklists and real-time dashboards for system health, trading activity, risk, operations, and compliance
    - `IntradayChecklist`, `PreMarketCheck`, `MidDayCheck`, `PreCloseCheck`, `PostCloseCheck`, `SystemHealthDashboard`, `TradingActivityDashboard`, `RiskOverviewDashboard`, `OperationsDashboard`, `ComplianceDashboard`
