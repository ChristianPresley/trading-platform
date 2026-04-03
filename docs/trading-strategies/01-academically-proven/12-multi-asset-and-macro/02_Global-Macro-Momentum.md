# Global Macro Momentum

> **Source**: [151 Trading Strategies, Ch. 19](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) (Kakushadze & Serur, 2018); [AQR - Fundamental Trends and Dislocated Markets](https://www.aqr.com/-/media/AQR/Documents/Insights/White-Papers/AQR-Fundamental-Trends-and-Dislocated-Markets-An-Integrated-Approach-to-Global-Macro.pdf)
> **Asset Class**: Multi-Asset (Equities, Fixed Income, Currencies, Commodities across countries)
> **Crypto/24-7 Applicable**: No --- requires macroeconomic data and global market infrastructure not present in crypto
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

Applies momentum signals to macroeconomic factors and asset class indices across countries, capturing persistent trends driven by central bank policy cycles, economic growth differentials, and structural capital flows. Unlike security-level momentum, global macro momentum operates at the country and asset class level, exploiting the slow-moving nature of macroeconomic trends. The strategy goes long countries/asset classes with improving fundamentals (rising growth, falling rates, strong currency trends) and short those with deteriorating fundamentals. Academic research shows Sharpe ratios of 0.5-0.7 for individual macro themes, with diversification across themes boosting portfolio-level risk-adjusted returns.

## Trading Rules

1. **Macro Factor Selection**: Track momentum in key macro factors for each country/region:
   - **Growth Momentum**: PMI, industrial production, GDP nowcasts (3-month and 12-month changes)
   - **Inflation Momentum**: CPI, PPI trends (direction relative to central bank targets)
   - **Monetary Policy**: Rate cut/hike cycles, yield curve slope changes
   - **Currency Momentum**: 3-month and 12-month FX returns
   - **Commodity Trends**: Rolling 12-month commodity index returns
2. **Signal Construction**: For each factor, compute a z-score relative to its own history (e.g., current PMI momentum relative to the past 5 years of PMI momentum readings).
3. **Cross-Country Ranking**: Rank countries by each factor. Go long the top third of countries/asset classes on each factor, short the bottom third.
4. **Portfolio Construction**: Combine signals across factors using equal weighting or a more sophisticated weighting based on historical factor performance. Target 10-15% annualized volatility.
5. **Instrument Selection**: Express views through liquid futures: equity index futures, government bond futures, FX forwards, and commodity futures.
6. **Rebalancing**: Monthly, aligned with macroeconomic data release schedules.
7. **Risk Management**: Limit single-country exposure to 15% of portfolio. Apply correlation-based position sizing. Reduce exposure during periods of macro regime uncertainty (e.g., policy pivots).

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.5 - 0.7 (single factor); 0.8 - 1.2 (diversified) |
| CAGR | 6% - 12% |
| Max Drawdown | -10% to -20% |
| Win Rate | 52% - 58% |
| Volatility | 8% - 15% annualized |
| Profit Factor | 1.3 - 1.6 |
| Rebalancing | Monthly |

## Efficacy Rating

**4/5** --- Global macro momentum has strong academic support and institutional adoption. Macroeconomic trends are persistent because they are driven by slow-moving fundamental forces: central bank policy cycles take years to unfold, economic growth trends are autocorrelated, and capital flows respond gradually to changing conditions. This persistence creates a durable source of alpha that is difficult to arbitrage away because it requires patience, diversification across many countries, and tolerance for tracking error. The strategy is well-diversified by construction (multiple factors, multiple countries) and has low correlation with traditional equity/bond portfolios. The main challenge is the moderate signal-to-noise ratio of macroeconomic data and the lag in data releases.

## Academic References

- Kakushadze, Z. & Serur, J. A. (2018). "151 Trading Strategies." *Palgrave Macmillan*. [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865)
- Brooks, J. et al. (2017). "Fundamental Trends and Dislocated Markets: An Integrated Approach to Global Macro." *AQR White Paper*. [AQR](https://www.aqr.com/-/media/AQR/Documents/Insights/White-Papers/AQR-Fundamental-Trends-and-Dislocated-Markets-An-Integrated-Approach-to-Global-Macro.pdf)
- Asness, C. S., Moskowitz, T. J., & Pedersen, L. H. (2013). "Value and Momentum Everywhere." *Journal of Finance*, 68(3), 929-985.
- Ilmanen, A. (2011). "Expected Returns: An Investor's Guide to Harvesting Market Rewards." *Wiley Finance*.

## Implementation Notes

- **Data Requirements**: Requires access to macroeconomic databases (e.g., FRED, IMF, OECD) for growth, inflation, and monetary policy data across 20-30 countries. FX and commodity data from market data providers.
- **Data Lag**: Macro data is released with delays (GDP: 1-3 months, PMI: 1-2 weeks, CPI: 2-4 weeks). The strategy must only use data available at the time of the signal.
- **Futures Execution**: Global macro is typically expressed through futures, which provide leverage, liquidity, and the ability to go short. Requires futures account and margin management across multiple exchanges (CME, Eurex, ICE, etc.).
- **Not Crypto Applicable**: This strategy operates at the national/macro level and requires government bond yields, sovereign FX, and official economic statistics. None of these have crypto analogues.
- **Pure Zig Implementation**: The signal computation (z-scores, rankings, portfolio construction) is standard statistics and sorting. The data ingestion from macro data APIs (FRED, etc.) uses HTTP client and JSON parsing from Zig std lib. The strategy's monthly frequency means latency is not a concern.
- **Capacity**: Global macro strategies have very high capacity (billions of dollars) due to the liquidity of futures markets, making them attractive for institutional implementation.
