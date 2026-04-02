## Execution Algorithms (Part 1)

Execution algorithms break large orders into smaller child orders to minimize market impact and achieve benchmark prices. Each algorithm targets a different objective, and the choice depends on urgency, liquidity, benchmark, and information sensitivity.

### 1.1 VWAP (Volume-Weighted Average Price)

**Objective**: Match the day's volume-weighted average price over a specified time window.

**Mechanism**: The algorithm uses a historical volume profile (typically 20-day or 30-day rolling average of intraday volume distribution, bucketed into 1-minute, 5-minute, or 10-minute intervals) to schedule child order quantities. A higher share of the parent order is released during periods of historically higher volume (e.g., the open, the close, and around major economic releases).

**Volume Profile Construction**:
- Source: consolidated tape volume by minute, excluding auctions and block trades
- Normalization: each bucket expressed as percentage of total day volume
- Adjustments: removal of outlier days (earnings, index rebalance), half-day sessions, early close days
- Intraday recalibration: some implementations blend the historical profile with real-time observed volume to adapt when the day deviates from historical norms (adaptive VWAP)

**Child Order Scheduling**:
- For each time bucket, target quantity = (bucket volume %) x (total parent order quantity)
- Cumulative target curve represents the ideal execution trajectory
- The algorithm tracks actual fills vs. the cumulative target and adjusts aggressiveness if it falls behind or ahead of schedule
- Typical participation rate stays below 15-20% of bucket volume to avoid being the dominant flow

**Execution Tactics per Slice**:
- Passive: post limit orders at the bid (for buys) or ask (for sells), capture spread
- Midpoint peg: rest at the midpoint of NBBO
- Aggressive: cross the spread with marketable limit orders when behind schedule
- Dark sweep: route to dark pools before posting to lit venues

**Shortcomings**:
- Backward-looking volume profile may not match today's actual distribution
- Susceptible to information leakage over long horizons since the participation pattern is predictable
- Does not account for price momentum or adverse price moves during execution

**Common Parameters**:
| Parameter | Typical Name | Description |
|-----------|-------------|-------------|
| `StartTime` | Start time | Begin of execution window (default: now) |
| `EndTime` | End time | End of execution window (default: market close) |
| `MaxParticipationRate` | Max POV | Cap on participation in any single bucket (e.g., 25%) |
| `PriceLimit` | Limit price | Do not execute worse than this price |
| `WouldPrice` | Would price | Price at which to become more aggressive |
| `Urgency` | Urgency | Low/Medium/High — shifts the passive-aggressive mix |
| `DarkPoolPolicy` | Dark pool | Include/Exclude/DarkOnly |
| `AdaptiveMode` | Adaptive | Enable real-time volume profile adjustment |
| `MinSliceSize` | Min slice qty | Minimum child order quantity (avoid odd lots or sub-round-lot fills) |

---

### 1.2 TWAP (Time-Weighted Average Price)

**Objective**: Execute evenly over a specified time window, regardless of volume patterns.

**Mechanism**: Divides the parent order quantity equally across N time slices within the window. If the window is 2 hours and slice interval is 1 minute, each of the 120 slices gets an equal share of the total quantity.

**Use Cases**:
- Illiquid names where the historical volume profile is unreliable or noisy
- When the trader wants to avoid any predictable clustering of execution
- Overnight or extended-hours trading where volume profiles are flat
- As a fall-back benchmark when VWAP data is unavailable

**Randomization**:
- Professional implementations add variance to slice timing and size to reduce predictability
- Slice quantity: uniform random perturbation of +/- 20-30% around the target, with catch-up logic to stay on the cumulative trajectory
- Slice timing: jitter of +/- a few seconds within each interval to avoid executing at round time boundaries

**Common Parameters**:
| Parameter | Description |
|-----------|-------------|
| `StartTime` | Begin of execution window |
| `EndTime` | End of execution window |
| `SliceInterval` | Duration of each slice (e.g., 30s, 1m, 5m) |
| `PriceLimit` | Limit price |
| `Urgency` | Controls passive vs. aggressive placement within each slice |
| `RandomizePct` | Degree of randomization on slice sizes |
| `IWouldPrice` | Price level triggering more aggressive execution |

---

### 1.3 POV / Participation Rate

**Objective**: Maintain a target participation rate as a percentage of real-time market volume.

