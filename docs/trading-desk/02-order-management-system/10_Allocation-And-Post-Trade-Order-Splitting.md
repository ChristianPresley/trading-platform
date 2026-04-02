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
