## Reference Data and Static Data

### Instrument Master (Security Master)

The instrument master is the authoritative database of all tradeable instruments and their static attributes. It is the foundation on which all other market data systems build.

#### Core Attributes

| Category | Fields |
|----------|--------|
| **Identifiers** | Ticker, ISIN, CUSIP, SEDOL, FIGI, exchange symbol, RIC, Bloomberg ticker, internal ID |
| **Classification** | Asset class, instrument type (common stock, preferred, ETF, ADR, warrant, right, unit), sector (GICS, ICB), industry |
| **Listing** | Primary exchange (MIC), listing date, trading currency, country of risk, country of incorporation |
| **Trading parameters** | Tick size (minimum price increment), lot size (round lot, odd lot, board lot), minimum order size, maximum order size |
| **Pricing** | Price display format (decimal, fractional for US treasuries), price magnifier, settlement price type |
| **Corporate** | Issuer name, issuer LEI, shares outstanding, market cap, free float |
| **Options-specific** | Underlying, strike price, expiration date, option type (call/put), exercise style (American/European/Bermudan), contract multiplier, deliverable |
| **Futures-specific** | Underlying, expiration date, first notice date, last trading date, contract size, tick value, settlement method (cash/physical), delivery months |
| **FX-specific** | Currency pair, base currency, quote currency, spot date convention, pip value |
| **Fixed income** | Coupon rate, coupon frequency, maturity date, day count convention, accrued interest, call/put schedule |

### Corporate Actions

Corporate actions alter the characteristics of securities and require adjustments to market data, positions, and analytics:

| Action | Impact on Market Data |
|--------|---------------------|
| **Stock split / reverse split** | Adjust historical prices by split ratio. Update shares outstanding, lot sizes. |
| **Dividend** (cash, stock, special) | Ex-date price adjustment. Stock dividends affect share count. |
| **Merger / acquisition** | Ticker change, ISIN change, delisting of acquired entity, new listing for combined entity. |
| **Spin-off** | New instrument created, price adjustment for parent. |
| **Rights issue** | New temporary instrument (rights), dilution adjustment. |
| **Ticker change** | Symbol mapping update across all systems. |
| **Name change** | Descriptive update, no price impact. |
| **Delisting** | Instrument becomes non-tradeable; must be marked inactive. |
| **Conversion** (convertible bonds, preferred to common) | New instrument relationship, potential delisting of old. |

Handling corporate actions correctly is one of the hardest problems in financial data management. A single missed or misapplied corporate action can corrupt analytics, break backtests, and cause trading errors.

### Holiday Calendars

Trading systems must know when markets are open or closed:

- **Exchange-specific holidays**: Each exchange publishes its own holiday calendar. NYSE has ~9 holidays/year; LSE has ~8; TSE (Tokyo) has ~16+ including Golden Week.
- **Early close days**: Some exchanges close early on certain days (e.g., NYSE closes at 13:00 ET on the day before certain US holidays).
- **Settlement calendars**: Settlement dates depend on the business day calendar of the settlement currency and location.
- **Cross-market coordination**: Trading a cross-listed security or a multi-leg strategy requires knowledge of all relevant market calendars.

Calendar data providers: Bloomberg CALS function, Refinitiv calendar data, QuantLib holiday implementations, custom internal maintenance.

### Trading Hours

| Venue | Pre-Market | Core Session | Post-Market |
|-------|-----------|-------------|-------------|
| **NYSE** | 04:00-09:30 ET (via Arca) | 09:30-16:00 ET | 16:00-20:00 ET |
| **NASDAQ** | 04:00-09:30 ET | 09:30-16:00 ET | 16:00-20:00 ET |
| **CME ES** (E-mini S&P) | Sunday 18:00-Friday 17:00 ET (nearly 24h with 1h break) | Same | Same |
| **LSE** | 05:05-08:00 GMT (auction) | 08:00-16:30 GMT | 16:30-17:00 GMT (closing auction) |
| **Eurex** | 07:30-08:00 CET (pre-trading) | 08:00-22:00 CET (varies by product) | N/A |
| **TSE** | N/A | 09:00-11:30, 12:30-15:30 JST (morning/afternoon sessions, extended to 15:30 from Nov 2024) | N/A |
| **HKEX** | 09:00-09:30 HKT (pre-open) | 09:30-12:00, 13:00-16:00 HKT (morning/afternoon) | 16:00-16:10 HKT (closing auction) |

Trading hours are critical for: data feed activation/deactivation, stale data detection, auction phase identification, risk limit resets, and P&L calculations.

### Tick Size Tables

Tick sizes (minimum price increments) vary by instrument, price level, and venue:

#### US Equities (Reg NMS)

- Stocks priced >= $1.00: $0.01 minimum tick
- Stocks priced < $1.00: $0.0001 minimum tick

#### European Equities (MiFID II Tick Size Regime)

Tick sizes depend on the instrument's average daily number of transactions (ADNT) and price level, as defined in RTS 11 tables. For example, a liquid stock with ADNT > 10,000 trading at EUR 50 might have a tick size of EUR 0.01, while a less liquid stock at the same price might have a tick of EUR 0.05.

#### Futures

Tick sizes are contract-specific. For example:
- CME ES (E-mini S&P 500): 0.25 index points = $12.50/tick
- CME NQ (E-mini NASDAQ-100): 0.25 index points = $5.00/tick
- CME CL (WTI Crude Oil): $0.01/barrel = $10.00/tick
- Eurex FGBL (Euro-Bund): 0.01% = EUR 10.00/tick

### Lot Sizes

- **US equities**: Round lot = 100 shares (though odd-lot handling has evolved under SEC reforms).
- **LSE equities**: Varies by instrument, often 1 share for electronic order book.
- **HKEX**: Board lot varies by stock (commonly 100, 200, 400, 500, 1000, 2000 shares).
- **Futures**: Always 1 contract minimum. Block trade minimums are larger.
