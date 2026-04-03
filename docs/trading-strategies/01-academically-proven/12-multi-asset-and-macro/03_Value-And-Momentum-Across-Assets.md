# Value and Momentum Across Assets

> **Source**: [Asness, Moskowitz & Pedersen (2013)](https://onlinelibrary.wiley.com/doi/abs/10.1111/jofi.12021); [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading)
> **Asset Class**: Multi-Asset (Equities, Bonds, Currencies, Commodities)
> **Crypto/24-7 Applicable**: Adaptable --- momentum component is directly applicable; value metrics require adaptation for crypto assets
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

Implements the seminal Asness, Moskowitz, and Pedersen (2013) framework, which demonstrates that value and momentum factors generate positive returns across eight diverse markets and asset classes simultaneously. The strategy goes long assets that are cheap (high value) or have strong recent performance (high momentum), and short assets that are expensive or have weak performance. A critical finding is that value and momentum are negatively correlated with each other within and across asset classes, making a combined portfolio significantly more efficient than either factor alone. The combined strategy produces a high Sharpe ratio that challenges rational risk-based asset pricing models.

## Trading Rules

1. **Universe**: Trade across multiple asset classes using liquid futures or ETFs:
   - **Equities**: Country equity indices (US, UK, Europe, Japan, emerging markets)
   - **Fixed Income**: Government bond futures across countries
   - **Currencies**: G10 FX crosses
   - **Commodities**: Diversified commodity basket (energy, metals, agriculture)
2. **Value Signal**:
   - Equities: CAPE ratio, book-to-market, earnings yield relative to own history
   - Bonds: Real yield (nominal yield minus inflation expectations) relative to own history
   - Currencies: PPP deviation, real exchange rate relative to fair value
   - Commodities: Spot-to-5-year-average price ratio
3. **Momentum Signal**: 12-month return minus the most recent 1-month return (12-1 momentum) for each asset. This skips the most recent month to avoid short-term reversal.
4. **Portfolio Construction**:
   - Rank all assets within each class by value and by momentum separately.
   - Go long the top third, short the bottom third for each signal.
   - Combine value and momentum portfolios with equal weight (50/50).
5. **Rebalancing**: Monthly.
6. **Volatility Targeting**: Scale the combined portfolio to a target volatility (e.g., 10% annualized).
7. **Risk Management**: Limit sector/country concentration. Monitor for momentum crash risk (momentum factor can experience sharp reversals during market recoveries).

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.155 (individual factors); 0.6 - 1.0 (diversified combined) |
| CAGR | 5% - 10% (combined, unlevered) |
| Max Drawdown | -15% to -25% |
| Win Rate | 55% - 60% (monthly) |
| Volatility | 9.8% annualized (from Awesome Systematic Trading) |
| Profit Factor | 1.3 - 1.5 |
| Rebalancing | Monthly |

## Efficacy Rating

**5/5** --- This is one of the most important and robust findings in empirical asset pricing. The paper was published in the Journal of Finance (the field's top journal) and has become foundational to factor investing. Key strengths: (1) the value-momentum negative correlation provides natural diversification, (2) the result holds across eight different markets and 40+ years of data, (3) the common factor structure suggests deep economic drivers rather than data mining. The individual factor Sharpe ratios are modest (0.155), but the diversified multi-asset, multi-factor portfolio achieves substantially higher risk-adjusted returns. The strategy has very high capacity and is implementable with liquid futures. The main risk is that momentum can crash during sharp market reversals (e.g., 2009 momentum crash).

## Academic References

- Asness, C. S., Moskowitz, T. J., & Pedersen, L. H. (2013). "Value and Momentum Everywhere." *Journal of Finance*, 68(3), 929-985. [Wiley](https://onlinelibrary.wiley.com/doi/abs/10.1111/jofi.12021)
- Jegadeesh, N. & Titman, S. (1993). "Returns to Buying Winners and Selling Losers." *Journal of Finance*, 48(1), 65-91.
- Fama, E. F. & French, K. R. (1992). "The Cross-Section of Expected Stock Returns." *Journal of Finance*, 47(2), 427-465.
- AQR Capital Management. "Value and Momentum Everywhere." [AQR](https://www.aqr.com/Insights/Research/Journal-Article/Value-and-Momentum-Everywhere)

## Implementation Notes

- **Value Metric Computation**: Value signals require fundamental data (CAPE, book-to-market for equities; real yields for bonds; PPP for FX). These are available from academic databases (Shiller, Kenneth French) or commercial providers.
- **Momentum Computation**: Simple --- trailing 12-month return minus trailing 1-month return. Uses only price data.
- **Cross-Asset Normalization**: Signals must be standardized within each asset class before combining across classes. Use z-scores within each asset class.
- **Momentum Crash Protection**: Consider dynamic exposure reduction when momentum dispersion is high or when recent momentum returns have been extremely positive (historically precedes crashes).
- **Crypto Adaptation**: Momentum applies directly to crypto. Value is harder: there are no crypto equivalents of P/E or CAPE. Possible proxies include on-chain activity ratios (NVT ratio, active addresses to market cap), realized price to spot price, or supply schedule metrics.
- **Pure Zig Implementation**: Ranking, z-scoring, and portfolio construction are array operations. The monthly rebalancing frequency makes this strategy simple to implement and operate. The main complexity is managing the multi-asset data pipeline.
