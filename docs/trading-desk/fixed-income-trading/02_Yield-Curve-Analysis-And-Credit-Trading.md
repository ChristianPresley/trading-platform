## Yield Curve Analysis and Trading

### Curve Construction

The yield curve represents the term structure of interest rates. Construction involves:

**Input instruments:**
- **Short end (overnight to 2 years)**: overnight rates (SOFR, EONIA/ESTR), money market rates, FRAs (Forward Rate Agreements), Eurodollar/SOFR futures, short-term swaps.
- **Belly (2 to 10 years)**: interest rate swap rates, government bond yields, futures.
- **Long end (10 to 30+ years)**: long-dated swap rates, long-dated government bonds.

**Bootstrapping:**
- Sequential process to extract zero-coupon (spot) rates from observed par rates.
- Start with the shortest maturity instrument and work outward.
- Each successive instrument is priced using previously derived discount factors, solving for the new unknown rate.

**Interpolation methods:**
- **Linear**: simple but produces discontinuities in forward rates.
- **Cubic spline**: smooth curve through observed points. Natural cubic spline, not-a-knot, or clamped boundary conditions.
- **Monotone convex**: ensures forward rates remain positive and well-behaved.
- **Nelson-Siegel / Svensson**: parametric models that fit the curve using a small number of parameters (level, slope, curvature, and optionally a second hump term). Used by many central banks.
- **Piecewise constant forwards**: simple model assuming constant forward rates between node points.

**Multi-curve framework (post-2008):**
- The financial crisis revealed that LIBOR-based curves and OIS curves diverge significantly.
- Modern curve construction uses OIS discounting (SOFR/ESTR) for all collateralized derivatives, with separate projection curves for each tenor (1M, 3M, 6M SOFR/EURIBOR).
- Cross-currency basis swaps are used to construct curves in one currency collateralized in another.

### Curve Trading Strategies

**Flattener/Steepener:**
- **Bull flattener**: long end rallies more than short end (long rates fall faster). Occurs when the market prices in rate cuts or recession.
- **Bear flattener**: short end sells off more than long end (short rates rise faster). Occurs when the central bank is tightening.
- **Bull steepener**: short end rallies more than long end. Occurs when the central bank is cutting rates.
- **Bear steepener**: long end sells off more than short end. Occurs when inflation expectations rise or term premium increases.
- Implementation: duration-neutral combinations of two bonds/swaps at different maturities (e.g., long 2-year, short 10-year for a flattener).

**Butterfly/Barbell:**
- **Butterfly**: a three-legged trade combining body (one maturity) and wings (two other maturities). For example: short the 5-year, long the 2-year and 10-year.
- **Positive butterfly** (long wings, short body): profits if the belly cheapens relative to the wings (curve becomes more humped).
- **Negative butterfly** (short wings, long body): profits if the belly richens relative to the wings.
- Weighting: typically duration-neutral and cash-neutral (DV01-weighted). Use regression weights or principal-component-based weights for more sophisticated hedging.

**Curve spread trades:**
- **2s10s**: the spread between 2-year and 10-year yields. The most watched curve spread.
- **5s30s**: spread between 5-year and 30-year yields.
- **2s5s10s butterfly**: measures curvature at the 5-year point.
- **Implementation via futures**: use Treasury futures (2yr TU, 5yr FV, 10yr TY, Bond US, Ultra UB) to express curve views. Futures DV01 per contract must be used for proper weighting.

**Roll-down / Carry:**
- A bond "rolls down" the yield curve as time passes (assuming the curve is upward-sloping). A 10-year bond becomes a 9.5-year bond in 6 months, potentially at a lower yield.
- **Carry**: coupon income minus financing cost. Carry = (coupon rate - repo rate) * time.
- **Roll-down return**: additional return from price appreciation due to moving to a lower-yield point on the curve.
- **Carry and roll-down analysis** is fundamental to identifying rich/cheap points on the curve.

---

## Credit Trading

### Investment Grade (IG)

- Bonds rated BBB-/Baa3 or above.
- US IG corporate bond market: ~$7 trillion outstanding.
- Key indices: Bloomberg US Investment Grade Corporate Index, ICE BofA US Corporate Index, iBoxx USD Liquid Investment Grade Index.
- **Spread measures**: OAS (option-adjusted spread) over the Treasury curve or swap curve. IG spreads typically range from 50-200 bps, widening significantly in stress periods.
- **New issue market**: IG issuance is heavy ($1+ trillion/year in the US). New issue concession (premium yield over secondary market) attracts investor participation.
- **Sector trading**: financials (banks, insurance), industrials (energy, utilities, consumer, technology), and structured finance each have distinct spread dynamics.

