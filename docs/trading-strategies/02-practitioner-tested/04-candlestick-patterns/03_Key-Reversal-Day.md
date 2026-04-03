# Key Reversal Day Strategy

> **Source**: [Quantified Strategies — Key Reversal Day Pattern](https://www.quantifiedstrategies.com/key-reversal-day-pattern/), [Quantified Strategies — Reversal Day Trading Strategy](https://www.quantifiedstrategies.com/reversal-day-trading-strategy/)
> **Asset Class**: Equities, Commodities (backtested on Gold, S&P 500)
> **Crypto/24-7 Applicable**: Adaptable — the pattern requires intraday highs/lows which exist in crypto, but the lack of a defined session close reduces the pattern's significance
> **Evidence Tier**: Backtested Only
> **Complexity**: Simple

## Overview

A key reversal day is a high-conviction single-session price action pattern where momentum completely shifts within one trading day. A bullish key reversal occurs when price makes a new lower low (extending a downtrend) but then rallies to close above the previous day's high, signaling an exhaustive selling climax. A bearish key reversal is the mirror: price makes a new higher high but closes below the previous day's low.

Quantified Strategies backtested this pattern and found that the bullish version has significant statistical merit, particularly in Gold. The bearish version, however, consistently underperformed, largely due to the natural "overnight upward drift" that exists in most equity and commodity markets. The pattern works best as a high-conviction filter within a broader mean-reversion or trend-reversal system rather than as a standalone strategy, given its infrequent occurrence.

## Trading Rules

1. **Universe**: Liquid futures, ETFs, or individual stocks. Best documented results on Gold (GLD) and S&P 500 (SPY).

2. **Bullish Key Reversal Identification**:
   - Today's low is below the previous day's low (new multi-day or multi-week low preferred).
   - Today's close is above the previous day's high.
   - Volume is preferably above average (adds conviction).

3. **Bearish Key Reversal Identification**:
   - Today's high is above the previous day's high (new multi-day or multi-week high preferred).
   - Today's close is below the previous day's low.
   - Note: Bearish version has weak backtest results.

4. **Entry**: Buy at the close on a bullish key reversal day.

5. **Exit**: Sell after a fixed holding period (3-10 days) or when price reaches the prior swing high, whichever comes first.

6. **Position Sizing**: Full position on signal. Given the rarity, no overlap management needed.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.3-0.5 (bullish only) |
| CAGR | ~2-4% (limited by signal frequency) |
| Max Drawdown | -15% to -25% |
| Win Rate | ~60-65% (bullish reversals) |
| Volatility | ~12-18% annualized |
| Profit Factor | ~1.3-1.6 (bullish), <1.0 (bearish) |
| Rebalancing | Event-driven (on pattern signal) |

The bullish key reversal day shows a meaningful edge in Gold, with the pattern's statistical significance holding up across multiple decades of data. The bearish pattern does not produce reliable results due to the structural long bias in most markets. Signal frequency is very low, typically yielding only a handful of trades per year on any single instrument.

## Efficacy Rating

**Rating: 2/5** — The bullish key reversal day has genuine statistical merit in specific markets (notably Gold), but severe limitations reduce its practical value: extremely low signal frequency, market-specific results that do not generalize well, asymmetric effectiveness (bullish works, bearish does not), and sensitivity to the exact definition of "new low" and "close above prior high." The pattern is best used as a confirmation filter rather than a standalone strategy.

## Academic References

- Bulkowski, T. (2008). *Encyclopedia of Candlestick Charts*. John Wiley & Sons.
- Schwager, J. D. (1996). *Technical Analysis*. John Wiley & Sons.
- Lo, A. W., Mamaysky, H., & Wang, J. (2000). "Foundations of Technical Analysis: Computational Algorithms, Statistical Inference, and Empirical Implementation." *The Journal of Finance*, 55(4), 1705-1765.
- Lucke, B. (2003). "Are Technical Trading Rules Profitable? Evidence for Head-and-Shoulder Rules." *Applied Economics*, 35(1), 33-40.

## Implementation Notes

- **Market Specificity**: Always re-test on the specific instrument you intend to trade. Results from Gold do not transfer to Forex, equities, or crypto without independent validation.
- **Signal Rarity**: Expect 2-5 signals per year per instrument. To build a more active system, scan across a universe of 20-50 liquid instruments simultaneously.
- **Bullish Bias**: Only trade the bullish key reversal. The bearish version has consistently failed in backtests due to the overnight drift effect. If shorting is desired, combine with other bearish confirmation signals.
- **Volume Confirmation**: Signals coinciding with above-average volume or momentum divergences (RSI, MACD) carry more weight and historically produce larger average gains.
- **Crypto Adaptation**: The concept of "new low followed by close above prior high" translates directly, but define the session boundary carefully (e.g., UTC midnight). Without a natural session close, the pattern's psychological significance is diluted.
- **Combination Strategy**: Most effective when used as a high-conviction filter within a broader mean-reversion system. When a key reversal day coincides with an oversold reading (e.g., RSI below 30), the combined signal is significantly stronger.
