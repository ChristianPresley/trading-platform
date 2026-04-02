## Futures Roll Management

### What is a Roll?

Futures contracts expire. To maintain continuous exposure, traders "roll" from the expiring (front) contract to the next active (back) contract.

```
Roll = Sell Front Month + Buy Back Month  (for a long position)
Roll = Buy Front Month + Sell Back Month  (for a short position)
```

The roll is typically executed as a **calendar spread** to avoid leg risk.

### Roll Schedules

Each futures contract has a customary roll period when the majority of volume migrates from the front month to the next:

| Contract | Roll Period | Active Months |
|---|---|---|
| ES (E-mini S&P) | Thursday before expiration, ~8 days out | H, M, U, Z (quarterly) |
| CL (Crude Oil) | 3-4 trading days before last trade day | Every month |
| GC (Gold) | ~2 weeks before first notice day | Feb, Apr, Jun, Aug, Oct, Dec (even months) |
| ZN (10-Year Note) | Last week of month preceding delivery | H, M, U, Z |
| ZC (Corn) | ~5 days before first notice day | H, K, N, U, Z |
| 6E (Euro FX) | ~5 days before delivery | H, M, U, Z |
| BRN (Brent Crude) | 2 business days before last trade day | Every month |

**Roll timing matters:** The optimal roll date balances liquidity in both months. Rolling too early means trading in an illiquid back month with wide spreads. Rolling too late risks holding a contract into delivery notice or final settlement with thin liquidity.

### Volume Roll Indicator

Trading systems track the roll by monitoring open interest and volume:

- **OI crossover:** When the back month's open interest exceeds the front month's, the roll is considered complete.
- **Volume crossover:** When intraday volume in the back month exceeds the front month.
- Professional data vendors (Bloomberg, Refinitiv) publish "active contract" designations that switch on roll date.

### Synthetic Continuation (Continuous Contracts)

For charting and backtesting, traders need a continuous price series across contract months. Methods:

1. **Unadjusted (splice):** Simply concatenate front-month prices. Creates gaps at each roll. Suitable for short-term intraday analysis.

2. **Back-adjusted (Panama method):** Add a constant to all historical prices to eliminate the gap at each roll. The most common method. However, old prices become artificial and percentage returns are distorted.

3. **Ratio-adjusted (proportional):** Multiply all historical prices by a ratio at each roll. Preserves percentage returns but distorts absolute levels.

4. **Calendar-weighted:** During the roll period, blend front and back month prices using a weight that shifts linearly from 100% front to 100% back. Smooth transition.

5. **Perpetual contract:** A theoretical construct that interpolates between two nearest contracts to produce a constant-maturity price (e.g., "30-day constant maturity" crude oil).

### Roll Yield (Roll Return)

The return from rolling a futures position, arising from the shape of the futures curve.

- **Contango:** Front month is cheaper than back month (upward-sloping curve). Rolling a long position means selling cheap and buying expensive — **negative roll yield**.
- **Backwardation:** Front month is more expensive than back month (downward-sloping curve). Rolling a long position means selling expensive and buying cheap — **positive roll yield**.

Roll yield is a significant component of total return for commodity investors. Example: Crude oil in persistent contango can lose 5-10% per year from roll yield alone, even if spot prices are flat.

```
Roll Yield (annualized) ≈ (Front Price - Back Price) / Front Price x (365 / Days Between Contracts)
```

---

## Futures Spreads

### Calendar Spreads (Time Spreads)

Simultaneous long and short positions in different months of the same commodity.

```
Long Calendar Spread = Buy Back Month - Sell Front Month
```

**Use cases:**
- Trading the term structure (contango/backwardation)
- Lower margin than outright positions (CME provides spread margin credits)
- Rolling exposure (a roll is just a calendar spread)

**Examples:**
- Long CL March / Short CL February — betting that the March-Feb spread widens.
- Long ZN June / Short ZN March — trading the roll in Treasuries.

**Spread margin:** Typically 10-20% of the outright margin because the two legs are highly correlated.

### Inter-Commodity Spreads

Simultaneous positions in related but different commodities.

#### Crack Spreads (Energy Refining)

Model the economics of refining crude oil into products.

- **3:2:1 Crack Spread:** Buy 3 crude oil (CL), sell 2 gasoline (RB), sell 1 heating oil (HO). Represents a refinery's margin.
- **1:1 Gas Crack:** Buy 1 CL, sell 1 RB.
- **1:1 Heating Oil Crack:** Buy 1 CL, sell 1 HO.

**Calculation (simplified for 1:1 gas crack):**
```
Crack Spread = RB price ($/gallon) x 42 (gallons/barrel) - CL price ($/barrel)
```
42 gallons per barrel is the conversion factor. RB trades in dollars per gallon, CL in dollars per barrel.

Refineries use crack spreads to hedge their processing margin. A refiner who is long physical crude and short product can lock in the spread.

#### Crush Spreads (Agriculture)

Model the economics of crushing soybeans into soybean meal and soybean oil.

```
Crush Spread = (Soybean Meal value + Soybean Oil value) - Soybean cost
```

Standard conversion: 1 bushel of soybeans yields approximately 44 lbs of meal, 11 lbs of oil, and waste.

```
Crush = (ZM price x 0.022) + (ZL price x 11) - ZS price
```

Where ZM = soybean meal ($/short ton), ZL = soybean oil (cents/lb), ZS = soybeans (cents/bushel).

Soybean processors use this to lock in processing margins. The reverse crush is used by livestock feeders.

#### Spark Spreads (Power Generation)

Model the economics of converting natural gas into electricity.

```
Spark Spread = Power Price ($/MWh) - [Natural Gas Price ($/mmBtu) x Heat Rate]
```

Heat rate (mmBtu/MWh) represents the efficiency of the power plant. A typical gas turbine has a heat rate of 7-10 mmBtu/MWh.

**Dark spread:** Same concept but for coal-fired power plants.
**Clean spark/dark spread:** Subtracts the cost of carbon emissions allowances.

#### Other Notable Inter-Commodity Spreads

- **Gold-Silver ratio:** Long gold / Short silver (or vice versa). The ratio typically ranges 60:1 to 90:1.
- **NOB spread (Notes Over Bonds):** Long 10-year notes (ZN) / Short 30-year bonds (ZB). Trades the yield curve slope.
- **TED spread:** (Historical) Eurodollar minus T-bill. Replaced by SOFR-based equivalents.
- **Fly spreads:** Three-leg calendar spreads (e.g., buy M1, sell 2x M2, buy M3) that trade the curvature of the forward curve.
- **Frac spread:** Natural gas vs NGLs (natural gas liquids). Ethane-gas spread, propane-gas spread.
- **Cattle crush:** Feeder cattle + corn = live cattle cost basis.

### Spread Margin Credits

Exchanges recognize that spread positions have lower risk than outrights:

| Spread Type | Typical Margin Reduction |
|---|---|
| Calendar spread (same commodity) | 70-90% reduction vs sum of outrights |
| Inter-commodity (recognized pair) | 50-80% reduction |
| Butterfly (3-leg calendar) | 80-95% reduction |

CME SPAN automatically identifies and credits spread positions. Traders should verify that their clearing firm passes through exchange-level spread credits rather than charging full outright margin on each leg.
