## 3. Liquidity Risk

Liquidity risk is the risk that a position cannot be liquidated quickly enough at a reasonable price.

### Bid-Ask Spread Risk

The bid-ask spread represents an immediate transaction cost and varies with market conditions:

```
SpreadCost = 0.5 * BidAskSpread * PositionSize
```

For a portfolio:
```
LiquidationCost = sum_i [ 0.5 * Spread_i * abs(Position_i) ]
```

Spreads widen dramatically during market stress:

| Instrument | Normal Spread | Stressed Spread |
|---|---|---|
| Large-cap US equity | 1-2 bps | 10-50 bps |
| US Treasury 10Y | 0.5-1 bp | 5-15 bps |
| Investment grade corporate bond | 5-15 bps | 50-200 bps |
| High yield bond | 25-100 bps | 200-1000 bps |
| EM sovereign bond | 10-30 bps | 100-500 bps |
| Small-cap equity | 10-50 bps | 100-500 bps |

### Market Depth Analysis

Market depth measures how much can be traded at or near the current price without significantly moving the market.

**Market impact model (square-root model):**
```
MarketImpact = sigma * sqrt(Q / V) * k
```

Where:
- `sigma` = daily volatility
- `Q` = quantity to trade
- `V` = average daily volume (ADV)
- `k` = market impact coefficient (calibrated, typically 0.5-1.5)

**Participation rate constraint:**
```
MaxParticipation = 20-25% of ADV per day (typical soft limit)
```

For a position of size Q at price P:
```
DaysToLiquidate = Q / (MaxParticipation * ADV)
LiquidationCost = MarketImpact + SpreadCost + OpportunityCost
```

### Liquidation Horizon

The liquidation horizon is the time required to fully unwind a position without undue market impact:

```
LiquidationHorizon(days) = PositionSize / (ParticipationRate * ADV)
```

Example:
```
Position: 500,000 shares of mid-cap stock
ADV: 200,000 shares
Max participation: 25%
Liquidation horizon: 500,000 / (0.25 * 200,000) = 10 days
```

Liquidity-adjusted VaR incorporates the liquidation horizon:

```
LVaR = VaR(1 day) * sqrt(LiquidationHorizon) + LiquidationCost
```

### Concentration Risk (Liquidity Dimension)

Concentration risk arises when a position is large relative to the market:

| Metric | Formula | Threshold |
|---|---|---|
| % of ADV | `Position / ADV` | >25% is concentrated |
| % of shares outstanding | `Position / SharesOutstanding` | >1% triggers disclosure (13F) |
| % of float | `Position / FreeFloat` | >5% is highly concentrated |
| Days to liquidate | `Position / (ParticipationRate * ADV)` | >5 days is illiquid |
| % of open interest | `Contracts / OpenInterest` (derivatives) | >10% is concentrated |

### Liquidity Stress Metrics

| Metric | Description |
|---|---|
| **Liquidity Coverage Ratio (LCR)** | High-quality liquid assets / 30-day net cash outflows >= 100% |
| **Net Stable Funding Ratio (NSFR)** | Available stable funding / Required stable funding >= 100% |
| **Cash Burn Rate** | Days of operations fundable from available cash |
| **Redemption Gate** | Max redemption per period (hedge funds) |
| **Funding Liquidity** | Ability to roll short-term funding (repo, CP, credit lines) |

---

## 4. Operational Risk

Operational risk is the risk of loss from inadequate or failed internal processes, people, systems, or external events.

### Trade Errors

| Error Type | Description | Prevention |
|---|---|---|
| **Wrong side** | Buy instead of sell, or vice versa | Confirmation dialogs, color-coded buy/sell |
| **Wrong size** | Incorrect quantity or notional | Order size reasonability checks |
| **Wrong instrument** | Trading the wrong ticker/ISIN | Instrument validation, search disambiguation |
| **Wrong account** | Booked to incorrect account | Default account rules, account validation |
| **Wrong price** | Limit price error (e.g., decimal point) | Price reasonability checks vs. market |
| **Duplicate order** | Same order submitted twice | Duplicate detection (idempotency keys) |

### Fat Finger Prevention

Fat finger controls are automated checks that reject clearly erroneous orders:

```
Order Validation Rules:
  1. Price within X% of market price (e.g., 5% for equities, 1% for FX)
  2. Quantity below maximum order size for instrument
  3. Notional below trader's single-order limit
  4. No duplicates within time window (e.g., same instrument/side/size within 5 seconds)
  5. Order does not exceed position limit when filled
  6. Order does not exceed buying power / margin availability
```

Price reasonability check:
```
ReferencePrice = LastTradePrice or MidQuote
MaxAllowedPrice = ReferencePrice * (1 + PriceTolerancePct)
MinAllowedPrice = ReferencePrice * (1 - PriceTolerancePct)

If OrderPrice > MaxAllowedPrice OR OrderPrice < MinAllowedPrice:
    REJECT order with "Price outside tolerance band"
```

### System Failures and Kill Switches

**Kill switch** is an emergency mechanism to halt all trading activity instantly:

| Kill Switch Level | Scope | Trigger |
|---|---|---|
| **Trader-level** | Cancel all orders for one trader | Trader request, limit breach |
| **Desk-level** | Cancel all orders for entire desk | Desk-level risk breach |
| **Firm-level** | Cancel all orders across the firm | System malfunction, market crisis |
| **Strategy-level** | Halt a specific algo/strategy | Strategy behaving abnormally |
| **Venue-level** | Stop routing to a specific venue | Venue connectivity issues |

Kill switch implementation:
```
1. Cancel-on-Disconnect (COD): Exchange automatically cancels all open orders if connection drops
2. Heartbeat monitoring: If algo fails to send heartbeat within N seconds, kill all orders
3. P&L circuit breaker: If strategy loses more than threshold, kill all orders and flatten
4. Message rate breaker: If order rate exceeds threshold, throttle or halt
5. Position breaker: If position exceeds limit, kill risk-increasing orders
```

**SEC Rule 15c3-5** (Market Access Rule) requires broker-dealers to implement:
- Pre-trade risk controls.
- Real-time monitoring.
- Kill switch capability.
- Annual CEO certification of controls.

### Operational Risk Metrics

| Metric | Description |
|---|---|
| **Trade break rate** | % of trades with booking errors |
| **Settlement fail rate** | % of trades failing to settle on time |
| **System uptime** | Availability of critical trading systems |
| **RTO / RPO** | Recovery Time Objective / Recovery Point Objective |
| **Error loss amount** | Dollar loss from operational errors (trailing 12 months) |
| **Near miss count** | Incidents caught before causing loss |

---
