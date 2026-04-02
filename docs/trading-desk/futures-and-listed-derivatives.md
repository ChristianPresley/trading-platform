# Futures and Listed Derivatives — Professional Trading Desk Reference

## Table of Contents

1. [Futures Trading](#futures-trading)
2. [Futures Market Structure](#futures-market-structure)
3. [Futures Roll Management](#futures-roll-management)
4. [Futures Spreads](#futures-spreads)
5. [Clearing and Margining](#clearing-and-margining)
6. [Delivery and Settlement](#delivery-and-settlement)
7. [Exchange-Traded Funds and Notes](#exchange-traded-funds-and-notes)
8. [Structured Products](#structured-products)
9. [Cryptocurrency Derivatives](#cryptocurrency-derivatives)
10. [Cross-Margining Between Asset Classes](#cross-margining-between-asset-classes)
11. [Futures Basis Trading and Arbitrage](#futures-basis-trading-and-arbitrage)

---

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

---

## Futures Roll Management

### What is a Roll?

Futures contracts expire. To maintain continuous exposure, traders "roll" from the expiring (front) contract to the next active (back) contract.

```
Roll = Sell Front Month + Buy Back Month  (for a long position)
Roll = Buy Front Month + Sell Back Month  (for a short position)
```

The roll is typically executed as a **calendar spread** to avoid leg risk.

### Roll Schedules

Each futures contract has a customary roll period when the majority of volume migrates from the front month to the next:

| Contract | Roll Period | Active Months |
|---|---|---|
| ES (E-mini S&P) | Thursday before expiration, ~8 days out | H, M, U, Z (quarterly) |
| CL (Crude Oil) | 3-4 trading days before last trade day | Every month |
| GC (Gold) | ~2 weeks before first notice day | Feb, Apr, Jun, Aug, Oct, Dec (even months) |
| ZN (10-Year Note) | Last week of month preceding delivery | H, M, U, Z |
| ZC (Corn) | ~5 days before first notice day | H, K, N, U, Z |
| 6E (Euro FX) | ~5 days before delivery | H, M, U, Z |
| BRN (Brent Crude) | 2 business days before last trade day | Every month |

**Roll timing matters:** The optimal roll date balances liquidity in both months. Rolling too early means trading in an illiquid back month with wide spreads. Rolling too late risks holding a contract into delivery notice or final settlement with thin liquidity.

### Volume Roll Indicator

Trading systems track the roll by monitoring open interest and volume:

- **OI crossover:** When the back month's open interest exceeds the front month's, the roll is considered complete.
- **Volume crossover:** When intraday volume in the back month exceeds the front month.
- Professional data vendors (Bloomberg, Refinitiv) publish "active contract" designations that switch on roll date.

### Synthetic Continuation (Continuous Contracts)

For charting and backtesting, traders need a continuous price series across contract months. Methods:

1. **Unadjusted (splice):** Simply concatenate front-month prices. Creates gaps at each roll. Suitable for short-term intraday analysis.

2. **Back-adjusted (Panama method):** Add a constant to all historical prices to eliminate the gap at each roll. The most common method. However, old prices become artificial and percentage returns are distorted.

3. **Ratio-adjusted (proportional):** Multiply all historical prices by a ratio at each roll. Preserves percentage returns but distorts absolute levels.

4. **Calendar-weighted:** During the roll period, blend front and back month prices using a weight that shifts linearly from 100% front to 100% back. Smooth transition.

5. **Perpetual contract:** A theoretical construct that interpolates between two nearest contracts to produce a constant-maturity price (e.g., "30-day constant maturity" crude oil).

### Roll Yield (Roll Return)

The return from rolling a futures position, arising from the shape of the futures curve.

- **Contango:** Front month is cheaper than back month (upward-sloping curve). Rolling a long position means selling cheap and buying expensive — **negative roll yield**.
- **Backwardation:** Front month is more expensive than back month (downward-sloping curve). Rolling a long position means selling expensive and buying cheap — **positive roll yield**.

Roll yield is a significant component of total return for commodity investors. Example: Crude oil in persistent contango can lose 5-10% per year from roll yield alone, even if spot prices are flat.

```
Roll Yield (annualized) ≈ (Front Price - Back Price) / Front Price x (365 / Days Between Contracts)
```

---

## Futures Spreads

### Calendar Spreads (Time Spreads)

Simultaneous long and short positions in different months of the same commodity.

```
Long Calendar Spread = Buy Back Month - Sell Front Month
```

**Use cases:**
- Trading the term structure (contango/backwardation)
- Lower margin than outright positions (CME provides spread margin credits)
- Rolling exposure (a roll is just a calendar spread)

**Examples:**
- Long CL March / Short CL February — betting that the March-Feb spread widens.
- Long ZN June / Short ZN March — trading the roll in Treasuries.

**Spread margin:** Typically 10-20% of the outright margin because the two legs are highly correlated.

### Inter-Commodity Spreads

Simultaneous positions in related but different commodities.

#### Crack Spreads (Energy Refining)

Model the economics of refining crude oil into products.

- **3:2:1 Crack Spread:** Buy 3 crude oil (CL), sell 2 gasoline (RB), sell 1 heating oil (HO). Represents a refinery's margin.
- **1:1 Gas Crack:** Buy 1 CL, sell 1 RB.
- **1:1 Heating Oil Crack:** Buy 1 CL, sell 1 HO.

**Calculation (simplified for 1:1 gas crack):**
```
Crack Spread = RB price ($/gallon) x 42 (gallons/barrel) - CL price ($/barrel)
```
42 gallons per barrel is the conversion factor. RB trades in dollars per gallon, CL in dollars per barrel.

Refineries use crack spreads to hedge their processing margin. A refiner who is long physical crude and short product can lock in the spread.

#### Crush Spreads (Agriculture)

Model the economics of crushing soybeans into soybean meal and soybean oil.

```
Crush Spread = (Soybean Meal value + Soybean Oil value) - Soybean cost
```

Standard conversion: 1 bushel of soybeans yields approximately 44 lbs of meal, 11 lbs of oil, and waste.

```
Crush = (ZM price x 0.022) + (ZL price x 11) - ZS price
```

Where ZM = soybean meal ($/short ton), ZL = soybean oil (cents/lb), ZS = soybeans (cents/bushel).

Soybean processors use this to lock in processing margins. The reverse crush is used by livestock feeders.

#### Spark Spreads (Power Generation)

Model the economics of converting natural gas into electricity.

```
Spark Spread = Power Price ($/MWh) - [Natural Gas Price ($/mmBtu) x Heat Rate]
```

Heat rate (mmBtu/MWh) represents the efficiency of the power plant. A typical gas turbine has a heat rate of 7-10 mmBtu/MWh.

**Dark spread:** Same concept but for coal-fired power plants.
**Clean spark/dark spread:** Subtracts the cost of carbon emissions allowances.

#### Other Notable Inter-Commodity Spreads

- **Gold-Silver ratio:** Long gold / Short silver (or vice versa). The ratio typically ranges 60:1 to 90:1.
- **NOB spread (Notes Over Bonds):** Long 10-year notes (ZN) / Short 30-year bonds (ZB). Trades the yield curve slope.
- **TED spread:** (Historical) Eurodollar minus T-bill. Replaced by SOFR-based equivalents.
- **Fly spreads:** Three-leg calendar spreads (e.g., buy M1, sell 2x M2, buy M3) that trade the curvature of the forward curve.
- **Frac spread:** Natural gas vs NGLs (natural gas liquids). Ethane-gas spread, propane-gas spread.
- **Cattle crush:** Feeder cattle + corn = live cattle cost basis.

### Spread Margin Credits

Exchanges recognize that spread positions have lower risk than outrights:

| Spread Type | Typical Margin Reduction |
|---|---|
| Calendar spread (same commodity) | 70-90% reduction vs sum of outrights |
| Inter-commodity (recognized pair) | 50-80% reduction |
| Butterfly (3-leg calendar) | 80-95% reduction |

CME SPAN automatically identifies and credits spread positions. Traders should verify that their clearing firm passes through exchange-level spread credits rather than charging full outright margin on each leg.

---

## Clearing and Margining

### Central Counterparty (CCP) Clearing

All exchange-traded futures are cleared through a CCP. The CCP interposes itself between buyer and seller, becoming the buyer to every seller and the seller to every buyer.

**Benefits:**
- **Counterparty risk elimination:** If one party defaults, the CCP covers the other side using its waterfall of financial resources.
- **Netting:** Positions offset at the clearing level. If a firm is long 100 ES and short 50 ES, net exposure is 50.
- **Standardization:** Uniform margin and settlement processes.

**Major CCPs:**

| CCP | Exchange(s) | Products |
|---|---|---|
| **CME Clearing** | CME, CBOT, NYMEX, COMEX | Futures, options, OTC cleared swaps |
| **ICE Clear US** | ICE Futures US | Soft commodities, credit derivatives |
| **ICE Clear Europe** | ICE Futures Europe | Energy, emissions |
| **Eurex Clearing** | Eurex | European equity/fixed income derivatives |
| **LCH (LCH.Clearnet)** | LSE, various | OTC interest rate swaps (world's largest), listed derivatives |
| **JSCC** | OSE/JPX | JGB futures, equity derivatives |
| **OCC** | US options exchanges | Listed equity/index options |

### Initial Margin

The deposit required to open a position. Determined by the exchange/CCP using risk models (SPAN, PRISMA, VaR-based).

**SPAN (Standard Portfolio Analysis of Risk):** See the options document for details. For futures, SPAN evaluates 16 price/volatility scenarios and sets margin at the worst-case loss.

**Eurex PRISMA:** A more advanced margin model that uses historical simulation and Monte Carlo to estimate a 2-day 99.7% Expected Shortfall. Allows broader portfolio offsets.

**LCH PAIRS:** Portfolio Approach to Interest Rate Scenarios. Used for OTC cleared swaps. Evaluates portfolio P&L under hundreds of historical stress scenarios.

### Variation Margin

The daily mark-to-market cash flows.

- If the position gains value, the CCP pays variation margin to the clearing member.
- If the position loses value, the clearing member pays variation margin to the CCP.
- Variation margin is exchanged every business day (often intraday for large moves).

**Important distinction:** Initial margin is a deposit (returned when the position is closed). Variation margin is an actual cash transfer (realized P&L).

### Margin Calls

If an account's equity falls below the **maintenance margin** level:

1. The clearing firm issues a margin call.
2. The call must be met by the next business day's clearing deadline (typically by the start of the next trading session).
3. If not met, the clearing firm can liquidate positions.

**Intraday margin calls:** During extreme volatility, exchanges can issue intraday margin calls (CME Rule 930). These require immediate satisfaction, often within one hour.

**Exchange margin increases:** Exchanges frequently adjust margins during volatile periods. For example, CME increased initial margin on silver (SI) by 84% during the 2011 silver spike, and margins on crude oil surged in 2020 when WTI went negative.

### Margin Offsets

The clearing system recognizes correlated positions and reduces margin:

- **Intra-commodity spreads:** Long March ES vs short June ES. Margin is a fraction of the outright.
- **Inter-commodity spreads:** Long ES vs short NQ. Partial offset because S&P 500 and NASDAQ 100 are correlated.
- **Exchange-recognized combos:** CME publishes a list of inter-commodity spread credits (updated monthly).

### Default Waterfall

If a clearing member defaults, the CCP uses a waterfall of financial resources:

1. **Defaulting member's initial margin** — covers most losses.
2. **Defaulting member's default fund contribution** — the member's share of the mutualized guarantee fund.
3. **CCP's own capital (skin in the game)** — CCP contributes its own funds.
4. **Other members' default fund contributions** — mutualized loss sharing.
5. **Assessment powers** — CCP can call for additional contributions from surviving members.
6. **CCP's remaining capital and recovery tools** — tear-up of positions, partial settlement, etc.

This waterfall is designed to ensure that a single member's default does not cause systemic failure.

---

## Delivery and Settlement

### Physical Delivery

For physically-delivered contracts, the short position must deliver the underlying asset, and the long position must accept and pay for it.

**Delivery process (example: WTI Crude Oil — CL):**

1. **First Notice Day (FND):** The first day the exchange can issue delivery notices. For CL, this is one business day before the start of the delivery month. Long holders who do not want delivery must exit before FND.
2. **Delivery notice:** The short position submits a notice indicating intent to deliver. The exchange matches the oldest long position (FIFO).
3. **Delivery period:** The delivery occurs over a specified window (for CL, the entire delivery month).
4. **Delivery location:** Cushing, Oklahoma for WTI. The contract specifies acceptable delivery points, quality specifications (API gravity, sulfur content), and pipeline/storage requirements.
5. **Final settlement:** The long pays the invoice amount (settlement price x contract size) and receives a warehouse receipt or pipeline ticket.

**Quality standards:** Contracts specify acceptable grades. For WTI: light sweet crude with 37-42 API gravity and max 0.42% sulfur. Premiums/discounts apply for grades outside the par specification.

### Cash Settlement

For cash-settled contracts, no physical delivery occurs. Instead, the final settlement price is determined by a reference index, and positions are marked-to-market one final time.

**Examples:**
- **ES (E-mini S&P 500):** Settles to the Special Opening Quotation (SOQ) of the S&P 500 on the third Friday of the contract month.
- **SOFR Futures (SR3):** Settle to 100 minus the arithmetic average of daily SOFR rates during the contract month.
- **VIX Futures:** Settle to the VIX Special Opening Quotation on expiration morning.
- **Brent Crude (ICE BRN):** Cash-settled to the ICE Brent Index (a price assessment based on physical cargoes).

### Key Dates

| Date | Description | Significance |
|---|---|---|
| **First Notice Day (FND)** | First day delivery notices can be issued | Longs must exit if they don't want delivery |
| **Last Notice Day (LND)** | Last day delivery notices can be issued | Short must have exited or delivered |
| **Last Trading Day (LTD)** | Final day the contract trades | After this, open positions go to delivery/settlement |
| **First Delivery Day** | First day physical delivery can occur | Usually 1-2 days after FND |
| **Last Delivery Day** | Last day physical delivery can occur | End of the delivery window |

**Timing warning:** For physical delivery contracts, retail traders and most institutions must exit before FND. Brokers typically auto-liquidate any remaining positions 2-3 days before FND. The April 2020 WTI negative price event (-$37.63) was partly caused by traders unable to take delivery being forced to sell at any price.

### Delivery Logistics by Asset Class

**Agricultural (ZC, ZS, ZW):**
- Delivery via warehouse receipts at exchange-approved facilities (e.g., Chicago, Toledo, St. Louis for corn and soybeans).
- Quality inspected by exchange-licensed inspectors.
- Storage charges accrue to the receipt holder.

**Metals (GC, SI):**
- Delivery via vault receipts at COMEX-approved depositories (primarily in New York metro area).
- Gold bars must meet minimum fineness of .995 and weigh 100 troy oz (+/- 5%).
- Delivery is by book-entry transfer at the depository.

**Treasury Futures (ZN, ZB):**
- Delivery of the actual bond/note via Fedwire.
- The short chooses which eligible issue to deliver (the "cheapest to deliver" or CTD bond).
- A conversion factor adjusts the invoice price based on the coupon of the delivered bond relative to the contract's notional coupon (6% for CBOT Treasury futures).
- The CTD bond is the one that minimizes: (Bond Price - Futures Price x Conversion Factor).

**Energy (CL):**
- Physical delivery at Cushing, Oklahoma via pipeline.
- Requires access to pipeline and storage facilities.
- Most commercial participants use Exchange for Physical (EFP) to arrange delivery privately rather than through the exchange process.

---

## Exchange-Traded Funds and Notes

### ETF Structure

An ETF is an investment fund traded on a stock exchange. Unlike mutual funds, ETFs trade continuously at market-determined prices.

#### Creation/Redemption Mechanism

The key innovation of ETFs: a process that keeps the ETF price close to its Net Asset Value (NAV).

**Creation (new shares):**
1. An **Authorized Participant (AP)** — typically a large broker-dealer (e.g., Jane Street, Virtu, Goldman Sachs) — assembles a basket of the underlying securities matching the ETF's holdings.
2. The AP delivers the basket to the ETF issuer (e.g., BlackRock for iShares, Vanguard, State Street for SPDRs).
3. The issuer creates new ETF shares (in large blocks called "creation units," typically 25,000 or 50,000 shares) and delivers them to the AP.
4. The AP sells the new ETF shares on the exchange.

**Redemption (remove shares):**
1. The AP delivers creation-unit-sized blocks of ETF shares to the issuer.
2. The issuer redeems them for the underlying basket of securities.
3. The AP sells the underlying securities in the open market.

**Why this works:** If the ETF trades at a premium to NAV, APs create new shares (buy cheap basket, sell expensive ETF). If the ETF trades at a discount, APs redeem shares (buy cheap ETF, sell expensive basket). This arbitrage mechanism keeps the ETF price within a tight band around NAV.

#### NAV Tracking

- **Indicative NAV (iNAV):** Calculated and published every 15 seconds during trading hours based on the real-time value of the underlying holdings.
- **NAV premium/discount:** The percentage difference between the ETF's market price and its NAV. For liquid, domestic equity ETFs (e.g., SPY), this is typically less than $0.01. For international or illiquid ETFs, premiums/discounts can be larger (especially when the underlying market is closed).

#### Authorized Participants

- Typically 20-50 APs per ETF, though most creation/redemption activity is concentrated among 3-5 active APs.
- APs are not obligated to create/redeem — they do so when it is profitable.
- During market stress, APs may widen their thresholds or temporarily stop creating/redeeming, causing premiums/discounts to widen (observed during March 2020 in corporate bond ETFs like LQD and HYG).

### Key ETF Products for Trading Desks

| ETF | Ticker | Underlying | AUM (approx.) | Avg Daily Volume |
|---|---|---|---|---|
| SPDR S&P 500 | SPY | S&P 500 | $500B+ | 80M+ shares/day |
| iShares Core S&P 500 | IVV | S&P 500 | $400B+ | 5M+ shares/day |
| Invesco QQQ | QQQ | NASDAQ 100 | $250B+ | 50M+ shares/day |
| iShares Russell 2000 | IWM | Russell 2000 | $65B+ | 30M+ shares/day |
| SPDR Gold Trust | GLD | Gold bullion | $60B+ | 8M+ shares/day |
| iShares 20+ Year Treasury | TLT | Long-term Treasuries | $40B+ | 20M+ shares/day |
| iShares iBoxx HY Corp | HYG | High-yield bonds | $15B+ | 15M+ shares/day |
| United States Oil Fund | USO | WTI futures | $3B+ | 5M+ shares/day |
| VIX Short-Term Futures | VIXY | VIX futures | $500M+ | 5M+ shares/day |

### ETN Structure

An ETN is an unsecured debt instrument issued by a bank. Unlike an ETF, an ETN does not hold any underlying assets. The issuer promises to pay the return of the tracked index.

**Key differences from ETFs:**

| Feature | ETF | ETN |
|---|---|---|
| **Structure** | Fund (holds assets) | Unsecured note (debt) |
| **Credit risk** | None (assets held in trust) | Issuer's credit risk (e.g., Lehman ETNs became worthless in 2008) |
| **Tracking** | May have tracking error | Perfect tracking (by design, barring fees) |
| **Tax** | Subject to fund-level capital gains distributions | No distributions until sale; potential for long-term capital gains |
| **Maturity** | Perpetual | Typically 20-30 year maturity; callable by issuer |

**ETN risks:**
- Issuer credit risk (concentration to one bank).
- Acceleration risk: The issuer can call the notes at any time, potentially at an unfavorable price.
- Premium/discount to indicative value: ETNs can trade at significant premiums when creation is suspended (as with TVIX in 2012 and 2018, or GBTC before its ETF conversion).

---

## Structured Products

### Warrants

Exchange-listed securities issued by financial institutions (primarily in Europe and Asia) that give the holder the right to buy or sell an underlying asset.

- **Call warrants** — Right to buy the underlying at the strike price.
- **Put warrants** — Right to sell.
- **Key differences from options:** Warrants are issued by banks (not created by market participants), have specific ISINs, and may have unique exercise styles. Dilution does not apply (unlike equity warrants issued by the company itself).
- **Leverage:** Warrants provide leveraged exposure to the underlying. A warrant with ratio 10:1 on a stock at EUR 100 with a strike of EUR 90 might cost EUR 1.20, providing roughly 8x leverage.
- **Major markets:** Hong Kong (HKEX — world's largest warrant market by turnover), Germany (Stuttgart, Frankfurt), Switzerland (SIX).

### Certificates (Structured Certificates)

Investment products listed on exchanges, primarily in Germany, Switzerland, and the Nordics. There are dozens of structures:

- **Tracker Certificates:** 1:1 participation in the underlying (similar to an ETN). No leverage.
- **Bonus Certificates:** Pay a guaranteed bonus at maturity if the underlying never falls below a barrier level. If the barrier is breached, the certificate converts to a tracker.
- **Discount Certificates:** Buy the underlying at a discount (embedded short call). Max payoff is capped.
- **Express Certificates:** Autocallable structures that pay a coupon and redeem early if the underlying is above a level on observation dates.
- **Capital Protection Certificates:** 100% principal protection with upside participation (embedded zero-coupon bond + call option).

**Issuer risk:** Certificates are debt of the issuing bank — like ETNs, they carry issuer credit risk.

### Turbo Warrants (Knock-Out Warrants)

Leveraged products with a knock-out barrier. If the underlying touches the barrier, the product is terminated (knocked out) and the holder receives a small residual value or nothing.

- **Turbo Long (Bull):** Leveraged long position. Knock-out below current price.
- **Turbo Short (Bear):** Leveraged short position. Knock-out above current price.
- **Pricing:** Turbo warrants have minimal time value because the barrier eliminates much of the optionality. Price ≈ (Underlying - Strike) / Ratio for a turbo long.
- **Leverage:** Can be 5x-50x depending on the distance between the current price and the strike/barrier.
- **Funding cost:** Embedded in a daily adjustment to the strike price. The strike drifts higher each day for turbo longs (costing the holder) and lower for turbo shorts.

**Markets:** Very popular in Germany (over 1 million listed products), Netherlands, and Scandinavia.

### Contracts for Difference (CFDs)

A CFD is an agreement between a buyer and seller to exchange the difference in price of an underlying asset from the time the contract is opened to the time it is closed.

**Characteristics:**
- No ownership of the underlying asset.
- Leveraged: Margin requirements typically 5-20% (FCA mandated 3.33%-50% for retail in UK/EU under ESMA rules).
- Overnight financing: Long positions pay a daily financing charge (typically interbank rate + spread). Short positions may receive a credit.
- No expiration (perpetual, in most cases).
- Available on equities, indices, FX, commodities, cryptocurrencies.

**Regulatory landscape:**
- **Banned in the US** — the SEC does not permit CFD trading for US residents.
- **Restricted in EU/UK** — ESMA and FCA imposed leverage limits (30:1 for major FX, 20:1 for indices, 10:1 for commodities, 5:1 for equities, 2:1 for crypto) and negative balance protection for retail.
- **Widely available** in Australia, Singapore, South Africa, and the Middle East (with varying regulation).

**CFD providers:** IG Group, CMC Markets, Plus500, Saxo Bank, Interactive Brokers (non-US).

---

## Cryptocurrency Derivatives

### Bitcoin Futures

#### CME Bitcoin Futures (BTC)

- **Launch:** December 2017.
- **Contract size:** 5 BTC.
- **Tick size:** $5 per BTC ($25 per contract).
- **Settlement:** Cash-settled to the CME CF Bitcoin Reference Rate (BRR) — a volume-weighted average from major spot exchanges (Coinbase, Kraken, Bitstamp, Gemini, LMAX Digital) calculated daily at 4:00 PM London time.
- **Trading hours:** Sun-Fri, 5:00 PM - 4:00 PM CT.
- **Margin:** Approximately 40-50% of notional (significantly higher than traditional futures due to volatility).
- **Position limits:** 2,000 front-month contracts.

#### CME Micro Bitcoin Futures (MBT)

- **Contract size:** 0.1 BTC.
- **Tick size:** $5 per BTC ($0.50 per contract).
- **Launched:** May 2021. Designed for retail and smaller institutional traders.

#### CME Ether Futures (ETH)

- **Contract size:** 50 ETH.
- **Tick size:** $0.25 per ETH ($12.50 per contract).
- **Settlement:** Cash-settled to the CME CF Ether-Dollar Reference Rate.

### Bitcoin Options (CME)

- Options on Bitcoin futures (not spot).
- **Contract size:** 5 BTC (one Bitcoin futures contract).
- **Exercise style:** European.
- **Expiration:** Monthly and weekly (Friday).
- **Pricing:** Standard Black-76 model adapted for high volatility.

### Perpetual Swaps (Crypto-Native Exchanges)

The most popular crypto derivative product, originating from BitMEX (2016) and now offered by Binance, Bybit, OKX, dYdX, and others.

**How perpetual swaps work:**
- No expiration date (unlike traditional futures).
- Tracks the spot price through a **funding rate mechanism**.
- Every 8 hours (on most exchanges), longs pay shorts or shorts pay longs based on the premium/discount to spot.

**Funding rate calculation:**
```
Funding Rate = Premium Index + clamp(Interest Rate - Premium Index, -0.05%, 0.05%)
```
Where:
- Interest Rate = (Quote Currency Rate - Base Currency Rate) / Funding Interval. Typically defaults to 0.01% per 8 hours (approximately 10.95% annualized).
- Premium Index = (Mark Price - Index Price) / Index Price.
- If the funding rate is positive, longs pay shorts (the perpetual is trading at a premium to spot).
- If negative, shorts pay longs.

**Leverage:** Up to 125x on some exchanges (though most professional traders use 1x-10x). Leverage is set per position.

**Liquidation engine:** If the position's unrealized loss exceeds the maintenance margin, the exchange's liquidation engine takes over and force-closes the position. Insurance funds (funded by excess liquidation proceeds) cover the counterparty when liquidations cannot be filled at a profitable price. Socialized loss (auto-deleveraging) is the last resort.

**Mark price vs last traded price:** Exchanges use a "mark price" (typically derived from a multi-exchange index) rather than the last traded price to prevent manipulation-driven liquidations.

### Key Differences: CME Crypto Futures vs Perpetual Swaps

| Feature | CME Futures | Perpetual Swaps |
|---|---|---|
| **Expiration** | Monthly/quarterly | None |
| **Settlement** | Cash (BRR reference rate) | No settlement; funding rate |
| **Regulation** | CFTC-regulated | Largely unregulated (offshore) |
| **Counterparty risk** | CCP-cleared (CME Clearing) | Exchange risk (not cleared) |
| **Leverage** | ~2x-2.5x (50% margin) | Up to 125x |
| **Participants** | Institutional, funds, prop firms | Retail, crypto-native funds |
| **Trading hours** | 23 hours/day, 5 days/week | 24/7/365 |
| **KYC/AML** | Full compliance required | Varies (some no-KYC exchanges) |

### Crypto Options Ecosystem

Beyond CME, the primary crypto options venue is **Deribit** (based in Panama):

- ~90% of crypto options volume globally (as of 2025).
- Bitcoin and Ether options.
- European-style, cash-settled to the Deribit BTC Index.
- Max leverage on options buying is 1x (options must be paid in full).
- Supports complex strategies (spreads, combos).
- Block trading for institutional size.
- Portfolio margining available.

---

## Cross-Margining Between Asset Classes

### Concept

Cross-margining allows margin offsets between positions held at different clearing houses or across different asset classes within the same clearing house. The core principle is that hedged portfolios should require less margin than the sum of the parts.

### CME Cross-Margining Programs

#### CME-OCC Cross-Margin

Allows offsets between:
- CME equity index futures (ES, NQ, etc.)
- OCC-cleared equity index options (SPX, NDX options)
- OCC-cleared equity options and ETF positions

**Example:** A trader who is long SPX put options (cleared at OCC) and long ES futures (cleared at CME) has a partially hedged position. Under cross-margining, the combined requirement is lower than the sum of the individual requirements.

**Requirements:**
- Positions must be in a cross-margin account at an approved dual-member clearing firm.
- The firm must be a clearing member of both CME and OCC.
- Approved by CFTC (futures side) and SEC (securities side).

#### CME-LCH Cross-Margin

Allows offsets between:
- CME Treasury futures (ZN, ZB, etc.)
- LCH-cleared interest rate swaps

A trader with a duration-matched position in Treasury futures and interest rate swaps gets significant margin relief because these positions are highly correlated hedges.

### Eurex Prisma Cross-Margining

Eurex's PRISMA margin system provides cross-margining across:
- Equity index futures and options (FESX, FDAX)
- Fixed income futures and options (FGBL, FGBM, FGBS)
- OTC cleared interest rate swaps (via Eurex Clearing)
- Equity derivatives and repo

PRISMA uses a portfolio-based approach (historical simulation VaR with filtered scenarios) that naturally provides cross-asset margin offsets within a single account.

### Benefits and Considerations

**Benefits:**
- Significant capital savings (30-70% reduction for well-hedged portfolios).
- More accurate representation of true portfolio risk.
- Encourages hedging by not penalizing hedged positions with excessive margin.

**Considerations:**
- Operational complexity: Positions at multiple CCPs must be coordinated.
- Default management: If a member defaults, both CCPs must coordinate the close-out.
- Regulatory approval: Cross-margining between SEC-regulated products and CFTC-regulated products requires dual regulatory oversight.
- Not all brokers offer cross-margin accounts: Firms must be members of both CCPs.

---

## Futures Basis Trading and Arbitrage

### The Basis

The basis is the difference between the futures price and the spot (cash) price of the underlying:

```
Basis = Futures Price - Spot Price
```

For financial futures, the theoretical basis (fair value) is determined by the cost of carry:

```
Fair Value = Spot x (1 + r - d)^T
```

Or, in continuous compounding:

```
F = S x e^((r - q) x T)
```

Where r = risk-free rate, q = dividend yield (or convenience yield for commodities), T = time to expiration.

### Basis Convergence

The basis must converge to zero at expiration (for cash-settled contracts) or to the delivery cost (for physically-settled contracts). This convergence is the foundation of all basis trading.

- **Positive basis (contango):** Futures > Spot. Normal for financial futures (cost of carry is positive when r > q).
- **Negative basis (backwardation):** Futures < Spot. Common in commodity markets with high convenience yield (e.g., during supply shortages).

### Cash-and-Carry Arbitrage

If the futures price exceeds the theoretical fair value (the basis is "rich"):

1. **Buy spot** — Purchase the underlying in the cash market.
2. **Sell futures** — Short the futures contract.
3. **Finance** — Borrow cash to fund the spot purchase (at rate r).
4. **Hold to expiration** — Collect dividends/income from the spot position.
5. **Deliver or settle** — At expiration, the positions converge. The profit is the excess of the futures price over fair value.

**Example (S&P 500):**
- SPX at 4500, ES front-month at 4510.
- Fair value with 30 days to expiration, 5% rate, 1.5% dividend yield: 4500 x e^((0.05 - 0.015) x 30/365) = 4500 x 1.00288 = 4512.96.
- Basis = 4510 - 4500 = 10.00. Fair value basis = 12.96.
- Futures are cheap relative to fair value (negative mispricing of 2.96 points). No cash-and-carry arbitrage opportunity (the basis is actually thin).
- If instead ES were at 4520 (basis = 20.00, vs fair value 12.96), sell ES and buy the basket of S&P 500 stocks for a 7.04 point profit (minus transaction costs).

### Reverse Cash-and-Carry Arbitrage

If the futures price is below fair value (the basis is "cheap"):

1. **Sell/short spot** — Short the underlying.
2. **Buy futures** — Go long the futures.
3. **Invest short sale proceeds** — Earn interest on the cash.
4. **Close at expiration** — Converge, and the profit is the shortfall of the futures price below fair value.

In practice, reverse cash-and-carry is harder because shorting stocks has costs (borrow fees, hard-to-borrow constraints) that may exceed the arbitrage profit.

### Index Arbitrage (Program Trading)

The systematic exploitation of mispricing between index futures and the underlying basket of stocks.

**Implementation:**
1. Monitor the basis in real-time (actual basis vs fair value).
2. When the basis exceeds a threshold (typically a few points of S&P, accounting for transaction costs, market impact, and execution risk): trigger a "buy program" (sell futures, buy stocks) or "sell program" (buy futures, sell stocks).
3. Execute the stock basket via algorithmic execution (VWAP, arrival price, or portfolio trading algorithm) to minimize market impact.
4. Hold the position until expiration (or unwind if the basis reverts).

**Costs that determine the arbitrage threshold:**
- Exchange fees (futures and equity).
- Clearing fees.
- Market impact (buying/selling hundreds of stocks simultaneously).
- Dividend risk (uncertainty in dividend payments and ex-dates).
- Execution slippage.
- Financing cost differential.
- For reverse arb: stock borrowing cost.

**Participants:** Primarily quantitative prop trading firms (Jane Street, Citadel Securities, Jump Trading, Virtu) using automated systems with sub-second execution.

### Bond Basis Trading

For Treasury futures (ZN, ZB), basis trading involves the relationship between futures and the cheapest-to-deliver (CTD) bond.

```
Bond Basis = Cash Price - (Futures Price x Conversion Factor)
```

The basis reflects:
- **Carry:** Net income from holding the bond (coupon accrual minus financing cost).
- **Delivery option value:** The short's option to choose which bond to deliver, when to deliver, and the wildcard option (delivery after the futures market closes but before the delivery notice deadline).

**Basis trade:**
- **Long the basis** (buy bonds, sell futures): Profits if the basis widens or if carry exceeds the basis cost.
- **Short the basis** (sell bonds, buy futures): Profits if the basis narrows.

**Gross basis vs net basis:**
- Gross basis = Cash Price - Futures x CF.
- Net basis = Gross basis - Carry. The net basis represents the delivery option value.
- If net basis = 0, the bond is priced purely on carry and delivery is a certainty.

### ETF Arbitrage

The ETF creation/redemption mechanism creates a continuous arbitrage opportunity:

1. **Premium arbitrage:** If ETF price > NAV, APs buy the underlying basket, create ETF shares, sell on exchange.
2. **Discount arbitrage:** If ETF price < NAV, APs buy ETF shares, redeem for the underlying basket, sell the securities.

This keeps ETF prices within a tight band of NAV. The width of this band depends on:
- Transaction costs for the basket (number of holdings, liquidity).
- Creation/redemption fees (charged by the ETF issuer, typically $250-$1,500 per creation unit).
- Market hours overlap (international ETFs can have wider bands when the underlying market is closed).
- Hedging costs (for bond ETFs, the basket may contain illiquid bonds).

### Commodity Basis Trading

In commodities, the basis reflects physical market conditions:

```
Basis = Local Cash Price - Futures Price
```

**Factors affecting commodity basis:**
- **Transportation costs:** Grain in Iowa vs delivery point in Chicago.
- **Quality differentials:** Different grades of crude oil, different protein content of wheat.
- **Storage costs:** Carrying physical inventory.
- **Convenience yield:** The benefit of holding physical inventory (ability to meet unexpected demand).
- **Local supply/demand:** A refinery shutdown in a region can cause local basis to spike.

**Basis trading in practice:**
- An elevator operator (grain storage) buys grain from farmers at local cash price and sells futures to lock in the basis.
- The operator profits from the basis — the difference between what they pay locally and what they sell forward.
- The basis is their "margin" — if local supply is tight, they pay more (basis narrows or inverts), reducing their margin.

### Statistical Arbitrage with Futures

Beyond pure basis arbitrage, professional desks engage in statistical arbitrage strategies using futures:

- **Pairs trading:** Long one futures contract, short another, based on historical spread relationships (e.g., Brent vs WTI, gold vs silver, ES vs NQ).
- **Mean reversion:** Trade the basis or spread when it deviates significantly from its historical mean.
- **Cointegration-based strategies:** Identify futures pairs that are cointegrated (long-run equilibrium relationship) and trade deviations from the equilibrium.
- **Relative value:** Compare futures-implied interest rates across different maturities to identify mispricings in the yield curve.

### Regulatory Considerations

- **CFTC position limits:** Large traders must report positions exceeding reporting thresholds. Speculative position limits restrict the maximum number of contracts a non-commercial trader can hold.
- **Position accountability:** Above a threshold, the exchange can request information about the position and require reduction.
- **Large Trader Reporting (LTR):** CFTC Form 40 for identification; daily reporting by clearing firms of positions exceeding thresholds.
- **Anti-manipulation rules:** Commodity Exchange Act Section 9(a)(2) prohibits manipulation of commodity prices. Spoofing (placing and quickly canceling orders to create false liquidity) is a criminal offense under Dodd-Frank.
- **Cross-border considerations:** MiFID II in Europe imposes position limits on commodity derivatives and requires position reporting. EMIR requires reporting of all derivatives transactions to a trade repository.

---

*This document serves as a reference for implementing futures and listed derivatives trading features in a professional trading desk application. All contract specifications, margin requirements, exchange rules, and regulatory references should be verified against current exchange and regulatory publications before implementation.*
