## 1. Trade Confirmation and Affirmation

The confirmation and affirmation process ensures that both sides of a trade agree on the economic terms before settlement proceeds. This is the critical first step in reducing settlement fails.

### 1.1 Trade Matching

Trade matching is the process of comparing the trade details reported by both counterparties to verify agreement on all material terms.

**Matched fields typically include:**

- Trade date and settlement date
- Security identifier (ISIN, CUSIP, SEDOL)
- Buy/sell indicator
- Quantity (number of shares, contracts, or notional amount)
- Price (or rate for fixed income, premium for options)
- Currency and settlement currency (if different)
- Settlement location and method
- Counterparty identifiers (BIC, LEI, DTCC participant number)
- Accrued interest (for fixed income)
- Net settlement amount
- Commission and fees (where applicable)
- Special settlement instructions (DVP, FOP, etc.)

**Matching tolerance:**

- Price and quantity must match exactly in most cases.
- Net money amount tolerances may be applied (e.g., $25 or less for US domestic equities through DTCC, configurable for bilateral matching).
- Settlement date mismatches are flagged as "alleged" trades requiring resolution.

**Matching workflows:**

- **Automatic matching:** When both sides submit details that agree within tolerance, the trade is automatically confirmed. This is the target state for STP.
- **Partial matching:** Some fields match but others do not. The system presents unmatched fields to operations staff for investigation.
- **Unmatched/alleged trades:** One side has submitted details but the counterparty has not, or the counterparty's details do not match at all. These require outreach to the counterparty (typically via email, phone, or platform messaging).

### 1.2 Electronic Confirmations

Paper-based confirmations have been largely replaced by electronic confirmation and affirmation platforms, driven by regulatory requirements for same-day affirmation (SDA).

**SEC Rule 15c6-2 (effective May 2024, coinciding with T+1 settlement):**

- Broker-dealers must either enter into written agreements with their institutional customers to achieve allocation, confirmation, and affirmation by end of trade date, or establish, maintain, and enforce policies and procedures reasonably designed to ensure completion of these steps as soon as technologically practicable and no later than end of trade date.

**Key platforms:**

- **DTCC/ITP (Institutional Trade Processing):** The central matching utility for US institutional trades, comprising CTM (Central Trade Manager) and the legacy TradeSuite platform.
- **Bloomberg TOMS (Trade Order Management Solutions):** Provides electronic trade matching and affirmation through Bloomberg terminal integration.
- **MarketAxess / Tradeweb:** Electronic confirmation for fixed income and derivatives trades.
- **FIX Protocol:** The Financial Information eXchange protocol (FIX 4.2, 4.4, 5.0) is widely used for electronic trade confirmation messaging between buy-side and sell-side firms, as well as for allocation instructions.

### 1.3 DTCC/Omgeo CTM (Central Trade Manager)

