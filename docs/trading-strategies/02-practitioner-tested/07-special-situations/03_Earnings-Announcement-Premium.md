# Earnings Announcement Premium Strategy

> **Source**: [Awesome Systematic Trading](https://github.com/paperswithbacktest/awesome-systematic-trading), [Quantpedia — Earnings Announcement Premium](https://quantpedia.com/strategies/earnings-announcement-premium), [NBER Working Paper — The Earnings Announcement Premium and Trading Volume](https://www.nber.org/papers/w13090)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: No — requires corporate earnings calendars specific to public equities
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

The earnings announcement premium is the observation that stocks earn significantly higher average returns during the few days surrounding their quarterly earnings announcements compared to non-announcement periods. First documented by Beaver (1968) and more recently quantified by Frazzini and Lamont (2007), the premium is substantial: a portfolio that is long stocks expected to announce earnings in the next month and short all other stocks earns an annualized excess return of approximately 9.9%.

The economic explanation centers on compensation for information risk. Earnings announcements resolve uncertainty about firm fundamentals, and investors demand a premium for holding stocks during these high-uncertainty periods. The strategy capitalizes on this by systematically buying stocks in the days before their scheduled earnings announcement and selling shortly after.

The Awesome Systematic Trading repository documents this strategy with a Sharpe ratio of 0.192 and 3.7% annualized volatility, reflecting a modest but positive edge with remarkably low volatility due to the short holding periods and broad diversification across announcing firms.

## Trading Rules

1. **Universe**: All common stocks on major US exchanges with scheduled quarterly earnings announcements.

2. **Earnings Calendar**: Obtain the expected earnings announcement date for each stock (from Bloomberg, Refinitiv, or Estimize).

3. **Entry**: Buy each stock 5 trading days before its scheduled earnings announcement date.

4. **Exit**: Sell each stock 1 trading day after the earnings announcement.

5. **Portfolio Construction**:
   - Equal-weight all stocks entering the announcement window.
   - At any given time, the portfolio holds stocks approaching their announcement dates.
   - For the long-short version: short an equal-weight portfolio of all stocks NOT in their announcement window.

6. **Rebalancing**: Daily — add new announcers and remove stocks past their post-announcement exit date.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.192 |
| CAGR | ~4-6% (long-only), ~9.9% (long-short) |
| Max Drawdown | -10% to -20% |
| Win Rate | ~53-56% (per announcement trade) |
| Volatility | 3.7% annualized |
| Profit Factor | ~1.2-1.4 |
| Rebalancing | Daily |

The remarkably low volatility (3.7%) results from the strategy's high diversification — at any given time, multiple stocks are in their announcement windows, and each position is held for only 6 trading days. The Sharpe ratio of 0.192 suggests a positive but modest edge. Academic studies find the monthly excess return for the strategy is approximately 60 basis points (over 7% annualized), though implementation costs reduce this in practice.

## Efficacy Rating

**Rating: 3/5** — The earnings announcement premium is one of the more robust anomalies in empirical finance, documented across multiple decades, markets, and sample periods. The economic rationale (compensation for information risk) is well-founded. The deduction reflects: (a) the Sharpe ratio of 0.192 is positive but modest, suggesting implementation costs may erode much of the edge, (b) earnings date estimates can shift, causing premature entry or missed windows, (c) the strategy requires daily portfolio management across hundreds of stocks, adding operational complexity, (d) post-earnings drift and earnings surprises introduce directional risk that the premium may not fully compensate, and (e) no crypto applicability.

## Academic References

- Beaver, W. H. (1968). "The Information Content of Annual Earnings Announcements." *Journal of Accounting Research*, 6, 67-92.
- Frazzini, A., & Lamont, O. A. (2007). "The Earnings Announcement Premium and Trading Volume." NBER Working Paper No. 13090.
- Savor, P., & Wilson, M. (2016). "Earnings Announcements and Systematic Risk." *The Journal of Finance*, 71(1), 83-138.
- Cohen, D. A., Dey, A., Lys, T. Z., & Sunder, S. V. (2007). "Earnings Announcement Premia and the Limits to Arbitrage." *Journal of Accounting and Economics*, 43(2-3), 153-180.
- Barber, B., De George, E. T., Lehavy, R., & Trueman, B. (2013). "The Earnings Announcement Premium Around the Globe." *Journal of Financial Economics*, 108(1), 118-138.

## Implementation Notes

- **Earnings Calendar Accuracy**: The strategy's success depends on accurate earnings date predictions. Use multiple data sources and monitor for date changes. A stock that reports a day early or late can result in either a missed entry or unintended exposure to the actual announcement.
- **Date Estimation Services**: Bloomberg EEDS, Refinitiv I/B/E/S, and Wall Street Horizon provide earnings date estimates. The most accurate services achieve 90%+ accuracy within a 1-day window, but 5-10% of dates shift, requiring daily monitoring.
- **Transaction Costs**: The daily rebalancing across hundreds of stocks generates significant transaction costs. Ensure realistic cost modeling (commissions, spreads, market impact) before deployment. The strategy's low gross return per trade (~10-15 basis points per announcement) leaves little room for slippage.
- **Earnings Surprise Risk**: Individual announcements can produce 5-20% moves in either direction. The strategy relies on the average premium being positive, but individual positions carry significant event risk. Diversification across many simultaneous announcers is essential.
- **Sector and Earnings Clustering**: Earnings season concentrates announcements in specific weeks (typically 2-5 weeks after quarter-end). The portfolio is much larger during earnings season and nearly empty between seasons, creating uneven capital utilization.
- **No Crypto Application**: Cryptocurrency projects do not have standardized earnings reporting cycles. Some crypto projects publish periodic financial reports, but these are too irregular and infrequent to support a systematic strategy.
