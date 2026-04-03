# Top Candlestick Patterns (Ranked by Backtest)

> **Source**: [Quantified Strategies — 10 Best Candlestick Patterns Ranked by Backtest Performance](https://www.quantifiedstrategies.com/candlestick-patterns-ranked-by-backtest/), [Quantified Strategies — Complete Backtest of All 75 Candlestick Patterns](https://www.quantifiedstrategies.com/complete-backtest-of-all-75-candlestick-patterns/)
> **Asset Class**: Equities (backtested on SPY, 1993-present)
> **Crypto/24-7 Applicable**: Adaptable — all patterns are defined by OHLC data and apply to any market, but the original rankings are equity-specific and may not transfer directly to crypto
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

Quantified Strategies systematically coded and backtested all 75 recognized candlestick patterns on SPY using daily OHLCV data from February 1993 through present. Rather than relying on cherry-picked textbook examples, this study ranked every pattern by objective, quantified metrics to determine which patterns actually deliver a measurable trading edge.

The key finding is that most candlestick patterns have little to no predictive power in isolation. However, a small subset consistently generates positive expectancy, particularly when combined into a composite strategy. The top 10 patterns, ranked by backtest performance, demonstrate that the strongest signals tend to be bearish patterns used as bullish entry signals — a counter-intuitive result that aligns with mean-reversion dynamics in equities.

## Trading Rules

1. **Universe**: SPY (S&P 500 ETF) on daily bars. The methodology can be applied to other liquid instruments.

2. **Top 10 Patterns (Ranked)**:
   1. Bearish Engulfing (highest CAR: 5.37%)
   2. Three Outside Down
   3. Dark Cloud Cover
   4. Bullish Piercing Line
   5. Three Inside Up (highest profit factor: 2.5)
   6. Bullish Harami
   7. Neutral Doji
   8. Long-Legged Doji
   9. Bullish Marubozu
   10. Bearish Separating Lines

3. **Entry**: Buy at the close when any of the top-ranked patterns is identified on the daily chart.

4. **Exit**: Sell when the close crosses above the previous day's high.

5. **Combined Strategy (Preferred)**: Use the five best-performing patterns as a single entry rule. Enter when any of the top five patterns triggers; exit on close above prior day's high.

6. **Position Sizing**: Equal-weight, one position at a time.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.5-0.7 (combined top 5) |
| CAGR | ~5-8% (combined top 5, time-in-market adjusted) |
| Max Drawdown | -15% to -20% |
| Win Rate | ~65-75% (varies by pattern) |
| Volatility | ~10-14% annualized |
| Profit Factor | 1.5-2.5 (pattern-dependent; Three Inside Up highest at 2.5) |
| Rebalancing | Event-driven (on pattern signal) |

Individual pattern performance varies widely. The Bearish Engulfing pattern produced the highest compound annual return (5.37%) when used as a bullish mean-reversion entry, while the Three Inside Up achieved the highest profit factor (2.5). The combined top-5 strategy generates more signals and smoother equity curves than any single pattern.

## Efficacy Rating

**Rating: 3/5** — This is the most rigorous quantified analysis of candlestick patterns available, covering all 75 recognized patterns with systematic backtesting rather than anecdotal examples. The combined top-5 approach delivers a genuine, if modest, edge. The deduction reflects that: (a) results are limited to a single instrument (SPY), (b) the edge is moderate in magnitude and likely reflects mean-reversion dynamics more than the patterns themselves, (c) pattern definitions can be subjective and implementation-sensitive, and (d) no out-of-sample validation on other asset classes is provided.

## Academic References

- Marshall, B. R., Young, M. R., & Rose, L. C. (2006). "Candlestick Technical Trading Strategies: Can They Create Value for Investors?" *Journal of Banking & Finance*, 30(8), 2303-2323.
- Nison, S. (1991). *Japanese Candlestick Charting Techniques*. New York Institute of Finance.
- Bulkowski, T. (2008). *Encyclopedia of Candlestick Charts*. John Wiley & Sons.
- Caginalp, G., & Laurent, H. (1998). "The Predictive Power of Price Patterns." *Applied Mathematical Finance*, 5(3-4), 181-205.
- Lu, T. H., Shiu, Y. M., & Liu, T. C. (2012). "Profitable Candlestick Trading Strategies — The Evidence from a New Perspective." *Review of Financial Economics*, 21(2), 63-68.
- Morris, G. (2006). *Candlestick Charting Explained*. McGraw-Hill Education.

## Implementation Notes

- **Counter-Intuitive Signals**: The top-performing patterns are predominantly bearish patterns used as bullish entry signals. This is consistent with mean-reversion: a bearish engulfing pattern after a decline signals capitulation, not further selling. Do not trade these patterns in the direction their names suggest.
- **Exit Importance**: The exit rule (close above prior day's high) is critical to performance. Alternative exits (fixed time, trailing stop) produced notably worse results in the original backtest.
- **Pattern Definition Precision**: Different charting libraries define patterns differently. Small differences in implementation (e.g., how much the body must engulf, whether shadows count) meaningfully affect signal frequency and performance. Use the exact definitions from the Quantified Strategies methodology.
- **Combination Strategy**: The combined top-5 approach is strongly preferred over individual patterns. It generates 3-5x more signals, provides better diversification, and produces smoother equity curves.
- **Crypto Adaptation**: Apply on daily candles with a standardized session boundary. Backtest on the specific crypto pair before trading live, as the ranking of effective patterns may differ from equities due to different market microstructure and mean-reversion characteristics.
- **Beyond SPY**: While the original study only tests SPY, the mean-reversion nature of these signals suggests they may work on other major equity indices and large-cap ETFs. Independent validation is essential before deployment.
