# Turn of the Month Effect

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading) / [Quantpedia](https://quantpedia.com/strategies/turn-of-the-month-in-equity-indexes)
> **Asset Class**: Equities (broad indices)
> **Crypto/24-7 Applicable**: Adaptable — crypto markets have month-end rebalancing flows from funds and structured products
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

Stock market returns are disproportionately concentrated in the last trading day of each month and the first three trading days of the following month. This four-day window has historically captured all of the positive return of the DJIA over a 90-year sample. The effect is attributed to institutional cash flow patterns, particularly pension fund contributions and salary-linked investment flows that cluster around month boundaries.

## Trading Rules

1. **Universe**: S&P 500 ETF (SPY) or broad equity index futures
2. **Entry**: Buy at the close on the last trading day of each month (day T-1)
3. **Exit**: Sell at the close on the third trading day of the new month (day T+3)
4. **Position sizing**: Full allocation during the 4-day window; flat otherwise
5. **Variant (extended window)**: Ariel (1987) defines the window as day T-1 through T+8 for a 9-day holding period
6. **No short component**: Remain in cash outside the turn-of-month window

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.305 |
| CAGR | ~5-7% (4 days/month exposure) |
| Max Drawdown | ~15-20% |
| Win Rate | ~60-65% |
| Volatility | 7.2% |
| Profit Factor | ~1.3 |
| Rebalancing | Daily (month-end entry, early-month exit) |

## Efficacy Rating

**4/5** — One of the most robust and persistent calendar anomalies. Documented across 90+ years of U.S. data (Lakonishok and Smidt, 1988) and confirmed in international markets. The institutional flow mechanism (pension contributions, payroll investment) provides a durable economic rationale. The effect has weakened but not disappeared post-publication.

## Academic References

- Ariel, R. A. (1987). "A Monthly Effect in Stock Returns." *Journal of Financial Economics*, 18(1), 161-174.
- Lakonishok, J. & Smidt, S. (1988). "Are Seasonal Anomalies Real? A Ninety-Year Perspective." *Review of Financial Studies*, 1(4), 403-425.
- McConnell, J. J. & Xu, W. (2008). "Equity Returns at the Turn of the Month." *Financial Analysts Journal*, 64(2), 49-64.
- Kunkel, R. A., Compton, W. S., & Beyer, S. (2003). "The Turn-of-the-Month Effect Still Lives: The International Evidence." *International Review of Financial Analysis*, 12(2), 207-221.

## Implementation Notes

- **Execution**: Enter at market close on the last trading day; index futures provide the cleanest execution
- **Transaction costs**: Two round trips per month; costs are manageable with futures but must be accounted for with ETFs
- **Combining signals**: Can be overlaid with other calendar effects (e.g., holiday, options expiration) for confirmation
- **Crypto adaptation**: Monitor month-end flows from crypto funds, structured products, and options settlements on Deribit; the lunar-month or calendar-month rebalancing of DeFi vaults may create analogous patterns
- **Risk management**: The strategy is naturally conservative due to limited market exposure (~4 days out of ~21 trading days per month)
