# Carry and Fixed Income Strategies

Strategies that harvest yield differentials, term premia, and structural mispricings across currency and bond markets. These approaches exploit the persistent failure of uncovered interest rate parity, the term premium embedded in yield curves, and no-arbitrage relationships between credit instruments.

## Strategies

| # | Strategy | Sharpe | Rating | Crypto |
|---|----------|--------|--------|--------|
| 01 | [FX Carry Trade](01_FX-Carry-Trade.md) | 0.254 | 4/5 | Adaptable |
| 02 | [Dollar Carry Trade](02_Dollar-Carry-Trade.md) | 0.113 | 3/5 | No |
| 03 | [Bond Ladders, Bullets, and Barbells](03_Bond-Ladders-Bullets-Barbells.md) | 0.3-0.6 | 4/5 | No |
| 04 | [Bond Immunization](04_Bond-Immunization.md) | N/A | 4/5 | No |
| 05 | [Yield Curve Strategies](05_Yield-Curve-Strategies.md) | 0.3-0.7 | 4/5 | No |
| 06 | [CDS-Bond Basis Arbitrage](06_CDS-Basis-Arbitrage.md) | 0.3-0.7 | 3/5 | Adaptable |
| 07 | [Roll Down the Yield Curve](07_Roll-Down-Yield-Curve.md) | 0.3-0.6 | 4/5 | No |

## Key Concepts

- **Carry**: The return earned from holding a higher-yielding asset financed by borrowing at a lower rate. Carry strategies profit when the yield differential is not fully offset by adverse price movements, exploiting the well-documented failure of uncovered interest rate parity in FX markets and the persistent term premium in bond markets.
- **Term Premium**: The excess yield investors demand for holding longer-maturity bonds over rolling short-term instruments. This premium varies over time and drives the profitability of roll-down and yield curve strategies.
- **Duration and Convexity**: The primary risk measures for fixed-income strategies. Duration quantifies sensitivity to parallel rate shifts, while convexity measures the curvature of the price-yield relationship. Barbell portfolios have higher convexity than duration-matched bullets, creating structural advantages for large rate moves.
- **Yield Curve Dynamics**: The three principal components of curve movement — level, slope, and curvature — explain over 99% of yield curve variation (Litterman and Scheinkman, 1991). Different strategies target different components.
- **Basis Relationships**: In credit markets, the CDS spread and bond credit spread should theoretically be equal. Persistent deviations create arbitrage opportunities, though convergence can be slow and funding-dependent.

## Common Risk Factors

- **Crash risk and negative skewness**: Carry strategies are fundamentally short volatility — they collect small, steady premiums but face severe losses during risk-off episodes. The FX carry trade lost years of accumulated profits during the 2008 GFC, and CDS basis trades blew up as funding liquidity evaporated.
- **Interest rate regime dependence**: Most fixed-income strategies are sensitive to the direction and speed of rate changes. Roll-down and ladder strategies suffer during rising rate environments; steepener/flattener performance is regime-specific.
- **Funding and leverage risk**: Many of these strategies require leverage to generate meaningful absolute returns from small yield differentials. Leverage amplifies losses and creates margin call risk during stress, which is precisely when carry strategies are most vulnerable.
- **Liquidity withdrawal**: Corporate bond and CDS markets can become illiquid during crises, widening bid-ask spreads and preventing trade execution. Government bond markets are more resilient but not immune.
- **Model risk**: Duration matching, immunization, and basis calculations rely on models (Nelson-Siegel, Macaulay duration) that assume specific yield curve behaviors. Non-parallel shifts, jump risks, and structural breaks can invalidate model assumptions.
