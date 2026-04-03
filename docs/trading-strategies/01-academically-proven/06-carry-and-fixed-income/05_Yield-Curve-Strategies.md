# Yield Curve Strategies (Butterfly, Steepener, Flattener)

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 5
> **Asset Class**: Fixed Income
> **Crypto/24-7 Applicable**: No — requires a sovereign or corporate yield curve with multiple liquid maturity points; no crypto term structure of sufficient depth exists
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

Yield curve strategies are active fixed-income trades that express views on how the shape of the yield curve will change, rather than its overall level. The three canonical trade types — steepeners, flatteners, and butterflies — each target a different dimension of curve movement and are typically constructed to be duration-neutral, isolating the curve-shape bet from directional interest rate exposure.

A **steepener** profits when the spread between long-term and short-term rates widens (the curve steepens). The trade structure is long short-term bonds and short long-term bonds. A **flattener** is the opposite, profiting when the curve flattens — long the long end and short the short end. A **butterfly** takes positions at three maturity points: the wings (short and long end) and the body (intermediate), profiting from changes in curve curvature rather than slope.

These strategies are central to institutional fixed-income management and are among the most actively traded strategies in government bond markets. Academic work by Litterman and Scheinkman (1991) demonstrated that three factors — level, slope, and curvature — explain over 99% of yield curve movements, providing the theoretical foundation for these trades. The slope factor explains 5-10% of curve variation and is the primary driver of steepener/flattener returns, while the curvature factor (2-5% of variation) drives butterfly returns.

## Trading Rules

1. **Steepener Trade**:
   - **Long**: Short-term bonds (e.g., 2-year treasuries).
   - **Short**: Long-term bonds (e.g., 10-year or 30-year treasuries).
   - Duration-neutral: Weight positions so that the DV01 (dollar value of a basis point) is equal on both legs.
   - Profits when the 2s-10s or 2s-30s spread widens.

2. **Flattener Trade**:
   - **Long**: Long-term bonds (e.g., 10-year or 30-year).
   - **Short**: Short-term bonds (e.g., 2-year).
   - Duration-neutral construction (DV01-matched).
   - Profits when the yield curve flattens or inverts.
   - Historically performs well during rate-hiking cycles when front-end rates rise faster than long-end.

3. **Butterfly Trade**:
   - **Body**: Short intermediate bonds (e.g., 5-year or 7-year).
   - **Wings**: Long short-term and long-term bonds (e.g., 2-year and 10-year).
   - Duration-neutral and cash-neutral.
   - Profits when the intermediate segment cheapens relative to the wings (positive butterfly) or vice versa.
   - Weight the wings to be both DV01-neutral and regression-weighted to minimize exposure to parallel and slope moves.

4. **Signal Generation**:
   - Compare current curve shape metrics (2s-10s spread, butterfly spread) to historical percentiles.
   - Macroeconomic signals: position for steepening during easing cycles, flattening during tightening cycles.
   - Relative value: identify maturities that are cheap or rich relative to a fitted curve model (Nelson-Siegel, Svensson).

5. **Rebalancing**: Weekly to monthly, depending on the trade horizon and the speed of curve movements.

6. **Risk Management**: Set stop-losses based on basis point moves in the target spread (e.g., exit steepener if 2s-10s narrows by 30bp from entry).

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.3-0.7 (flattener during hiking cycles), 0.2-0.5 (steepener/butterfly) |
| CAGR | 1-4% (excess return, unlevered, duration-neutral) |
| Max Drawdown | -5% to -15% (depending on leverage and curve regime) |
| Win Rate | 50-60% (trade-level) |
| Volatility | 3-8% (duration-neutral construction) |
| Profit Factor | 1.2-1.8 |
| Rebalancing | Weekly to monthly |

Flattener trades show the strongest Sharpe ratios during rate-hiking cycles, where the front end bears the brunt of policy tightening while the long end is anchored by inflation expectations and term premium compression. Butterfly trades combined with flatteners substantially reduce portfolio volatility across rate-hiking cycles relative to standalone flatteners. Steepener performance is more regime-dependent, with the strongest returns during easing cycles and post-recession recovery periods.

## Efficacy Rating

**Rating: 4/5** — Yield curve strategies are fundamental to institutional fixed-income management, backed by decades of academic research on term structure dynamics. The Litterman-Scheinkman decomposition provides a rigorous theoretical framework, and these trades are highly liquid in government bond markets. The rating reflects the strong evidence base and institutional adoption. The deduction acknowledges the difficulty of consistently forecasting curve shape changes, the regime-dependence of performance, and the fact that duration-neutral construction limits absolute returns without leverage.

## Academic References

- Litterman, R., & Scheinkman, J. (1991). "Common Factors Affecting Bond Returns." *The Journal of Fixed Income*, 1(1), 54-61.
- Nelson, C. R., & Siegel, A. F. (1987). "Parsimonious Modeling of Yield Curves." *The Journal of Business*, 60(4), 473-489.
- Svensson, L. E. O. (1994). "Estimating and Interpreting Forward Interest Rates: Sweden 1992-1994." *NBER Working Paper No. 4871*.
- Ang, A., & Piazzesi, M. (2003). "A No-Arbitrage Vector Autoregression of Term Structure Dynamics with Macroeconomic and Latent Variables." *Journal of Monetary Economics*, 50(4), 745-787.
- Diebold, F. X., & Li, C. (2006). "Forecasting the Term Structure of Government Bond Yields." *Journal of Econometrics*, 130(2), 337-364.
- Adrian, T., Crump, R. K., & Moench, E. (2013). "Pricing the Term Structure with Linear Regressions." *Journal of Financial Economics*, 110(1), 110-138.

## Implementation Notes

- **Data Requirements**: Daily yield curve data at multiple maturity points (at minimum: 2Y, 3Y, 5Y, 7Y, 10Y, 30Y). The Federal Reserve publishes par and zero-coupon yield curves daily. Bloomberg and Refinitiv provide real-time data.
- **DV01 Calculation**: Accurate DV01 matching is essential for duration-neutral construction. A 1bp error in DV01 matching on a $100M notional trade creates ~$10K of unintended directional exposure per basis point of parallel movement.
- **Carry and Roll-Down**: Beyond curve shape changes, these trades generate carry (from the yield differential between long and short legs) and roll-down return. The flattener typically has negative carry (paying more on the short leg than earning on the long leg during normal curve shapes), making timing critical.
- **Transaction Costs**: Government bond markets (especially US treasuries) are among the most liquid in the world, with bid-ask spreads of 0.5-2bp for on-the-run issues. However, frequent rebalancing of duration-neutral positions can still generate meaningful costs.
- **Leverage**: Institutional implementations typically use 5-20x leverage on these trades due to the small basis-point moves involved. This is achieved through futures, swaps, or repo-financed cash bond positions.
