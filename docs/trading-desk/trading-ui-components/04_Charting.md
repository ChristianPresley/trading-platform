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
