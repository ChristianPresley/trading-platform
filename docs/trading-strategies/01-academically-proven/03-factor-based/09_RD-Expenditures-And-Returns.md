# R&D Expenditures and Stock Returns

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: Adaptable — development activity metrics (GitHub commits, developer count) could proxy for R&D
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

The R&D expenditures anomaly documents that firms spending heavily on research and development earn higher subsequent stock returns than firms with low or zero R&D spending. This is counterintuitive from an efficient-market perspective: R&D is risky, uncertain, and expensed immediately under GAAP accounting (depressing current earnings), yet investors appear to systematically undervalue the option-like payoffs from innovation. The effect is related to the broader intangibles mispricing literature, where accounting rules that expense intangible investments cause firms with high intangible investment to appear less profitable than they truly are. The R&D premium has been documented across U.S. and international equity markets, with the strongest effects among firms where R&D intensity is high relative to total assets or market capitalization.

## Trading Rules

1. **Universe**: All common stocks on major exchanges with available R&D expenditure data (excluding firms with zero R&D).
2. **Signal**: At the end of each year, compute R&D intensity as R&D expenditures / total assets (or R&D / market capitalization).
3. **Sort**: Rank all stocks with positive R&D by R&D intensity into quintiles or deciles.
4. **Long Portfolio**: Buy stocks in the top quintile (highest R&D intensity).
5. **Short Portfolio**: Sell short stocks in the bottom quintile (lowest R&D intensity among R&D-performing firms).
6. **Weighting**: Equal-weight positions within each portfolio leg.
7. **Rebalancing**: Annually (after annual reports are available).
8. **Holding Period**: One year, then re-sort and rebalance.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.354 |
| CAGR | ~4-6% (long-short spread) |
| Max Drawdown | ~25-30% |
| Win Rate | ~53% |
| Volatility | 8.1% |
| Profit Factor | ~1.2 |
| Rebalancing | Yearly |

## Efficacy Rating

**3 / 5** -- The R&D expenditures effect is a genuine anomaly with sound economic logic (accounting-driven mispricing of intangible investments) and reasonable empirical support. The Sharpe ratio of 0.354 is moderate, and the notably low volatility (8.1%) is attractive. However, the strategy receives a 3 rather than 4 because: (1) the universe is restricted to R&D-intensive firms, limiting breadth, (2) R&D data is noisy and sector-concentrated (technology, healthcare, industrials), and (3) the effect is partly subsumed by profitability and investment factors in multi-factor models. It adds value as a sector-specific tilt or supplementary signal.

## Academic References

- Chan, L.K.C., Lakonishok, J., and Sougiannis, T. (2001). "The Stock Market Valuation of Research and Development Expenditures." *Journal of Finance*, 56(6), 2431-2456.
- Lev, B. and Sougiannis, T. (1996). "The Capitalization, Amortization, and Value-Relevance of R&D." *Journal of Accounting and Economics*, 21(1), 107-138.
- Eberhart, A.C., Maxwell, W.F., and Siddique, A.R. (2004). "An Examination of Long-Term Abnormal Stock Returns and Operating Performance Following R&D Increases." *Journal of Finance*, 59(2), 623-650.
- Li, D. (2011). "Financial Constraints, R&D Investment, and Stock Returns." *Review of Financial Studies*, 24(9), 2974-3007.
- Hou, K., Xue, C., and Zhang, L. (2020). "Replicating Anomalies." *Review of Financial Studies*, 33(5), 2019-2133.

## Implementation Notes

- **Sector Concentration**: R&D-intensive firms cluster in technology, biotech/pharma, and industrials. Consider sector-neutral implementations to avoid unintended sector bets.
- **Accounting Treatment**: Under GAAP, R&D is expensed; under IFRS, development costs can be capitalized. Ensure consistency when applying across international markets.
- **R&D Quality**: Not all R&D spending is productive. Combining R&D intensity with patent output, citation metrics, or innovation efficiency ratios can improve signal quality.
- **Crypto Adaptation**: Developer activity (GitHub commits, unique contributors, protocol upgrade frequency) could serve as R&D proxies for crypto projects. Protocols with high, sustained development activity may exhibit similar return premiums, though this remains untested academically.
- **Holding Period**: The long holding period (annual rebalancing) means the strategy is slow-moving and low-turnover, which is advantageous for tax efficiency and transaction cost management.
