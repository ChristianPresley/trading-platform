# Fama-French Five-Factor Model

> **Source**: [Fama & French (2015)](https://www.sciencedirect.com/science/article/abs/pii/S0304405X14002323)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: Adaptable — individual factors can be constructed with crypto-native metrics
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

The Fama-French Five-Factor Model (2015) is the most comprehensive and widely adopted multi-factor asset pricing framework in modern finance. Building on the original three-factor model (1993), it adds profitability and investment factors to create a five-factor specification that explains 71-94% of cross-sectional variance in expected returns. The five factors are: (1) MKT -- market excess return, (2) SMB -- Small Minus Big (size), (3) HML -- High Minus Low (value/book-to-market), (4) RMW -- Robust Minus Weak (profitability), and (5) CMA -- Conservative Minus Aggressive (investment). Published in the Journal of Financial Economics (Volume 116, pages 1-22), the model subsumes many previously documented anomalies and has become the standard benchmark for evaluating investment strategies. Notably, Fama and French found that the addition of RMW and CMA made HML redundant in their sample, sparking ongoing debate about the role of value in factor models.

## Trading Rules

1. **Universe**: All common stocks on NYSE, AMEX, and NASDAQ (or equivalent global universe).
2. **Factor Construction** (following Fama-French methodology):
   - **MKT**: Market portfolio return minus the risk-free rate.
   - **SMB**: At the end of June each year, sort stocks by market cap into Small and Big using the NYSE median. Compute SMB as the average return of small-stock portfolios minus the average return of big-stock portfolios.
   - **HML**: Sort stocks by book-to-market ratio into three groups (top 30%, middle 40%, bottom 30%) using NYSE breakpoints. HML = average return of high B/M portfolios minus average return of low B/M portfolios.
   - **RMW**: Sort stocks by operating profitability (revenue minus COGS, minus SGA, minus interest expense, all divided by book equity) into three groups. RMW = average return of robust (high profitability) portfolios minus weak (low profitability) portfolios.
   - **CMA**: Sort stocks by total asset growth into three groups. CMA = average return of conservative (low investment) portfolios minus aggressive (high investment) portfolios.
3. **Portfolio Construction**: Form 2x3 independent sorts on size and each of the other variables to construct factor-mimicking portfolios.
4. **Weighting**: Value-weight positions within each portfolio cell.
5. **Rebalancing**: Annually (June for size, B/M, profitability, investment).
6. **Holding Period**: One year, then re-sort and rebalance.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.6-0.8 (combined factor portfolio) |
| CAGR | ~8-12% (multi-factor long-short) |
| Max Drawdown | ~20-30% |
| Win Rate | ~58% |
| Volatility | ~10-14% |
| Profit Factor | ~1.4-1.6 |
| Rebalancing | Yearly (factor portfolios) |

## Efficacy Rating

**5 / 5** -- The Fama-French Five-Factor Model represents the gold standard in empirical asset pricing. It synthesizes decades of anomaly research into a parsimonious framework that explains the vast majority of cross-sectional return variation. Each component factor has a deep academic literature, robust out-of-sample evidence across international markets, and compelling economic rationale. The model provides the conceptual foundation for virtually every serious multi-factor investment product and serves as the standard benchmark against which new factors and strategies are evaluated. Its influence on both academic research and industry practice is unmatched.

## Academic References

- Fama, E.F. and French, K.R. (2015). "A Five-Factor Asset Pricing Model." *Journal of Financial Economics*, 116(1), 1-22.
- Fama, E.F. and French, K.R. (1993). "Common Risk Factors in the Returns on Stocks and Bonds." *Journal of Financial Economics*, 33(1), 3-56.
- Fama, E.F. and French, K.R. (2017). "International Tests of a Five-Factor Asset Pricing Model." *Journal of Financial Economics*, 123(3), 441-463.
- Novy-Marx, R. (2013). "The Other Side of Value: The Gross Profitability Premium." *Journal of Financial Economics*, 108(1), 1-28.
- Hou, K., Xue, C., and Zhang, L. (2015). "Digesting Anomalies: An Investment Approach." *Review of Financial Studies*, 28(3), 650-705.
- Blitz, D., Hanauer, M.X., Vidojevic, M., and van Vliet, P. (2018). "Five Concerns with the Five-Factor Model." *Journal of Portfolio Management*, 44(4), 71-78.

## Implementation Notes

- **Data Requirements**: The five-factor model requires comprehensive accounting data (book equity, operating profitability, total assets) with appropriate lags. Kenneth French's data library provides pre-computed factor returns for the U.S. market at [mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html](https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html).
- **HML Redundancy**: Fama and French (2015) found that HML becomes redundant when RMW and CMA are included. This remains debated; many practitioners retain HML, especially for its role during value regime changes.
- **Factor Timing**: While individual factors experience prolonged drawdowns, their low correlations provide strong diversification benefits. Factor timing (over/underweighting based on valuation or momentum) is an active area of research but adds model risk.
- **Crypto Adaptation**: Each factor can potentially be constructed with crypto-native metrics: size (market cap), value (TVL/FDV or revenue/market-cap), profitability (protocol revenue margins), investment (token supply growth or treasury deployment). All remain experimental.
- **Transaction Costs**: Annual rebalancing keeps turnover moderate, but the 2x3 sort methodology requires trading across many portfolio cells. Institutional implementations should carefully model trading costs.
- **International Application**: The model has been validated across North American, European, and Asia-Pacific equity markets (Fama and French, 2017), though factor premia vary in magnitude across regions.
