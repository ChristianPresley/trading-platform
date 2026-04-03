# Bollinger Bands Mean Reversion / Breakout

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/bollinger-bands-trading-strategy/)
> **Asset Class**: US Equities (S&P 500 / SPY), Bitcoin
> **Crypto/24-7 Applicable**: Adaptable — Bollinger Bands are widely used in crypto; Bitcoin-specific backtests show strong results
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

Bollinger Bands use a simple moving average with standard deviation envelopes to define dynamic overbought/oversold zones. The mean reversion variant buys when price touches or crosses the lower band and sells on reversion to the mean. Multiple implementations exist: the base %B strategy (Larry Connors), the MACD+Bollinger combination, and the Bollinger Squeeze. Performance varies significantly by variant and asset class, with Bitcoin showing the strongest results.

## Trading Rules

### Connors %B Strategy (Equity)
1. **Calculate Bands**: 20-period SMA, 2 standard deviations (default).
2. **Entry Signal**: Buy at the close when %B (Bollinger Band position) falls below 0.2 for multiple consecutive days.
3. **Exit Signal**: Sell at the close when %B crosses above 0.8.
4. **Regime Filter**: Close must be above the 200-day SMA.

### MACD + Bollinger Bands (Enhanced)
1. **Entry Signal**: Buy when price touches the lower Bollinger Band AND MACD histogram is turning positive.
2. **Exit Signal**: Sell when price touches the upper band or MACD crosses below signal line.
3. **Win Rate**: 78%, average gain 1.4% per trade, max drawdown 15%.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.9 (Connors %B on SPY) |
| CAGR | 4.84% (Connors %B, SPY) / ~50% (Bitcoin variant) |
| Max Drawdown | 16-24% (depending on variant) |
| Win Rate | 75-78% |
| Volatility | Low (invested 10-15% of time on equity) |
| Profit Factor | 1.9 (Connors %B) |
| Rebalancing | Event-driven (signal-based) |

*Note: 677 trades for Connors %B. Bitcoin variant turned $100K into $6.2M with 34% time-in-market. Results vary enormously by variant and asset.*

## Efficacy Rating

**3/5** — Versatile indicator framework with multiple proven variants. The equity mean reversion versions produce consistent but modest returns. The Bitcoin application shows dramatically better results due to crypto's stronger mean-reverting behavior at the daily level. The MACD+Bollinger combination offers the best risk-adjusted equity returns. Loses points for parameter sensitivity and the wide performance range across variants.

## Academic References

- Bollinger, J. — *Bollinger on Bollinger Bands* (2001) — definitive reference
- Connors, L. — *Short Term Trading Strategies That Work* — %B strategy
- Lento, C. — "A Combined Signal Approach to Technical Analysis on the S&P 500" (2008)

## Implementation Notes

- **Variant selection matters**: The base Bollinger Band strategy (buy lower band, sell upper band) is mediocre. Adding MACD confirmation or using Connors' %B approach significantly improves results.
- **Bitcoin opportunity**: The Bitcoin Bollinger Band strategy shows ~50% CAGR with only 34% time-in-market, making it one of the strongest crypto adaptations in this section.
- **Bollinger Squeeze**: The squeeze (bandwidth contraction) signals impending volatility expansion. This is a useful complementary signal but works better for timing than direction.
- **Parameter sensitivity**: Results are sensitive to the lookback period (10 vs 20 vs 30 days) and standard deviation multiplier (1.5 vs 2.0 vs 2.5). Optimize per asset class.
- **Crypto parameters**: For crypto, consider 14-period with 1.5 standard deviations to account for higher baseline volatility.
