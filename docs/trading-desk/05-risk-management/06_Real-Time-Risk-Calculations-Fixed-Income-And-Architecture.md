### Fixed Income Risk Measures

#### DV01 / PV01

**DV01 (Dollar Value of a Basis Point)**: The change in bond price for a 1 basis point (0.01%) parallel shift in the yield curve.

```
DV01 = -(dP / dy) * 0.0001

Approximation:
DV01 = (P(y - 0.5bp) - P(y + 0.5bp)) / 2
```

**PV01 (Present Value of a Basis Point)**: Essentially the same concept; sometimes used to denote the DV01 of a swap (the change in PV for a 1bp shift in the swap rate).

```
For a bond:
  DV01 = ModifiedDuration * Price * 0.0001

Example:
  Bond price: $100
  Modified duration: 7.5 years
  DV01 = 7.5 * 100 * 0.0001 = $0.075 per $100 face value
  For $10M face: DV01 = $7,500 per basis point
```

#### Key Rate DV01s

Rather than assuming a parallel shift, key rate DV01s measure sensitivity to shifts at specific tenor points:

```
KeyRateDV01(tenor) = change in portfolio value for 1bp shift at that tenor only

Standard tenor points: 3M, 6M, 1Y, 2Y, 3Y, 5Y, 7Y, 10Y, 15Y, 20Y, 30Y

Example (portfolio of bonds and swaps):
  Tenor    KeyRate DV01
  2Y       -$2,500
  5Y       +$8,200
  10Y      -$15,800
  30Y      +$5,100
  Total    -$5,000 (=parallel DV01)
```

#### Spread Duration / CS01

**CS01 (Credit Spread 01)**: The change in value for a 1bp widening of credit spreads.

```
CS01 = -(dP / dSpread) * 0.0001

For a corporate bond:
  CS01 = SpreadDuration * Price * 0.0001 * FaceValue
```

#### Convexity

The second derivative of price with respect to yield:

```
Convexity = (1/P) * d^2P / dy^2

Price change including convexity:
  dP/P = -ModifiedDuration * dy + 0.5 * Convexity * (dy)^2
```

Convexity matters for large rate moves. Positive convexity (plain bonds) means the price increase from a rate drop exceeds the price decrease from an equal rate rise.

### Beta Exposure

Beta measures systematic risk relative to a market benchmark:

```
PortfolioBeta = sum_i (Weight_i * Beta_i)

Beta-adjusted exposure = sum_i (Notional_i * Beta_i)
```

Example:
```
Position       Notional    Beta    Beta-Adj Exposure
AAPL Long      $5M         1.15    $5.75M
XOM Long       $3M         0.85    $2.55M
SPY Short      -$4M        1.00    -$4.00M
                                   --------
Beta-Adj Net Exposure:              $4.30M
Portfolio Beta:                     0.72
```

### Real-Time Calculation Architecture

```
[Market Data Feed]
       |
  [Tick Plant / Normalized Feed]
       |
  +---------+---------+---------+
  |         |         |         |
[Equity  [Rates   [Vol      [FX
 Pricer]  Engine]  Surface]  Engine]
  |         |         |         |
  +----+----+----+----+
       |
  [Risk Aggregation Engine]
       |
  +----+----+----+----+
  |         |         |
[Greeks  [VaR     [Stress
 Server]  Engine]  Engine]
       |
  [Risk Dashboard / Alerts]
```

Latency targets:
- Greeks update: < 100ms after market tick
- Position P&L: < 50ms after trade or tick
- Portfolio VaR: 1-5 minute refresh cycle (full recomputation)
- Stress scenarios: 1-15 minute refresh cycle

---
