# Options Trading — Professional Trading Desk Reference

## Table of Contents

1. [Options Order Types and Strategies](#options-order-types-and-strategies)
2. [Options Chain Display](#options-chain-display)
3. [Options Pricing Models](#options-pricing-models)
4. [Greeks Calculation and Display](#greeks-calculation-and-display)
5. [Volatility Surfaces and Smile](#volatility-surfaces-and-smile)
6. [Options Exercise and Assignment](#options-exercise-and-assignment)
7. [Options Market Making](#options-market-making)
8. [Listed Options vs OTC Options](#listed-options-vs-otc-options)
9. [Exotic Options](#exotic-options)
10. [Options Strategy Builders](#options-strategy-builders)
11. [Portfolio Margining for Options](#portfolio-margining-for-options)

---

## Options Order Types and Strategies

### Single-Leg Orders

The most basic options trade involves a single contract — one call or one put. Order types applicable to single-leg options include:

- **Market** — filled at the best available price; dangerous in illiquid options where the bid-ask spread can be several dollars wide.
- **Limit** — specify maximum buy price or minimum sell price. The standard for options trading.
- **Stop** — triggers a market order when the option's last trade or mark hits the stop price.
- **Stop-Limit** — triggers a limit order at the stop price; avoids adverse fills but risks non-execution.
- **Trailing Stop** — adjusts dynamically by a fixed amount or percentage from the option's high/low.
- **Market-on-Close (MOC)** — executed during the closing rotation; used for expiration-day management.
- **Fill-or-Kill (FOK)** — entire order must fill immediately or is cancelled; used in large block trades.
- **Immediate-or-Cancel (IOC)** — fills as much as possible immediately, cancels the rest.
- **Good-Til-Cancelled (GTC)** — persists across sessions until filled or explicitly cancelled.
- **All-or-None (AON)** — must fill the entire quantity, but does not require immediate execution.

### Multi-Leg Strategies

Professional desks route multi-leg orders as a single package (complex order) to exchanges that support complex order books (COB). This avoids leg risk — the danger that one leg fills and the other does not.

#### Vertical Spreads

Vertical spreads use the same expiration, different strikes.

| Strategy | Construction | Max Profit | Max Loss | Outlook |
|---|---|---|---|---|
| **Bull Call Spread** | Buy lower-strike call, sell higher-strike call | Width minus debit | Net debit | Moderately bullish |
| **Bear Put Spread** | Buy higher-strike put, sell lower-strike put | Width minus debit | Net debit | Moderately bearish |
| **Bull Put Spread** | Sell higher-strike put, buy lower-strike put | Net credit | Width minus credit | Neutral to bullish |
| **Bear Call Spread** | Sell lower-strike call, buy higher-strike call | Net credit | Width minus credit | Neutral to bearish |

Width = difference between strikes. For example, a 100/105 bull call spread on SPY with a $2.00 debit has max profit of $3.00 and max loss of $2.00.

#### Horizontal (Calendar) Spreads

Same strike, different expirations. The trader buys the longer-dated option and sells the shorter-dated option.

- **Long Calendar Call Spread** — Buy far-month call, sell near-month call at same strike. Profits from time decay differential and volatility expansion in the back month.
- **Long Calendar Put Spread** — Same structure with puts.
- **Double Calendar** — Calendar spreads at two different strikes, bracketing the current price.

Key risk: if the underlying moves sharply away from the strike, both options lose value. Vega exposure is net long (back month has higher vega). Theta exposure is net positive near the short expiration.

#### Diagonal Spreads

Different strikes AND different expirations. Combines vertical and calendar characteristics.

- **Poor Man's Covered Call** — Buy a deep ITM LEAPS call (delta ~0.80), sell a short-term OTM call. Mimics covered call with less capital.
- **Diagonal Put Spread** — Buy a longer-dated put, sell a shorter-dated put at a different strike.

Diagonals require careful management because the short option expires first, and the remaining long position may need to be rolled or closed.

#### Straddles

Buy (or sell) both a call and a put at the same strike and expiration.

- **Long Straddle** — Pays when the underlying moves sharply in either direction. Breakevens are strike +/- total premium paid. Expensive because you buy two at-the-money options.
- **Short Straddle** — Collects premium; profits if the underlying stays near the strike. Theoretically unlimited risk on the call side, risk to zero on the put side.

Typical use: earnings plays (long), income generation on indices (short).

#### Strangles

Buy (or sell) an OTM call and an OTM put at different strikes, same expiration.

- **Long Strangle** — Cheaper than a straddle but requires a larger move to profit. Wider breakeven range.
- **Short Strangle** — Wider profit zone than a short straddle, but still significant risk.

Professional desks frequently sell index strangles (e.g., SPX 1-standard-deviation strangle) and delta-hedge dynamically.

#### Butterflies

Three strikes, same expiration. The position is constructed with a 1:2:1 ratio.

- **Long Call Butterfly** — Buy 1 lower call, sell 2 middle calls, buy 1 upper call. Max profit at middle strike. Very low cost. Used for pinning plays near expiration.
- **Long Put Butterfly** — Buy 1 upper put, sell 2 middle puts, buy 1 lower put.
- **Broken Wing Butterfly** — Uneven strike spacing (e.g., 95/100/110). Introduces directional bias and may result in a credit instead of a debit.
- **Iron Butterfly** — Sell ATM call and put (straddle), buy OTM call and put (strangle) as wings. Equivalent payoff to a long butterfly but constructed with all four options. Always entered for a credit.

#### Condors

Four strikes, same expiration.

- **Long Call Condor** — Buy lowest call, sell second call, sell third call, buy highest call. Profits in a range between the two middle strikes.
- **Long Put Condor** — Same structure with puts.

#### Iron Condors

The most popular income strategy among professional and retail traders.

- **Iron Condor** — Sell an OTM put spread and an OTM call spread simultaneously. Collect premium from both sides. Max profit = net credit. Max loss = width of wider spread minus credit.
- Typical setup: sell 1-SD strangle, buy 1.5-SD wings. Example on SPX: sell 4200 put / buy 4150 put / sell 4400 call / buy 4450 call for $5.00 credit.
- Management rules: close at 50% of max profit, adjust tested side at 25-delta, roll untested side for additional credit.

#### Ratio Spreads

Unequal numbers of long and short options.

- **Call Ratio Spread** — Buy 1 ATM call, sell 2 OTM calls. Creates a free or credit trade with unlimited upside risk. Also called a "1x2."
- **Put Ratio Spread** — Buy 1 ATM put, sell 2 OTM puts. Risk to the downside if the underlying drops sharply past the lower breakeven.
- **Ratio Backspread** — Reverse of the above (buy more than you sell). Long volatility play with defined risk on one side, unlimited profit on the other.

Ratio spreads are characterized by a point of maximum profit at the short strike, with risk accelerating beyond the breakeven.

#### Collar

- **Standard Collar** — Own the underlying, buy a protective put, sell a covered call. Often zero-cost or near-zero-cost. Limits both upside and downside.
- **Costless Collar** — The call premium exactly offsets the put premium. Common in corporate hedging (executives hedging concentrated stock positions, often under Rule 10b5-1 plans).
- **Variable Collar** — Different quantities of calls and puts, or different expiration dates.

---

## Options Chain Display

### Strike Ladder

The standard options chain display is a table organized by strike price with calls on the left and puts on the right (or vice versa). Professional platforms display:

| Column | Description |
|---|---|
| **Bid** | Best available bid price |
| **Ask** | Best available ask price |
| **Last** | Last trade price |
| **Volume** | Number of contracts traded today |
| **Open Interest** | Total outstanding contracts |
| **Implied Volatility** | Market-implied volatility for that specific strike |
| **Delta** | Rate of change of option price with respect to underlying |
| **Gamma** | Rate of change of delta |
| **Theta** | Daily time decay in dollars |
| **Vega** | Sensitivity to 1% change in implied volatility |

### Color Coding

- **In-the-money (ITM)** strikes are shaded (typically light blue or yellow) to distinguish from OTM.
- The **ATM** (at-the-money) strike is highlighted or bordered.
- Strikes with high open interest or unusual volume are flagged.
- Bid-ask spreads wider than a threshold (e.g., >10% of mid) are highlighted in red.

### Expiration Grid

A matrix view with expirations across the top and strikes down the side. Each cell shows the option price (or Greeks). This is particularly useful for:

- Identifying relative value across expirations (term structure)
- Spotting calendar spread opportunities
- Visualizing the volatility surface

Professional systems (Bloomberg OMON, Refinitiv Eikon, CQG) allow pivoting the grid between price, IV, delta, or any Greek.

### Greeks Display Modes

- **Per-contract** — Greeks for one contract (e.g., delta = 0.45).
- **Position-level** — Greeks multiplied by position size and contract multiplier (e.g., 100 shares per equity option). A position of 10 contracts with delta 0.45 shows position delta = 450.
- **Dollar Greeks** — Greeks expressed in dollar terms. Dollar delta = delta x underlying price x multiplier x quantity. Dollar gamma = gamma x underlying price^2 x multiplier / 100.
- **Percentage Greeks** — Useful for comparing options on different underlyings.

### Implied Volatility Display

- **Per-strike IV** — Shown in the chain for each individual option.
- **ATM IV** — The implied volatility at the at-the-money strike, often interpolated between the two nearest strikes.
- **IV Rank** — Current IV relative to its 52-week range: (Current IV - 52w Low) / (52w High - 52w Low). An IV rank of 80% means current IV is near the top of its annual range.
- **IV Percentile** — The percentage of days in the past year where IV was below the current level. More robust than IV rank because it accounts for the distribution of historical IV.
- **Skew indicator** — 25-delta put IV minus 25-delta call IV (risk reversal). Positive skew (the norm for equity indices) means OTM puts are more expensive than OTM calls.

---

## Options Pricing Models

### Black-Scholes-Merton (BSM)

The foundational model. Assumes:

- Log-normal distribution of returns
- Constant volatility
- No dividends (Black-Scholes) or continuous dividend yield (Merton adjustment)
- No transaction costs or taxes
- European exercise only
- Continuous trading

**Formula (call):**

```
C = S * N(d1) - K * e^(-rT) * N(d2)

d1 = [ln(S/K) + (r - q + sigma^2/2) * T] / (sigma * sqrt(T))
d2 = d1 - sigma * sqrt(T)
```

Where S = spot price, K = strike, r = risk-free rate, q = dividend yield, T = time to expiration (years), sigma = volatility, N() = standard normal CDF.

**Limitations:**
- Assumes constant volatility (violated by the existence of the volatility smile/skew)
- Cannot price American options (no early exercise)
- Assumes continuous trading (gaps at open are not modeled)
- Fat tails in real returns are not captured by the log-normal assumption

**Implementation note:** Most professional systems use BSM only for European options on indices (e.g., SPX, which is European-style). For American options, BSM serves as a starting approximation.

### Binomial Model (Cox-Ross-Rubinstein)

Discrete-time model that constructs a tree of possible underlying prices.

- At each time step, the price moves up by factor u = e^(sigma * sqrt(dt)) or down by d = 1/u.
- Risk-neutral probability: p = (e^((r-q)*dt) - d) / (u - d).
- Option value at each node is the maximum of intrinsic value (for American) and the discounted expected value from the next step.
- Convergence to BSM as the number of steps increases.

**Advantages:**
- Handles American exercise (check for early exercise at each node)
- Handles discrete dividends (adjust the tree at ex-dividend dates)
- Intuitive and easy to implement

**Professional usage:** Typically 200-500 steps for equity options. For dividends, the Escrowed Dividend Model or interpolated dividend tree is used.

### Trinomial Model

Extension of binomial with three branches at each node (up, middle, down).

- Up: u = e^(sigma * sqrt(2*dt))
- Down: d = 1/u
- Middle: m = 1

Converges faster than binomial with fewer steps. Particularly useful for barrier options where the tree can be adjusted so that the barrier falls exactly on a node layer.

### Monte Carlo Simulation

Simulates thousands of random price paths and averages the discounted payoff.

```
S(t+dt) = S(t) * exp((r - q - sigma^2/2)*dt + sigma*sqrt(dt)*Z)
```

Where Z is a standard normal random variable.

**Advantages:**
- Handles path-dependent payoffs (Asian, lookback, barrier options)
- Scales well to multiple underlyings (basket options, rainbow options)
- Can incorporate complex dynamics (stochastic volatility, jumps)

**Disadvantages:**
- Slow convergence (error decreases as 1/sqrt(N) where N = number of paths)
- Poor for American options (requires Longstaff-Schwartz least-squares regression or other techniques)

**Variance reduction techniques:**
- **Antithetic variates** — For each random draw Z, also simulate with -Z. Cuts variance roughly in half.
- **Control variates** — Use a related option with a known analytical price to adjust the estimate.
- **Importance sampling** — Shift the probability distribution to sample more from the payoff-relevant region.
- **Stratified sampling** — Divide the random space into strata and sample from each.
- **Quasi-random sequences** (Sobol, Halton) — Deterministic low-discrepancy sequences that fill the space more uniformly than pseudo-random numbers.

Professional systems typically run 100,000 to 1,000,000 paths. GPU-accelerated Monte Carlo (CUDA) reduces calculation time from minutes to seconds for exotic portfolios.

### Local Volatility Model (Dupire)

Derives a volatility function sigma(S, t) that is consistent with all observed market prices.

```
sigma_local^2(K, T) = [dC/dT + (r-q)*K*dC/dK + q*C] / [0.5 * K^2 * d^2C/dK^2]
```

Where C = market call price as a function of strike K and expiration T.

**Key properties:**
- Perfectly calibrates to the entire volatility surface at a single point in time
- Produces a unique, deterministic local volatility function
- Forward volatilities are fully determined

**Limitations:**
- Forward smile dynamics are unrealistic (the smile flattens over time, which contradicts market behavior)
- Poor for pricing exotic options that depend on the future smile (e.g., cliquets, forward-starting options)

### Stochastic Volatility — Heston Model

Volatility itself follows a random process:

```
dS = (r - q) * S * dt + sqrt(V) * S * dW_S
dV = kappa * (theta - V) * dt + xi * sqrt(V) * dW_V
Correlation: dW_S * dW_V = rho * dt
```

Parameters:
- **V** — instantaneous variance
- **kappa** — mean reversion speed
- **theta** — long-run variance
- **xi** — volatility of volatility (vol-of-vol)
- **rho** — correlation between asset returns and variance changes (typically negative for equities, producing the skew)

**Advantages:**
- Generates realistic volatility skew and smile
- Closed-form solution for European options (via characteristic function and Fourier inversion)
- More realistic forward smile dynamics than local volatility

**Calibration:** Typically fit to the observed volatility surface by minimizing the sum of squared differences between model prices and market prices. Common calibration techniques: Levenberg-Marquardt optimization, differential evolution, or particle swarm.

### SABR Model (Stochastic Alpha Beta Rho)

Widely used for interest rate options (swaptions, caps/floors) and increasingly for equity/FX options.

```
dF = alpha * F^beta * dW_F
d(alpha) = nu * alpha * dW_alpha
Correlation: dW_F * dW_alpha = rho * dt
```

Parameters:
- **alpha** — initial volatility level
- **beta** — controls the backbone (beta=1 is lognormal, beta=0 is normal)
- **nu** — volatility of volatility
- **rho** — correlation between forward and vol moves

**Hagan's approximation** provides a closed-form implied volatility formula, making SABR extremely fast to evaluate. This is why it dominates in interest rate derivatives where speed matters for large portfolios.

**Limitations:**
- Hagan's formula can produce negative densities for deep OTM options in low-rate environments.
- The "shifted SABR" (F + shift) or "free boundary SABR" addresses negative rates.

---

## Greeks Calculation and Display

### First-Order Greeks

#### Delta (Delta)

The rate of change of the option price with respect to a $1 move in the underlying.

- **Call delta** ranges from 0 to +1. Deep ITM calls approach +1; deep OTM calls approach 0.
- **Put delta** ranges from -1 to 0. Deep ITM puts approach -1; deep OTM puts approach 0.
- **ATM options** have delta near +0.50 (calls) or -0.50 (puts), adjusted slightly by the forward price and interest rates.
- **Position delta** = option delta x quantity x multiplier. 10 long SPY calls with 0.40 delta = position delta of +400 (equivalent to being long 400 shares).

**Uses:**
- Hedging: Buy/sell delta-equivalent shares to neutralize directional risk.
- Probability proxy: Delta roughly approximates the probability of finishing ITM (not exact due to risk-neutral vs real-world measure, but a useful heuristic).
- Strike selection: Traders reference strikes by delta (e.g., "the 25-delta put").

#### Gamma (Gamma)

The rate of change of delta with respect to a $1 move in the underlying.

- Gamma is highest for ATM options near expiration.
- Long options have positive gamma (benefit from large moves).
- Short options have negative gamma (penalized by large moves).
- **Dollar gamma** = 0.5 x gamma x S^2 x multiplier / 100 — the P&L from a 1% move in the underlying.

Gamma increases dramatically near expiration for ATM options. This creates "gamma risk" for market makers who are short near-expiry ATM options. A $1 move in the underlying can shift delta from 0.50 to 0.80, requiring a large hedge adjustment.

#### Theta (Theta)

The rate of change of the option price with respect to the passage of one day.

- Long options have negative theta (they lose value each day, all else equal).
- Short options have positive theta.
- ATM options have the highest absolute theta.
- Theta accelerates as expiration approaches — particularly in the final 30 days.
- **Weekend theta**: Options decay 7 calendar days per 5 trading days. Some platforms show calendar theta vs trading-day theta.

Professional platforms display theta in dollar terms: position theta x quantity x multiplier. A position theta of -$500 means the portfolio loses $500 per day from time decay.

#### Vega (Vega)

The rate of change of the option price with respect to a 1 percentage point change in implied volatility.

- Vega is always positive for long options.
- Vega is highest for ATM options and increases with time to expiration.
- Longer-dated options have higher vega than shorter-dated options.
- **Weighted vega**: Some desks weight vega by the square root of time to normalize across expirations: vega_weighted = vega / sqrt(T/T_ref).

**Vega by expiration bucket:** Professional risk systems aggregate vega by expiration (e.g., 0-30 days, 30-60, 60-90, 90-180, 180-365, 1y+) to manage term structure exposure.

#### Rho (Rho)

The rate of change of the option price with respect to a 1 percentage point change in the risk-free interest rate.

- Calls have positive rho; puts have negative rho.
- Rho is more significant for longer-dated options.
- In a low-rate environment, rho is often ignored for short-dated options. In a higher-rate environment (e.g., 5%+ Fed Funds), rho matters even for 3-6 month options.

### Second-Order and Higher-Order Greeks

#### Charm (Delta Decay)

The rate of change of delta with respect to time. Also called delta bleed.

- Tells you how much your delta hedge will drift overnight.
- Critical for managing daily hedging P&L.
- Charm is highest for ATM options and flips sign around the money.

#### Vanna

The sensitivity of delta to changes in implied volatility (equivalently, the sensitivity of vega to changes in the underlying price).

```
Vanna = d(Delta)/d(IV) = d(Vega)/d(S)
```

- Positive vanna for OTM calls, negative for OTM puts (in typical conventions).
- Important for understanding how delta hedges change when volatility moves.
- A vol spike during a selloff causes put deltas to increase in magnitude (become more negative), amplifying hedging flows. This is the vanna-driven gamma squeeze phenomenon.

#### Volga (Vomma)

The sensitivity of vega to changes in implied volatility.

```
Volga = d(Vega)/d(IV) = d^2(Price)/d(IV)^2
```

- Highest for deep OTM and deep ITM options.
- ATM options have near-zero volga.
- Important for vol-of-vol risk. A portfolio with high positive volga benefits from large moves in implied volatility.
- Key to understanding the volatility smile: the market price of volga explains why OTM options trade at higher implied volatilities than ATM options.

#### Speed

The rate of change of gamma with respect to the underlying price.

```
Speed = d(Gamma)/d(S)
```

- Third derivative of the option price with respect to the underlying.
- Important for understanding how gamma changes as the underlying moves, which affects the cost of delta hedging.

#### Color (Gamma Decay)

The rate of change of gamma with respect to time.

```
Color = d(Gamma)/d(t)
```

- Tells you how gamma will change as time passes.
- Relevant for managing the gamma profile near expiration.

### Greeks Display in Professional Systems

Professional risk systems display Greeks at multiple levels:

1. **Option level** — Greeks for each individual position.
2. **Underlying level** — Aggregated Greeks per underlying (e.g., total AAPL delta, gamma, theta, vega).
3. **Sector/portfolio level** — Aggregated across a portfolio or sector.
4. **Scenario Greeks** — Greeks recalculated under stress scenarios (e.g., delta if the market drops 5%, gamma if IV increases by 10 points).

**Greeks ladder/strip:** Shows how Greeks change across a range of underlying prices and/or volatilities. Essentially a slice through the P&L surface.

---

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

---

## Options Market Making

### Delta Hedging

The core activity of options market makers. After selling an option, the market maker buys delta-equivalent shares to neutralize directional risk.

**Process:**
1. Sell a call with delta = 0.45. Buy 45 shares per contract (assuming equity options with 100 multiplier).
2. As the underlying moves, delta changes. Rebalance by buying or selling shares.
3. The frequency of rehedging is a function of: gamma exposure, transaction costs, and risk tolerance.

**Hedging frequency:**
- High gamma positions near expiration: hedge continuously (every few minutes).
- Low gamma positions: hedge daily or when delta drift exceeds a threshold (e.g., re-hedge when position delta changes by more than $X or Y% of notional).

**Discrete hedging error:** In practice, hedging is not continuous. The P&L from a delta-hedged option position over one hedging interval is approximately:

```
P&L = 0.5 * Gamma * (realized_move^2 - implied_move^2)
```

Where implied_move = IV * S * sqrt(dt). This is the gamma P&L.

### Gamma Scalping

A strategy where the market maker is long gamma (long options) and repeatedly rebalances the delta hedge.

- When the underlying rises, delta increases. Sell shares to rebalance (sell high).
- When the underlying falls, delta decreases. Buy shares to rebalance (buy low).
- Each rebalancing cycle locks in a small profit proportional to gamma x move^2.
- The cost of the strategy is theta decay. Profitability depends on realized volatility exceeding implied volatility.

**Break-even realized vol:** The annualized realized volatility at which gamma scalping P&L exactly offsets theta decay. Equals the implied volatility at which the options were purchased.

### Volatility Trading

Market makers and volatility traders are ultimately trading the spread between implied and realized volatility.

- **Long volatility (long gamma):** Buy options, delta-hedge. Profit if realized vol > implied vol.
- **Short volatility (short gamma):** Sell options, delta-hedge. Profit if realized vol < implied vol.
- **Variance swaps:** A pure play on realized vs implied variance, traded OTC. The payoff is (realized_variance - strike_variance) x notional. No path dependency in terms of skew — depends only on the final realized variance.
- **VIX futures and options:** Trade the market's expectation of 30-day forward implied volatility.

### Skew Trading

Exploiting relative mispricings in the volatility surface.

- **Risk reversal:** Sell an OTM put and buy an OTM call (or vice versa) to trade the skew level. A negative risk reversal (selling puts richer than calls) profits if skew decreases.
- **Butterfly:** A long 25-delta butterfly (buy wings, sell body) is a play on the curvature of the smile. Profits if realized kurtosis exceeds implied kurtosis.
- **Calendar skew trade:** Differences in skew between near-dated and far-dated expirations.
- **Dispersion trading:** Sell index options (expensive due to correlation premium) and buy single-stock options. Profits if realized correlation is lower than implied correlation.

---

## Listed Options vs OTC Options

### Exchange-Traded (Listed) Options

#### Major U.S. Options Exchanges

| Exchange | Code | Notes |
|---|---|---|
| **Cboe Options Exchange** | CBOE | Largest options exchange. Home of VIX, SPX options. |
| **Cboe BZX Options** | BATS | Electronic-only. Competitive pricing. |
| **Cboe EDGX Options** | EDGX | Price-time priority. |
| **Cboe C2 Options** | C2 | Pro-rata allocation model. |
| **NYSE Arca Options** | ARCA | Price-time priority with directed orders. |
| **NYSE American Options** | AMEX | Pro-rata allocation for certain classes. |
| **Nasdaq PHLX** | PHLX | Specialist model. Key for FX options. |
| **Nasdaq ISE** | ISE | Electronic pro-rata model. |
| **Nasdaq GEMX** | GEMX | Price-time priority. |
| **Nasdaq MRX** | MRX | Price-time priority. |
| **MIAX Options** | MIAX | Price-time priority. |
| **MIAX Pearl** | PEARL | Electronic-only. |
| **MIAX Emerald** | EMERALD | Pro-rata allocation. |
| **BOX Options** | BOX | Price Improvement Period (PIP) mechanism. |
| **Cboe EDGX Options** | EDGX | Retail priority. |
| **MEMX Options** | MEMX | Newest entrant (2024). |

#### Key Features of Listed Options

- **Standardized contracts:** Fixed multiplier (100 shares for equity options), standard expirations (monthly, weekly, daily for high-volume underlyings).
- **Central clearing:** All trades cleared through the OCC. Counterparty risk is eliminated.
- **Transparency:** Real-time quotes, volume, open interest. OPRA (Options Price Reporting Authority) disseminates data.
- **Penny increments:** Most actively traded options quote in $0.01 increments. Less active names may quote in $0.05 or $0.10.
- **NBBO compliance:** Best bid and offer across all exchanges must be respected. Exchanges cannot trade through a better price on another exchange.

#### SPX Options Specifics

- European-style exercise.
- Cash-settled based on the Special Opening Quotation (SOQ) for AM-settled, or closing price for PM-settled.
- Multiplier: $100.
- SPX weeklys (SPXW) expire Monday, Wednesday, and Friday.
- Section 1256 tax treatment: 60% long-term / 40% short-term capital gains regardless of holding period.

#### VIX Options

- Based on the Cboe Volatility Index.
- European-style, cash-settled.
- Settlement is based on a Special Opening Quotation of the VIX on expiration morning (VIX SOQ), which can differ significantly from the prior close.
- No direct arbitrage relationship to VIX futures — VIX options are priced off VIX futures, not the VIX index itself.

### OTC Options

#### ISDA Documentation

OTC options are governed by ISDA (International Swaps and Derivatives Association) documentation:

- **ISDA Master Agreement** — The overarching legal framework covering all OTC derivatives between two counterparties. Includes default provisions, netting, and termination events.
- **Schedule** — Customizes the Master Agreement (e.g., choice of law, credit support details).
- **Credit Support Annex (CSA)** — Governs collateral/margin requirements. Specifies eligible collateral, haircuts, minimum transfer amounts, and thresholds.
- **Confirmation** — The specific trade terms for each transaction. For options: underlying, strike, premium, expiration, exercise style, settlement type.
- **ISDA Definitions** — Standardized definitions referenced in confirmations. The 2006 ISDA Definitions cover interest rate products; the 2002/2021 Equity Definitions cover equity options.

#### OTC vs Listed Comparison

| Feature | Listed | OTC |
|---|---|---|
| **Standardization** | Fixed strikes, expirations, multipliers | Fully customizable |
| **Counterparty risk** | Eliminated via CCP (OCC) | Bilateral, mitigated by CSA |
| **Transparency** | Public quotes, volume, OI | Private; no public reporting (pre-2024 SFTR/EMIR) |
| **Liquidity** | Quote-driven on exchanges | Relationship-driven; RFQ to dealer banks |
| **Settlement** | T+1, standard | Negotiated (T+2 typical for FX, T+1 for equity) |
| **Regulation** | SEC/CFTC regulated exchanges | Dodd-Frank Title VII; EMIR in EU |
| **Margin** | OCC-determined; standardized | CSA-determined; bilateral or cleared through CCP |
| **Size** | Standardized (100 shares) | Any notional amount |

#### OTC Exotic Options

OTC markets are where exotic options primarily trade. See the [Exotic Options](#exotic-options) section below.

---

## Exotic Options

### Path-Independent Exotics

#### Digital (Binary) Options

Pay a fixed amount if the underlying is above (digital call) or below (digital put) the strike at expiration.

- **Cash-or-nothing:** Pays a fixed cash amount (e.g., $100) if ITM. Zero otherwise.
- **Asset-or-nothing:** Pays the value of the underlying if ITM.
- **One-touch:** Pays if the underlying touches the barrier at any time before expiration (American digital).
- **No-touch:** Pays if the underlying never touches the barrier.

**Hedging challenge:** Digital options have discontinuous payoffs, creating infinite gamma at the strike near expiration. Market makers hedge with tight call/put spreads (overhedge) rather than delta hedging.

#### Compound Options

An option on an option. Four types: call on call, call on put, put on call, put on put.

- **Use case:** Bidding on an acquisition — the bidder has the right but not the obligation to acquire the target, which itself is exposed to the option-like payoff of equity.
- **Installment options:** A series of compound options where the holder pays premium in installments and can stop paying (let the option lapse) at any installment date.

#### Chooser Options

The holder decides at a specified future date whether the option becomes a call or a put.

- **Simple chooser:** Uses put-call parity to value; equivalent to a call plus a put with adjusted terms.
- **Complex chooser:** The call and put have different strikes and expirations.

### Path-Dependent Exotics

#### Asian Options

Payoff depends on the average price of the underlying over a period.

- **Average price (fixed strike):** Payoff = max(Average - K, 0). Common in commodity markets to hedge average exposure over a month or quarter.
- **Average strike (floating strike):** Payoff = max(S_T - Average, 0). Less common.
- **Arithmetic average:** No closed-form solution; priced via Monte Carlo or moment-matching approximation.
- **Geometric average:** Has a closed-form solution (used as a control variate for arithmetic Asian options).

**Use case:** A refiner hedges the average price of crude oil over the next quarter. An Asian option is cheaper than a vanilla option because averaging reduces volatility.

#### Lookback Options

Payoff depends on the maximum or minimum underlying price during the option's life.

- **Fixed strike lookback call:** max(S_max - K, 0). The holder benefits from the highest price reached.
- **Floating strike lookback call:** max(S_T - S_min, 0). The strike is set to the minimum price observed.
- **Partial lookback:** The lookback period is a subset of the option's life.

Expensive due to the path dependency. Priced via Monte Carlo or PDE methods.

#### Barrier Options

Vanilla options that are activated (knocked in) or deactivated (knocked out) when the underlying hits a barrier level.

**Knock-out options:**
- **Down-and-out call:** Standard call that ceases to exist if the underlying falls below the barrier.
- **Up-and-out call:** Call that ceases to exist if the underlying rises above the barrier.
- **Down-and-out put, Up-and-out put:** Analogous put versions.

**Knock-in options:**
- **Down-and-in call:** Only comes into existence if the underlying falls to the barrier.
- **Up-and-in call, Down-and-in put, Up-and-in put:** Analogous.

**Key relationship:** Knock-in + Knock-out = Vanilla (for the same barrier and otherwise identical terms).

**Barrier monitoring:** Continuous (any time during market hours) vs discrete (daily close only). Continuous barriers are cheaper to monitor but more likely to be triggered.

**Rebate:** Some barrier options pay a fixed rebate if knocked out.

**Hedging:** Barrier options have discontinuous delta at the barrier, making hedging difficult. Market makers often use barrier-shifted replication (hedge with a spread of vanillas near the barrier).

#### Quanto Options

Options denominated in a different currency than the underlying.

- Example: A European investor buys a call on the S&P 500 (denominated in USD) with a payoff converted at a fixed exchange rate into EUR (the quanto adjustment).
- Eliminates currency risk for the investor.
- Requires modeling the correlation between the underlying asset returns and the exchange rate.

**Quanto adjustment:** The risk-neutral drift of the underlying is adjusted by -rho * sigma_S * sigma_FX, where rho is the correlation between the asset and the exchange rate.

#### Rainbow Options

Options on multiple underlyings.

- **Best-of:** Payoff based on the maximum of N underlyings. max(S1, S2, ..., SN) - K.
- **Worst-of:** Payoff based on the minimum. More common in structured products. Cheaper than best-of because the worst performer is always less than or equal to any individual.
- **Spread option:** Payoff based on the difference between two underlyings. max(S1 - S2 - K, 0). Kirk's approximation provides a closed-form price.
- **Outperformance option:** Pays if one asset outperforms another.

#### Basket Options

Options on a weighted portfolio of underlyings.

- Payoff: max(weighted_sum(S_i) - K, 0).
- Common in equity-linked structured products.
- No closed-form solution. Priced via Monte Carlo, moment-matching (treating the basket as a single lognormal or shifted lognormal), or copula methods.
- Correlation between basket components is the key pricing driver.

---

## Options Strategy Builders

### Visual Strategy Builder

Professional platforms provide a graphical interface for constructing multi-leg strategies:

1. **Select underlying and expiration.**
2. **Click on the options chain** to add legs (calls/puts, buy/sell).
3. **The system automatically identifies the strategy type** (e.g., "iron condor" if you select four legs matching that pattern).
4. **Adjust quantities** — for ratio spreads, custom combinations.
5. **Set order type** — limit on the net debit/credit.
6. **Route as a complex order** to exchanges.

### Payoff Diagrams

The payoff diagram shows profit/loss at expiration as a function of the underlying price.

**Standard features:**
- **X-axis:** Underlying price at expiration.
- **Y-axis:** P&L in dollars.
- **Solid line:** Payoff at expiration.
- **Dashed line:** Payoff at a selected date before expiration (using the current IV surface).
- **Multiple curves:** Show payoff at various dates (T-30, T-15, T-7, T-1, expiration).
- **Break-even points:** Marked on the x-axis.
- **Max profit and max loss zones** shaded.
- **Current underlying price** indicated with a vertical line.

**Interactive features:**
- Drag to adjust strikes and see the payoff change in real-time.
- Toggle individual legs on/off to see their contribution.
- Adjust implied volatility to see the impact on the pre-expiration curves.
- Overlay the underlying's price distribution (based on implied volatility) on the payoff diagram.

### Break-Even Analysis

For each strategy, the system calculates:

- **Upper break-even** — underlying price at which the strategy transitions from profit to loss on the upside.
- **Lower break-even** — same on the downside.
- **Break-even at different dates** — accounting for remaining time value.
- **Break-even volatility** — the implied volatility level at which the position breaks even (for vega-sensitive strategies).

### Probability Analysis

Using the implied volatility and underlying price distribution:

- **Probability of Profit (POP)** — likelihood that the strategy yields any positive return at expiration. Based on the log-normal distribution implied by the current IV.
- **Probability of Max Profit** — likelihood of achieving the maximum possible profit (all short options expire worthless, all long options expire ITM).
- **Probability of touching** — likelihood that the underlying touches a specific price level at any time before expiration (higher than probability of finishing there).
- **Expected value** — probability-weighted average P&L. Integral of (P&L x probability density) over all underlying prices.
- **Expected value with slippage** — adjusts for bid-ask spread and execution quality.

### Scenario Analysis (What-If)

- **Vol scenarios:** Show P&L if IV increases/decreases by 5, 10, 15 percentage points.
- **Time scenarios:** Show P&L at various dates before expiration.
- **Combined scenarios:** A matrix of (underlying price change, IV change) with P&L in each cell. Also called a "risk matrix" or "scenario grid."
- **Monte Carlo scenario:** Simulate thousands of price paths and show the P&L distribution (histogram).

---

## Portfolio Margining for Options

### SPAN (Standard Portfolio Analysis of Risk)

Developed by the CME in 1988. Used globally for futures and options margining.

**How SPAN works:**

1. **Define risk arrays** — For each contract, calculate the theoretical gain or loss under 16 scenarios (combinations of underlying price moves and volatility changes).
   - Typical scan range: +/- 3 standard deviations of daily price move.
   - Volatility shifts: +/- 1 standard deviation of vol move (up/down).
   - The 16 scenarios: price up/down at 1/3, 2/3, 3/3 of the scan range, each with vol up and vol down, plus two extreme move scenarios (price up/down at 3x the scan range covering 35% of the loss).

2. **Identify the worst-case scenario** — The scenario producing the maximum loss is the scanning risk.

3. **Apply inter-month spread charges** — Additional margin for calendar risk (different expirations may not move in lockstep).

4. **Apply inter-commodity credits** — Offsets for correlated positions (e.g., crude oil vs heating oil).

5. **Apply short option minimum** — A floor to ensure short deep-OTM options carry some minimum margin.

6. **Sum net result** — SPAN margin = scanning risk + inter-month charge - inter-commodity credit, subject to short option minimum.

**SPAN margin rate** for a single futures contract is roughly equivalent to the expected 1-day price move at a 99% confidence level multiplied by the number of days for potential liquidation.

### TIMS (Theoretical Intermarket Margin System)

Used by the OCC for listed options. Predecessor to portfolio margining.

- Groups positions into classes (same underlying) and product groups (correlated underlyings).
- Uses theoretical pricing models to evaluate risk under multiple scenarios.
- Allows offsets between correlated products within a product group.

### OCC Risk-Based Margining (Portfolio Margin)

The OCC's portfolio margining system (also called "risk-based haircuts") for qualifying customer accounts.

**Eligibility:**
- Minimum account equity: $100,000 (FINRA requirement for portfolio margin).
- Must be approved by the broker for portfolio margining.
- Available for: equity options, index options, equity positions, ETF/ETN options.

**Methodology:**
- Evaluates the portfolio's theoretical gains and losses under 10 equidistant price moves:
  - Broad-based index: +/- 8% (SPX, NDX, RUT, DJX)
  - Non-broad-based index and ETF: +/- 15%
  - Individual equities: +/- 15%
- Each price move is evaluated at three volatility levels: current, +implied shift, -implied shift.
- The maximum loss across all scenarios is the margin requirement.
- Offsets are allowed across correlated positions.

### Portfolio Margin vs Reg-T Margin

| Feature | Reg-T Margin | Portfolio Margin |
|---|---|---|
| **Minimum equity** | $2,000 | $100,000 |
| **Methodology** | Strategy-based rules (fixed percentages) | Risk-based (scenario analysis) |
| **Short put margin** | 20% of underlying + premium - OTM amount | Max loss across +/- 15% scenarios |
| **Spread margin** | Max loss of the spread | Max loss across scenarios (often lower) |
| **Cross-position offsets** | Limited (within same underlying) | Broad (across correlated underlyings) |
| **Iron condor example (SPX)** | ~$45,000 per spread | ~$5,000-$10,000 per spread |
| **Typical capital efficiency** | Baseline | 3x to 6x more capital efficient |

**Example comparison:**

Short SPX 4200/4150 put spread (50-point wide):

- **Reg-T margin:** $50 x 100 = $5,000 per spread (max loss = margin requirement).
- **Portfolio margin:** Evaluated under +/- 8% scenarios. If SPX is at 4300, an 8% drop to 3956 would put the spread fully ITM, so margin is approximately the full $5,000. But if SPX is at 4500, an 8% drop to 4140 still leaves the spread near the edge, and the margin might be $3,000-$4,000 after volatility adjustment.

For complex portfolios with hedged positions, portfolio margin provides dramatically lower requirements due to the netting of risk across positions.

### Cross-Margining

Cross-margining allows offsets between positions held at different clearing organizations.

- **OCC-CME cross-margin program:** Offsets between listed equity options (OCC-cleared) and equity index futures (CME-cleared). A long SPX put position offsets against a long ES futures position.
- **Benefits:** Reduces total margin by recognizing hedges across product types.
- **Requirements:** Positions must be held in a cross-margin account at an approved clearing member.

### Margin Call Process

1. **Intraday monitoring:** Professional systems calculate margin in real-time. If equity falls below the maintenance requirement, a margin call is triggered.
2. **Margin call notification:** The broker notifies the account holder. Regulation T allows 2-3 business days to meet the call.
3. **Meeting the call:** Deposit cash, deposit marginable securities, or close positions to reduce the requirement.
4. **Forced liquidation:** If the call is not met, the broker can liquidate positions without notice. Brokers typically liquidate the most liquid positions first.

### Reg-T Margin Rules for Options (Key Rules)

- **Long options:** Must be paid for in full (100% of premium). No margin lending for long options.
- **Covered call:** No additional margin required (the shares serve as collateral).
- **Cash-secured put:** Must hold cash equal to the strike price x 100. Or, under margin, 20% of the underlying + premium - OTM amount (minimum 10% of strike + premium).
- **Naked call:** 20% of underlying + premium - OTM amount, minimum 10% of underlying + premium. Uncapped risk.
- **Vertical spread (credit):** Margin = width of spread - premium received. This is the max loss.
- **Vertical spread (debit):** Paid in full. No margin.
- **Iron condor:** Margin = max(put spread width, call spread width) - net premium. Only one side is margined because both sides cannot lose simultaneously.
- **Straddle/strangle (short):** Greater of the call side or put side requirement, plus the premium of the other side.

---

*This document serves as a reference for implementing options trading features in a professional trading desk application. All exchange rules, margin requirements, and regulatory references should be verified against current exchange and regulatory publications before implementation.*
