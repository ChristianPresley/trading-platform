## Market Microstructure

### 9.1 Bid-Ask Spread Dynamics

The bid-ask spread compensates market makers for three costs:
1. **Adverse selection**: risk of trading against an informed counterparty
2. **Inventory risk**: risk of holding an unhedged position
3. **Order processing**: fixed costs of operating as a market maker

**Spread Determinants**:
| Factor | Effect on Spread |
|--------|-----------------|
| Volatility (higher) | Wider spread |
| Volume (higher) | Narrower spread |
| Tick size (larger) | Constrains minimum spread |
| Number of market makers (more) | Narrower spread |
| Information asymmetry (higher) | Wider spread |
| Stock price level (higher) | Narrower spread (in bps) |

**Intraday Spread Pattern**:
- Widest at the open (high uncertainty)
- Narrows through the morning as price discovery occurs
- Relatively stable during midday
- Narrows further in late afternoon (pre-close liquidity)
- Spikes briefly during news events

**Tick Size**:
- US equities: $0.01 minimum tick for stocks >= $1.00 (Rule 612/Sub-Penny Rule)
- US equities: $0.0001 minimum tick for stocks < $1.00
- EU equities: MiFID II tick size regime (varies by liquidity band)
- SEC tick size pilot (2016-2018) tested wider tick sizes ($0.05) for small-cap stocks; results were mixed and the pilot expired

### 9.2 Order Book Dynamics

**Order Book Levels**:
- Level 1 (L1): best bid and best offer (BBO) with associated sizes
- Level 2 (L2): top N price levels with aggregate size (typically top 5-10 levels)
- Level 3 (L3) / Full Depth: every individual order in the book (available on some venues)
- Market-by-Order (MBO): individual order IDs, allowing tracking of additions, modifications, and cancellations
- Market-by-Price (MBP): aggregated by price level

**Order Book Events**:
- **Add**: new order enters the book
- **Modify**: existing order changes price or quantity
- **Cancel**: existing order is removed
- **Execute**: resting order matches with incoming order
- **Trade**: execution report (from matching engine perspective)

**Depth Analysis**:
- Total resting quantity within N cents of the midpoint
- Bid-ask imbalance: (bid size - ask size) / (bid size + ask size)
- Imbalance is predictive of short-term price direction (positive imbalance = upward pressure)
- "Book pressure" models use multi-level depth imbalance as a signal

### 9.3 Market Maker Behavior

**Designated Market Makers (DMMs)**:
- NYSE assigns a DMM to each listed stock (currently Citadel Securities, GTS, Virtu)
- DMMs have affirmative obligations to maintain fair and orderly markets
- DMMs have certain privileges: see order flow before others (at the open/close), can provide supplemental liquidity
- DMMs participate in NYSE opening and closing auctions

**Electronic Market Makers**:
- Firms that continuously post two-sided quotes (bid and offer) and profit from the spread
- Major firms: Citadel Securities, Virtu Financial, Jump Trading, Two Sigma Securities, Jane Street
- Obligation: none (voluntary), but exchange incentive programs reward consistent quoting
- Behavior: continuously update quotes based on microstructure signals, inventory, and cross-asset correlations

**Market Maker Strategies**:
- Quote management: adjust prices and sizes based on inventory, volatility, and information flow
- Inventory management: hedge accumulated positions via correlated instruments (ETFs, futures, options)
- Adverse selection avoidance: pull quotes when detecting informed flow (widening spreads on news)
- Queue management: maintain priority at the best price by posting early and refreshing strategically

### 9.4 Price Discovery

**Price discovery** is the process by which market prices converge to fundamental value through the interaction of informed and uninformed traders.

**Price Discovery Venues**:
- Historically concentrated on primary listing exchanges (NYSE, NASDAQ)
- Now fragmented across lit exchanges, dark pools, and off-exchange venues
- Studies show that a significant portion of price discovery occurs on off-exchange venues (wholesale market makers executing retail flow often move faster than lit exchanges)
- ETF-underlying stock price discovery: ETF prices can lead their underlying stocks, and vice versa

**Auction Price Discovery**:
- Opening and closing auctions provide concentrated price discovery
- NYSE opening auction: indicative match price published starting at 09:00 ET, with continuous updates
- NASDAQ opening cross: similar mechanism
- Closing auctions account for 7-10% of daily volume and are the primary price-setting mechanism for index-tracking and benchmark-sensitive strategies

### 9.5 Queue Priority

**Queue position** determines the order in which resting orders at the same price are filled. The most common priority rules:

**Price-Time (FIFO)**:
- Orders are prioritized first by price (most aggressive first), then by time of entry
- Used by most US exchanges (NASDAQ, ARCA, BATS)
- Advantage: rewards early commitment of liquidity
- Strategies: "penny jumping" (posting at a marginally better price to jump the queue)

**Price-Size-Time**:
- After price priority, larger orders have priority over smaller ones
- Less common in equities, sometimes used in futures

**Pro-Rata**:
- Orders at the same price share fills proportionally to their size
- Used in some options and futures markets (e.g., CME Eurodollar futures)
- Incentivizes posting large sizes

**Price-Display-Time**:
- Displayed orders have priority over reserve (hidden) orders at the same price
- Standard on most US exchanges
- Reserve order replenishment receives a new timestamp (loses queue position)

**Queue Position Estimation**:
- For passive execution strategies, estimating queue position is critical
- Track own order's entry time relative to the total queue size at that price level
- Estimate probability of fill as a function of queue position and expected volume at that price level
- Market-by-order (MBO) data feeds allow precise tracking of queue position on venues that provide it
