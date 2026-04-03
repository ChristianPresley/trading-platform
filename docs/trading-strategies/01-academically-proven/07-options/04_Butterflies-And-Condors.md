# Butterflies and Condors

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 2
> **Asset Class**: Equities / Multi-Asset (any asset with listed options)
> **Crypto/24-7 Applicable**: Adaptable — iron condors and iron butterflies are constructable on Deribit for BTC and ETH, though wider wing spacing is necessary due to crypto's higher volatility
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

Butterflies and condors are range-bound, defined-risk options strategies that profit when the underlying stays within a specified price range through expiration. Both strategies combine multiple option legs to create tent-shaped or plateau-shaped payoff profiles with capped maximum profit at a target price (butterfly) or within a target range (condor), and defined maximum loss equal to the net debit paid or the wing width minus credit received.

A **butterfly** combines three strikes: buy one option at a lower strike, sell two options at a middle strike, and buy one option at a higher strike (all same type and expiration). The maximum profit occurs at the middle strike at expiration. An **iron butterfly** achieves the same payoff using both calls and puts: sell an ATM straddle and buy OTM wings for protection.

A **condor** uses four strikes: buy one at the lowest, sell one at the second, sell one at the third, and buy one at the highest. The maximum profit zone is a plateau between the two middle strikes. An **iron condor** (the most commonly traded variant) sells an OTM put spread and an OTM call spread simultaneously, profiting when the underlying stays between the two short strikes.

Backtesting of SPX iron condors at 38 DTE shows that the 12-delta and 16-delta variations produce the most well-behaved risk profiles, confirmed by the highest Sharpe and Sortino ratios. Iron condors often perform best in the 45-60 DTE range to capture high theta while keeping gamma risk distant. Butterflies maximize profit convergence in the 20-30 DTE window, making them more suitable for shorter-term implementations.

## Trading Rules

1. **Iron Condor** (neutral, range-bound):
   - **Sell** an OTM put (e.g., delta -0.12 to -0.16).
   - **Buy** a further OTM put (wing, $5-$25 below short put).
   - **Sell** an OTM call (e.g., delta 0.12 to 0.16).
   - **Buy** a further OTM call (wing, $5-$25 above short call).
   - All same expiration: 38-60 DTE optimal.
   - Maximum profit: net credit received. Maximum loss: wing width minus credit.
   - Manage at 50% of max profit. Adjust or close if the underlying breaches a short strike.

2. **Iron Butterfly** (neutral, pinning to a specific price):
   - **Sell** an ATM put and an ATM call (same strike).
   - **Buy** an OTM put and an OTM call (wings, equidistant from center).
   - Maximum profit at the center strike at expiration (larger than iron condor but narrower profit zone).
   - Maximum loss: wing width minus credit received.

3. **Long Butterfly** (directional pinning bet):
   - **Buy** 1 call at lower strike, **sell** 2 calls at middle strike, **buy** 1 call at upper strike.
   - Cost: small net debit. Maximum profit: strike width minus debit (at middle strike).
   - Use as a cheap directional bet with defined risk when expecting the underlying to settle near a specific price.

4. **Strike Selection**:
   - Iron condor: place short strikes at 12-16 delta for optimal risk-adjusted returns.
   - Iron butterfly: center strike at current price or expected settlement price.
   - Wing width: balance between credit received and maximum loss. Wider wings collect more credit but increase max loss.

5. **Expiration**: 38-60 DTE for iron condors (theta capture with manageable gamma). 20-30 DTE for butterflies (maximize profit convergence near target).

6. **Risk Management**: Close at 50% of max profit. Adjust by rolling the tested side or converting to a different structure if the underlying trends strongly. Maximum position size = 3-5% of portfolio.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.3-0.7 (iron condor, 12-16 delta, managed) |
| CAGR | 8-18% (on capital at risk, managed iron condor) |
| Max Drawdown | -20% to -35% (of capital at risk, unmanaged) |
| Win Rate | 70-85% (iron condor, 12-16 delta) |
| Volatility | 8-15% (annualized, on capital at risk) |
| Profit Factor | 1.3-2.0 (with management rules) |
| Rebalancing | Monthly (new position each expiration cycle) |

The iron condor's 5:1 risk-to-reward structure (typical for tight wing widths) means that when the low-probability max loss event occurs, the resulting drawdown is proportionally large relative to accumulated profits. This makes active management (profit targets, stop-losses, rolling adjustments) essential. Butterflies have a more favorable risk-to-reward ratio (3:1 to 10:1 in the trader's favor) but a narrower profit zone and lower win rate. The optimal approach depends on market regime: iron condors outperform in moderate, stable volatility environments, while butterflies excel in quiet, low-IV markets.

## Efficacy Rating

**Rating: 4/5** — Butterflies and condors are well-established range-bound strategies with strong theoretical foundations and extensive backtesting data. The iron condor in particular has become one of the most popular retail and institutional options strategies due to its defined risk and high win rate. The deduction from a perfect score reflects the asymmetric payoff structure (large occasional losses relative to small frequent gains), the need for active management to achieve acceptable risk-adjusted returns, and the sensitivity to gap moves that can breach both short strikes simultaneously.

## Academic References

- Chaput, J. S., & Ederington, L. H. (2003). "Option Spread and Combination Trading." *The Journal of Derivatives*, 10(4), 70-88.
- Chaput, J. S., & Ederington, L. H. (2005). "Volatility Trade Design." *The Journal of Futures Markets*, 25(3), 243-279.
- Hull, J. C. (2018). *Options, Futures, and Other Derivatives*. 10th Edition, Pearson, Ch. 12.
- Natenberg, S. (1994). *Option Volatility and Pricing*. McGraw-Hill.
- Augen, J. (2011). *Trading Options at Expiration: Strategies and Models for Winning the Endgame*. FT Press.

## Implementation Notes

- **Data Requirements**: Full options chain with bid-ask quotes across multiple strikes, implied volatility surface, and Greeks for all four legs.
- **Margin Efficiency**: Iron condors and iron butterflies are defined-risk strategies — margin requirement equals the maximum loss (wing width minus credit). This capital efficiency makes them suitable for smaller accounts.
- **Greeks Management**: Iron condors are short gamma and short vega near the center of the range, and long gamma/vega at the wings. Monitor gamma risk as expiration approaches — gamma increases exponentially in the final week for ATM options, making iron butterflies particularly dangerous to hold through expiration without management.
- **Adjustment Strategies**: When the underlying approaches a short strike: (1) roll the untested side closer to collect additional credit, (2) close the tested side and accept the loss, or (3) convert to an iron butterfly or broken-wing butterfly. Adjustments add complexity but can improve overall strategy performance.
- **Crypto Adaptation**: Iron condors on BTC/ETH require wider strike spacing (20-30% OTM rather than 5-10%) to account for crypto's higher realized volatility and gap risk. The higher implied volatility generates larger credits, partially offsetting the wider strikes. Liquidity on Deribit is concentrated in monthly expirations; use these rather than weeklies for crypto iron condors.
- **Earnings and Events**: Avoid holding iron condors or butterflies through binary events (earnings, FOMC) where the underlying can gap beyond both short strikes simultaneously, realizing maximum loss.
