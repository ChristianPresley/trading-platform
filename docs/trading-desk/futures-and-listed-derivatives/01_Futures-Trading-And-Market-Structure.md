## Futures Trading

### Contract Specifications

A futures contract is a standardized agreement to buy or sell a specific quantity of an underlying asset at a predetermined price on a future date. Every futures contract is defined by its specification document published by the listing exchange.

#### Key Specification Fields

| Field | Description | Example (ES — E-mini S&P 500) |
|---|---|---|
| **Underlying** | The asset the contract references | S&P 500 Index |
| **Contract size / Multiplier** | Notional per point | $50 per index point |
| **Tick size** | Minimum price increment | 0.25 index points ($12.50) |
| **Contract months** | Which months are listed | Mar (H), Jun (M), Sep (U), Dec (Z) — quarterly |
| **Settlement method** | Physical or cash | Cash-settled |
| **Last trading day** | Final day to trade | Third Friday of contract month |
| **Trading hours** | Electronic and pit hours | CME Globex: Sun-Fri 5:00 PM – 4:00 PM CT (23 hrs) |
| **Position limits** | Max contracts a single entity can hold | Varies; accountability level at 20,000 ES |
| **Price limits** | Circuit breakers | 7%, 13%, 20% daily limits (equity index) |

#### Common Futures Contracts Reference

| Contract | Exchange | Ticker | Multiplier | Tick Size | Tick Value |
|---|---|---|---|---|---|
| E-mini S&P 500 | CME | ES | $50 | 0.25 | $12.50 |
| Micro E-mini S&P 500 | CME | MES | $5 | 0.25 | $1.25 |
| E-mini NASDAQ 100 | CME | NQ | $20 | 0.25 | $5.00 |
| Micro E-mini NASDAQ | CME | MNQ | $2 | 0.25 | $0.50 |
| E-mini Dow | CBOT | YM | $5 | 1.00 | $5.00 |
| E-mini Russell 2000 | CME | RTY | $50 | 0.10 | $5.00 |
| Crude Oil (WTI) | NYMEX | CL | 1,000 bbl | $0.01 | $10.00 |
| Natural Gas | NYMEX | NG | 10,000 mmBtu | $0.001 | $10.00 |
| Gold | COMEX | GC | 100 troy oz | $0.10 | $10.00 |
| Silver | COMEX | SI | 5,000 troy oz | $0.005 | $25.00 |
| Copper | COMEX | HG | 25,000 lbs | $0.0005 | $12.50 |
| Corn | CBOT | ZC | 5,000 bu | $0.0025 | $12.50 |
| Soybeans | CBOT | ZS | 5,000 bu | $0.0025 | $12.50 |
| Wheat | CBOT | ZW | 5,000 bu | $0.0025 | $12.50 |
| Euro FX | CME | 6E | EUR 125,000 | $0.00005 | $6.25 |
| Japanese Yen | CME | 6J | JPY 12,500,000 | $0.0000005 | $6.25 |
| British Pound | CME | 6B | GBP 62,500 | $0.0001 | $6.25 |
| 10-Year T-Note | CBOT | ZN | $100,000 face | 1/64 of a point | $15.625 |
| 30-Year T-Bond | CBOT | ZB | $100,000 face | 1/32 of a point | $31.25 |
| 2-Year T-Note | CBOT | ZT | $200,000 face | 1/128 of a point | $15.625 |
| Eurodollar (SOFR) | CME | SR3 | $2,500 per bps | 0.0025 (0.25 bps) | $6.25 |
| Euro Stoxx 50 | Eurex | FESX | EUR 10 | 1.0 | EUR 10.00 |
| DAX | Eurex | FDAX | EUR 25 | 0.5 | EUR 12.50 |
| FTSE 100 | ICE | Z | GBP 10 | 0.5 | GBP 5.00 |
| Nikkei 225 (USD) | CME | NKD | $5 | 5.0 | $25.00 |
| Hang Seng | HKEX | HSI | HKD 50 | 1.0 | HKD 50.00 |
| Brent Crude | ICE | BRN | 1,000 bbl | $0.01 | $10.00 |

### Tick Values and P&L Calculation

P&L for a futures position is calculated tick-by-tick:

```
P&L = (Exit Price - Entry Price) / Tick Size * Tick Value * Number of Contracts
```

Example: Buy 5 ES at 4500.00, sell at 4510.00:
- Price move: 10.00 points = 40 ticks (10 / 0.25)
- P&L = 40 ticks x $12.50 x 5 contracts = $2,500

### Margin Requirements

Futures margin is a performance bond (not a loan as in equity margin). Two types:

- **Initial margin** — The amount required to open a new position. Set by the exchange (e.g., CME) and often increased by the broker.
- **Maintenance margin** — The minimum equity required to hold the position. If the account falls below maintenance, a margin call is issued.

**Current approximate initial margins (subject to change):**

| Contract | Initial Margin (approx.) | Maintenance (approx.) |
|---|---|---|
| ES (E-mini S&P) | $12,650 | $11,500 |
| NQ (E-mini NASDAQ) | $17,600 | $16,000 |
| CL (Crude Oil) | $8,000 | $7,200 |
| GC (Gold) | $10,000 | $9,000 |
| ZN (10-Year Note) | $2,200 | $2,000 |
| ZB (30-Year Bond) | $4,400 | $4,000 |

