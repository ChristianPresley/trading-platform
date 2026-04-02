# Trading User Interface Components

Comprehensive reference for UI components found on professional trading desks, covering order entry, blotters, market data, charting, news, alerts, workspace management, and keyboard-driven workflows.

---

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

---

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

---

## 5. Market Data Displays

### 5.1 Watchlists

A watchlist is a configurable table of instruments with streaming market data.

**Standard columns:**

| Column | Description |
|---|---|
| Symbol | Ticker |
| Last | Last trade price |
| Change | Absolute change from previous close |
| Change % | Percentage change from previous close |
| Bid | Best bid price |
| Bid Size | Best bid size (displayed in round lots or shares) |
| Ask | Best ask price |
| Ask Size | Best ask size |
| Spread | Ask - Bid (or in basis points for fixed income) |
| Volume | Cumulative volume today |
| VWAP | Volume-weighted average price |
| Open | Opening price |
| High | Day high |
| Low | Day low |
| Prev Close | Previous session close |
| 52W High | 52-week high |
| 52W Low | 52-week low |
| Market Cap | Market capitalization |

**Watchlist features:**

- Multiple named watchlists (tabs).
- Drag-and-drop reordering.
- Right-click to trade, chart, or view news for a symbol.
- Row highlighting: configurable thresholds (e.g., flash row when price crosses a level).
- Conditional formatting: color cells based on value ranges.
- Symbol lookup with typeahead supporting ticker, name, CUSIP, ISIN.
- Import/export watchlists from CSV.
- Sorted columns with real-time re-sorting (optional; can be distracting so often toggled off).

### 5.2 Quote Boards

Quote boards are compact, tile-based layouts optimized for monitoring many instruments at a glance.

**Tile contents:**

- Symbol and short name
- Last price (large font)
- Change and Change % (color-coded green/red)
- Bid/Ask
- Mini sparkline chart (last N minutes)

**Layout:** Grid of tiles, typically 4-8 columns wide, scrollable. Tiles can be sized Small (price only), Medium (price + change), or Large (price + change + bid/ask + sparkline).

### 5.3 Market Depth / Level 2 Display

Shows the full order book beyond the best bid and offer.

**Layout:**

```
         BID                    ASK
Price     Size   Orders   Price     Size   Orders
187.49    1,200  3        187.50    800    2
187.48    3,500  7        187.51    2,100  5
187.47    2,800  4        187.52    1,500  3
187.46    5,000  12       187.53    4,200  8
187.45    1,100  2        187.54    900    1
187.44    8,200  15       187.55    6,300  11
187.43    2,400  6        187.56    1,800  4
187.42    3,100  5        187.57    3,600  7
187.41    1,600  3        187.58    2,000  5
187.40    4,500  9        187.59    1,200  2
```

**Features:**

- Size bars: horizontal bars behind each size value, proportional to the largest visible size. Bid bars extend left (blue), ask bars extend right (red).
- Price levels color-coded by size concentration.
- Cumulative depth column available (running total from inside out).
- Click-to-trade: clicking a bid level pre-populates a sell limit at that price; clicking an ask pre-populates a buy limit.
- Aggregate mode vs. order-by-order (when exchange provides individual order data, e.g., NASDAQ TotalView).
- Price levels auto-scroll to keep the inside market centered.
- Depth chart visualization: area chart of cumulative bid/ask depth.

### 5.4 Time and Sales (Tape)

Displays every trade print as it occurs.

**Columns:**

| Column | Description |
|---|---|
| Time | Trade timestamp (HH:MM:SS.mmm) |
| Price | Trade price |
| Size | Number of shares/contracts |
| Exchange | Executing venue |
| Condition | Trade condition codes (e.g., Regular, OddLot, Cross, Intermarket Sweep) |

**Color coding:**

- Trade at ask or above: green (uptick).
- Trade at bid or below: red (downtick).
- Trade between bid and ask: gray/white (midpoint).

**Features:**

- Cumulative volume counter per side (buy volume vs. sell volume estimate).
- Speed indicator: trades-per-second gauge.
- Filter by minimum size (e.g., show only prints >= 1,000 shares to see block trades).
- Aggregate mode: group prints at same price/time into single line with total size.

---

## 6. Charting

### 6.1 Chart Types

