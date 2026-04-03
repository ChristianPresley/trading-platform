# Earnings Quality Factor

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: Adaptable — limited applicability; most crypto projects lack traditional earnings statements
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

The earnings quality factor attempts to distinguish between firms with high-quality, sustainable earnings and firms with low-quality, manipulated, or transient earnings. Earnings quality is typically measured through accruals quality -- the degree to which reported earnings are backed by actual cash flows rather than accounting accruals. The foundational insight, building on Sloan (1996) and extended by Dechow and Dichev (2002), is that firms with high accruals relative to cash flows tend to have less persistent earnings, and the market systematically fails to price this difference. However, as a standalone trading factor, earnings quality has delivered disappointing results, with a negative Sharpe ratio in many implementations. The signal is more valuable as a quality screen within broader multi-factor strategies than as a primary alpha source.

## Trading Rules

1. **Universe**: All common stocks on major exchanges with available cash flow and income statement data.
2. **Signal**: At the end of each year, compute an earnings quality score based on the ratio of cash flow from operations to net income (higher is better quality), or alternatively, the Dechow-Dichev accruals quality measure (residual volatility from regressing working capital accruals on past, current, and future cash flows).
3. **Sort**: Rank all stocks by earnings quality score into deciles.
4. **Long Portfolio**: Buy stocks in the top decile (highest earnings quality -- earnings well-supported by cash flows).
5. **Short Portfolio**: Sell short stocks in the bottom decile (lowest earnings quality -- earnings driven by accruals).
6. **Weighting**: Equal-weight positions within each portfolio leg.
7. **Rebalancing**: Annually (after annual reports are available).
8. **Holding Period**: One year, then re-sort and rebalance.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | -0.18 |
| CAGR | ~-3 to -5% (long-short spread) |
| Max Drawdown | ~45-50% |
| Win Rate | ~47% |
| Volatility | 28.7% |
| Profit Factor | ~0.9 |
| Rebalancing | Yearly |

## Efficacy Rating

**2 / 5** -- The earnings quality factor, despite its strong theoretical appeal and intuitive logic, has delivered negative risk-adjusted returns in many backtested implementations. The negative Sharpe ratio (-0.18) combined with very high volatility (28.7%) makes it unattractive as a standalone strategy. The high volatility suggests the signal is noisy and the long-short spread is unreliable. However, earnings quality retains value as a secondary screen or risk management tool within multi-factor portfolios -- it helps avoid firms with accounting red flags even if it does not generate standalone alpha.

## Academic References

- Dechow, P.M. and Dichev, I.D. (2002). "The Quality of Accruals and Earnings: The Role of Accrual Estimation Errors." *The Accounting Review*, 77(Supplement), 35-59.
- Sloan, R.G. (1996). "Do Stock Prices Fully Reflect Information in Accruals and Cash Flows About Future Earnings?" *The Accounting Review*, 71(3), 289-315.
- Francis, J., LaFond, R., Olsson, P., and Schipper, K. (2005). "The Market Pricing of Accruals Quality." *Journal of Accounting and Economics*, 39(2), 295-327.
- Dechow, P.M., Ge, W., and Schrand, C. (2010). "Understanding Earnings Quality: A Review of the Proxies, Their Determinants and Their Consequences." *Journal of Accounting and Economics*, 50(2-3), 344-401.
- Penman, S.H. and Zhang, X.J. (2002). "Accounting Conservatism, the Quality of Earnings, and Stock Returns." *The Accounting Review*, 77(2), 237-264.

## Implementation Notes

- **Signal Noise**: The negative Sharpe ratio suggests the earnings quality signal, as typically constructed, does not reliably predict returns. Consider it a filter rather than an alpha generator.
- **Definition Sensitivity**: Earnings quality can be measured many ways (accruals quality, earnings persistence, predictability, smoothness, timeliness, conservatism). Results are highly sensitive to the specific definition used.
- **Forensic Accounting Approach**: More sophisticated implementations using Beneish M-Score or Piotroski F-Score as quality screens tend to perform better than simple accruals-based measures.
- **Crypto Adaptation**: Most crypto projects lack traditional earnings statements. For DeFi protocols with revenue, one could compare reported protocol metrics to on-chain verifiable cash flows, but the universe is extremely small.
- **Complementary Role**: Best used as a negative screen (avoiding low earnings quality stocks) within value or momentum strategies rather than as a primary signal.