**Day-trade margins:** Many brokers offer reduced intraday margins (e.g., $500 per ES contract during regular hours). These are broker-imposed, not exchange-mandated, and are subject to immediate increase during volatile conditions.

### Daily Settlement (Mark-to-Market)

All futures positions are marked-to-market daily:

1. At the close of each trading day, the exchange calculates the **settlement price** (typically based on a volume-weighted average of trades in the final minutes).
2. Gains are credited and losses are debited from each account.
3. This process resets the cost basis daily — you do not carry unrealized gains/losses. This is unique to futures and has tax implications (Section 1256: 60/40 tax treatment in the U.S.).

The daily settlement eliminates the accumulation of large unrealized losses, reducing systemic risk.

---

## Futures Market Structure

### Major Exchanges

#### CME Group

The world's largest derivatives exchange, formed through the merger of CME, CBOT, NYMEX, and COMEX.

| Division | Products | Key Contracts |
|---|---|---|
| **CME** | Equity indices, FX, interest rates | ES, NQ, 6E, Eurodollar/SOFR |
| **CBOT** | Treasuries, agricultural | ZN, ZB, ZC, ZS, ZW |
| **NYMEX** | Energy | CL, NG, RB, HO |
| **COMEX** | Metals | GC, SI, HG |

**Trading platform:** CME Globex (electronic). Nearly all volume is electronic. The pit trading floor at the CBOT in Chicago was largely closed by 2021, though some open outcry persists for options on agricultural futures.

**Order types on Globex:**
- Limit, Market, Stop, Stop-Limit
- Market-if-Touched (MIT) — becomes a market order when the price touches the trigger
- Fill-or-Kill (FOK), Immediate-or-Cancel (IOC)
- Good-Til-Cancelled (GTC), Good-Til-Date (GTD)
- Iceberg (reserve) — only displays a portion of the order
- Implied orders — the matching engine generates implied prices from outright and spread orders

**Matching algorithm:** FIFO (first-in-first-out) for most products. Some products use pro-rata allocation (e.g., Eurodollar futures) or a hybrid.

#### ICE (Intercontinental Exchange)

| Division | Products | Key Contracts |
|---|---|---|
| **ICE Futures US** | Soft commodities, Russell indices | Coffee (KC), Sugar (SB), Cotton (CT) |
| **ICE Futures Europe** | Energy, emissions | Brent Crude (BRN), Gas Oil, EU ETS Carbon |
| **ICE Futures Singapore** | Asian commodities | TSI Iron Ore |
| **NYSE** | Equities, options | (Owned by ICE but separate from futures) |

ICE's Brent Crude contract (BRN) is the global benchmark for oil pricing. It is cash-settled against the ICE Brent Index, unlike WTI (CL) which is physically delivered at Cushing, Oklahoma.

#### Eurex

Europe's largest derivatives exchange, owned by Deutsche Boerse.

| Product Area | Key Contracts |
|---|---|
| **Equity Indices** | Euro Stoxx 50 (FESX), DAX (FDAX), SMI (FSMI) |
| **Fixed Income** | Euro-Bund (FGBL), Euro-Bobl (FGBM), Euro-Schatz (FGBS) |
| **Dividend Derivatives** | Euro Stoxx 50 Dividend Futures |
| **Volatility** | VSTOXX Futures and Options |

**Eurex matching:** Price-time priority for most products. The Euro-Bund future is one of the most liquid fixed income futures globally.

#### SGX (Singapore Exchange)

Key for Asian derivatives:

| Product | Description |
|---|---|
| **SGX Nifty** | Indian stock index futures (for non-Indian access) |
| **MSCI Singapore** | Singapore equity index futures |
| **Iron Ore** | TSI-cleared iron ore futures |
| **Rubber** | TSR 20 rubber futures |

SGX operates the T+7 facility for settlement of Asian equities.

#### Other Notable Exchanges

- **HKEX (Hong Kong):** Hang Seng Index futures, H-shares futures, stock options.
- **OSE (Osaka Exchange / JPX):** Nikkei 225 futures, TOPIX futures, JGB futures.
- **B3 (Brazil):** Bovespa index futures (WIN/IND), DI interest rate futures (most liquid futures in LatAm).
- **MOEX (Moscow):** RTS index futures, USD/RUB futures.
- **BSE/NSE (India):** Nifty 50 futures, Bank Nifty futures, single-stock futures (world's largest single-stock futures market by volume).

### Pit vs Electronic Trading

**Pit (open outcry):** Traders physically stand in a designated pit and communicate orders via hand signals and voice. Advantages were price discovery in complex spreads and large block trades. The pit era is effectively over for futures; residual open outcry exists only for some agricultural options.

**Electronic (screen-based):** All major futures trading is now electronic. CME Globex, ICE's WebICE, Eurex T7, and SGX Titan handle millions of messages per second with sub-millisecond latency.

**Key electronic trading features:**
- **Co-location:** Exchanges rent rack space adjacent to the matching engine. Round-trip latency: microseconds. Essential for HFT firms.
- **Market data feeds:** Direct feeds from exchanges (CME Market Data Platform, Nasdaq TotalView). Multicast UDP. Level 1 (BBO), Level 2 (full depth), Level 3 (order-by-order).
- **FIX protocol:** The standard for order entry (FIX 4.2/4.4/5.0). CME also offers iLink (binary, lower latency).
- **API access:** CME provides CME STP (Straight-Through Processing), FIX, and iLink. ICE provides WebICE and FIX. Eurex provides ETI (Enhanced Trading Interface).
