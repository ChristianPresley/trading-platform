# Accrual Anomaly

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: Adaptable — very limited; requires traditional accounting data
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

The accrual anomaly, first documented by Richard Sloan in his seminal 1996 paper in The Accounting Review, reveals that firms with high levels of accounting accruals (the non-cash component of earnings) subsequently earn lower stock returns, while firms with low accruals earn higher returns. The economic mechanism is straightforward: investors fixate on total earnings without adequately distinguishing between the cash flow and accrual components. Since accruals are less persistent than cash flows (they tend to reverse), firms with high accruals experience future earnings disappointments that drive negative returns. Sloan documented that a long-short strategy based on accruals earned approximately 12% per year. However, subsequent research and out-of-sample testing have shown significant decay in the anomaly, particularly post-publication, with many implementations now showing negative risk-adjusted returns.

## Trading Rules

1. **Universe**: All common stocks on major exchanges with available balance sheet and cash flow statement data.
2. **Signal**: At the end of each year, compute total accruals as: (Change in Current Assets - Change in Cash) - (Change in Current Liabilities - Change in Short-Term Debt - Change in Taxes Payable) - Depreciation. Scale by average total assets.
3. **Sort**: Rank all stocks by scaled accruals into deciles.
4. **Long Portfolio**: Buy stocks in the bottom decile (lowest accruals -- earnings mostly from cash flows).
5. **Short Portfolio**: Sell short stocks in the top decile (highest accruals -- earnings inflated by accounting adjustments).
6. **Weighting**: Equal-weight positions within each portfolio leg.
7. **Rebalancing**: Annually (typically 4-6 months after fiscal year-end to ensure data availability).
8. **Holding Period**: One year, then re-sort and rebalance.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | -0.272 |
| CAGR | ~-4 to -6% (long-short spread, post-publication) |
| Max Drawdown | ~40-50% |
| Win Rate | ~46% |
| Volatility | 13.7% |
| Profit Factor | ~0.85 |
| Rebalancing | Yearly |

## Efficacy Rating

**2 / 5** -- The accrual anomaly holds an important place in the history of accounting-based anomalies and was groundbreaking when published. However, out-of-sample performance has been deeply disappointing, with a negative Sharpe ratio (-0.272) suggesting the anomaly has largely been arbitraged away or was partly a product of the specific sample period. The negative Sharpe indicates that the strategy as traditionally implemented now destroys value. The accrual anomaly's primary utility is historical and pedagogical; practitioners are better served by broader quality composites that incorporate accrual information alongside other metrics.

## Academic References

- Sloan, R.G. (1996). "Do Stock Prices Fully Reflect Information in Accruals and Cash Flows About Future Earnings?" *The Accounting Review*, 71(3), 289-315.
- Richardson, S.A., Sloan, R.G., Soliman, M.T., and Tuna, I. (2005). "Accrual Reliability, Earnings Persistence and Stock Prices." *Journal of Accounting and Economics*, 39(3), 437-485.
- Green, J., Hand, J.R.M., and Zhang, X.F. (2011). "The Supraview of Return Predictive Signals." *Review of Accounting Studies*, 16(1), 1-31.
- Dechow, P.M., Khimich, N.V., and Sloan, R.G. (2011). "The Accrual Anomaly." Working Paper, University of California Berkeley.
- Hirshleifer, D., Hou, K., Teoh, S.H., and Zhang, Y. (2004). "Do Investors Overvalue Firms with Bloated Balance Sheets?" *Journal of Accounting and Economics*, 38, 297-331.

## Implementation Notes

- **Post-Publication Decay**: The accrual anomaly is a textbook case of post-publication decay. Returns have deteriorated significantly since Sloan (1996), likely due to increased awareness among institutional investors and the rise of quantitative strategies that exploit accounting-based signals.
- **Balance Sheet vs. Cash Flow Accruals**: The original Sloan measure uses balance sheet changes; cash flow statement-based accruals (Net Income - Cash Flow from Operations) are simpler and produce similar (though also weak) results.
- **Short Leg Difficulty**: Much of the original anomaly's return came from the short leg (high-accrual stocks declining). Shorting constraints, especially for smaller stocks, limit practical implementation.
- **Crypto Adaptation**: Largely inapplicable to crypto. Most crypto projects do not have traditional accrual accounting. Protocol-level metrics are on-chain and inherently cash-based, eliminating the accrual vs. cash flow distinction.
- **Composite Use**: While the standalone strategy is unprofitable, accrual information remains useful as one input among many in composite quality or forensic accounting screens.
