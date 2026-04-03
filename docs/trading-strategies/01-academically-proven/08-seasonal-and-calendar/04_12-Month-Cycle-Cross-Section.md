# 12-Month Cycle Cross-Section

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading) / [Quantpedia](https://quantpedia.com/seasonalities-in-stock-returns/)
> **Asset Class**: Equities (individual stocks, cross-sectional)
> **Crypto/24-7 Applicable**: No — requires deep history of individual asset returns at monthly granularity; crypto asset histories are too short
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

Individual stocks exhibit persistent seasonal patterns where their relative performance in a given calendar month is positively correlated with their performance in the same month in prior years. Heston and Sadka (2008) document that this 12-month return cycle persists at lags of 12, 24, 36 months and extends up to 20 annual lags. The effect is independent of the standard momentum factor, size, industry, earnings announcements, dividends, and fiscal year. A long-short strategy that buys same-month historical winners and sells same-month historical losers generates significant cross-sectional alpha.

## Trading Rules

1. **Universe**: All common stocks on NYSE/AMEX/NASDAQ with sufficient history
2. **Ranking signal**: For each stock, compute the average return in the current calendar month over the past 5-20 years (e.g., average March return across prior Marches)
3. **Portfolio formation**: At the start of each month, rank all stocks by their historical same-month return
4. **Long**: Top decile (stocks with highest historical same-month returns)
5. **Short**: Bottom decile (stocks with lowest historical same-month returns)
6. **Holding period**: One month (rebalance monthly)
7. **Weighting**: Equal-weight within each leg

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.34 |
| CAGR | ~12-15% (long-short) |
| Max Drawdown | ~30-40% |
| Win Rate | ~53-55% |
| Volatility | 43.7% |
| Profit Factor | ~1.2 |
| Rebalancing | Monthly |

## Efficacy Rating

**3/5** — Academically robust finding with strong statistical significance across multiple sample periods and international markets. However, the very high volatility (43.7%) significantly dilutes the risk-adjusted returns. The Sharpe ratio of 0.34 is modest for the complexity and turnover involved. The strategy requires a large universe of stocks with long histories, making it capital-intensive and operationally complex.

## Academic References

- Heston, S. L. & Sadka, R. (2008). "Seasonality in the Cross-Section of Expected Stock Returns." *Journal of Financial Economics*, 87(2), 418-445.
- Heston, S. L., Korajczyk, R. A., & Sadka, R. (2010). "Intraday Patterns in the Cross-Section of Stock Returns." *Journal of Finance*, 65(4), 1369-1407.
- Keloharju, M., Linnainmaa, J. T., & Nyberg, P. (2016). "Return Seasonalities." *Journal of Finance*, 71(4), 1557-1590.
- Chang, T., Hartzmark, S. M., Solomon, D. H., & Soltes, E. F. (2017). "Being Surprised by the Unsurprising: Earnings Seasonality and Stock Returns." *Review of Financial Studies*, 30(1), 281-323.

## Implementation Notes

- **Data requirements**: Minimum 5 years of monthly return history per stock; the signal strengthens with 10-20 years of history, which limits the investable universe
- **Distinctness from momentum**: The 12-month seasonal effect is orthogonal to standard 2-12 month momentum; combining both can improve Sharpe ratios
- **Turnover**: Monthly rebalancing of a large cross-sectional portfolio generates substantial turnover; transaction cost modeling is critical
- **Capacity**: The strategy spans the full stock universe, so capacity is large in absolute terms, but small/micro-cap stocks contribute disproportionately to the signal
- **Earnings seasonality**: Part of the effect may be driven by recurring earnings surprise patterns in the same fiscal quarter; controlling for this reduces but does not eliminate the anomaly
- **Implementation complexity**: Requires a robust cross-sectional ranking infrastructure and historical database; not suitable for manual or small-scale trading
