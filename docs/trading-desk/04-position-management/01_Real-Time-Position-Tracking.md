## 1. Real-Time Position Tracking

### Core Position Record

Every position in a trading system is keyed by a composite identifier:

```
PositionKey = (Account, Instrument, Settlement Date, Currency, Legal Entity)
```

The minimum fields maintained per position:

| Field | Description |
|---|---|
| `Quantity` | Signed quantity (positive = long, negative = short) |
| `AverageCost` | Weighted average entry price |
| `MarketPrice` | Current mark-to-market price (live feed) |
| `RealizedPnL` | P&L locked in from closed trades |
| `UnrealizedPnL` | P&L on open positions at current market price |
| `TotalPnL` | `RealizedPnL + UnrealizedPnL` |
| `Notional` | `abs(Quantity) * MarketPrice * ContractMultiplier` |

### Intraday P&L

Intraday P&L tracks profit and loss accumulated since the start of the trading day (SOD). It combines realized and unrealized components:

```
IntradayPnL = RealizedPnL_Today + UnrealizedPnL_Change_Today
```

Where:

```
UnrealizedPnL_Change_Today = UnrealizedPnL_Now - UnrealizedPnL_SOD
```

For positions opened and closed intraday (day trades), the entire P&L flows through the realized component.

### Realized P&L

Realized P&L is recognized when a position is reduced or closed. The calculation depends on the cost basis method (see Section 8), but the general formula is:

```
RealizedPnL = (ExitPrice - EntryCost) * ClosedQuantity * ContractMultiplier
```

For short positions:

```
RealizedPnL = (EntryCost - ExitPrice) * abs(ClosedQuantity) * ContractMultiplier
```

Realized P&L is final and does not change with subsequent market movements.

### Unrealized P&L (Mark-to-Market)

Unrealized P&L reflects the paper gain or loss on open positions:

```
UnrealizedPnL = (MarketPrice - AverageCost) * Quantity * ContractMultiplier
```

This value changes continuously with market price updates. The `MarketPrice` source depends on instrument type:

| Instrument Type | Mark-to-Market Source |
|---|---|
| Listed equities | Last trade price, or mid-quote if no recent trade |
| OTC derivatives | Model price (e.g., Black-Scholes, local vol surface) |
| Fixed income | Evaluated price from pricing vendor (Bloomberg BVAL, ICE) |
| FX spot/forwards | Mid-rate from ECN or interbank feed |
| Illiquid securities | Stale price with staleness flag, manual override |

### Mark-to-Market Process

Mark-to-market (MTM) is the revaluation of all open positions at current market prices. Trading systems perform MTM:

- **Continuously (tick-by-tick)**: For real-time risk and P&L dashboards.
- **Official EOD snap**: For official books and records, NAV calculation, and reporting.
- **Intraday snaps**: Some desks take snapshots at fixed intervals (e.g., hourly) for audit trails.

The EOD MTM drives the next day's SOD position valuation.

### P&L Attribution

Professional systems decompose P&L into components:

```
TotalPnL = TradePnL + PositionPnL + CarryPnL + FxPnL + FeesAndCommissions
```

| Component | Description |
|---|---|
| `TradePnL` | P&L from trades executed today (slippage vs. arrival price) |
| `PositionPnL` | P&L from market moves on SOD positions |
| `CarryPnL` | Accrued interest, dividends, funding costs |
| `FxPnL` | P&L from currency moves on foreign-denominated positions |
| `FeesAndCommissions` | Exchange fees, broker commissions, clearing fees |

---

## 2. Position Views

Trading desks require multiple simultaneous views into the same underlying position data. These are real-time aggregated projections, not separate data stores.

### Standard Hierarchical Views