**Mechanism**: Rather than following a pre-computed schedule, the algorithm monitors consolidated volume in real time and adjusts its execution rate to track a target percentage. If the target is 10% and 50,000 shares have traded in the last minute, the algorithm targets 5,000 shares in that interval.

**Volume Tracking**:
- Real-time consolidated tape feed provides running total of market volume
- Algorithm maintains a running ratio: (algo fills) / (market volume) = participation rate
- When ratio falls below target, the algorithm increases aggressiveness (more aggressive limit orders, spread crossing)
- When ratio exceeds target, the algorithm reduces activity (cancels resting orders, waits)

**Advantages Over VWAP**:
- Self-adapting to actual market conditions in real time
- No dependency on historical volume profiles
- Natural behavior during unusual volume events (news, earnings, index changes)

**Risks**:
- In very low volume periods, the algorithm may produce tiny child orders or stall entirely
- If the stock is moving adversely, maintaining fixed participation rate may increase market impact
- Susceptible to gaming: if another participant detects fixed-rate participation, they can front-run

**Common Parameters**:
| Parameter | Description |
|-----------|-------------|
| `TargetRate` | Target participation rate (e.g., 10%, 15%, 20%) |
| `MinRate` | Floor participation rate |
| `MaxRate` | Ceiling participation rate |
| `StartTime` / `EndTime` | Execution window |
| `PriceLimit` | Limit price |
| `WouldPrice` | Price at which to increase participation |
| `Urgency` | Adjusts baseline aggressiveness |
| `CompletionTarget` | Latest time by which the order must be complete |

---

### 1.4 Implementation Shortfall / Arrival Price

**Objective**: Minimize total execution cost relative to the price at the time the order was received (the "arrival price" or "decision price"). Balances urgency against market impact.

**Mechanism**: This is the most analytically sophisticated of the standard execution algorithms. It uses a cost model that decomposes expected execution cost into:

- **Market impact cost**: the price concession caused by the algorithm's own trading, modeled as a function of participation rate, volatility, and market depth
- **Timing risk**: the risk that the price moves unfavorably while waiting to execute, driven by volatility and order duration
- **Opportunity cost**: the cost of not completing the order (relevant if the order is not guaranteed to fill)

The algorithm solves an optimization problem: find the execution trajectory (participation rate over time) that minimizes the sum of market impact cost and timing risk, subject to constraints.

**Cost Model Inputs**:
- Historical and real-time volatility (intraday, typically 5-minute or 15-minute realized vol)
- Average daily volume (ADV) and intraday volume profile
- Bid-ask spread
- Stock-specific permanent and temporary market impact parameters (often calibrated from proprietary fill data)
- Order size as fraction of ADV (a key driver of impact)

**Impact Models**:
- Square-root model: temporary impact ~ sigma * sqrt(Q / V), where sigma is volatility, Q is quantity per interval, V is interval volume
- Power-law models: impact ~ sigma * (Q / V)^alpha, with alpha typically between 0.5 and 0.7
- Almgren-Chriss framework: separate permanent and temporary impact components, linear or nonlinear
- Proprietary calibrations: most sell-side desks maintain regression-based impact models fitted to their own execution data

**Execution Trajectory**:
- Urgent orders: front-loaded execution, high initial participation rate decaying over time
- Patient orders: back-loaded, low and steady participation rate
- The optimal trajectory depends on the trade-off parameter (lambda) between impact cost and timing risk

**Adaptive Behavior**:
- If the price moves favorably after order receipt, the algorithm becomes more patient (the urgency to fill decreases since the shortfall is already positive)
- If the price moves adversely, the algorithm becomes more aggressive (the shortfall is growing, so the cost of further delay increases)
- This adaptive behavior is the hallmark of a well-implemented IS algorithm

**Common Parameters**:
| Parameter | Description |
|-----------|-------------|
| `ArrivalPrice` | The benchmark price (default: mid-price at order receipt) |
| `RiskAversion` | Lambda parameter controlling urgency-impact trade-off |
| `Urgency` | Mapped to risk aversion: Low/Medium/High/Aggressive/Hyper |
| `MaxParticipation` | Cap on participation rate |
| `PriceLimit` | Hard limit price |
| `StartTime` / `EndTime` | Execution window |
| `AlphaSignal` | Optional short-term alpha forecast to bias aggressiveness |
| `VolOverride` | Override for volatility estimate |
| `ImpactModel` | Choice of impact model (e.g., `SQUARE_ROOT`, `POWER_LAW`, `ALMGREN_CHRISS`) |
