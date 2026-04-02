## Cash Equities Trading

### Instrument Types

**Single Stocks (Common and Preferred Shares)**

- The core unit of equity trading. Each listed security has a unique ticker symbol, CUSIP (US), ISIN (global), and SEDOL (UK/international).
- Common shares carry voting rights and variable dividends. Preferred shares have priority on dividends and liquidation but typically no voting rights.
- Trading lots: standard lot = 100 shares (US); odd lots (< 100 shares) historically received inferior execution but modern exchanges now protect odd-lot orders.
- Tick size: $0.01 for stocks priced above $1.00 (SEC Rule 612); sub-penny pricing ($0.001 increments) is permitted only for midpoint executions in certain venues.

**Exchange-Traded Funds (ETFs)**

- Baskets of securities trading like a single stock. Key structural features relevant to a trading desk:
  - **NAV tracking**: intraday indicative value (iNAV / IOPV) published every 15 seconds. Authorized participants (APs) arbitrage deviations between market price and NAV via the creation/redemption mechanism.
  - **Creation/redemption**: in-kind or cash. The AP delivers a creation basket (specified by the ETF issuer daily) in exchange for new ETF shares, or redeems ETF shares for the underlying basket.
  - **Liquidity profile**: ETF on-screen liquidity is only part of the picture; implied liquidity from the underlying basket is the true measure.
  - **Tracking error/difference**: important for index-replicating ETFs. Sampling-based ETFs and those holding illiquid underlyings exhibit wider tracking variance.
- Leveraged, inverse, and thematic ETFs have distinct risk characteristics (daily rebalancing for leveraged/inverse leads to path dependency over multi-day horizons).

**American Depositary Receipts (ADRs)**

- USD-denominated certificates representing shares of a foreign company, held by a depositary bank.
- Three levels: Level I (OTC only, minimal SEC reporting), Level II (listed on exchange, full SEC compliance), Level III (listed and can raise capital in the US).
- ADR ratio defines how many ordinary shares one ADR represents (e.g., 1 ADR = 10 ordinary shares).
- Trading considerations:
  - FX exposure: ADR price = foreign share price * ADR ratio * FX rate.
  - Arbitrage between ADR and home-market listing (requires factoring FX, settlement cycles, ADR conversion fees).
  - Depositary fees deducted from dividends or charged per share.
  - Home-market hours overlap (or lack thereof) affects pricing efficiency.

**Real Estate Investment Trusts (REITs)**

- Must distribute at least 90% of taxable income as dividends (US IRC Section 856). Results in high dividend yields and sensitivity to interest rates.
- Equity REITs own physical properties; mortgage REITs hold debt instruments; hybrid REITs do both.
- Sector-specific exposure: office, retail, industrial, residential, healthcare, data centers, cell towers.
- Trading characteristics: lower beta to broad equity market, higher correlation to bond yields, larger average spreads in smaller REITs.
- Index inclusion considerations: REITs are in a dedicated GICS sector (60 - Real Estate) as of 2016.

### Order Types and Execution

A professional equity trading system must support a comprehensive order type taxonomy:

| Order Type | Description | Use Case |
|---|---|---|
| Market | Executes immediately at best available price | Urgent fills, high-liquidity names |
| Limit | Executes at specified price or better | Price discipline, passive capture |
| Stop | Becomes market order when trigger price reached | Risk management, breakout entry |
| Stop-Limit | Becomes limit order when trigger price reached | Controlled risk exits |
| MOO (Market on Open) | Executes in the opening auction | Benchmark to open price |
| MOC (Market on Close) | Executes in the closing auction | Index rebalance, fund NAV |
| LOO (Limit on Open) | Limit order for opening auction only | Price-protected open participation |
| LOC (Limit on Close) | Limit order for closing auction only | Price-protected close participation |
| Pegged (Primary, Midpoint, Market) | Price floats relative to NBBO | Passive liquidity capture |
| Discretionary | Limit order with hidden discretion range | Aggressive passive |
| Reserve / Iceberg | Displays only a fraction of total quantity | Large order concealment |
| IOC (Immediate or Cancel) | Fill what you can immediately, cancel rest | Sweep liquidity |
| FOK (Fill or Kill) | Fill entire quantity or nothing | All-or-nothing requirement |
| GTC (Good Till Cancel) | Persists across sessions until filled/cancelled | Multi-day working orders |
| Day | Expires at end of trading day | Default time-in-force |

**Algorithmic order types** layer on top of these primitives (VWAP, TWAP, IS/Arrival Price, Close, Percentage of Volume, etc.) and are covered in depth in separate algo documentation.
