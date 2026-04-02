# Dashboard and Analytics

Comprehensive reference for dashboards, analytics, reporting, data visualization, custom scripting, and compliance views found on professional trading desks.

---

## 1. Real-Time Dashboards

### 1.1 P&L Dashboard

The P&L dashboard provides a live, aggregated view of profit and loss across all trading activity.

**Top-level summary bar:**

| Metric | Description | Example |
|---|---|---|
| Total Day P&L | Net P&L for current session | +$342,150 |
| Realized P&L | P&L from closed positions today | +$187,200 |
| Unrealized P&L | P&L from open positions (mark-to-market) | +$154,950 |
| MTD P&L | Month-to-date cumulative P&L | +$2,145,800 |
| YTD P&L | Year-to-date cumulative P&L | +$18,742,300 |
| P&L vs. Budget | Actual vs. target/budget | +12% ahead |

**Intraday P&L chart:**

- X-axis: time (market open to current time).
- Y-axis: cumulative P&L in dollars.
- Line chart showing P&L evolution through the day.
- Shaded band for +/- 1 standard deviation of typical daily P&L path.
- Annotations for significant events (large fills, news events, market-moving releases).

**P&L breakdown table:**

| Column | Description |
|---|---|
| Strategy / Book | Sub-portfolio or trading strategy name |
| Trader | Trader responsible |
| Day P&L | Today's P&L for this strategy |
| MTD P&L | Month-to-date |
| Sharpe (annualized) | Rolling Sharpe ratio |
| Max Drawdown | Largest peak-to-trough decline |
| Win Rate | Percentage of profitable trades |
| Avg Win / Avg Loss | Ratio of average winning trade to average losing trade |
| # Trades | Trade count today |

**Drill-down:** Click a strategy row to expand individual positions and their contribution to P&L. Click further to see individual execution history.

### 1.2 Risk Dashboard

The risk dashboard surfaces portfolio risk metrics in real time.

**Key risk metrics panel:**

| Metric | Description | Display |
|---|---|---|
| VaR (Value at Risk) | 1-day, 95% and 99% confidence | Dollar amount + histogram |
| CVaR / Expected Shortfall | Expected loss beyond VaR | Dollar amount |
| Net Exposure | Long minus short market value | Dollar amount + gauge |
| Gross Exposure | Long plus abs(short) market value | Dollar amount + gauge |
| Beta Exposure | Portfolio beta to benchmark | Numeric (e.g., 0.85) |
| Delta Exposure | Net delta (for options portfolios) | Dollar delta |
| Gamma Exposure | Net gamma | Contracts equivalent |
| Vega Exposure | Net vega | Dollar per 1% vol move |
| Theta (Daily Decay) | Net theta | Dollar per day |
| Concentration | Largest single-name as % of gross | Percentage + bar |
| Leverage | Gross exposure / equity | Multiple (e.g., 2.3x) |

**Risk limit monitoring:**

| Limit | Threshold | Current | Status |
|---|---|---|---|
| Max Net Exposure | $50,000,000 | $34,200,000 | Green (68%) |
| Max Gross Exposure | $100,000,000 | $78,500,000 | Yellow (78%) |
| Max Single-Name | 10% of gross | 7.2% | Green |
| Max Sector | 25% of gross | 22.1% | Yellow (88%) |
| Daily Loss Limit | -$500,000 | +$342,150 | Green |
| VaR Limit (95%) | $2,000,000 | $1,450,000 | Green (72%) |
| Max Leverage | 3.0x | 2.3x | Green |

Status indicators: Green (< 75% of limit), Yellow (75-90%), Orange (90-100%), Red (breached). Breaches trigger alerts to the trader, risk manager, and compliance.

**Scenario analysis panel:**

- Predefined scenarios: Market crash (-10%), Rate shock (+100bps), Vol spike (+5 pts), Sector rotation.
- Custom scenarios: user-defined factor shocks.
- Stress test results: estimated P&L impact per scenario.
- Historical scenario replay: "What would our current portfolio have lost on [date]?"

**Greeks surface (options desks):**

