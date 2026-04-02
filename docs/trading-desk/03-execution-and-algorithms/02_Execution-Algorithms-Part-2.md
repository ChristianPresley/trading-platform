## Execution Algorithms (Part 2)

### 1.5 MOC (Market-on-Close) / Close Algorithms

**Objective**: Execute at or near the official closing price (the closing auction price on the primary listing exchange).

**Types**:

**Pure MOC**: Submit the entire order as a Market-on-Close order to the primary exchange's closing auction. Simple but exposes the full order size in the auction imbalance data (published starting around 15:50 ET for NYSE, 15:55 ET for NASDAQ).

**Close Algo (Aggressive Close)**: Executes a portion of the order throughout the last 15-30 minutes of continuous trading, with the remainder submitted to the closing auction. This reduces the quantity exposed in auction imbalance data and provides some pre-close liquidity.

**Close Algo Scheduling**:
- The algorithm must decide what percentage to trade pre-close vs. auction
- Higher pre-close percentage: reduces auction impact but increases tracking error vs. close price
- The optimal split depends on expected closing auction volume, stock volatility, and order size
- Typical split: 30-50% pre-close, 50-70% in auction for orders that are small relative to closing auction volume

**Auction Mechanics (NYSE)**:
- 15:50 ET: order imbalance data begins publishing (regulatory imbalance only)
- 15:55 ET: continuous order imbalance data with indicative match price
- 16:00 ET: closing auction executes
- MOC and LOC (Limit-on-Close) orders are irrevocable after 15:50 ET (NYSE) or 15:55 ET (NASDAQ)
- D-orders and closing offset orders provide additional flexibility

**Common Parameters**:
| Parameter | Description |
|-----------|-------------|
| `AuctionPct` | Percentage to allocate to the closing auction |
| `PreCloseStartTime` | When to begin pre-close trading (e.g., 15:30 ET) |
| `PriceLimit` | Limit price for pre-close and/or LOC component |
| `Urgency` | Controls pre-close aggressiveness |
| `ImbalanceReaction` | Whether to adjust the auction/pre-close split based on imbalance data |

---

### 1.6 Iceberg / Reserve Orders

**Objective**: Display only a fraction of the total order quantity on the order book, automatically replenishing the displayed quantity as it fills.

**Mechanism**: The exchange (or the algo) maintains a total quantity and a display quantity. When the displayed portion fills, the next tranche is automatically entered. This conceals the true size of the order from the market.

**Exchange-Native Icebergs**:
- Most exchanges support iceberg/reserve order types natively
- When the displayed portion fills, the reserve automatically refreshes
- The refreshed order typically receives a new timestamp, losing queue priority
- Some exchanges (e.g., NASDAQ) support "random reserve" where the replenishment size varies randomly within a range

**Algorithm-Managed Icebergs**:
- The algorithm can implement iceberg behavior by managing a sequence of child orders
- Advantage: more control over timing, sizing, and venue selection
- Can vary display size, add random delays between replenishments, and route across multiple venues
- Can combine iceberg behavior with dark pool routing

**Anti-Detection Measures**:
- Vary the displayed quantity (e.g., round lots vs. odd lots, randomized size)
- Add random delays between replenishments (50-500ms)
- Vary the price slightly (tick up/down within a tolerance)
- Route successive tranches to different venues
- Monitor for pattern detection and adjust behavior

**Common Parameters**:
| Parameter | Description |
|-----------|-------------|
| `TotalQty` | Full order quantity |
| `DisplayQty` | Quantity shown on the book at any time |
| `DisplayVariance` | Random variation in displayed quantity (e.g., +/- 20%) |
| `RefreshDelay` | Delay between replenishments |
| `PriceLimit` | Limit price |
| `VenueList` | Venues to rotate across |

---

### 1.7 Sniper / Liquidity Seeking

**Objective**: Passively monitor all available liquidity (dark pools, lit venues, crossing networks) and aggressively take liquidity when it appears, minimizing information leakage and footprint.

**Mechanism**: The algorithm does not post passive orders on lit venues. Instead, it:

1. Subscribes to dark pool IOI (Indication of Interest) feeds and conditional order notifications
2. Monitors lit order books for large resting orders or unusual depth
3. Pings dark pools with small orders to probe for hidden liquidity
4. When actionable liquidity is detected, immediately sends aggressive orders to capture it
5. After each fill, recalculates remaining quantity and resumes monitoring

**Liquidity Detection Techniques**:
- **Dark pool pinging**: Send small IOC (Immediate-or-Cancel) orders to multiple dark pools in sequence; if filled, send a larger follow-up order
- **IOI monitoring**: Subscribe to broker dark pool IOI feeds for indications of resting interest
- **Conditional order protocols**: Use conditional order workflows (e.g., BIDS, Luminex) where firm-up messages indicate real liquidity
- **Lit venue analysis**: Detect large resting limit orders on lit exchanges (though these may be icebergs or spoofed)
- **Sweep detection**: Monitor for sweep patterns that indicate aggressive buyers/sellers who may have remaining inventory

