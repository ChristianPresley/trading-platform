# Doji Strategy

> **Source**: [Quantified Strategies — Doji Candlestick Trading Strategy](https://www.quantifiedstrategies.com/doji-candlestick-trading-strategy/), [Quantified Strategies — Doji Trading Strategies](https://www.quantifiedstrategies.com/doji-trading-strategy/)
> **Asset Class**: Equities (backtested on SPY)
> **Crypto/24-7 Applicable**: Adaptable — doji patterns appear on any OHLC chart, but 24/7 crypto markets generate more noise and lower signal-to-noise ratios for single-candle patterns
> **Evidence Tier**: Backtested Only
> **Complexity**: Simple

## Overview

The doji candlestick is characterized by an open and close at nearly the same price, creating a cross or plus-sign shape that signals market indecision. The strategy treats the doji as a potential reversal signal, particularly after a pullback or trend exhaustion. When price has been declining and a doji forms, it suggests selling pressure is fading and a bounce may follow.

Quantified Strategies found that the doji alone provides a modest edge, but performance improves significantly when combined with a mean-reversion filter such as price being below a short-term moving average. This suggests the doji's value lies not in the candlestick itself but in its role as a confirmation signal within an oversold context. The edge is primarily a mean-reversion phenomenon that the doji helps time.

## Trading Rules

1. **Universe**: SPY (S&P 500 ETF) on daily bars. Applicable to other liquid equities and ETFs.

2. **Identification**: A doji forms when the absolute difference between the open and close is very small relative to the day's range (typically less than 10% of the high-low range).

3. **Basic Entry**: Buy at the close when a doji candle forms.

4. **Filtered Entry (Preferred)**: Buy at the close when a doji candle forms AND the close is below the 10-day simple moving average.

5. **Exit**: Sell when the close crosses above the previous day's high, or after a fixed holding period of 3-5 days.

6. **Position Sizing**: Equal-weight, full position on signal.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.4-0.5 (basic), ~0.6-0.8 (filtered) |
| CAGR | ~3-5% (basic), ~5-7% (filtered, time-in-market adjusted) |
| Max Drawdown | -15% to -20% |
| Win Rate | 80% (basic: 36/45 trades), 88% (filtered: 22/25 trades) |
| Volatility | ~12-15% annualized |
| Profit Factor | ~1.5 (basic), ~2.0 (filtered) |
| Rebalancing | Event-driven (on doji signal) |

The basic doji strategy produced 45 trades with an average gain of 0.76% per trade. With the 10-day moving average filter, trades dropped to 25 but average gain per trade rose to 1.39%. The high win rate reflects the mean-reversion nature of the setup, though the strategy's infrequent signals limit its standalone CAGR contribution.

## Efficacy Rating

**Rating: 2/5** — The doji pattern alone provides a weak and inconsistent edge. Performance improves meaningfully with additional filters, but the strategy generates very few signals (25-45 trades over decades of data), making it impractical as a standalone system. The edge appears to derive from mean-reversion dynamics rather than the candlestick pattern per se, and the results are limited to a single instrument (SPY). Out-of-sample robustness across asset classes is unverified.

## Academic References

- Nison, S. (1991). *Japanese Candlestick Charting Techniques*. New York Institute of Finance.
- Marshall, B. R., Young, M. R., & Rose, L. C. (2006). "Candlestick Technical Trading Strategies: Can They Create Value for Investors?" *Journal of Banking & Finance*, 30(8), 2303-2323.
- Lu, T. H., Shiu, Y. M., & Liu, T. C. (2012). "Profitable Candlestick Trading Strategies — The Evidence from a New Perspective." *Review of Financial Economics*, 21(2), 63-68.

## Implementation Notes

- **Signal Frequency**: Very low. Expect only 1-3 signals per year on daily SPY data, making this unsuitable as a primary strategy. Better used as a supplementary confirmation signal within a broader system.
- **Doji Definition Sensitivity**: Results are sensitive to how strictly the doji is defined. A tolerance of 5-10% of the daily range for the open-close gap is typical, but tighter thresholds reduce signal count further.
- **Mean-Reversion Context**: The filtered version (close below 10-day MA) dramatically outperforms. In implementation, always combine with an oversold or pullback condition rather than trading the doji in isolation.
- **Crypto Adaptation**: On crypto pairs, consider using 4-hour or 1-hour candles to generate more signals. Be cautious of exchange-specific OHLC differences and wick noise in thin order books.
- **Slippage**: Minimal concern since entries are at the close and the strategy targets multi-day holds, but ensure execution within the closing auction for equity implementations.
