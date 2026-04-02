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

