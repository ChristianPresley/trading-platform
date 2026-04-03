# WTI-Brent Spread

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading) / [Quantpedia](https://quantpedia.com/strategies/trading-wti-brent-spread)
> **Asset Class**: Commodity futures (crude oil pairs)
> **Crypto/24-7 Applicable**: No — this is a specific crude oil intermarket spread with no crypto analog
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

The WTI-Brent spread is the price difference between West Texas Intermediate (NYMEX) and Brent crude oil (ICE) futures. Because WTI and Brent are close substitutes (both light, sweet crude oils), their prices are cointegrated over the long term, and the spread mean-reverts around a fair value determined by transportation costs, pipeline capacity, refinery demand differentials, and geopolitical factors. The strategy trades deviations from this fair value, going long the spread when it is below fair value and short when above. Despite the theoretical appeal, backtested performance has been poor, with a negative Sharpe ratio.

## Trading Rules

1. **Instruments**: WTI crude oil futures (CL, NYMEX) and Brent crude oil futures (BRN, ICE)
2. **Spread calculation**: Spread = WTI price - Brent price (or Brent - WTI, depending on convention)
3. **Fair value estimation**: Compute the rolling mean of the spread over 60-120 trading days
4. **Entry (long spread)**: When the spread falls below fair value by more than 1.5-2.0 standard deviations, buy WTI and sell Brent
5. **Entry (short spread)**: When the spread rises above fair value by more than 1.5-2.0 standard deviations, sell WTI and buy Brent
6. **Exit**: Close when the spread reverts to the rolling mean (or within 0.5 standard deviations)
7. **Stop-loss**: Close at 3.0 standard deviations from the mean to limit losses from structural breaks
8. **Position sizing**: Equal notional value on both legs

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | -0.199 |
| CAGR | ~-1 to -3% |
| Max Drawdown | ~20-30% |
| Win Rate | ~48-52% |
| Volatility | 11.6% |
| Profit Factor | ~0.9 |
| Rebalancing | Daily |

## Efficacy Rating

**2/5** — The mean-reversion thesis is economically sound, but the strategy has historically produced negative risk-adjusted returns. The negative Sharpe ratio of -0.199 indicates that the spread is not reliably mean-reverting within the timeframe and parameter ranges typically tested. Structural breaks in the spread (e.g., the 2011-2014 WTI discount caused by the U.S. shale boom and Cushing pipeline bottlenecks) can persist for years, overwhelming any mean-reversion alpha. The strategy may work in specific regimes but is not robust across the full sample.

## Academic References

- Fattouh, B. (2010). "The Dynamics of Crude Oil Price Differentials." *Energy Economics*, 32(2), 334-342.
- Buyuksahin, B., Haigh, M. S., Harris, J. H., Overdahl, J. A., & Robe, M. A. (2008). "Fundamentals, Trader Activity and Derivative Pricing." Working Paper, CFTC.
- Scheitrum, D. P., Carter, C. A., & Revoredo-Giha, C. (2018). "WTI and Brent Futures Pricing Structure." *Energy Economics*, 72, 462-469.
- Bunn, D. & Chevallier, J. (2022). "Determinants of the WTI-Brent Price Spread Revisited." *Journal of Futures Markets*, 42(7), 1337-1356.

## Implementation Notes

- **Structural break risk**: The WTI-Brent spread experienced a massive structural shift from 2011-2014 when WTI traded at a sustained $10-25/barrel discount to Brent due to Cushing, Oklahoma pipeline constraints and the U.S. shale oil boom. Mean-reversion strategies were severely punished during this period
- **Regime detection**: Consider incorporating regime-switching models (Markov switching) or structural break tests before deploying the strategy; only trade mean-reversion in stable regimes
- **Cointegration testing**: Regularly test for cointegration between WTI and Brent using Johansen or Engle-Granger methods; if cointegration breaks down, stop trading
- **Spread drivers**: Monitor key fundamental factors: Cushing inventory levels, pipeline capacity utilization, OPEC production decisions, U.S. export policy, and North Sea production disruptions
- **Execution**: The spread can be traded directly using CME's WTI-Brent spread futures (BK) or by legging into the two contracts separately; the listed spread product reduces execution risk
- **Margin efficiency**: Exchanges offer spread margin credits for WTI-Brent positions, significantly reducing capital requirements
- **Not recommended standalone**: Given the negative historical Sharpe ratio, this strategy should only be considered as part of a broader commodity relative value book with active fundamental monitoring and regime awareness
