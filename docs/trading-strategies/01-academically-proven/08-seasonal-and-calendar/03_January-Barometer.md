# January Barometer

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading) / [Stock Trader's Almanac](https://www.stocktradersalmanac.com)
> **Asset Class**: Equities (broad indices)
> **Crypto/24-7 Applicable**: Adaptable — January sentiment and fund allocation patterns exist in crypto, though the track record is too short to validate
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

"As goes January, so goes the year." Coined by Yale Hirsch in the 1972 edition of the Stock Trader's Almanac, the January Barometer posits that the direction of the S&P 500 in January predicts its direction for the full calendar year. Since 1950, when January has been positive, the full year has been positive approximately 86% of the time with an average gain of ~16%. Negative Januaries have led to an average annual loss of ~1.7%.

## Trading Rules

1. **Universe**: S&P 500 (SPY or index futures)
2. **Signal**: Measure the total return of the S&P 500 from January 1 close through January 31 close
3. **If January is positive**: Go long the S&P 500 on February 1; hold through December 31
4. **If January is negative**: Move to cash (T-bills) or short the S&P 500 on February 1; hold through December 31
5. **Rebalance**: Once per year on February 1
6. **Variant (long-only)**: If January is positive, remain long; if January is negative, move to cash (no short)

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.365 |
| CAGR | ~8-10% (long-only variant) |
| Max Drawdown | ~25-35% |
| Win Rate | ~84% (directional accuracy since 1950) |
| Volatility | 7.4% |
| Profit Factor | ~1.5 |
| Rebalancing | Monthly (annual decision) |

## Efficacy Rating

**3/5** — High directional accuracy (84%) but limited practical alpha. The strategy makes only one decision per year, so a single miss can be costly. The 84% hit rate is partly inflated by the general upward bias of equities (the market is positive in ~70% of years regardless). The conditional improvement over buy-and-hold is meaningful but modest. Works best as a regime filter rather than a standalone strategy.

## Academic References

- Hirsch, Y. (1972). *Stock Trader's Almanac*. The Hirsch Organization.
- Cooper, M. J., McConnell, J. J., & Ovtchinnikov, A. V. (2006). "The Other January Effect." *Journal of Financial Economics*, 82(2), 315-341.
- Brown, L. D. & Luo, L. (2006). "The January Barometer: Further Evidence." *Journal of Investing*, 15(1), 25-31.
- Stivers, C., Sun, L., & Sun, Y. (2009). "The Other January Effect: International, Style, and Subperiod Evidence." *Journal of Financial Markets*, 12(3), 521-546.

## Implementation Notes

- **Signal clarity**: Use total return (including dividends) for the January measurement; the direction is more important than the magnitude
- **False signals**: The most damaging scenario is a positive January followed by a severe bear market (e.g., 2008 had a negative January, correctly signaling trouble; but 2001 had a positive January that preceded a bear market)
- **Enhancement**: Combine with other macro signals (yield curve, breadth indicators) to filter low-confidence January signals
- **Crypto adaptation**: Test whether January BTC/ETH returns predict full-year direction; early evidence is mixed due to short history and crypto's unique cycle drivers (halvings, regulatory events); the mechanism of institutional allocation decisions at year-start is plausible for crypto as institutional participation grows
- **Practical use**: Best deployed as a binary overlay that adjusts portfolio beta rather than as a standalone timing system