- 3D surface showing portfolio delta/gamma/vega across strike and expiration.
- Slice views: delta by expiration, gamma by strike.
- Hedge recommendations: suggested trades to neutralize specific Greek exposures.

### 1.3 Execution Dashboard

Monitors execution quality across all trading activity.

**Aggregate metrics:**

| Metric | Description |
|---|---|
| Total Orders | Count of orders placed today |
| Fill Rate | Percentage of orders fully filled |
| Partial Fill Rate | Percentage ending as partial fills |
| Cancel Rate | Percentage cancelled before any fill |
| Reject Rate | Percentage rejected |
| Avg Time to Fill | Mean time from submission to complete fill |
| VWAP Slippage | Average slippage versus VWAP benchmark |
| Arrival Price Slippage | Average slippage versus mid at arrival |
| Implementation Shortfall | Total cost of execution vs. decision price |

**Execution quality by venue:**

| Venue | Fill Rate | Avg Slippage (bps) | Avg Fill Time | Rebate / Fee |
|---|---|---|---|---|
| NYSE | 92% | 0.8 | 340ms | -$0.0012 |
| ARCA | 88% | 1.2 | 180ms | -$0.0020 |
| BATS | 91% | 0.9 | 150ms | +$0.0015 |
| EDGX | 85% | 1.5 | 200ms | +$0.0018 |
| IEX | 78% | 0.3 | 450ms | $0.0000 |
| Dark Pool A | 65% | -0.2 | 1200ms | -$0.0008 |

**Execution quality by algo:**

| Algo | Avg Slippage (bps) | Participation Rate | Completion Rate | Avg Duration |
|---|---|---|---|---|
| VWAP | 0.5 | 8.2% | 94% | 2h 15m |
| TWAP | 1.1 | 6.5% | 97% | 3h 00m |
| IS (Impl. Shortfall) | 0.3 | 12.4% | 91% | 45m |
| POV (% of Volume) | 0.7 | 15.0% | 89% | 1h 30m |
| Arrival Price | 0.2 | 18.6% | 85% | 25m |

**Time-of-day analysis chart:** Scatter plot showing slippage versus time of day to identify optimal execution windows.

### 1.4 Market Overview Dashboard

Provides a macro view of market conditions.

**Index summary tiles:**

| Index | Last | Change | Change % | Status |
|---|---|---|---|---|
| S&P 500 | 5,892.31 | +42.17 | +0.72% | Green |
| NASDAQ | 19,245.88 | +156.32 | +0.82% | Green |
| DJIA | 43,128.45 | +287.91 | +0.67% | Green |
| Russell 2000 | 2,345.67 | -12.34 | -0.52% | Red |
| VIX | 16.42 | -0.85 | -4.92% | Green |

**Sector performance heatmap:** Grid of GICS sectors color-coded by day performance (green to red gradient), sized by market cap weight.

**Additional panels:**

- Treasury yield curve (live): 1M, 3M, 6M, 1Y, 2Y, 3Y, 5Y, 7Y, 10Y, 20Y, 30Y plotted as a curve. Previous day's curve overlaid for comparison.
- FX major pairs: table with EUR/USD, USD/JPY, GBP/USD, USD/CHF, AUD/USD, USD/CAD.
- Commodities: WTI Crude, Brent, Gold, Silver, Natural Gas, Copper.
- Crypto: BTC, ETH (if traded).
- Market breadth: advance/decline ratio, new highs/new lows, percent of stocks above 200-day MA.
- Volatility term structure: VIX futures across expirations, contango/backwardation indicator.

---

## 2. Portfolio Analytics

### 2.1 Portfolio Composition

**Holdings table:**

| Column | Description |
|---|---|
| Symbol | Instrument ticker |
| Name | Full security name |
| Quantity | Shares/contracts/face value held |
| Market Value | Current market value |
| Weight (%) | Percentage of total portfolio value |
| Weight vs. Benchmark (%) | Active weight relative to benchmark |
| Cost Basis | Total cost of position |
| Unrealized P&L | Current market value minus cost basis |
| Beta | Individual security beta to benchmark |
| Contribution to Risk | Marginal contribution to portfolio VaR |

