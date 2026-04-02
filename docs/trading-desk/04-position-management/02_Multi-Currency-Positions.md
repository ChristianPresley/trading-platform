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

