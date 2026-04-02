## Data Visualization

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
