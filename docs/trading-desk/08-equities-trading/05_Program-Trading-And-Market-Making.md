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
