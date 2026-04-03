# Perpetual Futures Basis

> **Source**: [BIS Working Papers No. 1087 - Crypto Carry](https://www.bis.org/publ/work1087.pdf); [He & Manela (2022)](https://arxiv.org/html/2212.06888v5)
> **Asset Class**: Cryptocurrency (Derivatives)
> **Crypto/24-7 Applicable**: Yes --- perpetual futures and spot markets trade 24/7
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

Trades the basis (price differential) between spot cryptocurrency and perpetual futures contracts in a classic cash-and-carry arbitrage structure. When perpetual futures trade at a premium to spot (positive basis, contango), the strategy buys spot and sells the perpetual, profiting as the basis converges. When futures trade at a discount (negative basis, backwardation), the reverse trade applies. Unlike the Funding Rate Carry strategy, which focuses on periodic funding payments, the Basis strategy targets the outright price differential between spot and perpetual, which can be significantly larger during periods of high leverage demand.

## Trading Rules

1. **Basis Calculation**: Continuously compute the basis as: `Basis = (Perpetual Price - Spot Price) / Spot Price`, expressed as an annualized percentage.
2. **Entry (Positive Basis / Contango)**: When the annualized basis exceeds a threshold (e.g., > 20% annualized), buy spot and short an equal notional amount of the perpetual future. This captures basis convergence plus funding payments.
3. **Entry (Negative Basis / Backwardation)**: When the annualized basis is below a threshold (e.g., < -10% annualized), sell spot (or close long) and go long the perpetual. This is less common and harder to execute.
4. **Exit**: Close the trade when the basis narrows to near zero or reverses sign. Alternatively, hold until the basis reaches a target profit level.
5. **Position Sizing**: Size positions such that a 5% adverse basis move represents no more than 1% portfolio loss. Account for margin requirements on the futures leg.
6. **Rebalancing**: Adjust delta exposure as prices move to maintain approximate neutrality. Monitor margin requirements continuously.
7. **Risk Limits**: Maximum basis trade size of 20% of portfolio. Limit exposure to any single exchange to 10% of portfolio.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 1.5 - 3.5 |
| CAGR | 10% - 35% (depends on basis environment) |
| Max Drawdown | -5% to -12% |
| Win Rate | 75% - 90% |
| Volatility | 5% - 15% annualized |
| Profit Factor | 3.0 - 8.0 |
| Rebalancing | Continuous to daily |

## Efficacy Rating

**4/5** --- The crypto basis trade is one of the most well-understood and reliable strategies in the space. BIS research documents that crypto basis spreads have been "considerably larger in magnitude" than in traditional markets, offering substantially higher returns than equivalent trades in rates or FX. The economic rationale is clear: structural demand for leveraged long exposure from retail traders creates a persistent premium in perpetuals. However, the strategy requires significant operational infrastructure (accounts on multiple venues, margin monitoring, rebalancing), and exchange counterparty risk remains the dominant risk factor. Basis can widen sharply during liquidation cascades before eventually converging.

## Academic References

- Schmeling, M. et al. (2023). "Crypto Carry." *BIS Working Papers No. 1087*. [BIS](https://www.bis.org/publ/work1087.pdf)
- He, S. & Manela, A. (2022). "Fundamentals of Perpetual Futures." [arXiv:2212.06888](https://arxiv.org/html/2212.06888v5)
- Ackerer, D., Hugonnier, J., & Jermann, U. (2025). "Perpetual Futures Pricing." *Mathematical Finance*. [Wiley](https://onlinelibrary.wiley.com/doi/10.1111/mafi.70018)
- Alexander, C. & Heck, D. (2020). "Price Discovery in Bitcoin: The Impact of Unregulated Markets." *Journal of Financial Stability*, 50, 100776.

## Implementation Notes

- **Cross-Margining Friction**: The most significant implementation challenge. Without cross-margining, capital must fund both the spot leg and the futures margin independently, roughly doubling capital requirements. Some exchanges (e.g., Bybit, OKX) offer portfolio margin that partially addresses this.
- **Basis Monitoring**: Requires real-time price feeds from both spot and futures markets. WebSocket connections to Kraken spot and Kraken Futures are essential.
- **Liquidation Risk**: During extreme volatility, the short futures leg can face margin calls even when the spot leg is profitable. Maintain excess margin (2-3x minimum) to survive flash crashes.
- **Execution Timing**: Entry and exit should occur during high-liquidity periods to minimize slippage. Avoid thin weekend liquidity windows for large position changes.
- **Pure Zig Implementation**: The core logic (basis calculation, threshold comparison, position management) is simple arithmetic. The complexity lies in reliable exchange connectivity and margin monitoring, which benefits from Zig's deterministic performance for real-time systems.
- **Complementarity**: This strategy and the Funding Rate Carry strategy are closely related. In practice, they can be combined: the basis trade captures price convergence while the carry trade captures ongoing funding payments, compounding returns.