| Chart Type | Description | Use Case |
|---|---|---|
| Candlestick | Open-high-low-close bars; body = open/close range, wicks = high/low | Most common for active trading |
| Bar (OHLC) | Horizontal ticks for open (left) and close (right), vertical line for range | Traditional technical analysis |
| Line | Close prices connected by a line | Trend identification, overlays |
| Area | Line chart with filled area below | Visual emphasis on trend direction |
| Heikin-Ashi | Modified candlestick using averaged values | Smoother trend visualization |
| Renko | Fixed-size bricks ignoring time, only price movement | Noise reduction |
| Point & Figure | X (up) and O (down) columns, ignoring time | Support/resistance identification |
| Volume Profile | Horizontal histogram showing volume traded at each price level | Identifying value areas, POC |

### 6.2 Timeframes

Standard intervals available:

- **Intraday:** 1-tick, 1-second, 5s, 15s, 30s, 1-minute, 2m, 3m, 5m, 10m, 15m, 30m, 1-hour, 2h, 4h
- **Daily and above:** Daily, Weekly, Monthly, Quarterly, Yearly

Multi-timeframe analysis typically uses a layout of 3-4 chart panels:
- Top-left: Daily (big picture trend)
- Top-right: 1-hour (intermediate structure)
- Bottom-left: 15-minute (entry timing)
- Bottom-right: 1-minute (precise execution)

### 6.3 Technical Indicators

**Trend indicators:**

| Indicator | Parameters | Typical Defaults |
|---|---|---|
| Simple Moving Average (SMA) | Period | 20, 50, 200 |
| Exponential Moving Average (EMA) | Period | 9, 21, 55 |
| Weighted Moving Average (WMA) | Period | 20 |
| VWAP | Reset period (session/week/month) | Session |
| Ichimoku Cloud | Tenkan (9), Kijun (26), Senkou B (52) | Standard |
| Parabolic SAR | Step (0.02), Max (0.2) | Standard |
| SuperTrend | Period (10), Multiplier (3) | Standard |

**Momentum / Oscillator indicators:**

| Indicator | Parameters | Typical Defaults | Overbought/Oversold |
|---|---|---|---|
| RSI (Relative Strength Index) | Period | 14 | 70 / 30 |
| MACD | Fast (12), Slow (26), Signal (9) | Standard | Histogram crossover |
| Stochastic Oscillator | %K (14), %D (3), Slowing (3) | Standard | 80 / 20 |
| CCI (Commodity Channel Index) | Period | 20 | +100 / -100 |
| Williams %R | Period | 14 | -20 / -80 |
| ADX (Average Directional Index) | Period | 14 | >25 = trending |
| Rate of Change (ROC) | Period | 12 | Zero line |
| Money Flow Index (MFI) | Period | 14 | 80 / 20 |

**Volatility indicators:**

| Indicator | Parameters | Typical Defaults |
|---|---|---|
| Bollinger Bands | Period (20), Std Dev (2) | Standard |
| ATR (Average True Range) | Period | 14 |
| Keltner Channels | EMA Period (20), ATR Mult (1.5) | Standard |
| Donchian Channels | Period | 20 |
| Historical Volatility | Period | 20 |
| Implied Volatility Overlay | N/A (from options market) | N/A |

**Volume indicators:**

| Indicator | Description |
|---|---|
| Volume Bars | Standard volume histogram below price chart, colored by up/down candle |
| Volume Profile (Fixed Range) | Horizontal histogram for a selected range |
| Volume Profile (Session) | Horizontal histogram per trading session |
| OBV (On-Balance Volume) | Running cumulative volume based on close direction |
| Volume Weighted Average Price (VWAP) | Anchored or session VWAP with standard deviation bands |
| Accumulation/Distribution Line | Incorporates close location within range |

### 6.4 Drawing Tools

