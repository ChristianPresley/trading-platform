# Crypto Momentum

> **Source**: Academic papers on cryptocurrency momentum; [Liu & Tsyvinski (2021)](https://academic.oup.com/rfs/article-abstract/34/6/2689/5912024); [Liu, Tsyvinski & Wu (2022)](https://www.semanticscholar.org/paper/Common-Risk-Factors-in-Cryptocurrency-Liu-Tsyvinski/307abab0b64ed7f02d3f9a57bfe944e56ea70d0c)
> **Asset Class**: Cryptocurrency
> **Crypto/24-7 Applicable**: Yes --- designed for crypto asset cross-section
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

Applies cross-sectional momentum across a universe of cryptocurrency assets. Ranks cryptocurrencies by their recent returns (e.g., past 1-week to 12-week performance), goes long the top performers and short (or underweights) the bottom performers. Academic research demonstrates that momentum is a significant factor in crypto returns, driven by investor attention, herding behavior, and information diffusion across a fragmented market. Unlike traditional equity momentum, crypto momentum operates on shorter horizons due to faster information propagation and higher volatility.

## Trading Rules

1. **Universe Definition**: Select the top 20-50 cryptocurrencies by market capitalization, excluding stablecoins and wrapped tokens.
2. **Ranking**: At each rebalancing date, rank all assets by their cumulative return over the lookback period (e.g., past 7, 14, or 30 days). Skip the most recent 1-2 days to avoid short-term reversal effects.
3. **Portfolio Construction**: Go long the top quintile (top 20% by past returns) and short the bottom quintile (bottom 20%). Equal-weight within each leg.
4. **Rebalancing Frequency**: Weekly or bi-weekly. More frequent rebalancing captures faster momentum but incurs higher transaction costs.
5. **Position Sizing**: Equal risk contribution within each quintile. Scale total portfolio exposure to target a specific volatility (e.g., 20% annualized).
6. **Risk Management**: Cap individual position sizes at 10% of portfolio. Apply a market-wide trend filter (e.g., total crypto market cap above its 50-day MA) to reduce exposure during broad drawdowns.
7. **Long-Only Variant**: For simpler implementation, only go long the top quintile and hold cash/stablecoins for the remainder.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.8 - 1.5 |
| CAGR | 25% - 60% (long/short); 40% - 100% (long-only, includes beta) |
| Max Drawdown | -30% to -55% |
| Win Rate | 50% - 55% |
| Volatility | 30% - 50% annualized |
| Profit Factor | 1.3 - 1.8 |
| Rebalancing | Weekly to bi-weekly |

## Efficacy Rating

**3/5** --- Academic evidence for crypto momentum is solid. Liu, Tsyvinski, and Wu (2022) establish momentum as one of three factors (market, size, momentum) that explain the cross-section of crypto returns. However, implementation faces significant challenges: the short-selling leg is difficult to execute for many altcoins, liquidity in smaller tokens is thin, and transaction costs (spreads, slippage) can erode returns substantially. The strategy is also highly correlated with overall crypto market beta, making it difficult to isolate pure momentum alpha. Momentum crashes (rapid reversals) can be severe in crypto.

## Academic References

- Liu, Y. & Tsyvinski, A. (2021). "Risks and Returns of Cryptocurrency." *Review of Financial Studies*, 34(6), 2689-2727. [Oxford Academic](https://academic.oup.com/rfs/article-abstract/34/6/2689/5912024)
- Liu, Y., Tsyvinski, A., & Wu, X. (2022). "Common Risk Factors in Cryptocurrency." *Journal of Finance*, 77(2), 1133-1177.
- Jegadeesh, N. & Titman, S. (1993). "Returns to Buying Winners and Selling Losers: Implications for Stock Market Efficiency." *Journal of Finance*, 48(1), 65-91.
- Grobys, K. & Sapkota, N. (2020). "Momentum in Cryptocurrency Markets: Time Series and Cross-Sectional Evidence." *Journal of Alternative Investments*, 23(2), 59-72.

## Implementation Notes

- **Universe Management**: The crypto universe changes rapidly. New tokens launch weekly while others become illiquid or are delisted. Maintain a dynamic universe with minimum liquidity and market cap filters.
- **Short-Selling Constraints**: Many crypto assets cannot be shorted on centralized exchanges. A long-only variant (long winners, cash for losers) is more practical but captures less alpha.
- **Transaction Costs**: Spreads on smaller-cap tokens can be 0.5-2%, which significantly impacts weekly rebalancing. Focus on top-20 assets for tighter spreads.
- **Data Requirements**: Daily close prices and market caps for 50+ tokens. Kraken REST API covers major pairs; additional exchanges may be needed for broader coverage.
- **Pure Zig Implementation**: Ranking and portfolio construction are array sorting and allocation calculations, straightforward in Zig. The main complexity is managing the dynamic universe and multiple exchange API connections.
- **Momentum Crash Risk**: Crypto momentum can reverse violently (e.g., rotation from "blue chips" to "meme coins" and back). Consider momentum crash protection via stop-losses or volatility scaling.
