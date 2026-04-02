## Real-Time Dashboards

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
