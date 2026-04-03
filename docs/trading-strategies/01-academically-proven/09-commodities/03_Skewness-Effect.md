# Skewness Effect in Commodities

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading)
> **Asset Class**: Commodity futures (cross-sectional)
> **Crypto/24-7 Applicable**: No — requires a broad universe of commodity futures with distinct skewness profiles; crypto assets are too correlated and lack sufficient history
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

Commodities with negatively skewed return distributions outperform those with positively skewed distributions. Fernandez-Perez, Frijns, Fuertes, and Miffre (2018) document that a long-short strategy buying the most negatively skewed commodities and selling the most positively skewed generates significant excess returns. The effect is explained by investors' lottery preferences under cumulative prospect theory: investors overpay for positively skewed assets (those with small probabilities of large gains), depressing their future returns, while underpricing negatively skewed assets. Negatively skewed commodities also tend to exhibit backwardated term structures, linking this effect to the roll yield premium.

## Trading Rules

1. **Universe**: 20-30 liquid commodity futures across sectors
2. **Signal**: Compute the realized skewness of daily returns over the prior 12 months for each commodity
3. **Long leg**: Buy commodities in the bottom tercile of skewness (most negative skew)
4. **Short leg**: Sell commodities in the top tercile of skewness (most positive skew)
5. **Holding period**: 1 month (rebalance monthly)
6. **Weighting**: Equal-weight within each leg
7. **Robustness check**: Verify that the signal remains significant after controlling for momentum and roll yield

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.482 |
| CAGR | ~7-10% (long-short) |
| Max Drawdown | ~25-35% |
| Win Rate | ~54-58% |
| Volatility | 17.7% |
| Profit Factor | ~1.3-1.5 |
| Rebalancing | Monthly |

## Efficacy Rating

**3/5** — Strong Sharpe ratio (0.482) relative to other commodity strategies and supported by a clear behavioral mechanism (skewness preference). The academic backing from Fernandez-Perez et al. (2018) is rigorous, with controls for standard risk factors. However, the strategy is complex to implement, requires careful skewness estimation (sensitive to outliers), and the signal overlaps with roll yield and momentum. The incremental alpha after controlling for these factors is smaller but still significant.

## Academic References

- Fernandez-Perez, A., Frijns, B., Fuertes, A. M., & Miffre, J. (2018). "The Skewness of Commodity Futures Returns." *Journal of Banking & Finance*, 86, 143-158.
- Barberis, N. & Huang, M. (2008). "Stocks as Lotteries: The Implications of Probability Weighting for Security Prices." *American Economic Review*, 98(5), 2066-2100.
- Boyer, B., Mitton, T., & Vorkink, K. (2010). "Expected Idiosyncratic Skewness." *Review of Financial Studies*, 23(1), 169-202.
- Amaya, D., Christoffersen, P., Jacobs, K., & Vasquez, A. (2015). "Does Realized Skewness Predict the Cross-Section of Equity Returns?" *Journal of Financial Economics*, 118(1), 135-167.

## Implementation Notes

- **Skewness estimation**: Use daily returns over 12 months (approximately 252 observations); shorter windows increase noise. Consider robust skewness estimators (e.g., median-based) to reduce sensitivity to extreme outliers
- **Factor overlap**: The skewness signal is correlated with roll yield (backwardated commodities tend to have negative skew) and momentum (trending commodities develop skewed distributions). Orthogonalize the signal or use it as a complementary factor in a multi-signal framework
- **Rebalancing costs**: Monthly rebalancing of a cross-sectional portfolio incurs roll and transaction costs; ensure the alpha exceeds frictional costs
- **Prospect theory linkage**: The economic mechanism is well-understood -- investors systematically overpay for lottery-like payoffs. This behavioral bias is unlikely to be fully arbitraged away, supporting long-term persistence
- **Sector composition**: Positively skewed commodities tend to be in contango with lower roll yields, while negatively skewed commodities are typically backwardated -- monitor whether the strategy is inadvertently loading on the term structure factor
