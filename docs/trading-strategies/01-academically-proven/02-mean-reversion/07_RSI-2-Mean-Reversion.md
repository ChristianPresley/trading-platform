# RSI(2) Mean Reversion

> **Source**: [Quantified Strategies — RSI 2 Strategy](https://www.quantifiedstrategies.com/connors-rsi/), Connors, L. A. & Alvarez, C. (2009). *Short Term Trading Strategies That Work*
> **Asset Class**: Equities / ETFs
> **Crypto/24-7 Applicable**: Adaptable — RSI(2) can be applied to any instrument, though crypto's trending nature may reduce the mean-reversion edge
> **Evidence Tier**: Backtested Only
> **Complexity**: Simple

## Overview

The RSI(2) strategy, developed by Larry Connors and Cesar Alvarez, applies a 2-period Relative Strength Index to identify extreme short-term oversold and overbought conditions. The ultra-short lookback period makes the indicator extremely reactive to recent price action, generating signals when a security has experienced sharp short-term moves that are likely to revert. The strategy buys when the 2-period RSI drops below 10 (deeply oversold) and sells when it rises above 90 (overbought), capturing the short-term mean-reversion tendency in equity markets.

The RSI(2) approach has become one of the most widely cited retail mean-reversion strategies and has demonstrated strong backtested performance across multiple decades and instruments. Connors' original research showed that the lower the RSI(2) reading at entry, the higher the subsequent returns, with entries below 5 producing even better results than entries below 10. A notable and controversial aspect of the strategy is that Connors' testing found that stop-losses actually hurt performance — the strategy relies on mean reversion eventually occurring, and stops prematurely exit positions that would have recovered.

## Trading Rules

1. **Universe**: Liquid equity index ETFs (SPY, QQQ, IWM) or individual large-cap stocks. The strategy works best on instruments with strong daily mean-reversion characteristics.

2. **Trend Filter** (optional but recommended):
   - Only take long trades when the closing price is above the 200-day simple moving average (confirming a long-term uptrend).
   - Only take short trades when the closing price is below the 200-day SMA.

3. **Entry Rules**:
   - **Long Entry**: Buy at the close when the 2-period RSI drops below 10 (or below 5 for more selective entries).
   - **Short Entry**: Sell short at the close when the 2-period RSI rises above 90 (or above 95 for more selective entries).

4. **Exit Rules**:
   - **Primary Exit**: Close long positions when the 2-period RSI rises above 70 (or when price crosses above the 5-day SMA).
   - **Alternative Exit**: Close when the price makes a higher close than the previous day (simpler variant).
   - **No Stop-Loss**: Connors' research found that traditional stop-losses reduce overall performance. Risk is managed through position sizing rather than stops.

5. **Position Sizing**: Fixed percentage of capital per trade (typically 50-100% for index ETFs due to short holding periods, smaller for individual stocks).

6. **Holding Period**: Typically 1-5 trading days. The strategy is designed for very short-term mean reversion.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.8-1.2 (instrument-dependent) |
| CAGR | ~7% (SPY long-only variant) |
| Max Drawdown | -20% to -35% |
| Win Rate | ~70% |
| Volatility | 10-15% annualized |
| Profit Factor | 1.5-2.1 |
| Rebalancing | Daily (event-driven signals) |

The approximately 70% win rate is a standout characteristic — the strategy is right more often than it is wrong, though average losses tend to be larger than average wins. The CAGR of approximately 7% on SPY reflects the fact that the strategy is only invested a fraction of the time (roughly 20-30% of trading days). On a per-trade or time-invested basis, returns are substantially higher.

## Efficacy Rating

**Rating: 4/5** — One of the simplest and most effective short-term mean-reversion strategies available, with strong backtested performance spanning decades. The high win rate makes it psychologically easier to execute than many quantitative strategies. The deduction from a perfect score reflects: the lack of rigorous academic validation (the strategy originates from practitioner research, not peer-reviewed journals), evidence that the edge has partially decayed since the strategy's publication in 2009, the controversial absence of stop-losses which creates tail risk, and the relatively low CAGR when accounting for time out of the market.

## Academic References

- Connors, L. A., & Alvarez, C. (2009). "Short Term Trading Strategies That Work." *TradingMarkets Publishing*.
- Connors, L. A., Alvarez, C., & Radtke, M. (2012). "An Introduction to ConnorsRSI." *Connors Research Trading Strategy Series*.
- Wilder, J. W. (1978). "New Concepts in Technical Trading Systems." *Trend Research*.
- Quantified Strategies (2023). "Connors RSI Trading Strategy: Statistics, Facts, Backtests." *QuantifiedStrategies.com*.

## Implementation Notes

- **RSI Period**: The strategy is specifically designed for a 2-period RSI. Standard 14-period RSI has very different characteristics and does not produce the same mean-reversion signals. Ensure the implementation uses exactly 2 periods.
- **Threshold Sensitivity**: Lower entry thresholds (RSI < 5 vs. RSI < 10) produce fewer trades with higher average returns per trade, but the difference in overall portfolio performance is modest. The choice involves a trade-off between selectivity and opportunity frequency.
- **No Stop-Loss Caveat**: While Connors' research supports no stop-losses for maximizing backtest performance, this is unacceptable for many risk management frameworks. A practical compromise is using a time-based stop (exit after N days regardless) or a portfolio-level drawdown limit rather than individual position stops.
- **Post-Publication Decay**: The strategy was widely publicized after 2009, and some evidence suggests reduced efficacy in subsequent years as more participants adopted the approach. The vanilla strategy has lost some of its edge, though enhanced versions (incorporating market cap filters, multi-instrument diversification) continue to show positive results.
- **Crypto Adaptation**: RSI(2) can be computed on crypto daily bars, but crypto markets exhibit stronger trending behavior than equity indices. The mean-reversion assumption underlying the strategy is weaker in crypto, and deeply oversold readings (RSI < 10) may occur during prolonged drawdowns that do not revert quickly. Consider using crypto-specific thresholds calibrated through walk-forward optimization.
- **Combining with IBS**: RSI(2) and IBS are complementary indicators. Requiring both RSI(2) < 10 AND IBS < 0.2 for entry significantly improves signal quality at the cost of fewer trades. This combined approach has shown improved Sharpe ratios in backtesting.
