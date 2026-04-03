# Straddles and Strangles

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 2
> **Asset Class**: Equities / Multi-Asset (any asset with listed options)
> **Crypto/24-7 Applicable**: Adaptable — straddles and strangles are actively traded on Deribit for BTC and ETH; crypto's high implied volatility and frequent large moves create opportunities for both long and short volatility implementations
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

Straddles and strangles are volatility-directional strategies that profit from the magnitude (not direction) of the underlying's price movement relative to market expectations embedded in implied volatility. Both strategies involve simultaneously buying (or selling) a call and a put on the same underlying with the same expiration date.

A **straddle** uses the same strike price for both legs (typically ATM), creating maximum sensitivity to price movement in either direction. A **strangle** uses different strikes (the put strike below the call strike), which reduces the initial cost (for long positions) or the premium collected (for short positions) but widens the breakeven range. The choice between straddle and strangle reflects a tradeoff between sensitivity and cost.

**Long straddles/strangles** are bets that realized volatility will exceed implied volatility — they profit from large moves in either direction but bleed premium (theta) every day the underlying stays quiet. **Short straddles/strangles** are bets that implied volatility overestimates future realized volatility — they collect premium and profit when the underlying stays within a range, but face theoretically unlimited risk from large moves. Research shows that short straddles produce higher median monthly returns (+1.80%) but larger drawdowns (-13.7%), while short strangles offer a tighter risk profile with lower median returns (+1.25%) and shallower drawdowns (-11.1%).

The academic foundation rests on the variance risk premium (VRP) — the well-documented tendency of implied volatility to exceed realized volatility approximately 85-90% of the time, creating a structural edge for volatility sellers.

## Trading Rules

1. **Long Straddle** (volatility-buying):
   - **Buy** an ATM call and an ATM put with the same expiration.
   - Cost: combined premium of both options (total debit).
   - Breakeven: underlying must move beyond strike +/- total premium paid.
   - Optimal timing: before anticipated high-volatility events (earnings, FOMC, product launches) when IV has not yet fully priced in the expected move.
   - Exit: close the position at a target profit (e.g., 50-100% of premium paid) or before theta decay accelerates (typically with 10-15 DTE remaining).

2. **Long Strangle** (cheaper volatility-buying):
   - **Buy** an OTM put (e.g., delta -0.20 to -0.30) and an OTM call (e.g., delta 0.20-0.30) with the same expiration.
   - Lower cost than a straddle but requires a larger move to profit.
   - Breakeven range is wider than a straddle by the distance between strikes.

3. **Short Straddle** (volatility-selling):
   - **Sell** an ATM call and an ATM put with the same expiration.
   - Maximum profit: total premium received. Maximum loss: theoretically unlimited.
   - Manage at 25-50% of maximum profit to reduce tail risk.
   - Exit or hedge if the underlying moves beyond 1.5x the expected move (straddle price at entry).

4. **Short Strangle** (wider-range volatility-selling):
   - **Sell** an OTM put and an OTM call (typically delta 0.15-0.25 each).
   - Wider profit zone than the short straddle, lower premium collected.
   - Manage at 50% of maximum profit. Adjust (roll the tested side) if the underlying approaches a short strike.

5. **Expiration Selection**: 30-45 DTE for short positions (maximize theta decay). 45-60 DTE for long positions (more time for the expected move to materialize, slower theta decay).

6. **Risk Management**: For short positions, define maximum loss at 2-3x premium collected and set hard stop-losses. Use delta-hedging for larger positions to manage directional risk during the trade.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.3-0.6 (short straddle/strangle, managed), -0.1 to 0.3 (long) |
| CAGR | 8-15% (short, managed), -5% to 5% (long, event-based) |
| Max Drawdown | -13.7% (short straddle monthly), -11.1% (short strangle monthly) |
| Win Rate | 70-85% (short), 25-40% (long) |
| Volatility | 10-18% (short), 20-35% (long) |
| Profit Factor | 1.3-2.0 (short, managed), 0.8-1.3 (long, event-based) |
| Rebalancing | Monthly (new position each expiration cycle) |

Short straddles outperform short strangles on absolute return metrics (higher median returns, higher Sharpe) but with larger drawdowns. Short strangles are more suitable for risk-averse implementations. Long straddles/strangles are generally unprofitable as systematic strategies due to the variance risk premium — they should only be deployed tactically around specific anticipated events where the trader has reason to believe implied volatility underestimates the actual forthcoming move.

## Efficacy Rating

**Rating: 5/5** — Straddles and strangles are foundational volatility strategies with strong theoretical grounding in the variance risk premium and decades of live trading data. The short volatility side benefits from one of the most persistent risk premia in financial markets (implied > realized ~85-90% of the time). The long side provides pure volatility exposure when directional uncertainty is high. The strategies' transparency, defined mechanics, and broad applicability earn the top rating. The risk of short positions (unlimited loss, periodic large drawdowns) is a feature of the payoff structure rather than a deficiency of the strategy.

## Academic References

- Coval, J. D., & Shumway, T. (2001). "Expected Option Returns." *The Journal of Finance*, 56(3), 983-1009.
- Bakshi, G., & Kapadia, N. (2003). "Delta-Hedged Gains and the Negative Market Volatility Risk Premium." *Review of Financial Studies*, 16(2), 527-566.
- Goyal, A., & Saretto, A. (2009). "Cross-Section of Option Returns and Volatility." *Journal of Financial Economics*, 94(2), 310-326.
- Broadie, M., Chernov, M., & Johannes, M. (2009). "Understanding Index Option Returns." *Review of Financial Studies*, 22(11), 4493-4529.
- Israelov, R., & Klein, M. (2016). "Risk and Return of Equity Index Collar Strategies." *The Journal of Alternative Investments*, 19(1), 41-52.

## Implementation Notes

- **Data Requirements**: Real-time options chain data with bid-ask quotes, implied volatility surface, historical realized volatility, and event calendar (earnings dates, FOMC meetings, etc.).
- **Implied vs. Realized Monitoring**: Track the IV-RV spread before entering short positions. The strategy is most profitable when IV rank is high (above 50th percentile) and the VRP is wide. Avoid selling straddles/strangles when IV is already low.
- **Volatility Crush**: Long straddles used as earnings plays must account for the post-earnings IV collapse ("volatility crush"). The underlying must move more than the straddle price implies to be profitable, and the IV crush works against the long holder even when the underlying moves significantly.
- **Delta Management**: Both straddles and strangles drift in delta as the underlying moves. For systematic implementations, delta-hedge periodically (daily or at defined thresholds) to maintain the pure volatility exposure. Alternatively, accept the directional drift as part of the strategy.
- **Crypto Adaptation**: BTC and ETH straddles on Deribit benefit from higher absolute implied volatility (60-100%+ vs. 15-25% for equity indices), generating larger premiums for sellers. However, crypto's higher realized volatility and fat-tailed returns increase the frequency and severity of short-side losses. Short strangles with wider strikes (e.g., delta 0.10-0.15) are recommended for crypto to account for the higher kurtosis. Long straddles can be effective around halving events, regulatory announcements, and protocol upgrades where market underprices the forthcoming volatility.
- **Margin Requirements**: Short straddles and strangles require substantial margin, particularly on high-volatility underlyings. Portfolio margin (SPAN-based) significantly reduces requirements compared to Reg-T margin, making the strategy more capital-efficient for eligible accounts.
