# FED Model

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading); [Quantpedia - FED Model](https://quantpedia.com/strategies/fed-model)
> **Asset Class**: Equities and Fixed Income
> **Crypto/24-7 Applicable**: No --- requires equity earnings yield and government bond yield data
> **Evidence Tier**: Academic + Backtested (with caveats --- disputed by Asness/AQR)
> **Complexity**: Simple

## Overview

The FED Model compares the stock market's forward earnings yield (inverse of the P/E ratio) to the yield on long-term government bonds (typically the 10-year Treasury). When the earnings yield exceeds the bond yield (the "yield gap" is positive), equities are considered undervalued relative to bonds, and the model signals overweight equities. When the bond yield exceeds the earnings yield, bonds are favored. The model gained popularity in the late 1990s after being referenced in Federal Reserve testimony, though it was never an official Fed tool. It serves as a simple valuation-based timing mechanism for the equity-bond allocation decision.

## Trading Rules

1. **Compute the Yield Gap**:
   - Equity Earnings Yield = Forward 12-month earnings / Current S&P 500 price (or trailing E/P)
   - Bond Yield = 10-year US Treasury yield
   - Yield Gap = Earnings Yield - Bond Yield
2. **Signal Generation**:
   - **Overweight Equities**: When Yield Gap > 0 (equities cheaper than bonds), allocate 70-100% to equities.
   - **Overweight Bonds**: When Yield Gap < 0 (bonds cheaper than equities), allocate 70-100% to bonds.
   - **Neutral**: When Yield Gap is near zero (within +/- 0.5%), maintain a balanced 60/40 allocation.
3. **Smoothing**: Apply a 3-month moving average to the yield gap to avoid whipsaw from monthly fluctuations.
4. **Rebalancing**: Monthly, after updated earnings estimates and bond yields are available.
5. **Variant --- Regression-Based**: Use the yield gap as an independent variable in a regression to predict equity excess returns. Allocate based on the predicted excess return rather than a simple threshold.
6. **Risk Management**: Never go fully to 100% equities or 100% bonds. Maintain a minimum 20% allocation to the underweight asset class. Cap maximum single-period turnover at 30%.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.369 |
| CAGR | 5% - 8% |
| Max Drawdown | -20% to -30% |
| Win Rate | 52% - 56% (monthly) |
| Volatility | 14.3% annualized |
| Profit Factor | 1.1 - 1.3 |
| Rebalancing | Monthly |

## Efficacy Rating

**3/5** --- The FED Model has intuitive appeal and some empirical support: the yield gap has demonstrated predictive power for equity excess returns at short-to-medium horizons during specific periods (notably 1987-2000 and the post-2020 period). However, the model has been forcefully criticized by Asness (2003, "Fight the FED Model") and others on theoretical grounds: comparing a real variable (earnings yield) to a nominal variable (bond yield) is conceptually flawed, as it conflates inflation effects. Long-term empirical analysis shows the relationship held only during two specific US periods (1921-1928 and 1987-2000). Recent research suggests the model improves when accounting for structural shifts in the equity-bond yield relationship. The modest Sharpe ratio of 0.369 reflects these limitations. Best used as one input among several in an allocation framework, not as a standalone strategy.

## Academic References

- Quantpedia. "FED Model." [Quantpedia](https://quantpedia.com/strategies/fed-model)
- Asness, C. S. (2003). "Fight the Fed Model: The Relationship Between Future Returns and Stock and Bond Market Yields." *Journal of Portfolio Management*, 30(1), 11-24. [AQR](https://www.aqr.com/-/media/AQR/Documents/Journal-Articles/JPM-Fight-the-Fed-Model.pdf)
- Bekaert, G. & Engstrom, E. (2010). "Inflation and the Stock Market: Understanding the 'Fed Model'." *Journal of Monetary Economics*, 57(3), 278-294. [Columbia](https://business.columbia.edu/sites/default/files-efs/pubfiles/3038/inflation_stock_market.pdf)
- Estrada, J. (2006). "The Fed Model: A Note." *Finance Research Letters*, 3(1), 14-22. [IESE](https://blog.iese.edu/jestrada/files/2012/06/FedModel-Note.pdf)

## Implementation Notes

- **Data Sources**: Forward earnings yield from S&P or I/B/E/S consensus estimates. 10-year Treasury yield from FRED (Federal Reserve Economic Data). Both are widely available and updated daily.
- **Earnings Estimate Quality**: Forward earnings estimates are subject to analyst bias (typically optimistic). Consider using trailing 12-month earnings or a Shiller CAPE-based earnings yield for a more conservative measure.
- **Inflation Regime Sensitivity**: The model works best in stable inflation environments. During high-inflation periods (like the 1970s or 2022), the nominal bond yield contains a large inflation premium that distorts the comparison with earnings yield. Consider using real (inflation-adjusted) bond yields for a theoretically cleaner comparison.
- **Not Crypto Applicable**: The model requires equity earnings yields and government bond yields, neither of which exist in crypto markets.
- **Pure Zig Implementation**: Extremely simple. Compute two yields, take the difference, compare to threshold. The entire strategy logic is a handful of arithmetic operations.
- **Best as a Complement**: Given the theoretical criticisms and modest standalone performance, the FED Model is best used as one valuation signal within a broader multi-factor allocation framework (combining with momentum, risk parity, and macro signals).
