## 6. Position Reconciliation

### Trade Date vs. Settlement Date Positions

Trading systems maintain two position views simultaneously:

| View | Definition | Use |
|---|---|---|
| **Trade Date (T)** | Reflects all executed trades immediately | Real-time P&L, risk management |
| **Settlement Date (S)** | Reflects only settled trades | Cash management, delivery obligations |

Standard settlement cycles:

| Instrument | Settlement Cycle |
|---|---|
| US Equities | T+1 (since May 2024) |
| US Treasuries | T+1 |
| Corporate Bonds | T+1 or T+2 |
| FX Spot | T+2 |
| FX Forwards | Agreed date |
| Listed Options | T+1 |
| Futures | Daily variation margin; physical delivery varies |

Between trade date and settlement date, the position exists as a **pending settlement**. The cash impact is projected but not yet realized.

### Street-Side vs. House-Side Reconciliation

| Side | What It Represents |
|---|---|
| **House-side (internal)** | The firm's own books and records |
| **Street-side (external)** | Records held by counterparties, custodians, clearinghouses, and prime brokers |

Reconciliation is the process of matching house-side records against street-side records. Breaks (mismatches) must be investigated and resolved.

Common reconciliation points:

```
House Position (our books)
  vs. Custodian Position (DTC, Euroclear, Clearstream)
  vs. Prime Broker Position (Goldman, Morgan Stanley, JPM)
  vs. Fund Administrator Position (for fund vehicles)
  vs. Exchange/CCP Position (CME, LCH, ICE Clear)
```

### Break Categories

| Break Type | Description | Severity |
|---|---|---|
| **Quantity break** | Position quantity mismatch | High |
| **Price break** | Valuation price differs | Medium |
| **Cash break** | Cash balance mismatch | High |
| **Trade break** | Trade exists on one side but not the other | High |
| **Settlement break** | Trade failed to settle on expected date | Medium |
| **Corporate action break** | Different processing of a corporate action | Medium |
| **Timing break** | Same data, different cut-off times | Low |

### Reconciliation Workflow

1. **Extract**: Pull positions from all sources (internal systems, custodians, prime brokers).
2. **Normalize**: Map instruments to a common identifier (ISIN, CUSIP, SEDOL, internal ID).
3. **Match**: Automated matching by position key (instrument + account + date).
4. **Identify breaks**: Flag unmatched records or matched records with quantity/value differences.
5. **Investigate**: Operations team researches root cause of each break.
6. **Resolve**: Apply corrections (amendments, cancels/rebooking, manual adjustments).
7. **Escalate**: Aged breaks (>T+3 typically) escalated to management.

### Reconciliation Tolerances

Not all differences are genuine breaks. Systems apply tolerances:

```
Quantity tolerance: typically 0 (exact match required)
Price tolerance: 0.01-0.05% (for rounding differences)
Cash tolerance: $0.01 - $1.00 (for rounding)
FX rate tolerance: 0.0001 (4th decimal place)
```