CTM (now part of DTCC's Institutional Trade Processing, or ITP) is the industry-standard platform for matching institutional equity and fixed income trades in the US and globally.

**How CTM works:**

1. **Trade submission:** The broker-dealer (sell-side) submits trade details to CTM after execution. The investment manager (buy-side) independently submits their version of the trade, including allocation instructions.
2. **Central matching:** CTM compares the two submissions. If all fields match within configured tolerances, the trade is automatically matched and affirmed (TM — Trade Match status).
3. **Exception handling:** If submissions do not match, CTM presents the discrepancies to both parties. Either party can amend their submission. Re-matching occurs automatically upon amendment.
4. **Affirmation:** Once matched, the affirmed trade flows downstream to DTC (Depository Trust Company) for settlement processing.
5. **Standing Settlement Instructions (SSIs):** CTM integrates with DTCC's ALERT database, which stores pre-validated settlement instructions for institutional accounts. When a trade is matched, settlement instructions are automatically enriched from ALERT, eliminating manual SSI communication.

**CTM message types:**

- **MT515 / MT518 equivalents (ISO 15022/20022):** Trade confirmation and affirmation messages.
- CTM supports both FIX-based and proprietary message formats for input.
- Output to DTC is via automated feeds for settlement instruction delivery.

**Metrics:**

- Same-day affirmation (SDA) rates are a key industry metric. The target under T+1 settlement is to achieve affirmation by 9:00 PM ET on trade date. Industry SDA rates have risen above 90% for US equities as of 2025.
- DTCC publishes monthly SDA rate statistics by firm and instrument type.

---

## 2. Clearing and Settlement

### 2.1 CCP Clearing

A Central Counterparty (CCP) interposes itself between the buyer and seller after trade execution, becoming the buyer to every seller and the seller to every buyer. This process is called novation.

**Key CCPs:**

| CCP | Jurisdiction | Asset Classes |
|-----|-------------|---------------|
| NSCC (National Securities Clearing Corporation) | US | Equities, corporate/municipal bonds, UITs |
| FICC (Fixed Income Clearing Corporation) | US | Government securities (GSD), mortgage-backed securities (MBSD) |
| OCC (Options Clearing Corporation) | US | Listed options, futures |
| LCH (LCH.Clearnet) | UK/EU | Interest rate swaps, CDS, repos, equities, FX |
| Eurex Clearing | EU (Germany) | Listed derivatives, OTC IRS, repo |
| ICE Clear Europe | UK | CDS, energy futures, equity derivatives |
| JSCC (Japan Securities Clearing Corporation) | Japan | Interest rate swaps, CDS, listed derivatives |
| SGX-DC (SGX Derivatives Clearing) | Singapore | Listed derivatives, OTC commodities |
| ASX Clear / ASX Clear (Futures) | Australia | Equities, listed derivatives |

**CCP clearing process:**

1. **Trade capture:** The CCP receives trade data from the exchange or trading venue (for exchange-traded products) or from the trade confirmation platform (for OTC products subject to mandatory clearing).
2. **Novation:** The CCP becomes the legal counterparty to both sides. The original bilateral trade is replaced by two trades: one between the buyer and the CCP, and one between the CCP and the seller.
3. **Margining:**
   - **Initial margin (IM):** Collateral deposited at trade inception, calculated to cover the CCP's potential future exposure to a member default. Calculated using models such as SPAN (Standard Portfolio Analysis of Risk), VaR, or historical simulation. Called daily or intraday.
   - **Variation margin (VM):** Daily (or intraday) settlement of mark-to-market gains and losses. The losing party pays the CCP, which passes the payment to the winning party.
   - **Default fund contributions:** Each clearing member contributes to a mutualized default fund that covers losses exceeding the defaulting member's margin.
4. **Netting:** The CCP nets all obligations between itself and each clearing member, dramatically reducing the total number of settlement obligations and the gross value of securities and cash that must be delivered.
5. **Settlement instruction delivery:** The CCP sends net settlement instructions to the relevant CSD (Central Securities Depository) for final settlement.

### 2.2 Bilateral Clearing

Not all trades are cleared through a CCP. Bilateral clearing applies to OTC products not subject to mandatory clearing, certain bespoke derivatives, and some fixed income trades.

**Bilateral settlement workflow:**

1. Trade confirmation via bilateral ISDA-based processes (for derivatives) or direct counterparty confirmation.
2. Settlement instructions are exchanged bilaterally, often via SWIFT MT messages or platform-based communication.
3. Collateral management is handled bilaterally under ISDA CSA (Credit Support Annex) agreements: daily margin calls based on portfolio mark-to-market, independent amounts, and threshold/minimum transfer amounts.
4. Uncleared Margin Rules (UMR, under BCBS-IOSCO): Mandated initial margin exchange for uncleared OTC derivatives above a notional threshold (currently $8 billion AANA). IM must be held at a third-party custodian in segregated accounts and calculated using either ISDA SIMM (Standard Initial Margin Model) or a regulatory schedule-based approach.

### 2.3 Settlement Cycles

**Current settlement cycles (as of 2025):**

| Market / Asset Class | Settlement Cycle |
|---------------------|------------------|
| US equities and corporate bonds | T+1 (effective May 28, 2024) |
| US government securities (treasuries) | T+1 |
| Canadian equities | T+1 (effective May 27, 2024) |
| EU equities | T+2 (T+1 under discussion for 2027) |
| UK equities | T+2 (Accelerated Settlement Taskforce recommending T+1 by 2027) |
| India equities | T+1 (fully implemented January 2023) |
| China A-shares | T+1 (Shanghai/Shenzhen) |
| Hong Kong equities | T+2 |
| Japan equities | T+2 (moved from T+3 in May 2019) |
| Australia equities | T+2 |
| FX spot | T+2 |
| FX forwards/swaps | Varies per contract |
| Listed options exercise | T+1 (US) |
| OTC derivatives | Per ISDA terms (typically T+1 or T+2 for cash flows) |

**T+1 settlement implications:**

- The compression of the settlement cycle from T+2 to T+1 has significantly impacted post-trade workflows. Firms must achieve same-day allocation, confirmation, and affirmation to avoid settlement fails.
- Securities lending recall periods are shortened, requiring faster locate and recall processes.
- FX settlement for cross-border trades (where the currency leg settles T+2 but the securities leg settles T+1) creates funding mismatches that must be managed through pre-funding or FX settlement solutions.
- Corporate actions processing timelines are compressed, requiring faster ex-date and record date handling.

### 2.4 Fails Management

A settlement fail occurs when a securities transaction does not settle on the intended settlement date, either because the seller fails to deliver securities or the buyer fails to deliver cash.

**Fail monitoring:**

- The settlement system tracks all pending settlement obligations and identifies fails on settlement date.
- Fails are categorized by reason: short position (seller does not hold sufficient securities), operational failure (incorrect SSIs, account issues), counterparty failure, CSD processing error, or external event (system outage, market holiday discrepancy).
- Fail aging reports track how long each fail has been outstanding.

**Fail penalties:**

- **CSDR Settlement Discipline Regime (EU):** Mandatory cash penalties for settlement fails calculated daily based on the type of instrument and whether the fail is due to late delivery of securities or cash. Penalty rates: 1 basis point per day for liquid equities, 0.5 bps for other equities, 0.25 bps for SME growth market instruments, 0.10 bps for government and municipal bonds, and similar rates for other instrument types.
- **DTC (US):** While the US does not have mandatory cash penalties equivalent to CSDR, the SEC has considered adopting settlement discipline measures. NSCC's Stock Borrow Program and Continuous Net Settlement system manage fails through automated borrow and lending.

**Fail resolution:**

- **Buy-in process:** If a seller fails to deliver for an extended period, the buyer (or CCP) may execute a buy-in: purchasing the securities on the open market and charging the cost to the failing seller. Under CSDR, mandatory buy-ins were postponed (originally scheduled for February 2022, then indefinitely deferred). In the US, buy-in is at the buyer's discretion (except for Reg SHO mandatory close-outs).
- **Partial settlement:** Some CSDs support partial settlement, delivering whatever quantity is available and creating a residual obligation for the remainder. This reduces the all-or-nothing nature of settlement and can reduce overall fail rates.
- **Securities lending to cover fails:** Firms may borrow securities from their prime broker or a lending counterparty to cover a delivery failure.
- **Shaping:** Splitting large settlement obligations into smaller deliveries that can be settled individually, useful when partial quantities are available.