| Tool | Description |
|---|---|
| Trend Line | Straight line between two points |
| Horizontal Line | Price level marker |
| Vertical Line | Time marker |
| Channel | Parallel trend lines |
| Fibonacci Retracement | Horizontal levels at Fibonacci ratios (23.6%, 38.2%, 50%, 61.8%, 78.6%) |
| Fibonacci Extension | Price projection levels (100%, 127.2%, 161.8%, 200%, 261.8%) |
| Pitchfork (Andrews') | Median line and parallel channels from three points |
| Rectangle | Highlight a price/time region |
| Ellipse | Highlight a curved region |
| Text Annotation | Free-text label placed on chart |
| Arrow | Directional annotation |
| Measure Tool | Shows price change, percentage change, and bar count between two points |
| XABCD Pattern | Harmonic pattern overlay |

**Drawing features:**

- Snap to price: drawing endpoints snap to OHLC values.
- Magnetic mode: endpoints snap to nearby candle features.
- Lock drawings: prevent accidental modification.
- Drawing layers: organize drawings into layers that can be shown/hidden.
- Template save: save a set of drawings as a reusable template.
- Alert on cross: trigger an alert when price crosses a drawn level.

### 6.5 Chart Interaction

- **Crosshair:** shows price and time at cursor position, with readouts in a data window.
- **Zoom:** mouse wheel to zoom time axis; pinch-zoom on touch devices; hold `Ctrl` and scroll to zoom price axis only.
- **Pan:** click-and-drag, or use arrow keys.
- **Auto-scale:** price axis auto-scales to fit visible candles; toggle for fixed scale.
- **Compare mode:** overlay multiple symbols on the same chart (rebased to percentage change).
- **Split panes:** stack indicators in separate sub-panes below the main chart.
- **Right-click context menu:** add indicator, change chart type, change timeframe, save image, print.

---

## 7. News and Research Panels

### 7.1 Real-Time News Feeds

**Sources typically integrated:**

- Wire services: Reuters, Bloomberg, Dow Jones Newswires, AP
- Exchange feeds: NYSE alerts, NASDAQ market system status
- Regulatory: SEC EDGAR filings (8-K, 10-Q, 10-K, 13F, insider transactions)
- Social/alternative: Twitter/X financial feeds, Reddit sentiment, StockTwits

**News panel layout:**

| Column | Description |
|---|---|
| Time | Publication timestamp |
| Headline | Article headline (truncated) |
| Source | Wire/publication name |
| Symbols | Tagged tickers |
| Urgency | Flash/Urgent/Normal |
| Category | Earnings, M&A, Macro, Regulatory, Analyst, etc. |

**Features:**

- Click headline to expand full article in reading pane.
- Filter by symbol (linked to active watchlist symbol).
- Filter by category or source.
- Keyword search across headline and body.
- Urgency highlighting: flash-priority headlines appear with red background.
- Auto-link to related orders and positions.
- Story count indicator: badge showing number of stories for active symbol in last N hours.

### 7.2 Research Integration

- Broker research notes surfaced inline with analyst name, rating, target price.
- Consensus estimates panel: EPS, revenue estimates with beat/miss history.
- Earnings calendar: upcoming earnings dates with expected report time (BMO/AMC).
- Price target visualization: chart overlay showing consensus, high, low target prices.

### 7.3 Sentiment Indicators

| Indicator | Source | Display |
|---|---|---|
| News Sentiment Score | NLP on news articles | -1.0 to +1.0 gauge |
| Social Media Buzz | Twitter/Reddit volume | Sparkline + volume number |
| Put/Call Ratio | Options market data | Numeric + historical chart |
| Short Interest | Exchange data (bi-monthly) | % of float, days to cover |
| Analyst Consensus | Broker research | Buy/Hold/Sell distribution bar |
| Insider Activity | SEC Form 4 filings | Net buy/sell over 30/90 days |

### 7.4 Economic Calendar

| Column | Description |
|---|---|
| Date/Time | Event date and scheduled release time |
| Event | Name (e.g., "Non-Farm Payrolls", "FOMC Rate Decision") |
| Country | Flag + country code |
| Impact | High / Medium / Low (color-coded red/orange/yellow) |
| Previous | Previous release value |
| Forecast | Consensus forecast |
| Actual | Actual value (updated in real time upon release) |
| Surprise | Actual minus Forecast |

**Features:**

- Countdown timer to next high-impact event.
- Filter by country, impact level, or event category.
- Historical event data with market reaction analysis.
- Alert trigger: notify N minutes before a selected event.

---

## 8. Alert and Notification Systems

### 8.1 Alert Types

| Alert Type | Trigger Condition | Example |
|---|---|---|
| Price Alert | Last price crosses above/below a threshold | AAPL crosses above 190.00 |
| Price Change Alert | Percentage or absolute change exceeds threshold | AAPL moves +/- 3% from open |
| Volume Alert | Volume exceeds N-day average by multiple | AAPL volume > 2x 20-day avg |
| Order Fill Alert | Order receives fill or full completion | Order ORD-147 filled |
| Order Reject Alert | Order rejected by exchange or broker | Order rejected: insufficient margin |
| Risk Limit Alert | Portfolio risk metric breaches limit | Net exposure > $50M limit |
| P&L Alert | P&L crosses threshold (stop-loss or take-profit) | Day P&L below -$100,000 |
| Spread Alert | Bid-ask spread widens beyond threshold | AAPL spread > $0.10 |
| Technical Alert | Indicator condition met | RSI(14) crosses below 30 |
| News Alert | News published for a symbol or keyword | AAPL: "FDA" keyword match |
| Market Event Alert | Index circuit breaker, halt/resume, auction | AAPL trading halted: LULD |
| Correlation Alert | Pair spread exceeds threshold | AAPL/MSFT spread > 2 std dev |

### 8.2 Alert Configuration

**Alert setup form:**

- Symbol or instrument selector
- Condition builder (field, operator, value): e.g., `Last Price > 190.00`
- Compound conditions with AND/OR logic
- Trigger frequency: Once, Every Time, Once Per Bar
- Expiration: End of Day, GTC, Specific Date
- Action on trigger: popup, sound, email, SMS, webhook

### 8.3 Notification Delivery

| Channel | Description |
|---|---|
| Desktop popup (toast) | Non-modal notification in corner of screen, auto-dismiss after N seconds |
| Sound alert | Configurable per alert type; distinct sounds for fills, rejects, price alerts |
| In-app notification center | Bell icon with badge count; scrollable list of all alerts |
| Email | Formatted email with alert details |
| SMS / Push notification | Mobile delivery for critical alerts |
| Webhook | HTTP POST to external system for automation |
| Blotter highlight | Row flash in blotter when related alert fires |

### 8.4 Alert Management

- Alert manager panel listing all active alerts with columns: Symbol, Condition, Status (Armed/Triggered/Expired), Created Time, Last Triggered.
- Bulk enable/disable.
- Alert history log with timestamps and trigger values.
- Template alerts: save common alert configurations for reuse.

---

## 9. Multi-Monitor and Workspace Management

### 9.1 Layout Management

Professional trading desks typically use 4-8 monitors. The UI must support:

**Layout paradigms:**

- **Tabbed panels:** Multiple components in a single panel area, switch via tabs.
- **Split panes:** Horizontal and vertical splits within a window; drag dividers to resize.
- **Floating windows:** Components detached from main window, positioned anywhere across monitors.
- **Docking system:** Drag components to dock positions (top, bottom, left, right, center) with visual guides.

**Typical multi-monitor arrangement (6 monitors, 3x2 grid):**

| Monitor | Position | Content |
|---|---|---|
| 1 | Top-left | Watchlists and quote board |
| 2 | Top-center | Charts (multi-timeframe, 2x2 grid) |
| 3 | Top-right | News feed and research |
| 4 | Bottom-left | Order blotter and execution blotter (stacked) |
| 5 | Bottom-center | Position blotter with P&L and Level 2 depth |
| 6 | Bottom-right | Risk dashboard and alerts |

### 9.2 Workspace Saving and Loading

- **Named workspaces:** Save entire layout as a named configuration (e.g., "US Equities Morning", "Earnings Season", "Risk Review").
- **Auto-save:** Layout state persisted on every change; restored on application restart.
- **Workspace sharing:** Export workspace as a file; import on another workstation.
- **Component state:** Each workspace saves not just layout positions but also:
  - Watchlist contents and column configuration
  - Chart symbols, timeframes, indicators, and drawings
  - Blotter filters and sort orders
  - Alert configurations
  - Window positions and sizes across all monitors

### 9.3 Tear-Off Windows

- Any panel or component can be "torn off" by dragging it out of its container.
- Torn-off window becomes a native OS window that can be moved to any monitor.
- Torn-off window remains linked to the application (linked symbol context, shared data).
- Double-click title bar to re-dock.
- Tear-off windows support independent resizing and z-ordering.

### 9.4 Linked Symbols (Symbol Linking)

- **Color-coded link groups:** Components assigned to the same color group (Red, Blue, Green, Yellow, etc.) share a selected symbol.
- Changing the symbol in one linked component updates all others in the same group.
- A component can be "unlinked" (gray) to be independent.
- Example: Watchlist (Red group), Chart (Red group), Level 2 (Red group), News (Red group) -- clicking a row in the watchlist updates the chart, depth display, and news filter simultaneously.

### 9.5 Multi-Screen Support

- Application detects monitor count, resolution, and arrangement on startup.
- Layout engine respects monitor boundaries (components do not span monitor bezels unless explicitly configured).
- DPI-aware rendering for mixed-resolution setups (e.g., 4K center monitor, 1080p side monitors).
- Taskbar/menu bar behavior: configurable whether tear-off windows appear as separate taskbar items.
- Fullscreen mode per monitor.

---

## 10. Keyboard-Driven Trading

### 10.1 Global Hotkeys

| Hotkey | Action |
|---|---|
| `Ctrl+N` | New order ticket |
| `Ctrl+Shift+B` | Quick-buy active symbol (opens pre-filled buy ticket) |
| `Ctrl+Shift+S` | Quick-sell active symbol |
| `Ctrl+F` | Global symbol search / command palette |
| `Ctrl+W` | Close active panel |
| `Ctrl+Tab` | Cycle through open panels |
| `Ctrl+1` through `Ctrl+9` | Switch to workspace 1-9 |
| `F5` | Refresh active panel data |
| `F11` | Toggle fullscreen |
| `Ctrl+Shift+L` | Lock/unlock layout |
| `Ctrl+,` | Open preferences/settings |

### 10.2 Order Management Hotkeys

| Hotkey | Action |
|---|---|
| `Ctrl+Shift+C` | Cancel selected order |
| `Ctrl+Shift+A` | Cancel all orders for active symbol |
| `Ctrl+Shift+X` | Cancel all orders (panic cancel) |
| `Ctrl+Shift+F` | Flatten position (close entire position for active symbol) |
| `Ctrl+Shift+P` | Flatten all positions |
| `Ctrl+R` | Replace/amend selected order |

### 10.3 Rapid Order Entry

Some professional platforms support a "speed trader" or "hot button" mode:

- Pre-configured order templates bound to keys: e.g., `F1` = Buy 1000 shares at market, `F2` = Sell 1000 shares at market, `F3` = Buy 100 at best bid, `F4` = Sell 100 at best ask.
- Numeric pad entry: type quantity then press side key. E.g., type `5000` then press `B` to buy 5,000 at market.
- Price ladder (DOM) trading: click or press keys on a vertical price ladder to place limit orders at specific price levels. The DOM (Depth of Market) ladder shows:
  - Price column (centered, scrollable)
  - Bid quantity column (left)
  - Ask quantity column (right)
  - Your working orders displayed at their price levels
  - One-click to place, click existing order to cancel

### 10.4 Command Palette

A searchable command palette (invoked via `Ctrl+Shift+P` or `Ctrl+F`) that supports:

- Symbol search: type a ticker to navigate all linked components.
- Action search: type "cancel all", "flatten", "new order" to execute actions.
- Component search: type "chart", "blotter", "news" to focus that panel.
- Settings search: type "theme", "font size", "sound" to jump to preferences.
- Recent actions: shows last 10 commands for quick repeat.

### 10.5 Customizable Keybindings

- All hotkeys configurable via a keybinding editor.
- Conflict detection: warns if a new binding conflicts with an existing one.
- Context-aware bindings: same key can have different actions depending on focused component (e.g., `Enter` submits an order in the ticket but expands a row in the blotter).
- Import/export keybinding profiles.
- Chord bindings supported: e.g., `Ctrl+K, Ctrl+C` (press Ctrl+K then Ctrl+C).

---

## Appendix: Common UX Patterns

### Color Themes

- **Dark theme** (dominant on trading desks): dark gray/black backgrounds (#1a1a2e, #16213e), high-contrast text, reduces eye strain over long sessions.
- **Light theme:** available but rarely used on active desks.
- **Color palette:** green for positive/buy, red for negative/sell (Western convention); some desks invert for Asian markets. Configurable in settings.

### Real-Time Update Patterns

- **Cell flash:** background color briefly changes on value update (200-500ms).
- **Tick arrows:** small up/down arrows next to prices showing direction of last change.
- **Stale data indicator:** values not updated within a configurable threshold (e.g., 5 seconds) shown dimmed or with a warning icon.
- **Connection status:** green/yellow/red indicator showing market data feed health.

### Accessibility Considerations

- Font size configurable globally and per-component (typical range: 10-16pt; some traders prefer 8pt for density).
- Color-blind modes: use shapes and patterns in addition to color to convey information.
- High-contrast mode for visually impaired users.
- Screen reader support for compliance requirements.

### Performance Expectations

- Market data latency: display within 1-5ms of receipt for co-located setups; within 50-200ms for WAN connections.
- Blotter update: order status changes reflected within 1ms of FIX message receipt.
- Chart rendering: re-render within 16ms (60fps target) for smooth scrolling and live candle updates.
- Startup time: workspace fully restored and streaming within 5-15 seconds.
- Memory: trading applications commonly consume 2-8 GB RAM depending on number of open instruments and historical data loaded.
