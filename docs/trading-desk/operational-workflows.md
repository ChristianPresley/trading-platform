# Operational Workflows in Professional Trading Desk Applications

## Table of Contents

1. [Start-of-Day Procedures](#1-start-of-day-procedures)
2. [End-of-Day Procedures](#2-end-of-day-procedures)
3. [Trade Booking Workflows](#3-trade-booking-workflows)
4. [Break Management](#4-break-management)
5. [Exception Handling](#5-exception-handling)
6. [Batch Processing](#6-batch-processing)
7. [Market Event Handling](#7-market-event-handling)
8. [Manual Intervention Workflows](#8-manual-intervention-workflows)
9. [Client Onboarding for Trading](#9-client-onboarding-for-trading)
10. [Disaster Recovery Procedures](#10-disaster-recovery-procedures)
11. [Intraday Monitoring Checklists and Operational Dashboards](#11-intraday-monitoring-checklists-and-operational-dashboards)

---

## 1. Start-of-Day Procedures

The start-of-day (SOD) process is the critical transition from overnight batch processing to live trading readiness. A failed or incomplete SOD can delay the desk's ability to trade and expose the firm to risk from stale data.

### 1.1 SOD Position Loading

Positions are the foundation of trading operations. Every desk must begin the day with an accurate view of what it holds.

**Position loading sequence**:

1. **Extract closing positions from the books of record**: The overnight batch (see Section 6) produces end-of-day positions for T-1. These are the authoritative positions that include all settlements, corporate actions, and reconciliation adjustments from the previous day.

2. **Apply overnight events**: Between market close and the next morning, several events may affect positions:
   - **Settlements**: Trades settling on T (today) cause actual delivery/receipt of securities and cash
   - **Corporate actions**: Ex-date processing (dividends, splits, mergers) may alter positions
   - **Margin calls**: Collateral movements processed overnight
   - **Transfers**: Internal book-to-book or entity-to-entity transfers executed overnight

3. **Load into the real-time position server**: The calculated SOD positions are loaded into the in-memory position engine that traders will interact with during the day. This engine applies real-time trade and fill events on top of the SOD base.

4. **Validate SOD positions against external sources**:
   - **Custodian positions**: Compare against custodian/depository statements received overnight
   - **Prime broker positions**: For hedge funds, compare against PB statements
   - **Exchange positions**: For listed derivatives, compare against clearing house margin statements
   - **Fund administrator positions**: For asset managers, compare against fund admin NAV packs

5. **Flag and investigate discrepancies**: Any difference between the internal SOD position and external statements must be flagged as a break and investigated before trading begins (see Section 4 on Break Management).

**Position loading timeline** (typical US equities desk):
| Time (ET) | Activity |
|---|---|
| 04:00 | Overnight batch completes, T-1 EOD positions finalized |
| 04:30 | SOD position files generated and validated |
| 05:00 | Positions loaded into real-time engine |
| 05:30 | External position files received (custodian, PB) |
| 06:00 | Automated reconciliation runs, breaks flagged |
| 06:30 | Operations reviews breaks, escalates material items |
| 07:00 | Desk head confirms trading readiness |
| 07:30 | Pre-market trading begins (if applicable) |
| 09:30 | Regular market open |

**Failure mode**: If SOD positions cannot be loaded (e.g., batch failure, data corruption), the desk must either trade on estimated/stale positions (with heightened risk controls) or delay trading until the issue is resolved. This decision involves the desk head, risk management, and operations, and must be documented.

### 1.2 System Health Checks

Before the trading day begins, automated and manual checks verify that all platform components are operational.

**Automated health check suite**:

| Component | Check | Pass Criteria | Impact if Failed |
|---|---|---|---|
| Order Management System | Heartbeat, order submission test | Response < 50ms | Cannot trade |
| Execution Management System | Connectivity to all venues | All configured venues connected | Reduced venue access |
| FIX Connectivity | Session status per counterparty | All sessions logged on | Cannot route to specific venues |
| Market Data Feed | Tick count, last update time | Ticks received within last 5 seconds | Stale pricing, cannot trade |
| Risk Engine | Limit loading, calculation test | All limits loaded, test calc correct | Cannot enforce risk limits |
| Position Server | SOD positions loaded, count validation | Position count matches expected | Incorrect P&L, risk exposure |
| Database | Connection pool, query performance | Connections available, queries < 100ms | Degraded performance |
| Network | Latency to exchanges, internal latency | Within normal bounds | Execution quality degradation |
| Disaster Recovery | DR site replication lag | Lag < 30 seconds | Increased recovery time |
| Reference Data | Instrument master load | All expected instruments present | Cannot trade missing instruments |

**Health check dashboard**: The SOD health check results are displayed on an operational dashboard with red/amber/green status. All red items must be resolved before trading begins. Amber items can proceed with documented risk acceptance.

**Sign-off process**: The operations manager or a designated SOD controller must formally sign off that the system is ready for trading. This sign-off is logged and timestamped.

### 1.3 Market Data Validation

Stale or incorrect market data is one of the most dangerous failure modes in a trading system because it can cause orders to be priced incorrectly.

**Market data validation checks**:

1. **Staleness check**: Verify that market data feeds are delivering fresh ticks. Compare the last tick timestamp against the current time. A feed that has not updated in more than N seconds (configurable per asset class) is flagged as stale.

2. **Cross-source validation**: Compare prices from multiple data sources (e.g., Bloomberg, Refinitiv, direct exchange feeds). Divergences beyond a configurable threshold trigger an alert.

3. **Reasonability check**: Compare current prices against previous close. Moves exceeding a configurable threshold (e.g., >10% for equities, >50bps for sovereign bonds) are flagged for review. This catches data errors (e.g., a decimal point shift) and also surfaces legitimate overnight moves that may require attention.

4. **Corporate action adjustment**: Verify that prices reflect corporate actions (e.g., a stock that split 2:1 overnight should show approximately half the previous close).

5. **Holiday calendar validation**: Confirm that market data feeds for closed markets are correctly showing as inactive rather than stale. A feed showing zero ticks for the Tokyo exchange on a Japanese holiday is correct, not an error.

6. **Derived data validation**: Verify that calculated values (implied volatility, yield, spread) are consistent with their inputs. A bond showing a negative yield when the price and coupon imply a positive yield indicates a calculation error.

### 1.4 Risk Limit Loading

Risk limits must be loaded and active before any trading is permitted.

**Risk limit loading process**:

1. **Load limit definitions**: Read the current limit configuration from the limit management database. This includes all desk-level, trader-level, and book-level limits.
2. **Apply overnight changes**: Any limit changes approved overnight (e.g., a temporary limit increase approved the previous evening) are applied.
3. **Expire temporary limits**: Temporary limit increases that have passed their expiry time are reverted to the base limit.
4. **Validate limit hierarchy**: Ensure that sub-limits (e.g., per-trader limits) do not exceed parent limits (e.g., desk limits). Flag configuration errors.
5. **Load current utilization**: Calculate current limit utilization based on SOD positions. A desk starting the day at 90% of its VaR limit needs to know this immediately.
6. **Activate pre-trade risk checks**: Enable the real-time pre-trade risk check engine that evaluates every incoming order against applicable limits.

**Limit loading failure mode**: If limits cannot be loaded, no trading is permitted. This is a hard requirement. Trading without risk limits is equivalent to trading with unlimited risk.

### 1.5 Price Validation and Reference Data

Reference data (instrument master, counterparty master, settlement instructions) must be loaded and validated before trading.

**Reference data checks**:
- **Instrument count**: Compare the number of loaded instruments against the expected count. A significant shortfall (e.g., >1% missing) indicates a data load failure.
- **New instruments**: Verify that any newly listed instruments (IPOs, new bond issues, new derivatives series) are present and correctly configured.
- **Expired instruments**: Verify that expired instruments (matured bonds, expired options, delisted stocks) are correctly marked as inactive.
- **Static data quality**: Spot-check key attributes (tick size, lot size, currency, exchange, settlement cycle) against a reference source.
- **Pricing reference data**: Verify that closing prices, settlement prices, and reference rates (SOFR, EURIBOR, etc.) are loaded correctly.
- **Calendar data**: Verify that holiday calendars and trading schedules are current for all markets the desk trades.

---

## 2. End-of-Day Procedures

End-of-day (EOD) procedures close out the trading day, produce official figures, and prepare the system for the overnight batch.

### 2.1 EOD P&L Calculation

The P&L calculation is the single most important EOD output. It determines the desk's performance and feeds into fund NAV, regulatory capital, and management reporting.

**P&L components**:

| Component | Description | Calculation |
|---|---|---|
| **Realized P&L** | Profit/loss from trades closed during the day | Sum of (sell price - cost basis) for all closing trades |
| **Unrealized P&L** | Mark-to-market change on open positions | Sum of (current mark - previous mark) x position for all open positions |
| **Total P&L** | Realized + Unrealized | Sum of above |
| **Fees and commissions** | Execution costs | Sum of all fees paid (exchange fees, broker commissions, clearing fees) |
| **Financing costs** | Cost of funding positions | Margin interest, repo costs, stock borrow fees |
| **FX P&L** | P&L from currency movements on non-base-currency positions | Position x FX rate change |
| **Accrued interest** | For fixed income, interest accrued during the day | Coupon rate x day count fraction |

**P&L hierarchy**:
```
Firm P&L
  Division P&L
    Desk P&L
      Book P&L
        Strategy P&L
          Trade-level P&L
```

Every level must reconcile: the sum of child P&Ls must equal the parent P&L. Discrepancies indicate a booking error, missing trade, or calculation error.

**Mark-to-market pricing**:
- **Liquid instruments** (listed equities, major FX pairs, liquid futures): Use official closing/settlement price from the exchange
- **Semi-liquid instruments** (corporate bonds, less liquid options): Use composite pricing from multiple sources (Bloomberg BVAL, Refinitiv, broker quotes)
- **Illiquid instruments** (OTC derivatives, structured products, distressed debt): Use model-based pricing with independent price verification (IPV)
- **Fair value hierarchy**: Level 1 (quoted prices), Level 2 (observable inputs), Level 3 (unobservable inputs, model-based). Accounting standards (ASC 820, IFRS 13) require disclosure of which level applies to each position.

**P&L sign-off process**:
1. Automated P&L calculation runs after market close
2. P&L is compared against intraday estimates (any material difference is investigated)
3. Desk head reviews and approves desk-level P&L
4. Finance/product control verifies P&L independently (independent P&L verification, or IPV)
5. Material P&L differences between front-office and product control are investigated and resolved
6. Official P&L is published to downstream systems (risk, accounting, reporting)

### 2.2 Position Reconciliation

Position reconciliation ensures that the firm's internal position records match external records.

**Reconciliation levels**:

| Level | Internal Source | External Source | Frequency |
|---|---|---|---|
| Front-to-back | Trading system (front office) | Books of record (back office) | Daily |
| Internal-to-custodian | Books of record | Custodian/depository statement | Daily |
| Internal-to-counterparty | Books of record | Counterparty/broker statement | Daily |
| Internal-to-exchange | Derivatives positions | Clearing house statement | Daily |
| Cash reconciliation | Cash ledger | Bank statement | Daily |
| NAV reconciliation | Internal NAV | Fund administrator NAV | Daily |

**Reconciliation workflow**:
1. Load internal positions and external positions into the reconciliation engine
2. Apply matching rules:
   - **Auto-match**: Positions that agree exactly (quantity, instrument, account) are automatically matched
   - **Tolerance match**: Positions that agree within a defined tolerance (e.g., +/- 0.01% for quantity, +/- $0.01 for cash) are matched with a warning
   - **Partial match**: Positions where some fields agree but others do not are flagged for investigation
   - **Unmatched**: Positions that appear on one side but not the other are flagged as breaks
3. Breaks are categorized by type and materiality
4. Immaterial breaks (below a defined threshold) are auto-resolved or deferred
5. Material breaks are assigned to an investigator with a resolution SLA

### 2.3 Trade Matching

Trade matching confirms that both sides of a trade agree on the terms. Unmatched trades carry settlement risk.

**Matching process**:
- **Electronic matching**: For exchange-traded products and electronically-confirmed OTC trades, matching is automatic via the exchange or confirmation platform (e.g., DTCC CTM, MarkitWire, Omgeo)
- **Manual matching**: For voice-traded OTC products, matching involves comparing trade details sent by each counterparty (e.g., via SWIFT confirmations or email)

**Key matching fields**: Trade date, settlement date, instrument, quantity/notional, price/rate, buy/sell side, counterparty, settlement instructions.

**Matching statuses**:
| Status | Description | Action Required |
|---|---|---|
| Matched | Both sides agree on all terms | None, proceed to settlement |
| Alleged | One side has submitted, other has not | Chase counterparty for confirmation |
| Disputed | Both sides submitted but terms differ | Investigate and resolve discrepancy |
| Unmatched | Timeout, no counterparty submission | Escalate, potential trade break |

### 2.4 Reporting Generation

EOD reporting produces the official record of the day's activity for multiple consumers.

**Report types**:

| Report | Audience | Content | Deadline |
|---|---|---|---|
| Daily P&L report | Desk heads, management, finance | P&L by desk, book, strategy | T+0 close + 2 hours |
| Position report | Risk, compliance, operations | Positions by desk, instrument, account | T+0 close + 2 hours |
| Risk report | Risk management, senior management | VaR, Greeks, stress tests, limit utilization | T+0 close + 3 hours |
| Execution quality report | Compliance, trading | Fill rates, slippage, venue analysis | T+1 morning |
| Regulatory transaction report | Regulators (via reporting channels) | MiFIR, EMIR, Dodd-Frank reportable trades | T+1 (often mandatory deadline) |
| Client report | Clients, sales | Execution details, portfolio summary | T+1 morning |
| Settlement instruction report | Operations, custodian | Pending settlements, SSI details | T+0 close + 1 hour |
| Break report | Operations, management | Outstanding breaks by type and age | T+0 close + 2 hours |
| Compliance surveillance report | Compliance | Flagged trades, alerts, restricted list activity | T+1 morning |

### 2.5 NAV Calculation

For asset management firms, the Net Asset Value calculation is the definitive measure of fund performance and determines investor returns.

**NAV calculation process**:

1. **Position valuation**: Mark all positions to market using official closing prices (see P&L mark-to-market pricing above)
2. **Accrued income**: Calculate accrued interest, pending dividends, and other income
3. **Expense accrual**: Accrue management fees, performance fees, fund operating expenses, and transaction costs
4. **Shareholder activity**: Process subscriptions and redemptions effective on this date
5. **Currency translation**: Translate non-base-currency positions to the fund's base currency using closing FX rates
6. **Gross NAV**: Sum of all asset values minus liabilities
7. **Per-share NAV**: Gross NAV divided by shares outstanding
8. **Swing pricing** (if applicable): Adjust NAV for the cost of trading to accommodate large inflows/outflows, preventing dilution for existing shareholders
9. **NAV publication**: Publish to fund administrator, pricing services, and distribution platforms

**NAV timeline** (typical daily-dealing fund):
| Time | Activity |
|---|---|
| T+0 16:00 | Market close, dealing cut-off |
| T+0 18:00 | Preliminary NAV calculated internally |
| T+0 20:00 | NAV sent to fund administrator |
| T+1 08:00 | Fund administrator returns verified NAV |
| T+1 10:00 | NAV discrepancies investigated and resolved |
| T+1 12:00 | Official NAV published |
| T+1 14:00 | NAV distributed to pricing services (Bloomberg, Refinitiv, Morningstar) |

---

## 3. Trade Booking Workflows

### 3.1 Trade Capture

Trade capture is the process of recording a trade in the system. The goal is to capture every trade accurately, completely, and as close to real-time as possible.

**Capture methods**:

| Method | Description | STP Rate | Latency |
|---|---|---|---|
| **Electronic execution** | Orders filled on exchange or via electronic venues | >99% | Milliseconds |
| **Algo execution** | Fills from algorithmic execution strategies | >99% | Milliseconds |
| **RFQ platforms** | Trades executed via electronic RFQ (Tradeweb, MarketAxess, Bloomberg) | >95% | Seconds |
| **Voice broker** | Trades negotiated by phone, entered manually | 0% (manual) | Minutes to hours |
| **Block trade** | Large trades negotiated off-exchange | 50-80% | Minutes |
| **Give-up/take-up** | Trades executed by one broker, given up to another for clearing | 60-80% | Hours |
| **Allocation** | Block trades split across multiple accounts/funds | 70-90% | Minutes to hours |

**Trade capture data model** (core fields):
```
Trade
  TradeId (system-generated, immutable)
  ExternalTradeId (exchange/platform trade ID)
  TradeDate
  SettlementDate
  Instrument
    InstrumentId, ISIN, CUSIP, SEDOL, Ticker
    InstrumentType
  Side (Buy/Sell/SellShort/BuyCover)
  Quantity / Notional
  Price / Rate
  Currency
  Counterparty
  Broker / ExecutingVenue
  Account / Book
  Trader (who executed)
  OrderId (link to originating order)
  TradeStatus (new, confirmed, settled, cancelled, amended)
  CommissionAndFees
    ExchangeFee, BrokerCommission, ClearingFee, Tax
  SettlementInstructions
    DeliveryAgent, ReceivingAgent
    SWIFT/BIC codes, account numbers
  RegulatoryFields
    ReportingFlag, TransactionReportId
    LEI (Legal Entity Identifier) of both parties
    TradingCapacity (principal, agent, riskless principal)
```

### 3.2 Trade Enrichment

Enrichment is the process of automatically populating fields that the trader did not explicitly enter but are required for booking, settlement, and reporting.

**Enrichment rules**:

| Field | Enrichment Source | Rule |
|---|---|---|
| Settlement date | Market convention engine | T+2 for equities (US/EU), T+1 for US Treasuries, T+0 for FX spot (T+2 for most pairs) |
| Settlement instructions | SSI database | Look up default SSI for counterparty + instrument type + currency |
| Clearing broker | Clearing relationship table | Based on instrument type and execution venue |
| Commission | Commission schedule | Based on broker, instrument type, and trade size |
| Exchange fees | Fee schedule | Based on exchange, instrument, and trade side |
| Tax | Tax rules engine | Stamp duty, FTT, withholding tax based on jurisdiction |
| Regulatory flags | Regulatory rules engine | Determine if trade is reportable under EMIR, MiFIR, Dodd-Frank |
| LEI | Counterparty master | Look up Legal Entity Identifier |
| Account | Allocation rules | For PM-initiated trades, determine target account based on allocation model |
| Book | Booking rules | Determine which book the trade should be booked to based on desk, strategy, instrument type |

**Enrichment failure handling**: If enrichment cannot complete (e.g., no SSI found for a new counterparty, unknown instrument), the trade is placed in an exception queue for manual enrichment by operations. The trade must not be booked to a live book until enrichment is complete.

### 3.3 Trade Validation

Validation checks ensure the trade is internally consistent and passes all business rules before booking.

**Validation checks**:

1. **Mandatory field validation**: All required fields are present and non-null
2. **Reference data validation**: Instrument, counterparty, account, and book all exist in the reference data and are active
3. **Date validation**: Trade date is valid (not a holiday, not in the future for non-forward trades), settlement date is correct per market convention
4. **Price validation**: Trade price is within a configurable tolerance of the current market price (fat-finger check)
5. **Quantity validation**: Trade quantity is a valid lot size for the instrument
6. **Limit validation**: Trade does not breach position limits, notional limits, or concentration limits
7. **Compliance validation**: Trade does not involve a restricted instrument, does not breach mandate constraints
8. **Counterparty validation**: Counterparty is approved, credit limit is not breached, all required documentation (ISDA, CSA) is in place
9. **Duplicate check**: Trade is not a duplicate of an already-booked trade (based on key fields and timing)
10. **Settlement instruction validation**: SSIs are valid, correspondent banks are correct

### 3.4 Booking to Books and Accounts

Once enriched and validated, the trade is booked, meaning it becomes part of the firm's official position and P&L record.

**Booking process**:

1. **Assign to book**: The trade is assigned to the appropriate trading book based on booking rules (desk, strategy, instrument type, trader)
2. **Generate accounting entries**: The trade generates accounting entries in the general ledger:
   - Debit/credit to the position account (securities inventory)
   - Debit/credit to the cash/settlement account (payable/receivable)
   - Commission and fee accruals
3. **Update position**: The real-time position engine is updated with the new trade
4. **Update P&L**: The P&L engine recalculates for the affected book
5. **Generate confirmations**: Trade confirmations are generated and sent to the counterparty (via SWIFT, DTCC, or electronic platform)
6. **Generate regulatory reports**: If the trade is reportable, the regulatory report is generated and queued for submission
7. **Notify downstream systems**: Trade events are published to downstream consumers (risk, compliance, settlement, accounting)

**Booking status lifecycle**:
```
New -> Enriched -> Validated -> Booked -> Confirmed -> Settled
                                    \-> Amended (creates new version)
                                    \-> Cancelled (soft delete)
```

---

## 4. Break Management

### 4.1 Types of Breaks

A "break" is any discrepancy between two records that should agree. Breaks are the primary indicator of operational problems and are a key focus for middle and back office teams.

**Position breaks**:
- **Internal position break**: Front-office position does not match back-office position. Typically caused by a trade booked in one system but not the other, or booked with different terms.
- **External position break**: Internal position does not match custodian/clearing house/counterparty statement. Caused by missed settlements, incorrect corporate action processing, or booking errors.
- **Cash position break**: Cash ledger does not match bank statement. Caused by missed cash movements, incorrect fee calculations, or unbooked cash events.

**Trade breaks**:
- **Unmatched trade**: Trade exists internally but the counterparty has not confirmed it (alleged trade)
- **Disputed trade**: Both sides have confirmed but terms differ (price, quantity, settlement date, instrument)
- **Missing trade**: Counterparty has confirmed a trade that does not exist internally
- **Duplicate trade**: Same trade appears to have been booked twice

**Cash breaks**:
- **Settlement cash break**: Expected settlement amount does not match actual cash movement
- **Income break**: Expected coupon/dividend payment does not match actual receipt
- **Fee break**: Expected fee deduction does not match actual deduction
- **FX settlement break**: Expected currency amount does not match after FX conversion

### 4.2 Break Investigation Workflow

**Break lifecycle**:
```
Detected -> Assigned -> Under Investigation -> Root Cause Identified -> Resolution Proposed -> Resolved -> Closed
```

**Investigation process**:

1. **Detection**: The reconciliation engine flags a discrepancy that exceeds the tolerance threshold
2. **Categorization**: The break is automatically categorized by:
   - Type (position, trade, cash)
   - Materiality (based on dollar amount and percentage of position)
   - Age (new, 1 day, 2-5 days, >5 days)
   - Asset class and desk
3. **Assignment**: The break is assigned to an investigator based on desk ownership, asset class expertise, and workload balancing
4. **Investigation**: The investigator:
   - Reviews all relevant trade records, position snapshots, and external statements
   - Contacts the counterparty if needed (via Operations contacts, not traders)
   - Identifies the root cause from common causes: booking error, missed settlement, corporate action discrepancy, timing difference, data feed issue
5. **Resolution**: Based on the root cause, the investigator proposes a resolution:
   - **Amend**: Correct the trade details (price, quantity, date, account)
   - **Cancel/rebook**: Cancel the incorrect trade and enter the correct one
   - **Book missing trade**: Enter a trade that was missing from the system
   - **Adjust position**: Post a manual adjustment with full documentation
   - **Write-off**: For immaterial amounts that cannot be resolved, post a write-off (requires approval)
6. **Approval**: Material resolutions (above a threshold) require approval from a supervisor or operations manager
7. **Closure**: The break is marked as resolved, with full documentation of the root cause and resolution

### 4.3 Break Resolution SLAs

| Break Type | Materiality | Resolution SLA |
|---|---|---|
| Position break | > $1M | Same day |
| Position break | $100K - $1M | T+1 |
| Position break | < $100K | T+2 |
| Trade break (unmatched) | Any | T+1 (before settlement date) |
| Cash break | > $100K | Same day |
| Cash break | < $100K | T+2 |
| Aged break (> 5 days) | Any | Escalation to management |
| Aged break (> 30 days) | Any | Mandatory write-off review |

### 4.4 Break Aging and Escalation

Break aging is a critical metric. Old breaks indicate systemic problems and carry increasing risk.

**Aging escalation ladder**:
| Age | Action |
|---|---|
| T+1 | Break appears on daily break report, assigned to investigator |
| T+3 | Automatic escalation to operations manager |
| T+5 | Automatic escalation to desk head and risk manager |
| T+10 | Automatic escalation to COO / Head of Operations |
| T+30 | Mandatory management review, potential write-off |
| T+60 | Regulatory concern (some regulators require breaks to be resolved within defined timeframes) |

---

## 5. Exception Handling

### 5.1 Failed Trades

A failed trade is one that did not settle on the intended settlement date. Settlement failure is a significant operational and regulatory event.

**Common causes of settlement failure**:
- **Insufficient securities**: Seller does not have the securities in the correct account at the custodian
- **Insufficient funds**: Buyer does not have the cash to pay for the securities
- **SSI mismatch**: Settlement instructions are incorrect or not set up at the custodian
- **Documentation gap**: Required documentation (e.g., legal agreement for an OTC derivative) is not in place
- **Counterparty failure**: The counterparty's operational infrastructure failed
- **CSD/ICSD issues**: The central securities depository experienced an outage or processing error
- **Regulatory restriction**: A regulatory hold or sanction prevents settlement

**Failed trade workflow**:

1. **Detection**: The settlement system reports that settlement did not occur on the expected date. This may come from the custodian, clearing house, or the CSD.
2. **Notification**: Operations is alerted immediately. The desk is notified if the failure may have trading implications (e.g., a short position that was supposed to be covered).
3. **Root cause investigation**: Operations determines why the trade failed and what is needed to resolve it.
4. **Resolution actions**:
   - Resubmit with corrected SSIs
   - Arrange securities borrowing if short of inventory
   - Contact counterparty operations to resolve on their side
   - Escalate to custodian or CSD if the issue is on their end
5. **Partial settlement**: Some CSDs support partial settlement (delivering a portion of the position while the remainder is pending). Operations decides whether to accept partial settlement.
6. **Penalty tracking**: Under CSDR (Central Securities Depositories Regulation) in the EU, settlement failures incur daily cash penalties. These must be tracked, allocated to the responsible party, and reported.
7. **Buy-in procedures**: If a trade remains failed beyond a defined period, the buyer may initiate a mandatory buy-in (purchasing the securities from another source and charging the failing seller for any price difference).

**Settlement failure metrics**:
- Settlement failure rate (target: <2% by value)
- Average days to resolution
- Penalty costs incurred
- Repeat failures by counterparty (for relationship management)

### 5.2 Rejected Orders

Orders can be rejected at multiple points in the execution chain.

**Rejection points and handling**:

| Rejection Point | Common Causes | Handling |
|---|---|---|
| **Pre-trade risk check** | Limit breach, restricted instrument, invalid parameters | Immediate feedback to trader, suggest corrective action |
| **Compliance check** | Restricted list, mandate breach, position limit | Notify compliance, trader cannot override |
| **Venue validation** | Invalid instrument for venue, market closed, invalid order type | Immediate feedback, suggest alternative |
| **Exchange rejection** | Price outside daily limit, invalid lot size, self-trade prevention | Immediate feedback with exchange error code |
| **Broker rejection** | Credit limit breach, bilateral agreement issue | Notify operations, escalate to credit |
| **Clearing rejection** | Margin insufficient, position limit at clearing house | Notify operations, arrange margin |

**Rejection workflow**:
1. System captures the rejection with full context (reason code, timestamp, original order details)
2. Trader is notified immediately with a clear explanation
3. If the rejection is due to a system or configuration issue (not a legitimate business rule), IT is notified
4. Repeated rejections of the same type trigger an investigation (is there a systemic problem?)
5. All rejections are logged for compliance surveillance (patterns of rejected orders can indicate market manipulation attempts)

### 5.3 Unmatched Trades

Unmatched trades are trades that have been booked internally but not confirmed by the counterparty.

**Unmatched trade workflow**:
1. **Automatic matching**: The confirmation platform (DTCC, MarkitWire, etc.) attempts to match the trade electronically
2. **T+0 matching check**: At EOD, any unmatched trades are flagged
3. **Counterparty chase**: Operations contacts the counterparty's operations team to determine why the trade is unmatched:
   - Counterparty has not yet booked the trade (timing lag)
   - Counterparty has booked with different terms (dispute)
   - Counterparty does not recognize the trade (potential error)
4. **Escalation**: If unmatched by T+1 (or before settlement date, whichever is earlier), escalate to desk and relationship management
5. **Resolution**: Amend terms if agreed, or cancel and rebook if necessary
6. **Settlement risk**: Unmatched trades that approach their settlement date without resolution may need to be settled on a "with-risk" basis (settling without confirmation, accepting the risk of subsequent dispute)

### 5.4 Late Allocations

Late allocations occur when a block trade has been executed but the allocation to individual accounts/funds has not been completed in time.

**Late allocation impact**:
- Settlement may be delayed because the custodian does not know which account to deliver to/from
- NAV calculations may be incorrect because the trade is not assigned to the correct fund
- Regulatory reporting may be delayed or inaccurate

**Late allocation workflow**:
1. **SLA monitoring**: Block trades must be allocated within a defined time window (e.g., T+0 for same-day settlement markets, before the allocation cut-off for the custodian/prime broker)
2. **Alert**: If the allocation deadline is approaching and allocations are not complete, operations and the PM are alerted
3. **Default allocation**: Some systems support a "default allocation" that is applied automatically if no instructions are received. This uses a pre-defined allocation model (pro-rata by AUM, equal weight, etc.)
4. **Late allocation processing**: If allocations are received after the cut-off:
   - Custodian/PB may charge late allocation fees
   - Settlement may be delayed by a day
   - The block trade may settle to a suspense account and then be transferred, creating additional operational work
5. **Root cause analysis**: Persistent late allocations indicate a process problem (PM not providing timely instructions, system integration issue, timezone mismatch for global funds)

---

## 6. Batch Processing

### 6.1 Overnight Batch Runs

The overnight batch is the backbone of the daily operational cycle. It processes the day's activity into the official books and records and prepares the system for the next trading day.

**Batch sequence** (typical order):

```
Phase 1: Close of Business (COB) Processing
  1.1  Trade snapshot - Lock the day's trade population
  1.2  Price snapshot - Lock closing/settlement prices
  1.3  FX rate snapshot - Lock closing FX rates
  1.4  Position calculation - Calculate official EOD positions
  1.5  P&L calculation - Calculate official EOD P&L
  1.6  Risk calculation - Run overnight risk calculations (full VaR, stress tests)

Phase 2: Settlement Processing
  2.1  Settlement instruction generation - Generate settlement messages (SWIFT MT5xx)
  2.2  Netting - Net settlement obligations by counterparty, currency, and CSD
  2.3  Settlement file generation - Create files for custodian/CSD
  2.4  Cash projection - Calculate expected cash movements for the next N days
  2.5  Margin calculation - Calculate margin requirements for cleared positions

Phase 3: Corporate Actions Processing
  3.1  Ex-date processing - Apply corporate actions going ex on T+1
  3.2  Record date processing - Determine entitlements based on positions at record date
  3.3  Payment processing - Book dividend/coupon payments for pay date = T+1
  3.4  Mandatory event processing - Apply splits, mergers, consolidations

Phase 4: Regulatory and Client Reporting
  4.1  Transaction reporting - Generate EMIR, MiFIR, Dodd-Frank transaction reports
  4.2  Position reporting - Generate regulatory position reports (CFTC large trader, SEC 13F)
  4.3  Client reporting - Generate client statements and portfolio reports
  4.4  Internal management reporting - Generate management dashboards and KPIs

Phase 5: System Preparation for Next Day
  5.1  Roll forward dates - Advance the system date to T+1
  5.2  Reference data updates - Load updated instrument master, calendar data
  5.3  Market data preparation - Prime the market data cache for the next trading day
  5.4  Pre-generate SOD files - Prepare position and limit files for the SOD load
  5.5  Archive and purge - Archive intraday data, purge temporary files
```

**Batch monitoring**: Each batch phase has a scheduled start time and an expected completion time. Batch monitoring tools track progress, alert on delays, and provide estimated completion times based on historical run times.

**Batch failure recovery**: If a batch step fails, the system must support:
- **Retry**: Re-run the failed step from the beginning
- **Skip and continue**: Proceed with subsequent steps (if independent) and return to the failed step later
- **Rollback**: Undo the partially-completed step and restore to the pre-step state
- **Manual override**: Allow an operator to manually complete the step and mark it as done

### 6.2 Settlement Processing

Settlement processing converts traded obligations into actual securities and cash movements.

**Settlement lifecycle**:
```
Trade Execution -> Trade Matching -> Settlement Instruction Generation -> Pre-settlement Matching -> Settlement -> Confirmation
```

**Settlement instruction generation**:
1. For each trade settling on T+N, generate settlement instructions
2. Apply netting rules (net buy/sell obligations with the same counterparty, same instrument, same settlement date)
3. Validate settlement instructions against the SSI database
4. Format instructions per the custodian/CSD requirements (SWIFT MT541/MT543 for deliveries, MT542/MT544 for receipts)
5. Submit instructions to the custodian/CSD before their cut-off time

**Settlement cycles by market**:
| Market | Standard Cycle | Notes |
|---|---|---|
| US Equities | T+1 | Changed from T+2 in May 2024 |
| European Equities | T+2 | |
| UK Equities | T+1 | Changed from T+2 in October 2027 (planned) |
| US Treasuries | T+1 | |
| Corporate Bonds | T+2 | Varies by market |
| FX Spot | T+2 (T+1 for CAD, TRY, RUB) | |
| Listed Derivatives | Varies | Daily margining, no final settlement until expiry |
| OTC Derivatives | Varies | Initial margin and variation margin |

### 6.3 Corporate Actions Processing

Corporate actions (CAs) are events initiated by the issuer of a security that affect the holders of that security. They are one of the most complex and error-prone areas of operations.

**Corporate action types**:

| Type | Category | Complexity | Example |
|---|---|---|---|
| Cash dividend | Mandatory | Low | AAPL pays $0.24/share |
| Stock split | Mandatory | Medium | NVDA 10:1 split |
| Merger (cash) | Mandatory | High | Target delisted, cash per share |
| Merger (stock) | Mandatory | High | Target shares converted to acquirer shares |
| Rights issue | Voluntary | High | Holder can subscribe for new shares at discount |
| Tender offer | Voluntary | High | Offer to buy shares at a premium |
| Bond coupon | Mandatory | Low | Semi-annual coupon payment |
| Bond call | Mandatory/Voluntary | Medium | Issuer redeems bond before maturity |
| Spin-off | Mandatory | High | New entity shares distributed to holders |

**Corporate actions processing workflow**:
1. **Notification**: Receive CA notification from data vendors (Bloomberg, DTCC, S&P) or custodian
2. **Scrubbing**: Validate CA details against multiple sources (vendor A vs. vendor B vs. issuer announcement)
3. **Setup**: Configure the CA event in the system (dates, rates, options, election deadlines)
4. **Entitlement calculation**: Determine which positions are entitled based on record date holdings
5. **Election** (for voluntary events): Collect elections from portfolio managers by the deadline
6. **Instruction**: Submit elections/instructions to the custodian by their deadline
7. **Processing**: On the effective date, apply the CA to positions:
   - Adjust quantities (for splits, mergers, spin-offs)
   - Book cash payments (for dividends, coupons, cash mergers)
   - Create new positions (for spin-offs, rights)
   - Close positions (for full redemptions, cash mergers)
8. **Reconciliation**: Verify that the CA was applied correctly by comparing positions and cash before/after
9. **Claims management**: If the firm is entitled to CA proceeds but did not receive them (e.g., because securities were on loan), initiate a claim against the borrower

### 6.4 Data Loads

The trading platform depends on reference data feeds that are loaded in batch.

**Key data feeds**:
| Feed | Source | Frequency | Content |
|---|---|---|---|
| Instrument master | Bloomberg, Refinitiv, exchange | Daily | New listings, delistings, attribute changes |
| Corporate actions | Bloomberg, DTCC, custodian | Daily + intraday | Upcoming and processed corporate actions |
| Closing prices | Exchange, Bloomberg BVAL | Daily | Official settlement/closing prices |
| FX rates | WM/Reuters, Bloomberg | Daily (4pm London fix) | Official closing FX rates for valuation |
| Reference rates | Administrators (SOFR, EURIBOR) | Daily | Benchmark interest rates |
| Counterparty master | Internal, LEI lookup | As needed | New counterparties, KYC updates, credit ratings |
| Holiday calendars | Bloomberg, exchange | Quarterly | Market holidays and trading schedules |
| Regulatory data | Regulators, industry bodies | As needed | Regulation changes, reporting requirement updates |

**Data load validation**: Every data load must be validated:
- Row count vs. expected count
- Checksums on critical fields
- Referential integrity (no orphaned foreign keys)
- Business rule validation (no negative prices, no future dates for historical data)
- Comparison against previous load (flag anomalous changes)

---

## 7. Market Event Handling

### 7.1 Trading Halts

Trading halts occur when an exchange suspends trading in a specific instrument, typically due to pending news, order imbalance, or regulatory concern.

**Halt handling workflow**:

1. **Detection**: The market data feed delivers a halt indicator for the instrument (typically via exchange-specific message types or the FIX SecurityTradingStatus field).
2. **System response**:
   - Mark the instrument as halted in the instrument master
   - Block new order submission for the halted instrument
   - Display halt status prominently on the trading UI
   - Alert traders who have open orders or positions in the instrument
3. **Open order handling**: Orders that were open when the halt was announced:
   - Exchange-held orders remain on the exchange order book (behavior varies by exchange)
   - The system tracks which orders are "frozen" and displays their status
4. **Resume handling**: When the halt lifts:
   - Update instrument status to active
   - Re-enable order entry
   - Notify traders that trading has resumed
   - Display the re-opening price and any indicative price published during the halt
5. **Audit**: All halt events, system responses, and user actions during halts are logged

**Halt types**:
| Halt Type | Typical Duration | Trigger |
|---|---|---|
| News pending (T1) | Minutes to hours | Material news imminent (earnings, M&A) |
| LULD (Limit Up/Limit Down) | 5-10 minutes | Price moves outside LULD bands |
| Volatility interruption | 2-5 minutes | Price moves exceed exchange threshold |
| Regulatory halt | Hours to days | SEC or exchange investigation |
| IPO halt | Until opening auction | New listing, pre-first-trade |
| Circuit breaker (market-wide) | 15 min to full day | Broad market decline (see 7.2) |

### 7.2 Circuit Breakers

Circuit breakers are market-wide trading halts triggered by a significant decline in a benchmark index.

**US market circuit breakers** (as of current rules):

| Level | Trigger | Halt Duration | Reference |
|---|---|---|---|
| Level 1 | S&P 500 declines 7% from prior close | 15-minute halt | Applies if triggered before 3:25 PM ET |
| Level 2 | S&P 500 declines 13% from prior close | 15-minute halt | Applies if triggered before 3:25 PM ET |
| Level 3 | S&P 500 declines 20% from prior close | Market closed for remainder of day | Applies at any time |

**System response to circuit breaker**:
1. Halt all equity order entry across all US venues
2. Notify all traders via system alert and squawk box
3. Cancel or freeze all pending algo orders (algos should not resume automatically)
4. Display circuit breaker status with countdown timer
5. Prepare for high volume when trading resumes (capacity planning)
6. Alert risk management (margin requirements may be recalculated)
7. Log all actions taken during the circuit breaker

### 7.3 Exchange Outages

Exchange outages are unplanned events where an exchange stops functioning.

**Outage response procedure**:

1. **Detection**: FIX session drops, market data stops, or exchange issues an official outage notification
2. **Immediate actions**:
   - Alert all traders who route to the affected exchange
   - Display outage status on the trading UI
   - Redirect the smart order router to alternative venues (if available and appropriate)
   - Track open orders that were on the affected exchange (status unknown)
3. **Order management during outage**:
   - New orders: Route to alternative venues or queue for the affected exchange
   - Open orders: Mark as "status uncertain" until exchange confirms
   - Filled orders: Validate fills received before the outage; be prepared for late fill reports when the exchange recovers
4. **Recovery**:
   - When the exchange comes back online, reconcile all order statuses
   - Resend any orders that were lost during the outage
   - Verify that all fills are accounted for
   - Check for duplicate fills (the exchange may replay messages)
5. **Post-incident review**: After resolution, operations reviews the impact:
   - Were any orders lost?
   - Were any fills missed?
   - What was the financial impact of routing to alternative venues?
   - How can the response be improved?

### 7.4 Market Closures and Early Closes

Markets close for holidays and sometimes close early (e.g., the day before a major holiday or during a national emergency).

**Early close handling**:
1. **Calendar management**: Trading calendars are maintained with regular close times and early close times for every market
2. **Advance notification**: The system alerts traders N days before an early close
3. **Order handling**: GTC orders remain; DAY orders are cancelled at early close time
4. **Algo management**: Algos with end-time parameters must be adjusted for early close (e.g., a VWAP algo set to run until 16:00 must be shortened to 13:00)
5. **Batch schedule**: The overnight batch may start earlier on early close days
6. **Cross-market coordination**: An early close in one market may affect cross-market strategies (e.g., FX hedging for equity positions in a market that closed early)

---

## 8. Manual Intervention Workflows

### 8.1 Manual Trade Entry

Despite the drive toward electronic execution, manual trade entry remains necessary for certain workflows.

**Scenarios requiring manual entry**:
- Voice-traded OTC instruments (bespoke derivatives, illiquid bonds, block trades negotiated by phone)
- Trades executed on platforms not integrated with the OMS
- Historical trade corrections or adjustments
- Inter-entity transfers (moving positions between legal entities)
- Cash bookings (fee payments, margin calls, corporate action proceeds)

**Manual trade entry workflow**:

1. **Entry**: The authorized user enters the trade details via a dedicated manual trade entry form. All fields that are normally auto-populated from electronic execution must be manually entered.
2. **Validation**: The same validation rules apply as for electronic trades (price reasonability, limit checks, compliance checks). However, certain checks may be relaxed for specific manual entry types (e.g., off-market price check for an inter-entity transfer at carrying value).
3. **Four-eyes approval**: All manual trades require approval from a second authorized user before booking. The approver reviews the trade details and confirms they are correct and legitimate.
4. **Booking**: Once approved, the trade is booked and flows through the normal downstream processes.
5. **Documentation**: Manual trades must have supporting documentation attached:
   - For voice trades: Recording reference, counterparty confirmation (email, fax, SWIFT)
   - For corrections: Original trade reference, reason for correction, approval
   - For transfers: Transfer request form, approval from both desks

**Audit requirements**: Manual trades receive heightened scrutiny in compliance surveillance because they bypass the electronic audit trail of normal order flow. The system should flag all manual entries for compliance review.

### 8.2 Trade Amendments

Trade amendments change the economic or non-economic terms of an existing trade after it has been booked.

**Amendment types**:

| Type | Examples | Approval Required |
|---|---|---|
| **Economic amendment** | Price, quantity, notional, settlement date | Four-eyes, desk head, counterparty agreement |
| **Non-economic amendment** | Account, book, strategy tag, trader ID | Four-eyes |
| **SSI amendment** | Settlement instructions | Four-eyes, operations manager |
| **Regulatory amendment** | Reporting flags, LEI, trading capacity | Compliance |

**Amendment workflow**:
1. User requests the amendment, specifying the field(s) to change
2. System displays old value and new value side-by-side
3. System validates the amendment (same rules as new trade entry)
4. Approver reviews and approves
5. System creates a new version of the trade (original version preserved for audit)
6. If the trade has already been confirmed, a cancellation and re-confirmation are sent to the counterparty
7. If the trade has already settled, a correction may require a cash adjustment
8. All amendments are logged with full before/after detail

**Amendment cut-off**: Amendments have time-based restrictions:
- Before confirmation: Relatively straightforward
- After confirmation but before settlement: Requires counterparty agreement
- After settlement: Requires cash adjustment, counterparty agreement, and potentially custodian coordination

### 8.3 Off-Market Trades

Off-market trades are trades executed at a price that is significantly different from the prevailing market price. They are legitimate in certain contexts but are also a red flag for compliance.

**Legitimate off-market scenarios**:
- Inter-entity transfers at carrying value (no market execution, just moving between books)
- Closing out OTC derivatives at a negotiated price (accounting for CVA/DVA, CSA terms)
- Portfolio transfers at a negotiated package price
- Give-up/take-up trades where the give-up price differs from the original execution price

**Off-market trade handling**:
1. System detects that the trade price is outside the configurable tolerance (e.g., >1% from mid-market)
2. System blocks the trade and requires additional justification
3. User provides a reason code (inter-entity transfer, portfolio transfer, etc.) and supporting narrative
4. Compliance is automatically notified for all off-market trades
5. Desk head and operations manager must approve
6. The trade is booked with an "off-market" flag for ongoing surveillance

### 8.4 Voice Trades

Voice trades (phone-negotiated trades) are still common in OTC markets, block trading, and less liquid instruments.

**Voice trade workflow**:
1. **Negotiation**: Trader negotiates with counterparty by phone (all calls recorded on turret system)
2. **Verbal agreement**: Both parties verbally agree on terms (read-back of key terms is standard practice)
3. **Manual entry**: Trader or operations enters the trade into the system
4. **Confirmation**: System generates a confirmation sent to the counterparty's operations team
5. **Matching**: Counterparty confirms the terms, creating a matched trade
6. **Recording link**: The call recording reference is attached to the trade record
7. **Compliance review**: Voice trade activity is sampled for compliance review

**Voice trade risks**:
- Human error in translating verbal terms to system entry
- Delayed entry (trade executed but not entered for hours)
- Dispute risk (different recollection of agreed terms)

**Mitigation**: Read-back procedures, immediate entry SLAs (must be entered within 15 minutes of execution), automatic flagging of voice trades for compliance review.

---

## 9. Client Onboarding for Trading

### 9.1 Account Setup

Client onboarding for trading is a multi-week process involving legal, compliance, credit, operations, and technology teams.

**Account setup workflow**:

**Phase 1: Client Due Diligence (CDD) - Week 1-3**
1. Collect client identification documents (certificate of incorporation, articles of association, director/shareholder registers)
2. Perform Know Your Customer (KYC) checks:
   - Identity verification (directors, beneficial owners, authorized signatories)
   - Sanctions screening (OFAC, EU sanctions, UN sanctions)
   - Adverse media screening
   - Politically Exposed Person (PEP) screening
   - Anti-money laundering (AML) risk assessment
3. Assign a risk rating (low, medium, high, prohibited)
4. Obtain Legal Entity Identifier (LEI) or verify existing LEI
5. Determine client classification (MiFID II: retail, professional, eligible counterparty)

**Phase 2: Legal Documentation - Week 2-4**
1. Execute trading agreements:
   - ISDA Master Agreement (for OTC derivatives)
   - Credit Support Annex (CSA) for collateral management
   - Global Master Repurchase Agreement (GMRA) for repos
   - Master Securities Lending Agreement (MSLA) for securities lending
   - Prime brokerage agreement
   - Give-up agreement (if applicable)
2. Obtain authorized trader list (who at the client can place orders)
3. Obtain authorized settlement instruction signatories

**Phase 3: Credit and Limit Setup - Week 3-4**
1. Credit analysis (financial statement review, credit rating, counterparty risk assessment)
2. Set credit limits:
   - Pre-settlement exposure limit (mark-to-market exposure)
   - Settlement exposure limit (pending settlement amounts)
   - Product-specific limits (FX, rates, credit, equity)
   - Tenor limits (for derivatives)
   - Country limits (for EM exposure)
3. Set margin parameters (initial margin, variation margin, haircuts)
4. Configure netting agreements

**Phase 4: Operational Setup - Week 3-5**
1. Create client entity in the counterparty master
2. Configure settlement instructions (SSIs):
   - Cash correspondent bank details per currency
   - Securities custodian/depository details per market
   - SWIFT BIC codes, account numbers
3. Set up confirmation routing (SWIFT, DTCC, email)
4. Configure market data and research access (if applicable)
5. Set up client portal access (trade reporting, statement access)
6. Test connectivity (FIX session if electronic trading, API access)

**Phase 5: Go-Live - Week 5**
1. Operational readiness review (all systems configured, all documentation signed)
2. Test trade execution (small test trade through full lifecycle)
3. Verify confirmation delivery
4. Verify settlement processing
5. Go-live approval from operations, compliance, and relationship management
6. First trade with the client

### 9.2 Credit Limits

Credit limit management is a continuous process that extends well beyond initial onboarding.

**Credit limit structure**:
```
Client: ABC Fund
  Aggregate Credit Limit: $50M
    Pre-settlement Limit: $30M
      FX: $15M
      Rates: $10M
      Credit: $5M
    Settlement Limit: $20M
      DvP: $15M (lower risk, delivery vs. payment)
      FoP: $5M (higher risk, free of payment)
  Margin Terms:
    Initial Margin: 5% of notional
    Variation Margin: Daily, cash only
    Minimum Transfer Amount: $500K
    Rounding: $100K
```

**Credit limit monitoring**:
- Real-time utilization tracking (pre-trade and post-trade)
- Automated alerts at utilization thresholds (75%, 90%, 100%)
- Intraday mark-to-market of exposure
- What-if analysis (impact of a proposed trade on credit utilization)

### 9.3 Margin Agreements

Margin agreements define how collateral is exchanged between counterparties to mitigate credit risk.

**Margin workflow**:
1. **Calculation**: Each business day, calculate the mark-to-market exposure for each margined relationship
2. **Netting**: Net the exposure across all trades under the netting agreement
3. **Threshold and MTA**: Apply the threshold (exposure below which no margin is required) and minimum transfer amount
4. **Call**: If the net exposure exceeds the threshold + MTA, issue a margin call to the counterparty (or receive one)
5. **Delivery**: Counterparty delivers collateral (cash or eligible securities) by the agreed deadline (typically T+1 for variation margin)
6. **Valuation**: Value received collateral (applying haircuts to securities collateral)
7. **Dispute resolution**: If the counterparty disputes the margin call amount, initiate the dispute resolution procedure defined in the CSA/regulatory framework
8. **Substitution**: If the counterparty wants to substitute one piece of collateral for another, validate the substitution against eligibility criteria

---

## 10. Disaster Recovery Procedures

### 10.1 Disaster Recovery Architecture

A trading platform's disaster recovery (DR) architecture must ensure business continuity during partial or complete failure of the primary site.

**Recovery objectives**:
| Metric | Definition | Target |
|---|---|---|
| **RTO** (Recovery Time Objective) | Maximum acceptable time to restore trading | < 30 minutes for critical functions, < 4 hours for all functions |
| **RPO** (Recovery Point Objective) | Maximum acceptable data loss | < 1 minute (near-zero for order/position data) |
| **MTPD** (Maximum Tolerable Period of Disruption) | Maximum time the business can survive without the system | < 24 hours |

**DR configurations**:

| Configuration | Description | RTO | RPO | Cost |
|---|---|---|---|---|
| **Active-Active** | Both sites handle live traffic simultaneously | Near zero | Zero | Highest |
| **Active-Warm** | DR site has systems running and data replicated, but not serving traffic | 15-30 min | < 1 min | High |
| **Active-Cold** | DR site has hardware but systems are not running | 2-4 hours | Hours (last backup) | Medium |
| **Cloud DR** | DR infrastructure in cloud (AWS, Azure), scaled on demand | 30-60 min | < 5 min | Variable |

**For trading platforms**: Active-Active or Active-Warm is the standard. Active-Cold is insufficient for firms that need to resume trading during the same session.

### 10.2 Failover Testing

Failover testing verifies that the DR site can assume production responsibilities within the defined RTO.

**Test types**:

| Test Type | Frequency | Scope | Impact on Production |
|---|---|---|---|
| **Tabletop exercise** | Quarterly | Review procedures, identify gaps | None |
| **Component failover** | Monthly | Fail over individual components (database, app server) | Minimal |
| **Full site failover** | Semi-annually | Fail over all systems to DR site | Production runs on DR for the test period |
| **Unannounced test** | Annually | DR team is not warned in advance | Measures actual response time |

**Full site failover test procedure**:

1. **Pre-test** (T-1 week):
   - Notify all stakeholders (trading, operations, risk, compliance, IT)
   - Verify DR site readiness (hardware, network, data replication)
   - Document current state (positions, open orders, system configuration)
   - Brief all participants on the test plan and escalation procedures

2. **Failover execution** (Test day):
   - Announce failover start time
   - Stop production systems at primary site (simulate site loss)
   - Activate DR site systems
   - Verify data consistency (positions, orders, reference data match pre-failover state)
   - Verify external connectivity (FIX sessions to exchanges and brokers, market data feeds)
   - Execute test trades on DR site
   - Run P&L and risk calculations on DR site
   - Verify client-facing services (web portal, API, reporting)

3. **Validation checklist**:
   - All trading desks can enter and execute orders
   - Market data is live and accurate
   - Positions match pre-failover positions
   - Risk limits are enforced
   - Compliance checks are active
   - Settlement processing functions
   - Regulatory reporting can be generated
   - Communications (phone, chat, email) are functional

4. **Failback**:
   - Migrate back to primary site
   - Verify data consistency after failback
   - Confirm all systems are nominal on primary site

5. **Post-test review**:
   - Document actual RTO achieved
   - Document any data discrepancies
   - Document any system failures during the test
   - Update procedures based on lessons learned
   - Report results to management and regulators (if required)

### 10.3 Backup Site Activation

When a real disaster occurs (not a test), the activation procedure follows a more urgent path.

**Activation triggers**:
- Physical site loss (fire, flood, power failure, building access denied)
- Network failure (complete loss of connectivity from primary site)
- System failure (cascading failure that cannot be resolved within the RTO)
- Cybersecurity incident (ransomware, data breach requiring system isolation)

**Activation decision chain**:
1. Incident is detected and reported to the on-call operations team
2. Operations assesses severity and estimated time to resolve
3. If estimated resolution time exceeds RTO, operations recommends DR activation
4. DR activation authority (typically CTO, COO, or designated DR coordinator) makes the go/no-go decision
5. DR activation is announced to all stakeholders via the emergency communication system

**During DR operations**:
- Reduced functionality may be acceptable (e.g., only core trading, not all analytics)
- Headcount at DR site may be limited (prioritize critical roles: traders, operations, IT support)
- Communication with counterparties, exchanges, and regulators about the DR event
- Enhanced monitoring of DR site performance
- Regular status updates to management

### 10.4 Communication Protocols

Clear communication during a disaster is as important as the technical failover.

**Communication plan**:

| Audience | Channel | Responsible | Timing |
|---|---|---|---|
| Trading desks | Squawk box, SMS, phone tree | Desk heads | Immediate |
| Operations | SMS, phone tree | Operations manager | Immediate |
| IT team | Incident management system (PagerDuty, ServiceNow) | On-call engineer | Immediate |
| Senior management | SMS, phone call | CTO/COO | Within 5 minutes |
| Exchanges/CCPs | Designated contact, email | Operations | Within 15 minutes |
| Regulators | Designated regulatory contact | Compliance | Within 30 minutes (or per regulatory requirement) |
| Clients | Email, client portal notice | Client services | Within 1 hour |
| Counterparties | Email, phone | Operations | Within 1 hour |
| Media (if applicable) | Press statement | Communications/PR | As needed |

**Communication template** (for counterparties/clients):
```
Subject: [FIRM NAME] - Business Continuity Event Notification

We are writing to inform you that [FIRM NAME] has activated its business 
continuity plan due to [brief description].

Trading operations: [Active / Suspended / Limited]
Expected resolution: [Time estimate]
Settlement processing: [Normal / Delayed]
Contact for urgent matters: [Name, phone, email]

We will provide updates every [frequency]. Please direct any questions 
to [contact details].
```

---

## 11. Intraday Monitoring Checklists and Operational Dashboards

### 11.1 Intraday Monitoring Checklists

Operations and technology teams run scheduled checks throughout the trading day to detect problems before they escalate.

**Pre-Market Checklist** (60-90 minutes before market open):

| # | Check | Owner | Status |
|---|---|---|---|
| 1 | SOD positions loaded and reconciled | Operations | |
| 2 | All FIX sessions connected | IT/Operations | |
| 3 | Market data feeds active and ticking | IT | |
| 4 | Risk limits loaded and active | Risk | |
| 5 | Compliance rules loaded (restricted list, etc.) | Compliance | |
| 6 | Reference data loaded (instruments, calendars) | IT | |
| 7 | Overnight batch completed successfully | IT | |
| 8 | Outstanding breaks reviewed | Operations | |
| 9 | System performance nominal (CPU, memory, latency) | IT | |
| 10 | DR replication current | IT | |
| 11 | Known issues / system changes reviewed | IT/Operations | |
| 12 | Trading readiness sign-off | Operations Manager | |

**Mid-Morning Check** (1-2 hours after market open):

| # | Check | Owner |
|---|---|---|
| 1 | Order flow is normal (no stuck orders, no unusual rejections) | Operations |
| 2 | FIX session health (message counts, sequence numbers, no gaps) | IT |
| 3 | Market data quality (no stale feeds, no anomalous prices) | IT |
| 4 | P&L is calculating correctly (spot-check against manual estimate) | Operations |
| 5 | Risk utilization is within expected ranges | Risk |
| 6 | No unusual compliance alerts | Compliance |
| 7 | Algo execution is performing as expected | Trading |
| 8 | Settlement status for T+0 settlements | Operations |

**Mid-Day Check** (around noon or mid-session):

| # | Check | Owner |
|---|---|---|
| 1 | System resource utilization (trending, not just snapshot) | IT |
| 2 | Trade count vs. historical average (detect anomalies) | Operations |
| 3 | Break count and aging (any new breaks, any aged breaks not progressing) | Operations |
| 4 | Margin call status (any outstanding calls) | Operations |
| 5 | Counterparty settlement status (any expected fails) | Operations |
| 6 | Corporate actions pending for today (any actions not yet processed) | Operations |

**Pre-Close Check** (30-60 minutes before market close):

| # | Check | Owner |
|---|---|---|
| 1 | Open algo orders scheduled to complete by close | Trading |
| 2 | GTC order review (any orders that should be cancelled) | Trading |
| 3 | Allocation instructions received for today's block trades | Operations |
| 4 | Batch processing prerequisites met | IT |
| 5 | EOD pricing sources ready | Operations |
| 6 | Regulatory reporting data complete for the day | Compliance |

**Post-Close Check** (after market close):

| # | Check | Owner |
|---|---|---|
| 1 | All orders cancelled or filled (no unexpected open orders) | Operations |
| 2 | All fills received and matched | Operations |
| 3 | Preliminary P&L calculated and reviewed | Operations/Trading |
| 4 | Allocations completed | Operations |
| 5 | Batch processing initiated | IT |
| 6 | After-hours system maintenance window communicated | IT |

### 11.2 Operational Dashboards

Operational dashboards provide real-time visibility into the health and performance of the trading operation.

**Dashboard 1: System Health**

Displays the real-time status of all platform components:
```
+------------------------------------------------------------------+
| SYSTEM HEALTH DASHBOARD                        2026-04-02 10:35  |
+------------------------------------------------------------------+
| Component            | Status | Latency | Throughput | Errors    |
|---------------------|--------|---------|------------|-----------|
| Order Management     | GREEN  | 2ms     | 450/sec    | 0         |
| Execution Mgmt       | GREEN  | 1ms     | 320/sec    | 0         |
| Risk Engine          | GREEN  | 5ms     | 200/sec    | 0         |
| Position Server      | GREEN  | 3ms     | 150/sec    | 0         |
| Market Data (Eqs)    | GREEN  | <1ms    | 50K/sec    | 0         |
| Market Data (FI)     | AMBER  | 12ms    | 5K/sec     | 3         |
| FIX: NYSE            | GREEN  | Connected| -         | 0         |
| FIX: NASDAQ          | GREEN  | Connected| -         | 0         |
| FIX: CME             | GREEN  | Connected| -         | 0         |
| FIX: Broker A        | GREEN  | Connected| -         | 0         |
| FIX: Broker B        | RED    | Disconn  | -         | ALERT     |
| Database Primary     | GREEN  | 1ms     | -          | 0         |
| Database Replica     | GREEN  | 1ms     | Lag: 0.2s  | 0         |
| DR Replication       | GREEN  | -       | Lag: 0.5s  | 0         |
+------------------------------------------------------------------+
| Alerts: FIX Broker B disconnected at 10:33:12 - auto-reconnect  |
|         Market Data FI latency elevated - investigating          |
+------------------------------------------------------------------+
```

**Dashboard 2: Trading Activity**

Displays real-time trading metrics:
```
+------------------------------------------------------------------+
| TRADING ACTIVITY                               2026-04-02 10:35  |
+------------------------------------------------------------------+
| Metric                          | Today    | Avg (20d) | Delta   |
|---------------------------------|----------|-----------|---------|
| Orders Submitted                | 12,450   | 14,200    | -12%    |
| Orders Filled                   | 8,230    | 9,800     | -16%    |
| Orders Rejected                 | 45       | 30        | +50%    |
| Fill Rate                       | 66.1%    | 69.0%     | -2.9%   |
| Notional Traded (USD equiv)     | $2.4B    | $3.1B     | -23%    |
| Avg Order-to-Fill Latency       | 45ms     | 42ms      | +7%     |
| Algo Orders Active              | 34       | 28        | +21%    |
| Manual Trades Entered           | 7        | 5         | +40%    |
+------------------------------------------------------------------+
| By Desk:                                                         |
|   US Equities:  5,200 orders | $1.1B notional | P&L: +$450K     |
|   US Rates:     2,100 orders | $800M notional | P&L: -$120K     |
|   FX:           3,400 orders | $350M notional | P&L: +$85K      |
|   Credit:       1,750 orders | $150M notional | P&L: +$210K     |
+------------------------------------------------------------------+
```

**Dashboard 3: Risk Overview**

Displays real-time risk metrics:
```
+------------------------------------------------------------------+
| RISK OVERVIEW                                  2026-04-02 10:35  |
+------------------------------------------------------------------+
| Desk         | VaR Util | P&L Today | Loss Limit | Greeks       |
|--------------|----------|-----------|------------|--------------|
| US Equities  | 72%      | +$450K    | 35% used   | Delta: 2.1M  |
| US Rates     | 85%      | -$120K    | 55% used   | DV01: $45K   |
| FX           | 45%      | +$85K     | 12% used   | -            |
| Credit       | 61%      | +$210K    | 22% used   | CS01: $15K   |
| TOTAL FIRM   | 68%      | +$625K    | 28% used   | -            |
+------------------------------------------------------------------+
| Alerts:                                                          |
|   US Rates VaR at 85% - approaching limit                       |
|   Trader JSmith: intraday loss at 55% of limit                  |
+------------------------------------------------------------------+
```

**Dashboard 4: Operations and Settlement**

Displays operational status:
```
+------------------------------------------------------------------+
| OPERATIONS DASHBOARD                           2026-04-02 10:35  |
+------------------------------------------------------------------+
| Settlement Status (T+0):                                         |
|   Pending: 234 trades ($450M)                                    |
|   Settled: 189 trades ($320M)                                    |
|   Failed:  12 trades ($28M) [see details]                        |
|                                                                  |
| Trade Matching:                                                  |
|   Matched: 1,245 (94.2%)                                        |
|   Alleged: 52 (3.9%)                                             |
|   Disputed: 8 (0.6%)                                             |
|   Unmatched: 17 (1.3%)                                           |
|                                                                  |
| Breaks:                                                          |
|   New today: 14                                                  |
|   Outstanding (1-3 days): 23                                     |
|   Outstanding (>3 days): 8 [ESCALATED]                           |
|   Resolved today: 19                                             |
|                                                                  |
| Allocations:                                                     |
|   Pending: 5 block trades (awaiting PM instructions)             |
|   Completed: 42 block trades                                     |
|   Late: 2 block trades [ALERT - approaching custodian cutoff]    |
|                                                                  |
| Margin:                                                          |
|   Calls issued: 3 ($12M total)                                   |
|   Calls received: 2 ($8M total)                                  |
|   Calls outstanding: 1 ($4M - counterparty DEF, due by 14:00)   |
+------------------------------------------------------------------+
```

**Dashboard 5: Compliance Monitoring**

Displays compliance and surveillance status:
```
+------------------------------------------------------------------+
| COMPLIANCE DASHBOARD                           2026-04-02 10:35  |
+------------------------------------------------------------------+
| Pre-Trade Checks Today:                                          |
|   Total evaluated: 12,450                                        |
|   Passed: 12,380 (99.4%)                                        |
|   Soft blocks (overridden): 25 (0.2%)                            |
|   Hard blocks: 45 (0.4%)                                         |
|     Restricted list: 3                                           |
|     Position limit: 12                                           |
|     Mandate breach: 8                                             |
|     Risk limit: 22                                               |
|                                                                  |
| Surveillance Alerts:                                             |
|   New alerts today: 7                                            |
|   Under investigation: 15                                        |
|   Closed today: 4                                                |
|   Alert types: Spoofing(2), Layering(1), Front-running(1),      |
|                Wash trade(1), Unusual volume(2)                   |
|                                                                  |
| Restricted List:                                                 |
|   Active restrictions: 34 instruments                            |
|   Added today: 1 (XYZ Corp - pending M&A announcement)          |
|   Removed today: 0                                               |
|                                                                  |
| Regulatory Reporting:                                            |
|   T-1 EMIR reports: Submitted (1,234 trades)                    |
|   T-1 MiFIR reports: Submitted (892 trades)                     |
|   Rejections from regulator: 3 [investigating]                   |
+------------------------------------------------------------------+
```

### 11.3 Alert Management

Alerts generated by dashboards and monitoring systems must be managed systematically to prevent alert fatigue and ensure critical issues are addressed.

**Alert severity levels**:
| Level | Description | Response | Example |
|---|---|---|---|
| **Critical** | Trading is impacted or at imminent risk | Immediate response, all-hands | Exchange connectivity lost, risk engine down |
| **High** | Significant operational issue | Response within 15 minutes | Settlement fails exceeding threshold, VaR limit breach |
| **Medium** | Issue requiring attention | Response within 1 hour | Unmatched trade approaching settlement, elevated rejection rate |
| **Low** | Informational or minor issue | Response within 4 hours | New break detected, minor data quality issue |

**Alert lifecycle**:
```
Generated -> Acknowledged -> Assigned -> Under Investigation -> Resolved -> Closed
```

**Alert routing rules**:
- System health alerts route to IT on-call
- Risk alerts route to the risk manager and desk head
- Compliance alerts route to the compliance officer
- Settlement alerts route to operations
- Multiple unresolved alerts of the same type trigger escalation to management

**Alert suppression**: To prevent alert fatigue, the system should support:
- Grouping related alerts (e.g., 50 settlement failures for the same counterparty become one alert)
- Suppressing known issues (e.g., if a FIX session is down for planned maintenance, suppress the connectivity alert)
- Escalating alerts that have been acknowledged but not resolved within the SLA
- Daily alert summary reports showing alert counts by type, severity, and resolution time
