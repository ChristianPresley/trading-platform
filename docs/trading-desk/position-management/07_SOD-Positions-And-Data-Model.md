## 9. SOD Positions and Position Breaks

### Start of Day (SOD) Position Process

The SOD position is the official opening position for each trading day. It serves as the baseline for all intraday P&L calculations.

**SOD Build Process (End of Day):**

1. Take previous day's SOD positions.
2. Apply all confirmed trades from the day (T date positions).
3. Apply corporate action adjustments effective today.
4. Apply settlement movements (for settlement date positions).
5. Apply manual adjustments and corrections.
6. Reconcile against external sources (custodians, prime brokers).
7. Resolve or flag any breaks.
8. Snapshot the result as the new SOD.
9. Load SOD into the real-time position server for the next trading day.

```
SOD(T+1) = SOD(T) + Trades(T) + CorpActions(T) + Adjustments(T) +/- Breaks_Resolved(T)
```

### SOD Position Attributes

| Attribute | Description |
|---|---|
| `SOD Quantity` | Position quantity at start of day |
| `SOD Average Cost` | Average cost at start of day |
| `SOD Market Price` | Previous day's closing/settlement price |
| `SOD Market Value` | `SOD Quantity * SOD Market Price * Multiplier` |
| `SOD Unrealized PnL` | `(SOD Market Price - SOD Average Cost) * SOD Quantity` |
| `SOD Accrued Interest` | For fixed income: accrued interest as of SOD |

### Position Breaks

A position break is any discrepancy between expected and actual positions. Breaks can occur between:

- **SOD and real-time**: Trades or adjustments not yet reflected in SOD.
- **Internal systems**: Different systems showing different positions (OMS vs. risk system vs. accounting).
- **Internal vs. external**: Firm's books vs. custodian, prime broker, or clearinghouse.

### Break Detection

```
Break = Position_Source_A - Position_Source_B

If abs(Break) > Tolerance:
    Flag as break, assign to operations for investigation
```

### Common Causes of Position Breaks

| Cause | Description | Resolution |
|---|---|---|
| Late trade booking | Trade entered after EOD cutoff | Rebook with correct trade date |
| Amendment/cancellation | Trade modified after EOD snap | Apply amendment to SOD |
| Missed corporate action | Corp action not processed | Apply adjustment |
| FX conversion error | Wrong FX rate used | Correct rate, recompute |
| System timing | Different cutoff times between systems | Align cutoffs or apply timing adjustment |
| Failed settlement | Trade did not settle as expected | Investigate with counterparty |
| Misbooked trade | Wrong account, instrument, or quantity | Cancel and rebook correctly |

### Break Aging and Escalation

```
T+0:  Newly identified break, assigned to operations
T+1:  First follow-up, root cause expected
T+3:  Escalate to operations manager
T+5:  Escalate to desk head, potential P&L impact quantified
T+10: Escalate to COO/CFO, regulatory implications assessed
```

---


## Appendix: Key Data Model Entities

```
Position
├── PositionId (PK)
├── AccountId (FK)
├── InstrumentId (FK)
├── LegalEntityId (FK)
├── TraderId (FK)
├── StrategyId (FK)
├── SettlementDate
├── Currency
├── Quantity
├── AverageCost
├── MarketPrice
├── UnrealizedPnL
├── RealizedPnL
├── SODQuantity
├── SODAverageCost
├── LastUpdated
│
├── TaxLots[]
│   ├── LotId (PK)
│   ├── OpenDate
│   ├── Quantity
│   ├── CostPrice
│   ├── CostFxRate
│   └── WashSaleAdjustment
│
├── CorporateActionAdjustments[]
│   ├── AdjustmentId (PK)
│   ├── ActionType
│   ├── ExDate
│   ├── AdjustmentFactor
│   └── CashInLieu
│
└── PositionLimits[]
    ├── LimitId (PK)
    ├── LimitType
    ├── LimitValue
    ├── CurrentUtilization
    └── Status (GREEN/AMBER/RED/BREACH)
```
