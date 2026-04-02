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
