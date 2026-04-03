# Asset Growth Effect

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: Adaptable — on-chain treasury growth or token supply expansion could serve as proxies
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

The asset growth effect documents that firms with high rates of total asset growth subsequently earn lower stock returns, while firms with low or negative asset growth earn higher returns. First rigorously established by Cooper, Gulen, and Schill (2008) in the Journal of Finance, the anomaly is remarkably strong: the annual return spread between the lowest and highest asset growth deciles was approximately 20% per year in their sample. The effect is robust to controls for size, book-to-market, momentum, and other known factors, and in fact dominates many of them in cross-sectional regressions. Explanations include overinvestment driven by empire-building managers, market overreaction to growth expectations, and the investment factor embedded in production-based asset pricing models (q-theory). The Fama-French five-factor model later incorporated an investment factor (CMA) that is closely related to this anomaly.

## Trading Rules

1. **Universe**: All common stocks on major exchanges with available balance sheet data.
2. **Signal**: At the end of each year, compute year-over-year total asset growth rate: (Total Assets_t - Total Assets_{t-1}) / Total Assets_{t-1}.
3. **Sort**: Rank all stocks by asset growth rate into deciles.
4. **Long Portfolio**: Buy stocks in the bottom decile (lowest or most negative asset growth -- contracting firms).
5. **Short Portfolio**: Sell short stocks in the top decile (highest asset growth -- rapidly expanding firms).
6. **Weighting**: Equal-weight positions within each portfolio leg.
7. **Rebalancing**: Annually (typically July, after fiscal year-end data is available).
8. **Holding Period**: One year, then re-sort and rebalance.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.835 |
| CAGR | ~15-20% (long-short spread) |
| Max Drawdown | ~20-25% |
| Win Rate | ~58% |
| Volatility | 10.2% |
| Profit Factor | ~1.5 |
| Rebalancing | Yearly |

## Efficacy Rating

**4 / 5** -- The asset growth effect is one of the strongest cross-sectional return predictors documented in the academic literature, with an exceptionally high Sharpe ratio (0.835) and low volatility (10.2%). It receives a 4 rather than 5 because: (1) annual rebalancing introduces significant timing risk, (2) the effect relies on accounting data which is subject to manipulation and reporting lags, and (3) the premium has shown some decay since publication as it became incorporated into factor models. However, its economic magnitude and robustness across international markets make it a highly valuable factor.

## Academic References

- Cooper, M.J., Gulen, H., and Schill, M.J. (2008). "Asset Growth and the Cross-Section of Stock Returns." *Journal of Finance*, 63(4), 1609-1651.
- Fama, E.F. and French, K.R. (2015). "A Five-Factor Asset Pricing Model." *Journal of Financial Economics*, 116(1), 1-22.
- Hou, K., Xue, C., and Zhang, L. (2015). "Digesting Anomalies: An Investment Approach." *Review of Financial Studies*, 28(3), 650-705.
- Watanabe, A., Xu, Y., Yao, T., and Yu, T. (2013). "The Asset Growth Effect: Insights from International Equity Markets." *Journal of Financial Economics*, 108(2), 529-563.
- Lipson, M.L., Mortal, S., and Schill, M.J. (2011). "On the Scope and Drivers of the Asset Growth Effect." *Journal of Financial and Quantitative Analysis*, 46(6), 1651-1682.

## Implementation Notes

- **Data Availability**: Total asset data comes from annual financial statements; ensure a minimum 6-month lag from fiscal year-end to avoid look-ahead bias.
- **Sector Effects**: The asset growth effect is particularly strong in sectors with large capital expenditure cycles (industrials, energy, real estate).
- **Decomposition**: The effect can be decomposed into components (capex growth, acquisition growth, equity issuance) which may have different return predictability.
- **Crypto Adaptation**: Potential proxies include token supply growth rate, protocol treasury expansion, or total value locked (TVL) growth. Protocols aggressively expanding (high token emissions, aggressive treasury deployment) may underperform.
- **Combination with CMA**: The Fama-French CMA (Conservative Minus Aggressive) factor is closely related; combining asset growth with other investment metrics can enhance signal quality.
