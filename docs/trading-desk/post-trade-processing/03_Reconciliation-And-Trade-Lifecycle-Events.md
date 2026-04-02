## 5. Reconciliation

Reconciliation is the process of comparing two sets of records to verify that they are in agreement. In the trading context, reconciliation covers trade data, position data, and cash data across internal systems and external counterparts (custodians, prime brokers, clearing houses, counterparties, fund administrators).

### 5.1 Trade Reconciliation

Comparison of internally booked trades against external confirmations and reports.

**Sources compared:**

- Internal OMS/EMS trade records vs. broker/dealer confirmations
- Internal trade records vs. exchange/venue trade reports
- Internal trade records vs. clearing house/CCP records
- Internal trade records vs. custodian trade records

**Common breaks (discrepancies):**

- Missing trades (trade in one system but not the other)
- Quantity mismatches
- Price mismatches (often due to rounding, currency conversion, or accrued interest calculations)
- Settlement date mismatches
- Commission/fee discrepancies
- Incorrect security identification
- Incorrect counterparty/account attribution

**Trade reconciliation timing:** Ideally performed intraday (real-time matching) and definitively on T+0 evening to support T+1 settlement timelines. Any breaks must be resolved before settlement date.

### 5.2 Position Reconciliation

Comparison of internally held position records against external position statements.

**Key position reconciliation dimensions:**

- **Quantity reconciliation:** Number of shares, units, contracts, or notional held in each security per account.
- **Market value reconciliation:** Agreeing on the mark-to-market value of positions (requires agreeing on pricing sources and valuation methodology).
- **Settled vs. traded position reconciliation:** Distinguishing between positions based on trade-date records (which include unsettled trades) and settlement-date records (which reflect only settled transactions). Both must reconcile against the corresponding view in the external system.
- **Tax lot reconciliation:** Verifying that the cost basis, acquisition date, and tax lot structure of each position agrees between the firm's records and the custodian/fund administrator.

**Frequency:** Daily position reconciliation is the industry standard. Intraday position reconciliation (real-time or near-real-time) is increasingly implemented for risk management purposes.

**Position breaks resolution:**

- Investigate whether the break is caused by a timing difference (a trade that has been booked internally but not yet reflected externally, or vice versa).
- Identify whether the break is due to a failed settlement, a missing or duplicate trade, or a corporate action processing difference.
- Escalation procedures with defined timelines (e.g., breaks over $X must be escalated to a supervisor within Y hours).

### 5.3 Cash Reconciliation

Comparison of internal cash records against bank and custodian cash statements.

**Cash reconciliation includes:**

- **Trade settlement cash flows:** Expected debits and credits from trade settlements.
- **Income (dividends, interest, coupons):** Expected and actual income receipts compared against entitlement calculations.
- **Corporate action cash flows:** Merger consideration, tender offer payments, return of capital.
- **Fees and commissions:** Broker commissions, custody fees, management fees, other charges.
- **Margin cash flows:** Variation margin payments, initial margin calls and returns.
- **FX settlements:** Currency conversion cash flows, including CLS (Continuous Linked Settlement) settlements.
- **Funding and financing:** Repo proceeds and repayments, securities lending collateral flows.

**Cash break resolution:** Similar to position breaks — investigate timing differences, missing bookings, duplicate entries, or incorrect amounts. Cash breaks can have significant financial impact (failed interest payments, overdraft charges) and must be resolved promptly.

### 5.4 Breaks Management

A robust reconciliation system includes a breaks management workflow:

