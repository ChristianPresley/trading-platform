# Williams %R Mean Reversion

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/williams-r-trading-strategy/)
> **Asset Class**: US Equities (S&P 500 / SPY, Nasdaq 100 / QQQ)
> **Crypto/24-7 Applicable**: Adaptable — oscillator logic transfers well, but threshold tuning required for crypto volatility
> **Evidence Tier**: Backtested Only
> **Complexity**: Simple

## Overview

Williams %R is a momentum oscillator developed by Larry Williams that measures the current close relative to the high-low range over a lookback period. This strategy exploits deep oversold readings (below -90) as mean reversion entry points, with exits triggered by price strength or the oscillator returning to neutral. Backtests show it outperforms RSI and Stochastics on equivalent setups, with the additional benefit of low market exposure.

## Trading Rules

1. **Lookback Period**: Use a 2-day Williams %R (best performing period in backtests).
2. **Entry Signal**: Buy at the close when Williams %R falls below -90.
3. **Exit Signal**: Sell at the close when either:
   - Today's close is higher than yesterday's high, OR
   - Williams %R closes above -30.
4. **Direction**: Long only.
5. **No regime filter required** in the base version (though adding a 200-day MA filter improves risk-adjusted returns).

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~1.2 (estimated) |
| CAGR | ~8% (SPY, with low time-in-market) |
| Max Drawdown | ~18% |
| Win Rate | 81% |
| Volatility | Low (invested ~20-25% of the time) |
| Profit Factor | 2.0+ |
| Rebalancing | Event-driven (signal-based) |

*Note: Crisis-period returns were exceptional — 98.9% in 2008, 43.3% in 2020, 15.7% in 2022 bear market.*

## Efficacy Rating

**3/5** — Strong win rate, solid profit factor, and excellent crisis-period performance. The low time-in-market (~20-25%) significantly reduces black swan exposure. Outperforms RSI and Stochastics on comparable backtests. Loses a point because raw CAGR is modest and the strategy still requires favorable mean-reverting market conditions.

## Academic References

- Williams, L. — *Long-Term Secrets to Short-Term Trading* (original Williams %R)
- Connors, L. & Raschke, L. — *Street Smarts* (mean reversion oscillator strategies)

## Implementation Notes

- **Lookback optimization**: The 2-day period is optimal for S&P 500. For crypto, test 2-5 day periods on 4-hour or daily candles.
- **Threshold calibration**: -90 entry / -30 exit works for equities. Crypto may need -95 / -20 due to wider oscillator swings.
- **Beats RSI**: In Quantified Strategies' head-to-head tests, Williams %R consistently outperformed RSI and Stochastics on identical entry/exit logic.
- **Crisis alpha**: The strategy generates its best returns during high-volatility selloffs — a desirable property for portfolio construction.
- **Execution**: Close-to-close execution; pre-close order placement recommended.
