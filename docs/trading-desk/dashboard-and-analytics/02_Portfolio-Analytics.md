## Portfolio Analytics

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
