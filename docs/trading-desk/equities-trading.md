# Equities Trading

Comprehensive reference for equity asset-class features on a professional trading desk. Covers cash equities, derivatives overlays, market structure, and operational workflows relevant to building a trading platform.

---

## Table of Contents

1. [Cash Equities Trading](#cash-equities-trading)
2. [Equity Market Structure](#equity-market-structure)
3. [IPO and Secondary Offering Participation](#ipo-and-secondary-offering-participation)
4. [Short Selling Mechanics](#short-selling-mechanics)
5. [Equity Index Trading](#equity-index-trading)
6. [Block Trading and the Upstairs Market](#block-trading-and-the-upstairs-market)
7. [Equity Swaps and Synthetic Positions](#equity-swaps-and-synthetic-positions)
8. [Program Trading and Portfolio Rebalancing](#program-trading-and-portfolio-rebalancing)
9. [Market Making in Equities](#market-making-in-equities)
10. [Small Cap vs Large Cap Trading Considerations](#small-cap-vs-large-cap-trading-considerations)
11. [Pre/Post Market Trading (Extended Hours)](#prepost-market-trading-extended-hours)

---

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

---

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

---

## IPO and Secondary Offering Participation

### IPO Process (Primary Market)

- **Book building**: lead underwriter(s) solicit indications of interest (IOIs) from institutional investors during the roadshow period. IOIs specify share quantity and sometimes price limits.
- **Allocation**: underwriter allocates shares based on investor quality, long-term holding intent, and relationship factors. Allocations are discretionary.
- **Pricing**: IPO price is set the night before the first trading day based on the order book, market conditions, and issuer/underwriter negotiation.
- **Stabilization**: the underwriter may engage in stabilizing transactions (buying shares in the aftermarket) to support the IPO price. The greenshoe option (over-allotment option, typically 15% of the offering) allows the underwriter to sell additional shares and buy them back if the price drops.
- **Lock-up period**: insiders and pre-IPO investors are typically restricted from selling for 90-180 days after the IPO.

**Trading desk considerations:**
- IOI submission and tracking workflow.
- Allocation notification parsing and position booking.
- First-day trading: often volatile with wide spreads. Market makers in the IPO typically get the first look at the order book.
- Tracking lock-up expiry dates for potential supply events.

### Secondary Offerings

- **Follow-on offerings**: additional shares issued by an already-public company. Can be dilutive (new shares) or non-dilutive (selling shareholders).
- **Accelerated bookbuilds (ABBs)**: overnight block offerings, typically priced at a discount to the closing price. Common in European and Asian markets.
- **At-the-market (ATM) offerings**: issuer sells shares gradually through a broker-dealer at prevailing market prices. Minimal price impact but slower capital raise.
- **Rights issues**: existing shareholders offered the right to buy new shares at a discount. Rights may be tradeable.
- **Block trades**: large secondary sales by existing holders (private equity exits, insider sales). See Block Trading section.

**Trading desk workflow:**
- Receive deal terms (pricing, size, discount).
- Decision to participate based on fundamental view and portfolio fit.
- Allocation tracking and settlement (typically T+1 or T+2 depending on jurisdiction).
- Hedging during the offering period if participating as an underwriter or syndicate member.

---

## Short Selling Mechanics

### Locate and Borrow

Before selling short, the broker-dealer must have reasonable grounds to believe the security can be borrowed for delivery on settlement date (SEC Reg SHO Rule 203(b)(1)).

**Locate process:**
1. Trader submits locate request specifying security and quantity.
2. Securities lending desk checks internal inventory (long positions held in margin accounts, proprietary positions).
3. If not available internally, the desk contacts external lenders (custodian banks, asset managers, pension funds, insurance companies) or uses electronic locate platforms (e.g., EquiLend, NGT, SL-x).
4. Locate is granted with a rate (borrow cost) expressed in basis points or fee per share.
5. Locate is valid for the trading day; pre-borrows can lock shares for multi-day availability.

**Borrow cost components:**
- **General collateral (GC)**: easy-to-borrow securities. Borrow rate is minimal (close to the federal funds rate or slightly above).
- **Specials**: hard-to-borrow securities command a premium rate, sometimes hundreds of basis points.
- **Collateral**: short seller posts cash collateral (typically 102% of the borrowed security's value for US domestic, 105% for international). The lender rebates interest on this cash minus the borrow fee (the "rebate rate"). A negative rebate means the borrower is paying more than the risk-free rate.
- **Mark-to-market**: collateral is adjusted daily based on the security's closing price.

### Hard-to-Borrow (HTB) Lists

- Maintained by prime brokers and updated daily (sometimes intraday).
- Securities on the HTB list have limited supply relative to demand. Locates may be unavailable or available only at elevated rates.
- Factors driving HTB status: high short interest, small float, concentrated ownership, corporate events (mergers, spin-offs), regulatory restrictions.
- Trading platforms must integrate HTB status into the order entry workflow, preventing short sales when no locate is available.

### Recall Risk

- The securities lender can recall borrowed shares at any time (subject to contractual notice periods, typically T+2 or T+3).
- Recall triggers: lender wants to sell the position, lender needs shares for a proxy vote, corporate action requiring share tender.
- Upon recall, the short seller must either: find an alternative borrow or buy the shares in the market (forced buy-in).
- **Buy-in risk**: if the short seller fails to deliver shares by settlement, the broker or clearinghouse initiates a buy-in, purchasing shares in the open market at potentially unfavorable prices.
- CSDR (EU Central Securities Depositories Regulation) imposes mandatory buy-in penalties for settlement fails.

### Short Interest and Data

- **Short interest**: total shares sold short, reported by FINRA bi-monthly (settlement dates around mid-month and end-of-month).
- **Days to cover (short interest ratio)**: short interest divided by average daily volume. Higher values indicate more crowded short positions.
- **Utilization**: shares on loan divided by shares available to lend. High utilization (>90%) signals a crowded borrow.
- **Cost to borrow**: available from securities lending data providers (IHS Markit / S&P Global, DataLend, FIS Astec Analytics).
- Short squeeze dynamics: when a heavily shorted stock rises, short sellers buy to cover, driving the price higher in a feedback loop.

### Regulatory Framework

- **Reg SHO (US)**: locate requirement, close-out requirement for fails to deliver, threshold securities list.
- **Short Sale Circuit Breaker (Rule 201 / Alternative Uptick Rule)**: when a stock drops 10% or more from the prior day's close, short sales are restricted to prices above the national best bid for the remainder of that day and the following day.
- **EU Short Selling Regulation (SSR)**: disclosure requirements for net short positions (0.2% to regulators, 0.5% to the public). Ban on naked short selling.
- **Market-wide short selling bans**: regulators may impose temporary bans during market stress (as seen in 2008, 2020).

---

## Equity Index Trading

### Index Futures

- Cash-settled futures contracts on equity indices (S&P 500, NASDAQ 100, Dow Jones, Russell 2000, Euro Stoxx 50, FTSE 100, Nikkei 225, Hang Seng, etc.).
- **Contract specifications**: multiplier (e.g., $50 per point for E-mini S&P 500), tick size ($0.25 = $12.50 per contract), quarterly expiration (March, June, September, December), daily settlement.
- **Micro contracts**: smaller notional (e.g., Micro E-mini S&P 500 = $5 per point) for finer position sizing.
- **Basis**: futures price minus spot index price. Reflects cost of carry (interest rate minus dividend yield) and supply/demand imbalances.
- **Roll**: traders roll positions from the expiring contract to the next quarter. Roll period typically begins 8 trading days before expiration. Roll spread is quoted and traded as a calendar spread.
- **Fair value**: theoretical futures price based on carry model. Deviations from fair value create arbitrage opportunities (see index arbitrage below).

### ETF Creation/Redemption and Index Arbitrage

**Creation/redemption mechanism:**
1. Authorized participant (AP) observes the ETF trading at a premium to NAV.
2. AP buys the underlying basket of securities and delivers them to the ETF issuer.
3. ETF issuer creates new ETF shares and delivers them to the AP.
4. AP sells ETF shares in the market, capturing the premium as profit.
5. Reverse process for discounts: AP buys ETF shares, redeems them for the underlying basket, sells the basket.

**Index arbitrage (cash-futures arbitrage):**
- When the futures basis exceeds fair value: buy the underlying basket, sell the futures contract.
- When the futures basis is below fair value: sell the underlying basket (or short), buy the futures contract.
- Execution speed is critical; high-frequency firms dominate this space.
- Transaction costs, borrowing costs (for short baskets), and execution risk limit arbitrage profitability.
- Program trading systems execute the basket leg rapidly across multiple exchanges.

**ETF-futures arbitrage:**
- Three-way relationship: index futures, index ETF, and underlying basket.
- Any persistent mispricing between pairs creates an arbitrage opportunity.

### Index Rebalancing

- Major indices (S&P 500, Russell, MSCI) rebalance periodically (quarterly or annually).
- Additions and deletions drive significant volume: stocks being added experience buying pressure; stocks being removed experience selling pressure.
- Announcement-to-effective date window creates a trading opportunity.
- Float adjustments, share count changes, and sector reclassifications also trigger rebalancing flows.
- Estimated tracking AUM for major indices runs into trillions of dollars, making rebalance trades among the largest predictable flows in the market.

---

## Block Trading and the Upstairs Market

### Definition and Thresholds

- A block trade is a large transaction negotiated privately between institutional counterparties, typically above a minimum size threshold (e.g., 10,000 shares or $200,000 in notional value, though practical thresholds are much higher).
- "Upstairs market" refers to the off-exchange negotiation process, contrasted with the "downstairs" exchange order book.

### Block Trading Workflow

1. **Indication of interest (IOI)**: the sell-side trader broadcasts IOIs to the buy-side indicating availability of a block (natural or facilitation). IOIs may be "natural" (representing a real client order) or "conditional."
2. **Price negotiation**: parties negotiate a price, typically referencing the last sale, VWAP, NBBO midpoint, or a fixed percentage discount/premium.
3. **Execution**: once agreed, the block is executed as a single trade, often printed to exchange tape or reported to FINRA TRF (Trade Reporting Facility).
4. **Risk transfer**: in a facilitation/principal trade, the dealer takes the other side of the client's order onto their own book and hedges the position.

### Venues and Protocols

- **Liquidnet**: buy-side-only dark pool for block crossing. Members see aggregated IOIs; no information leakage to sell-side.
- **POSIT (ITG/Virtu)**: crossing network for institutional blocks.
- **Broker-dealer block desks**: traders at bulge bracket firms facilitate blocks using their balance sheet.
- **Request for Block (RFB)**: electronic protocol where the buy-side requests a block bid/offer from multiple dealers simultaneously.

### Pricing Considerations

- **Volume-weighted risk**: larger blocks relative to ADV (average daily volume) require larger discounts.
- **Information content**: blocks that signal informed trading (e.g., from well-known fundamental managers) command larger discounts than those from index funds or rebalancing flows.
- **Market impact**: estimated using models like Almgren-Chriss or proprietary TCA (transaction cost analysis) frameworks.
- **Guaranteed VWAP**: dealer guarantees execution at the day's VWAP, absorbing the risk of achieving that benchmark.

---

## Equity Swaps and Synthetic Positions

### Total Return Swaps (TRS)

A total return swap transfers the economic exposure of a stock or basket without transferring ownership.

**Structure:**
- **Equity leg**: one party (the long side) receives the total return of the reference equity (price appreciation/depreciation + dividends).
- **Financing leg**: the long side pays a financing rate (typically SOFR/SONIA + spread) on the notional amount.
- **Settlement**: periodic (monthly, quarterly) or at maturity. Can be physical or cash settlement.

**Use cases:**
- **Leveraged exposure**: investor gains synthetic long exposure without funding the full purchase price.
- **Regulatory capital efficiency**: may require less capital than outright ownership depending on jurisdiction and entity type.
- **Short exposure**: the short side of the TRS is economically short the reference equity.
- **Tax and dividend optimization**: in some jurisdictions, swap-based exposure has different tax treatment for dividends (withholding tax reclaim, manufactured dividends).
- **Disclosure avoidance**: in certain jurisdictions, swap positions may not count toward ownership disclosure thresholds (though regulations are tightening, e.g., SEC Rule 13d amendments).

### Contract for Difference (CFD)

- Common in European and Asian markets; not available to US retail investors.
- Economically similar to a TRS but structured as a leveraged derivative product.
- Trader posts initial margin (e.g., 5-20% of notional) and pays/receives the daily P&L on the reference security.
- Financing cost embedded as an overnight funding charge.

### Portfolio Swaps

- A single swap referencing a basket of securities, rebalanced periodically.
- Used by hedge funds for leveraged long/short portfolios.
- The prime broker is the swap counterparty, managing the hedge portfolio.
- Margin terms, concentration limits, and eligible securities are defined in the ISDA/CSA documentation.

### Implementation Considerations

- **Valuation**: mark-to-market based on reference security price, accrued financing, and accrued dividends.
- **Corporate actions**: swap terms must specify handling of dividends, splits, mergers, spin-offs, and other corporate events.
- **Counterparty credit risk**: managed via collateral/margin agreements (CSA - Credit Support Annex).
- **Regulatory reporting**: swap positions must be reported to trade repositories (DTCC, REGIS-TR) under Dodd-Frank / EMIR.

---

## Program Trading and Portfolio Rebalancing

### Program Trading

- Defined broadly as the simultaneous purchase or sale of a basket of 15 or more stocks with a total value exceeding $1 million (historical NYSE definition).
- Modern usage: any systematic basket execution, typically managed by an algorithmic execution engine.

**Use cases:**
- Index fund replication and rebalancing.
- ETF creation/redemption basket execution.
- Transition management (shifting a portfolio from one manager/strategy to another).
- Tax-loss harvesting across a portfolio.
- Factor portfolio construction (buying a long basket, selling a short basket).

**Execution approaches:**
- **Agency**: broker executes the basket as agent, using algorithms (VWAP, TWAP, IS) to minimize market impact.
- **Principal/risk**: broker takes the entire basket as a principal trade at an agreed price (typically NAV + spread).
- **Guaranteed benchmarks**: broker guarantees execution at a specific benchmark (VWAP, closing price, arrival price).

### Portfolio Rebalancing

**Triggers:**
- Calendar-based: monthly, quarterly, annual rebalancing to target weights.
- Threshold-based: rebalance when any position drifts beyond a tolerance band (e.g., +/- 2% of target weight).
- Cash flow: new subscriptions/redemptions require proportional buying/selling.
- Index reconstitution: changes in benchmark composition require corresponding portfolio changes.

**Optimization:**
- Minimize transaction costs (spread, impact, commissions) while achieving the target portfolio.
- Tax-aware rebalancing: avoid realizing short-term gains; harvest losses where possible.
- Factor exposure management: ensure rebalance trades don't introduce unintended factor tilts.
- **Rebalance trade list generation**: optimizer outputs a trade list specifying shares to buy/sell for each security, considering lot-level tax information, round lot preferences, and minimum trade size thresholds.

### Transition Management

- Specialized form of program trading for moving a large portfolio between strategies or managers.
- **Pre-trade analysis**: estimate tracking error and implementation shortfall during the transition period.
- **Legacy portfolio**: current holdings to be liquidated or retained.
- **Target portfolio**: desired end-state holdings.
- **Crossing**: overlap between legacy and target portfolios is "crossed" (netted), reducing the volume that must trade in the market.
- **Interim portfolio management**: during a multi-day transition, the in-progress portfolio must be managed for risk (e.g., maintaining beta neutrality).

---

## Market Making in Equities

### Role and Obligations

Market makers provide liquidity by continuously quoting two-sided markets (bids and offers).

**Designated Market Makers (DMMs) on NYSE:**
- Assigned to specific securities.
- Obligations: maintain fair and orderly markets, facilitate the opening and closing auctions, provide price improvement, dampen volatility.
- Compensation: information advantage (seeing the order book), maker rebates, reduced fees.

**Registered market makers on NASDAQ/other exchanges:**
- Voluntary registration per security.
- Quoting obligations: must maintain two-sided quotes during regular trading hours, meeting minimum size and maximum spread requirements.
- Benefits: enhanced rebates, reduced access fees, participation in certain order types.

**Systematic Internalisers (SIs) under MiFID II (Europe):**
- Investment firms that deal on their own account on an organized, frequent, systematic basis outside a trading venue.
- Must publish firm quotes in liquid instruments when dealing above standard market size.
- Effectively, in-house market making to client flow.

### Inventory Management

- **Inventory risk**: market makers accumulate positions as they fill client orders. Holding inventory exposes them to adverse price movements.
- **Skewing**: adjusting bid/offer prices based on current inventory. If the market maker is long, they lower their bid (to discourage further buying from clients) and lower their offer (to encourage selling to clients, which reduces inventory).
- **Position limits**: internal risk limits on maximum inventory per name, sector, and overall portfolio.
- **End-of-day flattening**: many market makers target flat or near-flat positions by end of day to avoid overnight risk.

### Hedging Strategies

- **Single-stock hedging**: delta hedging via the underlying stock or correlated instruments.
- **Portfolio hedging**: using index futures, ETFs, or sector ETFs to hedge systematic risk in the market-making portfolio.
- **Statistical hedging**: using pairs/basket relationships to hedge idiosyncratic risk (e.g., hedging a long position in stock A with a short in highly correlated stock B).
- **Options hedging**: using options to manage tail risk on concentrated inventory positions.

### Economics

- **Bid-ask spread capture**: the primary revenue source. Market makers profit from the spread when they buy at the bid and sell at the offer.
- **Rebate capture**: maker-taker exchanges pay rebates (typically $0.0020-$0.0032/share) for posted liquidity.
- **Adverse selection costs**: informed traders (who have superior information) tend to pick off stale quotes, causing losses for market makers. Managing adverse selection is the central challenge.
- **Speed**: lower latency enables faster quote updates, reducing adverse selection. This drives investment in co-location, FPGA/ASIC hardware, and optimized network infrastructure.

---

## Small Cap vs Large Cap Trading Considerations

### Liquidity Differences

| Characteristic | Large Cap | Small Cap |
|---|---|---|
| Average daily volume | High (millions of shares) | Low (tens of thousands) |
| Bid-ask spread | Tight (1-2 cents) | Wide (5-50+ cents) |
| Market depth | Deep (large size at each level) | Shallow |
| Number of market makers | Many | Few |
| Dark pool availability | Extensive | Limited |
| Analyst coverage | Broad | Sparse |
| Index inclusion | Major indices (S&P 500, etc.) | Russell 2000, small-cap indices |
| Institutional ownership | High | Variable |

### Execution Challenges in Small Caps

- **Market impact**: even modest order sizes can move the price significantly. A $500,000 order may represent several days of volume.
- **Information leakage**: fewer participants means orders are more easily detected.
- **Limited algo effectiveness**: standard participation algorithms may not find enough liquidity. Dark pool hit rates are low.
- **Wider benchmarking uncertainty**: VWAP and other volume-based benchmarks are noisier with lower volume.

### Small Cap Execution Strategies

- **Patience**: use very low participation rates (1-5% of volume) and extend the execution horizon.
- **Natural block matching**: use platforms like Liquidnet where other institutional holders may provide natural contra-side liquidity.
- **Limit-order strategies**: work orders passively at the bid or midpoint, avoiding taking liquidity.
- **Avoid momentum signals**: do not rush to complete orders in small caps, as this creates price momentum that works against the position.
- **Broker selection**: choose brokers with strong small-cap coverage and market-making activity, as they may have natural other-side flow.

### Large Cap Execution

- Rich venue selection: dark pools, lit exchanges, wholesale market makers all compete for order flow.
- Algorithmic execution highly effective due to predictable volume profiles and deep liquidity.
- Primary challenge is minimizing information leakage in very large orders (multiple days of ADV).
- Electronic market making is most competitive in large caps; spreads are at their tightest.

---

## Pre/Post Market Trading (Extended Hours)

### US Extended Hours Sessions

**Pre-market:**
- Available on most exchanges and ECNs from 4:00 AM ET to 9:30 AM ET (some venues open as early as 4:00 AM, others at 7:00 AM or 8:00 AM).
- Key period: 8:00-9:30 AM ET when economic data releases and pre-market earnings reactions create meaningful volume.

**Post-market (After Hours):**
- Available from 4:00 PM ET to 8:00 PM ET.
- Driven by after-hours earnings announcements and news events.

### Characteristics of Extended Hours Trading

- **Lower liquidity**: significantly less volume than regular trading hours. Bid-ask spreads are wider.
- **Higher volatility**: prices can move sharply on relatively small volume, especially around earnings announcements.
- **Limit orders only**: most venues only accept limit orders during extended hours (no market orders) to protect participants from adverse fills in thin markets.
- **No auction mechanism**: extended hours are continuous trading only; there are no opening/closing auctions.
- **Fragmentation**: fewer participants, fewer venues active, and no Reg NMS order protection (trade-through protection does not apply outside regular trading hours).

### Use Cases

- **Earnings reaction**: trading immediately after earnings announcements (most US companies report before the open or after the close).
- **News response**: reacting to corporate news, M&A announcements, geopolitical events, or economic data releases.
- **International overlap**: pre-market session overlaps with European trading hours, allowing cross-market hedging and reaction to European developments.
- **Risk management**: closing or hedging positions in response to post-market news without waiting for the next day's open.

### Implementation Considerations

- **Order routing**: must specify extended-hours eligibility when submitting orders. Not all venues accept extended-hours orders.
- **Risk controls**: wider price bands for limit checks, as extended-hours prices can diverge significantly from regular-session closes.
- **Market data**: extended-hours trades are reported to the consolidated tape but distinguished from regular-session trades.
- **Gap risk**: the opening auction on the following day may gap significantly from extended-hours prices as broader participation arrives.
- **Settlement**: extended-hours trades settle on the same cycle as regular-session trades (T+1 in US equities as of May 2024).

---

## Key Data Requirements for an Equities Trading Platform

A comprehensive equities trading system requires integration with the following data sources:

| Data Type | Sources | Latency Requirements |
|---|---|---|
| Real-time quotes and trades | Direct exchange feeds (e.g., NYSE Pillar, NASDAQ ITCH), SIP (CTA/UTP) | Microseconds to milliseconds |
| Depth of book | Exchange direct feeds, Level 2 / TotalView | Microseconds |
| Short locate availability | Internal inventory, EquiLend, broker APIs | Real-time to minutes |
| Corporate actions | Bloomberg, Refinitiv, ISO 15022/20022 feeds | Daily/event-driven |
| Index compositions | Index providers (S&P, MSCI, FTSE Russell) | Daily with event-driven updates |
| ETF creation baskets | ETF issuers, NSCC | Daily |
| IPO/offering calendars | Underwriter allocations, Bloomberg, Dealogic | Daily/event-driven |
| Regulatory thresholds | Reg SHO threshold list, short sale circuit breaker status | Real-time |
| Reference data | CUSIP, ISIN, SEDOL, FIGI, ticker symbology | Daily |
| Trading calendars | Exchange holiday/half-day schedules by market | Annually with updates |
