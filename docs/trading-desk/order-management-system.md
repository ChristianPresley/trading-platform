# Order Management System (OMS)

Reference documentation covering the design, behavior, and integration concerns of a professional trading desk Order Management System.

---

## Table of Contents

1. [Order Types](#1-order-types)
2. [Order Lifecycle and State Machine](#2-order-lifecycle-and-state-machine)
3. [Order Routing and Smart Order Routing](#3-order-routing-and-smart-order-routing)
4. [Order Validation and Pre-Trade Checks](#4-order-validation-and-pre-trade-checks)
5. [Order Amendments and Cancellations](#5-order-amendments-and-cancellations)
6. [Parent/Child Order Relationships](#6-parentchild-order-relationships)
7. [Order Book Management](#7-order-book-management)
8. [Multi-Asset Order Management](#8-multi-asset-order-management)
9. [FIX Protocol Integration](#9-fix-protocol-integration)
10. [Drop Copy and Order Audit Trails](#10-drop-copy-and-order-audit-trails)
11. [Care vs DMA Orders](#11-care-vs-dma-orders)
12. [Allocation and Post-Trade Order Splitting](#12-allocation-and-post-trade-order-splitting)

---

## 1. Order Types

### 1.1 Basic Order Types

#### Market Order
Executes immediately at the best available price. No price guarantee.

| Field | FIX Tag | Value |
|-------|---------|-------|
| OrdType | 40 | `1` (Market) |
| Side | 54 | `1` (Buy) / `2` (Sell) |
| OrderQty | 38 | Quantity |
| Symbol | 55 | Ticker |

Implementation notes:
- Must handle partial fills when displayed liquidity is insufficient.
- In fast markets, effective price may differ significantly from last-traded price.
- Many venues reject market orders during pre/post-market sessions.

#### Limit Order
Executes at the specified price or better. Buy limits execute at or below the limit; sell limits execute at or above.

| Field | FIX Tag | Value |
|-------|---------|-------|
| OrdType | 40 | `2` (Limit) |
| Price | 44 | Limit price |
| TimeInForce | 59 | `0` (Day), `1` (GTC), etc. |

Implementation notes:
- Limit price must comply with the venue's tick size table (e.g., SEC Rule 612 sub-penny rule for NMS stocks).
- Displayed vs. reserve quantity distinction applies when the limit order is also an iceberg (see below).

#### Stop Order (Stop-Loss)
Becomes a market order when the stop price is reached.

| Field | FIX Tag | Value |
|-------|---------|-------|
| OrdType | 40 | `3` (Stop) |
| StopPx | 99 | Trigger price |

Trigger logic:
- Buy stop: triggers when the market price trades at or above StopPx.
- Sell stop: triggers when the market price trades at or below StopPx.
- "Last trade" vs. "bid/ask" trigger variants exist; the trigger method should be configurable per venue.

#### Stop-Limit Order
Becomes a limit order when the stop price is reached.

| Field | FIX Tag | Value |
|-------|---------|-------|
| OrdType | 40 | `4` (Stop Limit) |
| StopPx | 99 | Trigger price |
| Price | 44 | Limit price after trigger |

Implementation notes:
- After triggering, the order may never fill if the market moves through the limit price. The OMS must track both the "triggered" and "working as limit" states.

#### Trailing Stop Order
Stop price adjusts automatically as the market moves favorably.

| Field | FIX Tag | Value |
|-------|---------|-------|
| OrdType | 40 | `P` (Trailing Stop, FIX 5.0) |
| PegOffsetValue | 211 | Trail amount (absolute or %) |
| PegOffsetType | 836 | `0` (Price), `1` (BasisPoints), `2` (Ticks), `3` (PriceTier) |

Implementation notes:
- The OMS must maintain and update the effective stop price on every qualifying tick.
- Trail amount can be absolute (e.g., $0.50) or percentage-based.
- High-water mark (for sells) or low-water mark (for buys) must be persisted.
- Trailing stop is typically managed OMS-side, not venue-side, unless the venue natively supports it.

### 1.2 Time-in-Force Variants

| TIF | FIX 59 Value | Behavior |
|-----|-------------|----------|
| Day | `0` | Expires at end of trading day |
| Good-Til-Cancelled (GTC) | `1` | Remains active until filled or explicitly cancelled. Broker/exchange may impose a maximum duration (e.g., 90 days). |
| Immediate-or-Cancel (IOC) | `3` | Must fill immediately (partial fills accepted); any unfilled portion is cancelled. |
| Fill-or-Kill (FOK) | `4` | Must fill entirely and immediately or the entire order is cancelled. Zero partial fills. |
| Good-Til-Date (GTD) | `6` | Expires at a specified date/time. Uses FIX tag `432` (ExpireDate) or `126` (ExpireTime). |
| At-the-Open (OPG) | `2` | Participates in opening auction only. |
| At-the-Close | `7` | Participates in closing auction only. |
| Good-for-Auction | `A` | Valid for the next auction only. |

Implementation notes:
- GTC orders require a daily re-validation process: corporate actions (splits, symbol changes) may invalidate outstanding GTC orders. Most brokers cancel GTC orders on ex-dates and require re-entry.
- GTD requires a reliable scheduler to expire orders at the specified time, even if the OMS was restarted.
- FOK is rare on most lit venues; typically used in dark pools or for block trades.

### 1.3 Auction and Close Orders

#### Market-on-Open (MOO)
Participates in the opening auction at whatever price the auction determines.

| Field | FIX Tag | Value |
|-------|---------|-------|
| OrdType | 40 | `1` (Market) |
| TimeInForce | 59 | `2` (OPG) |

#### Limit-on-Open (LOO)
Participates in the opening auction with a price limit.

| Field | FIX Tag | Value |
|-------|---------|-------|
| OrdType | 40 | `2` (Limit) |
| TimeInForce | 59 | `2` (OPG) |
| Price | 44 | Limit price |

#### Market-on-Close (MOC)
Participates in the closing auction at whatever price the auction determines.

| Field | FIX Tag | Value |
|-------|---------|-------|
| OrdType | 40 | `1` (Market) |
| TimeInForce | 59 | `7` (AtTheClose) |

Regulatory note: NYSE imposes a cutoff (typically 3:50 PM ET) after which MOC orders cannot be submitted or cancelled except to correct a genuine error (via the exchange's error-correction process).

#### Limit-on-Close (LOC)
Participates in the closing auction with a price limit.

| Field | FIX Tag | Value |
|-------|---------|-------|
| OrdType | 40 | `2` (Limit) |
| TimeInForce | 59 | `7` (AtTheClose) |
| Price | 44 | Limit price |

### 1.4 Hidden and Reserve Orders

#### Iceberg / Reserve Order
Only a portion of the order is displayed; the rest is held in reserve.

| Field | FIX Tag | Value |
|-------|---------|-------|
| OrderQty | 38 | Total quantity |
| MaxFloor | 111 | Displayed quantity (the visible "clip") |

Implementation notes:
- When the displayed portion fills, the venue automatically replenishes from the reserve up to MaxFloor.
- Some venues randomize the replenish quantity (e.g., +/- 10-20%) to reduce detection.
- The OMS must track both DisplayQty and TotalQty and reconcile fills against the total.
- Minimum display size requirements vary by venue (e.g., at least one round lot).

#### Hidden / Non-Displayed Order
Entirely hidden from the public order book. Available on most dark pools and many lit venues.

| Field | FIX Tag | Value |
|-------|---------|-------|
| DisplayMethod | 1084 | `4` (Undisclosed) |

Implementation notes:
- Hidden orders typically have lower priority than displayed orders at the same price level.
- Some venues (e.g., IEX) have specific order types (D-Peg) that are inherently non-displayed.

### 1.5 Pegged Orders

Pegged orders automatically adjust their price relative to a reference price (NBBO, midpoint, primary market).

| Field | FIX Tag | Value |
|-------|---------|-------|
| OrdType | 40 | `P` (Pegged) |
| PegPriceType | 1094 | `1` (LastPeg), `2` (MidPricePeg), `3` (OpeningPeg), `4` (MarketPeg), `5` (PrimaryPeg) |
| PegOffsetValue | 211 | Offset from peg reference |

#### Primary Peg
Pegged to the same-side quote: bid for buy orders, ask for sell orders.

#### Market Peg
Pegged to the opposite-side quote: ask for buy orders, bid for sell orders. Often used with a negative offset (more aggressive than the far side).

#### Midpoint Peg
Pegged to the NBBO midpoint. The dominant order type in dark pools.

| Field | FIX Tag | Value |
|-------|---------|-------|
| PegPriceType | 1094 | `2` (MidPricePeg) |
| Price | 44 | Optional limit price cap |

Implementation notes:
- Midpoint peg orders are non-displayed by definition.
- If the spread is sub-penny, the midpoint may be at a sub-penny price. Some venues allow this; others round.
- Must handle locked/crossed NBBO scenarios: many venues will not execute midpoint pegs when NBBO is locked or crossed.

#### Discretionary Peg (D-Peg, IEX-specific)
A non-displayed pegged order that uses IEX's signal to exercise price discretion up to the midpoint.

### 1.6 Conditional and Specialized Orders

#### All-or-None (AON)
Must fill the entire quantity in a single execution or not at all. Unlike FOK, there is no immediacy requirement.

| Field | FIX Tag | Value |
|-------|---------|-------|
| ExecInst | 18 | `G` (AllOrNone) |

Implementation notes:
- AON is not supported on most lit exchanges for displayed orders. Common in OTC and block trading.
- The OMS must suppress partial fill execution reports for AON-flagged orders.

#### Minimum Quantity
Order will only execute if at least a minimum quantity can be filled.

| Field | FIX Tag | Value |
|-------|---------|-------|
| MinQty | 110 | Minimum acceptable fill quantity |

#### Not Held
Gives the broker discretion on timing and price. The broker is "not held" to the limit price or time of receipt.

| Field | FIX Tag | Value |
|-------|---------|-------|
| ExecInst | 18 | `1` (NotHeld) |

Common for institutional orders routed to a sales trader or algorithm.

---

## 2. Order Lifecycle and State Machine

### 2.1 FIX-Standard Order States

The canonical order states, based on FIX protocol OrdStatus (tag 39):

```
                    +-----------+
                    | PendingNew|  (OrdStatus = A)
                    +-----+-----+
                          |
                    +-----v-----+
               +--->|    New     |  (OrdStatus = 0)
               |    +-----+-----+
               |          |
               |    +-----v-----------+
               |    | PartiallyFilled |  (OrdStatus = 1)
               |    +-----+-----------+
               |          |
               |    +-----v-----+
               |    |  Filled   |  (OrdStatus = 2) [Terminal]
               |    +-----------+
               |
  +------------+----+
  | PendingCancel   |  (OrdStatus = 6)
  +--------+--------+
           |
  +--------v--------+
  |    Cancelled     |  (OrdStatus = 4) [Terminal]
  +-----------------+

  +------------------+
  | PendingReplace   |  (OrdStatus = E)
  +--------+---------+
           |
  +--------v--------+
  |    Replaced      |  (OrdStatus = 5)
  +-----------------+
           |
     (new order version created, old version -> Cancelled)

  +-----------+
  | Rejected  |  (OrdStatus = 8) [Terminal]
  +-----------+

  +-----------+
  | Expired   |  (OrdStatus = C) [Terminal]
  +-----------+

  +-----------+
  | Suspended |  (OrdStatus = 9)
  +-----------+

  +-------------+
  | DoneForDay  |  (OrdStatus = 3) [Terminal for the day]
  +-------------+
```

### 2.2 State Descriptions

| State | OrdStatus (39) | Description |
|-------|---------------|-------------|
| **PendingNew** | `A` | Order has been received by the OMS but not yet acknowledged by the venue/broker. |
| **New** | `0` | Order acknowledged and working on the venue. |
| **PartiallyFilled** | `1` | Some quantity has been executed; remainder is still working. |
| **Filled** | `2` | Entire order quantity has been executed. Terminal state. |
| **DoneForDay** | `3` | Order is no longer working for the current session but may resume next day (e.g., GTC order). |
| **Cancelled** | `4` | Order has been successfully cancelled. Terminal state. |
| **Replaced** | `5` | Order has been modified (cancel/replace). The old version is effectively cancelled; a new version is created. In FIX, this appears as an ExecutionReport with OrdStatus=Replaced, and the new order carries a new OrderID. |
| **PendingCancel** | `6` | Cancel request sent but not yet confirmed. The order may still fill during this window. |
| **Rejected** | `8` | Order was rejected by the venue or broker. Terminal state. ExecType=8, with reject reason in OrdRejReason (103) and Text (58). |
| **Suspended** | `9` | Order is on the book but not eligible for execution (e.g., halted security, circuit breaker). |
| **PendingReplace** | `E` | Replace request sent but not yet confirmed. Original order may still fill. |
| **Expired** | `C` | Order expired per its TimeInForce instructions. Terminal state. |

### 2.3 Valid State Transitions

```
PendingNew     -> New, Rejected
New            -> PartiallyFilled, Filled, Cancelled, Replaced, Expired, Suspended, DoneForDay, PendingCancel, PendingReplace
PartiallyFilled -> PartiallyFilled (additional fills), Filled, Cancelled, Replaced, Expired, Suspended, DoneForDay, PendingCancel, PendingReplace
PendingCancel  -> Cancelled, PartiallyFilled (fill arrived before cancel), Filled (fill arrived before cancel), New (cancel rejected)
PendingReplace -> Replaced, PartiallyFilled (fill arrived before replace), Filled, New (replace rejected)
Suspended      -> New, Cancelled, Expired
DoneForDay     -> New (next session), Cancelled, Expired
Replaced       -> [Replaced creates a new order version which starts at New]
```

### 2.4 Critical Race Conditions

**Fill-before-cancel:** A cancel request is in flight when a fill arrives. The OMS must process the fill first, then either:
- If the fill is a complete fill: transition to Filled, drop the pending cancel.
- If the fill is partial: remain in PartiallyFilled, continue the cancel on the leaves quantity.

**Fill-before-replace:** Similar to above. If a fill arrives while a replace is pending:
- Process the fill.
- If the order is now fully filled, the replace is moot.
- If partially filled, the replace applies to the new leaves quantity, which may now differ from what was originally requested.

**Unsolicited cancel:** The venue cancels the order without a user request (e.g., corporate action, market close, self-trade prevention). The OMS must accept this as a valid terminal transition from any non-terminal state.

### 2.5 Internal OMS States (Beyond FIX)

Production OMSs typically extend the FIX state model with internal states:

| Internal State | Description |
|---------------|-------------|
| **Staged** | Order created in the blotter but not yet submitted. Used in care-order workflows where a PM creates an order and a trader works it. |
| **Validating** | Pre-trade compliance checks are running. |
| **RoutePending** | Order has passed validation and is queued for routing. |
| **SentToAlgo** | Order has been sent to an algorithmic execution engine. |
| **AlgoWorking** | The algo has acknowledged and is actively working the order (spawning child orders). |
| **ManualReview** | Flagged for manual review (e.g., compliance hold, unusual size). |
| **CancelPending (internal)** | Internal cancel request sent to algo engine, awaiting child order cancellations. |

### 2.6 Order Versioning

When an order is amended (cancel/replace), the OMS must maintain a version history:

```
OrderID: ORD-2024-001
  Version 1: Buy 10,000 AAPL @ 185.00 Limit  [Replaced]
  Version 2: Buy 10,000 AAPL @ 186.00 Limit  [Replaced]
  Version 3: Buy  8,000 AAPL @ 186.50 Limit  [Filled]
```

Each version retains:
- Timestamp of the amendment
- User who requested the amendment
- Previous and new values for all changed fields
- FIX ClOrdID (11), OrigClOrdID (41) linkage

---

## 3. Order Routing and Smart Order Routing

### 3.1 Direct Market Access (DMA)

DMA routing sends orders directly to a specific venue without broker intermediation.

Key fields:

| Field | FIX Tag | Description |
|-------|---------|-------------|
| ExDestination | 100 | Target venue (e.g., `XNYS`, `XNAS`, `ARCX`, `BATS`) |
| ExDestinationIDSource | 1133 | `M` (MIC code) |

Venue identification uses ISO 10383 MIC codes:
- `XNYS` -- NYSE
- `XNAS` -- Nasdaq
- `ARCX` -- NYSE Arca
- `BATS` -- CBOE BZX
- `EDGX` -- CBOE EDGX
- `IEXG` -- IEX
- `XCHI` -- NYSE Chicago

### 3.2 Smart Order Routing (SOR)

SOR engines dynamically select venues based on real-time conditions. Core inputs:

**Market data:**
- Top-of-book quotes (BBO) at each venue
- Depth-of-book where available
- Venue-specific order types and capabilities

**Cost model:**
- Exchange fee/rebate schedules (maker/taker, inverted venues)
- SEC fees, TAF fees
- Clearing costs per venue

**Execution quality metrics:**
- Historical fill rates per venue
- Average latency per venue
- Information leakage scores

**Regulatory constraints:**
- Reg NMS Order Protection Rule (Rule 611): cannot trade through a protected quote at a better price on another venue
- Reg NMS access fee cap ($0.0030/share for equities)

#### SOR Decision Logic (Simplified)

```
1. Receive order (symbol, side, qty, limit price, urgency)
2. Snapshot current NBBO and depth across all connected venues
3. For each venue with available liquidity at or better than limit price:
   a. Calculate expected fill quantity
   b. Calculate expected cost (including fees/rebates)
   c. Score venue on fill probability, latency, information leakage
4. Rank venues by composite score
5. Allocate quantity across top-ranked venues (may spray to multiple simultaneously)
6. Submit child orders
7. Monitor fills; re-route unfilled quantity as book updates
```

#### SOR Strategies

| Strategy | Description |
|----------|-------------|
| **Aggressive** | Sweep all available liquidity at or better than limit, hit dark pools first for price improvement |
| **Passive** | Post on the venue with the best rebate; use dark pools for midpoint improvement |
| **Cost-Optimized** | Minimize total execution cost (net of rebates). Prefers inverted venues for taking, maker venues for posting |
| **Latency-Optimized** | Route to fastest venues to minimize adverse selection |
| **Dark-First** | Attempt dark pool fills for price improvement before accessing lit venues |
| **Spray** | Simultaneously send to multiple venues to maximize fill rate |
| **Serial** | Route to venues sequentially, using fill/no-fill signals before trying next venue |

### 3.3 Broker Algo Routing

Instead of routing directly to a venue, the OMS sends orders to a broker's algorithmic execution engine.

| Field | FIX Tag | Description |
|-------|---------|-------------|
| TargetStrategy | 847 | Algo strategy identifier |
| TargetStrategyParameters | 848 | Algo-specific parameters (XML/FIX-encoded) |
| HandlInst | 21 | `1` (Automated, no intervention), `2` (Automated, broker can intervene), `3` (Manual) |

Common broker algo strategies:

| Algo | Objective | Key Parameters |
|------|-----------|----------------|
| **VWAP** | Match volume-weighted average price over a time horizon | StartTime, EndTime, MaxPctVolume, MinPctVolume |
| **TWAP** | Evenly distribute execution over time | StartTime, EndTime, WouldStyle (Passive/Aggressive) |
| **Arrival Price** (Implementation Shortfall) | Minimize slippage from the price at order arrival | UrgencyLevel (1-5), RiskAversion, MaxPctVolume |
| **Percentage of Volume (POV)** | Participate at a target % of market volume | TargetPctVolume (e.g., 10%), MaxPrice, MinPrice |
| **Close** | Target the closing price | MOC vs. LOC, MaxPctClose |
| **Iceberg / Drip** | Break large order into small clips, post passively | ClipSize, ClipVariance, DisplayQty |
| **Sniper / Liquidity Seeker** | Sweep dark pool liquidity opportunistically | MinDarkFillSize, AggressionLevel |
| **Pairs / Spread** | Execute a pair trade maintaining a target spread | LegRatio, SpreadTarget, LegSymbols |

### 3.4 Venue Connectivity

The OMS maintains persistent connections to each venue/broker:

```
OMS
 |
 +-- FIX Session -> NYSE (XNYS)
 +-- FIX Session -> Nasdaq (XNAS)
 +-- FIX Session -> CBOE BZX (BATS)
 +-- FIX Session -> CBOE EDGX (EDGX)
 +-- FIX Session -> IEX (IEXG)
 +-- FIX Session -> Dark Pool A
 +-- FIX Session -> Dark Pool B
 +-- FIX Session -> Broker Algo A
 +-- FIX Session -> Broker Algo B
 +-- Binary Protocol -> Exchange Gateway (for lowest latency)
```

Each connection requires:
- Session-level heartbeat monitoring (FIX Heartbeat/TestRequest)
- Sequence number management and gap-fill recovery
- Connection failover and reconnection logic
- Message rate throttling per venue limits

---

## 4. Order Validation and Pre-Trade Checks

### 4.1 Validation Pipeline

Every order passes through a sequential validation pipeline before routing:

```
Order Entry
    |
    v
[1. Schema Validation]          -- Required fields, data types, enums
    |
    v
[2. Instrument Validation]      -- Symbol exists, is tradeable, correct asset class
    |
    v
[3. Fat Finger Checks]         -- Price/size reasonability
    |
    v
[4. Restricted List Check]     -- Compliance: is the security restricted?
    |
    v
[5. Position Limit Check]      -- Would this order breach position limits?
    |
    v
[6. Credit/Buying Power Check] -- Sufficient capital/margin?
    |
    v
[7. Regulatory Checks]         -- Short sale rules, locate requirements
    |
    v
[8. Risk Limit Checks]         -- Aggregate exposure, concentration
    |
    v
[9. Market Access Controls]     -- SEC 15c3-5 compliance
    |
    v
Route Order
```

### 4.2 Fat Finger Checks

Prevent catastrophically erroneous orders. Configurable per symbol, per asset class, per user.

| Check | Description | Example Threshold |
|-------|-------------|-------------------|
| **Price deviation** | Reject if limit price is more than X% from current market | +/- 10% from last trade |
| **Notional value** | Reject if order value exceeds a threshold | > $10,000,000 single order |
| **Quantity** | Reject if quantity exceeds a threshold | > 1,000,000 shares |
| **Price precision** | Reject if price has more decimals than the tick size allows | > 2 decimal places for stocks |
| **Duplicate detection** | Reject if an identical order was submitted within N seconds | Same symbol/side/qty/price within 5 seconds |
| **Away-from-market** | Reject if limit price is unreasonably far from current market | Limit price > 50% away from NBBO midpoint |

### 4.3 Position Limits

| Limit Type | Description |
|-----------|-------------|
| **Gross position** | Maximum total long + short position in a single security |
| **Net position** | Maximum net long or short in a single security |
| **Notional limit** | Maximum dollar exposure per security, sector, or portfolio |
| **Concentration limit** | Maximum % of portfolio in a single name or sector |
| **ADV limit** | Position cannot exceed X% of average daily volume (to ensure liquidability) |
| **Account-level** | Aggregate limits across all positions in an account |

Position limit checks must consider:
- Current position (settled + unsettled)
- Open orders (working orders that could fill)
- The candidate order itself
- Pending allocations

### 4.4 Credit and Buying Power

| Check | Description |
|-------|-------------|
| **Cash available** | For cash accounts: sufficient settled/unsettled cash |
| **Margin available** | For margin accounts: sufficient margin equity after applying Reg T or portfolio margin requirements |
| **Buying power** | Pre-calculated buying power considering current positions, open orders, and margin |
| **Intraday buying power** | Pattern day trader buying power (4x equity for equities) |
| **Cross-margining** | Credit from offsetting positions across correlated products |

Credit checks are typically real-time and must account for the "worst case" scenario where all open orders fill simultaneously.

### 4.5 Restricted Lists

| List Type | Description |
|-----------|-------------|
| **Restricted list** | Securities that cannot be traded (e.g., the firm has material non-public information) |
| **Watch list** | Securities under compliance monitoring; trading allowed but flagged for review |
| **Grey list** | Internal deal-side awareness; trading may be restricted depending on information barriers |
| **Do-not-trade list** | Absolute prohibition on trading (e.g., sanctioned entities) |
| **Auto-execute exempt list** | Securities that require manual execution (thinly traded, illiquid) |

Restricted list checks must be real-time and cannot be cached aggressively since additions can occur intraday.

### 4.6 Short Sale Checks

| Rule | Description |
|------|-------------|
| **Reg SHO Rule 200** | Must accurately mark orders as Long, Short, or Short Exempt |
| **Reg SHO Rule 203(b)** | Locate requirement: must have a reasonable basis to believe the security can be borrowed before short selling |
| **Reg SHO Rule 201 (Circuit Breaker)** | When a stock drops 10% from prior close, short sales must be at a price above the current NBB (uptick rule alternative) for remainder of day and next day |
| **FIX Tag 54** | Side: `5` (Sell Short), `6` (Sell Short Exempt) |

Locate management:
- Pre-borrow: shares actually borrowed before the trade
- Locate: reasonable expectation to borrow (e.g., easy-to-borrow list)
- Locate IDs must be tracked and associated with each short sale order
- Locates typically expire at end of day

### 4.7 SEC Rule 15c3-5 (Market Access Rule)

Requires broker-dealers providing market access to implement:
- Pre-trade risk controls that prevent the entry of erroneous orders
- Regulatory and financial controls that are reasonably designed to prevent violations
- Controls must be under the broker-dealer's direct and exclusive control
- Cannot be overridden by the customer

Required controls:
1. Pre-set credit or capital thresholds
2. Erroneous order prevention (fat finger checks)
3. Compliance with regulatory requirements (restricted lists, short sale rules)
4. Controls must be applied on an order-by-order basis in real time

---

## 5. Order Amendments and Cancellations

### 5.1 Cancel Request

FIX message type: `F` (OrderCancelRequest)

| Field | FIX Tag | Description |
|-------|---------|-------------|
| OrigClOrdID | 41 | ClOrdID of the order to cancel |
| ClOrdID | 11 | New unique identifier for the cancel request |
| OrderID | 37 | Venue-assigned order ID (if available) |
| Side | 54 | Must match original order |
| Symbol | 55 | Must match original order |
| TransactTime | 60 | Timestamp of the cancel request |

Cancel outcomes:
- **Cancel accepted:** ExecutionReport with OrdStatus=4 (Cancelled), ExecType=4
- **Cancel rejected:** OrderCancelReject (MsgType=9) with CxlRejReason (102):
  - `0` = Too late to cancel
  - `1` = Unknown order
  - `2` = Broker option
  - `3` = Already pending cancel or replace
  - `99` = Other

### 5.2 Cancel/Replace Request (Order Amendment)

FIX message type: `G` (OrderCancelReplaceRequest)

| Field | FIX Tag | Description |
|-------|---------|-------------|
| OrigClOrdID | 41 | ClOrdID of the order to replace |
| ClOrdID | 11 | New unique identifier for the replacement |
| OrderQty | 38 | New quantity (can increase or decrease) |
| Price | 44 | New limit price |
| OrdType | 40 | Usually must remain the same |
| Side | 54 | Must match original (cannot flip side) |
| TimeInForce | 59 | Can be changed |

Cancel/replace semantics:
- Atomically cancels the old order and submits a new one.
- The replacement order may or may not retain time priority depending on the venue and the nature of the change:
  - Price improvement (more aggressive): retains priority on most venues.
  - Price deterioration (less aggressive): loses priority.
  - Quantity decrease: typically retains priority.
  - Quantity increase: typically loses priority.
- If the original order fills between the cancel and replace, the replace is rejected, and the OMS must reconcile.

### 5.3 Mass Cancel

Cancel all orders matching a filter criteria. Not a standard FIX message but commonly implemented as a custom message or via loops.

Common mass cancel filters:
- All orders for a symbol
- All orders for an account
- All orders on a specific venue
- All orders for a trader/desk
- All orders (emergency kill switch)

Implementation approaches:
1. **Iterative cancel:** Loop through all matching orders and send individual cancel requests. Simple but slow for large order counts.
2. **Venue mass cancel:** Some venues support mass cancel messages (e.g., CME Mass Quote Cancel). Much faster.
3. **Kill switch:** Emergency mechanism that cancels all orders and disables new order submission. Required by SEC 15c3-5.

### 5.4 Cancel-on-Disconnect (COD)

Orders are automatically cancelled when the FIX session disconnects.

| Field | FIX Tag | Value |
|-------|---------|-------|
| CancelOnDisconnect | 8013 (custom) | `Y` / `N` |

Implementation notes:
- Typically configured at the session level, not per-order.
- Most exchanges support COD as a session-level setting.
- The OMS must track which orders were submitted on COD-enabled sessions and update their state if the session drops.
- For algo orders, COD on the parent should cascade to all child orders.
- Some venues distinguish between clean disconnect (Logout) and dirty disconnect (TCP drop). COD typically applies to dirty disconnects only.

---

## 6. Parent/Child Order Relationships

### 6.1 Algorithmic Order Decomposition

A parent (algo) order is worked by an execution algorithm that spawns one or more child orders.

```
Parent Order: Buy 100,000 MSFT @ 420.00 Limit (VWAP, 09:30-16:00)
  |
  +-- Child 1: Buy 500 MSFT @ 419.85 Limit -> XNAS   [Filled 500 @ 419.82]
  +-- Child 2: Buy 300 MSFT @ 419.90 Limit -> BATS    [Filled 300 @ 419.90]
  +-- Child 3: Buy 800 MSFT @ 420.00 Limit -> ARCX    [Working]
  +-- Child 4: Buy 400 MSFT @ Midpoint Peg  -> DARK1  [Working]
  ...
  +-- Child N: (to be generated as algo progresses)
```

Key invariants:
- Sum of child order quantities must not exceed parent order quantity.
- Sum of child fills rolls up to parent fills.
- Parent CumQty (14) = sum of all child CumQty values.
- Parent AvgPx (6) = quantity-weighted average of all child fill prices.
- Cancelling the parent must cancel all working children.
- Amending the parent may require amending or cancelling children.

FIX linkage fields:

| Field | FIX Tag | Description |
|-------|---------|-------------|
| ClOrdLinkID | 583 | Links related orders |
| ParentOrderID | (custom) | OMS-internal parent reference |
| ChildOrderCount | (custom) | Number of active children |

### 6.2 Bracket Orders

A bracket order consists of a primary order with two contingent orders (take-profit and stop-loss) that activate when the primary fills.

```
Primary:     Buy 1,000 AAPL @ 185.00 Limit
Take-Profit: Sell 1,000 AAPL @ 195.00 Limit   (activates on primary fill)
Stop-Loss:   Sell 1,000 AAPL @ 180.00 Stop     (activates on primary fill)
```

The take-profit and stop-loss form an OCO pair: when one fills, the other is cancelled.

### 6.3 OCO (One-Cancels-Other) Orders

Two or more orders linked such that when one fills (or partially fills), the other(s) are automatically cancelled.

| Field | FIX Tag | Description |
|-------|---------|-------------|
| ContingencyType | 1385 | `1` (OCO) |
| ClOrdLinkID | 583 | Shared link ID across OCO group |

Implementation notes:
- OCO cancellation should be immediate upon fill of the sibling.
- Partial fill handling: if one side partially fills, should the OCO sibling be reduced proportionally or cancelled entirely? This must be configurable.
- Race condition: both sides could theoretically fill simultaneously on different venues. The OMS must handle this gracefully (potentially allowing both fills and flagging for manual review).

### 6.4 Contingent Orders (If-Then)

A contingent order becomes active only when a specified condition is met.

Common contingency types:
| Type | Description |
|------|-------------|
| **If-touched** | Activate when a price level is touched |
| **If-done** | Activate when a linked order fills |
| **If-filled** | Synonym for if-done |
| **Conditional on market data** | Activate when a market data condition is met (e.g., spread narrows) |

Implementation notes:
- The OMS must maintain a contingency evaluation engine that monitors relevant triggers.
- Pending contingent orders exist in a "Staged" or "Held" state until their condition triggers.
- Conditions may be complex: composite conditions involving multiple instruments, spreads, or portfolio-level metrics.

### 6.5 Multi-Leg / List Orders

Multiple orders submitted as a group, potentially with inter-order dependencies.

FIX message type: `E` (NewOrderList)

| Field | FIX Tag | Description |
|-------|---------|-------------|
| ListID | 66 | Unique list identifier |
| TotNoOrders | 68 | Total number of orders in the list |
| ListSeqNo | 67 | Sequence number within the list |
| BidType | 394 | `1` (NonDisclosed), `2` (Disclosed), `3` (NoBiddingProcess) |

Used for:
- Program trading (basket orders)
- Portfolio rebalances
- Pairs/spread trades

---

## 7. Order Book Management

### 7.1 Blotter Views

The order blotter is the trader's primary interface to the OMS. Standard blotter views:

#### Working Orders (Live Blotter)
Shows all orders in a non-terminal state.

| Column | Source | Description |
|--------|--------|-------------|
| Order ID | ClOrdID (11) | Unique order identifier |
| Account | Account (1) | Trading account |
| Symbol | Symbol (55) | Instrument identifier |
| Side | Side (54) | Buy/Sell/Short |
| Qty | OrderQty (38) | Total order quantity |
| Filled | CumQty (14) | Quantity filled so far |
| Remaining | LeavesQty (151) | Quantity still working |
| Limit | Price (44) | Limit price |
| Avg Price | AvgPx (6) | Average fill price |
| Status | OrdStatus (39) | Current order state |
| Route | ExDestination (100) | Venue or algo |
| Time | TransactTime (60) | Order entry time |
| TIF | TimeInForce (59) | Time in force |
| Trader | SenderSubID (50) | Trader who entered the order |

#### Filled Orders (Execution Blotter)
Shows all fills for the current session.

Additional columns:
| Column | Source | Description |
|--------|--------|-------------|
| Exec ID | ExecID (17) | Unique execution identifier |
| Exec Qty | LastQty (32) | Fill quantity |
| Exec Price | LastPx (31) | Fill price |
| Exec Time | TransactTime (60) | Fill timestamp |
| Exec Venue | LastMkt (30) | Venue where fill occurred |
| Liquidity | LastLiquidityInd (851) | `1` (Added), `2` (Removed), `3` (Routed), `4` (Auction) |

#### Order History / Audit Trail
Complete chronological history of all order events. Every state transition, amendment, and fill is recorded.

### 7.2 Blotter Functionality

| Feature | Description |
|---------|-------------|
| **Real-time updates** | Blotter updates in real time as execution reports arrive. Typically uses a reactive/push model (event bus, WebSocket). |
| **Filtering** | Filter by symbol, account, status, side, desk, trader, strategy, date range. |
| **Sorting** | Sort by any column, with multi-column sort support. |
| **Grouping** | Group by symbol, account, status, strategy. Show subtotals per group. |
| **Quick actions** | Right-click or button to cancel, amend, or duplicate an order. |
| **Alert/highlight rules** | Color-code rows based on conditions (e.g., red for rejected, yellow for partially filled, green for filled). |
| **Export** | Export to CSV/Excel for post-trade analysis. |
| **Linked views** | Click an order to see its execution details, child orders, allocation, audit trail. |

### 7.3 Position View

Real-time position view derived from orders and fills:

| Column | Description |
|--------|-------------|
| Symbol | Instrument |
| Net Qty | Current net position (long positive, short negative) |
| Avg Cost | Average entry cost |
| Market Price | Current market price |
| Unrealized P&L | (Market - AvgCost) x NetQty |
| Realized P&L | Sum of closed trade P&L |
| Notional | Market price x abs(NetQty) |
| % of NAV | Position as percentage of portfolio |
| Day Volume | Shares traded today |
| VWAP | Volume-weighted average price of today's executions |

### 7.4 Order Book Aggregation

For multi-venue, multi-strategy environments, the OMS must aggregate:
- Orders across all venues into a single blotter
- Fills from DMA, algo, and care order workflows
- Positions across prime broker accounts, custodians, and clearing firms
- Cross-asset exposure (equity + derivatives + FX hedges)

---

## 8. Multi-Asset Order Management

### 8.1 Equities

Standard equity order fields:

| Field | FIX Tag | Notes |
|-------|---------|-------|
| Symbol | 55 | Ticker symbol |
| SecurityIDSource | 22 | `1` (CUSIP), `2` (SEDOL), `4` (ISIN), `8` (Exchange Symbol) |
| SecurityID | 48 | Identifier value |
| SecurityExchange | 207 | Primary listing exchange MIC |
| Currency | 15 | Trading currency |

Equity-specific considerations:
- Lot sizes (round lot = 100 shares in US; varies internationally)
- Tick size tables (pilot programs, price tiers)
- Short sale rules and locate management
- Reg NMS order protection
- LULD (Limit Up/Limit Down) price bands
- Trading halts (MWCB, regulatory, news pending)
- Corporate actions impact on open orders

### 8.2 Fixed Income

Fixed income orders differ significantly from equities:

| Field | FIX Tag | Notes |
|-------|---------|-------|
| SecurityType | 167 | `GOVT`, `CORP`, `MUNI`, `MBS`, `ABS`, etc. |
| MaturityDate | 541 | Bond maturity |
| CouponRate | 223 | Annual coupon rate |
| Price | 44 | Can be price (dirty or clean), yield, or spread |
| YieldType | 235 | `AFTERTAX`, `ANNUAL`, `MATURITY`, `WORST`, `SPREAD` |
| Yield | 236 | Yield value if ordering by yield |
| OrderQty | 38 | Face value (notional), not number of bonds |

Fixed income-specific considerations:
- OTC market: most bonds trade off-exchange via RFQ (Request for Quote) or voice
- RFQ workflow:
  1. Send RFQ to N dealers (FIX MsgType `AH`)
  2. Receive quotes (FIX MsgType `S`)
  3. Accept best quote (converts to executable order)
- Price types: clean price, dirty price, yield, spread to benchmark, discount margin
- Quantity is in face/par value (e.g., $1,000,000 face), not units
- Accrued interest calculations
- Settlement conventions (T+1 for US Treasuries, T+2 for corporates)
- Minimum denomination and increment sizes

### 8.3 Foreign Exchange (FX)

FX orders use distinct conventions:

| Field | FIX Tag | Notes |
|-------|---------|-------|
| Symbol | 55 | Currency pair (e.g., `EUR/USD`) |
| Currency | 15 | Deal currency |
| SettlCurrency | 120 | Settlement currency |
| FutSettDate | 64 | Value date |
| OrderQty | 38 | Amount in deal currency |
| OrdType | 40 | `D` (Previously Quoted) for RFQ fills |

FX-specific considerations:
- Spot, forward, swap, NDF (non-deliverable forward) order types
- Dealing in "amount currency" vs. "counter currency"
- Streaming price model: FX prices are typically streamed from liquidity providers, not posted on a central book
- Last-look: LPs may have a last-look window to reject trades after execution
- Value date management (T+2 for spot, broken dates for forwards)
- Netting and aggregation for settlement
- Multi-dealer competition (request streaming prices from multiple LPs)

### 8.4 Listed Derivatives (Futures and Options)

| Field | FIX Tag | Notes |
|-------|---------|-------|
| SecurityType | 167 | `FUT`, `OPT`, `FOP` (Future Option) |
| MaturityMonthYear | 200 | Contract expiry (e.g., `202403`) |
| StrikePrice | 202 | For options |
| PutOrCall | 201 | `0` (Put), `1` (Call) |
| CFICode | 461 | ISO 10962 classification |
| UnderlyingSymbol | 311 | Underlying instrument |
| ContractMultiplier | 231 | Contract size (e.g., 100 for equity options) |

Derivatives-specific considerations:
- Margin requirements (initial and maintenance margin)
- Contract specifications: multiplier, tick size, expiry rules
- Exercise and assignment workflows
- Spread/combo orders (calendar spreads, straddles, strangles, butterflies)
- Position limits (exchange-imposed, regulatory)
- Options pricing: Greeks (delta, gamma, vega, theta) for risk checks
- Auto-exercise rules at expiration
- Series creation: new strikes/expiries listed dynamically

### 8.5 Commodities

Additional considerations beyond standard derivatives:
- Physical delivery vs. cash settlement
- Warehouse receipts and delivery notices
- Position limits specific to physical commodities (CFTC limits)
- Intercommodity spreads
- Seasonal patterns affecting order management
- Energy-specific protocols (e.g., ICE, CME Globex)

### 8.6 Multi-Asset OMS Architecture

A multi-asset OMS must normalize across asset classes:

```
                    +-------------------+
                    | Unified Order API |
                    +--------+----------+
                             |
          +------------------+------------------+
          |         |         |        |        |
     +----v---+ +---v---+ +--v--+ +---v---+ +--v---+
     |Equities| |Fixed  | | FX  | |Derivs | |Crypto|
     |Handler | |Income | |Hndlr| |Handler| |Hndlr |
     +----+---+ |Handler| +--+--+ +---+---+ +--+---+
          |     +---+---+    |        |        |
          v         v        v        v        v
      [Venue    [RFQ     [LP      [Exchange [Exchange
       Gateway]  Engine]  Stream]  Gateway]  Gateway]
```

Each asset class handler manages:
- Asset-specific validation rules
- Asset-specific order types and TIF options
- Price format normalization (decimals, fractions, 32nds, ticks)
- Quantity normalization (shares, face value, contracts, lots)
- Settlement convention differences

---

## 9. FIX Protocol Integration

### 9.1 FIX Versions

| Version | Status | Key Differences |
|---------|--------|-----------------|
| **FIX 4.2** | Legacy, still widely used | Mature, well-understood. Limited multi-leg support. |
| **FIX 4.4** | Most common in production | Added multi-leg instruments, improved party identification, position maintenance. |
| **FIX 5.0 (FIXT 1.1)** | Current standard | Separates session (FIXT) and application layers. Adds pre-trade risk, algo order support. |
| **FIX 5.0 SP2** | Latest service pack | Extended party information, better derivatives support. |

### 9.2 Session Management

FIX sessions use the FIXT (or FIX 4.x session) layer for transport reliability.

#### Session Establishment

```
Initiator                          Acceptor
    |                                  |
    |--- Logon (MsgType=A) ---------->|
    |    HeartBtInt=30                 |
    |    ResetSeqNumFlag=Y (optional) |
    |                                  |
    |<-- Logon (MsgType=A) -----------|
    |                                  |
    |<-> Heartbeat (MsgType=0) <----->|  (every HeartBtInt seconds)
    |                                  |
```

Key session fields:

| Field | FIX Tag | Description |
|-------|---------|-------------|
| SenderCompID | 49 | Sender's firm identifier |
| TargetCompID | 56 | Receiver's firm identifier |
| SenderSubID | 50 | Trader/desk identifier |
| MsgSeqNum | 34 | Message sequence number |
| SendingTime | 52 | UTC timestamp |
| HeartBtInt | 108 | Heartbeat interval in seconds |
| EncryptMethod | 98 | `0` (None), `1`-`6` (various encryption) |
| ResetSeqNumFlag | 141 | Reset sequence numbers on logon |
| Username | 553 | Authentication username |
| Password | 554 | Authentication password |

#### Sequence Number Management

- Each side maintains independent outgoing sequence numbers.
- If a gap is detected, the receiver sends a ResendRequest (MsgType=2) specifying the range.
- The sender responds with SequenceReset-GapFill (MsgType=4) for admin messages or retransmits application messages.
- PossDupFlag (43) = `Y` on retransmitted messages to prevent double-processing.
- PossResend (97) = `Y` on messages that may have been previously sent.

#### Session Recovery

```
After reconnection:
    |
    |--- Logon (A) ------------------>|
    |    MsgSeqNum=1001               |   (last sent was 1000)
    |                                  |
    |<-- Logon (A) --------------------|
    |    MsgSeqNum=2501               |   (acceptor expected 2001)
    |                                  |
    |<-- ResendRequest (2) -----------|
    |    BeginSeqNo=1001              |
    |    EndSeqNo=0 (infinity)        |
    |                                  |
    |--- SequenceReset-GapFill (4) -->|  (for admin msgs in gap)
    |--- Retransmit app msgs -------->|  (with PossDupFlag=Y)
    |                                  |
    |--- ResendRequest (2) ---------->|  (if initiator has gap too)
    |    BeginSeqNo=2001              |
    |    EndSeqNo=2500                |
    |                                  |
```

### 9.3 Core Order Messages

#### NewOrderSingle (MsgType = D)

| Field | FIX Tag | Required | Description |
|-------|---------|----------|-------------|
| ClOrdID | 11 | Y | Client-assigned unique order ID |
| Account | 1 | N | Trading account |
| HandlInst | 21 | Y | `1` Auto-private, `2` Auto-public, `3` Manual |
| Symbol | 55 | Y | Instrument identifier |
| Side | 54 | Y | `1` Buy, `2` Sell, `5` Sell Short, `6` Sell Short Exempt |
| TransactTime | 60 | Y | Order creation timestamp (UTC) |
| OrdType | 40 | Y | See order types section |
| OrderQty | 38 | Y | Order quantity |
| Price | 44 | C | Required for limit orders |
| StopPx | 99 | C | Required for stop orders |
| TimeInForce | 59 | N | Default is Day |
| ExDestination | 100 | N | Target venue |
| MinQty | 110 | N | Minimum fill quantity |
| MaxFloor | 111 | N | Display quantity (iceberg) |
| ExecInst | 18 | N | Execution instructions |
| Currency | 15 | N | Order currency |
| SecurityID | 48 | N | Alternative security identifier |
| SecurityIDSource | 22 | N | Source of SecurityID |
| Text | 58 | N | Free-form text |
| TargetStrategy | 847 | N | Algo strategy code |

#### ExecutionReport (MsgType = 8)

The primary response message for all order events.

| Field | FIX Tag | Required | Description |
|-------|---------|----------|-------------|
| OrderID | 37 | Y | Venue-assigned order ID |
| ClOrdID | 11 | Y | Client order ID from the request |
| OrigClOrdID | 41 | C | For cancel/replace responses |
| ExecID | 17 | Y | Unique execution report ID |
| ExecType | 150 | Y | `0` New, `1` PartialFill (FIX4.2), `4` Cancelled, `5` Replaced, `8` Rejected, `F` Trade, `C` Expired |
| OrdStatus | 39 | Y | Current order status |
| Side | 54 | Y | Order side |
| LeavesQty | 151 | Y | Remaining quantity |
| CumQty | 14 | Y | Total filled quantity |
| AvgPx | 6 | Y | Average fill price |
| LastQty | 32 | C | Quantity of last fill (if ExecType=Trade) |
| LastPx | 31 | C | Price of last fill |
| LastMkt | 30 | N | Execution venue |
| Text | 58 | N | Free text (reject reasons, etc.) |
| OrdRejReason | 103 | C | Reason code when ExecType=Rejected |
| ExecRestatementReason | 378 | C | Reason for unsolicited state change |

ExecType values (FIX 4.4+):

| ExecType | Value | Meaning |
|----------|-------|---------|
| New | `0` | Order accepted |
| Trade | `F` | Fill or partial fill |
| DoneForDay | `3` | Not working for rest of day |
| Cancelled | `4` | Order cancelled |
| Replaced | `5` | Order replaced |
| PendingCancel | `6` | Cancel request received |
| Rejected | `8` | Order rejected |
| Suspended | `9` | Order suspended |
| PendingNew | `A` | Order received, not yet accepted |
| Expired | `C` | Order expired |
| PendingReplace | `E` | Replace request received |
| TradeCorrect | `G` | Trade correction (bust/correct) |
| OrderStatus | `I` | Status request response |

#### OrderCancelRequest (MsgType = F)

| Field | FIX Tag | Required |
|-------|---------|----------|
| OrigClOrdID | 41 | Y |
| ClOrdID | 11 | Y |
| Side | 54 | Y |
| Symbol | 55 | Y |
| TransactTime | 60 | Y |
| OrderQty | 38 | Y |

#### OrderCancelReplaceRequest (MsgType = G)

Same as NewOrderSingle, plus:

| Field | FIX Tag | Required |
|-------|---------|----------|
| OrigClOrdID | 41 | Y |

All order fields must be resent, not just the changed ones.

#### OrderCancelReject (MsgType = 9)

| Field | FIX Tag | Description |
|-------|---------|-------------|
| OrderID | 37 | Venue order ID |
| ClOrdID | 11 | ClOrdID from the cancel/replace request |
| OrigClOrdID | 41 | Original order's ClOrdID |
| OrdStatus | 39 | Current status of the order |
| CxlRejResponseTo | 434 | `1` (Cancel), `2` (Cancel/Replace) |
| CxlRejReason | 102 | `0` TooLate, `1` Unknown, `2` BrokerOption, `3` AlreadyPending, `99` Other |
| Text | 58 | Human-readable reason |

### 9.4 Party Identification

FIX uses the Parties repeating group for multi-party identification:

| Field | FIX Tag | Description |
|-------|---------|-------------|
| NoPartyIDs | 453 | Number of party entries |
| PartyID | 448 | Party identifier value |
| PartyIDSource | 447 | `B` (BIC), `C` (Proprietary), `D` (ISO Country Code) |
| PartyRole | 452 | `1` (Executing Firm), `3` (Client ID), `4` (Investor ID), `7` (Entering Firm), `11` (Order Origination Trader), `12` (Executing Trader), `13` (Order Origination Firm), `36` (Entering Trader) |
| PartySubID | 523 | Sub-identifier |

### 9.5 Algo Order Parameters in FIX

Standard strategy parameters (FIX 5.0):

| Field | FIX Tag | Description |
|-------|---------|-------------|
| TargetStrategy | 847 | Strategy code (e.g., `1000` = VWAP) |
| TargetStrategyParameters | 848 | Algo parameters string |
| NoStrategyParameters | 957 | Number of strategy parameter entries |
| StrategyParameterName | 958 | Parameter name (e.g., `StartTime`) |
| StrategyParameterType | 959 | Data type |
| StrategyParameterValue | 960 | Parameter value |

Common FIXatdl parameters (FIX Algorithmic Trading Definition Language):

```xml
<Strategy name="VWAP" fixTag="847" uiRep="VWAP">
  <Parameter name="StartTime" fixTag="958" use="required" type="UTCTimestamp"/>
  <Parameter name="EndTime" fixTag="958" use="required" type="UTCTimestamp"/>
  <Parameter name="MaxPctVolume" fixTag="958" use="optional" type="Percentage"/>
  <Parameter name="Urgency" fixTag="958" use="optional" type="Int" minValue="1" maxValue="5"/>
  <Parameter name="WouldStyle" fixTag="958" use="optional" type="String" enumValues="Passive|Neutral|Aggressive"/>
</Strategy>
```

---

## 10. Drop Copy and Order Audit Trails

### 10.1 Drop Copy

A drop copy is a real-time, read-only copy of all execution reports sent to a secondary FIX session. Used for:
- Independent risk monitoring
- Compliance surveillance
- Middle/back office reconciliation
- Disaster recovery

Architecture:

```
Trader -> OMS -> Venue
                   |
                   +---> Drop Copy Session -> Risk System
                   +---> Drop Copy Session -> Compliance System
                   +---> Drop Copy Session -> Middle Office
```

Drop copy implementation:
- Separate FIX session with its own SenderCompID/TargetCompID
- Receives all ExecutionReport (8) messages in real time
- May also receive OrderCancelReject (9) messages
- Must not send orders (read-only session)
- Must handle gap-fill and retransmission independently
- Some venues provide drop copy as a separate service (e.g., CME iLink drop copy)

FIX tags relevant to drop copy:

| Field | FIX Tag | Description |
|-------|---------|-------------|
| CopyMsgIndicator | 797 | `Y` indicates this is a drop copy message |
| SecondaryExecID | 527 | Secondary execution ID for cross-referencing |

### 10.2 Order Audit Trail

Regulatory requirements mandate comprehensive order audit trails:

#### SEC Rule 17a-25 / CAT (Consolidated Audit Trail)

The CAT NMS Plan requires reporting of:
- Order receipt or origination
- Order routing
- Order modification (cancel/replace)
- Order cancellation
- Order execution

CAT reporting fields:
| Field | Description |
|-------|-------------|
| senderIMID | Sender's Industry Member ID |
| routedOrderID | Unique routed order identifier |
| symbol | Security symbol |
| eventTimestamp | Timestamp in nanosecond precision |
| side | Buy/Sell/Short/ShortExempt |
| price | Order price |
| quantity | Order quantity |
| orderType | Market/Limit/Stop/etc. |
| timeInForce | TIF code |
| tradingSession | Regular/PreMarket/PostMarket |
| handlingInstructions | Algo, DMA, care, etc. |
| routeRejectedFlag | Whether the route was rejected |
| firmDesignatedID | Customer account identifier |

#### OATS (Order Audit Trail System) -- Replaced by CAT

Legacy FINRA system, now superseded by CAT. Documented here for historical context.

#### MiFID II (European Markets)

Transaction reporting requirements under MiFID II RTS 25:
- Timestamps must have microsecond precision for high-frequency systems
- Client identification (LEI, national ID)
- Decision maker identification (trader ID)
- Algo identification (algo ID tag)
- Short selling flag
- Waiver indicators for dark pool trades

### 10.3 Internal Audit Trail

Beyond regulatory requirements, the OMS should maintain an internal audit trail with:

| Event | Data Captured |
|-------|---------------|
| Order created | Full order snapshot, user, timestamp, source system |
| Order validated | Validation results (pass/fail), which checks ran |
| Order routed | Destination, routing decision rationale |
| Order acknowledged | Venue order ID, venue timestamp |
| Fill received | Fill details, venue, liquidity indicator |
| Order amended | Previous values, new values, user, reason |
| Order cancelled | Cancellation source (user, system, venue), reason |
| Order rejected | Rejection reason, rejecting entity |
| State transition | Previous state, new state, triggering event |
| Allocation | Post-trade allocation details |

Implementation requirements:
- Append-only storage (immutable audit log)
- Cryptographic chaining or checksums to detect tampering
- Minimum 7-year retention (SEC), 5-year retention (MiFID II)
- Microsecond-precision timestamps, synchronized via PTP or NTP
- Correlation IDs linking related events across systems

---

## 11. Care vs DMA Orders

### 11.1 Care Orders

A care order is given to a broker or sales trader who uses discretion to work the order. The broker "takes care" of the order.

Workflow:
```
Portfolio Manager                  Sales Trader / Broker
      |                                    |
      |--- "Buy 50k AAPL around here" --->|
      |    (phone, chat, or staged order)  |
      |                                    |
      |    [Broker works the order using   |
      |     their judgment, algo, or       |
      |     manual execution]              |
      |                                    |
      |<-- Fill reports over time ---------|
      |                                    |
      |<-- "Done, avg 185.23" ------------|
```

FIX representation:

| Field | FIX Tag | Value |
|-------|---------|-------|
| HandlInst | 21 | `3` (Manual) or `2` (Automated, broker can intervene) |
| ExecInst | 18 | `1` (Not Held) |

Care order characteristics:
- The broker has discretion over timing, price, venue, and execution method.
- The broker is "not held" to a specific price or time benchmark.
- Common for large institutional orders where information leakage is a concern.
- The broker may use algorithms, work the order on the phone, or cross it internally.
- Commissions are typically higher to compensate for the broker's service.
- The OMS tracks the parent care order and receives fill reports but does not control child order generation.

### 11.2 DMA Orders

Direct Market Access orders go directly to the venue without broker intermediation.

| Field | FIX Tag | Value |
|-------|---------|-------|
| HandlInst | 21 | `1` (Automated execution, no broker intervention) |

DMA characteristics:
- The buy-side firm controls routing, timing, and price.
- The firm's OMS or EMS generates and routes orders directly to venues.
- Lower commission costs (execution-only, no advisory service).
- The firm is responsible for all pre-trade risk controls (SEC 15c3-5).
- Requires sponsored access agreement with the broker providing market access.
- Lower latency since there is no broker intermediation.

### 11.3 Sponsored Access vs. Direct Access

| Model | Description |
|-------|-------------|
| **Sponsored access** | The buy-side connects through the broker's infrastructure. The broker's MPID is on the order. Broker provides pre-trade risk controls. |
| **Direct access (naked)** | Largely prohibited after SEC 15c3-5. The buy-side connected directly to the exchange with minimal broker oversight. |
| **Co-located DMA** | The buy-side's trading engine runs in the exchange's co-location facility, connected through the broker's gateway. |

### 11.4 Hybrid Workflows

In practice, many orders start as care and transition:

1. PM creates a care order in the OMS.
2. Trader receives the order on the blotter.
3. Trader decides to work it via a broker algo (semi-DMA).
4. Or trader sends it DMA to a specific venue.
5. The OMS tracks both the parent care order and the child DMA/algo orders.

---

## 12. Allocation and Post-Trade Order Splitting

### 12.1 Pre-Trade Allocation (Block Order Model)

A block order is placed for a single account or an aggregated "average price" account, then allocated post-trade to individual sub-accounts.

Workflow:
```
1. PM creates order: Buy 100,000 AAPL for Fund Complex
2. Order is executed as a single block (better execution quality)
3. After fills are received, the block is allocated:
   - Fund A: 40,000 shares
   - Fund B: 35,000 shares
   - Fund C: 25,000 shares
4. Each fund receives shares at the average fill price
```

### 12.2 Allocation Methods

| Method | Description |
|--------|-------------|
| **Pro-rata** | Allocate proportionally based on predefined target ratios |
| **Equal** | Equal shares to each account |
| **Specific** | Manually specified quantities per account |
| **Rotational** | Rotate priority across accounts to ensure fairness over time |
| **Target-based** | Allocate to bring each account closest to its target weight |
| **Minimum dispersion** | Algorithm that minimizes deviation from ideal allocation (round-lot aware) |

### 12.3 Average Price Processing

When a block order receives multiple fills at different prices, all sub-accounts receive shares at the average price.

```
Fills:
  10,000 @ 185.00
  15,000 @ 185.10
  25,000 @ 185.05
  20,000 @ 184.95
  30,000 @ 185.08

Average Price = (10000*185.00 + 15000*185.10 + 25000*185.05 + 20000*184.95 + 30000*185.08) / 100000
             = 185.042

All allocations use 185.042 as the fill price, ensuring fair treatment across accounts.
```

Regulatory requirement: SEC Rule 206(3)-2 and investment adviser fiduciary duty require fair allocation. No account can be systematically advantaged by receiving better-priced fills.

### 12.4 FIX Allocation Messages

#### Allocation Instruction (MsgType = J)

| Field | FIX Tag | Description |
|-------|---------|-------------|
| AllocID | 70 | Unique allocation identifier |
| AllocTransType | 71 | `0` (New), `1` (Replace), `2` (Cancel) |
| AllocType | 626 | `1` (Calculated), `2` (Preliminary), `5` (Ready-To-Book) |
| NoOrders | 73 | Number of orders in the block |
| ClOrdID | 11 | (repeating) Order IDs being allocated |
| Side | 54 | Side of the block |
| Symbol | 55 | Instrument |
| Shares | 53 | Total block quantity |
| AvgPx | 6 | Average price |
| TradeDate | 75 | Trade date |
| NoAllocs | 78 | Number of allocation entries |
| AllocAccount | 79 | (repeating) Target account |
| AllocQty | 80 | (repeating) Quantity for each account |
| AllocPrice | 366 | (repeating) Price per account (usually avg price) |

#### Allocation Report (MsgType = AS)

Confirmation of allocation from the broker/prime broker:

| Field | FIX Tag | Description |
|-------|---------|-------------|
| AllocReportID | 755 | Unique report ID |
| AllocStatus | 87 | `0` (Accepted), `1` (Block Level Reject), `2` (Account Level Reject), `3` (Received) |
| AllocRejCode | 88 | Reason code if rejected |
| MatchStatus | 573 | `0` (Compared/Matched), `1` (Uncompared), `2` (Advisory) |

### 12.5 Step-Out and Give-Up

| Concept | Description |
|---------|-------------|
| **Step-out** | Executing broker transfers (steps out) part of an execution to another broker for clearing. Used when the buy-side has execution relationships with multiple brokers but consolidates clearing. |
| **Give-up** | The executing broker "gives up" the trade to the clearing broker designated by the client. Common in futures markets. |

FIX fields:

| Field | FIX Tag | Description |
|-------|---------|-------------|
| NoAllocs | 78 | Number of give-up allocations |
| AllocAccount | 79 | Give-up account |
| AllocQty | 80 | Give-up quantity |
| IndividualAllocID | 467 | Unique ID per allocation leg |
| PartyRole=GiveUpFirm | 452=6 | The firm receiving the give-up |
| PartyRole=ClearingFirm | 452=21 | The clearing broker |

### 12.6 Post-Trade Workflow Summary

```
Execution
    |
    v
[Fills Received] -> Update positions, blotter, P&L
    |
    v
[Trade Matching]  -> Match OMS fills with venue/broker confirms
    |
    v
[Allocation]      -> Split block into sub-account allocations
    |
    v
[Confirmation]    -> Send/receive allocation confirms (FIX J/AS)
    |
    v
[Affirmation]     -> Institutional trade affirmation (e.g., via DTCC CTM/Omgeo)
    |
    v
[Settlement       -> Settlement instruction generation
 Instruction]        CSD/ICSD settlement (DTCC, Euroclear, Clearstream)
    |
    v
[Reconciliation]  -> End-of-day position and cash reconciliation
```

### 12.7 Trade Booking

Allocations result in individual bookings to fund accounting / portfolio management systems:

| Booking Field | Description |
|--------------|-------------|
| Account | Fund/portfolio account |
| Symbol | Instrument |
| Side | Buy/Sell |
| Quantity | Allocated quantity |
| Price | Average fill price |
| Commission | Allocated commission |
| Fees | SEC fee, TAF, exchange fees |
| Net Amount | Total settlement amount |
| Trade Date | Execution date |
| Settlement Date | Expected settlement date |
| Broker | Executing broker |
| Clearing Broker | Clearing firm (if different) |
| Custodian Account | Custodian/prime broker account for settlement |

---

## Appendix A: Common FIX Tag Reference

| Tag | Name | Description |
|-----|------|-------------|
| 1 | Account | Trading account |
| 6 | AvgPx | Average fill price |
| 11 | ClOrdID | Client order ID |
| 14 | CumQty | Cumulative filled quantity |
| 15 | Currency | Order currency |
| 17 | ExecID | Execution report ID |
| 18 | ExecInst | Execution instructions |
| 21 | HandlInst | Handling instructions |
| 22 | SecurityIDSource | Security ID type |
| 30 | LastMkt | Last execution venue |
| 31 | LastPx | Last fill price |
| 32 | LastQty | Last fill quantity |
| 34 | MsgSeqNum | Message sequence number |
| 37 | OrderID | Venue-assigned order ID |
| 38 | OrderQty | Order quantity |
| 39 | OrdStatus | Order status |
| 40 | OrdType | Order type |
| 41 | OrigClOrdID | Original client order ID |
| 43 | PossDupFlag | Possible duplicate flag |
| 44 | Price | Limit price |
| 48 | SecurityID | Security identifier |
| 49 | SenderCompID | Sender firm ID |
| 50 | SenderSubID | Sender sub-ID (trader) |
| 52 | SendingTime | Message timestamp |
| 54 | Side | Order side |
| 55 | Symbol | Instrument symbol |
| 56 | TargetCompID | Target firm ID |
| 58 | Text | Free-form text |
| 59 | TimeInForce | Time in force |
| 60 | TransactTime | Transaction timestamp |
| 66 | ListID | List order ID |
| 70 | AllocID | Allocation ID |
| 75 | TradeDate | Trade date |
| 76 | ExecBroker | Executing broker |
| 78 | NoAllocs | Number of allocations |
| 79 | AllocAccount | Allocation account |
| 80 | AllocQty | Allocation quantity |
| 97 | PossResend | Possible resend flag |
| 99 | StopPx | Stop trigger price |
| 100 | ExDestination | Target venue |
| 102 | CxlRejReason | Cancel reject reason |
| 103 | OrdRejReason | Order reject reason |
| 108 | HeartBtInt | Heartbeat interval |
| 110 | MinQty | Minimum fill quantity |
| 111 | MaxFloor | Display quantity (iceberg) |
| 126 | ExpireTime | Order expiration time |
| 141 | ResetSeqNumFlag | Reset sequence numbers |
| 150 | ExecType | Execution report type |
| 151 | LeavesQty | Remaining quantity |
| 167 | SecurityType | Security type |
| 200 | MaturityMonthYear | Derivatives expiry |
| 201 | PutOrCall | Put or call |
| 202 | StrikePrice | Option strike price |
| 207 | SecurityExchange | Primary exchange |
| 211 | PegOffsetValue | Peg offset |
| 231 | ContractMultiplier | Contract multiplier |
| 378 | ExecRestatementReason | Unsolicited state change reason |
| 432 | ExpireDate | Order expiration date |
| 434 | CxlRejResponseTo | Cancel or cancel/replace |
| 447 | PartyIDSource | Party ID source |
| 448 | PartyID | Party identifier |
| 452 | PartyRole | Party role |
| 453 | NoPartyIDs | Number of parties |
| 461 | CFICode | ISO 10962 instrument class |
| 527 | SecondaryExecID | Secondary execution ID |
| 553 | Username | Session username |
| 554 | Password | Session password |
| 583 | ClOrdLinkID | Linked order group ID |
| 626 | AllocType | Allocation type |
| 797 | CopyMsgIndicator | Drop copy flag |
| 836 | PegOffsetType | Peg offset type |
| 847 | TargetStrategy | Algo strategy |
| 848 | TargetStrategyParameters | Algo parameters |
| 851 | LastLiquidityInd | Liquidity add/remove |
| 957 | NoStrategyParameters | Number of algo params |
| 958 | StrategyParameterName | Algo param name |
| 959 | StrategyParameterType | Algo param type |
| 960 | StrategyParameterValue | Algo param value |
| 1084 | DisplayMethod | Display method |
| 1094 | PegPriceType | Peg price type |
| 1133 | ExDestinationIDSource | Venue ID source |
| 1385 | ContingencyType | Contingency type |

---

## Appendix B: OrdRejReason Values (Tag 103)

| Value | Meaning |
|-------|---------|
| 0 | Broker/exchange option |
| 1 | Unknown symbol |
| 2 | Exchange closed |
| 3 | Order exceeds limit |
| 4 | Too late to enter |
| 5 | Unknown order |
| 6 | Duplicate order |
| 7 | Duplicate of a verbally communicated order |
| 8 | Stale order |
| 9 | Trade along required |
| 10 | Invalid investor ID |
| 11 | Unsupported order characteristic |
| 13 | Incorrect quantity |
| 14 | Incorrect allocated quantity |
| 15 | Unknown account(s) |
| 18 | Invalid price increment |
| 99 | Other |

---

## Appendix C: ExecRestatementReason Values (Tag 378)

| Value | Meaning |
|-------|---------|
| 0 | GT corporate action |
| 1 | GT renewal/restatement |
| 2 | Verbal change |
| 3 | Repricing of order |
| 4 | Broker option |
| 5 | Partial decline of OrderQty |
| 6 | Cancel on Trading Halt |
| 7 | Cancel on System Failure |
| 8 | Market (Exchange) Option |
| 9 | Cancelled, not best |
| 10 | Warehouse recap |
| 11 | Peg refresh |
| 99 | Other |