| View Dimension | Description | Typical Use |
|---|---|---|
| **Account** | Positions per trading account or fund | Fund accounting, client reporting |
| **Desk** | Aggregated across all traders on a desk | Desk head oversight, desk-level risk |
| **Trader** | Positions attributed to a specific trader | Individual P&L attribution, trader limits |
| **Strategy** | Positions grouped by trading strategy | Strategy P&L, alpha decomposition |
| **Instrument** | Single instrument across all accounts/traders | Firm-wide exposure to a single name |
| **Asset Class** | Equities, fixed income, FX, commodities, derivatives | Asset class risk budgets |
| **Currency** | Positions grouped by denomination currency | FX exposure management |
| **Legal Entity** | Positions per legal entity or booking entity | Regulatory reporting, capital calculations |
| **Sector / Industry** | GICS sector, ICB classification | Concentration risk monitoring |
| **Geography / Country** | Country of risk or country of domicile | Sovereign risk, sanctions compliance |
| **Counterparty** | Positions grouped by executing/clearing counterparty | Counterparty credit exposure |
| **Custodian** | Positions grouped by custodian or prime broker | Custody risk, margin management |

### View Implementation

Views are typically implemented as:

1. **Materialized aggregations**: Pre-computed in memory, updated incrementally as positions change. Low latency but high memory cost.
2. **On-demand roll-ups**: Computed on query from the base position store. Higher latency but always consistent.
3. **OLAP cubes / columnar stores**: For ad-hoc slicing across multiple dimensions simultaneously.

A real-time position server typically uses approach (1) for the most critical views (desk, trader) and approach (2) or (3) for ad-hoc analysis.

### Cross-Dimensional Queries

Traders frequently need cross-cuts such as:

- "Show me all delta exposure to AAPL across every account and strategy."
- "What is the net EUR exposure by legal entity?"
- "Total notional in high-yield bonds on the credit desk, broken down by trader."

These require the ability to filter and aggregate across multiple dimensions simultaneously.

---

## 3. Position Aggregation and Netting

### Gross vs. Net Positions

| Measure | Definition | Use |
|---|---|---|
| **Gross Position** | `sum(abs(Quantity))` across all sub-positions | Total market exposure, margin calculations |
| **Net Position** | `sum(Quantity)` (signed) across all sub-positions | Directional exposure, hedging analysis |
| **Long Exposure** | `sum(Quantity) where Quantity > 0` | Long-side risk |
| **Short Exposure** | `sum(abs(Quantity)) where Quantity < 0` | Short-side risk |
| **Gross Notional** | `sum(abs(Quantity * Price * Multiplier))` | Leverage calculations |
| **Net Notional** | `sum(Quantity * Price * Multiplier)` | Directional notional exposure |

### Netting Levels

Netting can occur at multiple levels depending on purpose:

| Level | Netting Scope | Purpose |
|---|---|---|
| **Trade-level** | No netting (each fill is separate) | Audit trail, transaction cost analysis |
| **Position-level** | Fills netted per position key | Real-time position management |
| **Account-level** | Positions netted across instruments within account | Margin netting, portfolio risk |
| **Legal entity** | Positions netted per entity | Regulatory capital |
| **Counterparty-level** | Positions netted per counterparty under ISDA/CSA | Counterparty credit exposure, collateral |
| **CCP-level** | Positions netted at the clearinghouse | Cleared margin requirements |

### Long/Short Breakdown

Professional position blotters display the long/short decomposition:

```
Account: FUND-A
-----------------------------------------------------------
Instrument    Long Qty   Short Qty   Net Qty   Net Notional
-----------------------------------------------------------
AAPL           5,000         0        5,000     $875,000
MSFT               0    -2,000       -2,000    -$760,000
GOOG           1,000      -500          500     $70,000
SPY Put             0      -20          -20    -$90,000
-----------------------------------------------------------
Totals         6,000     -2,520       3,480     $95,000
Gross Notional: $1,795,000
Net Notional:   $95,000
Long/Short Ratio: 2.38
```

### Netting Agreements (OTC)

For OTC derivatives, bilateral netting is governed by ISDA Master Agreements. Under a netting agreement, if a counterparty defaults, all trades under the agreement are netted to a single payable/receivable rather than being settled individually. This dramatically reduces credit exposure:

```
Gross Exposure = sum(max(0, MTM_i)) for all trades i with counterparty
Net Exposure = max(0, sum(MTM_i)) for all trades i under netting agreement
```

Netting benefit is often 60-80% reduction in exposure for large dealer portfolios.

