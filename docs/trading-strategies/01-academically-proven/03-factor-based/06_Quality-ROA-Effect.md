# Quality Factor (ROA Effect)

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: Adaptable — protocol revenue and asset metrics are emerging for DeFi projects
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

The quality factor based on Return on Assets (ROA) captures the tendency of highly profitable firms to outperform less profitable ones. ROA, defined as net income divided by total assets, measures how efficiently a firm converts its asset base into earnings. The profitability premium was documented across multiple studies and ultimately formalized as the RMW (Robust Minus Weak) factor in the Fama-French five-factor model (2015). The economic rationale centers on the market's tendency to underreact to persistent profitability differences: investors systematically undervalue firms with high, stable profitability while overpaying for firms with weak profitability but speculative growth potential. While ROA is a simple single-metric approach to quality, it captures a meaningful slice of the broader quality premium.

## Trading Rules

1. **Universe**: All common stocks on major exchanges with available income statement and balance sheet data.
2. **Signal**: At the end of each month, compute ROA (trailing 12-month net income / total assets) for each stock.
3. **Sort**: Rank all stocks by ROA into deciles.
4. **Long Portfolio**: Buy stocks in the top decile (highest ROA -- most profitable firms).
5. **Short Portfolio**: Sell short stocks in the bottom decile (lowest ROA -- least profitable or loss-making firms).
6. **Weighting**: Equal-weight or value-weight positions within each portfolio leg.
7. **Rebalancing**: Monthly.
8. **Holding Period**: One month, then re-sort and rebalance.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.155 |
| CAGR | ~2-3% (long-short spread) |
| Max Drawdown | ~30-35% |
| Win Rate | ~52% |
| Volatility | 8.7% |
| Profit Factor | ~1.1 |
| Rebalancing | Monthly |

## Efficacy Rating

**3 / 5** -- The ROA-based quality factor captures a real and economically meaningful effect, but as a standalone signal its performance is modest. The Sharpe ratio of 0.155 is below the threshold typically considered attractive for a standalone strategy. The low volatility (8.7%) is a positive feature, but the weak risk-adjusted return limits its utility as a primary signal. The quality factor is far more powerful when: (1) combined with other quality metrics (gross profitability, operating margins, earnings stability, low leverage), (2) used in conjunction with value or momentum factors, or (3) implemented as a composite quality score. As part of a multi-factor framework, quality is indispensable.

## Academic References

- Fama, E.F. and French, K.R. (2015). "A Five-Factor Asset Pricing Model." *Journal of Financial Economics*, 116(1), 1-22.
- Novy-Marx, R. (2013). "The Other Side of Value: The Gross Profitability Premium." *Journal of Financial Economics*, 108(1), 1-28.
- Asness, C.S., Frazzini, A., and Pedersen, L.H. (2019). "Quality Minus Junk." *Review of Accounting Studies*, 24(1), 34-112.
- Haugen, R.A. and Baker, N.L. (1996). "Commonality in the Determinants of Expected Stock Returns." *Journal of Financial Economics*, 41(3), 401-439.
- Ball, R., Gerakos, J., Linnainmaa, J.T., and Nikolaev, V. (2015). "Deflating Profitability." *Journal of Financial Economics*, 117(2), 225-248.

## Implementation Notes

- **Composite Quality**: ROA alone is a weak signal; combining ROA with gross profitability (Novy-Marx, 2013), earnings stability, low leverage, and low accruals creates a significantly stronger composite quality factor.
- **Accounting Differences**: ROA definitions vary across data providers; standardize the calculation and be aware of industry-specific differences (e.g., financial firms have naturally different asset structures).
- **Interaction with Value**: Quality and value factors have low or negative correlation, making them excellent diversifiers in a multi-factor portfolio. The "quality at a reasonable price" (QARP) combination is particularly effective.
- **Crypto Adaptation**: For DeFi protocols, ROA analogues include protocol revenue relative to TVL, fee revenue relative to fully diluted valuation, or token holder yield. Data availability and standardization remain significant challenges.
- **Persistence**: Focus on persistent profitability rather than one-time spikes; use multi-year average ROA or median ROA over rolling windows.
