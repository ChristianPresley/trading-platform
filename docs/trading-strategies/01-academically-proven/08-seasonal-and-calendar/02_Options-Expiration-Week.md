# Options Expiration Week Effect

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading) / [Quantpedia](https://quantpedia.com/strategies/option-expiration-week-effect)
> **Asset Class**: Equities (large-cap indices)
> **Crypto/24-7 Applicable**: Adaptable — crypto options (Deribit) have monthly/quarterly expiration cycles with measurable market impact
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

The S&P 500 and other large-cap indices exhibit above-average returns during the third week of each month, which corresponds to the standard options expiration week (the week containing the third Friday). The effect is driven by hedge rebalancing activity from options market makers who must adjust their delta positions as expiration approaches, creating systematic buying pressure in the underlying equities.

## Trading Rules

1. **Universe**: S&P 500 ETF (SPY) or S&P 500 futures (ES)
2. **Entry**: Buy at the close on the Friday before options expiration week (i.e., the second Friday of the month)
3. **Exit**: Sell at the close on expiration Friday (third Friday of the month)
4. **Holding period**: One week per month
5. **Position sizing**: Full allocation during expiration week; flat otherwise
6. **Monthly filter (optional)**: Exclude July and January, which historically show negative expiration-week returns
7. **Enhancement**: Combine with quarterly "triple witching" weeks (March, June, September, December) for larger effect size

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.452 |
| CAGR | ~4-6% (1 week/month exposure) |
| Max Drawdown | ~12-18% |
| Win Rate | ~58-62% |
| Volatility | 5.0% |
| Profit Factor | ~1.4 |
| Rebalancing | Weekly (monthly frequency) |

## Efficacy Rating

**3/5** — Statistically significant effect with a clear microstructural mechanism (delta-hedging flows). The Sharpe ratio of 0.452 is reasonable for a strategy with such limited market exposure. However, the proliferation of weekly options and 0DTE contracts may be diluting the monthly expiration effect. The strategy works best on large-cap indices where options open interest is concentrated.

## Academic References

- Stoll, H. R. & Whaley, R. E. (1987). "Program Trading and Expiration-Day Effects." *Financial Analysts Journal*, 43(2), 16-28.
- Ni, S. X., Pearson, N. D., & Poteshman, A. M. (2005). "Stock Price Clustering on Option Expiration Dates." *Journal of Financial Economics*, 78(1), 49-87.
- Stivers, C. & Sun, L. (2010). "Cross-Sectional Return Dispersion and Time Variation in Value and Momentum Premiums." *Journal of Financial and Quantitative Analysis*, 45(4), 987-1014.

## Implementation Notes

- **Execution**: Friday close-to-close is simplest; futures avoid settlement complications
- **Quarterly expirations**: Triple/quadruple witching weeks (index futures, index options, stock options, and single-stock futures all expire) tend to show amplified effects due to larger hedging volumes
- **Weekly options caveat**: Since the introduction of weekly SPX options (2005) and especially 0DTE options (2022+), hedging flows are more evenly distributed throughout the month, potentially weakening the monthly expiration signal
- **Crypto adaptation**: Deribit monthly and quarterly BTC/ETH options expirations create analogous dynamics; monitor open interest and max-pain levels heading into the last Friday of each month; CME crypto options add additional expiration-linked flows
- **Combining signals**: Overlay with turn-of-month effect when expiration week coincides with month-end for stronger signal
