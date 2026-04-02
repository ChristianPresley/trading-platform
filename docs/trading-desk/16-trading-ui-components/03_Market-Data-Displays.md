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
