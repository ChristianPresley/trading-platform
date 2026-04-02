## 3. Execution Blotter

The execution blotter shows individual fills (execution reports) rather than parent orders.

### 3.1 Columns

| Column | Description | Example |
|---|---|---|
| Exec ID | Unique execution ID (FIX tag 17) | EXEC-20260402-004821 |
| Time | Execution timestamp (microsecond precision) | 09:31:04.237482 |
| Order ID | Parent order reference | ORD-20260402-000147 |
| Symbol | Instrument | AAPL |
| Side | Buy / Sell | Buy |
| Fill Qty | Shares filled in this execution | 400 |
| Fill Price | Price of this fill | 187.42 |
| Cumulative Qty | Running total fills for parent order | 3,200 |
| Leaves Qty | Remaining on parent order | 1,800 |
| Avg Price | VWAP across all fills for parent order | 187.43 |
| Venue | Execution venue (exchange/ECN/dark pool) | ARCA |
| Liquidity | Add / Remove liquidity indicator | Add |
| Commission | Per-fill commission | $0.80 |
| Fee | Exchange fee or rebate | -$0.52 (rebate) |
| Net Amount | Fill Qty * Fill Price +/- fees | $74,968.80 |
| Exec Type | New, Partial Fill, Fill, Cancelled, Replaced | Partial Fill |
| Contra Broker | Counterparty (if available) | GSCO |
| Settlement Date | Expected settlement date | 2026-04-03 |

### 3.2 Partial Fills and Average Price

When an order receives multiple partial fills, the execution blotter displays each fill individually. A summary row (parent order level) shows:

- **Average Price Calculation:** `Avg Price = SUM(Fill Qty_i * Fill Price_i) / SUM(Fill Qty_i)`
- **Example:**

  | Fill # | Qty | Price | Cumulative Qty | Avg Price |
  |---|---|---|---|---|
  | 1 | 1,000 | 187.40 | 1,000 | 187.4000 |
  | 2 | 800 | 187.42 | 1,800 | 187.4089 |
  | 3 | 1,000 | 187.45 | 2,800 | 187.4229 |
  | 4 | 400 | 187.50 | 3,200 | 187.4328 |

### 3.3 Execution Quality Metrics (inline)

Some execution blotters display per-fill benchmarks:

- **Arrival Price Slippage:** Fill price vs. mid-price at order arrival time.
- **VWAP Slippage:** Fill price vs. interval VWAP.
- **Implementation Shortfall:** Realized cost vs. decision price.
- **Spread Capture:** How much of the bid-ask spread was captured vs. paid.

---

## 4. Position Blotter

The position blotter displays current holdings and real-time profit and loss.

### 4.1 Columns

| Column | Description | Example |
|---|---|---|
| Symbol | Instrument ticker | AAPL |
| Description | Full instrument name | Apple Inc. |
| Account | Trading account | MAIN-EQ-001 |
| Position | Net quantity (positive = long, negative = short) | 12,500 |
| Avg Cost | Average cost basis per share | 185.32 |
| Last Price | Current market price (real-time) | 187.50 |
| Market Value | Position * Last Price | $2,343,750.00 |
| Cost Basis | Position * Avg Cost | $2,316,500.00 |
| Unrealized P&L | Market Value - Cost Basis | +$27,250.00 |
| Unrealized P&L % | Unrealized P&L / Cost Basis | +1.18% |
| Realized P&L | P&L from closed trades (today) | +$4,200.00 |
| Total P&L | Unrealized + Realized | +$31,450.00 |
| Day P&L | Change in value from previous close | +$15,600.00 |
| Day Change % | Day P&L / previous close value | +0.67% |
| Notional Exposure | Absolute market value | $2,343,750.00 |
| % of Portfolio | Weight in overall portfolio | 3.2% |
| Beta-Adj Exposure | Position exposure * beta | $2,578,125.00 |
| Sector | GICS sector classification | Technology |
| Open Orders | Count of active orders for this symbol | 2 |
| Volume Today | Shares traded today in this name | 8,400 |

### 4.2 Live P&L Updates

- P&L cells flash green for positive ticks, red for negative ticks.
- Flash duration is configurable (typically 200-500ms).
- P&L columns can be toggled between absolute ($) and percentage (%) modes.
- Font weight or color intensity can scale with magnitude of change.
- Total portfolio P&L displayed in a summary row pinned at the bottom.

### 4.3 Exposure Views

**By dimension:**

- **Net exposure:** Long market value minus short market value.
- **Gross exposure:** Long market value plus absolute short market value.
- **Net/Gross ratio:** Indicates directionality.

**Grouping views:**

- By Sector (GICS levels 1-4)
- By Country / Region
- By Currency
- By Asset Class
- By Strategy / Sub-portfolio
- By Market Cap bucket (Large, Mid, Small, Micro)

### 4.4 Heat Maps

Position heat maps use a grid or treemap layout:

- **Size** of each cell is proportional to position notional value.
- **Color** represents P&L performance: deep green (large gain) through white (flat) to deep red (large loss).
- **Interaction:** Hover shows tooltip with position details; click navigates to position detail or chart.
- **Grouping:** Cells can be grouped by sector, geography, or strategy.
