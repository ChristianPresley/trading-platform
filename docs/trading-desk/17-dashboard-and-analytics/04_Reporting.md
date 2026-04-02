## Reporting

### 4.1 End-of-Day Reports

**Daily P&L report:**

- Summary: net P&L, realized, unrealized, fees/commissions.
- P&L by strategy, trader, sector, instrument.
- Top 10 winners and losers (positions).
- Comparison to prior day and MTD/YTD running totals.
- Format: PDF or HTML email, auto-generated at configurable time (e.g., 16:30 ET).

**Daily position report:**

- All positions as of close with market values, weights, and cost basis.
- New positions opened today.
- Positions closed today.
- Cash balance and margin usage.

**Daily risk report:**

- End-of-day VaR, stress test results.
- Limit utilization summary.
- Limit breaches (if any) with explanation.
- Largest risk contributors.

**Trade blotter report:**

- All orders and executions for the day.
- Columns match the blotter UI (see Trading UI Components doc).
- Exportable as CSV, XLSX, or PDF.

### 4.2 Trade Confirmations

Generated per trade or per allocation for client-facing or internal records.

**Confirmation fields:**

| Field | Description |
|---|---|
| Confirmation Number | Unique identifier |
| Trade Date | Execution date |
| Settlement Date | Settlement date |
| Account | Account name/number |
| Symbol / CUSIP / ISIN | Instrument identifier |
| Description | Full security description |
| Side | Bought / Sold |
| Quantity | Amount traded |
| Price | Execution price |
| Gross Amount | Quantity * Price |
| Commission | Broker commission |
| Fees | Exchange and regulatory fees |
| Net Amount | Gross +/- commission +/- fees |
| Counterparty | Executing broker / venue |
| Settlement Instructions | Delivery vs. payment details |

**Delivery:** Email to client, uploaded to client portal, stored in document management system.

### 4.3 Regulatory Reports

| Report | Regulation | Frequency | Description |
|---|---|---|---|
| Large Trader Report (Form 13H) | SEC Rule 13h-1 | Annual + event-driven | Traders exceeding NMS volume thresholds |
| Form 13F | SEC | Quarterly | Institutional holdings over $100M |
| Schedule 13D/13G | SEC | Event-driven | Beneficial ownership > 5% of a class |
| Consolidated Audit Trail (CAT) | SEC/FINRA | Daily | Order lifecycle events for NMS securities |
| Transaction Reporting (MiFID II) | ESMA | Real-time (T+1) | All transactions in EU instruments |
| EMIR Trade Reporting | ESMA | T+1 | All OTC derivative transactions |
| Short Interest Reporting | FINRA | Bi-monthly | Short positions in all equity securities |
| Blue Sheet (EBS) | SEC/FINRA | On-demand | Detailed trading records upon regulatory request |
| Best Execution Report (RTS 28) | MiFID II | Annual | Top 5 venues per instrument class |
| Order Execution Quality (RTS 27) | MiFID II | Quarterly | Execution quality statistics per venue |

**Report generation:**

- Automated data extraction from order management and execution systems.
- Validation checks: completeness, consistency, format compliance.
- Audit trail of report generation, review, and submission.
- Exception queue for records failing validation.

### 4.4 Client Reports

**For asset managers and hedge funds reporting to investors/allocators:**

| Report | Frequency | Content |
|---|---|---|
| Monthly Performance Letter | Monthly | NAV, returns (gross/net), benchmark comparison, commentary |
| Quarterly Factsheet | Quarterly | Performance, top holdings, sector allocation, risk stats |
| Annual Report | Annually | Full performance review, audited financials reference |
| Risk Report | Monthly/Quarterly | VaR, drawdown, Sharpe, Sortino, exposure breakdowns |
| Holdings Transparency Report | Monthly/Quarterly | Full or partial holdings disclosure |
| Capital Account Statement | Monthly | Investor-specific NAV, P&L, management/performance fees |

**Formatting:** Branded PDF templates with charts and tables. White-label support for multi-fund administrators.
