## Performance Attribution

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
