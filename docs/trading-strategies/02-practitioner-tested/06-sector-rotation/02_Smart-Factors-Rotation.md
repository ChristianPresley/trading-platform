# Smart Factors Rotation Strategy

> **Source**: [Awesome Systematic Trading](https://github.com/paperswithbacktest/awesome-systematic-trading), [Quantpedia — Sector Momentum Rotational System](https://quantpedia.com/strategies/sector-momentum-rotational-system)
> **Asset Class**: Equities (Factor ETFs)
> **Crypto/24-7 Applicable**: No — requires factor ETFs that do not have direct crypto equivalents
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

Smart factors rotation applies momentum-based rotation across factor ETFs — funds that target specific equity risk factors such as value, momentum, quality, low volatility, and size. Rather than selecting individual stocks, the strategy rotates capital among factor exposures based on their recent relative performance, attempting to time factor cycles.

The rationale is that equity factors exhibit cyclical behavior: value outperforms in certain macroeconomic regimes, momentum in others, and low volatility during risk-off periods. By systematically rotating into the currently strongest factor, the strategy aims to capture the upside of factor timing without the complexity of multi-factor stock selection. The Awesome Systematic Trading repository catalogs this strategy with a Sharpe ratio of 0.388 and 8.2% annualized volatility, reflecting a modest but consistent edge.

## Trading Rules

1. **Universe**: Factor ETFs representing the major equity risk factors:
   - MTUM (Momentum)
   - VLUE (Value)
   - QUAL (Quality)
   - USMV (Minimum Volatility)
   - SIZE (Size Factor)
   - Optionally: DGRO (Dividend Growth), HDV (High Dividend)

2. **Ranking**: At the end of each month, rank all factor ETFs by their total return over the past 6-12 months (or a composite momentum score).

3. **Allocation**: Invest 100% of capital in the top-ranked factor ETF. Alternatively, allocate across the top 2 factors (50/50 split).

4. **Rebalancing**: Monthly, on the last trading day.

5. **Cash Filter (Optional)**: If the top-ranked factor ETF has a negative 12-month return, rotate to cash or a short-term bond ETF.

6. **Holding**: Hold the selected factor ETF(s) for the full month.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.388 |
| CAGR | ~5-7% |
| Max Drawdown | -20% to -30% |
| Win Rate | ~52-55% (monthly) |
| Volatility | 8.2% annualized |
| Profit Factor | ~1.2-1.4 |
| Rebalancing | Monthly |

The Sharpe ratio of 0.388 indicates a positive but modest risk-adjusted return. The low volatility (8.2%) reflects the diversification benefit of factor ETFs, which are broadly diversified equity portfolios themselves. The strategy's edge is subtle — it slightly outperforms an equal-weight factor allocation but does not dramatically beat the market. The modest Sharpe ratio suggests that factor timing is difficult and the signal is noisy.

## Efficacy Rating

**Rating: 3/5** — Factor rotation has a sound theoretical basis: factor premia are cyclical and influenced by macroeconomic conditions. The documented Sharpe ratio of 0.388 with low volatility represents a real, if modest, improvement over naive factor allocation. The rating reflects: (a) the difficulty of timing factor cycles, with factor momentum being a weaker signal than cross-sectional stock momentum, (b) the risk of factor crowding as smart beta ETFs have attracted massive flows, potentially eroding the rotation premium, (c) limited out-of-sample validation given that most factor ETFs have relatively short histories (post-2013), and (d) the strategy underperforms during factor reversals when previously losing factors suddenly outperform.

## Academic References

- Asness, C. S., Moskowitz, T. J., & Pedersen, L. H. (2013). "Value and Momentum Everywhere." *The Journal of Finance*, 68(3), 929-985.
- Arnott, R. D., Harvey, C. R., Kalesnik, V., & Linnainmaa, J. T. (2019). "Alice's Adventures in Factorland: Three Blunders That Plague Factor Investing." *The Journal of Portfolio Management*, 45(4), 18-36.
- Gupta, T., & Kelly, B. (2019). "Factor Momentum Everywhere." *The Journal of Finance*, 74(3), 1325-1379.
- Hurst, B., Ooi, Y. H., & Pedersen, L. H. (2017). "A Century of Evidence on Trend-Following Investing." *The Journal of Portfolio Management*, 44(1), 15-29.

## Implementation Notes

- **Factor ETF Selection**: Use the largest and most liquid factor ETFs to minimize tracking error. iShares Edge MSCI factor ETFs (MTUM, VLUE, QUAL, USMV, SIZE) provide the cleanest factor exposures among US-listed products.
- **Lookback Period**: Factor momentum is typically slower than stock momentum. A 12-month lookback with 1-month skip (to avoid short-term reversal) is the standard academic specification. Shorter lookbacks (3-6 months) are noisier but more responsive.
- **Factor Crowding Risk**: The massive growth of smart beta ETFs ($1.5T+ AUM) means factor rotation strategies now compete with significant institutional capital following similar signals. This crowding may compress future returns.
- **Regime Awareness**: Factor performance is correlated with macroeconomic regimes. Value tends to outperform during economic recoveries, momentum during stable growth, and low volatility during downturns. Some implementations overlay a regime indicator (e.g., yield curve slope, ISM manufacturing) to improve factor selection.
- **No Direct Crypto Equivalent**: While crypto tokens can be categorized by "sector," the factor framework (value, momentum, quality, size) does not translate directly to crypto. Crypto sector rotation (see ETF Rotation strategy) is the closest analogue.
- **Transaction Costs**: Monthly rebalancing of factor ETFs generates minimal costs. The primary concern is tax drag from short-term capital gains, which can be managed through tax-advantaged account placement.
