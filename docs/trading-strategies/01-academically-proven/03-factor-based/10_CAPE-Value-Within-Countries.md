# CAPE Value Within Countries

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading)
> **Asset Class**: Equities (Country-Level Allocation)
> **Crypto/24-7 Applicable**: Adaptable — could apply to sector or protocol-level valuations using crypto-native metrics
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

The CAPE (Cyclically Adjusted Price-to-Earnings) ratio, developed by Robert Shiller and John Campbell, divides the real (inflation-adjusted) price of an equity market by its 10-year average of real earnings. When applied cross-country, CAPE becomes a powerful tactical asset allocation tool: countries with low CAPE ratios (cheap markets) tend to outperform countries with high CAPE ratios (expensive markets) over subsequent 5-10 year periods. Research by Norbert Keimling (2016) demonstrated this relationship holds across 17 MSCI country indices, and Meb Faber showed that investing in the cheapest quartile of countries by CAPE substantially outperformed the S&P 500 from 1993-2018. The strategy applies the well-documented value premium at the country level rather than the individual stock level.

## Trading Rules

1. **Universe**: Broad equity indices of developed and major emerging market countries (typically 20-40 countries with available CAPE data).
2. **Signal**: At the end of each year, compute the Shiller CAPE ratio for each country's equity market index using 10-year trailing real earnings.
3. **Sort**: Rank all countries by CAPE ratio from lowest to highest.
4. **Long Portfolio**: Invest in the bottom quartile of countries (cheapest by CAPE).
5. **Short Portfolio**: Sell short the top quartile of countries (most expensive by CAPE), or simply underweight/avoid in a long-only implementation.
6. **Weighting**: Equal-weight across selected country indices.
7. **Rebalancing**: Annually.
8. **Holding Period**: One year, then re-sort and rebalance.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.351 |
| CAGR | ~7-10% |
| Max Drawdown | ~40-45% |
| Win Rate | ~55% |
| Volatility | 20.2% |
| Profit Factor | ~1.2 |
| Rebalancing | Yearly |

## Efficacy Rating

**4 / 5** -- CAPE-based cross-country value allocation is one of the most intuitive and well-supported macro factor strategies. The relationship between starting CAPE and subsequent long-term returns is remarkably consistent across countries and time periods. It receives a 4 rather than 5 because: (1) volatility is high (20.2%) due to country-level concentration risk, (2) the signal is very slow-moving (CAPE has a 10-year lookback), meaning it can stay "wrong" for extended periods, (3) value traps exist at the country level (cheap markets that stay cheap due to structural problems), and (4) the strategy requires patience as CAPE is a better predictor over 5-10 year horizons than 1-year horizons.

## Academic References

- Campbell, J.Y. and Shiller, R.J. (1988). "Stock Prices, Earnings, and Expected Dividends." *Journal of Finance*, 43(3), 661-676.
- Keimling, N. (2016). "Predicting Stock Market Returns Using the Shiller CAPE -- An Improvement Towards Traditional Value Indicators?" SSRN Working Paper No. 2736423.
- Faber, M.T. (2013). "Global Value: How to Spot Bubbles, Avoid Market Crashes, and Earn Big Returns in the Stock Market." Cambria Investment Management.
- Shiller, R.J. (2000). *Irrational Exuberance*. Princeton University Press.
- Asness, C.S., Israelov, R., and Liew, J.M. (2011). "International Diversification Works (Eventually)." *Financial Analysts Journal*, 67(3), 24-38.

## Implementation Notes

- **Long Horizon**: CAPE is most predictive over 5-10 year horizons; annual rebalancing captures the signal imperfectly. Accept that individual years will be noisy.
- **Value Traps**: Some countries are persistently cheap for structural reasons (governance risk, capital controls, demographic decline). Combine CAPE with momentum or quality screens to avoid value traps.
- **Currency Risk**: Cross-country strategies introduce significant currency exposure. Consider hedging or accepting currency as an additional risk/return dimension.
- **Data Source**: CAPE data for international markets is available from Research Affiliates, Barclays, and Shiller's online database.
- **Crypto Adaptation**: At the crypto sector level, one could compute rolling P/E-like ratios (market cap / annualized protocol revenue) for DeFi sectors or Layer 1 ecosystems and apply a similar cheapest-quartile approach. This is highly experimental.
- **Concentration**: Investing in only 5-10 countries creates significant concentration risk. Consider wider quartiles or a tilt approach rather than binary inclusion/exclusion.
