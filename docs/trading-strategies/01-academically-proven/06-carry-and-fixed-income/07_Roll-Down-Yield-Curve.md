# Roll Down the Yield Curve

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 5
> **Asset Class**: Fixed Income
> **Crypto/24-7 Applicable**: No — requires an upward-sloping yield curve with multiple liquid maturity points; no equivalent crypto term structure exists
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

The roll-down (or "riding the yield curve") strategy captures the price appreciation that occurs as a bond ages and "rolls down" an upward-sloping yield curve toward lower-yielding, higher-priced maturities. The strategy buys bonds with maturities longer than the investment horizon, holds them as they naturally move toward the shorter end of the curve, and sells before maturity to capture the capital gain from the declining yield.

The fundamental mechanism is straightforward: in a normal (upward-sloping) yield curve environment, a 5-year bond yielding 4% will, after one year, become a 4-year bond. If the 4-year yield is 3.7%, the bond's price has increased — this price appreciation is the roll-down return, which adds to the coupon income. The total return (coupon plus roll-down) exceeds the return from simply buying a bond matching the investment horizon.

The strategy's profitability depends on the yield curve's steepness and stability. It works when the curve remains approximately unchanged in shape over the holding period. If the curve flattens, steepens, or shifts upward, the roll-down return can be reduced or eliminated. Academic research by Ilmanen (1995) and Bieri and Chincarini (2005) documents a persistent "term premium" that compensates investors for holding longer-duration bonds, providing the economic foundation for why the roll-down strategy has historically generated positive excess returns in most developed government bond markets.

## Trading Rules

1. **Universe**: Government bonds (treasuries, gilts, bunds) across the 2-10 year maturity range, where the yield curve is typically steepest and most liquid.

2. **Yield Curve Assessment**:
   - Verify the yield curve is upward-sloping (normal shape). The strategy is only active when the curve is positively sloped.
   - Identify the steepest segment of the curve — this is where roll-down return is maximized.
   - Compute the expected roll-down return for each maturity: (yield at current maturity - yield at maturity minus holding period) x modified duration.

3. **Position Construction**:
   - Buy bonds in the maturity segment offering the highest expected roll-down return per unit of risk.
   - Typically, the 3-7 year segment offers the best risk-adjusted roll-down in most curve environments.
   - Equal-weight or risk-weight across 2-3 target maturities.

4. **Holding Period**: 6-12 months. The strategy requires time for the bond to "roll" meaningfully down the curve.

5. **Exit Rules**:
   - Sell when the bond reaches the shorter maturity target (e.g., buy 5-year, sell when it becomes a 4-year).
   - Exit early if the yield curve flattens, inverts, or shifts upward significantly (e.g., if the yield at the target maturity rises by more than the expected roll-down).

6. **Reinvestment**: Roll proceeds back into new longer-maturity bonds to maintain the strategy continuously.

7. **Risk Management**: Monitor curve shape daily. Reduce exposure when the curve is flat or showing signs of inversion. Apply stop-losses based on total return deviation from expected roll-down.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.3-0.6 (incremental return above maturity-matched strategy) |
| CAGR | 0.5-1.5% (excess return above holding-period-matched bonds) |
| Max Drawdown | -3% to -8% (relative to maturity-matched benchmark) |
| Win Rate | 65-75% (annual, when curve remains normal) |
| Volatility | 2-5% (incremental, relative to benchmark) |
| Profit Factor | 1.5-2.5 |
| Rebalancing | Semi-annually to annually |

The roll-down strategy generates modest but consistent excess returns when the yield curve maintains its shape. For example, a 4-year bond at 3.52% held for one year would be expected to yield 3.31% as a 3-year bond, producing a roll-down gain of approximately 0.59% on top of the 3.52% coupon, for a total return of approximately 4.11%. The strategy's consistency (65-75% win rate) makes it attractive for institutional portfolios seeking incremental yield without taking directional duration bets.

## Efficacy Rating

**Rating: 4/5** — The roll-down strategy is one of the simplest and most reliable fixed-income strategies, requiring only an upward-sloping yield curve (which is the normal state in most developed markets for roughly 70-80% of the time). The academic evidence for a persistent term premium supports the strategy's long-run profitability. The deduction reflects its dependence on curve shape — the strategy generates zero or negative excess returns during flat or inverted curve environments, and rising rate environments can overwhelm the roll-down benefit. The modest absolute excess return also limits its standalone impact.

## Academic References

- Ilmanen, A. (1995). "Time-Varying Expected Returns in International Bond Markets." *The Journal of Finance*, 50(2), 481-506.
- Bieri, D. S., & Chincarini, L. B. (2005). "Riding the Yield Curve: A Variety of Strategies." *The Journal of Fixed Income*, 15(2), 6-35.
- Ang, A., Piazzesi, M., & Wei, M. (2006). "What Does the Yield Curve Tell Us about GDP Growth?" *Journal of Econometrics*, 131(1-2), 359-403.
- Cochrane, J. H., & Piazzesi, M. (2005). "Bond Risk Premia." *American Economic Review*, 95(1), 138-160.
- Kim, D. H., & Wright, J. H. (2005). "An Arbitrage-Free Three-Factor Term Structure Model and the Recent Behavior of Long-Term Yields and Distant-Horizon Forward Rates." *Federal Reserve Board Finance and Economics Discussion Series*, 2005-33.
- LSEG/FTSE Russell (2023). "FTSE Fixed Income Factor Research Series: The Carry Concept."

## Implementation Notes

- **Data Requirements**: Daily yield curve data across at minimum 5-7 maturity points. The US Treasury par curve and zero-coupon curve (available from the Federal Reserve and Bloomberg) are the standard references.
- **Optimal Curve Segment**: The 3-7 year segment typically offers the best risk-adjusted roll-down because the curve tends to be steepest in this region while duration risk remains manageable. The 10-30 year segment offers higher absolute roll-down but with substantially more duration risk.
- **Carry vs. Roll-Down**: Total expected return of a bond position has two components: carry (the coupon income minus the financing cost) and roll-down (the capital gain from moving down the curve). Both should be computed when evaluating strategy attractiveness.
- **Curve Environment Filter**: Only run the strategy when the 2s-10s spread exceeds a minimum threshold (e.g., 50bp). Below this threshold, the roll-down benefit is too small to justify the risk.
- **Premium Bonds vs. Discount Bonds**: The strategy works best with par or discount bonds. Premium bonds (trading above par) experience price decline as they approach par at maturity, which can partially offset the roll-down gain. Select bonds trading near par for the cleanest implementation.
- **Transaction Costs**: Government bond trading costs are low (1-3bp for on-the-run issues), and the strategy's low turnover (semi-annual to annual) keeps total costs modest. The primary friction is the bid-ask spread when selling the "rolled-down" bond and buying a new longer-maturity replacement.
