# Opening Range Breakout (ORB)

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/opening-range-breakout-strategy/)
> **Asset Class**: US Equities (S&P 500 / SPY)
> **Crypto/24-7 Applicable**: Adaptable — use session opens (US equity open, Asian open, London open) as synthetic opening ranges for 24/7 markets
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

The Opening Range Breakout (ORB) strategy trades the breakout of the price range established in the first 15-30 minutes of the trading session. The theory is that early trading reflects overnight order flow and institutional positioning, creating a range that, once broken, signals the session's directional bias. While historically popular, Quantified Strategies' recent backtests indicate the basic ORB on S&P 500 has lost most of its edge, and meaningful filters are now required for profitability.

## Trading Rules

### Base Strategy (5-Minute Bars)
1. **Define Opening Range**: Record the high and low of the first 15-30 minutes of the regular trading session (9:30-10:00 AM ET).
2. **Long Entry**: Buy when price breaks above the opening range high.
3. **Short Entry**: Sell short when price breaks below the opening range low.
4. **Stop Loss**: Place stop at the opposite side of the opening range.
5. **Exit**: Close all positions at the end of the trading session (4:00 PM ET) or at a profit target of 1-2x the opening range width.

### Enhanced Strategy (With Filters)
1. Apply a daily trend filter (e.g., price above/below 20-day SMA for directional bias).
2. Add volume confirmation (above-average volume during the range breakout).
3. Use an oversold/overbought daily filter (RSI or similar).

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.3 (base, degraded) |
| CAGR | ~2-4% (base, S&P 500) |
| Max Drawdown | ~15% |
| Win Rate | ~50% (base) / ~60% (with filters) |
| Volatility | Moderate |
| Profit Factor | ~1.1 (base) / ~1.5 (with filters) |
| Rebalancing | Daily (intraday) |

*Note: Average gain per trade is only 0.04% on the base strategy. The strategy's edge has eroded significantly due to crowding. Filters are essential for modern implementation.*

## Efficacy Rating

**3/5** — A historically important strategy that introduced the concept of session-based breakout trading. However, the base version has lost its edge on the S&P 500, with average gains per trade near zero. Rating reflects the potential when combined with smart filters (daily trend, volume, oversold conditions) rather than the degraded base strategy. The conceptual framework remains valuable even if the simple implementation no longer works.

## Academic References

- Crabel, T. — *Day Trading with Short Term Price Patterns and Opening Range Breakout* (1990) — foundational ORB reference
- Fisher, M. — *The Logical Trader* (2002) — ACD method (ORB variant)
- Harris, L. — *Trading and Exchanges* (2003) — market microstructure and session dynamics

## Implementation Notes

- **Edge erosion**: The basic ORB is no longer profitable on S&P 500 as a standalone strategy. The strategy's popularity has eroded its edge through crowding.
- **Filters are mandatory**: Daily trend filters, volume confirmation, and oversold/overbought conditions significantly improve results. Do not implement the base strategy alone.
- **Crypto adaptation**: Define synthetic opening ranges around major session opens (US 9:30 AM ET, London 8:00 AM GMT, Tokyo 9:00 AM JST). The London and US opens tend to produce the most significant ranges in crypto markets.
- **Range width matters**: Wider opening ranges tend to be more reliable breakout signals. Filter for ranges that are above the recent average range width.
- **Risk management**: The opening range width provides a natural stop loss distance. Position size should be calibrated so that a stop-out represents a fixed percentage of capital (e.g., 0.5-1%).
- **Time decay**: ORB signals lose predictive power as the session progresses. If the breakout hasn't occurred by 11:00 AM, the setup is less reliable.
