# Statistical Arbitrage and Pairs Trading

Strategies that exploit relative pricing inefficiencies between related securities. These approaches are grounded in mean-reversion of price relationships, cointegration theory, and no-arbitrage conditions, rather than directional market views.

## Strategies

| # | Strategy | Sharpe | Rating | Crypto |
|---|----------|--------|--------|--------|
| 01 | [Pairs Trading — Stocks](01_Pairs-Trading-Stocks.md) | 0.634 | 4/5 | Adaptable |
| 02 | [Pairs Trading — Country ETFs](02_Pairs-Trading-Country-ETFs.md) | 0.257 | 3/5 | No |
| 03 | [Statistical Arbitrage](03_Statistical-Arbitrage.md) | 1.0-1.5+ | 4/5 | Adaptable |
| 04 | [Dispersion Trading](04_Dispersion-Trading.md) | 0.432 | 4/5 | No |
| 05 | [Kalman Filter Pairs Trading](05_Kalman-Filter-Pairs-Trading.md) | 0.5-0.8 | 3/5 | Adaptable |
| 06 | [Triangular Arbitrage](06_Triangular-Arbitrage.md) | N/A | 3/5 | Yes |

## Key Concepts

- **Cointegration**: Two or more price series share a long-run equilibrium relationship, even if individually non-stationary. Deviations from this equilibrium are expected to revert, creating trading opportunities.
- **Mean Reversion of Spreads**: The core assumption is that the price spread between related assets will revert to a historical mean or model-implied fair value.
- **Market Neutrality**: Most strategies here are constructed to be dollar-neutral or beta-neutral, isolating the relative value signal from broad market exposure.
- **Stationarity Testing**: Augmented Dickey-Fuller (ADF) and Engle-Granger tests are standard tools for validating that a pair's spread is mean-reverting.
- **Dynamic Hedge Ratios**: Static hedge ratios degrade over time; Kalman filters and rolling regression provide adaptive alternatives.

## Common Risk Factors

- **Regime changes**: Cointegration relationships can break down permanently due to structural shifts (M&A, sector rotation, regulatory changes).
- **Crowding**: Popular pairs attract capital, compressing returns and increasing correlation during stress.
- **Execution risk**: Many of these strategies require simultaneous execution across multiple legs, where slippage on one leg can eliminate the edge.
- **Convergence timing**: Mispricings may persist longer than capital allows, particularly during liquidity crises.
