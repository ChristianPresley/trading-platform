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