**Summary statistics:**

| Metric | Value |
|---|---|
| Number of Positions | 147 |
| Long Market Value | $82,450,000 |
| Short Market Value | -$31,200,000 |
| Net Market Value | $51,250,000 |
| Gross Market Value | $113,650,000 |
| Cash & Equivalents | $12,800,000 |
| Total NAV | $64,050,000 |
| Number of Long Positions | 98 |
| Number of Short Positions | 49 |
| Median Position Size | $350,000 |
| Largest Position | 4.2% of NAV |

### 2.2 Sector Allocation

**Displayed as:**

- **Bar chart:** horizontal bars showing portfolio weight per GICS sector vs. benchmark weight.
- **Table:**

| Sector | Portfolio Weight | Benchmark Weight | Active Weight | Long | Short | Net |
|---|---|---|---|---|---|---|
| Technology | 28.5% | 31.2% | -2.7% | $23,500K | -$8,200K | $15,300K |
| Healthcare | 14.2% | 12.8% | +1.4% | $11,700K | -$3,100K | $8,600K |
| Financials | 12.8% | 13.1% | -0.3% | $10,600K | -$4,500K | $6,100K |
| Consumer Disc. | 10.5% | 10.2% | +0.3% | $8,700K | -$2,800K | $5,900K |
| Industrials | 9.1% | 8.7% | +0.4% | $7,500K | -$3,200K | $4,300K |
| ... | ... | ... | ... | ... | ... | ... |

- **Treemap:** rectangles sized by weight, grouped by sector, colored by performance.
- **Pie/donut chart:** less common on professional desks due to difficulty comparing slice sizes, but sometimes used for high-level presentations.

**Drill-down:** Sector > Industry Group > Industry > Sub-Industry > Individual Holdings.

### 2.3 Geographic Exposure

**Map visualization:**

- World map with countries color-coded by exposure level (darker = higher exposure).
- Bubble overlay: bubble size proportional to notional exposure.

**Geographic table:**

| Region / Country | Portfolio Weight | Benchmark Weight | Active Weight | Exposure ($) |
|---|---|---|---|---|
| North America | 62.3% | 64.0% | -1.7% | $39,900K |
| -- United States | 58.1% | 61.2% | -3.1% | $37,200K |
| -- Canada | 4.2% | 2.8% | +1.4% | $2,700K |
| Europe | 18.5% | 16.0% | +2.5% | $11,850K |
| -- United Kingdom | 6.2% | 4.5% | +1.7% | $3,970K |
| -- Germany | 4.1% | 3.8% | +0.3% | $2,630K |
| Asia Pacific | 15.2% | 16.5% | -1.3% | $9,740K |
| Emerging Markets | 4.0% | 3.5% | +0.5% | $2,560K |

**Currency exposure:** Separate view showing exposure by settlement currency and whether FX hedges are in place.

### 2.4 Factor Exposure

Factor exposure analysis decomposes the portfolio into systematic risk factor loadings.

**Common factor model (e.g., Barra, Axioma, Northfield):**

| Factor | Portfolio Loading | Benchmark Loading | Active Loading | Factor Return (1D) |
|---|---|---|---|---|
| Market (Beta) | 1.05 | 1.00 | +0.05 | +0.72% |
| Size (SMB) | -0.12 | 0.00 | -0.12 | -0.15% |
| Value (HML) | +0.08 | 0.00 | +0.08 | +0.22% |
| Momentum | +0.25 | 0.00 | +0.25 | +0.31% |
| Quality | +0.15 | 0.00 | +0.15 | +0.08% |
| Volatility | -0.18 | 0.00 | -0.18 | -0.12% |
| Growth | +0.10 | 0.00 | +0.10 | +0.18% |
| Leverage | -0.05 | 0.00 | -0.05 | -0.03% |
| Liquidity | +0.07 | 0.00 | +0.07 | +0.05% |