- **Automated matching:** Rules-based matching of records with configurable tolerances and matching algorithms (exact match, fuzzy match, one-to-many, many-to-many).
- **Break categorization:** Automatic classification of breaks by type (missing record, quantity difference, price difference, etc.) and expected resolution path.
- **Break aging:** Tracking how long each break has been outstanding, with escalation triggers at configurable aging thresholds (e.g., T+1, T+3, T+5).
- **Root cause analysis:** Identifying systemic issues that cause recurring breaks (e.g., a misconfigured interface, a consistent corporate action processing lag, or a specific counterparty that frequently submits incorrect data).
- **Dashboards and KPIs:** Match rates, break counts and aging, resolution times, and trend analysis. Target match rates for highly automated processes: 95%+ auto-match rate before manual intervention.
- **Regulatory requirements:** MiFID II organizational requirements (Article 16) and CASS (FCA Client Assets Sourcebook) require regular reconciliation of client assets and client money.

**Reconciliation platforms:** SmartStream TLM, Broadridge, Gresham Clareti, Duco, Bloomberg AIM, and custom-built solutions using data comparison engines.

---

## 6. Trade Lifecycle Events

After initial booking, trades may undergo various lifecycle events that must be accurately captured, communicated, and settled.

### 6.1 Amendments

An amendment modifies one or more economic terms of an existing trade.

**Common amendment scenarios:**

- Price correction (e.g., correcting a miskeyed price)
- Quantity correction
- Settlement date change
- Account re-allocation (moving a trade from one account to another)
- Settlement instruction change

**Amendment workflow:**

1. The requesting party submits an amendment request (via OMS, email, or phone).
2. The counterparty must agree to the amendment (bilateral agreement is required for confirmed trades).
3. Both sides update their internal records.
4. If the trade has already been submitted for clearing or settlement, the amendment must also be reflected at the CCP/CSD level, which may require cancellation and rebook.
5. Audit trail must capture the original terms, the amended terms, the reason for amendment, and the identities of the individuals who approved the change.
6. Regulatory reports may need to be amended or supplemented (e.g., EMIR action type "Modification," MiFIR amendment reporting).

### 6.2 Cancellations

A cancellation removes a trade from the books entirely.

**Cancellation reasons:**

- Trade was executed in error
- Trade was duplicated
- Counterparty does not recognize the trade (DK — Don't Know)
- Regulatory requirement (e.g., erroneous execution broken by the exchange)

**Cancellation workflow:**

1. Cancellation request submitted with reason code and supporting documentation.
2. Counterparty agreement required (unless the exchange has already broken the trade under clearly erroneous execution rules).
3. All downstream systems must be notified: clearing, settlement, accounting, risk, regulatory reporting.
4. If the trade has already settled, a cancellation may require a reversal trade to unwind the settlement.
5. P&L impact must be calculated and reflected.
6. Regulatory reports must be updated: EMIR action type "Cancellation," MiFIR cancellation flag, CAT cancel event.

### 6.3 Corrections

A correction is functionally similar to a cancel-and-rebook: the original trade is canceled and a new trade with corrected terms is booked.

**Distinction from amendment:**

- Amendments modify in place, preserving the original trade ID and history.
- Corrections create a new trade with a new trade ID, linked to the original via a reference. The original trade is canceled.
- The choice between amendment and correction often depends on the downstream system capabilities and the nature of the change (minor field changes vs. material economic changes).

### 6.4 Late Trades

Late trades are trades booked after the standard end-of-day processing cutoff, often due to late reporting by the execution venue, time zone differences, or operational delays.

**Challenges:**

- Late trades may miss the T+0 reconciliation cycle, creating breaks that persist until the trade is booked.
- Under T+1 settlement, late trades have minimal time to complete confirmation, affirmation, and settlement instruction delivery before settlement date.
- P&L and risk reports for the trade date may need to be restated.
- NAV (Net Asset Value) calculations for funds may be affected if the late trade is material.

**Controls:**

- Late trade monitoring dashboards tracking the number and value of trades booked after various cutoff times.
- Root cause analysis to identify why trades are arriving late and implement corrective measures.
- Expedited processing workflows for late trades to accelerate confirmation and settlement.
- Tolerance policies for NAV impact (e.g., if a late trade would change NAV by less than 1 basis point, it may be reflected in the next day's NAV rather than requiring a restatement).
