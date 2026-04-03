# K-Nearest Neighbors

> **Source**: [151 Trading Strategies, Ch. 3](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) (Kakushadze & Serur, 2018); [QuantConnect Examples](https://www.quantconnect.com/)
> **Asset Class**: Equities (adaptable to other asset classes)
> **Crypto/24-7 Applicable**: Adaptable --- KNN is asset-class agnostic; can be applied to crypto with appropriate feature engineering
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

Uses the K-Nearest Neighbors (KNN) algorithm to predict stock return direction by comparing the current market state to the K most similar historical states. For each new observation defined by a feature vector (e.g., recent returns, volume ratios, volatility metrics), KNN identifies the K closest historical observations using a distance metric (typically Euclidean) and predicts the future return direction based on a majority vote of those neighbors' outcomes. The approach is non-parametric, making no assumptions about the distribution of returns, and can capture complex non-linear relationships.

## Trading Rules

1. **Feature Engineering**: Construct a feature vector for each trading day. Common features include: past 5-day and 20-day returns, RSI(14), volume ratio (current vs. 20-day average), realized volatility (20-day), Bollinger Band percentile.
2. **Training Set**: Use a rolling window of historical observations (e.g., 500-1000 trading days) as the reference set for neighbor lookup.
3. **Neighbor Selection**: For the current day's feature vector, compute the Euclidean distance to all training observations. Select the K nearest neighbors (K typically 5-20).
4. **Prediction**: Take a majority vote: if more than 50% of the K neighbors had positive returns in the subsequent period, predict a positive return.
5. **Signal Generation**: Go long when the prediction is positive, go to cash (or short) when negative.
6. **Feature Normalization**: Standardize all features to zero mean and unit variance to prevent any single feature from dominating the distance calculation.
7. **Risk Management**: Apply a volatility scaling layer: reduce position size when realized volatility exceeds 1.5x its 60-day average. Stop-loss at 2x ATR.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.5 - 1.0 |
| CAGR | 8% - 18% |
| Max Drawdown | -15% to -30% |
| Win Rate | 52% - 58% |
| Volatility | 12% - 20% annualized |
| Profit Factor | 1.1 - 1.4 |
| Rebalancing | Daily |

## Efficacy Rating

**3/5** --- KNN provides a simple, interpretable baseline for ML-based trading. Academic studies report prediction accuracies around 55-70% for direction, which is statistically meaningful but generates modest alpha after transaction costs. The main strengths are simplicity, interpretability (you can inspect which historical states drove the prediction), and no distributional assumptions. Weaknesses include high computational cost at prediction time (distance to all training points), sensitivity to feature selection and K choice, and degradation in high-dimensional feature spaces (curse of dimensionality). Performance trails more sophisticated ML methods like gradient boosting and neural networks.

## Academic References

- Kakushadze, Z. & Serur, J. A. (2018). "151 Trading Strategies." *Palgrave Macmillan*. [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865)
- Alkhatib, K. et al. (2013). "Stock Price Prediction Using K-Nearest Neighbor Algorithm." *International Journal of Business, Humanities and Technology*, 3(3). [PDF](https://ijbht.thebrpi.org/journals/Vol_3_No_3_March_2013/4.pdf)
- Gu, S., Kelly, B., & Xiu, D. (2020). "Empirical Asset Pricing via Machine Learning." *Review of Financial Studies*, 33(5), 2223-2273.
- Krauss, C., Do, X. A., & Huck, N. (2017). "Deep Neural Networks, Gradient-Boosted Trees, Random Forests: Statistical Arbitrage on the S&P 500." *European Journal of Operational Research*, 259(2), 689-702.

## Implementation Notes

- **Computational Cost**: KNN has O(N) prediction complexity where N is the training set size. For large universes or high-frequency signals, consider approximate nearest neighbor algorithms (e.g., KD-trees, ball trees).
- **Feature Selection**: Critical to performance. Too many features cause the curse of dimensionality; too few miss important market state information. Use feature importance from gradient boosting or mutual information as a guide.
- **K Selection**: Cross-validate over K values. Odd values avoid ties. Typical optimal K is 5-15 for daily stock prediction.
- **Distance Metric**: Euclidean is standard but Mahalanobis distance (accounting for feature correlations) can improve results.
- **Crypto Adaptation**: Replace equity-specific features with crypto equivalents. Add crypto-specific features like funding rates, exchange flows, and on-chain metrics.
- **Pure Zig Implementation**: KNN inference is a distance computation loop followed by a sort --- straightforward in Zig. Feature normalization uses basic statistics. The main challenge is efficient storage and retrieval of the training set, which can leverage Zig's array and sorting primitives.
