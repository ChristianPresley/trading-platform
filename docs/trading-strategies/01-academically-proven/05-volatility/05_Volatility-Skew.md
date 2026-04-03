# Volatility Skew Trading

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 7
> **Asset Class**: Equity Options / FX Options
> **Crypto/24-7 Applicable**: Adaptable — crypto options on Deribit exhibit persistent skew (puts richer than calls for BTC/ETH), creating a tradeable skew premium, though liquidity across strikes is thinner than in equity options
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

Volatility skew trading exploits the asymmetry in implied volatility across option strike prices. In equity markets, out-of-the-money (OTM) puts consistently have higher implied volatility than OTM calls at equivalent distances from the money — the "volatility smirk." This skew reflects excess demand for downside protection (portfolio hedging) relative to upside exposure, creating a structural overpricing of puts relative to calls.

The primary trading vehicle is the risk reversal: selling an OTM put and buying an OTM call at the same expiration. Because the put's implied volatility is higher, the risk reversal collects net premium (or has a favorable implied volatility spread), profiting if the skew compresses or if realized returns are not as negatively skewed as implied. The strategy is a direct bet on whether the market's pricing of tail risk is too expensive.

The economic rationale is rooted in the observation that equity skew has been persistently "too steep" relative to realized return distributions. Studies show that the implied probability of large downside moves (derived from put prices) systematically exceeds the historical frequency of such moves. This excess skew represents a tradeable premium — analogous to the overall VRP but concentrated in the tails.

However, the skew premium is harder to extract than the ATM VRP because: (a) OTM options have wider bid-ask spreads, (b) the payoff is more binary (the risk reversal either wins or loses significantly), and (c) the strategy has significant delta exposure unless carefully hedged. Institutional implementations often use skew-neutral spread structures (e.g., put spread collars, risk reversal with ATM straddle overlay) to isolate the skew component.

## Trading Rules

1. **Core Trade — Risk Reversal**:
   - Sell a 25-delta put (OTM, typically 5-8% below current price).
   - Buy a 25-delta call (OTM, typically 5-8% above current price).
   - Same expiration, typically 1-3 months.
   - The risk reversal collects net premium when put IV exceeds call IV (normal skew conditions).

2. **Delta Neutralization**: The risk reversal has net positive delta (long call + short put). Delta-hedge at inception using the underlying or futures:
   - Delta to hedge = delta(call) - |delta(put)| + any net premium delta.
   - Re-hedge weekly or when delta drifts beyond +/- 10% of notional.

3. **Skew Signal**: Trade only when the 25-delta risk reversal skew (put IV minus call IV at 25-delta) exceeds its 6-month rolling average by 0.5 standard deviations:
   - This ensures entry when skew is unusually rich, not just normally elevated.
   - Avoid entry when skew is at or below historical average — the premium is insufficient.

4. **Maturity Selection**: 1-3 month expirations offer the best balance of skew premium and theta decay. Shorter expirations have more gamma risk; longer expirations have more vega risk. 2-month is a common sweet spot.

5. **Position Sizing**: Size such that the maximum loss on the short put leg (underlying drops to zero) does not exceed 10% of portfolio. In practice, the 25-delta put has a ~2-5% probability of finishing ITM, making expected losses more manageable.

6. **Exit Rules**:
   - Close at 50% of maximum profit (when the risk reversal's net value has decayed by half).
   - Close if the skew collapses (risk reversal spread narrows to less than 1 vol point) — the edge is gone.
   - Close if the underlying drops more than the short put strike (position becomes a losing directional bet).

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.3-0.6 |
| CAGR | 4-8% (delta-hedged) |
| Max Drawdown | -15% to -30% |
| Win Rate | 60-70% |
| Volatility | 10-18% annualized |
| Profit Factor | 1.2-1.5 |
| Rebalancing | Monthly (option roll), weekly (delta hedge) |

The Sharpe ratio of 0.3-0.6 is lower than the ATM VRP strategy because: (a) skew is more variable and occasionally inverts, (b) OTM options have wider bid-ask spreads that erode the premium, and (c) delta-hedging imprecision introduces noise. The strategy is best used as a complement to ATM VRP capture rather than a standalone allocation. The combination of ATM VRP (via straddles) and skew premium (via risk reversals) provides more robust exposure to the full volatility risk premium surface.

## Efficacy Rating

**Rating: 3/5** — The equity volatility skew premium is well-documented and economically rational (structural demand for OTM puts from institutional hedgers). The 3/5 rating reflects: (a) lower Sharpe than the ATM VRP, making standalone implementation less compelling, (b) higher transaction costs due to wide bid-ask spreads in OTM options, (c) significant delta exposure that requires active hedging, and (d) skew can invert during certain market regimes (strong rallies compress put demand), eliminating the premium entirely. The strategy is most effective as part of a comprehensive volatility premium harvesting program.

## Academic References

- Bollen, N. P. B., & Whaley, R. E. (2004). "Does Net Buying Pressure Affect the Shape of Implied Volatility Functions?" *The Journal of Finance*, 59(2), 711-753.
- Garleanu, N., Pedersen, L. H., & Poteshman, A. M. (2009). "Demand-Based Option Pricing." *The Review of Financial Studies*, 22(10), 4259-4299.
- Xing, Y., Zhang, X., & Zhao, R. (2010). "What Does the Individual Option Volatility Smirk Tell Us About Future Equity Returns?" *Journal of Financial and Quantitative Analysis*, 45(3), 641-662.
- Dennis, P., & Mayhew, S. (2002). "Risk-Neutral Skewness: Evidence from Stock Options." *Journal of Financial and Quantitative Analysis*, 37(3), 471-493.
- Kozhan, R., Neuberger, A., & Schneider, P. (2013). "The Skew Risk Premium in the Equity Index Market." *The Review of Financial Studies*, 26(9), 2174-2203.

## Implementation Notes

- **Bid-Ask Costs**: OTM options have wider percentage bid-ask spreads than ATM options. For SPX 25-delta options, the bid-ask spread is typically 0.3-0.8 vol points, compared to 0.1-0.3 for ATM. This cost must be incorporated into signal thresholds — the skew must exceed transaction costs to be profitable.
- **Skew Measurement**: The standard measure is the 25-delta risk reversal: IV(25-delta put) minus IV(25-delta call). For S&P 500 options, this typically ranges from 4 to 12 vol points. Values above 8 indicate rich skew; values below 4 indicate compressed skew.
- **Event Risk**: Scheduled events (earnings, FOMC, elections) temporarily inflate skew as hedging demand spikes. Post-event, skew normalizes, providing a specific timing signal for entry. Avoid selling skew ahead of major events when it may steepen further.
- **Crypto Adaptation**: BTC and ETH options on Deribit exhibit a similar put skew, though it is less stable and sometimes inverts during bull runs (calls become richer). The skew premium in crypto is noisier but potentially larger due to less sophisticated hedging demand. Use wider entry thresholds (skew > 1.0 standard deviations above average) to compensate for the higher noise. Liquidity is concentrated in BTC and ETH; altcoin options are too illiquid.
- **Vega Risk**: The risk reversal has net vega exposure (short vega from the put, long vega from the call). In a vol spike, the short put vega dominates, creating losses beyond the delta exposure. Pairing with an ATM straddle position can neutralize the vega component.
