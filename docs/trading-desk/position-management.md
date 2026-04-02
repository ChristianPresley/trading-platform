# Position Management

Comprehensive reference for position management as implemented in professional trading desk applications. Covers real-time tracking, aggregation, multi-currency handling, reconciliation, corporate actions, cost basis, and limit monitoring.

---

## Table of Contents

1. [Real-Time Position Tracking](#1-real-time-position-tracking)
2. [Position Views](#2-position-views)
3. [Position Aggregation and Netting](#3-position-aggregation-and-netting)
4. [Multi-Currency Positions](#4-multi-currency-positions)
5. [Cash and Margin Management](#5-cash-and-margin-management)
6. [Position Reconciliation](#6-position-reconciliation)
7. [Corporate Actions Impact on Positions](#7-corporate-actions-impact-on-positions)
8. [Average Cost and Tax Lot Tracking](#8-average-cost-and-tax-lot-tracking)
9. [SOD Positions and Position Breaks](#9-sod-positions-and-position-breaks)
10. [Position Limits and Monitoring](#10-position-limits-and-monitoring)

---

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

---

## 4. Multi-Currency Positions

### Base Currency Conversion

Every firm defines a **base currency** (also called reporting currency or book currency). All positions denominated in foreign currencies must be converted to the base currency for consolidated reporting.

```
PositionValue_Base = PositionValue_Local * FxRate(Local -> Base)
```

FX rates are sourced from:

- **Real-time spot rates** for intraday reporting.
- **WM/Reuters 4pm London fix** (or similar benchmark) for official EOD valuations.

### FX Exposure

FX exposure arises from holding any asset denominated in a currency other than the base currency. The total FX exposure to a given currency is:

```
FxExposure(CCY) = sum(MTM_Base) for all positions denominated in CCY
```

This includes:

- Direct FX positions (spot, forwards, options).
- Indirect exposure from foreign-denominated securities.
- Accrued income in foreign currency.
- Pending settlements in foreign currency.

### Cross-Currency P&L

P&L on foreign-denominated positions decomposes into local P&L and FX P&L:

```
TotalPnL_Base = LocalPnL * FxRate + FxPnL
```

Where:

```
LocalPnL = (Price_Now - Price_Prev) * Quantity * Multiplier  [in local currency]
FxPnL = PositionValue_Local * (FxRate_Now - FxRate_Prev)     [in base currency]
```

More precisely, using the exact decomposition:

```
PnL_Base = (P1 * FX1 - P0 * FX0) * Qty * Multiplier
         = (P1 - P0) * FX0 * Qty * Multiplier          [Local price P&L at old FX]
         + P0 * (FX1 - FX0) * Qty * Multiplier          [FX P&L on old position value]
         + (P1 - P0) * (FX1 - FX0) * Qty * Multiplier   [Cross-term]
```

The cross-term is typically small and is allocated to either the local P&L or FX P&L depending on firm convention.

### Multi-Currency Cash Balances

Cash balances are tracked per currency. A typical cash ladder shows:

```
Currency   SOD Balance   Buys      Sells     Fees     EOD Balance   Base Equiv
--------   -----------   ------    ------    ------   -----------   ----------
USD        1,250,000     -500,000  300,000   -1,200   1,048,800     1,048,800
EUR          450,000     -200,000  150,000     -800     399,200       439,120
GBP          200,000            0   50,000     -300     249,700       317,118
JPY       50,000,000           0         0    -5,000  49,995,000     333,300
--------                                                           ----------
Total Base                                                          2,138,338
```

---

## 5. Cash and Margin Management

### Buying Power

Buying power represents the total value of securities a trader can purchase. It is calculated differently for cash accounts vs. margin accounts:

**Cash Account:**
```
BuyingPower = CashBalance + UnsettledSales - UnsettledPurchases
```

**Margin Account (Reg T, US Equities):**
```
BuyingPower = (Equity - InitialMarginRequirement) / InitialMarginRate
```

For a standard Reg T account with 50% initial margin:
```
BuyingPower = ExcessEquity / 0.50 = ExcessEquity * 2
```

**Portfolio Margin Account:**
```
BuyingPower = NetLiquidation - PortfolioMarginRequirement
```

Portfolio margin uses risk-based calculations (TIMS, SPAN, or OCC methodology) and typically provides 4-6x more buying power than Reg T for hedged portfolios.

### Margin Requirements

| Margin Type | When Assessed | Purpose |
|---|---|---|
| **Initial Margin** | At trade entry | Minimum equity to open a position |
| **Maintenance Margin** | Ongoing | Minimum equity to hold a position |
| **Variation Margin** | Daily (futures/cleared OTC) | Daily settlement of MTM gains/losses |
| **Concentration Margin** | When position exceeds thresholds | Additional margin for concentrated positions |

### Reg T Margin (US Equities)

```
Initial Margin = 50% of position value (Regulation T)
Maintenance Margin = 25% of position value (FINRA minimum, many brokers use 30-40%)
```

Margin equity calculation:
```
Equity = MarketValue_Long - DebitBalance + CreditBalance - MarketValue_Short
MarginExcess = Equity - MaintenanceRequirement
```

### SPAN Margin (Futures and Options)

SPAN (Standard Portfolio Analysis of Risk) is used by most futures exchanges. It calculates margin by simulating portfolio value changes under 16 risk scenarios:

| Scenario | Price Move | Volatility Move |
|---|---|---|
| 1 | 0 | +1 vol shift |
| 2 | 0 | -1 vol shift |
| 3 | +1/3 range | +1 vol shift |
| 4 | +1/3 range | -1 vol shift |
| 5 | -1/3 range | +1 vol shift |
| 6 | -1/3 range | -1 vol shift |
| 7 | +2/3 range | +1 vol shift |
| 8 | +2/3 range | -1 vol shift |
| 9 | -2/3 range | +1 vol shift |
| 10 | -2/3 range | -1 vol shift |
| 11 | +3/3 range | +1 vol shift |
| 12 | +3/3 range | -1 vol shift |
| 13 | -3/3 range | +1 vol shift |
| 14 | -3/3 range | -1 vol shift |
| 15 | +extreme move | 0 |
| 16 | -extreme move | 0 |

SPAN margin = maximum portfolio loss across all 16 scenarios, with offsets for inter-commodity spreads.

### Margin Calls

A margin call is triggered when account equity falls below the maintenance margin requirement:

```
MarginCall = MaintenanceRequirement - AccountEquity  (when positive)
```

Margin call types:

| Type | Trigger | Deadline |
|---|---|---|
| **Reg T Call** | Initial margin not met at trade entry | T+2 (or T+5 with extension) |
| **Maintenance Call** | Equity below maintenance requirement | Typically T+3 to T+5 |
| **Fed Call** | Reg T initial margin shortfall | T+2 |
| **Exchange Call** | Exchange minimum not met | Same day or next morning |
| **House Call** | Broker's internal margin not met | Immediate to T+3 |

Failure to meet a margin call results in forced liquidation of positions, typically starting with the most liquid holdings.

### Cash Management Metrics

| Metric | Formula |
|---|---|
| Net Liquidation Value | `Cash + MarketValue_Long - MarketValue_Short + OptionValue` |
| Available Funds | `NetLiquidation - InitialMarginRequirement` |
| Excess Liquidity | `NetLiquidation - MaintenanceMarginRequirement` |
| SMA (Special Memorandum Account) | High-water mark of Reg T excess, adjusted daily |
| Leverage Ratio | `GrossPositionValue / NetLiquidation` |

---

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

---

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

---

## 8. Average Cost and Tax Lot Tracking

### Tax Lot Concept

A **tax lot** is a record of a specific purchase (or short sale) of securities, including the date, quantity, and price. Tax lots are the building blocks of cost basis tracking. When a position is reduced, the system must determine which specific tax lots are being sold to calculate realized P&L.

### Cost Basis Methods

#### FIFO (First In, First Out)

The oldest lots are sold first.

```
Buys:
  Lot 1: 100 shares @ $50  (Jan 15)
  Lot 2: 200 shares @ $55  (Feb 10)
  Lot 3: 150 shares @ $52  (Mar 5)

Sell: 250 shares @ $60

FIFO allocation:
  Close Lot 1: 100 shares, RealizedPnL = (60 - 50) * 100 = $1,000
  Close Lot 2: 150 shares, RealizedPnL = (60 - 55) * 150 = $750
  Remaining Lot 2: 50 shares @ $55
  Lot 3 untouched: 150 shares @ $52

Total Realized P&L = $1,750
```

#### LIFO (Last In, First Out)

The newest lots are sold first.

```
Same example, LIFO allocation:
  Close Lot 3: 150 shares, RealizedPnL = (60 - 52) * 150 = $1,200
  Close Lot 2: 100 shares, RealizedPnL = (60 - 55) * 100 = $500
  Remaining Lot 2: 100 shares @ $55
  Lot 1 untouched: 100 shares @ $50

Total Realized P&L = $1,700
```

#### Specific Lot Identification

The trader or portfolio manager selects which specific lots to sell. This provides maximum control over tax consequences and P&L timing.

Common strategies:
- **Highest cost**: Minimize realized gain (or maximize realized loss) for tax purposes.
- **Lowest cost**: Maximize realized gain (e.g., to offset losses elsewhere).
- **Tax-loss harvesting**: Specifically target lots with losses.
- **Long-term vs. short-term**: Select lots based on holding period for preferential tax rates.

#### Average Cost Method

Used primarily for mutual funds and some jurisdictions (e.g., UK for CGT calculations):

```
AverageCost = TotalCostOfAllLots / TotalQuantity
```

After each new purchase:
```
AverageCost = (OldQuantity * OldAvgCost + NewQuantity * NewPrice) / (OldQuantity + NewQuantity)
```

When selling:
```
RealizedPnL = (SellPrice - AverageCost) * SoldQuantity
```

### Wash Sale Rules (US)

Under IRS wash sale rules, a loss on a sale is disallowed if a "substantially identical" security is purchased within 30 days before or after the sale. The disallowed loss is added to the cost basis of the replacement shares.

```
Example:
  Sell 100 shares of AAPL at a $2,000 loss on March 1
  Buy 100 shares of AAPL on March 15 at $150

  Wash sale triggered: $2,000 loss disallowed
  New cost basis: $150 + ($2,000/100) = $170 per share
  Holding period: Tacked from original purchase date
```

Systems must track wash sales across:
- The same account.
- Related accounts (IRA, spouse accounts in some interpretations).
- Substantially identical securities (e.g., converting between share classes).

### Multi-Currency Tax Lots

For foreign-denominated securities, each tax lot records:

```
Lot {
  Quantity: 1000
  LocalPrice: EUR 45.00
  FxRateAtPurchase: 1.10 (EUR/USD)
  BaseCurrencyCost: USD 49,500
  PurchaseDate: 2024-03-15
}
```

On sale, both the local price change and the FX rate change contribute to realized P&L:

```
SaleProceeds_Base = LocalSalePrice * Quantity * FxRate_AtSale
CostBasis_Base = LocalPurchasePrice * Quantity * FxRate_AtPurchase
RealizedPnL_Base = SaleProceeds_Base - CostBasis_Base
```

---

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

## 10. Position Limits and Monitoring

### Limit Types

Professional trading desks enforce multiple layers of position limits:

| Limit Type | Scope | Example |
|---|---|---|
| **Per-Trader** | Individual trader limits | Max $10M net notional per trader |
| **Per-Desk** | Aggregate desk limits | Max $100M gross notional for equity desk |
| **Per-Instrument** | Single security concentration | Max 50,000 shares of any single name |
| **Per-Sector** | GICS sector exposure | Max 30% of NAV in Technology |
| **Per-Country** | Country concentration | Max 15% of NAV in any emerging market country |
| **Per-Asset-Class** | Asset class allocation | Max 40% of NAV in fixed income |
| **Per-Strategy** | Strategy allocation | Max $25M to mean-reversion strategy |
| **Per-Issuer** | Issuer concentration | Max 5% of NAV in any single issuer |
| **Per-Currency** | Currency exposure | Max 20% unhedged FX exposure |
| **Per-Tenor** | Maturity bucket (fixed income) | Max $50M DV01 in 10Y+ bucket |

### Limit Metrics

Limits can be expressed in various units:

| Metric | Description |
|---|---|
| **Quantity** | Number of shares/contracts |
| **Notional** | Market value of position |
| **% of NAV** | Position as percentage of fund net asset value |
| **% of ADV** | Position as percentage of average daily volume |
| **DV01** | Dollar value of 1bp interest rate move |
| **Delta-adjusted** | Options positions expressed as delta-equivalent underlying |
| **VaR** | Value at Risk contribution |
| **Margin** | Margin requirement as limit measure |

### Limit Monitoring Architecture

```
[Trade Entry / OMS]
        |
        v
[Pre-Trade Limit Check]  <-- Synchronous, blocks order if limit breached
        |
        v
[Order Routing / Execution]
        |
        v
[Post-Trade Position Update]
        |
        v
[Real-Time Limit Monitor]  <-- Asynchronous, alerts on utilization thresholds
        |
        v
[Alert / Dashboard / Escalation Engine]
```

### Utilization Thresholds

Limits typically have multiple alert thresholds:

| Utilization Level | Action |
|---|---|
| 0-75% | Green: Normal trading |
| 75-90% | Amber: Warning alert to trader and risk manager |
| 90-100% | Red: Urgent alert, reduced order sizes, requires approval for new positions |
| >100% | Breach: Trading halted for risk-increasing trades, escalation to management |

### Hard Limits vs. Soft Limits

| Characteristic | Hard Limit | Soft Limit |
|---|---|---|
| Enforcement | Automated rejection of orders | Alert-based, allows temporary exceedance |
| Override | Requires senior management approval | Trader can acknowledge and proceed (within reason) |
| Example | Regulatory position limits (CFTC speculative limits) | Internal risk budget guidelines |
| Audit trail | Full log of any override | Log of acknowledgment |

### Regulatory Position Limits

| Regulation | Scope | Example |
|---|---|---|
| **CFTC Speculative Limits** | US futures | Spot month limits on agricultural, energy, metals |
| **SEC Rule 105** | Short selling before offerings | No short sales within 5 business days of offering |
| **EU Short Selling Regulation** | European equities | Reporting at 0.1% of issued share capital, public disclosure at 0.5% |
| **Section 13(d)/13(g)** | Beneficial ownership | Report within 10 days of crossing 5% of outstanding shares |
| **Hart-Scott-Rodino** | Merger control | Filing required for acquisitions above threshold (~$111.4M in 2023) |

### Position Limit Calculation Example

```
Trader: J. Smith
Desk: US Equity Long/Short
Base Currency: USD
NAV: $500,000,000

Limit Framework:
  Max Gross Notional: $1,000,000,000 (200% of NAV)
  Max Net Notional: $250,000,000 (50% of NAV)
  Max Single Name: $25,000,000 (5% of NAV)
  Max Sector: $150,000,000 (30% of NAV)
  Max Single Name % ADV: 15%

Current Positions:
  Long Notional:  $620,000,000
  Short Notional: $480,000,000
  Gross Notional: $1,100,000,000 ** BREACH: 220% > 200% limit **
  Net Notional:   $140,000,000  (OK: 28% < 50% limit)

  Largest Single Name: AAPL $30,000,000 ** BREACH: 6% > 5% limit **
  Tech Sector: $145,000,000 (OK: 29% < 30% limit)
```

### Concentration Limits

Concentration risk is monitored across multiple dimensions:

```
HHI (Herfindahl-Hirschman Index) = sum((Weight_i)^2) for all positions i

Interpretation:
  HHI < 0.01:  Highly diversified
  0.01-0.15:   Unconcentrated
  0.15-0.25:   Moderate concentration
  HHI > 0.25:  High concentration
```

Top-N concentration:
```
Top 5 Concentration = sum of top 5 position weights as % of total
Top 10 Concentration = sum of top 10 position weights as % of total
```

Many funds target Top 10 concentration below 40-50% of NAV.

### Real-Time Monitoring Dashboard

A typical position limit monitoring dashboard displays:

```
+------------------------------------------------------------------+
| POSITION LIMIT MONITOR - US Equity Desk      2024-03-15 14:35:22 |
+------------------------------------------------------------------+
| Metric              | Current    | Limit      | Util% | Status   |
|---------------------|------------|------------|-------|----------|
| Gross Notional      | $980M      | $1,000M    | 98%   | RED      |
| Net Notional        | $120M      | $250M      | 48%   | GREEN    |
| Max Single Name     | $24.5M     | $25M       | 98%   | RED      |
| Tech Sector         | $140M      | $150M      | 93%   | RED      |
| EM Country Max      | $42M       | $75M       | 56%   | GREEN    |
| VaR (95%, 1d)       | $8.2M      | $10M       | 82%   | AMBER    |
| Leverage            | 3.8x       | 4.0x       | 95%   | RED      |
+------------------------------------------------------------------+
| ACTIVE BREACHES: 0                                                |
| WARNINGS: Gross Notional approaching limit                       |
+------------------------------------------------------------------+
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
