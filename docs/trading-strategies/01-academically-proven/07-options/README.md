# Options Strategies

Systematic options strategies that exploit the structural properties of options markets — the variance risk premium, time decay, put-call parity, and the bounded payoff characteristics of multi-leg structures. These approaches range from simple income overlays to complex multi-legged volatility and hedging structures.

## Strategies

| # | Strategy | Sharpe | Rating | Crypto |
|---|----------|--------|--------|--------|
| 01 | [Covered Call and Protective Put](01_Covered-Call-And-Protective-Put.md) | 0.54 (BXM) | 5/5 | Adaptable |
| 02 | [Vertical Spreads](02_Vertical-Spreads.md) | 0.4-0.8 | 5/5 | Adaptable |
| 03 | [Straddles and Strangles](03_Straddles-And-Strangles.md) | 0.3-0.6 (short) | 5/5 | Adaptable |
| 04 | [Butterflies and Condors](04_Butterflies-And-Condors.md) | 0.3-0.7 | 4/5 | Adaptable |
| 05 | [Calendar and Diagonal Spreads](05_Calendar-And-Diagonal-Spreads.md) | 0.4-0.8 | 4/5 | Adaptable |
| 06 | [Collar and Seagull](06_Collar-And-Seagull.md) | 0.4-0.6 | 4/5 | Adaptable |
| 07 | [Synthetic Positions](07_Synthetic-Positions.md) | Matches underlying | 4/5 | Adaptable |

## Key Concepts

- **Variance Risk Premium (VRP)**: The persistent tendency of implied volatility to exceed subsequent realized volatility (~85-90% of the time). This premium compensates option sellers for bearing tail risk and is the primary structural edge exploited by short volatility strategies (covered calls, short straddles/strangles, iron condors).
- **Time Decay (Theta)**: Options lose value as expiration approaches, with the decay accelerating in the final 30-45 days. Strategies that are net short options (covered calls, credit spreads, iron condors, calendar spreads) collect this decay as income.
- **Put-Call Parity**: The fundamental relationship linking calls, puts, the underlying, and risk-free bonds. This equivalence means every option strategy has a synthetic counterpart, and apparent complexity can always be decomposed into simpler building blocks.
- **Greeks**: Delta (directional exposure), gamma (rate of delta change), theta (time decay), vega (volatility sensitivity), and rho (interest rate sensitivity) fully characterize an option position's risk profile and are essential for managing multi-leg strategies.
- **Defined Risk**: Multi-leg strategies (verticals, butterflies, condors, collars) cap the maximum possible loss, making risk management explicit and position sizing straightforward. This contrasts with naked options (short straddles, uncovered calls) where losses are theoretically unlimited.

## Common Risk Factors

- **Tail risk and negative skewness**: Short volatility strategies collect small premiums consistently but face occasional large losses during market dislocations. The VRP exists precisely because sellers are compensated for bearing this crash risk.
- **Volatility crush and expansion**: Long option positions suffer when implied volatility declines (even if the underlying moves favorably), while short positions benefit. Conversely, short positions can face sudden losses when IV spikes, particularly around unexpected events.
- **Liquidity and execution risk**: Multi-leg strategies require simultaneous execution of 2-4 option legs. Wide bid-ask spreads, particularly in less liquid underlyings or during volatile markets, can significantly erode edge. Legging into complex positions creates execution risk.
- **Pin risk and assignment**: Near expiration, positions with short legs near ATM face uncertain assignment risk. Early assignment (American-style options) can disrupt hedge ratios and create unexpected stock positions.
- **Model risk**: Options pricing relies on models (Black-Scholes, binomial) that assume specific distributional properties. Real-world returns exhibit fat tails, jumps, and stochastic volatility that models imperfectly capture, creating residual risk in any model-dependent strategy.
- **Margin and capital risk**: Short option strategies require margin that can increase during volatile markets, potentially forcing position liquidation at unfavorable prices. Portfolio margin provides relief but requires higher account minimums and regulatory approval.
