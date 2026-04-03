# Crypto Mean Reversion

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/mean-reversion-trading-strategy/)
> **Asset Class**: Cryptocurrency
> **Crypto/24-7 Applicable**: Yes --- exploits crypto-specific volatility patterns
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

Exploits the tendency of cryptocurrency prices to revert to a mean after extreme short-term moves. When BTC or ETH experiences a sharp deviation from its recent average (measured by Bollinger Bands, RSI, or z-score), the strategy enters a counter-trend position expecting reversion. Crypto markets exhibit high volatility with frequent overreactions driven by retail panic and euphoria, creating mean reversion opportunities on short timeframes. However, the strong trending nature of crypto on longer horizons means this strategy works best on intraday to multi-day timeframes.

## Trading Rules

1. **Mean Calculation**: Compute the 20-period SMA and standard deviation on hourly or 4-hour bars.
2. **Entry (Long)**: Enter long when price drops below the lower Bollinger Band (2 standard deviations below SMA) and RSI(14) is below 30. Alternatively, enter when the z-score of price relative to the 20-period mean falls below -2.0.
3. **Entry (Short)**: Enter short when price rises above the upper Bollinger Band and RSI(14) exceeds 70. Alternatively, when z-score exceeds +2.0.
4. **Exit**: Close position when price reverts to the SMA (z-score returns to 0) or after a fixed holding period (e.g., 24-48 hours).
5. **Stop-Loss**: Hard stop at 3x ATR from entry. This is critical in crypto where trends can persist much further than in traditional markets.
6. **Position Sizing**: Smaller positions than trend-following due to higher per-trade risk. Risk no more than 0.5-1% of portfolio per trade.
7. **Regime Filter**: Only trade mean reversion when a volatility regime indicator (e.g., ADX below 25) suggests a range-bound market. Disable during strong trends.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.6 - 1.2 |
| CAGR | 15% - 40% |
| Max Drawdown | -20% to -35% |
| Win Rate | 60% - 72% |
| Volatility | 25% - 45% annualized |
| Profit Factor | 1.2 - 1.5 |
| Rebalancing | Intraday to multi-day |

## Efficacy Rating

**3/5** --- Mean reversion in crypto is a double-edged sword. The high win rate is appealing, but crypto markets trend more than they mean-revert on most timeframes. The strategy works well in range-bound markets but can suffer catastrophic losses during breakouts and trend continuations. Academic evidence is weaker than for trend following in crypto. The strategy requires careful regime detection and strict stop-losses to avoid holding through a -50% crash. Performance is best on short timeframes (1-hour to 4-hour) where microstructure noise creates reversion opportunities.

## Academic References

- Quantified Strategies. "Mean Reversion Trading Strategies." [Link](https://www.quantifiedstrategies.com/mean-reversion-trading-strategy/)
- Poterba, J. M. & Summers, L. H. (1988). "Mean Reversion in Stock Prices: Evidence and Implications." *Journal of Financial Economics*, 22(1), 27-59.
- Caporale, G. M. & Plastun, A. (2019). "The Day of the Week Effect in the Cryptocurrency Market." *Finance Research Letters*, 31, 258-269.
- Makarov, I. & Schoar, A. (2020). "Trading and Arbitrage in Cryptocurrency Markets." *Journal of Financial Economics*, 135(2), 293-319.

## Implementation Notes

- **Timeframe Sensitivity**: Mean reversion alpha concentrates on shorter timeframes. Daily or weekly mean reversion in crypto is generally unprofitable due to strong trending behavior.
- **Regime Detection**: A critical component. Use ADX, realized volatility ratio, or Hurst exponent to determine whether the market is range-bound (mean-reverting) or trending. Only activate the strategy in mean-reverting regimes.
- **Stop-Loss Discipline**: The occasional large loser (when a "dip" turns into a crash) can erase months of small gains. Hard stops are non-negotiable.
- **Execution**: Limit orders at Bollinger Band levels can improve fill prices and reduce slippage compared to market orders.
- **Pure Zig Implementation**: Bollinger Bands, RSI, and z-score calculations are straightforward in Zig. The regime filter adds moderate complexity but is still basic arithmetic.
- **Correlation with Trend Following**: This strategy is negatively correlated with trend following, making it a good portfolio diversifier when combined with the Crypto Trend Following strategy.