**Factor contribution to return:** Bar chart showing how much of the day's/month's return came from each factor bet vs. stock-specific (idiosyncratic) returns.

**Factor risk decomposition:** Pie chart or stacked bar showing percentage of portfolio variance attributable to each factor vs. specific risk.

---

## 3. Performance Attribution

### 3.1 Brinson Attribution (Brinson-Fachler Model)

Decomposes portfolio return relative to benchmark into allocation effect, selection effect, and interaction effect.

**Formula:**

- **Allocation Effect** = (Portfolio Weight_sector - Benchmark Weight_sector) * (Benchmark Return_sector - Benchmark Return_total)
- **Selection Effect** = Benchmark Weight_sector * (Portfolio Return_sector - Benchmark Return_sector)
- **Interaction Effect** = (Portfolio Weight_sector - Benchmark Weight_sector) * (Portfolio Return_sector - Benchmark Return_sector)
- **Total Active Return** = Allocation + Selection + Interaction

**Attribution table:**

| Sector | Port Wt | Bench Wt | Port Ret | Bench Ret | Allocation | Selection | Interaction | Total |
|---|---|---|---|---|---|---|---|---|
| Technology | 28.5% | 31.2% | +1.2% | +0.9% | -0.02% | +0.09% | -0.01% | +0.06% |
| Healthcare | 14.2% | 12.8% | +0.5% | +0.3% | +0.01% | +0.03% | +0.003% | +0.04% |
| Financials | 12.8% | 13.1% | -0.2% | -0.4% | +0.001% | +0.03% | -0.001% | +0.03% |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |
| **Total** | | | **+0.82%** | **+0.65%** | **+0.04%** | **+0.11%** | **+0.02%** | **+0.17%** |

**Visualization:** Waterfall chart showing how allocation, selection, and interaction sum to total active return.

**Time periods:** Daily, WTD, MTD, QTD, YTD, ITD (inception-to-date), custom range.

### 3.2 Factor Attribution

Decomposes returns into factor-driven and stock-specific components using a multi-factor risk model.

**Factor attribution table:**

| Source | Return Contribution | Description |
|---|---|---|
| Market (Beta) | +0.52% | Systematic market exposure |
| Size | -0.02% | Small/large cap tilt |
| Value | +0.04% | Value/growth tilt |
| Momentum | +0.08% | Momentum factor bet |
| Quality | +0.02% | Quality factor bet |
| Industry Factors | +0.06% | Net sector/industry bets |
| Country Factors | +0.01% | Geographic bets |
| Currency | -0.03% | FX impact |
| Specific Return | +0.14% | Stock-picking alpha |
| **Total Return** | **+0.82%** | |

**Rolling factor attribution chart:** Stacked area chart over time (e.g., 12 months) showing cumulative return from each source. Specific return (alpha) shown as a distinct color to highlight stock-picking contribution.

### 3.3 Transaction Cost Attribution

Measures the cost of trading and decomposes slippage.

**Implementation shortfall decomposition:**

| Component | Value (bps) | Description |
|---|---|---|
| Decision Price | -- | Mid-price when trade decision was made |
| Delay Cost | 2.1 | Slippage from decision to order submission |
| Market Impact | 4.5 | Price movement caused by the order itself |
| Timing Cost | 1.2 | Slippage from algo execution timing |
| Spread Cost | 1.8 | Half-spread paid on execution |
| Commission | 0.5 | Broker commission |
| **Total IS** | **10.1** | **Total implementation shortfall** |

**TCA benchmarks:**

| Benchmark | Description |
|---|---|
| VWAP | Volume-weighted average price for the interval |
| TWAP | Time-weighted average price |
| Arrival Price | Mid-price at time of order arrival |
| Close | Closing price of the session |
| Open | Opening price of the session |
| Previous Close | Prior session close |
| Interval VWAP | VWAP for a specific time window |

**TCA by order characteristics:** Scatter plot of slippage vs. order size (as % ADV), colored by urgency level, to identify whether larger or more urgent orders have higher cost.

---

## 4. Reporting

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

---

## 5. Data Visualization

