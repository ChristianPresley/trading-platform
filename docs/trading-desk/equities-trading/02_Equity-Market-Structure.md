## Equity Market Structure

### Exchanges

US equity markets operate under Reg NMS (Regulation National Market System), which mandates:

- **Order Protection Rule (Rule 611)**: trade-throughs of protected quotations are prohibited. Execution venues must route to the venue displaying the best price or execute at a price equal to or better.
- **Access Fee Cap (Rule 610)**: maximum $0.0030/share for accessing protected quotations.
- **Sub-Penny Rule (Rule 612)**: quotes in increments of less than $0.01 are prohibited for stocks priced >= $1.00.

**Primary listing exchanges:**
- NYSE (New York Stock Exchange): designated market maker (DMM) model. DMMs have affirmative obligations to maintain fair and orderly markets, quoting at the NBBO a specified percentage of the time.
- NASDAQ: pure electronic limit order book. Three tiers: NASDAQ Global Select Market, NASDAQ Global Market, NASDAQ Capital Market.
- NYSE American (formerly AMEX): hybrid model targeting smaller companies.
- CBOE (Cboe BZX, BYX, EDGX, EDGA): four equity exchanges with distinct fee/rebate structures.
- IEX: speed bump exchange (350 microsecond delay) designed to reduce information asymmetry.
- MEMX (Members Exchange): low-cost exchange launched by consortium of broker-dealers and market makers.
- LTSE (Long-Term Stock Exchange): listing standards encouraging long-term focus.

**European venues:**
- London Stock Exchange (LSE), Euronext (Amsterdam, Paris, Brussels, Lisbon, Dublin, Oslo, Milan), Deutsche Boerse (Xetra), SIX Swiss Exchange, NASDAQ Nordic/Baltic.
- MiFID II / MiFIR regime: best execution obligations, double volume cap on dark trading, systematic internaliser (SI) regime, consolidated tape discussion.

**Asia-Pacific venues:**
- Tokyo Stock Exchange (TSE/JPX), Hong Kong Exchange (HKEX), Shanghai/Shenzhen Stock Exchanges (SSE/SZSE via Stock Connect), Singapore Exchange (SGX), ASX (Australia).

### Electronic Communication Networks (ECNs)

ECNs are electronic systems that automatically match buy and sell orders. In US equities, many have converted to registered exchanges (e.g., Arca was an ECN, now NYSE Arca exchange). Key historical and current examples:

- **Instinet**: one of the earliest ECNs, now part of Nomura.
- **BATS Global Markets**: started as an ECN, became an exchange, now part of Cboe.
- **Direct Edge**: became an exchange, merged into BATS/Cboe.

In modern US markets, the ECN concept is largely subsumed into the exchange and ATS categories.

### Dark Pools (Alternative Trading Systems - ATS)

Dark pools are off-exchange venues that do not display orders in the public quote. They exist to allow large institutional orders to execute without information leakage.

**Types:**
- **Broker-dealer operated**: internal crossing networks (e.g., Goldman Sachs Sigma X, Morgan Stanley MS Pool, JP Morgan JPM-X, UBS ATS).
- **Independent/agency**: operated by non-dealer firms (e.g., IEX before it became an exchange, Liquidnet).
- **Exchange-affiliated**: dark order types on lit exchanges (e.g., NYSE Dark, NASDAQ midpoint orders).

**Matching mechanisms:**
- Midpoint matching: orders execute at the NBBO midpoint. No price improvement beyond mid.
- Pegged matching: orders pegged to near, far, or midpoint of NBBO.
- Conditional/indication of interest (IOI): venue sends an IOI to contra-side when a potential match exists; both sides must firm up to trade.
- Periodic auctions: orders collect and match in discrete intervals (e.g., Cboe Periodic Auctions in Europe).

**Regulatory considerations:**
- SEC Form ATS-N: enhanced transparency requirements for NMS Stock ATSs.
- FINRA ATS transparency data: bi-weekly publication of per-security ATS volume.
- MiFID II double volume cap (DVC): limits dark trading to 4% of total volume on any single venue and 8% across all dark venues per instrument (EU).

### OTC (Over-the-Counter)

- **OTC Markets Group** (formerly Pink Sheets): three tiers - OTCQX (highest standards), OTCQB (venture market), Pink (minimal disclosure).
- **Bulletin board stocks**: less regulated, wider spreads, lower liquidity.
- **Wholesale market makers**: firms like Citadel Securities, Virtu Financial, and others execute retail order flow off-exchange as OTC market makers, internalising the flow and providing price improvement vs. NBBO.

### Auction Mechanisms

**Opening Auction:**
- Aggregates all pre-market orders (MOO, LOO, limit, market) and determines a single opening price that maximizes matched volume.
- NYSE: DMM facilitates the open; can use supplemental liquidity providers (SLPs) and their own capital.
- NASDAQ: opening cross uses a reference price and imbalance information published starting at 9:20 AM ET.
- Imbalance data dissemination: exchanges publish indicative match price, match volume, and buy/sell imbalance in the minutes leading up to the auction. This data is a key input for algorithmic strategies benchmarked to the open.

**Closing Auction:**
- The most liquid event of the trading day. In US equities, closing auctions routinely account for 7-10%+ of daily volume.
- NYSE: closing auction uses MOC, LOC, and closing offset (CO) orders. Imbalance information published starting at 3:45 PM ET.
- NASDAQ: closing cross, similar structure.
- D-orders (NASDAQ) and closing-only orders concentrate liquidity at the close.
- Index fund rebalancing, ETF NAV calculations, and portfolio valuations all reference closing prices, driving massive closing auction participation.

**Intraday Auctions:**
- Some exchanges run periodic intraday auctions (e.g., Cboe Europe Periodic Auctions, LSE periodic auctions).
- These are typically non-displayed, randomized-duration auctions that collect orders and match periodically.
- Used to comply with MiFID II dark trading caps while still providing midpoint-like execution quality.
- Volatility auctions: triggered when a stock's price moves beyond a threshold during continuous trading (circuit breaker). The exchange halts continuous trading and runs an auction to re-establish a price.

**Halt/IPO Auctions:**
- Used to resume trading after a regulatory halt (LULD - Limit Up Limit Down halt, news halt) or to open trading in a newly listed security (IPO).
- Extended order entry period followed by a price discovery mechanism similar to opening/closing auctions.
