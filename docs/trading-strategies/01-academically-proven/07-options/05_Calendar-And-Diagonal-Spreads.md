# Calendar and Diagonal Spreads

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 2
> **Asset Class**: Equities / Multi-Asset (any asset with listed options)
> **Crypto/24-7 Applicable**: Adaptable — calendar and diagonal spreads are constructable on Deribit for BTC and ETH, particularly effective when crypto's term structure of implied volatility is in contango
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

Calendar spreads (also called time spreads or horizontal spreads) and diagonal spreads exploit the differential time decay between options with different expiration dates. Both strategies sell a shorter-dated option and buy a longer-dated option, profiting from the faster theta decay of the near-term option relative to the far-term option. The calendar spread uses the same strike for both legs, while the diagonal spread uses different strikes, adding a directional bias.

The core mechanism is that theta decay accelerates as expiration approaches — an option with 30 DTE decays faster per day than an identical option with 90 DTE. By selling the faster-decaying near-term option and owning the slower-decaying far-term option, the spread captures this differential. The strategy also benefits from an increase in implied volatility of the long leg (positive vega exposure) and is harmed by a decrease.

Calendar spreads profit most when the underlying stays near the short strike at the near-term expiration, allowing the short option to expire worthless while the long option retains significant time value. Diagonal spreads offer more flexibility by combining the time spread with a directional bias — a "poor man's covered call" (long deep ITM LEAPS call, short OTM near-term call) is one of the most popular diagonal implementations, replicating a covered call with much less capital. Backtesting shows experienced practitioners average 3-4% weekly gains on diagonal strategies, though with significant variance.

## Trading Rules

1. **Calendar Spread** (neutral):
   - **Sell** a near-term option (30-45 DTE) at a chosen strike (typically ATM).
   - **Buy** a far-term option (60-120 DTE) at the same strike.
   - Net debit position. Maximum profit occurs when the underlying is at the strike price at near-term expiration.
   - After near-term expiration, the long option can be sold or used to establish a new calendar by selling another near-term option.

2. **Diagonal Spread** (directional):
   - **Buy** a far-term option (90-180 DTE) at one strike (typically 50 delta for moderate directional bias, deep ITM for covered call replication).
   - **Sell** a near-term option (30-60 DTE) at a different strike (OTM relative to the long leg).
   - The short leg generates income while the long leg provides the directional foundation.

3. **Double Diagonal** (neutral, range-bound):
   - Combine a diagonal call spread and a diagonal put spread.
   - Buy far-term OTM calls and puts, sell near-term OTM calls and puts.
   - Profits from time decay and limited price movement, with defined risk.
   - If the short options expire worthless, the position converts to a long strangle for the remaining expiration period.

4. **Strike and Expiration Selection**:
   - Near-term short: 30-45 DTE (steepest theta decay curve).
   - Far-term long: 60-180 DTE (slower theta, higher vega).
   - The expiration gap should be at least 30 days to maintain meaningful theta differential.

5. **Rolling**: After the short leg expires or is closed at profit, sell a new short-dated option against the long leg. This "rolling" process can be repeated multiple times over the life of the long option.

6. **Risk Management**: Close the entire position if the underlying moves beyond the profitable range (typically 1.5-2 standard deviations from the short strike). Maximum loss is the net debit paid for the spread.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.4-0.8 (managed diagonal, rolling monthly) |
| CAGR | 15-30% (on capital at risk, active rolling) |
| Max Drawdown | -15% to -30% (of capital at risk) |
| Win Rate | 60-70% (per rolling cycle) |
| Volatility | 12-20% (annualized, on capital at risk) |
| Profit Factor | 1.4-2.2 |
| Rebalancing | Monthly (rolling short leg at each expiration) |

Calendar and diagonal spreads benefit most when shorter-dated implied volatility is higher than longer-dated (backwardation in the volatility term structure), and when the underlying remains range-bound near the short strike. The "poor man's covered call" diagonal has similar returns to a traditional covered call but requires 60-80% less capital, dramatically improving capital efficiency. Active rolling (selling a new short leg each month) compounds the theta advantage over time.

## Efficacy Rating

**Rating: 4/5** — Calendar and diagonal spreads are well-established time-decay strategies with strong theoretical foundations and proven practical effectiveness. The strategies offer superior capital efficiency compared to covered calls and provide exposure to both time decay and volatility term structure dynamics. The deduction reflects the strategies' sensitivity to volatility changes (a drop in IV of the long leg can cause losses even if the underlying cooperates), the complexity of managing multi-expiration positions, and the gap risk between the near-term expiration and the far-term option.

## Academic References

- Hull, J. C. (2018). *Options, Futures, and Other Derivatives*. 10th Edition, Pearson, Ch. 12.
- Natenberg, S. (1994). *Option Volatility and Pricing*. McGraw-Hill, Ch. 13.
- Chaput, J. S., & Ederington, L. H. (2005). "Volatility Trade Design." *The Journal of Futures Markets*, 25(3), 243-279.
- Euan Sinclair (2013). *Volatility Trading*. 2nd Edition, Wiley.
- Passarelli, D. (2012). *Trading Option Greeks*. 2nd Edition, Bloomberg Press.

## Implementation Notes

- **Data Requirements**: Options chains across multiple expiration dates with implied volatility, theta, and vega for each strike/expiration combination. A volatility term structure curve is essential for identifying optimal entry points.
- **Volatility Term Structure**: The spread benefits most when near-term IV > far-term IV (term structure in backwardation). This condition often exists around earnings dates, where the front-month options carry event premium that far-dated options do not. Avoid initiating calendar spreads when the term structure is steep in contango, as the short leg premium is small relative to the long leg cost.
- **Pin Risk**: At near-term expiration, if the underlying is exactly at or near the short strike, the short option has uncertain assignment risk and the spread's value is maximally sensitive to small price changes. Close or roll the short leg before the final day to avoid this risk.
- **Capital Efficiency**: The "poor man's covered call" (buy 70-80 delta LEAPS, sell 30 delta monthly calls) replicates a covered call with 20-40% of the capital. This capital efficiency improvement is the strategy's primary advantage for smaller accounts.
- **Crypto Adaptation**: Calendar spreads on BTC/ETH benefit from crypto's frequently elevated front-month implied volatility (particularly around halving events, protocol upgrades, and regulatory deadlines). The Deribit term structure often shows elevated short-term IV, creating favorable conditions for calendar spread entry. Use monthly expirations rather than weeklies for better liquidity.
- **Greeks Complexity**: Calendar and diagonal spreads have complex Greeks profiles — they are typically short gamma, long vega, and long theta at inception, but these relationships change as the underlying moves and time passes. Position monitoring requires tracking all Greeks across both expirations simultaneously.