### 5.1 Heat Maps

**Position heat map:**

- Grid of rectangles, one per position.
- Rectangle size proportional to absolute market value.
- Color represents day P&L %: deep green (+3% or more) through white (flat) to deep red (-3% or more).
- Grouped by sector or other dimension.
- Hover tooltip: symbol, position size, P&L, key metrics.
- Click to drill down to position detail.

**Correlation heat map:**

- Square matrix with instruments on both axes.
- Cell color: dark blue (+1.0 correlation) through white (0.0) to dark red (-1.0).
- Diagonal is always +1.0 (self-correlation).
- Configurable lookback period (30, 60, 90, 252 days).
- Hierarchical clustering to reorder axes and reveal correlation blocks.

**Market sector heat map (S&P 500 style):**

- Treemap layout: each rectangle is a stock, grouped by sector.
- Size = market cap weight.
- Color = day change percentage.
- Standard in market overview dashboards (similar to finviz.com map).

### 5.2 Treemaps

Used for portfolio composition visualization:

- **Primary grouping:** Sector
- **Secondary grouping:** Industry or individual names
- **Size metric:** Market value, risk contribution, or P&L
- **Color metric:** Performance, active weight, or risk measure
- Drill-down: click a sector to see its sub-industries, click again for individual names.

### 5.3 Scatter Plots

**Common uses:**

| X-Axis | Y-Axis | Bubble Size | Use Case |
|---|---|---|---|
| Risk (Volatility) | Return | Position size | Risk-return profile of holdings |
| Beta | Alpha | Market value | Factor exposure analysis |
| ADV (%) | Slippage (bps) | Order size | Transaction cost analysis |
| Short Interest (%) | Days to Cover | Market cap | Short squeeze screening |
| Estimated EPS Growth | P/E Ratio | Market cap | Valuation analysis |

**Features:**

- Regression line with R-squared.
- Quadrant labels (e.g., "High Return / Low Risk" upper-left).
- Point labels (ticker symbols) toggled on/off.
- Click point to navigate to that position.

### 5.4 Correlation Matrices

**Display options:**

- Full matrix: all pairwise correlations.
- Lower-triangle only (since matrix is symmetric).
- Color-coded cells (blue-white-red scale).
- Numeric values displayed in each cell.
- Dendrogram along axes showing hierarchical clustering.

**Calculation parameters:**

- Return type: price returns vs. log returns.
- Frequency: daily, weekly, monthly.
- Lookback: 30, 60, 90, 120, 252 days.
- Method: Pearson, Spearman (rank), or Kendall (for non-normal distributions).
- Rolling correlation chart: time series of pairwise correlation for a selected pair.

### 5.5 Yield Curves

**Standard yield curve display:**

- X-axis: maturity (3M, 6M, 1Y, 2Y, 3Y, 5Y, 7Y, 10Y, 20Y, 30Y).
- Y-axis: yield (%).
- Current curve as a solid line.
- Previous close curve as a dashed line overlay.
- Curve from N days ago for comparison (user-selected).

**Derived views:**

| View | Description |
|---|---|
| Spot Curve | Zero-coupon yields bootstrapped from par curve |
| Forward Curve | Implied forward rates (e.g., 1y1y, 2y1y, 5y5y) |
| Spread Curve | Corporate spread over Treasuries by maturity |
| Real Yield Curve | TIPS yields (inflation-adjusted) |
| Breakeven Curve | Nominal yield minus real yield = expected inflation |

**Curve changes:**

- Bar chart showing yield change by tenor (e.g., 2Y +3bps, 10Y +1bp = flattening).
- Butterfly spread monitor: 2s5s10s, 2s10s30s.
- Slope indicators: 2s10s spread (key recession indicator), 3m10y spread.

### 5.6 Volatility Surfaces

**3D surface plot:**

- X-axis: expiration (days to expiry or date).
- Y-axis: strike price or delta.
- Z-axis: implied volatility (%).
- Color gradient reinforcing Z-axis (cool colors = low vol, warm = high vol).
- Rotatable 3D view or fixed perspective angles.

