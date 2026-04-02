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
