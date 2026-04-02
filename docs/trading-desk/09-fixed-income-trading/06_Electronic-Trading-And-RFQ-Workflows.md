## RFQ (Request for Quote) Workflows

### Standard RFQ Process

The RFQ is the dominant electronic trading protocol in fixed income.

**Workflow:**
1. **Client initiates**: specifies security (CUSIP/ISIN), direction (buy/sell), and quantity (face amount). May include a target price or leave it open.
2. **Dealer selection**: client selects 3-10 dealers to compete for the trade (platform rules may require a minimum number of dealers).
3. **Quote submission**: dealers have a defined time window (30 seconds to several minutes, depending on the platform and asset class) to submit firm, executable prices.
4. **Comparison and execution**: client compares all received quotes and selects the best price (or rejects all). Execution is immediate upon selection.
5. **Trade confirmation and reporting**: platform generates trade confirmations and reports to TRACE (or equivalent).

**RFQ variations:**
- **Indicative RFQ**: dealers provide indicative (non-binding) prices. Client may follow up bilaterally for a firm price.
- **Disclosed vs anonymous**: most D2C RFQs are disclosed (the client reveals their identity). Some platforms offer anonymous RFQ.
- **Dealer-to-dealer RFQ**: interdealer platforms like Tradeweb D2D or Bloomberg IB allow dealers to RFQ each other.

### RFQ Optimization

**For the client (buy-side):**
- **Dealer selection strategy**: balance between competitive tension (more dealers) and information leakage (each dealer knows you are looking to trade).
- **Timing**: RFQ during active hours (10 AM - 3 PM ET for US credit) yields tighter quotes.
- **Size signaling**: very large sizes may cause dealers to widen their quotes or decline. Consider breaking large orders into smaller RFQs.
- **Auto-execution rules**: set up automated acceptance of quotes that meet specified price thresholds.

**For the dealer (sell-side):**
- **Pricing engine**: automated pricing based on inventory position, market conditions, client tier, and expected information content.
- **Win rate optimization**: track hit rates per client and adjust pricing to optimize the revenue vs risk trade-off.
- **Inventory management**: integrate RFQ responses with overall inventory position and risk limits.
- **Axes**: proactively advertise bonds the desk wants to buy or sell (axed inventory) to attract matching RFQs.

### All-to-All Trading

A newer model where any participant (not just traditional dealers) can respond to RFQs or provide liquidity:

- **MarketAxess Open Trading**: the leading all-to-all protocol. Any client can respond to an RFQ, not just dealers. This democratizes liquidity provision.
- **Trumid**: all-to-all platform for credit.
- **Benefits**: more liquidity sources, tighter spreads, particularly for off-the-run/less liquid bonds.
- **Challenges**: credit intermediation (how to manage counterparty risk when non-dealers are trading), settlement logistics.

---

## Electronic Bond Trading Evolution and Protocols

### Historical Evolution

**Pre-2000: Voice-only**
- All bond trading conducted via phone between traders.
- Pricing was opaque; no post-trade transparency.
- Dealer balance sheets funded large inventory positions.

**2000-2010: Early electronification**
- RFQ platforms launched (TradeWeb for government bonds, MarketAxess for credit).
- TRACE introduced post-trade transparency for US corporate bonds (2002).
- Electronic trading share: government bonds ~50%, IG credit ~10-15%.

**2010-2020: Acceleration**
- MiFID II (2018) mandated pre- and post-trade transparency and best execution.
- All-to-all protocols emerged (MarketAxess Open Trading, Trumid).
- Portfolio trading protocols launched.
- Algo/systematic trading entered fixed income.
- Electronic share of IG credit trading grew to ~35-40%.

**2020-present: Maturation**
- COVID-19 pandemic accelerated electronification (voice trading difficult with remote work).
- Portfolio trading became a major protocol for credit (~6-8% of US IG volume).
- Automated/algo execution by buy-side firms increased.
- Electronic share: IG credit ~40-50%, HY credit ~30-35%, government bonds ~70-80%.

### Trading Protocols

**Click-to-Trade (Streaming):**
- Dealers stream continuous firm prices to clients.
- Client clicks to execute at the displayed price.
- Dominant in government bonds (especially on-the-runs) and liquid IG credit.
- Requires the dealer to manage quote staling risk (prices become stale in fast markets).

**Central Limit Order Book (CLOB):**
- Continuous anonymous order matching (like equity exchanges).
- Used for government bonds on BrokerTec and MTS (D2D).
- Limited adoption for corporate bonds due to lower liquidity and heterogeneity of instruments.

**Portfolio Trading:**
- Client submits a basket of bonds (50 to 1000+ line items) as a single package.
- Dealers bid on the entire portfolio, providing a single price (typically expressed as a spread to a benchmark or as a percentage of par).
- Benefits: operational efficiency (one execution for many bonds), potential for netting (dealer may already own some bonds in the basket or can cross-hedge).
- Dominant in ETF creation/redemption baskets and large portfolio rebalances.
- Platforms: Tradeweb, MarketAxess, Bloomberg.

**Session-Based Trading:**
- Orders are collected during a defined window and then matched in a crossing session.
- Used by some platforms for less liquid bonds.

**Processed Trading / Work-Up:**
- After an initial trade on a CLOB, other participants can "work up" additional volume at the same price for a limited time.
- Common on BrokerTec for Treasuries.

### Data and Analytics in Electronic Trading

**Composite pricing:**
- Aggregation of dealer quotes and trade data to establish a "fair value" mid-price.
- MarketAxess CP+ (Composite Plus), Bloomberg BVAL, ICE Pricing, Refinitiv evaluated pricing.
- Used as a pre-trade benchmark, a reference for RFQ evaluation, and for portfolio valuation.

**Transaction Cost Analysis (TCA):**
- Post-trade analysis of execution quality relative to benchmarks (arrival price, composite mid, VWAP equivalent).
- Increasingly mandated by regulations (MiFID II best execution) and demanded by asset owners.
- Metrics: implementation shortfall, spread to mid at time of trade, market impact.

**Liquidity scores:**
- Vendor-provided estimates of bond liquidity (frequency of trading, number of dealers quoting, depth of quotes, bid-ask spread).
- Used for portfolio liquidity risk management, trade scheduling, and venue selection.
- Examples: MarketAxess Liquidity Score, Bloomberg LQA, ICE Liquidity Indicators.

---

## Key Data Requirements for a Fixed Income Trading Platform

| Data Type | Sources | Update Frequency |
|---|---|---|
| Reference data (CUSIP, ISIN, terms, covenants) | Bloomberg, Refinitiv, ICE | Daily with event-driven |
| Real-time quotes | Tradeweb, MarketAxess, Bloomberg, dealer streams | Real-time |
| Trade reporting (TRACE) | FINRA | Real-time (15-min delay public) |
| Yield curves (government, swap, OIS) | Bloomberg, Refinitiv, internal curve engines | Real-time/intraday |
| Credit ratings | S&P, Moody's, Fitch | Event-driven |
| CDS spreads | Markit (S&P Global), Bloomberg | End-of-day / intraday |
| Prepayment models and speeds | Andrew Davidson, Yield Book, Bloomberg | Monthly actuals, daily model updates |
| Repo rates (GC and specials) | DTCC GCF Repo Index, SOFR, dealer indications | Daily |
| Index compositions and analytics | Bloomberg Barclays, ICE BofA, JP Morgan, FTSE Russell | Daily |
| New issue calendars | Bloomberg, IFR, Dealogic | Daily/event-driven |
| Regulatory filings (13F, EMMA for munis) | SEC EDGAR, MSRB EMMA | Periodic |
