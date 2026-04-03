# Reversal During Earnings Announcements

> **Source**: [Awesome Systematic Trading](https://github.com/paperswithbacktest/awesome-systematic-trading), [Quantpedia — Reversal During Earnings Announcements](https://quantpedia.com/strategies/reversal-during-earnings-announcements)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: No — strategy requires corporate earnings announcements, which are exclusive to equities
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

This strategy exploits a well-documented anomaly in which stocks exhibiting extreme price movements in the week prior to an earnings announcement tend to reverse during the announcement window itself. Stocks that have declined sharply before earnings tend to bounce, while stocks that have rallied tend to pull back. The effect is significantly stronger than random short-term reversal, with studies showing a six-fold difference in reversal magnitude during earnings announcements compared to non-announcement periods.

The economic explanation centers on inventory risk and liquidity dynamics. As an earnings announcement approaches, market makers face heightened uncertainty about fundamental value and become less willing to provide liquidity. This causes temporary price dislocations as order flow imbalances push prices away from fundamental value. When the earnings announcement resolves uncertainty, these dislocations correct rapidly. The strategy has been profitable in 40 of the past 42 years studied, demonstrating remarkable consistency.

## Trading Rules

1. **Universe**: All stocks on major exchanges (NYSE, AMEX, NASDAQ) with scheduled earnings announcements. Require minimum market capitalization and daily volume thresholds to ensure tradability.

2. **Pre-Announcement Ranking**: In the 5 trading days before each scheduled earnings announcement, compute each stock's cumulative abnormal return (relative to the market or its sector).

3. **Portfolio Construction**:
   - **Long Portfolio**: Buy stocks in the bottom quintile of pre-announcement returns (stocks that declined the most before earnings).
   - **Short Portfolio**: Sell short stocks in the top quintile of pre-announcement returns (stocks that rallied the most before earnings).
   - Equal-weight positions within each portfolio.

4. **Entry Timing**: Enter positions at the close on the day before the earnings announcement (or as close to the announcement as practical).

5. **Holding Period**: Hold for 1-3 trading days, spanning the earnings announcement window (typically the day before, day of, and day after the announcement).

6. **Exit Rules**: Close all positions at the end of the 3-day announcement window. No discretionary holds beyond this window.

7. **Calendar**: The strategy generates signals throughout the quarter but concentrates activity during earnings seasons (January-February, April-May, July-August, October-November).

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.785 |
| CAGR | ~15-20% (long-short, annualized) |
| Max Drawdown | -20% to -30% |
| Win Rate | 60-65% (per announcement trade) |
| Volatility | 25.7% annualized |
| Profit Factor | 1.4-1.8 |
| Rebalancing | Daily (event-driven) |

The relatively high volatility (25.7%) reflects the concentrated nature of earnings events and the inherent uncertainty around announcements. The Sharpe ratio of 0.785 is strong given the short holding periods and event-driven nature. Average 3-day return on the long-short portfolio is approximately 1.45%.

## Efficacy Rating

**Rating: 4/5** — Highly robust anomaly with strong academic evidence and consistent profitability across decades. The deduction reflects several practical limitations: the strategy is only actionable during earnings seasons (roughly 8-10 weeks per year), requires accurate earnings announcement date data, is sensitive to pre-market and after-hours price moves that are difficult to capture, and involves holding through binary events with elevated overnight risk. The equity-only restriction limits the investable universe.

## Academic References

- So, E. C., & Wang, S. (2014). "News-Driven Return Reversals: Liquidity Provision Ahead of Earnings Announcements." *Journal of Financial Economics*, 114(1), 20-35.
- Jegadeesh, N. (1990). "Evidence of Predictable Behavior of Security Returns." *The Journal of Finance*, 45(3), 881-898.
- Chordia, T., & Shivakumar, L. (2005). "Earnings and Price Momentum." *Journal of Financial Economics*, 80(3), 627-656.
- Bernard, V. L., & Thomas, J. K. (1989). "Post-Earnings-Announcement Drift: Delayed Price Response or Risk Premium?" *Journal of Accounting Research*, 27, 1-36.
- Frazzini, A. (2006). "The Disposition Effect and Underreaction to News." *The Journal of Finance*, 61(4), 2017-2046.

## Implementation Notes

- **Earnings Calendar Data**: Requires a reliable source of scheduled earnings announcement dates. Wall Street Horizon, Estimize, or vendor calendars (Bloomberg, Refinitiv) provide this data. Announced dates can shift, so monitoring for date changes is critical.
- **Execution Timing**: The strategy is sensitive to entry timing. Ideally enter at the close on the day before the announcement, but many earnings are released after hours or pre-market. Limit orders at the next open may be necessary.
- **Overnight Risk**: Holding through earnings announcements inherently involves gap risk. Position sizing should account for the possibility of large overnight moves (5-10%+) against the position.
- **Short-Selling Constraints**: Stocks with high short interest or limited borrow availability before earnings may be difficult or expensive to short. Hard-to-borrow fees can erode returns on the short side.
- **Crypto Applicability**: Not applicable. Cryptocurrencies do not have earnings announcements. Analogous events (protocol upgrades, token unlocks, regulatory decisions) could theoretically exhibit similar reversal patterns, but this has not been rigorously studied.
- **Seasonality**: The strategy is most active during peak earnings season. Capital is idle for significant portions of the quarter, making this strategy best used as a component of a multi-strategy allocation.
