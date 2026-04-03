# Holiday Effects

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/) / [Quantpedia](https://quantpedia.com/strategies/pre-holiday-effect/)
> **Asset Class**: Equities (broad indices)
> **Crypto/24-7 Applicable**: Adaptable — crypto does not close for holidays, but reduced liquidity and sentiment shifts around U.S. holidays create detectable patterns
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

Stock returns on the trading day immediately preceding market holidays (New Year's, Presidents' Day, Good Friday, Memorial Day, July 4th, Labor Day, Thanksgiving, Christmas) are abnormally high, averaging 9 to 14 times the mean return of ordinary trading days. Ariel (1990) documented that over one-third of the total market return from 1963-1982 was earned on just eight pre-holiday trading days per year. The effect has been confirmed internationally by Kim and Park (1994) and across 90 years of DJIA data by Lakonishok and Smidt (1988).

## Trading Rules

1. **Universe**: S&P 500 ETF (SPY) or equity index futures
2. **Holiday calendar**: New Year's Day, Martin Luther King Jr. Day, Presidents' Day, Good Friday, Memorial Day, Independence Day, Labor Day, Thanksgiving, Christmas
3. **Entry**: Buy at the close of the trading day two days before the holiday (T-2) or at the open of the day before the holiday (T-1)
4. **Exit**: Sell at the close of the pre-holiday trading day (T-1) or at the open of the first post-holiday trading day
5. **Extended variant**: Hold from T-1 close through T+1 close (capturing both pre- and post-holiday drift)
6. **Position sizing**: Full allocation on pre-holiday days; cash otherwise
7. **Best holidays**: Thanksgiving, Christmas, and Independence Day historically show the strongest pre-holiday effects

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.3-0.5 (varies by holiday) |
| CAGR | ~2-4% (8-9 trading days/year) |
| Max Drawdown | ~5-8% |
| Win Rate | ~65-75% |
| Volatility | ~4-7% |
| Profit Factor | ~1.5-2.0 |
| Rebalancing | Daily (around holiday dates) |

## Efficacy Rating

**3/5** — One of the most statistically robust calendar anomalies, with high win rates and a clear behavioral explanation (pre-holiday optimism, short-covering, reduced selling pressure). The effect persists across decades and international markets. However, the limited number of trading opportunities (8-9 per year) constrains absolute returns. Some research suggests the pre-holiday premium has diminished in recent decades (Ko et al., 2021).

## Academic References

- Ariel, R. A. (1990). "High Stock Returns Before Holidays: Existence and Evidence on Possible Causes." *Journal of Finance*, 45(5), 1611-1626.
- Lakonishok, J. & Smidt, S. (1988). "Are Seasonal Anomalies Real? A Ninety-Year Perspective." *Review of Financial Studies*, 1(4), 403-425.
- Kim, C. W. & Park, J. (1994). "Holiday Effects and Stock Returns: Further Evidence." *Journal of Financial and Quantitative Analysis*, 29(1), 145-157.
- Ko, K., Lee, I., & Yun, K. (2021). "The Pre-Holiday Premium of Ariel (1990) Has Largely Disappeared." *Critical Finance Review*.
- Meneu, V. & Pardo, A. (2004). "Pre-Holiday Effect, Large Trades and Small Investor Behaviour." *Journal of Empirical Finance*, 11(2), 231-246.

## Implementation Notes

- **Holiday calendar maintenance**: Ensure the holiday calendar is accurate and updated for exchange-specific closures; international markets have different holiday schedules
- **Thin markets**: Pre-holiday sessions often have reduced volume and wider spreads; use limit orders rather than market orders
- **Post-holiday continuation**: Some studies find positive drift continues into the first post-holiday session; extending the holding period to T+1 may capture additional alpha
- **Crypto adaptation**: While crypto markets trade 24/7, U.S. holidays reduce institutional participation and liquidity; test for pre-holiday patterns in BTC/ETH aligned to U.S. market holidays; reduced sell pressure from institutional desks may create upward drift similar to equities
- **Combining signals**: The pre-holiday effect stacks well with turn-of-month when holidays fall near month boundaries (e.g., New Year's, Independence Day near month-end)
- **Diminishing returns**: Ko et al. (2021) present evidence that the pre-holiday premium has weakened significantly post-publication; out-of-sample validation is important
