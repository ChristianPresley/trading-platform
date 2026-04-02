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
