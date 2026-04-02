## End-of-Day Procedures

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
