# Term Structure Effect in Commodities

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading) / [Quantpedia](https://quantpedia.com/strategies/term-structure-effect-in-commodities)
> **Asset Class**: Commodity futures (cross-sectional)
> **Crypto/24-7 Applicable**: No — requires a broad universe of commodity futures with multi-tenor term structures; crypto futures curves lack the depth and heterogeneity needed
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

The shape of the commodity futures term structure predicts cross-sectional returns. Commodities with inverted (backwardated) curves -- where near-term contracts trade at a premium to deferred contracts -- tend to outperform those with upward-sloping (contangoed) curves. Szymanowska et al. (2014) decompose commodity futures returns into spot premia and term premia, finding that both components carry risk premia. The strategy ranks commodities by the slope of their futures curves and constructs a long-short portfolio, capturing the structural risk transfer premium embedded in the term structure.

## Trading Rules

1. **Universe**: 20-30 liquid commodity futures with at least 2-3 actively traded contract maturities
2. **Signal**: Compute the term structure slope as the log ratio of the second-nearby to the first-nearby futures price: ln(F2/F1)
3. **Long leg**: Buy commodities with the most negative slope (strongest backwardation), bottom tercile
4. **Short leg**: Sell commodities with the most positive slope (strongest contango), top tercile
5. **Holding period**: 1 month (rebalance monthly)
6. **Weighting**: Equal-weight within each leg
7. **Variant (full curve)**: Use the slope across 3+ contract maturities for a more stable signal

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.128 |
| CAGR | ~2-4% (long-short) |
| Max Drawdown | ~35-45% |
| Win Rate | ~51-53% |
| Volatility | 23.1% |
| Profit Factor | ~1.1 |
| Rebalancing | Monthly |

## Efficacy Rating

**3/5** — Theoretically well-grounded in the storage theory of commodity pricing and the Keynes-Hicks risk transfer framework. Szymanowska et al. (2014) provide rigorous academic support. However, the realized Sharpe ratio of 0.128 is low, and the high volatility (23.1%) makes the strategy challenging as a standalone. The term structure signal overlaps significantly with roll yield, making it partially redundant in a multi-factor commodity portfolio. Works best as a complementary signal alongside momentum and skewness.

## Academic References

- Szymanowska, M., De Roon, F., Nijman, T., & Van Den Goorbergh, R. (2014). "An Anatomy of Commodity Futures Risk Premia." *Journal of Finance*, 69(1), 453-482.
- Fuertes, A. M., Miffre, J., & Rallis, G. (2010). "Tactical Allocation in Commodity Futures Markets: Combining Momentum and Term Structure Signals." *Journal of Banking & Finance*, 34(10), 2530-2548.
- Gorton, G., Hayashi, F., & Rouwenhorst, K. G. (2013). "The Fundamentals of Commodity Futures Returns." *Review of Finance*, 17(1), 35-105.
- Koijen, R. S. J., Moskowitz, T. J., Pedersen, L. H., & Vrugt, E. B. (2018). "Carry." *Journal of Financial Economics*, 127(2), 197-225.

## Implementation Notes

- **Relationship to roll yield**: The term structure signal and roll yield are closely related but not identical. Roll yield measures the return from rolling a single contract pair, while the term structure slope captures the broader curve shape. In practice, their correlation is 0.7-0.9
- **Full curve vs. front-end**: Using only the front two contracts captures most of the signal but can be noisy for commodities with irregular delivery schedules. The full-curve slope (3+ tenors) is more stable but requires deeper liquidity across the curve
- **Combining signals**: Fuertes, Miffre, and Rallis (2010) show that combining term structure and momentum signals produces a portfolio with significantly higher Sharpe ratios than either signal alone
- **Financialization effects**: Post-2004 commodity index inflows distorted term structures, pushing many commodities into persistent contango regardless of fundamentals; this may have weakened the strategy during 2005-2015
- **Seasonal patterns**: Some commodities (e.g., natural gas, agriculture) have strong seasonal term structure patterns driven by storage and harvest cycles; consider deseasonalizing the signal for these contracts
- **Capacity**: Similar to other commodity cross-sectional strategies, capacity is constrained by the size of commodity futures markets relative to equity markets
