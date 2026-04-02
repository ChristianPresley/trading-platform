## Fixed Income Analytics

### Duration

**Macaulay Duration:**
- Weighted average time to receive the bond's cash flows, where the weights are the present values of the cash flows.
- Expressed in years. Higher coupon bonds have shorter duration than lower coupon bonds at the same maturity.

**Modified Duration:**
- Measures the percentage price change for a 1% (100 bps) change in yield.
- Modified Duration = Macaulay Duration / (1 + yield/n), where n is the number of compounding periods per year.
- Example: a bond with modified duration of 5.0 will decrease in price by approximately 5% for a 100 bps increase in yield.

**Effective Duration (Option-Adjusted Duration):**
- Measures price sensitivity to a parallel shift in the benchmark yield curve, accounting for embedded options (calls, puts, prepayment options).
- Calculated numerically: (P_down - P_up) / (2 * P_0 * delta_y), where P_down and P_up are prices under shifted curves.
- Essential for callable bonds and MBS, where modified duration is misleading.

**DV01 (Dollar Value of a Basis Point) / PV01:**
- Dollar change in price for a 1 bp change in yield.
- DV01 = Modified Duration * Price * 0.0001.
- The standard unit for hedging: to hedge a $10M position with DV01 of $800, find a hedge instrument whose DV01 offsets.

**Key Rate Duration (KRD):**
- Measures sensitivity to changes in specific points on the yield curve (e.g., 2-year, 5-year, 10-year, 30-year key rates).
- Essential for managing curve risk in a portfolio. A portfolio may be duration-neutral but have significant exposure to curve reshaping.
- Sum of all key rate durations equals the effective duration.

### Convexity

- Measures the curvature of the price-yield relationship (the second derivative).
- **Positive convexity**: most option-free bonds. The price increases more for a rate decrease than it decreases for an equal rate increase. This is beneficial for the holder.
- **Negative convexity**: callable bonds and MBS. When rates fall, the bond's upside is limited by the call or prepayment option. The price-yield curve flattens or bends downward on the left side.
- **Convexity adjustment**: for large yield changes, duration alone underestimates price changes. The convexity adjustment = 0.5 * Convexity * (delta_y)^2.
- **Dollar convexity**: convexity expressed in dollar terms.

### Spread Measures

**Nominal Spread (G-spread):**
- Yield spread over the interpolated government bond yield curve.
- Simple to calculate but ignores the term structure of rates (uses a single point on the curve).

**Z-spread (Zero-Volatility Spread):**
- The constant spread added to each point on the spot rate (zero-coupon) curve that makes the present value of the bond's cash flows equal to its market price.
- Better than nominal spread because it uses the entire curve, not a single benchmark.
- Appropriate for option-free bonds.

**I-spread (Interpolated Spread):**
- Spread over the swap curve (SOFR or EURIBOR swap rates).
- Used when the swap curve is the relevant benchmark (common in European markets and for financial institution bonds).
- Typically quoted as the bond yield minus the linearly interpolated swap rate at the bond's maturity.

**OAS (Option-Adjusted Spread):**
- The spread added to the risk-free rate in an interest rate model that equates the model price to the market price, after accounting for embedded options.
- Uses a term structure model (e.g., Black-Karasinski, Hull-White, BDT) to generate interest rate paths. Along each path, cash flows are adjusted for option exercise (calls, prepayments). The OAS is the spread that makes the average present value across all paths equal to the market price.
- The gold standard for comparing bonds with different embedded options.
- **OAS vs Z-spread**: for option-free bonds, OAS equals Z-spread. For callable bonds, OAS is less than Z-spread (the difference is the option cost). For putable bonds, OAS is greater than Z-spread.

**ASW (Asset Swap Spread):**
- The spread earned by an investor who buys a bond and swaps the fixed coupons to floating. Reflects the bond's credit spread relative to the swap curve.
- Par ASW vs market ASW: par ASW assumes the bond is purchased at par (adjustment for premium/discount); market ASW uses the actual market price.
- Commonly used in the European market for relative value analysis.

**CDS-Bond Basis:**
- CDS spread minus bond spread (usually Z-spread or ASW).
- **Positive basis**: CDS is wider than the bond spread. Can arise from cheapest-to-deliver optionality in CDS, funding costs, or counterparty risk.
- **Negative basis**: bond spread is wider than CDS. Can arise from cash bond illiquidity, forced selling, or funding dislocations.
- Negative basis trades (buy the bond, buy CDS protection) were popular pre-2008 and blew up when funding costs spiked.

### Relative Value Metrics

**Rich/cheap analysis:**
- Compare a bond's OAS or Z-spread to a fitted curve (spline or model) of similar bonds.
- Residual (actual spread minus fitted spread) indicates richness (negative residual) or cheapness (positive residual).
- Must control for differences in liquidity, issue size, coupon, and embedded options.

**Carry and roll-down:**
- As described in the yield curve section, but applied specifically to each bond.
- Total expected return = carry + roll-down + spread change * duration + convexity adjustment.
