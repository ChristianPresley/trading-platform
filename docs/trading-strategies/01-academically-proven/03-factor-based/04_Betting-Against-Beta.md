# Betting Against Beta

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading)
> **Asset Class**: Equities (also documented across bonds, credit, commodities, currencies, and crypto)
> **Crypto/24-7 Applicable**: Adaptable — beta sorting and leverage application work in crypto markets
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

The Betting Against Beta (BAB) factor, formalized by Frazzini and Pedersen (2014), exploits the empirical finding that low-beta assets deliver higher risk-adjusted returns than high-beta assets across virtually every asset class studied. The theoretical foundation rests on funding constraints: many investors cannot freely leverage, so they instead tilt toward high-beta assets to achieve their desired return targets. This demand pressure inflates the price of high-beta assets (depressing their future returns) while leaving low-beta assets underpriced. The BAB factor constructs a leveraged long position in low-beta securities and a de-leveraged short position in high-beta securities, producing a market-neutral portfolio that has delivered significant positive alpha. The paper ranks as the third most downloaded in the history of the Journal of Financial Economics.

## Trading Rules

1. **Universe**: All common stocks on major exchanges (the original paper also tests bonds, credit, commodities, and currencies).
2. **Signal**: At the end of each month, estimate the beta of each stock using trailing 12-month daily returns regressed against the market portfolio.
3. **Sort**: Rank all stocks by estimated beta.
4. **Long Portfolio**: Buy low-beta stocks (bottom half or bottom tertile). Lever up to target beta of 1.0.
5. **Short Portfolio**: Sell short high-beta stocks (top half or top tertile). De-lever to target beta of 1.0.
6. **Weighting**: Beta-rank-weighted within each leg; the portfolio is constructed to be market-neutral (net beta of zero).
7. **Rebalancing**: Monthly.
8. **Holding Period**: One month, then re-estimate betas and rebalance.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.594 |
| CAGR | ~10-12% (long-short spread) |
| Max Drawdown | ~35-40% |
| Win Rate | ~55% |
| Volatility | 18.9% |
| Profit Factor | ~1.3 |
| Rebalancing | Monthly |

## Efficacy Rating

**4 / 5** -- The BAB factor represents one of the most intellectually compelling factor strategies, with a clear theoretical mechanism (leverage constraints) and strong empirical support across multiple asset classes and time periods. It receives a 4 rather than 5 due to: (1) the relatively high volatility of the long-short portfolio (18.9%), (2) sensitivity to funding conditions (BAB performs poorly during funding squeezes), and (3) implementation complexity from the leverage/de-leverage structure. The multi-asset class applicability and theoretical grounding make it a valuable component of diversified factor portfolios.

## Academic References

- Frazzini, A. and Pedersen, L.H. (2014). "Betting Against Beta." *Journal of Financial Economics*, 111(1), 1-25.
- Black, F. (1972). "Capital Market Equilibrium with Restricted Borrowing." *Journal of Business*, 45(3), 444-455.
- Baker, M., Bradley, B., and Wurgler, J. (2011). "Benchmarks as Limits to Arbitrage: Understanding the Low-Volatility Anomaly." *Financial Analysts Journal*, 67(1), 40-54.
- Asness, C.S., Frazzini, A., and Pedersen, L.H. (2012). "Leverage Aversion and Risk Parity." *Financial Analysts Journal*, 68(1), 47-59.
- Schneider, P., Wagner, C., and Zechner, J. (2020). "Low-Risk Anomalies?" *Journal of Finance*, 75(5), 2673-2718.

## Implementation Notes

- **Leverage Requirement**: The strategy requires leverage on the low-beta leg, which introduces borrowing costs and margin risk. Implementation must carefully account for these costs.
- **Beta Estimation**: Beta estimates are noisy; consider shrinkage estimators (Vasicek adjustment) or longer estimation windows to reduce estimation error.
- **Funding Conditions**: BAB performs poorly during funding crises (e.g., 2008 deleveraging) when leverage constraints bind tightly across the market. Monitor TED spread and other funding stress indicators.
- **Crypto Adaptation**: In crypto markets, beta can be estimated relative to BTC or a broad crypto index. The leverage constraint mechanism likely applies as many crypto participants face margin constraints. However, shorting costs and liquidation risks in crypto derivatives require careful management.
- **Multi-Asset Application**: The BAB concept extends naturally to cross-asset allocation: overweight low-beta asset classes and underweight high-beta ones, with leverage to equalize risk contributions.
