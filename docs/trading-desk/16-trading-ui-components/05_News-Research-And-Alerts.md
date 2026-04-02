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
