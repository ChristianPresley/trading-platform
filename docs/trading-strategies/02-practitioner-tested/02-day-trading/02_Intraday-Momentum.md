# Intraday Momentum Strategy

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/intraday-momentum-trading-strategy/)
> **Asset Class**: US Equities (S&P 500 / SPY, Nasdaq 100 / QQQ)
> **Crypto/24-7 Applicable**: Adaptable — the first-half-hour momentum effect has analogues in crypto around major session opens
> **Evidence Tier**: Backtested Only
> **Complexity**: Simple

## Overview

The intraday momentum strategy exploits the empirical finding that the return in the first 30 minutes of trading (from prior close to 10:00 AM ET) has a statistically and economically significant positive correlation with the return in the last 30 minutes of trading (3:30-4:00 PM ET). If the first half-hour return is positive, the strategy goes long for the final half-hour; if negative, it goes short. The effect is amplified on FOMC announcement days.

## Trading Rules

1. **Measure First Half-Hour Return**: Calculate the return from the prior day's close to 10:00 AM ET.
2. **Direction Decision**:
   - If first half-hour return is positive: go long at 3:30 PM ET.
   - If first half-hour return is negative: go short at 3:30 PM ET.
3. **Exit**: Close the position at 4:00 PM ET (market close).
4. **Holding Period**: 30 minutes.
5. **No stop loss** in the base version (30-minute holding period limits downside).

### Enhanced Version (Full Day)
1. **Entry**: Open position at 10:00 AM ET based on first half-hour direction.
2. **Exit**: Close at 4:00 PM ET.
3. **Performance**: 19.6% annualized return, Sharpe 1.33 (May 2007 - early 2024).

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 1.08 (base) / 1.33 (enhanced) |
| CAGR | 6.67% (base) / 19.6% (enhanced) |
| Max Drawdown | ~12% (base) / ~20% (enhanced) |
| Win Rate | ~53% |
| Volatility | Moderate |
| Profit Factor | ~1.4 (base) / ~1.8 (enhanced) |
| Rebalancing | Daily (intraday) |

*Note: Base strategy beats buy-and-hold Sharpe (0.29) by 3.7x. FOMC days show R-squared of 11% and 20.04% annualized return. Enhanced version returned 1,985% total over 17 years.*

## Efficacy Rating

**3/5** — Strong academic foundation with a clear, documented persistence effect. The base last-30-minutes variant is capital-efficient and simple to implement. The enhanced full-day version shows impressive 19.6% annualized returns with a 1.33 Sharpe ratio. The strategy benefits from FOMC days disproportionately. Main concerns: the win rate is barely above 50%, and the edge relies on microstructure effects that could shift with market structure changes.

## Academic References

- Gao, L., Han, Y., Li, S.Z. & Zhou, G. — "Market Intraday Momentum" (Journal of Financial Economics, 2018) — foundational paper documenting the first-half-hour predictive effect
- Elaut, G. et al. — "Intraday Momentum in FX Markets" (2018)
- Heston, S., Korajczyk, R. & Sadka, R. — "Intraday Patterns in the Cross-Section of Stock Returns" (2010)

## Implementation Notes

- **FOMC amplification**: The effect is dramatically stronger on FOMC announcement days (R-squared 11%, annualized return 20%). Consider increasing position size on FOMC days.
- **Transaction costs**: The base variant (30-minute hold, daily frequency) requires low commissions and tight spreads to be profitable after costs.
- **Enhanced version**: The full-day hold (10:00 AM to 4:00 PM) dramatically improves returns (19.6% CAGR) and is more practical for most implementations due to fewer round-trips.
- **Crypto adaptation**: Apply around major session opens. Measure the first-hour return after US equity open (9:30 AM ET) and use it to predict direction for the remaining US trading hours. The effect may also exist around Asian and European session opens.
- **Market microstructure**: The first-half-hour effect is attributed to informed trading and order flow patterns. Changes in market structure (dark pools, algorithmic trading) could erode this edge over time.
- **Risk management**: The short holding period naturally limits risk, but position sizing should still account for the ~53% win rate (barely above coin flip).
