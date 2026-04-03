# ETF Rotation Strategy

> **Source**: [Quantified Strategies — ETF Rotation Strategy](https://www.quantifiedstrategies.com/etf-rotation-strategy/), [Quantified Strategies — Monthly Momentum Strategy](https://www.quantifiedstrategies.com/a-monthly-momentum-strategy-in-etfs/)
> **Asset Class**: Equities (ETFs)
> **Crypto/24-7 Applicable**: Adaptable — the rotation concept can be applied to crypto sectors (L1s, DeFi, NFTs, infrastructure tokens) using a momentum ranking of sector-representative tokens
> **Evidence Tier**: Backtested Only
> **Complexity**: Simple

## Overview

ETF rotation ranks a set of sector or asset-class ETFs by relative momentum and allocates capital to the top-performing ETF(s) each month. The strategy exploits the well-documented cross-sectional momentum effect: assets that have outperformed recently tend to continue outperforming in the near term. By continuously rotating into the strongest sector, the strategy aims to capture sector trends while avoiding or underweighting declining sectors.

Quantified Strategies backtested a rotation strategy using SPY (US equities), TLT (long-term bonds), and EEM (emerging markets), ranking by 1-month performance and holding the best performer for the subsequent month. Since inception, the strategy achieved an 11% CAGR, beating buy-and-hold with lower drawdowns for most of the test period. The approach struggled in 2022 when all three asset classes declined simultaneously, highlighting the strategy's vulnerability to correlated drawdowns.

## Trading Rules

1. **Universe**: A diversified set of sector or asset-class ETFs. Common choices:
   - **3-ETF Model**: SPY (US equities), TLT (US long bonds), EEM (emerging markets).
   - **Sector Model**: XLK (tech), XLF (financials), XLE (energy), XLV (healthcare), XLY (consumer discretionary), XLP (consumer staples), XLI (industrials), XLU (utilities), XLB (materials), XLRE (real estate), XLC (communications).

2. **Ranking**: At the end of each month, rank all ETFs by their total return over the past 1 month (or 3-month, 6-month, or 12-month for smoother signals).

3. **Allocation**: Invest 100% of capital in the top-ranked ETF. Alternatively, split across the top 2-3 ETFs for diversification.

4. **Rebalancing**: Monthly, on the last trading day of each month.

5. **Cash Filter (Optional)**: If the top-ranked ETF has a negative absolute return over the lookback period, move to cash (or a short-term Treasury ETF like SHY) instead.

6. **Holding**: Hold the selected ETF(s) for the full month until the next rebalancing date.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.6-0.8 |
| CAGR | 11% (3-ETF model since inception) |
| Max Drawdown | -20% to -30% |
| Win Rate | ~55-60% (monthly) |
| Volatility | ~12-16% annualized |
| Profit Factor | ~1.4-1.7 |
| Rebalancing | Monthly |

The 11% CAGR exceeded buy-and-hold for most of the backtest period, with notably lower drawdowns until 2022. The Sharpe ratio improvement over buy-and-hold comes primarily from drawdown reduction during bear markets, when the strategy rotates into bonds or cash. The strategy beat buy-and-hold from inception through 2021 but experienced a significant relative drawdown in 2022 when equities, bonds, and emerging markets all declined.

## Efficacy Rating

**Rating: 3/5** — ETF rotation is one of the simplest and most accessible momentum strategies, with a two-decade live track record and solid theoretical backing from the cross-sectional momentum literature. The strategy is easy to implement, requires only monthly rebalancing, and has low transaction costs. The deduction reflects: (a) vulnerability to correlated drawdowns when all asset classes decline simultaneously, (b) concentration risk from holding only 1-3 positions, (c) the 2022 experience showing the strategy can significantly underperform during inflation/rate shocks, and (d) the lookback period for ranking is a tunable parameter with potential for overfitting.

## Academic References

- Jegadeesh, N., & Titman, S. (1993). "Returns to Buying Winners and Selling Losers: Implications for Stock Market Efficiency." *The Journal of Finance*, 48(1), 65-91.
- Moskowitz, T. J., & Grinblatt, M. (1999). "Do Industries Explain Momentum?" *The Journal of Finance*, 54(4), 1249-1290.
- Antonacci, G. (2014). *Dual Momentum Investing*. McGraw-Hill.
- Asness, C. S., Moskowitz, T. J., & Pedersen, L. H. (2013). "Value and Momentum Everywhere." *The Journal of Finance*, 68(3), 929-985.

## Implementation Notes

- **Universe Selection**: The choice of ETFs in the rotation universe is the most impactful design decision. A broader universe (10+ sector ETFs) provides more rotation opportunities but increases the chance of momentum crashes. A narrower universe (3-4 diversified asset classes) is more stable but limits upside.
- **Lookback Period**: 1-month lookback is most responsive but noisiest. 3-month or 6-month lookback periods produce smoother signals with less whipsaw. Some practitioners use a composite score (e.g., average of 1-month, 3-month, and 6-month returns).
- **Cash Filter**: Adding a cash filter (rotate to cash when the best ETF has negative momentum) significantly reduces drawdowns but sacrifices return during recoveries. This is a risk-tolerance decision.
- **Crypto Adaptation**: Replace ETFs with sector-representative tokens: L1 smart contract platforms (ETH, SOL, AVAX), DeFi (UNI, AAVE, MKR), infrastructure (LINK, GRT), etc. Monthly rotation among crypto sectors captures the pronounced sector rotation patterns in crypto bull markets. Beware of much higher volatility and correlation during crypto bear markets.
- **Transaction Costs**: Minimal for ETF rotation (monthly rebalancing, liquid ETFs). For crypto adaptation, exchange fees and slippage on less liquid tokens need to be factored in.
- **Tax Efficiency**: Monthly rotation generates short-term capital gains. Consider implementing in tax-advantaged accounts or using tax-loss harvesting to offset gains.