**2D cross-sections:**

- **Volatility smile/skew:** Implied vol vs. strike for a fixed expiration.
- **Term structure:** Implied vol vs. expiration for a fixed strike (ATM).

**Comparison views:**

- Current surface vs. previous close (difference surface showing vol changes).
- Current surface vs. realized volatility (overpriced/underpriced identification).
- Historical vol surface animation: play back vol surface evolution over days/weeks.

**Key metrics extracted from the surface:**

| Metric | Description |
|---|---|
| ATM Vol | At-the-money implied volatility for each expiry |
| 25-Delta Skew | IV of 25-delta put minus 25-delta call |
| Put Skew | How steeply IV rises for OTM puts |
| Vol-of-Vol | Rate of change of implied volatility |
| Term Structure Slope | ATM vol difference between near and far expirations |

---

## 6. Custom Analytics and Scripting

### 6.1 User-Defined Calculations

Professional platforms allow traders and analysts to define custom metrics.

**Formula column system:**

- Add a calculated column to any blotter or watchlist.
- Reference other columns by name.
- Syntax similar to spreadsheet formulas.

**Examples:**

```
// Risk-reward ratio
RiskReward = (TargetPrice - LastPrice) / (LastPrice - StopLoss)

// Distance from VWAP in basis points
VWAPBasis = (LastPrice - VWAP) / VWAP * 10000

// Implied move from options (for earnings)
ImpliedMove = ATMStraddle / LastPrice * 100

// Custom P&L including financing
AdjustedPnL = UnrealizedPnL - (PositionValue * FinancingRate * DaysHeld / 360)

// Relative value: stock vs sector ETF
RelativeReturn = StockReturn_5D - SectorETFReturn_5D
```

**Features:**

- Autocomplete for available field names.
- Real-time recalculation as underlying data updates.
- Conditional logic: `IF(RSI < 30, "Oversold", IF(RSI > 70, "Overbought", "Neutral"))`.
- Cross-referencing: pull data from other instruments (e.g., reference VIX level in an equity formula).
- Formula library: save and share named formulas across the desk.

### 6.2 Custom Indicators (Charting)

Users can create custom technical indicators using a scripting language (similar to TradingView's Pine Script or Bloomberg's BQL).

**Scripting capabilities:**

- Access OHLCV data for any lookback period.
- Standard math functions (abs, sqrt, log, exp, min, max, round).
- Statistical functions (sma, ema, stdev, correlation, percentile, linreg).
- Conditional logic and loops.
- Multi-series output (plot multiple lines from one indicator).
- Color control (dynamic coloring based on conditions).
- Alert integration (trigger alerts from indicator conditions).

**Example custom indicator (mean reversion signal):**

```
// Z-Score of price relative to 20-day VWAP
period = 20
vwap20 = vwap(close, volume, period)
stdev20 = stdev(close, period)
zscore = (close - vwap20) / stdev20

plot(zscore, "VWAP Z-Score", color=zscore > 0 ? green : red)
hline(2.0, "Upper Band", color=gray, style=dashed)
hline(-2.0, "Lower Band", color=gray, style=dashed)
hline(0, "Zero", color=gray)

alert(cross_under(zscore, -2.0), "Z-Score below -2: potential mean reversion buy")
alert(cross_over(zscore, 2.0), "Z-Score above +2: potential mean reversion sell")
```

### 6.3 Screening and Scanning

Custom scanners filter the universe of instruments based on user-defined criteria.

**Scanner configuration:**

| Parameter | Description | Example |
|---|---|---|
| Universe | Instrument universe to scan | S&P 500, Russell 3000, All US Equities |
| Criteria | Filter conditions (AND/OR) | Volume > 1M AND RSI(14) < 30 AND Price > 10 |
| Sort By | Ranking metric | Volume (descending) |
| Refresh | Static (run once) or streaming | Streaming (every 30 seconds) |
| Columns | Fields to display in results | Symbol, Last, Change%, Volume, RSI, MACD Signal |

**Predefined scans:**

