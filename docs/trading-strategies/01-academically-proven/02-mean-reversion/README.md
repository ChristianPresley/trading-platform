# Mean Reversion Strategies

Mean reversion strategies exploit the tendency of asset prices to revert toward a historical average, equilibrium level, or fair value after experiencing extreme deviations. These strategies systematically buy underperformers and sell outperformers, profiting from the correction of temporary mispricings driven by liquidity shocks, behavioral overreaction, or microstructure effects.

Mean reversion is one of the most enduring concepts in quantitative finance, with the short-term reversal effect in equities documented as early as 1990. The strategies in this section range from simple indicator-based approaches (IBS, RSI-2) to statistically sophisticated clustering methods, and span equities, futures, ETFs, and cryptocurrencies.

---

## Strategies

1. [Short-Term Reversal in Stocks](01_Short-Term-Reversal-In-Stocks.md) `[Backtested]` `[Whitepaper]`
   **Rating: 4/5** — Weekly reversal: buy past losers, sell past winners over 1-4 week horizons. Sharpe 0.816, one of the most well-documented anomalies in finance. Jegadeesh (1990).

2. [Mean Reversion — Single Cluster](02_Mean-Reversion-Single-Cluster.md) `[Backtested]` `[Whitepaper]`
   **Rating: 3/5** — Identify mean-reverting clusters using statistical methods and trade deviations from the cluster mean. Sound theoretical basis but highly implementation-dependent.

3. [Mean Reversion — Multiple Clusters](03_Mean-Reversion-Multiple-Clusters.md) `[Backtested]` `[Whitepaper]`
   **Rating: 3/5** — Extension using multiple clusters for diversified mean-reversion capture. Improved Sharpe through diversification, but added complexity and overfitting risk.

4. [Reversal During Earnings Announcements](04_Reversal-During-Earnings-Announcements.md) `[Backtested]` `[Whitepaper]`
   **Rating: 4/5** — Stocks that performed poorly pre-earnings tend to reverse during the announcement window. Sharpe 0.785, profitable in 40 of 42 years studied.

5. [Short-Term Reversal with Futures](05_Short-Term-Reversal-With-Futures.md) `[Backtested]` `[Whitepaper]`
   **Rating: 2/5** — Apply the reversal effect to futures contracts. Negative Sharpe (-0.05) indicates the equity reversal premium does not transfer to futures markets.

6. [IBS Mean Reversion](06_IBS-Mean-Reversion.md) `[Backtested]`
   **Rating: 3/5** — Internal Bar Strength indicator: buy when the close is near the daily low, sell on reversion. CAGR 14.8%, profit factor 1.75 on FXI. Simple and robust.

7. [RSI(2) Mean Reversion](07_RSI-2-Mean-Reversion.md) `[Backtested]`
   **Rating: 4/5** — Larry Connors' 2-period RSI strategy: buy when RSI(2) drops below 10, sell above 90. ~70% win rate, one of the most widely adopted retail mean-reversion strategies.

8. [Rebalancing Premium in Cryptocurrencies](08_Rebalancing-Premium-In-Cryptocurrencies.md) `[Backtested]` `[Whitepaper]` `[Crypto]`
   **Rating: 4/5** — Systematic rebalancing of a crypto portfolio captures a volatility harvesting premium. Sharpe 0.698, natively designed for 24/7 crypto markets.

---

## Section Summary

| # | Strategy | Asset Class | Sharpe | Rating | Crypto |
|---|----------|-------------|--------|--------|--------|
| 1 | Short-Term Reversal in Stocks | Equities | 0.816 | 4/5 | Adaptable |
| 2 | Mean Reversion — Single Cluster | Equities | 0.8-1.2 | 3/5 | Adaptable |
| 3 | Mean Reversion — Multiple Clusters | Equities | 1.0-1.5 | 3/5 | Adaptable |
| 4 | Reversal During Earnings Announcements | Equities | 0.785 | 4/5 | No |
| 5 | Short-Term Reversal with Futures | Futures | -0.05 | 2/5 | Adaptable |
| 6 | IBS Mean Reversion | ETFs/Equities | ~1.0-1.3 | 3/5 | Adaptable |
| 7 | RSI(2) Mean Reversion | Equities/ETFs | ~0.8-1.2 | 4/5 | Adaptable |
| 8 | Rebalancing Premium in Cryptocurrencies | Crypto | 0.698 | 4/5 | Yes |

**Average Rating**: 3.4/5
**Crypto-Native Strategies**: 1 (Rebalancing Premium)
**Crypto-Adaptable Strategies**: 6
