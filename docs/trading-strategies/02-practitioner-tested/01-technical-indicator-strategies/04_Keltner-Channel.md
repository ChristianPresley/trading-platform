# Keltner Channel Strategy

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/keltner-bands-trading-strategies/)
> **Asset Class**: US Equities (S&P 500 / SPY, Nasdaq 100 / QQQ)
> **Crypto/24-7 Applicable**: Adaptable — ATR-based channels work on any asset with measurable volatility, but parameters need recalibration
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

Keltner Channels are volatility envelopes set above and below an exponential moving average, using the Average True Range (ATR) as the band width. The strategy exploits mean reversion when price touches or crosses the lower band, signaling a temporary oversold condition. It can also be used as a momentum/breakout strategy when price breaks above the upper band. Backtests show stronger results on Nasdaq (QQQ) compared to S&P 500 (SPY).

## Trading Rules

### Mean Reversion Variant (Primary)
1. **Calculate Channels**: EMA period = 6 days, ATR multiplier = 1.3.
2. **Entry Signal**: Buy at the close when the close drops below the lower Keltner Channel band.
3. **Exit Signal**: Sell at the close when the close crosses above the middle line (EMA).
4. **Direction**: Long only.

### Momentum/Breakout Variant
1. **Entry Signal**: Buy at the close when the close breaks above the upper Keltner Channel band.
2. **Exit Signal**: Sell when price falls back below the middle line.
3. **Performance**: Lower CAGR (~4.7%) with 158 trades on S&P 500.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.7 (estimated) |
| CAGR | 6.3% (mean reversion, SPY) |
| Max Drawdown | ~22% |
| Win Rate | 77-80% |
| Volatility | Low (invested ~15% of the time) |
| Profit Factor | 2.0 |
| Rebalancing | Event-driven (signal-based) |

*Note: 288 trades in backtest. Optimal parameters cluster around 6-10 day periods and 1.0-1.5 ATR multiplier. Performance has declined post-2016.*

## Efficacy Rating

**2/5** — Solid win rate and respectable profit factor, but modest CAGR (6.3%) and declining performance in recent years are concerns. The mean reversion variant outperforms the breakout variant. Works slightly better on QQQ than SPY. The post-2016 performance degradation suggests the edge may be eroding.

## Academic References

- Keltner, C. — *How to Make Money in Commodities* (1960) — original Keltner Channel
- Chande, T. — Modernized Keltner Channel with ATR (replacing original range calculation)
- Connors, L. — Mean reversion frameworks for channel-based indicators

## Implementation Notes

- **Parameter sensitivity**: Best results with 6-10 day EMA and 1.0-1.5 ATR multiplier. Wider multipliers reduce trade frequency but may improve average gain per trade.
- **Declining edge**: Performance has weakened post-2016, possibly due to changed market microstructure or strategy crowding. Monitor out-of-sample results carefully.
- **QQQ preference**: The strategy performs better on Nasdaq 100 than S&P 500, suggesting it favors higher-beta assets.
- **Crypto adaptation**: For crypto, test 4-8 period EMA on 4-hour candles with 1.0-2.0 ATR multiplier. Higher crypto volatility will naturally widen the channels.
- **Complementary use**: The low time-in-market (15%) makes this suitable as one component in a multi-strategy portfolio.
