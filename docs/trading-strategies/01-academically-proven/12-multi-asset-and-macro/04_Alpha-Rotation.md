# Alpha Rotation

> **Source**: [151 Trading Strategies, Ch. 4](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) (Kakushadze & Serur, 2018)
> **Asset Class**: Multi-Asset (Equities, Bonds, Commodities, REITs)
> **Crypto/24-7 Applicable**: Adaptable --- can include crypto as one of the rotational asset classes
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

Rotates capital allocation among asset classes based on alpha signals --- metrics designed to identify which asset class is likely to outperform over the next period. Unlike static allocation (e.g., 60/40) or risk-based allocation (risk parity), alpha rotation dynamically shifts 100% or a concentrated allocation into the asset class(es) with the strongest expected performance. Alpha signals may include momentum (recent performance), fundamental metrics (earnings yields, real yields), macro indicators (PMI, yield curve), or a combination thereof. The strategy is aggressive by nature, accepting higher tracking error and concentration risk in exchange for potentially higher returns.

## Trading Rules

1. **Asset Universe**: Define 4-8 broad asset classes represented by liquid ETFs or futures:
   - US Equities (SPY / ES futures)
   - International Equities (EFA / VEU)
   - US Bonds (TLT / ZN futures)
   - Commodities (DBC / GLD)
   - REITs (VNQ)
   - Optionally: Emerging Markets (EEM), Crypto (BTC)
2. **Alpha Signal Computation**: For each asset class, compute one or more alpha signals:
   - **Momentum Alpha**: Trailing 3-month, 6-month, or 12-month total return
   - **Fundamental Alpha**: Relative value (e.g., equity earnings yield minus bond yield)
   - **Macro Alpha**: Economic surprise index, PMI direction
   - **Composite Alpha**: Weighted combination of the above
3. **Ranking and Selection**: Rank asset classes by composite alpha score. Allocate to the top 1-3 asset classes.
4. **Allocation**:
   - **Concentrated**: 100% in the top-ranked asset class
   - **Moderate**: 50% in top-1, 30% in top-2, 20% in top-3
   - **Risk-Adjusted**: Allocate among top-3 by inverse volatility within the selected set
5. **Rebalancing**: Monthly or quarterly.
6. **Cash Filter**: If no asset class has a positive alpha signal (e.g., all have negative 12-month momentum), move to cash/T-bills.
7. **Risk Management**: Cap maximum allocation to any single asset class at 50-60% in the moderate variant. Apply a drawdown circuit breaker: move to cash if portfolio drawdown exceeds 15%.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.5 - 0.9 |
| CAGR | 7% - 14% |
| Max Drawdown | -15% to -30% |
| Win Rate | 50% - 58% |
| Volatility | 10% - 18% annualized |
| Profit Factor | 1.2 - 1.5 |
| Rebalancing | Monthly to quarterly |

## Efficacy Rating

**3/5** --- Alpha rotation is an intuitive and appealing concept, and backtests often show attractive returns because the strategy captures the "best" performing asset class in hindsight. However, forward-looking alpha signals are noisy, and the strategy suffers from two key weaknesses: (1) concentration risk --- allocating heavily to a single asset class means a wrong call is very costly, and (2) whipsaw during regime transitions --- the strategy can rapidly rotate in and out of asset classes at exactly the wrong times. Performance is highly sensitive to the alpha signal choice and look-back period. The strategy works best as a complement to a diversified core portfolio rather than as a standalone allocation.

## Academic References

- Kakushadze, Z. & Serur, J. A. (2018). "151 Trading Strategies." *Palgrave Macmillan*. [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865)
- Antonacci, G. (2012). "Risk Premia Harvesting Through Dual Momentum." *Portfolio Management Consultants*.
- Keller, W. J. & Keuning, T. M. (2016). "Protective Asset Allocation (PAA): A Simple Momentum-Based Alternative for Term Deposits." *SSRN Working Paper*.
- Faber, M. T. (2007). "A Quantitative Approach to Tactical Asset Allocation." *Journal of Wealth Management*, 10(1), 69-79.

## Implementation Notes

- **Signal Selection is Critical**: The choice of alpha signal (momentum period, fundamental metric, or composite) drives most of the performance variation. Avoid over-optimizing; use simple, well-established signals.
- **Transaction Costs**: Rotation between asset classes can be expensive if turnover is high. Monthly rebalancing is a reasonable compromise between signal freshness and cost management.
- **Tax Efficiency**: Frequent rotation generates short-term capital gains. Consider in tax-advantaged accounts or use futures (which have different tax treatment in some jurisdictions).
- **Crypto Inclusion**: Adding BTC or a crypto index as one of the rotational asset classes is straightforward. The alpha signal (momentum) is directly applicable. Crypto's high volatility means it will be selected during strong uptrends and avoided during downtrends.
- **Pure Zig Implementation**: Trivially implementable. Compute returns over lookback periods, rank, allocate. The entire strategy logic is basic arithmetic and comparison operations.
- **Combination with Risk Parity**: Alpha rotation and risk parity can be combined: use risk parity as the base allocation and tilt toward alpha rotation signals. This provides diversification from risk parity with alpha capture from rotation.
