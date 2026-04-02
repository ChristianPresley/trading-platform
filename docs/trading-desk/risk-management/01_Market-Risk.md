## 1. Market Risk

Market risk is the risk of losses due to adverse movements in market prices, rates, and volatilities.

### Value at Risk (VaR)

VaR answers: "What is the maximum loss over a given time horizon at a given confidence level, under normal market conditions?"

```
VaR(alpha, T) = the loss level such that P(Loss > VaR) = 1 - alpha
```

Typical parameters:
- **Confidence level**: 95% or 99%
- **Time horizon**: 1 day (trading), 10 days (regulatory)
- **Observation window**: 250 trading days (1 year) to 500+ days

#### Historical VaR

Uses actual historical returns to construct the P&L distribution.

**Method:**

1. Collect N days of historical returns for all risk factors.
2. For each historical day i (i = 1 to N), apply the historical changes in risk factors to the current portfolio.
3. Compute the hypothetical portfolio P&L for each day.
4. Sort the P&L values from worst to best.
5. VaR at confidence level alpha = the P&L at the (1-alpha) * N-th percentile.

```
Example: 250 days of history, 99% confidence
  Sort 250 P&L scenarios from worst to best
  99% VaR = 2nd worst loss (since 250 * 0.01 = 2.5, round to 2nd)

  Sorted P&Ls: [-$8.2M, -$6.1M, -$5.8M, ..., +$7.3M]
  99% 1-day VaR = $6.1M (2nd worst)
```

**Advantages**: No distributional assumptions; captures fat tails and correlations naturally.
**Disadvantages**: Limited to historical events; window length is a trade-off (longer = more data but less relevant; shorter = more relevant but more noise).

#### Parametric (Variance-Covariance) VaR

Assumes returns are normally (or near-normally) distributed.

```
VaR = z_alpha * sigma_portfolio * sqrt(T)
```

Where:
- `z_alpha` = standard normal quantile (1.645 for 95%, 2.326 for 99%)
- `sigma_portfolio` = portfolio standard deviation
- `T` = time horizon in days

For a portfolio of N assets:

```
sigma_portfolio = sqrt(w' * Sigma * w)
```

Where:
- `w` = vector of portfolio weights (notional exposures)
- `Sigma` = N x N covariance matrix of asset returns

**Advantages**: Computationally efficient; easy to decompose into component and marginal VaR.
**Disadvantages**: Assumes normality (underestimates tail risk); poor for non-linear instruments (options).

**Scaling VaR across time horizons** (square-root-of-time rule):
```
VaR(T days) = VaR(1 day) * sqrt(T)
```

This assumes i.i.d. returns (independent and identically distributed). The assumption is reasonable for short horizons but breaks down for longer periods due to serial correlation and mean reversion.

#### Monte Carlo VaR

Simulates thousands of possible future scenarios using stochastic processes.

**Method:**

1. Define stochastic processes for all risk factors (e.g., geometric Brownian motion for equities, Hull-White for rates).
2. Calibrate model parameters to historical data or market-implied values.
3. Generate N random scenarios (typically 10,000-100,000).
4. Revalue the entire portfolio under each scenario.
5. Construct the P&L distribution from the simulated values.
6. VaR = the loss at the (1-alpha) percentile of the simulated distribution.

```
For each simulation i (i = 1 to N):
  For each risk factor j:
    S_j(t+dt) = S_j(t) * exp((mu_j - 0.5*sigma_j^2)*dt + sigma_j*sqrt(dt)*Z_ij)
    where Z_ij ~ N(0,1), correlated across risk factors using Cholesky decomposition
  
  PnL_i = Portfolio_Value(new risk factors) - Portfolio_Value(current risk factors)

VaR = percentile(PnL_1, ..., PnL_N, 1-alpha)
```

**Advantages**: Handles non-linear instruments (options, structured products); can model non-normal distributions, jumps, stochastic volatility.
**Disadvantages**: Computationally expensive; model risk from assumed stochastic processes; convergence requires many simulations.

### Expected Shortfall (CVaR)

Expected Shortfall (also called Conditional VaR or CVaR) measures the average loss in the tail beyond VaR:

```
ES_alpha = E[Loss | Loss > VaR_alpha]
```

ES is the average of all losses that exceed the VaR threshold. It provides information about the severity of tail losses, not just the threshold.

```
Example: 99% ES with 250 scenarios
  99% VaR = 2nd worst loss = $6.1M
  99% ES = average of the 2 worst losses = ($8.2M + $6.1M) / 2 = $7.15M
```

ES is **coherent** (satisfies subadditivity), unlike VaR:
```
ES(A + B) <= ES(A) + ES(B)   [always true for ES]
VaR(A + B) <= VaR(A) + VaR(B) [NOT always true for VaR]
```

Basel III's Fundamental Review of the Trading Book (FRTB) replaced VaR with ES as the primary market risk measure.

### Stress Testing

Stress testing evaluates portfolio impact under extreme but plausible scenarios. Unlike VaR (which measures "normal" market conditions), stress tests measure losses in crisis scenarios.

**Types of stress tests:**

| Type | Description |
|---|---|
| **Historical** | Replay actual crisis scenarios |
| **Hypothetical** | Construct plausible future scenarios |
| **Reverse** | Determine what scenarios would cause a given loss level |
| **Sensitivity** | Shift one or more risk factors by fixed amounts |

Standard historical stress scenarios:

| Scenario | Period | Key Characteristics |
|---|---|---|
| Black Monday | Oct 1987 | US equities -22% in one day |
| LTCM / Russian Crisis | Aug-Sep 1998 | Spread widening, flight to quality |
| Dot-Com Crash | 2000-2002 | Tech stocks -78% (NASDAQ peak to trough) |
| 9/11 | Sep 2001 | Markets closed 4 days, reopened down 7% |
| Global Financial Crisis | 2007-2009 | Credit crisis, equities -57%, massive vol spike |
| European Sovereign Crisis | 2010-2012 | Peripheral spreads blow out |
| COVID-19 | Mar 2020 | Equities -34%, VIX > 80, rates collapse |
| 2022 Rate Shock | 2022 | Fastest rate hike cycle in 40 years, bonds -13% |

### Scenario Analysis

Scenario analysis applies specific, defined changes to market variables:

```
Scenario: "Rates +100bps, Equities -10%, Vol +5 pts, USD +5%"

Apply simultaneously:
  Rate curves: parallel shift up 100bps
  Equity indices: all down 10%
  Implied volatility surfaces: flat shift up 5 vol points
  FX: USD appreciates 5% against all currencies

Revalue entire portfolio under stressed parameters
Portfolio P&L under scenario = Stressed Value - Current Value
```

---
