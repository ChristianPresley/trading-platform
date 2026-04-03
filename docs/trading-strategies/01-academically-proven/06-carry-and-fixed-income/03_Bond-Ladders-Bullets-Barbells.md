# Bond Ladders, Bullets, and Barbells

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 5
> **Asset Class**: Fixed Income
> **Crypto/24-7 Applicable**: No — requires a traditional yield curve with multiple maturities of sovereign or corporate debt instruments
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

Bond ladders, bullets, and barbells are the three foundational portfolio construction strategies along the yield curve, each offering distinct risk-return profiles depending on the shape and expected movement of the term structure. These are not directional trading strategies per se, but rather structural approaches to fixed-income portfolio construction that exploit specific yield curve properties.

A **ladder** distributes bond holdings evenly across maturities (e.g., 1-year through 10-year), creating a portfolio that naturally rolls down the curve and provides regular reinvestment opportunities. A **bullet** concentrates holdings around a single maturity point, typically the intermediate segment, maximizing exposure to a specific part of the curve. A **barbell** allocates to the short and long ends of the curve while avoiding intermediate maturities, combining high yield from the long end with liquidity and reinvestment flexibility from the short end.

The relative performance of these strategies depends critically on how the yield curve evolves. Academic work by Ilmanen (1995) demonstrates that the term premium is time-varying and concentrates differently across maturities in different interest rate regimes. The ladder provides the most robust performance across diverse environments due to its diversification across the curve, while bullets and barbells are tactical tools that express specific views on curve shape changes.

## Trading Rules

1. **Universe**: Government bonds (treasuries or sovereign debt) across the maturity spectrum, typically 1-year to 30-year. Can also use investment-grade corporate bonds.

2. **Ladder Construction**:
   - Divide capital equally across N maturity buckets (e.g., 1, 2, 3, 5, 7, 10 years).
   - As bonds mature or approach the shortest rung, reinvest proceeds into the longest rung.
   - Maintain approximately equal dollar duration across rungs, or equal par amounts.

3. **Bullet Construction**:
   - Concentrate all holdings in bonds with maturities clustered around a target date (e.g., 5-7 years).
   - Match the portfolio's Macaulay duration to a specific liability or investment horizon.
   - Offers the highest cash flow certainty at the target date.

4. **Barbell Construction**:
   - Allocate approximately 50% to short-term bonds (1-3 years) and 50% to long-term bonds (20-30 years).
   - Adjust weights to achieve a target portfolio duration matching the bullet alternative.
   - The barbell has higher convexity than a duration-matched bullet, benefiting from large parallel rate moves in either direction.

5. **Rebalancing**: Semi-annually or annually. Reinvest maturing proceeds according to the strategy structure.

6. **Tactical Switching**: Shift between barbell and bullet based on curve shape expectations:
   - Barbell outperforms when the curve flattens or during inversions.
   - Bullet outperforms immediately after yield curve normalization (1-3 years post-inversion).
   - Ladder provides stable, middle-ground performance across all regimes.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.3-0.6 (varies by structure and period) |
| CAGR | 3-6% (total return, depending on rate environment) |
| Max Drawdown | -5% to -15% (ladder), -10% to -20% (barbell in rising rates) |
| Win Rate | 65-75% (annual, total return including coupons) |
| Volatility | 3-8% (ladder), 5-12% (barbell) |
| Profit Factor | 1.5-2.5 (predominantly coupon-driven) |
| Rebalancing | Semi-annually to annually |

Ladders exhibit the lowest volatility and shallowest drawdowns due to curve diversification and natural roll-down. Barbells offer higher convexity, outperforming during large parallel rate moves and curve flattening episodes. Historical comparisons show the barbell provides higher 5- and 7-year returns following curve inversions, while the bullet provides higher 1- and 3-year returns immediately post-inversion.

## Efficacy Rating

**Rating: 4/5** — These are well-established, academically validated portfolio construction techniques used universally by institutional fixed-income managers. The strategies are simple to implement and provide reliable income streams with manageable risk. The rating reflects their proven track record and broad applicability. The deduction acknowledges that these are primarily portfolio construction approaches rather than alpha-generating strategies, and that performance is heavily dependent on the interest rate environment — all three structures suffer during sustained rising rate periods.

## Academic References

- Ilmanen, A. (1995). "Time-Varying Expected Returns in International Bond Markets." *The Journal of Finance*, 50(2), 481-506.
- Ilmanen, A. (2011). *Expected Returns: An Investor's Guide to Harvesting Market Rewards*. Wiley.
- Fabozzi, F. J. (2007). *Fixed Income Analysis*. 2nd Edition, CFA Institute Investment Series.
- Leibowitz, M. L., & Kogelman, S. (1991). "Asset Allocation under Shortfall Constraints." *The Journal of Portfolio Management*, 17(2), 18-23.
- Diebold, F. X., & Li, C. (2006). "Forecasting the Term Structure of Government Bond Yields." *Journal of Econometrics*, 130(2), 337-364.

## Implementation Notes

- **Data Requirements**: Yield curve data across multiple maturities (at minimum 2-year, 5-year, 10-year, 30-year). The US Treasury curve is the standard reference, available from the Federal Reserve (H.15 series).
- **Convexity Advantage**: The barbell's higher convexity relative to a duration-matched bullet means it outperforms for large parallel shifts in rates (in either direction) but underperforms for small moves. This makes the barbell a long-gamma position relative to the bullet.
- **Ladder Reinvestment Risk**: The ladder's primary risk is reinvestment — when short rungs mature during low-rate periods, proceeds must be reinvested at the long end at potentially unattractive yields. This is partially offset by the averaging effect across maturities.
- **Duration Matching**: When comparing bullet vs. barbell, ensure both portfolios have identical modified duration to isolate the convexity and curve-shape effects. Without duration matching, performance differences reflect duration bets rather than structural differences.
- **Tax Considerations**: In taxable accounts, the higher coupon income from the long end of the barbell may be less tax-efficient than the capital gains orientation of a ladder that benefits from roll-down.
