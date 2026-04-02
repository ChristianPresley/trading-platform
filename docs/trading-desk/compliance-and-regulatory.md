# Compliance, Regulatory, and Market Access Controls

This document covers the compliance, regulatory reporting, and market access control features found in professional trading desk applications. It addresses the full lifecycle of regulatory obligations from pre-trade through post-trade, spanning multiple jurisdictions and asset classes.

---

## Table of Contents

1. [Pre-Trade Compliance](#1-pre-trade-compliance)
2. [Trade Surveillance](#2-trade-surveillance)
3. [Regulatory Reporting](#3-regulatory-reporting)
4. [Best Execution Monitoring and Reporting](#4-best-execution-monitoring-and-reporting)
5. [Record Keeping Requirements](#5-record-keeping-requirements)
6. [Short Selling Regulations](#6-short-selling-regulations)
7. [Market Access Controls](#7-market-access-controls)
8. [AML/KYC in Trading Context](#8-amlkyc-in-trading-context)
9. [Position Reporting](#9-position-reporting)
10. [Cross-Border Trading Regulations](#10-cross-border-trading-regulations)

---

## 1. Pre-Trade Compliance

Pre-trade compliance checks are enforced before an order reaches the market. They operate as synchronous gatekeepers in the order flow, typically adding microseconds to single-digit milliseconds of latency depending on complexity.

### 1.1 Restricted Lists

A restricted list contains securities that the firm is prohibited from trading, typically because the firm possesses material nonpublic information (MNPI) about the issuer or has a conflict of interest.

**Operational details:**

- The compliance department maintains one or more restricted lists in a centralized compliance engine (e.g., Bloomberg VAULT, Compliance Science ComplySci, NICE Actimize).
- Lists are keyed by security identifier (ISIN, CUSIP, SEDOL, FIGI, ticker) and may apply at the issuer level (covering all securities of a given issuer: equity, debt, derivatives).
- Restrictions can be absolute (no trading permitted) or conditional (e.g., trading permitted only for index rebalance, hedging existing positions, or client-directed unsolicited orders).
- Each entry has an effective date, expiration date (or open-ended), reason code, and the name of the information barrier group that imposed it.
- Order management systems (OMS) check every incoming order against the restricted list before routing. A hard block prevents the order from proceeding; a soft block requires compliance officer override with documented justification.
- When a security is added to the restricted list, the system should also flag any existing open orders or outstanding limit orders in that security for review and potential cancellation.

**Implementation considerations:**

- Near-real-time list updates via event bus or polling (sub-second refresh).
- Support for hierarchy-based restrictions: restricting a parent issuer restricts all subsidiaries.
- Audit trail of every check performed, including timestamp, user, security, result, and override (if any).

### 1.2 Watch Lists (Grey Lists)

A watch list (also called a grey list) contains securities that are under heightened monitoring but not necessarily restricted. The existence of a security on the watch list is itself confidential.

**Operational details:**

- Watch list entries trigger enhanced monitoring rather than trade blocking. Trades in watch list securities are flagged for post-trade review by compliance.
- The watch list is visible only to senior compliance personnel, not to traders or sales staff, to prevent information leakage.
- Typical triggers for watch list addition: the firm is advising on a potential M&A transaction, the research department is about to change a rating, or the firm has received confidential information through its lending desk.
- Monitoring includes tracking unusual position build-ups, timing of trades relative to announcement dates, and communication patterns around the security.

### 1.3 Insider Trading Prevention

Trading desk applications implement multiple layers of insider trading prevention aligned with SEC Rule 10b-5 (US), EU Market Abuse Regulation (MAR) Article 8/14, and equivalent rules in other jurisdictions.

**Information barriers (Chinese Walls):**

- Logical and physical separation between departments that may possess MNPI (investment banking, M&A advisory, principal trading) and those that execute client orders or proprietary trades.
- The OMS enforces barriers by associating users with barrier groups and restricting order flow across groups.
- Wall-crossing events are logged when an individual from a non-restricted side is brought "over the wall" for a specific transaction. The system tracks: who was crossed, when, by whom, for which transaction, and when they were brought back.
- Personal devices and communication channels are monitored during wall-crossing periods.

**Insider lists:**

- Under MAR Article 18, firms must maintain insider lists identifying all persons with access to inside information, with precise timestamps of when access was granted and revoked.
- Insider lists must be provided to the relevant national competent authority (NCA) upon request.
- The system must support both deal-specific insider lists and permanent insider lists (for individuals who routinely have access to inside information by virtue of their role).

### 1.4 Personal Account Dealing (PA Dealing) Rules

Regulations require firms to monitor and restrict the personal trading of employees, particularly those with access to client information or MNPI.

**Typical controls:**

- **Pre-clearance:** Employees must submit personal trade requests through a compliance portal before executing. The system checks the proposed trade against restricted lists, watch lists, recent client order flow, and pending research publications.
- **Holding periods:** Minimum holding periods (commonly 30-60 days) are enforced for approved personal trades to prevent short-term speculation based on firm information.
- **Blackout periods:** Trading windows may be closed around earnings announcements, research publication dates, or when the employee's team is working on a sensitive transaction.
- **Duplicate brokerage statements:** Employees are required to route personal brokerage accounts through designated brokers that send duplicate confirmations and statements directly to the compliance department.
- **Disclosure requirements:** Annual and quarterly holdings reports (required under SEC Rule 204A-1 for US investment advisers, and under MiFID II Article 29 for EU firms).
- **Gift and entertainment tracking:** Integrated tracking of gifts, entertainment, and political contributions that may create conflicts of interest.

**Standards:** FCA SYSC 10.2 (UK), SEC Rule 204A-1 (US), FINRA Rule 3210, MiFID II Delegated Regulation Article 29.

---

## 2. Trade Surveillance

Trade surveillance systems monitor order flow and trading activity in real time and historically to detect potential market abuse. These systems operate on both real-time streaming data and batch analysis of historical patterns.

### 2.1 Market Manipulation Detection

Market manipulation encompasses a broad range of behaviors intended to artificially influence the price, supply, or demand for a security. Under MAR Article 12 and Dodd-Frank Section 747, firms must have systems to detect and report suspected manipulation.

**Common patterns detected:**

- **Marking the close / Marking the open:** Placing orders near market close or open to influence settlement or reference prices. Detected by analyzing order placement timing relative to auction periods and their impact on closing/opening prices.
- **Painting the tape:** Executing a series of transactions that are reported publicly to give the impression of active trading. Detected through unusual volume spikes in low-liquidity securities correlated with limited counterparty diversity.
- **Pump and dump / Trash and cash:** Building a position, disseminating misleading positive (or negative) information, then unwinding at an artificial price. Detected by correlating trading patterns with communication analysis and social media monitoring.
- **Cornering / Squeezing:** Acquiring a dominant position in a security to control supply and force short sellers to cover at inflated prices. Detected through position concentration analysis.
- **Ramping:** Placing aggressive orders to move the price in a desired direction before a large trade, then canceling the aggressive orders. Overlaps with spoofing detection.

### 2.2 Spoofing and Layering Detection

Spoofing (placing orders with the intent to cancel before execution) and layering (placing multiple orders at different price levels to create false depth) are prohibited under Dodd-Frank Section 747 and MAR Article 12(1)(a).

**Detection methodology:**

- **Order-to-trade ratio analysis:** Abnormally high ratios of orders placed to orders filled, measured by trader, by security, and by time period. Thresholds are typically calibrated per venue and asset class.
- **Cancel-to-fill ratio:** Tracking the percentage of orders canceled versus filled. Ratios above a configurable threshold (e.g., 90%+) trigger alerts.
- **Temporal analysis:** Identifying orders placed and canceled within very short time windows (sub-second to seconds), particularly when the cancellation follows an execution on the opposite side.
- **Order book depth analysis:** Detecting non-bona-fide orders placed at multiple price levels on one side of the book that are removed after a fill on the opposite side.
- **Flipping detection:** Identifying rapid alternation between buy and sell sides, where orders on one side are consistently canceled after the other side executes.
- **Machine learning models:** Supervised models trained on confirmed spoofing cases and regulator-flagged patterns, using features such as order duration, distance from best bid/offer, volume relative to average, and subsequent price impact.

**Alert workflow:**

1. Real-time detection engine generates an alert with severity scoring.
2. Alert is enriched with order book context, trader history, and related alerts.
3. Compliance analyst reviews the alert in a case management interface.
4. Analyst dispositions the alert: escalate, close with rationale, or request further investigation.
5. Escalated alerts enter a formal investigation workflow and may result in a SAR (Suspicious Activity Report) or STR (Suspicious Transaction Report) filing.

### 2.3 Wash Trading Detection

Wash trading involves executing trades where there is no genuine change of beneficial ownership, creating misleading appearance of market activity. Prohibited under CEA Section 4c(a) and MAR.

**Detection approaches:**

- **Same-account matching:** Identifying cases where the same account (or accounts under common control) appears on both sides of a trade.
- **Beneficial ownership analysis:** Resolving trades to ultimate beneficial owners to detect wash trades across different accounts controlled by the same entity.
- **Pre-arranged trading patterns:** Detecting trades between accounts that exhibit suspiciously precise matching in timing, price, and quantity.
- **Cross-venue wash trading:** Monitoring for offsetting trades across different venues that net to zero position change.
- **Volume inflation:** Statistical analysis to identify securities where reported volume significantly exceeds genuine changes in beneficial ownership.

### 2.4 Front-Running Detection

Front-running occurs when a firm or individual trades ahead of a client order to profit from the expected price impact. Prohibited under MiFID II Article 25(1) and SEC common law principles.

**Detection methodology:**

- **Temporal correlation:** Analyzing the timing of proprietary or personal trades relative to large client orders in the same security. A pattern of proprietary buys preceding large client buy orders is indicative.
- **Information barrier monitoring:** Detecting leakage of client order information across information barriers by correlating trading activity with order receipt.
- **Communication analysis:** Cross-referencing trading timestamps with communication records (chat, voice, email) to detect information sharing preceding proprietary trades.
- **Statistical patterns:** Building baseline models of expected proprietary trading behavior and flagging statistically significant deviations that correlate with subsequent client order flow.
- **Reverse front-running:** Detecting cases where a trader delays or resequences client orders to benefit from anticipated market movements.

### 2.5 Cross-Trading Monitoring

Cross trades (trades between accounts managed by the same firm) are permitted in some circumstances but heavily regulated to prevent conflicts of interest.

**Controls:**

- **Price fairness validation:** Cross trades must be executed at a fair market price, typically the midpoint of the NBBO (National Best Bid and Offer) or the current market price.
- **Client consent verification:** Both sides of the cross trade must have consented to cross-trading, either through investment management agreements or specific consent.
- **Regulatory compliance by jurisdiction:** SEC Rule 17a-7 (for investment companies), ERISA Section 406 (for pension funds), and MiFID II Article 23 (for systematic internalisers) each impose different requirements.
- **Audit trail:** Complete documentation of the rationale for the cross, the pricing methodology, and confirmation that both accounts benefited or were not disadvantaged.
- **Aggregate cross-trade monitoring:** Identifying patterns where one account consistently loses on cross trades with another, which may indicate favoritism.

---

## 3. Regulatory Reporting

Professional trading desks must submit transaction and trade reports to multiple regulators and trade repositories, often in real time or within very short windows.

### 3.1 MiFID II / MiFIR Transaction Reporting

Under MiFIR Article 26, investment firms must report complete and accurate details of transactions in financial instruments to their national competent authority (NCA) no later than the close of the following working day (T+1).

**Report content (65 fields including):**

- Transaction reference number (firm-generated unique ID)
- Venue of execution (MIC code) or "XOFF" for off-venue
- Instrument identification (ISIN)
- Price, quantity, currency
- Buyer/seller identification (LEI for legal entities, national identifiers for natural persons)
- Trader identification (national ID or internal identifier of the person or algorithm making the decision)
- Decision-maker vs. executor distinction (who decided to trade vs. who executed)
- Algo identifier (if an algorithm made the investment or execution decision)
- Short selling indicator
- Waiver indicators
- Commodity derivative indicators (position reduction, hedging)

**Submission channels:**

- Via an Approved Reporting Mechanism (ARM): e.g., Bloomberg ARM, UnaVista (LSE), TRAX (MarketAxess)
- Via the trading venue (if the venue agrees to report on behalf of the firm)
- Directly to the NCA (less common)

**Key challenges:**

- LEI (Legal Entity Identifier) management: ensuring all counterparties have valid, non-lapsed LEIs
- National identifier collection for natural persons (passport numbers, national IDs) across EU member states
- Algo flagging: maintaining a register of all algorithms and ensuring correct tagging at the point of order entry
- Short sale flagging: real-time determination of short sale status

### 3.2 EMIR Trade Reporting

The European Market Infrastructure Regulation (EMIR) requires reporting of all derivative contracts to a registered Trade Repository (TR) by T+1.

**Scope:** All derivative asset classes (interest rate, credit, equity, commodity, FX) including OTC and exchange-traded derivatives.

**Report types:**

- **New trades:** Full details of the derivative contract, including UTI (Unique Trade Identifier), UPI (Unique Product Identifier), LEI of both counterparties, notional, maturity, and valuation.
- **Modifications:** Any amendment to the economic terms of the contract.
- **Valuations:** Daily mark-to-market or mark-to-model valuations and collateral posted.
- **Lifecycle events:** Compression, novation, early termination, exercise, assignment.

**EMIR Refit (effective April 2024):**

- Expanded from 129 to 203 reportable fields
- Mandatory use of ISO 20022 XML format
- UTI generation and sharing protocols aligned with CPMI-IOSCO guidance
- Mandatory LEI for all counterparties (no more BIC fallbacks)
- New fields for event types, prior UTI linkage, and package identifiers

**Trade Repositories (EU):** DTCC GTR, Regis-TR, UnaVista, KDPW, ICE Trade Vault Europe.

### 3.3 Dodd-Frank Reporting

Under Title VII of the Dodd-Frank Act, swap transactions must be reported to registered Swap Data Repositories (SDRs).

**Key requirements:**

- **Real-time reporting:** Publicly reportable swap data must be submitted "as soon as technologically practicable" after execution (typically within 15 minutes for on-facility trades, 30 minutes for off-facility).
- **Continuation data:** Ongoing lifecycle events, valuations, and collateral must be reported.
- **CFTC Part 43 (public dissemination):** Swap pricing and volume data is disseminated publicly in real time, subject to block trade and large notional transaction delays and caps.
- **CFTC Part 45 (regulatory reporting):** Comprehensive data reported to SDRs for regulatory oversight, including counterparty identification and valuation data.
- **SEC Rule 901 (Regulation SBSR):** Security-based swap reporting to registered SDRs, parallel regime to CFTC rules.
- **SDRs:** DTCC Data Repository, ICE Trade Vault, CME Repository, Bloomberg SDR.

**CFTC Rewrite Rules (effective 2022-2024):**

- Introduction of Unique Transaction Identifier (UTI) waterfall
- Unique Product Identifier (UPI) via ANNA-DSB
- Updated data elements aligned with CDE (Critical Data Elements) defined by CPMI-IOSCO
- Legal entity responsible for reporting hierarchy

### 3.4 CAT / OATS Reporting

**Consolidated Audit Trail (CAT):**

CAT, mandated by SEC Rule 613, is the comprehensive audit trail for US equities and listed options, replacing the older OATS system (which was retired in September 2020).

**Key aspects:**

- CAT captures every order event in the lifecycle: origination/receipt, routing, modification, cancellation, execution (full or partial).
- Reported by broker-dealers and exchanges to the CAT NMS Plan processor (FINRA CAT LLC).
- Events must include: Customer Account Information (with FDID — Firm Designated ID), material terms, timestamps (to the millisecond for manual events, microsecond for electronic), and linkage keys to trace the order through its full lifecycle.
- **Clock synchronization:** Firms must synchronize business clocks to NIST within 50 milliseconds (for events recorded manually) or within configurable tolerances for automated systems.
- **Customer and Account Reporting (CARS):** Firms must report customer and account information including name, address, date of birth (for natural persons), and LEI (for institutional accounts).
- **Error correction:** Errors must be corrected by T+3.

**Data sensitivity:** CAT data contains highly sensitive trading information. SEC Rule 613 and Plan amendments require extensive information security controls, with the CAT NMS Plan defining specific requirements for encryption, access controls, and data retention.

### 3.5 SFTR (Securities Financing Transactions Regulation)

SFTR requires EU counterparties to report securities financing transactions (SFTs) — repos, securities lending, buy-sell backs, and margin lending — to a registered trade repository.

**Requirements:**

- **Scope:** Repos, reverse repos, securities and commodities lending/borrowing, buy-sell back/sell-buy back transactions, margin lending.
- **Report timing:** T+1 (next business day after the SFT is concluded, modified, or terminated).
- **Fields:** 155 reportable fields including UTI, LEI, collateral data (on a line-by-line basis), reuse of collateral, cash reinvestment.
- **Dual-sided reporting:** Both counterparties must report, and UTIs must be agreed between them.
- **Trade Repositories:** DTCC GTR, Regis-TR, UnaVista, KDPW.

### 3.6 SEC Rule 606 (Order Routing Disclosure)

SEC Rule 606 (formerly Rule 11Ac1-6) requires broker-dealers to publicly disclose their order routing practices.

**Requirements:**

- **Quarterly public reports (Rule 606(a)):** For each calendar quarter, broker-dealers must publish reports detailing the venues to which they route non-directed customer orders in NMS securities and listed options, including:
  - Percentage of total orders routed to each venue
  - Material aspects of the firm's relationship with each venue (payment for order flow, profit-sharing, internalization arrangements)
  - Information on payment for order flow (PFOF) and transaction rebates received

- **Customer-specific reports on request (Rule 606(b)):**
  - For held NMS stock orders: venue routing details, fill rates, and net payment/rebate per share
  - For not-held NMS stock and options orders: detailed order-by-order information including timestamps, venues, and execution details within 7 business days of request

---

## 4. Best Execution Monitoring and Reporting

Best execution is the obligation to take sufficient steps to obtain the best possible result for clients when executing orders, taking into account price, costs, speed, likelihood of execution, settlement, size, nature, and any other relevant consideration.

### 4.1 Execution Quality Statistics

Trading desk applications maintain comprehensive execution quality metrics:

- **Price improvement:** Percentage of orders receiving a price better than the prevailing quote at time of receipt. Measured in basis points of improvement and as a percentage of order flow.
- **Effective spread vs. quoted spread:** The effective spread (2 * |execution price - midpoint at time of order|) compared to the prevailing quoted spread.
- **Implementation shortfall (IS):** The difference between the paper portfolio return (using decision price) and the actual portfolio return after all trading costs. Decomposed into:
  - Delay cost (market movement between decision and order release)
  - Market impact (price movement due to the order itself)
  - Timing cost (intraday price movement during execution)
  - Opportunity cost (unfilled portion of the order)
- **VWAP slippage:** Execution price vs. volume-weighted average price over the relevant benchmark period.
- **Fill rates:** Percentage of orders fully filled, partially filled, and unfilled, segmented by order type, size, and venue.
- **Latency metrics:** Order submission to acknowledgment, order to first fill, and order to complete fill.
- **Reversion analysis:** Post-trade price movement (5-second, 1-minute, 5-minute, 30-minute) to assess information leakage and market impact.

### 4.2 Venue Analysis

- **Venue-by-venue comparison:** Fill rates, average execution prices, spreads, and latency across all connected venues (exchanges, dark pools, systematic internalisers, market makers).
- **Toxicity analysis:** Measuring adverse selection by venue — some venues have higher rates of trades that are immediately followed by price moves against the order.
- **Venue tiering:** Classifying venues by execution quality for different order types and sizes to inform smart order routing (SOR) logic.
- **Dark pool analysis:** Comparing dark pool execution quality (midpoint fills, fill rates, information leakage) with lit venue alternatives.
- **Internalization monitoring:** Tracking when the firm internalizes client orders and comparing execution quality against external venues.

### 4.3 RTS 27 and RTS 28 Reports (MiFID II)

**RTS 28 (now the active requirement after RTS 27 was suspended):**

- Investment firms must publish annually a report identifying the top five execution venues by trading volume for each class of financial instrument, separately for retail and professional clients.
- The report must include the percentage of orders executed at each venue, the percentage of passive vs. aggressive orders, and the percentage of directed orders.
- Firms must disclose payment for order flow arrangements, close links with venues, and conflicts of interest.
- The report must cover executed client orders and securities financing transactions.

**RTS 27 (suspended by European Commission until further notice, originally required):**

- Execution venues were required to publish quarterly execution quality data including: prices and costs, speed and likelihood of execution, at a per-instrument level.
- Data was to be published in machine-readable format to enable comparison across venues.
- Although suspended in the EU, the transparency objectives behind RTS 27 continue to influence best execution monitoring practices.

**Best execution policy requirements (MiFID II Article 27):**

- Firms must establish, implement, and maintain a best execution policy that specifies the relative importance of execution factors for each asset class.
- The policy must identify the venues the firm relies on and the criteria for selecting between them.
- Regular monitoring (at minimum quarterly) of execution quality obtained, with adjustments to venue selection and routing logic as needed.
- Annual best execution report to clients summarizing monitoring results and any material changes.

---

## 5. Record Keeping Requirements

### 5.1 Order and Trade Records

Regulatory record-keeping obligations require firms to capture and retain extensive data about every stage of the order lifecycle.

**MiFID II / RTS 25 requirements:**

- All orders received from clients, including the date and time of receipt (to the granularity of the business clock requirement, at least one millisecond for electronic orders).
- All decisions to deal, including the algorithm identifier and parameters used.
- All orders submitted to venues, including venue identification, order type, limit price, quantity, and any special conditions (e.g., IOC, FOK, iceberg parameters).
- All order modifications, cancellations, expirations, and executions, with timestamps.
- For algorithmic trading, the system must log all parameters of each algorithm instance, including parent-child order relationships.

**SEC and FINRA requirements:**

- SEC Rule 17a-3 and 17a-4 define record creation and retention requirements for broker-dealers.
- Records must include: blotters (purchase/sale, receipt/delivery, cash), customer account records, order tickets (memoranda of orders), confirmations, trial balances, and securities records.
- FINRA Rule 4511 requires members to make and preserve books and records as required under applicable rules.
- Records of customer complaints and their resolution.

**Timestamps and clock synchronization:**

- MiFID II RTS 25: Business clocks must be synchronized to UTC, with granularity depending on the activity: 1 microsecond for high-frequency trading, 1 millisecond for other electronic trading, 1 second for non-electronic methods.
- FINRA/CAT: Clocks must be synchronized within 50 milliseconds of NIST for manual events and within the tolerances specified in the CAT NMS Plan for electronic events.

### 5.2 Communication Records

Firms must record and retain communications related to trading activity.

**Voice recording:**

- MiFID II Article 16(7): Firms must record telephone conversations and electronic communications relating to transactions concluded when dealing on own account and the provision of client order services that relate to the reception, transmission, and execution of client orders.
- Recordings must cover both firm-provided and personal devices if the firm has permitted use of personal devices for business communications.
- Recordings must be provided to clients on request.

**Electronic communications:**

- All electronic communications (email, chat, instant messaging) that relate to order reception, transmission, and execution must be recorded.
- Bloomberg chat (IB), Refinitiv Eikon Messenger, Symphony, ICE Chat, Microsoft Teams, and similar platforms must be archived.
- Under FINRA Rule 3110 and SEC Rule 17a-4, broker-dealers must retain electronic communications in a manner that allows for prompt retrieval and review.
- WhatsApp, WeChat, and other off-channel communication use has been the subject of significant SEC/FINRA enforcement actions and fines (over $2 billion in aggregate industry fines 2021-2024), making off-channel communication monitoring a critical area.

### 5.3 Retention Periods

| Jurisdiction / Regulation | Record Type | Minimum Retention |
|---------------------------|-------------|-------------------|
| MiFID II (Article 16) | Transaction records | 5 years |
| MiFID II (Article 16) | Voice / electronic communications | 5 years (may be extended to 7 by NCA) |
| SEC Rule 17a-4 | Blotters, ledgers, customer records | 6 years (first 2 years readily accessible) |
| SEC Rule 17a-4 | Order tickets, confirmations | 3 years (first 2 years readily accessible) |
| SEC Rule 17a-4 | Communications | 3 years |
| CFTC Rule 1.31 | All required records | 5 years (first 2 years readily accessible) |
| FCA (UK) | MiFID records | 5 years (communication records may be 3-5 years) |
| EMIR | Derivative trade reports | 5 years after termination of contract |
| SFTR | SFT data | 10 years following termination of the SFT |

**Storage requirements:**

- Records must be stored in non-rewritable, non-erasable format (WORM — Write Once Read Many) under SEC Rule 17a-4(f).
- Records must be readily accessible and searchable.
- Firms must maintain backup and disaster recovery capabilities.
- Cloud storage is permitted under SEC guidance, provided the cloud provider meets WORM and accessibility requirements and the firm retains ultimate control.

---

## 6. Short Selling Regulations

### 6.1 Locate Requirements

Before executing a short sale, the broker-dealer must have reasonable grounds to believe that the security can be borrowed and delivered by settlement date.

**US (Regulation SHO Rule 203(b)):**

- The firm must document the locate source (stock loan desk confirmation, easy-to-borrow list, or third-party locate service).
- Easy-to-borrow (ETB) lists must be updated at least daily and are based on the firm's historical ability to borrow the security.
- For securities not on the ETB list, a specific locate must be obtained from the stock loan desk or an external lending agent.
- Locates are typically valid for the trading day only and must be refreshed for orders carried overnight.
- Market makers may have an exception from the locate requirement under certain conditions (Rule 203(b)(2)(iii)), though this exception has been narrowed over time.

**EU Short Selling Regulation (SSR — Regulation 236/2012):**

- Requires a "locate" arrangement: the seller must have borrowed the shares, entered into an agreement to borrow, or have an arrangement with a third party confirming that the shares can be located and there is a reasonable expectation of settlement.
- Uncovered (naked) short selling of shares admitted to trading on an EU venue is prohibited.
- Uncovered short selling of EU sovereign debt CDS is also restricted (unless the buyer can demonstrate a hedging purpose).

### 6.2 Regulation SHO (US)

Regulation SHO is the primary US regulation governing short sales.

**Key provisions:**

- **Rule 200:** Definitions of long, short, and short exempt positions. Requires firms to aggregate net positions across all accounts and strategies to determine long/short status, with exceptions for independent trading units.
- **Rule 203(b)(1) — Locate requirement:** As described above.
- **Rule 203(b)(3) — Close-out requirement:** If a fail to deliver persists for 13 consecutive settlement days (T+13 from trade date, or T+3 from settlement date under T+1 settlement), the firm must purchase or borrow shares to close out the position. During the close-out period, the firm (and any broker acting on its behalf) is prohibited from further short sales in that security without first pre-borrowing.
- **Rule 204 — Close-out for CNS fails:** Positions that result in a fail to deliver at the NSCC's Continuous Net Settlement (CNS) system must be closed out by the morning of T+2 (under T+1 settlement), or T+4 in the case of long sales or market maker activity.
- **Threshold securities list:** The exchanges publish daily lists of securities with significant FTD levels (aggregate fails of 10,000+ shares that persist for 5+ consecutive settlement days and represent at least 0.5% of the total shares outstanding). Enhanced close-out obligations apply to threshold securities.

### 6.3 Short Sale Rule (SSR) / Circuit Breaker

SEC Rule 201 (the "Alternative Uptick Rule" or "Short Sale Circuit Breaker"):

- **Trigger:** When a security's price declines by 10% or more from the previous day's closing price.
- **Effect:** Once triggered, short sale orders may only be executed at a price above the current national best bid (the "uptick" requirement). This restriction applies for the remainder of the trading day and the entire following trading day.
- **Purpose:** Prevents short sellers from exacerbating a rapid price decline.
- **Implementation:** The listing exchange triggers the circuit breaker and disseminates a "short sale price test restriction" indicator via market data feeds. The OMS must enforce the restriction by rejecting or re-pricing short sale orders that do not comply.
- **Exceptions:** Market makers may be exempt for bona fide market-making activity. Orders marked "short exempt" may execute below the bid if the trader has an independent basis for marking the order exempt (e.g., the order was placed before the trigger, or the sale is for a VWAP contract).

### 6.4 Reporting Requirements

- **SEC Form SH (historical):** Previously required for institutional managers with significant short positions; no longer in effect, but proposals for new short position reporting have been advanced (SEC Rule 13f-2, effective January 2025).
- **SEC Rule 13f-2 and Form SHO:** Requires institutional investment managers to report short position data to the SEC on a monthly basis when positions exceed certain thresholds. Aggregated, anonymized data is then published by the exchanges.
- **EU SSR reporting thresholds:** Net short positions in shares of 0.1% of issued share capital must be reported to the NCA; positions of 0.5% and each subsequent 0.1% increment must be publicly disclosed. For sovereign debt, thresholds are set by the relevant NCA.
- **FCA (UK):** Similar disclosure regime post-Brexit, with reporting to the FCA at 0.1% and public disclosure at 0.5%.
- **ESMA emergency powers:** ESMA can impose temporary short selling bans in exceptional circumstances (invoked during the March 2020 COVID-19 market stress).

---

## 7. Market Access Controls

### 7.1 SEC Rule 15c3-5 (Market Access Rule)

SEC Rule 15c3-5 requires broker-dealers with market access (or that provide market access to others) to establish, document, and maintain a system of risk management controls and supervisory procedures that are reasonably designed to manage the financial, regulatory, and other risks of market access.

**Required controls:**

- **Pre-trade financial risk controls:**
  - Credit/capital thresholds: hard limits on the aggregate financial exposure from orders routed to the market, by customer, trading desk, and firmwide.
  - Single order size limits (preventing "fat finger" errors).
  - Order price reasonability checks (rejecting orders priced significantly away from the current market).
  - Position concentration limits (preventing excessive accumulation in a single security).
  - Aggregate notional/exposure limits per trader, desk, account, and firm.

- **Pre-trade regulatory risk controls:**
  - Restricted list checks (as described in Section 1.1).
  - Short sale compliance (locate verification, SSR enforcement).
  - Regulation NMS compliance (order protection rule / trade-through prevention).
  - LULD (Limit Up-Limit Down) price band enforcement.

- **Post-trade controls:**
  - Real-time position monitoring.
  - P&L monitoring with alert thresholds.
  - Intraday exposure reports.

**Key requirements:**

- Controls must be under the exclusive control of the broker-dealer providing market access (they cannot be outsourced to or controlled by the customer).
- Controls must prevent the entry of orders that exceed pre-set credit or capital thresholds.
- The system must be subject to regular review (at minimum annually) and the CEO must certify compliance.
- Direct market access (DMA) and sponsored access customers require the same level of controls as if the broker-dealer were entering the orders itself.

### 7.2 Pre-Trade Risk Controls (General)

Beyond SEC Rule 15c3-5, pre-trade risk controls are standard practice and increasingly mandated globally:

- **Kill switch / emergency halt:** The ability to immediately cancel all open orders and halt new order entry for a specific trader, algorithm, account, or the entire firm. Must be operable by risk management independently of the trading desk.
- **Rate limiters (message throttles):** Preventing excessive order submission rates that could overwhelm exchanges or trigger exchange-imposed throttles.
- **Duplicative order detection:** Identifying and preventing the same order from being submitted multiple times due to system glitches.
- **Self-trade prevention (STP):** Controls to prevent the firm from inadvertently trading with itself across different accounts or strategies. Exchanges typically offer STP mechanisms (cancel newest, cancel oldest, cancel both, decrement).
- **Algorithm-specific limits:** Individual risk limits per algorithm, including maximum order size, maximum participation rate, maximum position, and maximum loss.

### 7.3 Erroneous Trade Prevention

- **Price collars:** Rejecting orders priced more than a configurable percentage away from the NBBO or last trade price. Thresholds typically vary by security price (e.g., 5% for stocks over $25, 10% for stocks $3-$25, 20% for stocks under $3).
- **LULD compliance:** During Limit Up-Limit Down bands, orders that would execute outside the price bands are handled according to exchange rules (typically held or rejected, not executed).
- **Clearly erroneous execution (CEE) policies:** Exchanges have rules (e.g., NYSE Rule 128, Nasdaq Rule 11890) that allow trades to be broken or adjusted if they occur at prices substantially away from the prevailing market. Firms should have internal procedures for requesting CEE review.
- **Fat finger protection:** Maximum order size and notional limits to prevent data entry errors from reaching the market.

---

## 8. AML/KYC in Trading Context

### 8.1 Suspicious Activity Monitoring

While AML programs are primarily a firm-wide compliance function, trading desk applications integrate with AML systems in several ways:

- **Transaction monitoring:** Trading activity is fed to AML transaction monitoring systems (e.g., NICE Actimize, Oracle Financial Services AML, SAS Anti-Money Laundering) that apply rules and models to detect patterns indicative of money laundering, terrorist financing, or other financial crimes.
- **Suspicious patterns in trading:**
  - Structuring of transactions to avoid reporting thresholds
  - Rapid movement of funds through securities transactions (buying securities, immediately selling, and wiring proceeds)
  - Trading in thinly traded securities to manipulate prices and create artificial profits
  - Layering transactions through multiple accounts to obscure the audit trail
  - Mirror trading (offsetting transactions in correlated securities in different jurisdictions)
  - Use of shell companies or nominee accounts to conceal beneficial ownership

- **SAR/STR filing:** When suspicious activity is identified, the firm must file a Suspicious Activity Report (SAR) with FinCEN in the US (within 30 days of detection, or 60 days if no suspect is identified) or a Suspicious Transaction Report (STR) with the FCA (UK) or relevant NCA. The filing is confidential, and the firm must not "tip off" the subject.
- **Currency Transaction Reports (CTRs):** In the US, cash transactions exceeding $10,000 must be reported to FinCEN on a CTR. While less common in securities trading (which is predominantly electronic), physical settlement or cash transactions may trigger this requirement.

### 8.2 Sanctions Screening

Trading desks must screen all counterparties, issuers, and beneficial owners against sanctions lists.

**Key sanctions lists:**

- **OFAC SDN List (US):** The Office of Foreign Assets Control's Specially Designated Nationals and Blocked Persons List. Also includes sectoral sanctions (SSI) and non-SDN lists (CAPTA, NS-MBS).
- **EU/UK sanctions lists:** Consolidated lists maintained by the EU and the UK Office of Financial Sanctions Implementation (OFSI).
- **UN Security Council sanctions.**
- **Country-specific programs:** Cuba, Iran, North Korea, Syria, Russia (which has expanded significantly since 2022), and others.

**Implementation in trading systems:**

- **Pre-trade screening:** Every order is screened against sanctions lists to verify that neither the counterparty nor the issuer of the security (nor any substantially owned subsidiary) is sanctioned.
- **Reference data enrichment:** Security master data must include issuer domicile, ultimate parent, and ownership chain to support sanctions screening against securities issued by sanctioned entities or entities in sanctioned jurisdictions.
- **Real-time list updates:** Sanctions lists can be updated at any time. Systems must be able to ingest updates and apply them to pending orders within minutes.
- **Secondary sanctions:** US secondary sanctions may apply to non-US persons who transact with sanctioned parties. Firms operating globally must consider the extraterritorial reach of US sanctions.
- **Sectoral sanctions:** Some sanctions prohibit only specific types of transactions (e.g., debt with maturity over 14 days, new equity issuance) rather than all transactions with the designated party. This requires more granular screening logic.

---

## 9. Position Reporting

### 9.1 Large Trader Reporting (SEC)

**SEC Rule 13h-1 (Large Trader Reporting):**

- Any person or entity whose transactions in NMS securities equal or exceed 2 million shares or $20 million in any calendar day, or 20 million shares or $200 million in any calendar month, must register as a "large trader" with the SEC.
- Large traders receive a Large Trader ID (LTID) which must be provided to all broker-dealers through whom they transact.
- Broker-dealers must maintain records of LTID-associated transactions and report them to the SEC upon request (via electronic filing through the EDGAR system or, historically, the EBS — Electronic Blue Sheet system, now being replaced by CAT).

### 9.2 CFTC Position Limits and Reporting

**CFTC Position Limits (Part 150):**

- Federal position limits apply to 25 core referenced futures contracts (agricultural, energy, metals) and their economically equivalent swaps.
- Spot month limits are set at 25% of estimated deliverable supply (physical delivery contracts) or 25% of open interest (cash-settled contracts), up to a maximum of 10,000 contracts.
- Single-month and all-months limits are set at 10% of open interest for the first 25,000 contracts and 2.5% thereafter.
- Exchange-set position limits and accountability levels may be more restrictive.

**CFTC Reporting requirements:**

- **Form 40 (Statement of Reporting Trader):** Filed by traders who hold or control positions at or above reporting levels. Contains identification information and trading purpose.
- **Large Trader Reporting System (LTRS):** Futures commission merchants (FCMs) and clearing members must file daily large trader reports (Part 17) for any account holding a position at or above the CFTC's reportable level in any single futures or options contract.
- **Ownership and control reporting (OCR):** Links trading accounts to their owners, controllers, and associated entities for surveillance purposes.

### 9.3 SEC 13F Filings

**SEC Form 13F:**

- Filed quarterly (within 45 days of quarter-end) by institutional investment managers exercising investment discretion over $100 million or more in Section 13(f) securities (primarily US exchange-listed equities, ETFs, and certain convertible bonds and options).
- Reports the name, class, CUSIP, number of shares, and market value of each holding, along with investment discretion (sole, shared, none) and voting authority.
- Confidential treatment requests may be made for positions that the manager is actively accumulating or disposing of, though the SEC scrutinizes such requests and disclosure is delayed, not eliminated.
- 13F data is publicly available via the SEC EDGAR system and is widely used by the investment community for position tracking.

### 9.4 Schedule 13D and 13G

**Schedule 13D (Beneficial Ownership Report):**

- Required when any person or group acquires beneficial ownership of more than 5% of a class of registered equity securities.
- Must be filed within 5 business days of crossing the 5% threshold (reduced from 10 calendar days under 2024 amendments).
- Requires disclosure of: the identity and background of the acquirer, the source and amount of funds used, the purpose of the acquisition (including any plans for mergers, reorganizations, or other extraordinary transactions), and the number of shares held.
- Material changes (1% or more change in position, or change in purpose or plans) require an amendment within 2 business days.

**Schedule 13G (Short-Form Beneficial Ownership Report):**

- Available to certain categories of filers who acquire more than 5% but are not seeking to change or influence control of the issuer:
  - **Qualified Institutional Investors (QIIs):** Must file within 45 days of quarter-end in which the 5% threshold is first crossed. Amendments required within 5 business days of month-end if holdings exceed 10% or change by 5%.
  - **Passive investors:** Must file within 5 business days of crossing 5%. Must file within 2 business days of exceeding 10%.
  - **Exempt investors:** Certain investors who acquired shares prior to the issuer's registration.
- If the holder's intent changes from passive to active, they must switch to Schedule 13D within 10 days.

**Trading desk implementation:**

- Position monitoring systems must track beneficial ownership percentages in real time across all funds, accounts, and strategies managed by the firm.
- Alerts must fire when positions approach the 5% threshold (typically at 4.5% or a configurable warning level) to allow for timely filing preparation.
- Holdings must be aggregated across all accounts under common control, including derivative positions that confer economic exposure or voting rights (swaps, options, convertible securities).

---

## 10. Cross-Border Trading Regulations

### 10.1 United States — SEC and CFTC

**Key regulatory bodies:** Securities and Exchange Commission (SEC), Commodity Futures Trading Commission (CFTC), Financial Industry Regulatory Authority (FINRA).

**Key regulations for trading desks:**

- Securities Exchange Act of 1934 (broker-dealer registration, market structure rules)
- Regulation NMS (order protection, access, sub-penny pricing, market data)
- Regulation SHO (short selling)
- Regulation ATS (alternative trading systems registration and fair access)
- SEC Rule 15c3-5 (market access controls)
- SEC Rule 15c3-1 (net capital requirements)
- Dodd-Frank Title VII (OTC derivatives regulation)
- Volcker Rule (restrictions on proprietary trading by banks)
- FINRA Rules (suitability, best execution, trade reporting)

### 10.2 United Kingdom — FCA

**Key regulatory body:** Financial Conduct Authority (FCA).

**Post-Brexit framework:**

- UK retained and onshored MiFID II / MiFIR as UK domestic law, then began diverging.
- UK MiFIR transaction reporting remains largely aligned with EU MiFIR but with UK-specific modifications (e.g., reporting to the FCA rather than through EU ARMs).
- The FCA has proposed reforms under the Wholesale Markets Review, including:
  - Replacing the share trading obligation and the double volume cap
  - Reforming the transparency regime for equities and fixed income
  - Reviewing the systematic internaliser regime
- UK EMIR retained for derivatives reporting, with the FCA and Bank of England as supervisory authorities.
- UK Benchmark Regulation covers LIBOR transition and benchmark manipulation (post-LIBOR scandal reforms).
- Senior Managers and Certification Regime (SM&CR) imposes personal accountability on senior management for compliance failures.

### 10.3 European Union — ESMA

**Key regulatory body:** European Securities and Markets Authority (ESMA), plus national competent authorities (NCAs) in each member state (e.g., BaFin in Germany, AMF in France, CONSOB in Italy).

**Key regulations:**

- MiFID II / MiFIR (investment services, market structure, transparency, transaction reporting)
- MAR (Market Abuse Regulation — insider dealing, market manipulation, unlawful disclosure)
- EMIR (OTC derivatives clearing and reporting)
- SFTR (securities financing transactions reporting)
- CSDR (Central Securities Depositories Regulation — settlement discipline, mandatory buy-ins postponed but still contemplated)
- EU Short Selling Regulation (SSR)
- BMR (Benchmarks Regulation)
- DORA (Digital Operational Resilience Act — effective January 2025, covering ICT risk management, incident reporting, digital operational resilience testing, and third-party risk management for financial entities)

### 10.4 Singapore — MAS

**Key regulatory body:** Monetary Authority of Singapore (MAS).

**Key regulations:**

- Securities and Futures Act (SFA) — licensing, market conduct, and market abuse provisions.
- Financial Advisers Act (FAA) — suitability and advice obligations.
- MAS Notice SFA04-N16 — risk management practices for capital market services licensees.
- OTC derivatives reporting under the SFA Part VIA — reporting of specified derivatives to a licensed trade repository.
- Position limits set by SGX (Singapore Exchange) for exchange-traded derivatives.
- Short selling is permitted but regulated: "naked" short selling is prohibited; covered short selling must comply with SGX rules including a mandatory buy-in regime.
- Substantial shareholding notifications required at 5% threshold under Section 135 of the SFA.

### 10.5 Hong Kong — SFC / HKMA

**Key regulatory bodies:** Securities and Futures Commission (SFC), Hong Kong Monetary Authority (HKMA, for banking institutions).

**Key regulations:**

- Securities and Futures Ordinance (SFO) — market misconduct, licensing, disclosure.
- SFC Code of Conduct — suitability, best execution, client asset protection.
- OTC derivatives mandatory clearing and reporting under the SFO Part IIIA.
- Short selling: SFC maintains a list of designated securities eligible for short selling. Short selling of securities not on the list is prohibited. All short sales must be covered and executed at or above the best current ask price (tick rule).
- Disclosure of interests: Substantial shareholding disclosure required at 5% under Part XV of the SFO, with notification within 3 business days.
- Stock Connect (Shanghai-Hong Kong, Shenzhen-Hong Kong): Cross-border trading link with specific regulatory requirements including daily quotas, eligible securities, investor qualification, and settlement arrangements.

### 10.6 Australia — ASIC

**Key regulatory body:** Australian Securities and Investments Commission (ASIC).

**Key regulations:**

- Corporations Act 2001 — market integrity rules, licensing, market misconduct.
- ASIC Market Integrity Rules — separate rule sets for ASX, Chi-X, and other venues covering pre-trade controls, order management, best execution, and market manipulation.
- ASIC derivative transaction rules (reporting) — reporting of OTC derivatives to a licensed trade repository (DTCC GTR or other).
- Short selling: Covered short selling is permitted; naked short selling is prohibited. Short sale indicators must be included in all sell orders that are short sales. ASIC publishes daily aggregated short sale data.
- Substantial holding disclosure required at 5% under the Corporations Act, with notification within 2 business days.
- Design and Distribution Obligations (DDO) — product governance requirements for financial products.
- ASIC requires algorithmic trading participants to have adequate risk controls, including kill switch capabilities, testing requirements, and monitoring.

### 10.7 Cross-Border Implementation Considerations

When building a multi-jurisdictional trading platform, the following considerations apply:

- **Regulatory perimeter mapping:** Determine which regulations apply based on the entity executing the trade, the venue of execution, the domicile of the client, and the domicile of the instrument's issuer. A single trade may trigger obligations under multiple jurisdictions.
- **Equivalence and substituted compliance:** Some jurisdictions recognize each other's regulatory regimes as equivalent (e.g., EU-US substituted compliance for swap reporting). The system must track which equivalence determinations are in effect and route reporting accordingly.
- **Data localization requirements:** Some jurisdictions require certain data to be stored within their borders (e.g., China, Russia). The system architecture must accommodate data residency constraints.
- **Timezone handling:** Regulatory deadlines are defined in local time of the relevant jurisdiction. A global platform must handle settlement dates, reporting deadlines, and trading hours across all time zones.
- **Multi-entity booking model:** Large firms operate through multiple legal entities across jurisdictions. The system must support entity-specific compliance rules, reporting obligations, and capital requirements.
- **Regulatory change management:** The system must be configurable to adapt to regulatory changes without code changes wherever possible. Regulation evolves continuously, and the platform must support versioned rule sets with effective dates.

---

## Glossary of Key Acronyms

| Acronym | Definition |
|---------|-----------|
| ARM | Approved Reporting Mechanism (MiFID II) |
| ASIC | Australian Securities and Investments Commission |
| CAT | Consolidated Audit Trail |
| CCP | Central Counterparty Clearing House |
| CEA | Commodity Exchange Act |
| CFTC | Commodity Futures Trading Commission |
| CNS | Continuous Net Settlement |
| CSD | Central Securities Depository |
| CSDR | Central Securities Depositories Regulation |
| CTR | Currency Transaction Report |
| DMA | Direct Market Access |
| DORA | Digital Operational Resilience Act |
| DTCC | Depository Trust & Clearing Corporation |
| EMIR | European Market Infrastructure Regulation |
| ESMA | European Securities and Markets Authority |
| ETB | Easy-to-Borrow |
| FCA | Financial Conduct Authority (UK) |
| FIGI | Financial Instrument Global Identifier |
| FINRA | Financial Industry Regulatory Authority |
| FTD | Fail to Deliver |
| HKMA | Hong Kong Monetary Authority |
| ISIN | International Securities Identification Number |
| LEI | Legal Entity Identifier |
| LTID | Large Trader ID |
| LULD | Limit Up-Limit Down |
| MAR | Market Abuse Regulation (EU) |
| MAS | Monetary Authority of Singapore |
| MIC | Market Identifier Code |
| MiFID | Markets in Financial Instruments Directive |
| MiFIR | Markets in Financial Instruments Regulation |
| MNPI | Material Nonpublic Information |
| NBBO | National Best Bid and Offer |
| NCA | National Competent Authority |
| NMS | National Market System |
| OATS | Order Audit Trail System (retired) |
| OFAC | Office of Foreign Assets Control |
| OMS | Order Management System |
| PFOF | Payment for Order Flow |
| SAR | Suspicious Activity Report |
| SDR | Swap Data Repository |
| SEC | Securities and Exchange Commission |
| SEDOL | Stock Exchange Daily Official List |
| SFC | Securities and Futures Commission (Hong Kong) |
| SFTR | Securities Financing Transactions Regulation |
| SHO | Regulation SHO (Short Sales) |
| SOR | Smart Order Router |
| SSR | Short Selling Regulation / Short Sale Rule |
| STP | Straight-Through Processing |
| STR | Suspicious Transaction Report |
| SWIFT | Society for Worldwide Interbank Financial Telecommunication |
| TR | Trade Repository |
| UPI | Unique Product Identifier |
| UTI | Unique Trade Identifier |
| VWAP | Volume-Weighted Average Price |
| WORM | Write Once Read Many |
