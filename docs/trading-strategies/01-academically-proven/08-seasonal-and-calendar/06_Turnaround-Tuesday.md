# Turnaround Tuesday

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/turnaround-tuesday/)
> **Asset Class**: Equities (broad indices)
> **Crypto/24-7 Applicable**: Adaptable — crypto markets show day-of-week patterns; Monday weakness exists due to traditional market sentiment spillover, and Tuesday reversals are plausible
> **Evidence Tier**: Backtested Only
> **Complexity**: Simple

## Overview

After a weak Monday, stock markets have a statistically significant tendency to reverse and post positive returns on Tuesday. The effect is attributed to several behavioral and structural mechanisms: weekend pessimism causes overreaction selling on Monday, institutional investors reduce positions on Friday to limit weekend exposure and rebuild on Tuesday, and bad news published over the weekend is fully digested by Monday's close. Since 1980, Tuesday has been the best-performing day of the week for the S&P 500, with an average gain of 0.07%. Removing Tuesday returns from the S&P 500 since 1980 would reduce the cumulative gain from approximately 2,500% to roughly 560%.

## Trading Rules

1. **Universe**: S&P 500 ETF (SPY) or index futures
2. **Condition**: Monday's close is lower than Friday's close (i.e., Monday was a down day)
3. **Entry**: Buy at Monday's close (or Tuesday's open)
4. **Exit**: Sell at Tuesday's close
5. **Position sizing**: Full allocation on confirmed signal days
6. **No trade**: If Monday is positive, no position is taken
7. **Variant (aggressive)**: Buy Monday's close regardless of direction; exit Tuesday's close

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.3-0.5 (varies by period) |
| CAGR | ~3-5% (limited exposure) |
| Max Drawdown | ~8-12% |
| Win Rate | ~58-63% |
| Volatility | ~8-12% |
| Profit Factor | ~1.3-1.5 |
| Rebalancing | Weekly (conditional) |

## Efficacy Rating

**3/5** — Robust backtested performance over 30+ years of data with a clear behavioral rationale. The conditional version (buy only after down Mondays) performs significantly better than the unconditional version. However, the effect may partly be explained by the overnight return premium rather than a true Tuesday-specific anomaly. The strategy's simplicity is both its strength (easy to implement) and weakness (widely known and potentially arbitraged).

## Academic References

- French, K. R. (1980). "Stock Returns and the Weekend Effect." *Journal of Financial Economics*, 8(1), 55-69.
- Gibbons, M. R. & Hess, P. (1981). "Day of the Week Effects and Asset Returns." *Journal of Business*, 54(4), 579-596.
- Quantified Strategies. "The Turnaround Tuesday Trading Strategy." Available at: https://www.quantifiedstrategies.com/turnaround-tuesday/
- Quantified Strategies. "Turnaround Tuesday Strategy: Backtest, Trading Rules, and Performance." Available at: https://www.quantifiedstrategies.com/turnaround-tuesday-strategy/

## Implementation Notes

- **Execution**: Monday close execution is straightforward with futures; ETF traders can use market-on-close orders
- **Signal quality**: Larger Monday declines tend to produce stronger Tuesday reversals; consider sizing proportionally to Monday's drawdown
- **Overnight effect caveat**: Research suggests much of the Tuesday reversal occurs in the overnight session (Monday close to Tuesday open); intraday-only Tuesday returns are weaker
- **Crypto adaptation**: BTC and ETH show detectable day-of-week patterns, though they differ from equities due to 24/7 trading; the Monday weakness effect exists partly because crypto reacts to weekend institutional absence; test the signal using Monday 00:00 UTC to Tuesday 00:00 UTC or aligned to U.S. market hours
- **Combining signals**: Overlay with VIX levels (stronger effect when VIX is elevated) or RSI (stronger after oversold Mondays) for improved signal quality
- **Risk**: Single-day holding periods are vulnerable to gap risk from overnight news events
