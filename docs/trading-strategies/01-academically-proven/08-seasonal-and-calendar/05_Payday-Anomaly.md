# Payday Anomaly

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading) / [Quantpedia](https://quantpedia.com/strategies/payday-anomaly)
> **Asset Class**: Equities (broad indices)
> **Crypto/24-7 Applicable**: No — the mechanism (salary-driven investment flows) is specific to traditional equity markets with retirement account contributions
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

Stock market returns spike around common payday dates, particularly the 1st, 2nd, and 16th of each month. The effect arises because a significant proportion of U.S. workers receive semi-monthly paychecks, and a portion of those wages flows automatically into retirement accounts (401(k) plans) which are then invested in equity index funds. Ma and Pratt (2018) document that the 16th of the month is the third-best-performing calendar day, and its ranking has improved monotonically each decade since the 1950s as more employers adopted semi-monthly pay schedules.

## Trading Rules

1. **Universe**: S&P 500 ETF (SPY) or equity index futures
2. **Entry**: Buy at the close on the 15th calendar day of each month (or the preceding trading day if the 15th falls on a weekend/holiday)
3. **Exit**: Sell at the close on the 17th calendar day (or following trading day)
4. **Secondary window**: Also buy at the close on the last trading day of the month; sell at the close on the 2nd calendar day of the new month
5. **Position sizing**: Full allocation during payday windows; cash otherwise
6. **No short component**: Strategy captures the positive drift only

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.269 |
| CAGR | ~3-5% (limited exposure days) |
| Max Drawdown | ~10-15% |
| Win Rate | ~55-58% |
| Volatility | 3.8% |
| Profit Factor | ~1.2 |
| Rebalancing | Daily (around payday dates) |

## Efficacy Rating

**2/5** — Statistically detectable but economically marginal. The Sharpe ratio of 0.269 is below the threshold for standalone viability after transaction costs. The effect overlaps significantly with the turn-of-month anomaly (the month-end payday window is essentially the same signal). The mid-month component adds incremental value but is small. The shift from semi-monthly to bi-weekly pay schedules at many firms may weaken the mid-month signal over time.

## Academic References

- Ma, A. & Pratt, W. R. (2018). "Payday Anomaly." Working Paper, SSRN. Available at: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3257064
- Lakonishok, J. & Smidt, S. (1988). "Are Seasonal Anomalies Real? A Ninety-Year Perspective." *Review of Financial Studies*, 1(4), 403-425.
- Ogden, J. P. (1990). "Turn-of-Month Evaluations of Liquid Profits and Stock Returns: A Common Explanation for the Monthly and January Effects." *Journal of Finance*, 45(4), 1259-1272.

## Implementation Notes

- **Overlap with turn-of-month**: The month-end payday window is largely captured by the turn-of-month strategy; the marginal contribution is the mid-month (15th-16th) window
- **Transaction costs**: Four round trips per month for both windows; given the small per-trade alpha, costs can easily consume the edge
- **Pay schedule evolution**: As more firms shift to bi-weekly pay (every other Friday), the mid-month signal may dissipate since paydays no longer cluster on fixed calendar dates
- **Standalone viability**: Not recommended as a standalone strategy; better used as a timing overlay that confirms entry signals from other strategies
- **Data sensitivity**: Results are sensitive to the exact day definition and whether calendar vs. trading days are used