**Ping Strategies**:
- Minimum ping size: typically 100-200 shares (below most dark pool minimum quantity thresholds)
- Ping frequency: controlled to avoid being labeled as a "toxic" pinger by dark pool operators
- Ping sequencing: round-robin through dark pools, prioritized by historical fill probability
- Anti-gaming: randomize ping timing, size, and venue order

**Common Parameters**:
| Parameter | Description |
|-----------|-------------|
| `Urgency` | Controls how aggressively to sweep lit venues when dark liquidity is not found |
| `DarkPoolList` | Ordered list of dark pools to monitor/ping |
| `MinBlockSize` | Minimum fill size to target (filter out retail-sized fills) |
| `PriceLimit` | Limit price |
| `MaxSpreadCross` | Maximum spread to cross when taking lit liquidity |
| `PingSize` | Size of probe orders |
| `WouldPrice` | Price at which to switch from dark-only to lit venues |

---

### 1.8 Dark Pool Algorithms

**Objective**: Execute entirely or primarily in dark venues to minimize information leakage and market impact.

**Dark-Only Execution**:
- The algorithm routes exclusively to dark pools, crossing networks, and midpoint venues
- No lit venue interaction, no displayed orders
- Ideal for large block orders where information leakage is the primary concern
- Risk: may not complete the order if insufficient dark liquidity exists

**Dark-Preferring Execution**:
- Routes first to dark venues; if insufficient liquidity is found within a time threshold, falls back to lit venues
- Configurable dark-to-lit ratio and escalation timing

**Venue Prioritization**:
- Dark pools are ranked by historical fill rate, adverse selection, and average fill size
- Broker-operated dark pools (e.g., Credit Suisse CrossFinder, Goldman Sachs Sigma-X, Morgan Stanley MS Pool) may have different characteristics than exchange-operated dark pools (e.g., BATS Dark, NYSE Arca Dark)
- Fill probability models: logistic regression or gradient boosted models using stock characteristics (ADV, spread, volatility), time of day, order size, and venue history

**Common Parameters**:
| Parameter | Description |
|-----------|-------------|
| `VenueList` | Ordered list or scoring weights for dark pools |
| `MinFillSize` | Minimum acceptable fill quantity |
| `MidpointOnly` | Only accept midpoint or better fills |
| `MaxVenuePct` | Maximum percentage of order to route to any single venue |
| `FallbackToLit` | Whether to fall back to lit venues if dark fills are insufficient |
| `FallbackDelay` | Time to wait before falling back to lit |

---

### 1.9 Pairs Trading Algorithms

**Objective**: Execute two correlated legs simultaneously, maintaining a target spread or ratio between them.

**Mechanism**: The algorithm manages two parent orders (long leg and short leg) and coordinates their execution to:
- Maintain a target ratio (e.g., 1.5:1 shares of stock A to stock B)
- Maintain a target spread (dollar or percentage spread between the two legs)
- Minimize leg risk: the risk of completing one leg but not the other

**Execution Approaches**:

**Ratio-Based**: Execute both legs at the same participation rate, ensuring the filled ratio stays close to the target. If one leg fills faster, slow it down and accelerate the other.

**Spread-Based**: Monitor the real-time spread between the two legs. When the spread is favorable (wider than target for a convergence trade, narrower for a divergence trade), accelerate execution. When unfavorable, pause or slow down.

**Leg Priority**: In some cases, one leg is designated as the "hard" leg (less liquid, harder to fill) and the other as the "easy" leg. The algorithm executes the hard leg first, then hedges with the easy leg.

**Common Parameters**:
| Parameter | Description |
|-----------|-------------|
| `Leg1Symbol` / `Leg2Symbol` | Instruments for each leg |
| `Leg1Qty` / `Leg2Qty` | Quantities or ratio |
| `TargetSpread` | Target spread between legs |
| `SpreadTolerance` | Acceptable deviation from target spread |
| `LegPriority` | Which leg to prioritize (HARD_FIRST, BALANCED, EASY_FIRST) |
| `MaxLegImbalance` | Maximum allowed imbalance between legs as % of total |
| `BaseAlgo` | Underlying execution algorithm for each leg (e.g., VWAP, IS) |

---

### 1.10 Adaptive / Multi-Strategy Algorithms

**Objective**: Dynamically switch between execution strategies based on real-time market conditions.

**Mechanism**: An adaptive algorithm monitors market conditions (volatility, spread, volume, momentum, depth) and adjusts its behavior accordingly:
- High volume, tight spread: execute more aggressively, take lit liquidity
- Low volume, wide spread: go passive, rest in dark pools, use midpoint pegs
- Strong momentum (favorable): slow down, let the market come to you
- Strong momentum (adverse): speed up to avoid further slippage

**Signal Inputs**:
- Short-term price momentum (e.g., 5-minute returns, tick direction)
- Realized volatility vs. historical volatility
- Spread dynamics (widening/tightening)
- Order book imbalance (bid-heavy vs. ask-heavy)
- Volume surge detection
- Sector/market-wide momentum (beta-adjusted)

**Modern implementations** use machine learning models (gradient boosted trees, neural networks) trained on historical execution data to predict the best tactic at each point in time. Features include the above signals plus stock-specific characteristics and order-specific features (remaining quantity, time remaining, fill rate so far).
