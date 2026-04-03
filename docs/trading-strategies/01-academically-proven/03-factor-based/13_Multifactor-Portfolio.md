# Multifactor Portfolio

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) — Kakushadze & Serur (2018), Ch. 3
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: Adaptable — factor combination framework applies to any asset class with sufficient cross-sectional breadth
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

The multifactor portfolio strategy combines multiple individual return-predictive factors into a single diversified portfolio, capturing the benefits of factor diversification. Rather than relying on any single anomaly (value, momentum, size, quality, etc.), the multifactor approach recognizes that individual factors experience prolonged drawdowns at different times and that their imperfect correlations create a substantially smoother return stream when combined. The approach draws on the extensive academic literature demonstrating that no single factor dominates across all market regimes, but a thoughtfully constructed combination provides more consistent alpha with lower drawdown risk. As detailed in Kakushadze and Serur's "151 Trading Strategies" (Section 3.6), the multifactor portfolio methodology involves selecting factors with strong individual evidence, determining combination weights (equal-weight, risk-parity, or optimized), and managing the interaction effects between factors.

## Trading Rules

1. **Universe**: All common stocks on major exchanges with sufficient data for all selected factors.
2. **Factor Selection**: Choose 3-7 factors with strong individual academic evidence and low pairwise correlations. A typical set includes:
   - Value (book-to-market or earnings yield)
   - Momentum (12-1 month price momentum)
   - Size (market capitalization)
   - Quality (profitability, low leverage, earnings stability)
   - Low Volatility (realized volatility or beta)
   - Investment (asset growth or capex growth)
3. **Composite Signal**: For each stock, compute a composite score by:
   - Standardizing each factor signal (z-score within the cross-section).
   - Combining z-scores using equal weights, risk-parity weights, or optimized weights.
4. **Portfolio Construction**: Sort stocks by composite score into deciles or quintiles.
   - **Long Portfolio**: Buy stocks in the top decile (highest composite score).
   - **Short Portfolio**: Sell short stocks in the bottom decile (lowest composite score).
5. **Weighting**: Equal-weight or inverse-volatility-weight within each leg.
6. **Rebalancing**: Monthly (for factors with monthly signals) or quarterly (for a blend of monthly and annual factors).
7. **Holding Period**: Match rebalancing frequency; stagger portfolio entry dates for smoother turnover.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.8-1.2 (depends on factor selection) |
| CAGR | ~10-15% (long-short) |
| Max Drawdown | ~15-25% |
| Win Rate | ~58-62% |
| Volatility | ~8-12% |
| Profit Factor | ~1.5-1.8 |
| Rebalancing | Monthly to Quarterly |

## Efficacy Rating

**4 / 5** -- The multifactor portfolio is one of the most practical and robust approaches to systematic equity investing. By combining factors with well-documented individual premia, the strategy achieves significantly higher risk-adjusted returns and lower drawdowns than any single factor. It receives a 4 rather than 5 because: (1) implementation complexity is high (data requirements, factor construction, weight optimization), (2) factor crowding and regime dependence mean that even diversified factor portfolios can experience painful drawdowns (e.g., the "quant quake" of August 2007), and (3) the specific factor weights and combination methodology introduce model risk. However, the diversification principle is sound and well-established.

## Academic References

- Kakushadze, Z. and Serur, J.A. (2018). *151 Trading Strategies*. Palgrave Macmillan / Springer. ISBN: 978-3-030-02791-9.
- Asness, C.S., Moskowitz, T.J., and Pedersen, L.H. (2013). "Value and Momentum Everywhere." *Journal of Finance*, 68(3), 929-985.
- Ilmanen, A. (2011). *Expected Returns: An Investor's Guide to Harvesting Market Rewards*. Wiley.
- Hsu, J.C., Kalesnik, V., and Viswanathan, V. (2015). "A Framework for Assessing Factors and Implementing Smart Beta Strategies." *Journal of Index Investing*, 6(1), 89-97.
- Arnott, R.D., Harvey, C.R., Kalesnik, V., and Linnainmaa, J.T. (2021). "Reports of Value's Death May Be Greatly Exaggerated." *Financial Analysts Journal*, 77(1), 44-67.
- Coqueret, G. and Guida, T. (2020). *Machine Learning for Factor Investing: R Version*. Chapman and Hall/CRC.

## Implementation Notes

- **Factor Interaction**: Some factors interact positively (value + momentum: negatively correlated, excellent diversifiers) while others overlap (quality + low volatility: moderately correlated, less diversification benefit). Factor selection should prioritize low pairwise correlations.
- **Weighting Schemes**: Equal-weight is the simplest and most robust; risk-parity weights (inverse-volatility) reduce the impact of high-vol factors; optimized weights (maximize Sharpe) are theoretically optimal but prone to overfitting.
- **Turnover Management**: Monthly rebalancing across multiple factors generates significant turnover. Implement turnover buffers (only trade when composite score changes by more than a threshold) and staggered portfolios to manage trading costs.
- **Crypto Adaptation**: A multifactor approach is directly applicable to crypto with sufficient universe breadth (50+ liquid tokens). Candidate crypto factors include: momentum (trailing returns), value (revenue/market-cap), size (market cap), development activity (commits/contributors), and on-chain usage (active addresses, transaction volume).
- **Dynamic Factor Allocation**: Advanced implementations dynamically adjust factor weights based on macroeconomic regime (expansion vs. recession), factor valuations (cheap vs. expensive factors), or factor momentum (trending vs. mean-reverting factors).
- **Capacity**: Multifactor portfolios generally have better capacity than single-factor strategies because factor diversification reduces concentration in any single set of stocks.
