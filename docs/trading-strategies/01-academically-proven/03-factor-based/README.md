# Factor-Based Strategies

> **Category**: Academically Proven — Factor Investing
> **Strategies**: 13
> **Asset Class**: Equities (with crypto adaptation notes)
> **Evidence Tier**: Academic + Backtested

Factor-based strategies exploit systematic, persistent return premiums associated with measurable stock characteristics. Rooted in decades of academic research beginning with the Capital Asset Pricing Model and evolving through the Fama-French multi-factor framework, these strategies represent the most rigorously studied and widely implemented category of systematic investing. Factor premia have been documented across global equity markets, multiple time periods, and increasingly across asset classes including fixed income, commodities, currencies, and crypto.

---

## Strategy Index

| # | Strategy | Sharpe | Vol | Rebal | Rating | Key Insight |
|---|----------|--------|-----|-------|--------|-------------|
| 01 | [Value (Book-to-Market)](01_Value-Book-To-Market.md) | 0.526 | 11.9% | Monthly | 5/5 | High B/M stocks outperform low B/M; the original value premium |
| 02 | [Size Factor (Small-Cap Premium)](02_Size-Factor-Small-Cap-Premium.md) | 0.747 | 11.1% | Yearly | 4/5 | Small caps outperform large caps; strongest with quality filter |
| 03 | [Low-Volatility Factor](03_Low-Volatility-Factor.md) | 0.717 | 11.5% | Monthly | 5/5 | Low-vol stocks beat high-vol; contradicts CAPM risk-return tradeoff |
| 04 | [Betting Against Beta](04_Betting-Against-Beta.md) | 0.594 | 18.9% | Monthly | 4/5 | Leverage constraints cause overpricing of high-beta assets |
| 05 | [Asset Growth Effect](05_Asset-Growth-Effect.md) | 0.835 | 10.2% | Yearly | 4/5 | High asset growth firms underperform; strongest cross-sectional predictor |
| 06 | [Quality (ROA Effect)](06_Quality-ROA-Effect.md) | 0.155 | 8.7% | Monthly | 3/5 | High-ROA firms outperform; best as part of composite quality score |
| 07 | [Earnings Quality Factor](07_Earnings-Quality-Factor.md) | -0.18 | 28.7% | Yearly | 2/5 | Accruals quality predicts returns in theory; weak standalone signal |
| 08 | [Accrual Anomaly](08_Accrual-Anomaly.md) | -0.272 | 13.7% | Yearly | 2/5 | High accruals predict lower returns; largely arbitraged away |
| 09 | [R&D Expenditures and Returns](09_RD-Expenditures-And-Returns.md) | 0.354 | 8.1% | Yearly | 3/5 | High R&D intensity predicts higher returns via intangibles mispricing |
| 10 | [CAPE Value Within Countries](10_CAPE-Value-Within-Countries.md) | 0.351 | 20.2% | Yearly | 4/5 | Low Shiller CAPE countries outperform; value at macro level |
| 11 | [ESG Factor Momentum](11_ESG-Factor-Momentum.md) | 0.559 | 21.8% | Monthly | 3/5 | Improving ESG ratings predict outperformance |
| 12 | [Fama-French Five Factors](12_Fama-French-Five-Factors.md) | ~0.6-0.8 | ~10-14% | Yearly | 5/5 | Complete five-factor model: MKT, SMB, HML, RMW, CMA |
| 13 | [Multifactor Portfolio](13_Multifactor-Portfolio.md) | ~0.8-1.2 | ~8-12% | Monthly-Qtr | 4/5 | Combining factors for diversified, consistent alpha |

---

## Rating Distribution

| Rating | Count | Strategies |
|--------|-------|------------|
| 5/5 | 3 | Value B/M, Low Volatility, Fama-French Five Factors |
| 4/5 | 5 | Size, Betting Against Beta, Asset Growth, CAPE Value, Multifactor Portfolio |
| 3/5 | 3 | Quality ROA, R&D Expenditures, ESG Momentum |
| 2/5 | 2 | Earnings Quality, Accrual Anomaly |

---

## Key Themes

### The Factor Zoo Problem
With over 400 published factors in the academic literature, distinguishing genuine risk premia from data-mined artifacts is critical. The strategies in this section focus on factors with the strongest theoretical foundations, longest out-of-sample track records, and broadest cross-market evidence.

### Factor Cyclicality
No single factor outperforms in every market regime. Value suffered during 2017-2020; momentum crashed in 2009; low-volatility underperformed during rate-rising environments. The multifactor approach (Strategy 13) addresses this through diversification across factors with low correlations.

### Post-Publication Decay
Several factors (notably the accrual anomaly) have shown significant performance decay after publication, as institutional capital flows into documented anomalies. Strategies with structural explanations (leverage constraints for BAB, institutional mandates for low-vol) tend to be more persistent than those relying purely on behavioral mispricing.

### Crypto Adaptability
All strategies include crypto adaptation notes. Factor investing in crypto is nascent but growing. The most directly applicable factors are momentum, size, and low-volatility. Fundamental factors (value, quality, investment) require crypto-native metrics that are still being standardized.

---

## Foundational References

- Fama, E.F. and French, K.R. (2015). "A Five-Factor Asset Pricing Model." *Journal of Financial Economics*, 116(1), 1-22.
- Fama, E.F. and French, K.R. (1993). "Common Risk Factors in the Returns on Stocks and Bonds." *Journal of Financial Economics*, 33(1), 3-56.
- Asness, C.S., Moskowitz, T.J., and Pedersen, L.H. (2013). "Value and Momentum Everywhere." *Journal of Finance*, 68(3), 929-985.
- Kakushadze, Z. and Serur, J.A. (2018). *151 Trading Strategies*. Palgrave Macmillan.
- Ilmanen, A. (2011). *Expected Returns: An Investor's Guide to Harvesting Market Rewards*. Wiley.
- Harvey, C.R., Liu, Y., and Zhu, H. (2016). "...and the Cross-Section of Expected Returns." *Review of Financial Studies*, 29(1), 5-68.
