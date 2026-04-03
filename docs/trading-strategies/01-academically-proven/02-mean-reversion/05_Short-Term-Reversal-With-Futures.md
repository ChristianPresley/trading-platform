# Short-Term Reversal with Futures

> **Source**: [Awesome Systematic Trading](https://github.com/paperswithbacktest/awesome-systematic-trading), [Papers With Backtest — Short-Term Reversal with Futures](https://paperswithbacktest.com/wiki/short-term-reversal-with-futures)
> **Asset Class**: Futures
> **Crypto/24-7 Applicable**: Adaptable — perpetual futures on crypto exchanges provide a suitable instrument, though the reversal premium appears weak in futures generally
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

This strategy applies the classic short-term reversal effect to futures contracts rather than individual equities. The approach ranks futures contracts across asset classes (commodities, equity indices, fixed income, currencies) by their recent returns over the past 1-4 weeks and takes long positions in the worst performers while shorting the best performers, expecting mean reversion over the subsequent holding period.

Unlike equities, where the short-term reversal effect is well-established and profitable, the effect in futures markets is substantially weaker and often statistically insignificant. The backtested Sharpe ratio is approximately -0.05, indicating that the strategy fails to generate positive risk-adjusted returns in this asset class. The primary reason is that futures markets are dominated by informed, institutional participants and hedgers whose order flow is fundamentally motivated rather than noise-driven. The microstructure-based and overreaction-based explanations that support equity reversal do not translate well to futures, where positions reflect genuine hedging demand, carry considerations, and macroeconomic views rather than retail sentiment or liquidity shocks.

## Trading Rules

1. **Universe**: A broad cross-section of liquid futures contracts across asset classes — typically 20-50 contracts spanning equity indices, government bonds, commodities (energy, metals, agriculture), and currencies.

2. **Formation Period**: At the end of each week, compute the return for each futures contract over the past 1 week (using the front-month continuous contract or a roll-adjusted series).

3. **Portfolio Construction**:
   - **Long Portfolio**: Buy the bottom quintile of futures ranked by past-week returns.
   - **Short Portfolio**: Sell the top quintile of futures ranked by past-week returns.
   - Equal-weight or risk-parity weighting across positions.

4. **Holding Period**: Hold for 1 week.

5. **Rebalancing**: Weekly. Close all positions and reconstruct the portfolio based on updated rankings.

6. **Roll Management**: Use a systematic roll schedule (typically rolling 5-10 days before expiry into the next front-month contract) to avoid delivery and minimize roll impact.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | -0.05 |
| CAGR | ~0% (approximately flat) |
| Max Drawdown | -20% to -30% |
| Win Rate | 48-52% |
| Volatility | 12.3% annualized |
| Profit Factor | ~1.0 |
| Rebalancing | Weekly |

The near-zero Sharpe ratio and profit factor close to 1.0 indicate that the strategy does not produce meaningful returns after accounting for transaction costs. The moderate volatility (12.3%) reflects the diversified multi-asset futures portfolio, but without a positive return to compensate for this risk.

## Efficacy Rating

**Rating: 2/5** — The poor backtest performance (negative Sharpe ratio) severely limits the strategy's practical utility. While the theoretical framework of short-term reversal is well-grounded for equities, the evidence strongly suggests that this effect does not transfer to futures markets. The strategy is included primarily for completeness and as a cautionary example against blindly applying equity anomalies to other asset classes. It may have marginal utility as a diversifying overlay or in combination with other signals, but is not viable as a standalone strategy.

## Academic References

- Jegadeesh, N. (1990). "Evidence of Predictable Behavior of Security Returns." *The Journal of Finance*, 45(3), 881-898.
- Moskowitz, T. J., Ooi, Y. H., & Pedersen, L. H. (2012). "Time Series Momentum." *Journal of Financial Economics*, 104(2), 228-250.
- Asness, C. S., Moskowitz, T. J., & Pedersen, L. H. (2013). "Value and Momentum Everywhere." *The Journal of Finance*, 68(3), 929-985.
- Koijen, R. S. J., Moskowitz, T. J., Pedersen, L. H., & Vrugt, E. B. (2018). "Carry." *Journal of Financial Economics*, 127(2), 197-225.
- Szymanowska, M., De Roon, F., Nijman, T., & Van den Goorbergh, R. (2014). "An Anatomy of Commodity Futures Risk Premia." *The Journal of Finance*, 69(1), 453-482.

## Implementation Notes

- **Why It Fails**: Futures markets have fundamentally different microstructure than equities. Hedging demand (from producers, consumers, and asset allocators) creates persistent directional pressure that does not revert in the same way as equity order flow imbalances. Trend-following (momentum) is the dominant anomaly in futures, and reversal signals often conflict with strong momentum signals.
- **Potential Enhancements**: Some research suggests that combining reversal signals with regime filters (only trading reversal in range-bound or high-volatility environments) or restricting to specific asset classes (e.g., agricultural commodities with seasonal patterns) may improve results, but evidence remains weak.
- **Transaction Costs**: Futures have low direct transaction costs (tight spreads, exchange fees), but the weekly turnover and the need for contract rolling add friction that further erodes the near-zero gross returns.
- **Crypto Adaptation**: Crypto perpetual futures could theoretically exhibit reversal effects due to retail-dominated order flow and funding rate dynamics. However, the strong trending behavior of crypto markets works against reversal strategies, and empirical evidence is limited.
- **Better Alternatives**: For futures markets, time-series momentum (Moskowitz et al., 2012) and carry strategies (Koijen et al., 2018) have much stronger empirical support and should be preferred over reversal approaches.
