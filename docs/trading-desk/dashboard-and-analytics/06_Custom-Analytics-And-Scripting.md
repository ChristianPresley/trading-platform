## Custom Analytics and Scripting

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
