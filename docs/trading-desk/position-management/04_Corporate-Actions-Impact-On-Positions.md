## 7. Corporate Actions Impact on Positions

Corporate actions are events initiated by a company that affect its securities. They require adjustments to positions, cost basis, and sometimes P&L.

### Mandatory Corporate Actions

These happen automatically; no holder election is required.

#### Stock Splits and Reverse Splits

**Forward Split (e.g., 2-for-1):**
```
New Quantity = Old Quantity * Split Ratio
New Price = Old Price / Split Ratio
New Average Cost = Old Average Cost / Split Ratio
```

Example: 1,000 shares at $200 average cost, 2:1 split:
```
After: 2,000 shares at $100 average cost
Position value unchanged: 2,000 * $100 = $200,000
```

**Reverse Split (e.g., 1-for-10):**
```
New Quantity = Old Quantity / Reverse Ratio
New Price = Old Price * Reverse Ratio
New Average Cost = Old Average Cost * Reverse Ratio
```

Fractional shares from reverse splits are typically cashed out, generating a small realized P&L.

#### Cash Dividends

On the **ex-date**, the stock price drops by approximately the dividend amount. Position tracking must handle:

```
Record Date: Determines holder of record (entitled to dividend)
Ex-Date: First trading date without dividend entitlement (typically T-1 before record date)
Pay Date: Cash is credited to the account
```

Impact on positions:
- Short sellers owe the dividend to the lender (manufactured dividend).
- Dividend receivable is booked on ex-date, cash credited on pay-date.
- Cost basis is not adjusted for ordinary dividends (but is for return-of-capital distributions).

#### Stock Dividends

```
New Quantity = Old Quantity * (1 + Dividend Rate)
New Average Cost = Old Average Cost / (1 + Dividend Rate)
```

#### Mergers and Acquisitions

Mergers can involve cash, stock, or a combination:

**Cash merger (target acquired for cash):**
```
Position closed at merger price
RealizedPnL = (MergerPrice - AverageCost) * Quantity
```

**Stock-for-stock merger:**
```
New Instrument = Acquirer stock
New Quantity = Old Quantity * Exchange Ratio
New Average Cost = Old Average Cost / Exchange Ratio (for tax purposes)
```

**Cash and stock combination:**
```
Cash component generates immediate realized P&L
Stock component continues with adjusted cost basis
```

#### Spin-offs

A spin-off creates a new independent company. The parent's cost basis is allocated between parent and spin-off based on the IRS-prescribed allocation (typically based on relative market values on the first day of regular-way trading):

```
Allocation ratio example: 85% to parent, 15% to spin-off

Parent new cost = Original cost * 0.85
Spin-off cost = Original cost * 0.15
```

The position in the spin-off is created automatically:
```
Spin-off shares = Parent shares * Distribution Ratio
```

### Voluntary Corporate Actions

Holders must elect an option. Systems must track elections and deadlines.

#### Tender Offers
```
Tendered shares: Position reduced, cash or new securities received
Non-tendered shares: Position unchanged (unless mandatory)
```

#### Rights Issues
```
Rights received = Existing shares * Rights Ratio
Rights can be: exercised (buy new shares at subscription price),
               sold in market, or
               allowed to lapse
```

Cost basis of rights:
- If exercised: Cost of new shares = Subscription Price + (allocated cost of rights if purchased)
- If sold: Proceeds less allocated cost basis = realized P&L

### Corporate Action Processing Challenges

- **Multi-market instruments**: ADRs vs. local shares may process differently.
- **Timing**: Announcements, ex-dates, record dates, and pay dates span multiple days.
- **Elections**: Must be submitted by a deadline; default elections apply if not submitted.
- **Fractional shares**: Cash-in-lieu calculations when corporate action produces fractional quantities.
- **Derivative adjustments**: Options, warrants, and convertibles must be adjusted (OCC issues adjustment memos for US listed options).

