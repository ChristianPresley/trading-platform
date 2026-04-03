# Kalman Filter Pairs Trading

> **Source**: [QuantConnect Research — Kalman Filter Based Pairs Trading](https://github.com/QuantConnect/Research/blob/master/Analysis/02%20Kalman%20Filter%20Based%20Pairs%20Trading.ipynb), [QuantStart — Dynamic Hedge Ratio with Kalman Filter](https://www.quantstart.com/articles/Dynamic-Hedge-Ratio-Between-ETF-Pairs-Using-the-Kalman-Filter/)
> **Asset Class**: Equities, ETFs
> **Crypto/24-7 Applicable**: Adaptable — the Kalman filter's adaptive hedge ratio is well-suited to crypto pairs where relationships shift rapidly, though the filter parameters require careful tuning for higher-volatility regimes
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

Kalman filter pairs trading enhances the classic pairs trading framework by replacing the static (OLS-estimated) hedge ratio with a dynamically adaptive one. The standard pairs trading approach estimates the hedge ratio via linear regression over a fixed lookback window, introducing two problems: the hedge ratio is stale (reflecting past relationships), and the choice of window length is arbitrary (too short adds noise, too long misses structural change). The Kalman filter resolves both issues by treating the hedge ratio as a hidden state variable that evolves over time, updating it optimally with each new price observation.

The Kalman filter is a recursive Bayesian estimation algorithm that maintains a running estimate of the hedge ratio (state) and its uncertainty (covariance). At each timestep, it produces a prediction of the next observation, compares it to the actual observation, and updates the state estimate proportionally to the "innovation" (prediction error). The filter automatically adapts to structural changes in the pair relationship without requiring a fixed lookback window or explicit regime detection.

In pairs trading, the state-space model is:
- **Observation equation**: `y_t = beta_t * x_t + alpha_t + epsilon_t` (price of asset A as a function of asset B)
- **State equation**: `[beta_t, alpha_t]' = [beta_{t-1}, alpha_{t-1}]' + eta_t` (hedge ratio and intercept evolve as random walks)

The resulting spread is more stationary and mean-reverting than spreads constructed with rolling OLS, leading to more reliable trading signals and improved risk-adjusted returns.

## Trading Rules

1. **Pair Selection**: Select pairs using the standard cointegration framework (Engle-Granger test on a 12-month formation period). The Kalman filter improves execution, not pair selection.

2. **Kalman Filter Initialization**:
   - Initial state: `[beta_0, alpha_0] = OLS estimates from formation period`
   - Initial state covariance: `P_0 = identity matrix * 1.0`
   - Observation noise variance: `R = var(OLS residuals)`
   - State transition noise covariance: `Q = diagonal matrix with small values (1e-5 to 1e-4)` — controls how quickly the hedge ratio adapts. Lower Q = smoother, higher Q = more responsive.

3. **Dynamic Spread Construction**:
   - At each timestep, run the Kalman filter predict-update cycle to obtain the current hedge ratio `beta_t` and intercept `alpha_t`.
   - Compute the spread: `spread_t = y_t - beta_t * x_t - alpha_t`
   - The spread should be approximately white noise if the filter is well-calibrated.

4. **Signal Generation**:
   - Standardize the spread using a rolling 20-day standard deviation: `z_t = spread_t / sigma_20`
   - Long the spread (long A, short beta*B) when z_t < -1.5
   - Short the spread (short A, long beta*B) when z_t > +1.5
   - Close when z_t reverts to within +/- 0.25 of zero.

5. **Position Sizing**: At entry, allocate $1 notional to asset A and $beta_t notional to asset B. The hedge ratio is fixed at the entry value for the duration of the trade to avoid constant rebalancing; the Kalman filter continues updating for signal purposes.

6. **Stop-Loss**: Close if |z_t| exceeds 3.5 (suggesting the filter may not be tracking the true relationship).

7. **Filter Monitoring**: Track the filter's prediction error variance. A sustained increase indicates model degradation — widen entry thresholds or stop trading the pair.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.5-0.8 (strategy dependent) |
| CAGR | 6-9% (gross of costs) |
| Max Drawdown | -12% to -20% |
| Win Rate | 55-62% |
| Volatility | 8-12% annualized |
| Profit Factor | 1.2-1.5 |
| Rebalancing | Daily (filter update), signal-driven (trades) |

QuantStart backtests on ETF pairs (e.g., TLT/IEI, GLD/GDX) showed a CAGR of approximately 8.7% with a Sharpe of 0.75, though this was gross of transaction costs. The key improvement over static-hedge pairs trading is more stable spread dynamics — rolling OLS hedge ratios oscillate wildly (0.6 to 1.2 in one example), while Kalman-smoothed ratios stay in a narrow band (0.55 to 0.65), producing cleaner signals.

## Efficacy Rating

**Rating: 3/5** — The Kalman filter is a genuine improvement over static hedge ratios for pairs trading, producing more stationary spreads and more reliable signals. The rating reflects that the improvement is incremental rather than transformative (it doesn't fix bad pairs), the strategy's performance is still constrained by the fundamental challenges of pairs trading (pair instability, crowding, costs), and the added complexity introduces new parameters to tune (Q, R matrices) that can be overfit. The approach is best viewed as an execution enhancement layered onto a robust pair selection process.

## Academic References

- Kalman, R. E. (1960). "A New Approach to Linear Filtering and Prediction Problems." *Journal of Basic Engineering*, 82(1), 35-45.
- Elliott, R. J., van der Hoek, J., & Malcolm, W. P. (2005). "Pairs Trading." *Quantitative Finance*, 5(3), 271-276.
- Montana, G., Triantafyllopoulos, K., & Tsagaris, T. (2009). "Flexible Least Squares for Temporal Data Mining and Statistical Arbitrage." *Expert Systems with Applications*, 36(2), 2819-2830.
- Triantafyllopoulos, K., & Montana, G. (2011). "Dynamic Modeling of Mean-Reverting Spreads for Statistical Arbitrage." *Computational Management Science*, 8(1-2), 23-49.
- Palomar, D. P. (2024). *Portfolio Optimization with R*. Chapter 15.6: Kalman Filtering for Pairs Trading.

## Implementation Notes

- **Kalman Filter Tuning**: The most critical parameter is Q, the state transition noise covariance. Too small and the filter adapts too slowly (like a long OLS window); too large and it tracks noise. Cross-validation on the formation period, or maximum likelihood estimation of Q and R, is recommended over ad-hoc tuning.
- **Filter Stability**: In early timesteps, the filter's state estimate has high uncertainty and should not be used for trading. Allow a burn-in period of at least 60 observations before generating signals.
- **Comparison to Alternatives**: Rolling OLS with optimal window selection, exponentially weighted moving average (EWMA) regression, and regime-switching models are alternative approaches to dynamic hedge ratios. The Kalman filter is optimal under Gaussian assumptions but may underperform robust alternatives when return distributions are heavy-tailed.
- **Computational Cost**: The Kalman filter is lightweight (O(d^2) per update for d-dimensional state, here d=2). It can run in real-time with negligible latency, making it suitable for intraday applications.
- **Crypto Adaptation**: The Kalman filter is particularly well-suited to crypto pairs because relationships shift faster. Use larger Q values (1e-3 to 1e-2) to allow the hedge ratio to adapt more quickly. Shorter standardization windows (10-day instead of 20-day) are also appropriate given higher crypto volatility. Test on major pairs: BTC/ETH, SOL/ETH, BNB/ETH.
