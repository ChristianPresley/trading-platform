## 5. Pre-Trade Risk Controls

Pre-trade risk controls are synchronous checks evaluated before an order is sent to market. They must execute in microseconds to avoid adding unacceptable latency.

### Control Framework

```
[Trader Submits Order]
       |
       v
[1. Order Validation]        -- Format, required fields, instrument validity
       |
       v
[2. Price Reasonability]     -- Order price vs. reference price
       |
       v
[3. Size Limits]             -- Max order size, max notional per order
       |
       v
[4. Position Limits]         -- Would fill cause position limit breach?
       |
       v
[5. Credit/Margin Check]     -- Sufficient margin/buying power?
       |
       v
[6. Concentration Check]     -- Would fill cause concentration issue?
       |
       v
[7. Message Rate Throttle]   -- Within allowed order rate?
       |
       v
[8. Duplicate Check]         -- Not a duplicate of recent order?
       |
       v
[PASS: Route to Market]   or   [FAIL: Reject with reason code]
```

### Order Size Limits

| Limit | Description | Example |
|---|---|---|
| **Max shares per order** | Per-instrument quantity cap | 100,000 shares for large-cap, 10,000 for small-cap |
| **Max notional per order** | Dollar value cap per order | $5M per order |
| **Max notional per day** | Cumulative daily notional cap | $100M per day per trader |
| **Max % ADV per order** | Order as fraction of average daily volume | 5% of ADV per order |
| **Max orders per second** | Message rate limit | 100 orders/second per session |

### Price Reasonability Checks

```
Equity:
  Reject if OrderPrice deviates > 5% from NBBO midpoint
  Reject if OrderPrice deviates > 10% from last trade

Fixed Income:
  Reject if yield deviation > 25bps from benchmark

FX:
  Reject if rate deviates > 0.5% from ECN mid-rate

Options:
  Reject if price deviates > 50% from theoretical value
  Additional check: reject if implied vol > 200% or < 1%
```

### Position Limit Checks

Pre-trade position checks project the effect of filling the order:

```
ProjectedPosition = CurrentPosition + OrderQuantity (for buys)
ProjectedPosition = CurrentPosition - OrderQuantity (for sells/shorts)

ProjectedNotional = abs(ProjectedPosition) * ReferencePrice * Multiplier

If ProjectedPosition > MaxPositionLimit: REJECT
If ProjectedNotional > MaxNotionalLimit: REJECT
```

For aggregated limits (desk-level, firm-level), the check must query the central position server:

```
DeskProjectedExposure = DeskCurrentExposure + IncrementalExposure(Order)
If DeskProjectedExposure > DeskLimit: REJECT
```

### Notional Limits

| Level | Limit Type | Typical Value |
|---|---|---|
| Per order | Single order notional | $1M - $50M |
| Per trader per day | Cumulative daily notional | $50M - $500M |
| Per desk per day | Cumulative desk daily | $500M - $5B |
| Per instrument per day | Daily trading in one name | $10M - $100M |

### Message Rate Throttling

Exchanges and regulators impose message rate limits to prevent order flooding:

```
OrdersPerSecond check:
  Count orders in sliding window (1 second)
  If count > MaxRate: THROTTLE (queue or reject)

Common limits:
  Equity exchange: 50-300 messages/second per port
  Options exchange: 100-500 messages/second per port
  Futures exchange: 50-200 messages/second per port

Internal limits may be tighter:
  Per-trader: 10-50 orders/second
  Per-strategy: 20-100 orders/second
  Per-desk: 100-500 orders/second
```

Order-to-trade ratio monitoring:
```
OTR = OrderCount / TradeCount
Regulatory concern if OTR > 100:1 (varies by jurisdiction)
```

---
