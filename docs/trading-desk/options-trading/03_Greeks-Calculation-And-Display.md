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
