# Mean Reversion — Multiple Clusters

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 3 (Kakushadze & Serur, 2018)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: Adaptable — multiple-cluster methods generalize to any liquid cross-section, though crypto market structure requires careful cluster count selection
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

The multiple-cluster mean reversion strategy extends the single-cluster approach by simultaneously identifying and trading across several distinct clusters of co-moving securities. Rather than focusing on one statistically coherent group, this method partitions the investment universe into multiple clusters and trades mean-reverting deviations within each cluster independently. The portfolio then aggregates signals across all clusters, diversifying across multiple independent mean-reversion relationships.

The key advantage over the single-cluster variant is diversification: by operating across multiple independent clusters, the strategy reduces reliance on any single co-movement relationship and generates a more consistent return stream. The approach is closely related to the eigenportfolio framework in statistical arbitrage, where residual returns relative to multiple factors (each corresponding roughly to a cluster) are traded as mean-reverting processes. The additional complexity lies in determining the optimal number of clusters, managing inter-cluster correlations, and allocating capital across clusters with different characteristics.

## Trading Rules

1. **Universe**: A broad cross-section of liquid equities (500-3,000 stocks) with adequate daily volume.

2. **Cluster Identification**:
   - Compute a rolling return covariance or correlation matrix over a lookback window (60-252 trading days).
   - Apply a clustering algorithm (k-means, spectral clustering, or Gaussian mixture models) to partition the universe into K clusters (typically K = 5-20).
   - Use a model selection criterion (silhouette score, gap statistic, or BIC for Gaussian mixtures) to determine the optimal number of clusters.
   - Each cluster should contain at least 10 stocks for statistical robustness.

3. **Signal Generation** (per cluster):
   - Calculate the cluster centroid return (equal-weighted or eigenportfolio-weighted average).
   - For each stock, compute the z-score of its residual return relative to its cluster centroid over a short lookback (5-20 days).
   - Long signal when z-score < -1.5; short signal when z-score > +1.5.

4. **Cross-Cluster Aggregation**:
   - Treat each cluster as an independent sub-strategy.
   - Allocate capital across clusters proportional to inverse volatility or equal-risk contribution.
   - Enforce position limits at both the individual stock and cluster levels.

5. **Exit Rules**: Close individual positions when z-score reverts within 0.5 standard deviations of the cluster mean, or after a maximum holding period of 5-20 days.

6. **Rebalancing**: Daily signal updates; re-estimate clusters monthly or quarterly.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 1.0-1.5 (varies by implementation) |
| CAGR | 6-12% (market-neutral) |
| Max Drawdown | -8% to -18% |
| Win Rate | 55-65% |
| Volatility | 5-10% annualized |
| Profit Factor | 1.3-1.7 |
| Rebalancing | Daily signals, monthly cluster updates |

The improvement over the single-cluster variant comes primarily from diversification across independent clusters. Lower volatility and improved drawdown characteristics are the primary benefits, with modest improvement in Sharpe ratio driven by reduced idiosyncratic risk.

## Efficacy Rating

**Rating: 3/5** — Theoretically superior to the single-cluster approach due to diversification, but practical implementation is significantly more complex. The strategy introduces additional parameters (number of clusters, capital allocation across clusters, cluster selection criteria) that create more degrees of freedom for overfitting. Cluster instability compounds when managing multiple groups simultaneously, and the computational burden scales with universe size. The incremental benefit over simpler mean-reversion approaches must be weighed against the added complexity and operational risk.

## Academic References

- Kakushadze, Z., & Serur, J. A. (2018). "151 Trading Strategies." *Palgrave Macmillan*. Chapter 3: Mean Reversion Strategies.
- Avellaneda, M., & Lee, J.-H. (2010). "Statistical Arbitrage in the U.S. Equities Market." *Quantitative Finance*, 10(7), 761-782.
- Kakushadze, Z. (2015). "Mean-Reversion and Optimization." *Journal of Asset Management*, 16(1), 14-40.
- Kakushadze, Z., & Yu, W. (2017). "Statistical Industry Classification." *Journal of Risk & Control*, 4(1), 17-65.
- Marco, I., & Avalos, M. (2021). "Machine Learning for Statistical Arbitrage: Clustering Approaches." *Journal of Financial Data Science*, 3(4), 72-91.

## Implementation Notes

- **Cluster Count Selection**: The optimal number of clusters K is a critical parameter. Too few clusters result in heterogeneous groups with weak mean-reversion signals; too many create small, unstable clusters. The silhouette score or gap statistic provides a data-driven approach, but should be validated with walk-forward analysis.
- **Inter-Cluster Correlations**: While individual cluster signals should be independent, in practice clusters may share exposure to common macro factors. Monitor aggregate portfolio factor exposures (market beta, sector tilts, size, value) and hedge residual exposures as needed.
- **Computational Overhead**: Clustering a universe of 2,000+ stocks monthly, plus daily z-score calculations across multiple clusters, requires efficient implementation. Pre-computing factor decompositions and using incremental clustering updates can reduce latency.
- **Regime Sensitivity**: Cluster structure changes materially across market regimes (e.g., risk-on/risk-off environments compress correlations). Shorter estimation windows respond faster to regime changes but produce noisier cluster estimates.
- **Crypto Adaptation**: The high correlation among crypto assets (crypto beta dominance) means that multiple-cluster methods may identify fewer meaningful clusters than in equities. Consider incorporating on-chain metrics, tokenomics categories, or sector labels (DeFi, L1, L2, memecoins) as priors for cluster initialization.
- **Scalability**: One of the more computationally intensive mean-reversion approaches. For a Zig implementation, the matrix operations (covariance estimation, eigendecomposition, clustering) should be optimized with SIMD and cache-aware algorithms.
