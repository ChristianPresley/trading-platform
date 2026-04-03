# Commodity Momentum

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading) / [Quantpedia](https://quantpedia.com/strategies/momentum-effect-in-commodities/)
> **Asset Class**: Commodity futures (cross-sectional)
> **Crypto/24-7 Applicable**: No — requires a broad, diversified universe of physically distinct commodity futures; crypto tokens are too correlated and lack the supply/demand heterogeneity that drives commodity momentum
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

Cross-sectional momentum in commodity futures involves buying the best-performing commodities over a lookback period and shorting the worst performers. Erb and Harvey (2006) document that a portfolio long the top-third and short the bottom-third of commodities ranked by prior 12-month returns generates more than 10% annualized returns. The strategy exploits the slow diffusion of supply/demand information across commodity markets and the tendency of fundamental trends (weather patterns, inventory cycles, geopolitical disruptions) to persist.

## Trading Rules

1. **Universe**: 20-30 liquid commodity futures (energy, metals, agriculture, livestock)
2. **Ranking signal**: Total return over the prior 12 months (alternative: 1-month, 3-month, 6-month lookbacks)
3. **Long leg**: Buy the top tercile (or quintile) of commodities by prior return
4. **Short leg**: Sell the bottom tercile (or quintile)
5. **Holding period**: 1 month (rebalance monthly)
6. **Weighting**: Equal-weight within each leg
7. **Variant**: Combine with time-series momentum (only go long commodities with positive absolute returns, short those with negative)

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.14 |
| CAGR | ~3-5% (long-short) |
| Max Drawdown | ~35-50% |
| Win Rate | ~52-54% |
| Volatility | 20.3% |
| Profit Factor | ~1.1 |
| Rebalancing | Monthly |

## Efficacy Rating

**3/5** — Well-documented academically across multiple time periods and geographies. However, the Sharpe ratio of 0.14 is notably low, and the high volatility (20.3%) makes the strategy difficult to implement as a standalone. Commodity momentum has historically underperformed equity momentum and is subject to severe momentum crashes during trend reversals. Works best as one component of a diversified multi-strategy commodity portfolio.

## Academic References

- Erb, C. B. & Harvey, C. R. (2006). "The Strategic and Tactical Value of Commodity Futures." *Financial Analysts Journal*, 62(2), 69-97.
- Miffre, J. & Rallis, G. (2007). "Momentum Strategies in Commodity Futures Markets." *Journal of Banking & Finance*, 31(6), 1863-1886.
- Asness, C. S., Moskowitz, T. J., & Pedersen, L. H. (2013). "Value and Momentum Everywhere." *Journal of Finance*, 68(3), 929-985.
- Moskowitz, T. J., Ooi, Y. H., & Pedersen, L. H. (2012). "Time Series Momentum." *Journal of Financial Economics*, 104(2), 228-250.
- Szymanowska, M., De Roon, F., Nijman, T., & Van Den Goorbergh, R. (2014). "An Anatomy of Commodity Futures Risk Premia." *Journal of Finance*, 69(1), 453-482.

## Implementation Notes

- **Roll methodology**: Returns must account for contract rolls; use nearest-to-expiry or second-nearest contract with consistent roll rules
- **Universe selection**: Avoid illiquid contracts (e.g., lumber, milk); focus on the 20-25 most liquid commodity futures across sectors
- **Sector neutrality (optional)**: Momentum within sectors (e.g., rank energy commodities against each other) can reduce sector concentration risk
- **Crash risk**: Commodity momentum is susceptible to sharp reversals, particularly in energy markets during geopolitical shocks; consider volatility-targeting or stop-losses
- **Combination with time-series momentum**: Moskowitz et al. (2012) show that time-series momentum (long if own past return is positive, short if negative) often outperforms cross-sectional momentum in commodities
- **Capacity**: Commodity futures markets have lower capacity than equity markets; large positions can move prices, especially in agricultural contracts
