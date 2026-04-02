## Volatility Surfaces and Smile

### Implied Volatility Surface Construction

The implied volatility surface is a three-dimensional object: IV as a function of strike (or moneyness) and expiration time.

**Construction steps:**

1. **Gather market prices** — Collect bid/ask for all listed options on the underlying.
2. **Filter** — Remove options with zero volume/OI, wide bid-ask spreads, obvious stale quotes. Use midpoint or weighted mid as the reference price.
3. **Invert BSM** — For each option, numerically invert the Black-Scholes formula to find the implied volatility. Newton-Raphson or Brent's method are standard.
4. **Smooth** — Raw IVs are noisy. Apply parametric fitting (SVI, SABR) or non-parametric smoothing (cubic splines, kernel regression).
5. **Interpolate** — Fill in the grid between observed strikes and expirations.
6. **Extrapolate** — Extend the surface to strikes and expirations beyond observed data. Wing extrapolation is critical and must be arbitrage-free.

### Moneyness Conventions

Different markets use different moneyness axes:

- **Strike** — raw strike price (simplest but not comparable across underlyings).
- **Log-moneyness** — ln(K/F) where F is the forward price.
- **Delta** — strikes expressed as delta values (e.g., 10-delta put, 25-delta put, ATM, 25-delta call, 10-delta call). Standard for FX options.
- **Standardized moneyness** — ln(K/F) / (sigma * sqrt(T)). Normalizes for time to expiration.

### Volatility Skew

The observation that implied volatility varies across strikes for a given expiration.

**Equity index skew:** OTM puts have higher IV than OTM calls. This creates a downward-sloping curve from low strikes to high strikes. The skew is driven by:

- Demand for protective puts (portfolio insurance)
- Supply-demand imbalance (more put buyers than put sellers)
- Empirical observation that markets crash more often than they melt up (negative skewness in returns)
- Leverage effect: lower stock prices increase leverage, increasing realized volatility

**Equity single-stock skew:** Similar to index skew but less pronounced. Individual stocks can exhibit positive skew (more expensive upside calls) around events like takeover speculation or earnings.

**Commodity skew:** Varies by commodity. Energy typically shows positive skew (upside calls expensive due to supply disruption risk). Agricultural commodities can show either direction depending on the season and supply outlook.

**FX skew:** Expressed as the 25-delta risk reversal. Depends on the currency pair and market regime.

### Term Structure

How ATM implied volatility varies across expirations.

- **Normal (contango):** Longer-dated options have higher IV. This is the typical state — more uncertainty over longer horizons.
- **Inverted (backwardation):** Shorter-dated options have higher IV. Occurs during market stress when near-term uncertainty spikes (e.g., around earnings, FOMC meetings, or during a selloff).
- **Humped:** IV peaks at a specific expiration (e.g., around an earnings date or Fed meeting) and is lower on both sides.

### SVI (Stochastic Volatility Inspired) Parameterization

Developed by Jim Gatheral. Provides a parametric fit to the volatility smile for each expiration.

```
w(k) = a + b * (rho * (k - m) + sqrt((k - m)^2 + sigma^2))
```

Where w = total implied variance (IV^2 * T), k = log-moneyness, and (a, b, rho, m, sigma) are fitted parameters.

**SSVI (Surface SVI):** Extends SVI to parameterize the entire surface with fewer parameters, guaranteeing calendar spread arbitrage-free conditions.

### Vol Surface Interpolation

Methods for interpolating between observed points:

- **Linear interpolation in variance** — Interpolate total variance (sigma^2 * T) linearly in time. This ensures no calendar spread arbitrage.
- **Cubic spline in variance** — Smoother than linear, with care taken to avoid negative forward variance.
- **SABR interpolation** — Fit SABR parameters at each expiration, then interpolate parameters between expirations.
- **SVI interpolation** — Fit SVI at each expiration, interpolate in the SVI parameter space.

### Arbitrage Constraints

A valid volatility surface must satisfy:

1. **No negative butterfly spread arbitrage** — The density function (second derivative of call price with respect to strike) must be non-negative. Equivalently, d^2C/dK^2 >= 0.
2. **No calendar spread arbitrage** — Total variance must be non-decreasing in time for any fixed strike. Equivalently, forward variance must be non-negative.
3. **Lee's moment formula** — Implied volatility cannot grow faster than sqrt(2/T * |k|) in the wings.

Professional systems enforce these constraints during surface construction. Violations indicate arbitrage opportunities (or more commonly, stale quotes or fitting errors).

---

## Options Exercise and Assignment

### Exercise Styles

#### American Options

Can be exercised at any time before expiration. All U.S. equity options (single stocks, ETFs) are American-style.

**Early exercise considerations:**

- **Calls:** Early exercise is optimal only when the time value is less than the dividend about to be paid. Specifically, exercise the day before ex-dividend if: dividend > C(S, K, T_remaining) - (S - K) where T_remaining is the time from ex-date to expiration. Deep ITM calls near ex-dividend dates are most susceptible.
- **Puts:** Early exercise can be optimal when the option is deep ITM and the interest earned on the strike price exceeds the remaining time value. More common in high interest rate environments.

#### European Options

Can only be exercised at expiration. U.S. examples: SPX options, XSP options, VIX options, most index options. All OTC vanilla options on currencies and rates are typically European.

**Advantages for market makers:** No early assignment risk simplifies hedging. European options have exact BSM pricing (no need for binomial trees).

#### Bermudan Options

Can be exercised on specific dates (e.g., quarterly, or on coupon dates for interest rate products). Common in:

- Interest rate derivatives (swaptions with multiple exercise dates)
- Convertible bonds (callable on specific dates)
- Employee stock options (exercise after vesting dates)

Priced with binomial/trinomial trees or Longstaff-Schwartz Monte Carlo.

### Auto-Exercise

The OCC (Options Clearing Corporation) automatically exercises options that are $0.01 or more in-the-money at expiration. This is the **Exercise by Exception** rule.

- Holders can submit a **Do Not Exercise (DNE)** notice if they do not want automatic exercise.
- Holders can also submit an exercise notice for options that are OTM (unusual, but allowed — for example, if there is after-hours news).
- The cutoff for contrary exercise instructions is typically 5:30 PM ET on expiration day.

### Exercise Notices

When an American option holder exercises:

1. The holder's broker submits an exercise notice to the OCC.
2. The OCC randomly assigns the exercise to a clearing member with a short position.
3. The clearing member assigns to one of its customer accounts (random or first-in-first-out, depending on the firm).
4. The assigned party must deliver (for calls, deliver shares at the strike price) or take delivery (for puts, buy shares at the strike price).

Settlement is T+1 for equity options (as of May 2024, aligned with equity settlement).

### Pin Risk

The risk that the underlying closes exactly at or very near the strike price on expiration day. This creates uncertainty about whether the option will be exercised.

- A short ATM call might or might not be assigned. If assigned, the seller is suddenly short shares over the weekend. If not assigned, they have no position.
- Professional desks actively manage pin risk by closing positions in the final hours of expiration day.
- Pin risk is exacerbated by high open interest at a single strike, which can create a "magnetic" effect as delta-hedging activity pins the underlying to that strike.
