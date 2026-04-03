# Golden Cross (50/200 SMA Crossover)

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/golden-cross-trading-strategy/)
> **Asset Class**: US Equities (S&P 500)
> **Crypto/24-7 Applicable**: Adaptable — widely used in crypto, but the long lookback periods (200 days) require sufficient price history
> **Evidence Tier**: Backtested Only
> **Complexity**: Simple

## Overview

The Golden Cross strategy is one of the most well-known trend-following signals: go long when the 50-day SMA crosses above the 200-day SMA (golden cross) and exit when the 50-day SMA crosses below the 200-day SMA (death cross). It is a slow, position-trading approach that generates very few signals but captures major trend regimes while reducing maximum drawdown by roughly half compared to buy-and-hold.

## Trading Rules

1. **Calculate Moving Averages**: 50-day SMA and 200-day SMA.
2. **Entry Signal (Golden Cross)**: Buy at the close when the 50-day SMA crosses above the 200-day SMA.
3. **Exit Signal (Death Cross)**: Sell at the close when the 50-day SMA crosses below the 200-day SMA.
4. **Direction**: Long only.
5. **Position Sizing**: Full allocation during golden cross regime.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.6 (raw), ~0.8 (risk-adjusted for time-in-market) |
| CAGR | ~6.7% (S&P 500, 1960-2026) |
| Max Drawdown | 33% (vs 56% buy-and-hold) |
| Win Rate | 79% |
| Volatility | Lower than buy-and-hold (invested ~70% of the time) |
| Profit Factor | ~2.5 |
| Rebalancing | Event-driven (very infrequent) |

*Note: Only 33 signals over 66 years. Average trade duration ~350 days. $100K grew to $7.2M (without dividends reinvested). Risk-adjusted return is 9.6% when accounting for 70% time-in-market.*

## Efficacy Rating

**3/5** — The quintessential trend-following benchmark. The main value is not outperformance on raw CAGR (it slightly trails buy-and-hold) but the 50% reduction in max drawdown. The 79% win rate is strong, but with only 33 signals in 66 years, statistical power is limited. Best used as a regime filter or portfolio overlay rather than a standalone strategy.

## Academic References

- Brock, W. et al. — "Simple Technical Trading Rules and the Stochastic Properties of Stock Returns" (1992)
- Faber, M. — "A Quantitative Approach to Tactical Asset Allocation" (2007)
- Glabadanidis, P. — "Market Timing with Moving Averages" (2015)

## Implementation Notes

- **Extremely low frequency**: 33 trades in 66 years means this is a regime indicator, not a trading strategy in the traditional sense. Use it as a filter for other strategies.
- **Drawdown reduction**: The primary value proposition. Cutting max drawdown from 56% to 33% is significant for portfolio risk management.
- **Dividend impact**: The backtest excludes reinvested dividends. Including them would improve absolute returns substantially.
- **Whipsaw periods**: The strategy underperforms in choppy, trendless markets where the SMAs repeatedly cross. These periods are infrequent but painful.
- **Crypto adaptation**: Bitcoin has shown strong golden cross signals historically, but the 200-day lookback requires at least 1 year of price data. Consider 21/100 SMA for faster crypto signals.
- **Regime overlay**: Use the golden/death cross state as a binary filter for other strategies (e.g., only take mean reversion longs when in a golden cross regime).
