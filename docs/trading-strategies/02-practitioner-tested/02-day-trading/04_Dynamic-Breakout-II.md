# Dynamic Breakout II Strategy

> **Source**: [QuantConnect](https://www.quantconnect.com/research/15373/the-dynamic-breakout-ii-strategy/)
> **Asset Class**: Forex (EURUSD, GBPUSD), adaptable to other asset classes
> **Crypto/24-7 Applicable**: Adaptable — adaptive channels work on any liquid asset with sufficient volatility
> **Evidence Tier**: Backtested Only
> **Complexity**: Complex

## Overview

The Dynamic Breakout II strategy uses Bollinger Bands with an adaptive lookback period that adjusts based on current market volatility. When volatility is high, the lookback period shortens (making the bands more responsive); when volatility is low, the lookback period lengthens (making the bands wider and less sensitive). This creates adaptive breakout channels that self-calibrate to market conditions. The strategy was originally designed for forex markets.

## Trading Rules

1. **Measure Volatility**: Calculate the current ATR or standard deviation relative to its recent average.
2. **Adjust Lookback Period**:
   - If current volatility > average volatility: decrease the Bollinger Band lookback period (minimum ~10).
   - If current volatility < average volatility: increase the Bollinger Band lookback period (maximum ~60).
3. **Long Entry**: Buy when the close breaks above the upper Bollinger Band (using the adaptive lookback).
4. **Short Entry**: Sell short when the close breaks below the lower Bollinger Band.
5. **Exit**: Close when price returns inside the bands or crosses the middle line (adaptive SMA).
6. **Stop Loss**: Fixed percentage or ATR-based stop.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.31 (EURUSD, 2010-2016) |
| CAGR | 2.3% (EURUSD) / negative (GBPUSD) |
| Max Drawdown | 14% (EURUSD) / 19% (GBPUSD) |
| Win Rate | ~45% |
| Volatility | Moderate |
| Profit Factor | ~1.2 (EURUSD) |
| Rebalancing | Event-driven (signal-based) |

*Note: Performance varies dramatically by currency pair and market regime. Profitable on EURUSD 2010-2014, with max drawdown occurring May-December 2015. Negative returns on GBPUSD. Works best in trending forex markets.*

## Efficacy Rating

**2/5** — Interesting adaptive concept but disappointing backtest results. The strategy is profitable on EURUSD over a specific period but produces negative returns on GBPUSD, demonstrating high sensitivity to the chosen instrument. The Sharpe ratio of 0.31 is mediocre. The adaptive lookback is a theoretically sound improvement over fixed Bollinger Bands, but the execution does not consistently translate to profits across markets and time periods.

## Academic References

- Bollinger, J. — *Bollinger on Bollinger Bands* (2001) — foundational band theory
- Kaufman, P.J. — *Trading Systems and Methods* (5th Ed., 2013) — adaptive channel systems
- Chan, E. — *Algorithmic Trading* (2013) — adaptive parameter systems

## Implementation Notes

- **Instrument dependency**: The strategy's profitability is highly dependent on the chosen instrument and time period. Do not assume results from one market transfer to another.
- **Adaptive logic**: The core innovation (volatility-adjusted lookback) is sound and can be applied to other band/channel strategies. Consider extracting this concept for use with Keltner Channels or ATR Bands.
- **Regime sensitivity**: Works best in trending markets and poorly in ranging markets. A trend strength filter (ADX > 25) may improve results by avoiding range-bound periods.
- **Crypto adaptation**: The adaptive lookback concept is well-suited to crypto, where volatility regimes shift dramatically. Test on BTC/USD and ETH/USD daily or 4-hour candles with a lookback range of 10-50 periods.
- **Parameter bounds**: The minimum and maximum lookback periods are critical. Too narrow a range (e.g., 15-25) negates the adaptive benefit; too wide (5-100) creates instability.
- **Combination potential**: The adaptive lookback concept is more valuable than the specific strategy. Extract and apply to other channel-based strategies in this collection.
