# VIX Futures Basis (Term Structure)

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 7, [Quantpedia — Exploiting Term Structure of VIX Futures](https://quantpedia.com/strategies/exploiting-term-structure-of-vix-futures)
> **Asset Class**: Volatility Futures
> **Crypto/24-7 Applicable**: No — VIX futures are specific to the CBOE/CFE ecosystem with no crypto equivalent of sufficient liquidity and term structure depth
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

The VIX futures basis strategy exploits the persistent term structure of VIX futures, which spend approximately 80-85% of the time in contango (longer-dated futures priced above shorter-dated ones or spot VIX). This contango reflects the insurance premium embedded in volatility protection: investors pay more for longer-dated vol insurance, creating an upward-sloping term structure that generates negative roll yield for long VIX positions and positive roll yield for short positions.

The strategy profits by selling near-term VIX futures (or going long inverse VIX ETPs) during contango, capturing the roll yield as futures converge toward the lower spot VIX at expiration. Conversely, during the rarer periods of backwardation (VIX spikes, typically during market stress), the strategy reverses to go long near-term VIX futures, capturing the roll yield as futures converge upward toward the elevated spot VIX.

The magnitude of the contango roll yield is substantial. The first-month VIX future typically decays 3-7% per month toward spot VIX during normal contango, generating annualized returns of 30-60% before accounting for the occasional severe loss during VIX spikes. The CBOE S&P 500 Short VIX Short-Term Futures Index (SHORTVOL) demonstrates the long-term profitability of a naive short VIX futures strategy, though the return path includes extreme drawdowns (notably February 2018's "Volmageddon" and March 2020).

The term structure slope (ratio of second-month to first-month VIX future) serves as the primary trading signal. A higher contango ratio indicates a stronger roll yield premium and better entry conditions for short positions.

## Trading Rules

1. **Term Structure Measurement**:
   - Compute the VIX futures roll: `Roll = VX2/VX1 - 1` where VX1 is the front-month and VX2 is the second-month VIX future.
   - Contango: Roll > 0 (typically 3-8%).
   - Backwardation: Roll < 0 (typically seen when VIX > 25-30).

2. **Contango Regime (Roll > +2%)**:
   - Short the front-month VIX future.
   - Alternatively, go long SVXY (0.5x inverse VIX short-term futures ETF) for a position-size-limited version.
   - Roll the short position 5-7 trading days before expiration to the next month to avoid expiration volatility.

3. **Backwardation Regime (Roll < -2%)**:
   - Go long the front-month VIX future.
   - Alternatively, go long VXX or UVXY for leveraged exposure.
   - This position profits from the convergence of futures upward toward elevated spot VIX.

4. **Neutral Zone (Roll between -2% and +2%)**:
   - Reduce position size by 50% or go flat. The roll yield is insufficient to compensate for the risk of a regime change.

5. **Position Sizing**:
   - Short VIX positions: Size so that a 100% overnight VIX spike (e.g., VIX from 15 to 30) would produce a maximum portfolio loss of 15-20%.
   - Long VIX positions: Size based on theta decay risk (VIX futures lose ~1-2% per week in backwardation as the curve normalizes).

6. **Risk Overlay**: Always monitor the VIX level itself. If VIX exceeds 35 while in a short position, close regardless of term structure slope — the risk of further spikes outweighs roll yield.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.5-1.0 (strategy dependent) |
| CAGR | 15-30% (short VIX during contango only) |
| Max Drawdown | -40% to -75% (Volmageddon, COVID) |
| Win Rate | 65-75% (monthly) |
| Volatility | 25-45% annualized |
| Profit Factor | 1.5-2.5 |
| Rebalancing | Monthly (futures roll) |

The wide range in metrics reflects the extreme sensitivity to position sizing and risk management. Naive short VIX strategies have the highest raw returns but catastrophic drawdowns (XIV lost 96% in a single day in February 2018). Volatility-targeted versions that scale exposure inversely to VIX level produce Sharpe ratios at the higher end of the range (0.8-1.0) with drawdowns of 20-40% — still large but survivable.

## Efficacy Rating

**Rating: 4/5** — The VIX contango premium is economically real and structurally persistent (driven by demand for portfolio insurance). The deduction reflects the strategy's extreme tail risk (February 2018 destroyed multiple funds and ETPs), the high volatility of returns even in normal periods, and the psychological difficulty of maintaining positions through 30-50% drawdowns. The strategy is viable only with disciplined position sizing, volatility targeting, and a willingness to accept extended recovery periods after tail events.

## Academic References

- Alexander, C., & Korovilas, D. (2013). "Diversification of Equity with VIX Futures: Personal Views and Skewness Preference." *Quantitative Finance*, 13(7), 1071-1083.
- Eraker, B., & Wu, Y. (2017). "Explaining the Negative Returns to VIX Futures and ETNs: An Equilibrium Approach." *Journal of Financial Economics*, 125(1), 72-98.
- Daigler, R. T., & Rossi, L. (2006). "A Portfolio of Stocks and Volatility." *Journal of Investing*, 15(2), 99-106.
- Simon, D. P., & Campasano, J. (2014). "The VIX Futures Basis: Evidence and Trading Strategies." *Journal of Derivatives*, 21(3), 54-69.
- Szado, E. (2009). "VIX Futures and Options: A Case Study of Portfolio Diversification During the 2008 Financial Crisis." *Journal of Alternative Investments*, 12(2), 68-85.

## Implementation Notes

- **Instruments**: VIX futures (VX) trade on CBOE Futures Exchange (CFE) with monthly expiration. Mini VIX futures offer smaller notional sizes. VIX options provide capped-risk alternatives. ETPs (SVXY, VXX, UVXY) offer accessible exposure but introduce tracking error and path dependency.
- **ETP Decay**: Leveraged and inverse VIX ETPs suffer from volatility decay (the constant-leverage trap). VXX has lost approximately 99.9% of its value since inception due to persistent contango roll costs. SVXY captures only 0.5x inverse exposure (reduced from 1.0x after the 2018 event). These instruments are suitable for short-term trading but not long-term holding.
- **February 2018 (Volmageddon)**: On February 5, 2018, the VIX spiked 116% intraday, causing XIV to lose 96% of its value and triggering termination of the product. SVXY lost 90% and was restructured to 0.5x leverage. This event demonstrates the importance of position sizing and the risks of products with embedded leverage.
- **Margin Considerations**: Short VIX futures require significant margin (typically $5,000-$15,000 per contract, increasing during volatility). Margin calls during VIX spikes can force liquidation at the worst time. Always maintain excess margin of at least 50% above initial requirements.
- **Timing Enhancement**: The VIX Futures Term Structure (VXST/VIX ratio, VIX/VXV ratio, or VIX/VXMT ratio) provides additional timing signals. Extreme contango (VIX/VXV < 0.85) tends to precede mean reversion. Combining term structure slope with VIX level improves timing.
