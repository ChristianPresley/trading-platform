# Variance Swaps

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 7, [Carr & Wu (2009)](https://engineering.nyu.edu/sites/default/files/2019-01/CarrReviewofFinStudiesMarch2009-a.pdf)
> **Asset Class**: Volatility Derivatives (OTC)
> **Crypto/24-7 Applicable**: No — variance swaps are OTC institutional instruments with no crypto market equivalent; the closest crypto analog would be selling straddles on Deribit, which is a different product
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

A variance swap is an OTC derivative contract whose payoff is the difference between realized variance and a pre-agreed strike (the "variance strike"), multiplied by a notional amount (the "variance notional"). The long side profits when realized variance exceeds the strike; the short side profits when realized variance is below the strike. Because implied variance systematically exceeds realized variance (the variance risk premium), selling variance swaps generates positive expected returns.

Variance swaps offer a theoretically cleaner exposure to the volatility risk premium than delta-hedged options. A perfectly replicated variance swap has a payoff that is linear in realized variance, regardless of the path the underlying takes. This is achieved through a static portfolio of options across all strikes (a "log contract"), combined with dynamic delta hedging of the underlying. In practice, the replication is approximate due to the finite set of listed strikes and the inability to hedge jumps.

Carr and Wu (2009) documented that the variance risk premium is large and negative (from the long variance buyer's perspective) across multiple asset classes. For S&P 500 variance swaps, the average monthly excess return for short variance positions is approximately 2-3% (annualized 25-35%), but with extreme negative skewness. The variance strike typically exceeds realized variance by 15-25% on a squared volatility basis — a substantial premium that compensates for the left-tail risk of being short variance during market crashes.

The term structure of variance risk premia adds a second dimension: short-dated variance swaps have higher variance risk premia per unit time than longer-dated ones, consistent with the observation that near-term uncertainty commands a larger insurance premium. This creates opportunities for calendar spread strategies that go long one maturity and short another.

## Trading Rules

1. **Core Trade**: Sell 1-month or 3-month variance swaps on the S&P 500 (or other liquid equity index).
   - Variance notional sized such that a move from 15% to 50% realized vol produces a loss no greater than 10% of portfolio.
   - Payoff: `Variance Notional * (Realized Variance - Variance Strike)`
   - Short side profits when Realized Variance < Variance Strike.

2. **Strike Negotiation**: The variance strike is set at trade inception based on the current implied variance surface. It is typically close to the ATM implied variance but includes adjustments for skew and convexity.

3. **Maturity Selection**:
   - **1-month**: Highest VRP per unit time, most theta decay, but most gamma/jump risk.
   - **3-month**: Lower VRP per month but smoother P&L and lower sensitivity to short-term spikes.
   - **Calendar spread**: Short 1-month variance, long 3-month variance. Captures the term structure differential while partially hedging tail risk.

4. **Timing Signal**: The VRP is time-varying. Larger short variance positions when:
   - VIX is above 20 (higher implied variance = more premium to collect).
   - VIX/realized vol spread exceeds 5 points.
   - Reduce when VIX is below 12 (low-vol regimes offer thin premium and elevated risk of regime change).

5. **Risk Limits**:
   - Maximum vega exposure: 1% of portfolio per vol point move.
   - Stop-loss: Close if realized variance exceeds the variance strike by 50% (e.g., strike at 225 = 15 vol, close if realized variance reaches 337 = 18.4 vol annualized equivalent).
   - Hard limit: Never be short more than 2 variance notional units.

6. **Capped Variance Swaps**: Where available, use capped variance swaps that limit the maximum realized variance payout (typically capped at 2.5x the strike). This truncates the left tail at the cost of a lower strike (less premium collected).

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.5-0.8 (depending on maturity and sizing) |
| CAGR | 8-15% (risk-managed) |
| Max Drawdown | -25% to -50% (2008, 2020) |
| Win Rate | 70-80% (monthly, short variance) |
| Volatility | 15-25% annualized |
| Profit Factor | 1.4-1.8 |
| Rebalancing | Monthly (roll) or quarterly |

Carr and Wu (2009) reported that the annualized Sharpe ratio for short S&P 500 variance positions was approximately 1.7 in their sample — dramatically higher than the equity risk premium. However, this overstates the achievable Sharpe because: (a) variance swaps have significant transaction costs (bid-ask spreads of 0.5-1.5 vol points), (b) the sample excluded the 2008 crisis, and (c) the extreme kurtosis of variance swap returns means Sharpe ratio understates true risk. Post-cost, post-crisis Sharpe ratios of 0.5-0.8 are more realistic.

## Efficacy Rating

**Rating: 3/5** — Variance swaps provide the purest exposure to the variance risk premium, making them theoretically superior to delta-hedged options strategies. The 3/5 rating reflects: (a) the strategy is accessible only to institutional investors (OTC market, ISDA agreements, credit requirements), (b) the extreme negative skewness of returns creates existential risk without rigorous position sizing, (c) marked-to-market losses during vol spikes create margin pressure even if the swap eventually expires profitably, and (d) counterparty risk in OTC markets is non-trivial.

## Academic References

- Carr, P., & Wu, L. (2009). "Variance Risk Premiums." *The Review of Financial Studies*, 22(3), 1311-1341.
- Demeterfi, K., Derman, E., Kamal, M., & Zou, J. (1999). "More Than You Ever Wanted to Know About Volatility Swaps." Goldman Sachs Quantitative Strategies Research Notes.
- Bossu, S., Strasser, E., & Guichard, R. (2005). "Just What You Need to Know About Variance Swaps." JPMorgan Equity Derivatives Research.
- Egloff, D., Leippold, M., & Wu, L. (2010). "The Term Structure of Variance Swap Rates and Optimal Variance Swap Investments." *Journal of Financial and Quantitative Analysis*, 45(5), 1279-1310.
- Dark, J. (2022). "Forecasting Variance Swap Payoffs." *Journal of Futures Markets*, 42(11), 2135-2164.
- Ait-Sahalia, Y., Karaman, M., & Mancini, L. (2020). "The Term Structure of Variance Swaps and Risk Premia." *Journal of Econometrics*, 219(2), 204-230.

## Implementation Notes

- **Access Requirements**: Variance swaps trade OTC between dealers and institutional clients. Access requires an ISDA Master Agreement, credit support annex (CSA), and typically a minimum trade size of $50,000-$100,000 vega notional. This is not accessible to retail traders.
- **Retail Alternatives**: Listed options can approximate variance swap exposure. A portfolio of options across many strikes (a "variance strip") replicates the variance swap payoff. In practice, selling an ATM straddle and delta-hedging captures most of the VRP, though with path-dependent residual risk.
- **Convexity**: Variance swaps have convex payoffs — the loss from a given increase in realized variance exceeds the gain from an equal decrease. This asymmetry is why variance strikes are set above ATM implied volatility (to compensate for the convexity premium sellers face). Capped variance swaps eliminate the unbounded loss tail.
- **Mark-to-Market Risk**: Even if a short variance swap expires profitably, it can show significant mark-to-market losses during the life of the trade when implied variance spikes. This creates margin calls and potential forced unwinds. Initial margin requirements are typically 20-40% of maximum potential loss.
- **Model Risk**: Variance swap pricing relies on the availability of a continuum of option strikes. In practice, the finite number of listed strikes and the extrapolation of the volatility surface beyond listed strikes introduces model risk, particularly in the tails.