### High Yield (HY)

- Bonds rated below BBB-/Baa3.
- US HY market: ~$1.5 trillion outstanding.
- Key indices: Bloomberg US Corporate High Yield Index, ICE BofA US High Yield Index.
- **Spread and yield**: HY bonds are often quoted on a price basis rather than spread basis (especially distressed names). Spreads range from 200 bps to 1000+ bps.
- **Credit tiers**: BB (highest quality HY), B (middle), CCC and below (most speculative, approaching distressed).
- **Covenant analysis**: HY bonds have protective covenants (limitations on debt, restricted payments, change of control). Covenant quality has deteriorated over market cycles ("covenant-lite" trends).
- **Call features**: most HY bonds are callable after a non-call period (e.g., NC3 = non-call for 3 years). Call prices step down to par over time.
- **Recovery analysis**: expected recovery rate in default. Senior secured: 60-80%, senior unsecured: 40-50%, subordinated: 20-30% (historical averages, with wide variance).

### Distressed Debt

- Bonds trading below 60-70 cents on the dollar, or with spreads above 1000 bps. Often involves companies in or approaching bankruptcy.
- **Fulcrum security**: the security in the capital structure where the enterprise value "breaks" (i.e., the security that will be partially impaired in a restructuring). Owning the fulcrum security provides leverage in restructuring negotiations.
- **Claims trading**: buying and selling bankruptcy claims at a discount.
- **Chapter 11 process (US)**: debtor-in-possession (DIP) financing, plan of reorganization, creditor committees, equitization (converting debt to equity in the reorganized entity).
- **Loan-to-own strategies**: distressed investors provide DIP financing or buy fulcrum debt with the goal of converting to equity ownership.
- **Event-driven trading**: restructuring announcements, covenant breaches, rating downgrades, tender offers all create trading opportunities.

### Credit Default Swaps (CDS)

A CDS is a bilateral contract where the protection buyer pays a periodic premium (spread) to the protection seller in exchange for a payment if a credit event occurs.

**Mechanics:**
- **Reference entity**: the issuer whose credit is being referenced.
- **Notional amount**: the face amount of protection.
- **Premium (spread)**: quoted in basis points per annum, paid quarterly (typically on IMM dates: March 20, June 20, September 20, December 20).
- **Credit events**: bankruptcy, failure to pay, restructuring (modified restructuring for North American IG, old restructuring for European, no restructuring for North American HY).
- **Settlement**: physical (deliver bonds, receive par) or cash (ISDA auction determines recovery price; seller pays par minus recovery).
- **Standard coupons**: since the Big Bang protocol (2009), CDS trade with standard coupons (100 bps for IG, 500 bps for HY) with upfront payment to equalize. The upfront amount represents the present value of the difference between the running spread and the standard coupon.

**Quoting:**
- IG CDS: quoted in spread (bps per annum).
- HY CDS: often quoted in price (points upfront + running coupon).
- Conversion between spread and upfront price uses the ISDA standard model (flat hazard rate assumption).

### CDS Indices (CDX / iTraxx)

**CDX (North America):**
- **CDX.NA.IG**: 125-name investment grade index. Most liquid credit derivative instrument globally. Rolls every 6 months (Series 1 started in 2003; new series in March and September).
- **CDX.NA.HY**: 100-name high yield index.
- **CDX.NA.IG tranches**: 0-3% (equity), 3-7% (mezzanine), 7-15% (senior), 15-100% (super senior). Tranche trading allows expression of correlation and specific loss views.

**iTraxx (Europe):**
- **iTraxx Europe Main**: 125-name European IG index.
- **iTraxx Crossover (Xover)**: ~75 high yield / crossover names. Very liquid, widely used for macro hedging.
- **iTraxx Senior Financials and Sub Financials**: bank credit indices.

**Index mechanics:**
- Indices roll to a new series every 6 months. The composition is updated (names that have been upgraded, downgraded, or defaulted are replaced).
- On-the-run vs off-the-run indices: the most recent series is most liquid.
- Basis: CDS index spread vs the theoretical spread from individual CDS (the "intrinsic"). Positive basis = index trades wide of intrinsics.
- **Index-to-single-name basis trades**: buy protection on the index, sell protection on individual names (or vice versa) to capture the basis.
