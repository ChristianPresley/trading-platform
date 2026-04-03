# Style Rotation Strategy

> **Source**: [Awesome Systematic Trading](https://github.com/paperswithbacktest/awesome-systematic-trading), [Quantpedia — Momentum Factor and Style Rotation Effect](https://quantpedia.com/strategies/momentum-factor-and-style-rotation-effect)
> **Asset Class**: Equities (Style ETFs)
> **Crypto/24-7 Applicable**: No — requires style-specific equity ETFs with no crypto equivalent
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

Style rotation attempts to time the cyclical performance shifts between equity investment styles — primarily growth versus value, and large-cap versus small-cap. The strategy uses momentum signals to rotate capital between style ETFs, buying the style that has recently outperformed and avoiding the one that has lagged.

Academic research on style rotation produces mixed results. The Awesome Systematic Trading repository documents a backtest with a Sharpe ratio of -0.056, indicating that value/growth rotation based on momentum is not reliably profitable. However, research from Quantpedia shows that small-cap/large-cap rotation using momentum is profitable, suggesting the edge depends heavily on which style dimension is being timed. The negative Sharpe for growth/value rotation may reflect the difficulty of timing the famously unpredictable value-growth cycle, which can persist for years in one direction before reversing.

## Trading Rules

1. **Universe**: Style ETFs representing the major equity style exposures:
   - **Growth vs. Value**: IWF (Russell 1000 Growth) vs. IWD (Russell 1000 Value), or VUG vs. VTV.
   - **Large vs. Small**: IWB (Russell 1000) vs. IWM (Russell 2000), or SPY vs. IWM.

2. **Ranking**: At the end of each month, compare the total return of each style pair over the past 6-12 months.

3. **Allocation**: Invest 100% of capital in the outperforming style. For the two-dimensional version, allocate across both axes (e.g., small-cap growth, large-cap value).

4. **Rebalancing**: Monthly, on the last trading day.

5. **Neutral Option**: If the performance differential between styles is below a threshold (e.g., less than 2% over the lookback period), hold an equal-weight allocation or move to a broad market ETF.

6. **Holding**: Hold the selected style ETF(s) for the full month.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | -0.056 (growth/value rotation) |
| CAGR | ~2-4% (growth/value), ~6-8% (size rotation) |
| Max Drawdown | -25% to -35% |
| Win Rate | ~48-50% (growth/value), ~53-55% (size rotation) |
| Volatility | 10% annualized |
| Profit Factor | ~0.9-1.0 (growth/value), ~1.2-1.4 (size rotation) |
| Rebalancing | Monthly |

The Sharpe ratio of -0.056 for growth/value rotation indicates the strategy does not generate a positive risk-adjusted return on this dimension. The value-growth cycle is notoriously difficult to time: value underperformed growth for over a decade (2010-2020), then sharply outperformed in 2021-2022, then reversed again. Momentum-based rotation captures some of these moves but generates too many whipsaw trades at turning points. Size rotation (small vs. large) shows more promise, with research suggesting momentum-based size rotation is profitable at realistic transaction cost levels.

## Efficacy Rating

**Rating: 2/5** — Style rotation on the growth/value axis has a negative expected Sharpe ratio, making it worse than a passive allocation. The deduction is severe because: (a) the primary growth/value rotation is unprofitable based on available evidence, (b) style cycles persist for long periods (sometimes 10+ years), making momentum an unreliable timing signal, (c) the modest edge in size rotation is small and may not survive transaction costs and taxes in practice, and (d) simpler strategies (equal-weight across styles, or broad market indexing) achieve similar or better risk-adjusted returns with zero complexity. The strategy retains a 2/5 rather than 1/5 because the size rotation dimension does show some promise.

## Academic References

- Fama, E. F., & French, K. R. (1993). "Common Risk Factors in the Returns on Stocks and Bonds." *Journal of Financial Economics*, 33(1), 3-56.
- Asness, C. S., Friedman, J. A., Krail, R. J., & Liew, J. M. (2000). "Style Timing: Value versus Growth." *The Journal of Portfolio Management*, 26(3), 50-60.
- Levis, M., & Liodakis, M. (1999). "The Profitability of Style Rotation Strategies in the United Kingdom." *The Journal of Portfolio Management*, 26(1), 73-86.
- Barberis, N., & Shleifer, A. (2003). "Style Investing." *Journal of Financial Economics*, 68(2), 161-199.
- Arnott, R. D., Kalesnik, V., & Wu, L. (2018). "The Folly of Hiring Winners and Firing Losers." *The Journal of Portfolio Management*, 45(1), 58-72.

## Implementation Notes

- **Avoid Growth/Value Timing**: The evidence strongly suggests that momentum-based growth/value rotation does not work. If exposed to both styles, an equal-weight or strategic allocation is preferred. The urge to time this dimension should be resisted.
- **Size Rotation Has More Promise**: If implementing style rotation, focus on the size dimension (small-cap vs. large-cap) where momentum signals have shown modest but positive returns in research.
- **Long Cycles**: Style cycles can persist for 5-15 years (e.g., growth's dominance from 2010-2020). A momentum strategy with a 6-12 month lookback will correctly ride the middle of these cycles but will generate costly whipsaw at turning points. Accept that timing the turns is not reliably possible.
- **Quantitative vs. Momentum Rotation**: Research from Quantpedia distinguishes between momentum-based rotation (use past returns to predict future) and quantitative rotation (use macro/fundamental indicators). Quantitative approaches show a slight edge over pure momentum for style timing.
- **No Crypto Application**: The growth/value and large/small style framework is specific to equity factor investing and does not have meaningful crypto equivalents. Crypto sector rotation (L1 vs. DeFi vs. infrastructure) is conceptually different from style rotation.
- **Simplicity Alternative**: An equal-weight allocation across IWF, IWD, IWB, and IWM, rebalanced quarterly, has historically achieved comparable or better risk-adjusted returns than any rotation approach, with zero prediction required.
