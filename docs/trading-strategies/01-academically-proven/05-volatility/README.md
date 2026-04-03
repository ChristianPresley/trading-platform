# Volatility Strategies

Strategies that trade volatility as an asset class, exploiting the persistent wedge between implied and realized volatility, the term structure of volatility futures, and the tendency of volatility to mean-revert.

## Strategies

| # | Strategy | Sharpe | Rating | Crypto |
|---|----------|--------|--------|--------|
| 01 | [Volatility Risk Premium](01_Volatility-Risk-Premium.md) | 0.637 | 4/5 | Adaptable |
| 02 | [VIX Futures Basis](02_VIX-Futures-Basis.md) | 0.5-1.0 | 4/5 | No |
| 03 | [Volatility Carry](03_Volatility-Carry.md) | 0.8-1.3 | 3/5 | No |
| 04 | [Variance Swaps](04_Variance-Swaps.md) | 0.5-0.8 | 3/5 | No |
| 05 | [Volatility Skew](05_Volatility-Skew.md) | 0.3-0.6 | 3/5 | Adaptable |
| 06 | [Index Volatility Targeting](06_Index-Volatility-Targeting.md) | Improves base | 4/5 | Adaptable |

## Key Concepts

- **Variance Risk Premium (VRP)**: The systematic difference between option-implied volatility and subsequent realized volatility. Implied volatility exceeds realized roughly 85-90% of the time, creating a structural premium for volatility sellers.
- **Term Structure**: VIX futures typically trade in contango (upward-sloping curve), reflecting the insurance premium embedded in longer-dated volatility. This structure creates roll yield for short positions.
- **Mean Reversion**: Volatility is one of the most strongly mean-reverting quantities in financial markets, making extreme readings tradeable.
- **Volatility Clustering**: High-volatility periods tend to persist (GARCH effects), but ultimately revert, creating predictable regime dynamics.
- **Skew and Smile**: The asymmetry in implied volatility across strikes encodes market expectations about tail risk, which can be traded directly.

## Common Risk Factors

- **Left-tail blowups**: Short volatility strategies have concave payoff profiles. Losses during volatility spikes (Feb 2018 "Volmageddon", March 2020) can exceed years of accumulated premium.
- **Regime dependence**: The VRP is not constant; it compresses during low-vol regimes and can turn negative during sustained crises.
- **Leverage and margin**: Many volatility instruments are implicitly leveraged, and margin calls during stress can force liquidation at the worst possible time.
- **Liquidity withdrawal**: Volatility markets can become illiquid precisely when hedging is most needed, widening bid-ask spreads dramatically.
- **Correlation spikes**: During crises, cross-asset correlations spike toward 1.0, reducing the diversification benefit of multi-asset volatility strategies.
