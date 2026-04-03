# Triple RSI Strategy

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/triple-rsi-trading-strategy/)
> **Asset Class**: US Equities (S&P 500 / SPY)
> **Crypto/24-7 Applicable**: Adaptable — RSI is asset-agnostic but parameters need recalibration for higher crypto volatility
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

The Triple RSI strategy combines three RSI indicators with different lookback periods (3-day, 7-day, and 14-day) to generate high-probability mean reversion signals. The core thesis is that when all three timeframes simultaneously indicate oversold conditions, a reversion to the mean is highly likely. A 200-day moving average acts as a regime filter to keep trades aligned with the prevailing trend.

## Trading Rules

1. **Regime Filter**: The close must be above the 200-day simple moving average (bullish regime).
2. **Entry Signal**: Buy at the close when all three RSI values (3-day, 7-day, and 14-day) are below 30 (oversold).
3. **Exit Signal**: Sell at the close when the 3-day RSI crosses above 70 (overbought).
4. **Position Sizing**: Full allocation per signal (original backtest uses 100% equity).
5. **Direction**: Long only.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~1.5 (estimated from risk-adjusted returns) |
| CAGR | ~7% (SPY, 1993-2023) |
| Max Drawdown | ~15% |
| Win Rate | 90.36% |
| Volatility | Low (invested ~5% of the time) |
| Profit Factor | 5.0 |
| Rebalancing | Event-driven (signal-based) |

*Note: Only 83 trades since 1993. Average gain per trade is 1.4%. Backtest excludes commissions, slippage, and taxes.*

## Efficacy Rating

**3/5** — Exceptionally high win rate and profit factor, but the very low trade frequency (83 trades over 30 years) limits practical utility and makes statistical significance marginal. Works best as a component in a portfolio of strategies rather than standalone.

## Academic References

- Connors, L. & Alvarez, C. — *Short Term Trading Strategies That Work* (RSI mean reversion foundations)
- Wilder, J.W. — *New Concepts in Technical Trading Systems* (1978) — original RSI definition

## Implementation Notes

- **Parameter sensitivity**: The 30/70 RSI thresholds are standard but should be validated on crypto with wider thresholds (e.g., 20/80) given higher baseline volatility.
- **Lookback alignment**: The 3/7/14-day RSI periods map to natural market cycles in equities. For crypto, consider 2/5/10 on 4-hour candles.
- **Regime filter**: The 200-day MA is critical; removing it degrades performance significantly.
- **Execution**: Signals trigger at the close, so implementation requires pre-close order placement or acceptance of next-open slippage.
- **Low frequency**: This strategy fires rarely. Pair it with complementary strategies to maintain portfolio activity.
