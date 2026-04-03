# Paired Switching

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading); [Quantpedia - Paired Switching](https://quantpedia.com/strategies/paired-switching)
> **Asset Class**: Multi-Asset (typically Equities and Bonds)
> **Crypto/24-7 Applicable**: Adaptable --- can pair crypto with bonds or stablecoins
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

A rotational strategy that switches capital between two negatively correlated assets (typically equities and government bonds) based on their relative recent performance. At each rebalancing date, the strategy allocates 100% to whichever asset performed better over the prior lookback period. The approach exploits the persistent negative correlation between stocks and bonds: when equities are in an uptrend, allocate to equities; when equities falter (and bonds typically rally), switch to bonds. The simplicity of the strategy --- only two assets and a single comparison --- makes it robust and resistant to overfitting, while the switching mechanism provides a form of trend following at the asset class level.

## Trading Rules

1. **Asset Pair Selection**: Choose two assets with historically negative or low correlation:
   - **Classic Pair**: US Equity Index (SPY) and US Long-Term Treasury Bonds (TLT)
   - **Alternative Pairs**: Equities/Gold, Equities/TIPS, Growth/Value, Domestic/International
2. **Performance Measurement**: At each rebalancing date, compute the total return of each asset over the lookback period (e.g., past 3 months, 6 months, or 12 months).
3. **Switching Rule**: Allocate 100% of the portfolio to the asset with the higher return over the lookback period. Hold for one rebalancing period.
4. **Rebalancing Frequency**: Quarterly (most common in academic studies). Monthly is an alternative but increases turnover.
5. **Cash Filter (Optional)**: If both assets have negative returns over the lookback period, move to cash/T-bills until the next rebalancing date.
6. **Variant --- Partial Switching**: Instead of 100% allocation, use a softer rule: 70% to the winner, 30% to the loser. This reduces concentration risk and turnover.
7. **Risk Management**: The strategy is inherently risk-managed by the switching mechanism. In equity bear markets, the strategy typically shifts to bonds, limiting drawdowns.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.691 |
| CAGR | 7% - 10% |
| Max Drawdown | -12% to -18% |
| Win Rate | 55% - 62% (quarterly) |
| Volatility | 9.5% annualized |
| Profit Factor | 1.3 - 1.6 |
| Rebalancing | Quarterly |

## Efficacy Rating

**4/5** --- Paired switching is remarkably effective given its extreme simplicity. Academic research shows that if the switching criterion has even minimal predictive accuracy, the strategy improves performance over static allocation. The stock-bond pair is particularly powerful because it captures two key dynamics: (1) equity momentum --- equities tend to continue performing well over intermediate horizons, and (2) flight-to-quality --- bonds rally when equities sell off. The Sharpe ratio of 0.691 with only 9.5% volatility and quarterly rebalancing represents excellent risk-adjusted performance with minimal management overhead. The main weakness is that the strategy can fail during simultaneous stock-bond selloffs (e.g., 2022 rising rate environment) and provides only binary allocation decisions.

## Academic References

- Quantpedia. "Paired Switching." [Quantpedia](https://quantpedia.com/strategies/paired-switching)
- Faber, M. T. (2007). "A Quantitative Approach to Tactical Asset Allocation." *Journal of Wealth Management*, 10(1), 69-79.
- Antonacci, G. (2014). "Dual Momentum Investing: An Innovative Strategy for Higher Returns with Lower Risk." *McGraw-Hill Education*.
- Keller, W. J. & Butler, A. (2015). "Momentum and Markowitz: A Golden Combination." *SSRN Working Paper*.

## Implementation Notes

- **Simplicity**: This is one of the simplest strategies to implement. It requires only quarterly total return calculations and a single comparison. Execution involves one or two trades per quarter at most.
- **Data Requirements**: Daily or weekly close prices for two assets. Minimal data infrastructure needed.
- **Lookback Period**: 3-month (quarterly) lookback is most common. 6-month and 12-month lookbacks also work. Avoid over-optimizing the lookback period.
- **2022 Challenge**: The strategy struggled in 2022 when both stocks and bonds fell simultaneously due to aggressive rate hikes. Consider adding a third asset (commodities or gold) as an alternative safe haven, or incorporate the cash filter.
- **Crypto Adaptation**: Pair BTC with TLT or a stablecoin yield product. The high volatility of BTC means switches will often be dramatic. Consider pairing BTC with gold for a "digital vs. physical store of value" variant.
- **Pure Zig Implementation**: Trivially implementable. Compute two returns, compare, allocate. The quarterly rebalancing frequency means the strategy logic runs infrequently.
- **Combination Potential**: Can be nested within a larger multi-strategy portfolio. Use paired switching for the fixed income / equity allocation decision, and apply other strategies (momentum, factor) within each allocation.
