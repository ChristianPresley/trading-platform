# Compliance, Regulatory, and Market Access Controls

Covers the compliance, regulatory reporting, and market access control features found in professional trading desk applications. Addresses the full lifecycle of regulatory obligations from pre-trade through post-trade, spanning multiple jurisdictions and asset classes.

## Contents

1. [Pre-Trade Compliance](01_Pre-Trade-Compliance.md) — Restricted/watch lists, insider trading prevention, information barriers, and personal account dealing controls
   - `RestrictedList`, `WatchList`, `checkRestrictedList()`, `InformationBarrier`, `WallCrossingEvent`, `InsiderList`, `PersonalAccountDealingRequest`, `preClearPersonalTrade()`, `BlackoutPeriod`

2. [Trade Surveillance](02_Trade-Surveillance.md) — Real-time detection of market manipulation, spoofing/layering, wash trading, front-running, and cross-trading monitoring
   - `SurveillanceEngine`, `detectSpoofing()`, `detectLayering()`, `detectWashTrading()`, `detectFrontRunning()`, `CrossTradeMonitor`, `AlertWorkflow`, `SuspiciousActivityReport`, `OrderToTradeRatio`, `CancelToFillRatio`

3. [Regulatory Reporting](03_Regulatory-Reporting.md) — MiFIR transaction reporting, EMIR/Dodd-Frank derivative reporting, CAT audit trail, SFTR, and SEC Rule 606 order routing disclosure
   - `MiFIRTransactionReport`, `EMIRTradeReport`, `DoddFrankSwapReport`, `CATEventReport`, `SFTRReport`, `Rule606Report`, `UniqueTradeIdentifier`, `UniqueProductIdentifier`, `submitToARM()`, `submitToSDR()`

4. [Best Execution Monitoring and Reporting](04_Best-Execution-Monitoring-And-Reporting.md) — Execution quality metrics, venue analysis, toxicity measurement, and RTS 27/28 report generation
   - `ExecutionQualityAnalyzer`, `calculateImplementationShortfall()`, `calculateVWAPSlippage()`, `VenueAnalysis`, `ToxicityAnalysis`, `RTS28Report`, `BestExecutionPolicy`, `measurePriceImprovement()`, `ReversionAnalysis`

5. [Record Keeping Requirements](05_Record-Keeping-Requirements.md) — Order/trade record retention, communication recording (voice and electronic), clock synchronization, and WORM storage compliance
   - `OrderRecord`, `TradeRecord`, `CommunicationRecorder`, `VoiceRecording`, `ElectronicCommunicationArchive`, `ClockSynchronizer`, `RetentionPolicy`, `WORMStorage`, `retrieveRecord()`

6. [Short Selling Regulations](06_Short-Selling-Regulations.md) — Locate requirements, Regulation SHO compliance, short sale circuit breaker (Rule 201), and short position reporting
   - `LocateManager`, `obtainLocate()`, `EasyToBorrowList`, `RegSHOCompliance`, `closeOutFailToDeliver()`, `ShortSaleCircuitBreaker`, `enforceUptickRule()`, `ThresholdSecurityList`, `ShortPositionReport`

7. [Market Access Controls](07_Market-Access-Controls.md) — SEC Rule 15c3-5 risk controls, kill switch, rate limiters, self-trade prevention, and erroneous trade prevention
   - `MarketAccessRiskControl`, `PreTradeRiskCheck`, `KillSwitch`, `activateKillSwitch()`, `RateLimiter`, `SelfTradePreventor`, `PriceCollar`, `LULDEnforcer`, `FatFingerProtection`, `DuplicateOrderDetector`

8. [AML/KYC in Trading Context](08_AML-KYC-In-Trading-Context.md) — Suspicious activity monitoring and SAR/STR filing, sanctions screening against OFAC/EU/UN lists, and real-time counterparty screening
   - `SuspiciousActivityMonitor`, `fileSAR()`, `fileSTR()`, `SanctionsScreener`, `screenCounterparty()`, `screenIssuer()`, `OFACSDNList`, `CurrencyTransactionReport`

9. [Position Reporting](09_Position-Reporting.md) — SEC large trader reporting, CFTC position limits, 13F filings, and Schedule 13D/13G beneficial ownership disclosure
   - `LargeTraderReport`, `LargeTraderID`, `CFTCPositionLimit`, `checkPositionLimit()`, `SEC13FReport`, `Schedule13D`, `Schedule13G`, `BeneficialOwnershipMonitor`, `alertOwnershipThreshold()`

10. [Cross-Border Trading Regulations](10_Cross-Border-Trading-Regulations.md) — Jurisdiction-specific regulatory requirements (US, UK, EU, Singapore, Hong Kong, Australia) and cross-border implementation considerations
    - `RegulatoryPerimeterMap`, `JurisdictionRuleSet`, `EquivalenceDetermination`, `DataLocalizationPolicy`, `MultiEntityBookingModel`, `RegulatoryChangeManager`, `TimezoneHandler`, `StockConnectCompliance`

11. [Glossary of Key Acronyms](11_Glossary-Of-Key-Acronyms.md) — Reference table of 60+ acronyms used across compliance, regulatory reporting, and market access domains
    - `ARM`, `CAT`, `CCP`, `EMIR`, `LEI`, `MiFIR`, `OFAC`, `SDR`, `SOR`, `SFTR`, `UTI`, `UPI`, `WORM`
