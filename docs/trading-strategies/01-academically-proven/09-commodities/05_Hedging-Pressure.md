# Hedging Pressure

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 9
> **Asset Class**: Commodity futures (cross-sectional)
> **Crypto/24-7 Applicable**: No — requires CFTC Commitments of Traders (COT) data distinguishing hedger and speculator positioning, which does not exist for crypto markets
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

The hedging pressure hypothesis, originating with Keynes (1930), Hicks (1939), and Cootner (1960), posits that commercial hedgers (producers and consumers) pay a risk premium to speculators for absorbing price risk. The net hedging pressure (NHP) -- the imbalance between producers' short hedging and consumers' long hedging -- determines whether speculators earn a positive or negative premium. The strategy uses CFTC Commitments of Traders (COT) data to measure hedger vs. speculator positioning and trades in the direction that earns the risk transfer premium.

## Trading Rules

1. **Universe**: 20-30 commodity futures covered by CFTC COT reports
2. **Data source**: Weekly CFTC Commitments of Traders report (released every Friday for positions as of Tuesday)
3. **Signal**: Compute net hedging pressure as (commercial short positions - commercial long positions) / total commercial positions for each commodity
4. **Long leg**: Buy commodities where hedgers are net short (producers dominating, positive NHP) -- speculators earn a long premium
5. **Short leg**: Sell commodities where hedgers are net long (consumers dominating, negative NHP) -- speculators earn a short premium
6. **Holding period**: 1 month (rebalance monthly after COT data release)
7. **Weighting**: Equal-weight within each leg
8. **Threshold variant**: Only trade when NHP exceeds a threshold (e.g., top/bottom quartile) to avoid noisy signals

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.2-0.4 (varies by study) |
| CAGR | ~3-6% (long-short) |
| Max Drawdown | ~25-40% |
| Win Rate | ~52-55% |
| Volatility | ~15-20% |
| Profit Factor | ~1.2-1.3 |
| Rebalancing | Monthly |

## Efficacy Rating

**3/5** — Theoretically compelling with deep roots in the Keynes-Hicks framework. Bessembinder (1992) and De Roon, Nijman, and Veld (2000) find empirical support for contemporaneous hedging pressure effects. However, more recent studies (Gorton et al., 2012; Szymanowska et al., 2014) find weaker or no predictive power, suggesting the relationship may have changed with the financialization of commodity markets. The reliance on weekly COT data introduces signal lag, and the distinction between "commercial" and "non-commercial" traders has become less meaningful as financial participants increasingly use commercial hedging designations.

## Academic References

- Keynes, J. M. (1930). *A Treatise on Money*, Vol. 2. London: Macmillan.
- Cootner, P. H. (1960). "Returns to Speculators: Telser versus Keynes." *Journal of Political Economy*, 68(4), 396-404.
- Bessembinder, H. (1992). "Systematic Risk, Hedging Pressure, and Risk Premiums in Futures Markets." *Review of Financial Studies*, 5(4), 637-667.
- De Roon, F. A., Nijman, T. E., & Veld, C. (2000). "Hedging Pressure Effects in Futures Markets." *Journal of Finance*, 55(3), 1437-1456.
- Gorton, G., Hayashi, F., & Rouwenhorst, K. G. (2013). "The Fundamentals of Commodity Futures Returns." *Review of Finance*, 17(1), 35-105.
- Basu, D. & Miffre, J. (2013). "Capturing the Risk Premium of Commodity Futures: The Role of Hedging Pressure." *Journal of Banking & Finance*, 37(7), 2652-2664.

## Implementation Notes

- **COT data lag**: COT data reflects positions as of Tuesday but is released Friday evening; the 3-day lag means the signal is stale by the time it can be traded
- **Classification problems**: The CFTC's "commercial" category includes entities that qualify for hedging exemptions but may be engaged in speculative activity; the signal is noisier than it appears
- **Financialization**: Since 2004, large commodity index fund inflows have distorted positioning data, as index replication is classified as speculative even though it is passive and non-directional
- **Cross-commodity effects**: De Roon et al. (2000) find that hedging pressure in related commodities (e.g., soybeans affecting soybean oil) has cross-predictive power; a multi-commodity signal may be more robust than single-commodity NHP
- **Combining signals**: Hedging pressure adds value when combined with momentum and term structure signals, as it captures a distinct (risk transfer) source of return
- **Capacity**: Similar to other commodity cross-sectional strategies; the strategy is capacity-constrained in less liquid agricultural and livestock markets
