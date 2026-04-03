# Mean Reversion — Single Cluster

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 3 (Kakushadze & Serur, 2018)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: Adaptable — clustering methods apply to any asset class with sufficient cross-sectional data, though crypto correlations are less stable
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

The single-cluster mean reversion strategy identifies groups of statistically related securities using clustering techniques (such as k-means, hierarchical clustering, or PCA-based grouping) and trades deviations of individual securities from their cluster's mean behavior. When a stock diverges significantly from the average return or price level of its identified cluster, the strategy assumes this divergence is temporary and takes positions expecting convergence back to the cluster mean.

This approach improves upon naive mean reversion by replacing arbitrary sector or industry classifications with statistically derived groupings that capture actual co-movement patterns. By identifying a single coherent cluster of related securities, the strategy focuses on the most robust mean-reverting relationships and avoids trading spurious deviations across unrelated assets. The method has roots in statistical arbitrage and is closely related to pairs trading, generalized to a group setting.

## Trading Rules

1. **Universe**: A broad cross-section of liquid equities, typically 500-2,000 stocks with adequate daily volume and market capitalization.

2. **Cluster Identification**:
   - Compute a rolling correlation or covariance matrix of stock returns over a lookback window (typically 60-252 trading days).
   - Apply a clustering algorithm (k-means, spectral clustering, or hierarchical agglomerative clustering) to identify a single coherent cluster of stocks exhibiting strong co-movement.
   - The cluster should contain 10-50 stocks with high average pairwise correlation.

3. **Signal Generation**:
   - Calculate the cluster mean return (equal-weighted or PCA-weighted average of cluster members' returns) over a short lookback (5-20 days).
   - For each stock in the cluster, compute its deviation from the cluster mean (z-score of the residual return).
   - Generate a long signal when a stock's z-score falls below -1.5 to -2.0 (underperforming relative to the cluster).
   - Generate a short signal when a stock's z-score rises above +1.5 to +2.0 (outperforming relative to the cluster).

4. **Position Sizing**: Size positions proportional to the magnitude of the z-score deviation, with maximum position limits per stock.

5. **Exit Rules**: Close positions when the z-score reverts to within 0.5 standard deviations of the cluster mean, or after a maximum holding period of 5-20 trading days.

6. **Rebalancing**: Recalculate clusters monthly or quarterly; update trading signals daily.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.8-1.2 (varies by implementation) |
| CAGR | 5-10% (market-neutral) |
| Max Drawdown | -10% to -20% |
| Win Rate | 55-65% |
| Volatility | 6-12% annualized |
| Profit Factor | 1.2-1.6 |
| Rebalancing | Daily signals, monthly cluster updates |

Performance is highly sensitive to the clustering methodology, the lookback window for cluster estimation, and the z-score thresholds used for entry and exit. Market-neutral implementations tend to have lower volatility but also lower absolute returns.

## Efficacy Rating

**Rating: 3/5** — The theoretical foundation is sound and the approach addresses real limitations of naive mean reversion. However, practical performance is highly dependent on implementation details: the choice of clustering algorithm, the number of clusters, lookback windows, and threshold parameters all materially affect results. Cluster stability over time is a persistent challenge, as statistical groupings can shift significantly across regimes. The strategy also requires substantial computational infrastructure and data quality.

## Academic References

- Kakushadze, Z., & Serur, J. A. (2018). "151 Trading Strategies." *Palgrave Macmillan*. Chapter 3: Mean Reversion Strategies.
- Avellaneda, M., & Lee, J.-H. (2010). "Statistical Arbitrage in the U.S. Equities Market." *Quantitative Finance*, 10(7), 761-782.
- Cont, R., & Kukanov, A. (2017). "Optimal Order Placement in Limit Order Markets." *Quantitative Finance*, 17(1), 21-39.
- D'Aspremont, A. (2011). "Identifying Small Mean-Reverting Portfolios." *Quantitative Finance*, 11(3), 351-364.

## Implementation Notes

- **Cluster Stability**: The primary operational challenge. Clusters should be re-estimated periodically (monthly or quarterly), but overly frequent re-estimation introduces turnover and potential overfitting. Use a stability metric (e.g., adjusted Rand index) to assess how much cluster membership changes between periods.
- **Dimensionality Reduction**: PCA or factor models can improve clustering quality by reducing noise. Using the first 5-10 principal components of the return covariance matrix before clustering typically yields more stable groups.
- **Transaction Costs**: More favorable than short-term reversal strategies since the strategy focuses on a single cluster of correlated stocks. Turnover is moderate (100-300% annually).
- **Crypto Adaptation**: Applicable to crypto markets but with caveats. Crypto asset correlations tend to be higher and less differentiated (often dominated by a single "crypto beta" factor), making it harder to identify meaningful clusters. Shorter lookback windows (30-60 days) may be necessary to capture regime shifts.
- **Overfitting Risk**: Extensive parameter choices create risk of in-sample overfitting. Walk-forward validation with out-of-sample testing is essential.