- Unusual volume (today's volume > 2x 20-day average)
- New 52-week highs/lows
- Gap up/down > 3% from previous close
- RSI oversold/overbought
- MACD bullish/bearish crossovers
- Price crossing 200-day SMA
- Highest implied volatility percentile

### 6.4 Backtesting Framework

Some platforms provide integrated backtesting.

**Backtest configuration:**

- Strategy logic (entry/exit rules defined via scripting or visual rule builder).
- Date range.
- Starting capital and position sizing rules.
- Commission and slippage assumptions.
- Benchmark for comparison.

**Backtest output:**

| Metric | Value |
|---|---|
| Total Return | +142.3% |
| Annualized Return | +18.5% |
| Benchmark Return | +12.2% |
| Sharpe Ratio | 1.45 |
| Sortino Ratio | 2.10 |
| Max Drawdown | -15.8% |
| Win Rate | 58.2% |
| Profit Factor | 1.85 |
| Avg Trade Duration | 8.3 days |
| Total Trades | 1,247 |
| Avg Win | +2.1% |
| Avg Loss | -1.2% |

**Equity curve chart:** cumulative return over time vs. benchmark, with drawdown chart below.

---

## 7. Audit and Compliance Views

### 7.1 Trade Surveillance

Trade surveillance systems monitor for potentially manipulative or non-compliant trading patterns.

**Alert types monitored:**

| Pattern | Description | Detection Method |
|---|---|---|
| Spoofing / Layering | Placing orders with intent to cancel before execution | Large orders placed and cancelled within short time window; order-to-trade ratio analysis |
| Wash Trading | Buying and selling the same instrument to create artificial volume | Same-account or related-account trades that offset with no economic purpose |
| Front-Running | Trading ahead of a known client order | Timeline analysis: proprietary trades preceding client order in same direction |
| Insider Trading | Trading on material non-public information | Unusual P&L around corporate events; communication correlation |
| Market Manipulation | Coordinated activity to artificially move prices | Price impact analysis around concentrated order flow |
| Marking the Close | Placing orders near market close to influence closing price | Time-weighted order concentration in final minutes |
| Pump and Dump | Accumulating then artificially inflating and selling | Volume and price pattern detection with position analysis |
| Best Execution Violation | Failing to achieve best available price for client orders | Systematic comparison of fills vs. NBBO, venue analysis |

**Surveillance dashboard:**

| Column | Description |
|---|---|
| Alert ID | Unique alert identifier |
| Alert Type | Pattern detected |
| Severity | Critical / High / Medium / Low |
| Date/Time | When the alert was generated |
| Symbol | Affected instrument |
| Trader | Trader involved |
| Account | Account involved |
| Status | New / Under Review / Escalated / Closed / False Positive |
| Assigned To | Compliance analyst reviewing |
| Details | Summary of flagged behavior |

**Investigation workflow:**

1. Alert generated by automated surveillance engine.
2. Compliance analyst reviews alert, accesses drill-down showing:
   - Full order/execution timeline for the flagged period.
   - Market data context (price chart, order book replay).
   - Trader communication logs (if integrated).
   - Related alerts for the same trader or instrument.
3. Analyst marks as False Positive (with reason), Escalated (to senior compliance), or Confirmed Violation.
4. Confirmed violations generate a case with documentation trail for regulatory reporting.

### 7.2 Pattern Detection Analytics

**Behavioral analytics dashboards:**

| Metric | Description |
|---|---|
| Order-to-Trade Ratio | Orders submitted vs. orders filled; high ratio may indicate spoofing |
| Cancel Rate by Trader | Percentage of orders cancelled; anomalous rates flagged |
| Pre-News Trading P&L | P&L in windows before material news; screens for insider trading |
| Concentrated Order Flow | Percentage of venue volume represented by a single trader |
| Cross-Account Activity | Trades between accounts under common control |
| Time-to-Cancel Distribution | Histogram of cancel times; very short-lived orders flagged |

**Visualization:**

- Timeline reconstruction: interactive chart showing all orders, cancels, fills, and market data on a single time axis for a flagged period.
- Network graph: shows relationships between accounts, traders, and counterparties to identify coordinated activity.
- Statistical outlier detection: Z-score or machine learning based anomaly scores for each trader's activity patterns relative to their historical baseline.

### 7.3 Communication Monitoring

For desks subject to communication surveillance requirements (MiFID II, Dodd-Frank):

**Monitored channels:**

- Bloomberg chat (IB messages)
- Symphony
- Email
- Voice (recorded and transcribed)
- Mobile messaging (where permitted)

**Compliance features:**

| Feature | Description |
|---|---|
| Keyword Detection | Flags messages containing terms like "guarantee", "sure thing", "inside info", "don't tell" |
| Sentiment Analysis | NLP models scoring communication for unusual urgency or secrecy |
| Trade-Communication Correlation | Links trades to preceding communications about the same instrument |
| Lexicon Management | Configurable keyword lists maintained by compliance |
| Retention | All communications retained for regulatory-required periods (typically 5-7 years) |
| Search | Full-text search across all monitored channels with date, participant, and keyword filters |
| Export | Generate evidence packages for regulatory inquiries |

### 7.4 Regulatory Compliance Dashboard

**Compliance status overview:**

| Area | Status | Detail |
|---|---|---|
| Position Limits | Green | All positions within limits |
| Short Selling Compliance | Green | All short sales have valid locates |
| Best Execution | Yellow | 2 alerts pending review |
| Trade Reporting (CAT) | Green | All reports submitted on time |
| Restricted List | Green | No trades in restricted names |
| Watch List | Yellow | 1 watch list name traded — review required |
| Personal Account Dealing | Green | All pre-clearances approved |
| Gift & Entertainment | Green | All within policy limits |

**Restricted and watch lists:**

- Restricted list: instruments that cannot be traded (e.g., during advisory mandates, material non-public information).
- Watch list: instruments under heightened monitoring (not prohibited but trades require review).
- Pre-trade compliance check: order entry system blocks orders in restricted names and flags watch list names.
- Real-time enforcement: orders that would violate restrictions are rejected with a compliance error code.

---

## Appendix: Dashboard Design Principles

### Layout Hierarchy

1. **Top bar:** Global P&L summary, market status, alert count, clock (multiple time zones: ET, CT, GMT, HKT, JST).
2. **Primary panels:** The dashboard's core content (charts, tables, visualizations).
3. **Side panel:** Contextual detail for selected items (drill-down, properties).
4. **Bottom bar:** System status (data feed health, connection status, last update timestamp).

### Refresh and Latency

| Data Type | Refresh Rate | Typical Latency |
|---|---|---|
| Market data (prices, quotes) | Streaming / tick-by-tick | 1-50ms |
| P&L calculations | On every tick or 1-second interval | 10-100ms |
| Risk metrics (VaR, Greeks) | 1-second to 1-minute | 100ms-1s |
| Factor analytics | 1-minute to intraday batch | 1-60 seconds |
| Performance attribution | Intraday batch (every 15-60 min) or EOD | 15-60 minutes |
| Surveillance alerts | Near-real-time | 1-30 seconds |
| Reports | Scheduled (EOD, weekly, monthly) | Batch |

### Interactivity Standards

- **Drill-down:** every aggregated number should be clickable to reveal underlying detail.
- **Cross-filtering:** selecting a dimension in one chart filters all other charts on the same dashboard.
- **Tooltip on hover:** show contextual data without requiring a click.
- **Export:** every table and chart should be exportable (CSV, XLSX, PDF, PNG).
- **Bookmarking:** save current filter/drill-down state as a named bookmark for quick return.
- **Undo:** support Ctrl+Z to reverse filter/view changes.

### Data Quality Indicators

- **Stale data warning:** if a feed has not updated within its expected interval, display a yellow/red indicator.
- **Data source badge:** indicate where data originates (real-time feed, delayed, end-of-day, calculated).
- **Last updated timestamp:** shown per panel or per data element.
- **Reconciliation status:** for P&L and positions, indicate whether front-office and back-office figures are reconciled.
