## 1. Order Entry Tickets

Order entry tickets are the primary mechanism through which a trader submits instructions to buy, sell, or modify financial instruments. Different asset classes demand different ticket layouts.

### 1.1 Single-Stock Equity Ticket

A single-stock equity ticket is the most common order entry form.

**Standard fields:**

| Field | Description | Typical Control |
|---|---|---|
| Symbol | Ticker lookup with typeahead | Autocomplete text input |
| Side | Buy / Sell / Sell Short / Buy to Cover | Toggle button group |
| Quantity | Number of shares | Numeric spinner with lot presets (100, 500, 1000) |
| Order Type | Market, Limit, Stop, Stop-Limit, MOC, LOC, Peg | Dropdown / segmented control |
| Limit Price | Required for limit/stop-limit orders | Numeric input snapped to tick size |
| Stop Price | Required for stop/stop-limit orders | Numeric input |
| Time in Force | DAY, GTC, IOC, FOK, GTD, OPG (at open), CLO (at close) | Dropdown |
| Account | Trading account or allocation profile | Dropdown |
| Destination | Exchange/venue routing (SMART, NYSE, ARCA, BATS, EDGX, dark pools) | Dropdown |
| Display Quantity | Iceberg/reserve quantity | Numeric input (optional) |
| Algo | Algorithmic strategy (VWAP, TWAP, POV, IS, Arrival Price) | Dropdown with sub-parameters |

**Algo sub-parameters panel** (appears when an algo is selected):

- Start time / End time
- Participation rate (e.g., 5-25% of volume)
- Urgency level (Passive / Neutral / Aggressive)
- Dark pool inclusion (Yes / No)
- Limit price / Would price
- Min fill size

**Validation rules:**

- Limit price required when order type is Limit or Stop-Limit.
- Quantity must be positive integer; fractional shares on supported venues only.
- Fat-finger checks: reject if quantity exceeds N-day ADV by configurable threshold (e.g., >50% of ADV).
- Price reasonability: reject if limit price deviates from NBBO by more than a configurable percentage.
- Short-sell locate check: block Sell Short unless locate confirmed.

### 1.2 Multi-Leg / Options Ticket

Used for options strategies: spreads, strangles, straddles, condors, butterflies, ratio spreads.

**Additional fields beyond single-stock:**

| Field | Description |
|---|---|
| Strategy Template | Vertical Spread, Calendar Spread, Iron Condor, Butterfly, Custom |
| Legs Table | Each row: Side, Quantity Ratio, Expiration, Strike, Put/Call, Price |
| Net Debit/Credit | Calculated net premium |
| Margin Requirement | Real-time margin estimate |
| Greeks Display | Net Delta, Gamma, Theta, Vega for the combined position |
| Exercise Style | American / European |

**Leg builder UX:**

- Click "Add Leg" to insert a row.
- Option chain matrix (strikes on Y-axis, expirations on X-axis) for click-to-add.
- Drag legs to reorder.
- Ratio column allows 1:2, 1:1:1:1 combinations.
- P&L payoff diagram rendered inline showing profit/loss at expiration across underlying prices.

### 1.3 FX Ticket

Foreign exchange tickets handle spot, forward, swap, and NDF (non-deliverable forward) transactions.

**FX-specific fields:**

| Field | Description |
|---|---|
| Currency Pair | e.g., EUR/USD, USD/JPY; base/quote convention |
| Deal Type | Spot, Forward, Swap, NDF |
| Amount | Notional in base or quote currency (toggle) |
| Rate | Limit rate (for limit orders) |
| Value Date | Spot date (T+2 for most pairs, T+1 for USD/CAD), forward date, or broken date |
| Far Leg (Swap) | Far date, far amount, swap points |
| Fixing Source | For NDFs: WM/Reuters, EMTA, Central Bank |
| Settlement Instructions | Standard settlement (SSI) or special |
| Tenor Shortcuts | O/N, T/N, S/N, 1W, 2W, 1M, 2M, 3M, 6M, 1Y, 2Y |

**Streaming price panel:** Two-sided quote showing bid/ask updating in real time. Trader clicks bid to sell, ask to buy. Spread displayed in pips.

### 1.4 Fixed Income Ticket

Covers government bonds, corporate bonds, municipal bonds, and structured products.

**Fixed income-specific fields:**

| Field | Description |
|---|---|
| Identifier | CUSIP, ISIN, or SEDOL |
| Side | Buy / Sell |
| Quantity | Face value / Par amount (e.g., $1,000,000 face) |
| Price Type | Price (clean), Yield, Spread to benchmark, OAS |
| Price / Yield | Depending on price type |
| Benchmark | On-the-run Treasury, swap rate, SOFR |
| Settlement Date | T+1 for Treasuries, T+2 for corporates |
| Accrued Interest | Auto-calculated, displayed read-only |
| All-In Price | Clean price + accrued (dirty price) |
| RFQ Mode | Request for Quote to multiple dealers |

