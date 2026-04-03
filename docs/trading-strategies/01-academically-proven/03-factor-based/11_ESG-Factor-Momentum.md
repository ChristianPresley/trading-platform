# ESG Factor Momentum

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: Adaptable — ESG-like scoring is emerging for crypto (energy use, governance transparency)
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

ESG Factor Momentum exploits the tendency of companies with improving Environmental, Social, and Governance (ESG) ratings to outperform companies with deteriorating ESG ratings. Unlike static ESG tilt strategies (which simply overweight high-ESG firms), the momentum approach focuses on the *change* in ESG scores -- buying firms whose ESG ratings are improving and shorting firms whose ratings are declining. Nagy, Kassam, and Lee (2016) demonstrated that this ESG momentum strategy outperformed the MSCI World Index over their sample period while also improving portfolio ESG characteristics. The effect is attributed to the market's slow reaction to fundamental improvements in corporate sustainability practices, with ESG upgrades signaling positive operational and reputational changes that are not immediately priced.

## Trading Rules

1. **Universe**: All stocks in a broad global index (e.g., MSCI World or MSCI ACWI) with ESG ratings from a major provider (MSCI, Sustainalytics, Refinitiv).
2. **Signal**: At the end of each month, compute the year-over-year change in each firm's ESG rating (ESG score at time t minus ESG score at time t-12).
3. **Sort**: Rank all stocks by ESG rating change into quintiles or deciles.
4. **Long Portfolio**: Buy stocks in the top quintile (largest ESG rating improvements).
5. **Short Portfolio**: Sell short stocks in the bottom quintile (largest ESG rating deteriorations).
6. **Weighting**: Market-cap-weight or equal-weight positions within each portfolio leg.
7. **Rebalancing**: Monthly.
8. **Holding Period**: One month, then re-sort and rebalance.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.559 |
| CAGR | ~8-12% |
| Max Drawdown | ~35-40% |
| Win Rate | ~55% |
| Volatility | 21.8% |
| Profit Factor | ~1.3 |
| Rebalancing | Monthly |

## Efficacy Rating

**3 / 5** -- ESG factor momentum is an interesting and relatively novel factor with solid initial academic support. The Sharpe ratio of 0.559 is respectable, suggesting a genuine return premium. However, it receives a 3 rather than 4 because: (1) the relatively short out-of-sample history limits confidence in robustness, (2) ESG ratings are subjective and vary significantly across providers (low inter-rater reliability), (3) high volatility (21.8%) indicates noisy signals, and (4) the rapid growth of ESG-aware capital may erode the premium as markets become more efficient at pricing ESG information. The strategy is most compelling as a complement to traditional factors rather than a standalone approach.

## Academic References

- Nagy, Z., Kassam, A., and Lee, L.E. (2016). "Can ESG Add Alpha? An Analysis of ESG Tilt and Momentum Strategies." *The Journal of Investing*, 25(2), 113-124.
- Giese, G., Lee, L.E., Melas, D., Nagy, Z., and Nishikawa, L. (2019). "Foundations of ESG Investing: How ESG Affects Equity Valuation, Risk, and Performance." *The Journal of Portfolio Management*, 45(5), 69-83.
- Pedersen, L.H., Fitzgibbons, S., and Pomorski, L. (2021). "Responsible Investing: The ESG-Efficient Frontier." *Journal of Financial Economics*, 142(2), 572-597.
- Berg, F., Koelbel, J.F., and Rigobon, R. (2022). "Aggregate Confusion: The Divergence of ESG Ratings." *Review of Finance*, 26(6), 1315-1344.
- Pastor, L., Stambaugh, R.F., and Taylor, L.A. (2021). "Sustainable Investing in Equilibrium." *Journal of Financial Economics*, 142(2), 550-571.

## Implementation Notes

- **Rating Provider Divergence**: ESG ratings from different providers (MSCI, Sustainalytics, Refinitiv, Bloomberg) have notoriously low correlation (~0.4-0.6). The choice of provider significantly affects portfolio composition and returns. Consider using multiple providers or focusing on the most objective sub-components.
- **Greenwashing Risk**: Some ESG improvements may reflect better reporting or PR rather than genuine operational improvements. Focus on material ESG factors that are relevant to each industry.
- **Regulatory Tailwinds**: Increasing ESG regulation (EU SFDR, SEC climate disclosure rules) may strengthen the ESG momentum effect as more capital is directed toward ESG-improving firms.
- **Crypto Adaptation**: Nascent ESG-like frameworks for crypto include energy consumption (proof-of-work vs. proof-of-stake transitions), governance decentralization scores, and transparency metrics. A protocol improving on these dimensions could be analogous to an ESG upgrade.
- **Capacity**: The strategy may have limited capacity, as ESG momentum is a crowded trade among institutional asset managers; position sizing should account for potential crowding effects.
