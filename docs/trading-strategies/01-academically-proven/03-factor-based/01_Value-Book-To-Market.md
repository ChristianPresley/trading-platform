# Value Factor (Book-to-Market)

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: Adaptable — crypto tokens with on-chain treasury metrics could serve as B/M proxies
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

The value factor, measured by the book-to-market (B/M) ratio, is one of the most extensively documented return anomalies in finance. Originally formalized by Fama and French (1993) as the HML (High Minus Low) factor in their three-factor model, it captures the tendency of high book-to-market (value) stocks to outperform low book-to-market (growth) stocks over long horizons. The effect is attributed to compensation for distress risk, behavioral overreaction to poor fundamentals, or a combination of both. Despite periods of underperformance (particularly during the late 1990s tech bubble and post-2017), the value premium remains one of the most robust factors across global equity markets and time periods spanning nearly a century.

## Trading Rules

1. **Universe**: All common stocks on NYSE, AMEX, and NASDAQ (or equivalent global universe).
2. **Signal**: At the end of each month, compute the book-to-market ratio (B/M) for each stock using the most recent book equity divided by current market capitalization.
3. **Sort**: Rank all stocks by B/M ratio into deciles or quintiles.
4. **Long Portfolio**: Buy stocks in the top decile (highest B/M — deep value stocks).
5. **Short Portfolio**: Sell short stocks in the bottom decile (lowest B/M — glamour/growth stocks).
6. **Weighting**: Value-weight positions within each portfolio leg.
7. **Rebalancing**: Monthly.
8. **Holding Period**: One month, then re-sort and rebalance.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.526 |
| CAGR | ~6-8% (long-short spread) |
| Max Drawdown | ~35-40% |
| Win Rate | ~55% |
| Volatility | 11.9% |
| Profit Factor | ~1.3 |
| Rebalancing | Monthly |

## Efficacy Rating

**5 / 5** -- The value factor is one of the most extensively documented and replicated anomalies in the history of empirical finance. It has been validated across dozens of countries, multiple centuries of data, and numerous asset classes. While the premium has experienced prolonged drawdowns (notably 2017-2020), the weight of academic evidence and the economic rationale for its persistence remain exceptionally strong. The factor's inclusion in virtually every serious multi-factor model underscores its foundational importance.

## Academic References

- Fama, E.F. and French, K.R. (1993). "Common Risk Factors in the Returns on Stocks and Bonds." *Journal of Financial Economics*, 33(1), 3-56.
- Fama, E.F. and French, K.R. (1992). "The Cross-Section of Expected Stock Returns." *Journal of Finance*, 47(2), 427-465.
- Lakonishok, J., Shleifer, A., and Vishny, R.W. (1994). "Contrarian Investment, Extrapolation, and Risk." *Journal of Finance*, 49(5), 1541-1578.
- Asness, C.S., Moskowitz, T.J., and Pedersen, L.H. (2013). "Value and Momentum Everywhere." *Journal of Finance*, 68(3), 929-985.
- Fama, E.F. and French, K.R. (2012). "Size, Value, and Momentum in International Stock Returns." *Journal of Financial Economics*, 105(3), 457-472.

## Implementation Notes

- **Data Lag**: Book equity data is typically available with a 3-6 month lag; use fiscal year-end data with appropriate delays to avoid look-ahead bias.
- **Sector Neutrality**: Consider sector-neutral implementations to avoid unintended sector bets (value strategies often overweight financials and energy).
- **Crypto Adaptation**: For crypto markets, potential proxies include protocol revenue-to-market-cap, total value locked (TVL) relative to fully diluted valuation, or on-chain treasury ratios. These remain experimental and lack the decades of academic validation present in equities.
- **Transaction Costs**: Monthly rebalancing can generate significant turnover; consider quarterly rebalancing for cost-sensitive implementations.
- **Combination**: The value factor pairs well with momentum (negative correlation between the two factors provides diversification benefits in a multi-factor portfolio).