**RFQ workflow:** Trader selects counterparties (3-5 dealers), sends inquiry, receives streaming quotes, clicks to execute best quote. Quote competition displayed as a ranked table with color coding (best = green, others = yellow/gray).

### 1.5 Quick-Trade vs. Full Ticket

| Aspect | Quick Trade | Full Ticket |
|---|---|---|
| Layout | Single row or floating mini-form | Full dialog / panel |
| Fields shown | Symbol, Side, Qty, Type, Price | All fields including algos, allocation, special instructions |
| Use case | Rapid execution, scalping, simple orders | Complex orders, multi-leg, allocations |
| Invocation | Click bid/ask on watchlist, hotkey | Menu, toolbar button, right-click context menu |
| Confirmation | Optional (configurable: 1-click trading) | Always shown with order summary |

### 1.6 Keyboard Shortcuts for Order Entry

| Shortcut | Action |
|---|---|
| `F2` or `/` | Focus symbol search |
| `B` | Set side to Buy |
| `S` | Set side to Sell |
| `Tab` | Move to next field |
| `Shift+Tab` | Move to previous field |
| `Enter` | Submit order |
| `Escape` | Cancel / close ticket |
| `Ctrl+Shift+N` | New order ticket |
| `+` / `-` | Increment / decrement price by tick size |
| `Ctrl+Up/Down` | Increment / decrement quantity by lot size |

---

## 2. Trading Blotter / Order Blotter

The order blotter is the master ledger of all orders placed during the trading session (and optionally historical orders). It provides real-time status tracking from submission through completion.

### 2.1 Standard Columns

| Column | Description | Example Values |
|---|---|---|
| Order ID | Internal unique identifier | ORD-20260402-000147 |
| Cl Ord ID | Client order ID (FIX tag 11) | CLORD-1680422400-001 |
| Time | Order submission timestamp | 09:31:04.237 |
| Last Update | Most recent status change timestamp | 09:31:04.892 |
| Symbol | Instrument ticker | AAPL |
| Side | Buy / Sell / Short | Buy |
| Qty | Total order quantity | 5,000 |
| Filled Qty | Cumulative filled quantity | 3,200 |
| Remaining Qty | Qty minus Filled Qty | 1,800 |
| Order Type | Market, Limit, Stop, etc. | Limit |
| Limit Price | Limit price if applicable | 187.50 |
| Stop Price | Stop trigger price | -- |
| Avg Fill Price | Volume-weighted average fill price | 187.43 |
| TIF | Time in force | DAY |
| Status | Order status (FIX OrdStatus) | Partially Filled |
| Account | Trading account | MAIN-EQ-001 |
| Destination | Routing venue | SMART |
| Algo | Algo name if applicable | VWAP |
| % Complete | Filled Qty / Qty as percentage | 64.0% |
| Trader | Trader ID or name | CPRESLEY |
| Desk | Trading desk | US Equities |
| Text | Free-text notes | "Stay passive" |

### 2.2 Status Color Coding

| Status | Color | Hex Example |
|---|---|---|
| New / Pending New | Light blue | `#B3D9FF` |
| Acknowledged | Blue | `#4A90D9` |
| Partially Filled | Yellow / Amber | `#FFD700` |
| Filled | Green | `#28A745` |
| Cancelled | Gray | `#999999` |
| Rejected | Red | `#DC3545` |
| Expired | Dark gray | `#666666` |
| Replaced (amended) | Purple | `#8B5CF6` |
| Pending Cancel | Orange | `#FFA500` |
| Pending Replace | Light orange | `#FFB347` |
| Suspended | Brown | `#8B4513` |

### 2.3 Filtering and Grouping

**Filter controls:**

- Side filter: All / Buy / Sell
- Status filter: Active Only / Completed / All (toggle chips)
- Account filter: multi-select dropdown
- Symbol filter: typeahead search
- Date range: date pickers for start/end
- Trader filter: multi-select (for desk heads managing multiple traders)
- Free-text search: searches across symbol, order ID, notes

**Grouping options:**

- Group by Symbol (all orders for same name together)
- Group by Account
- Group by Status
- Group by Trader
- Group by Algo
- Nested grouping (e.g., Account > Symbol > Status)

**Sorting:** Click column header to sort ascending; click again for descending. Hold `Shift` and click additional columns for multi-column sort. Sort indicator arrows shown in header.

### 2.4 Real-Time Updates

- New orders appear at top (or sorted position) with a brief highlight flash (e.g., 500ms yellow flash).
- Status changes animate the status cell with a color transition.
- Fill quantity updates in real time; progress bar or fill percentage column animates.
- Sound alerts configurable per status change (fill sound, reject sound).
- Update frequency: order blotter typically receives FIX execution reports and updates within 1-5ms of receipt.

### 2.5 Context Menu Actions

Right-click on an order row to access:

- Cancel Order
- Cancel/Replace (amend quantity or price)
- View Execution Details
- View Audit Trail
- Duplicate Order (pre-fill a new ticket)
- Add to Watchlist
- View Chart for Symbol
- Copy Row to Clipboard
- Export Selected Orders to CSV
