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
