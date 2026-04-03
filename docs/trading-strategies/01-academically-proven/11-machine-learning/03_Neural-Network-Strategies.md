# Neural Network Strategies

> **Source**: [QuantConnect TensorFlow/PyTorch Examples](https://www.quantconnect.com/); Academic deep learning for finance literature
> **Asset Class**: Equities (adaptable to other asset classes)
> **Crypto/24-7 Applicable**: Adaptable --- neural networks are architecture-agnostic and applicable to any asset class with sufficient data
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

Applies deep learning architectures --- Long Short-Term Memory (LSTM) networks, Transformer models, and convolutional neural networks (CNNs) --- to forecast asset prices or returns. These models learn hierarchical feature representations directly from raw or lightly processed market data, potentially discovering patterns invisible to traditional technical or fundamental analysis. LSTMs capture temporal dependencies in sequential price data, while Transformers use attention mechanisms to weigh the relevance of different time steps. Academic research shows deep learning methods outperform traditional models in certain regimes but face significant challenges with overfitting and non-stationarity.

## Trading Rules

1. **Data Preparation**: Construct input sequences of daily or intraday OHLCV data, plus auxiliary features (volume, volatility, macro indicators). Normalize using rolling z-scores.
2. **Model Architecture Selection**:
   - **LSTM**: 2-3 layer LSTM with 64-256 hidden units per layer. Input sequence length 20-60 days. Dropout 0.2-0.5 between layers.
   - **Transformer**: Multi-head self-attention with 2-4 layers, 4-8 attention heads, embedding dimension 64-128. Positional encoding for temporal ordering.
   - **CNN**: 1D convolutions over time with kernel sizes 3, 5, 7 for multi-scale pattern detection.
3. **Training**: Train on 3-5 years of rolling data. Use Adam optimizer with learning rate scheduling. Early stopping on validation loss. Purged/embargoed train-validation split.
4. **Output**: Predicted return (regression) or probability of positive return (classification) for the next 1-5 days.
5. **Signal Generation**: Go long when predicted return exceeds a threshold; short when below negative threshold; flat otherwise.
6. **Ensemble**: Combine predictions from multiple architectures (LSTM + Transformer + gradient boosting) for more robust signals.
7. **Risk Management**: Volatility scaling to target 15% annualized portfolio volatility. Maximum 3% risk per position. Drawdown-based position reduction.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.7 - 1.8 |
| CAGR | 12% - 35% |
| Max Drawdown | -15% to -30% |
| Win Rate | 52% - 58% |
| Volatility | 12% - 22% annualized |
| Profit Factor | 1.2 - 1.7 |
| Rebalancing | Daily |

## Efficacy Rating

**3/5** --- Deep learning shows the highest in-sample performance of any ML approach but faces the most severe overfitting risk. Academic studies (Gu et al., 2020) find neural networks achieve the highest out-of-sample R-squared for cross-sectional return prediction, but the edge is modest (1-3% improvement over gradient boosting). LSTMs and Transformers excel at capturing temporal patterns but require substantially more data and computation than simpler methods. The non-stationarity of financial markets means models degrade quickly without frequent retraining. Ensemble approaches that combine neural networks with tree-based methods tend to be more robust than any single architecture.

## Academic References

- Gu, S., Kelly, B., & Xiu, D. (2020). "Empirical Asset Pricing via Machine Learning." *Review of Financial Studies*, 33(5), 2223-2273.
- Sirignano, J. & Cont, R. (2019). "Universal Features of Price Formation in Financial Markets: Perspectives from Deep Learning." *Quantitative Finance*, 19(9), 1449-1459.
- Zhang, Z., Zohren, S., & Roberts, S. (2020). "Deep Learning for Portfolio Optimization." *Journal of Financial Data Science*, 2(4), 8-20.
- Lim, B. et al. (2021). "Temporal Fusion Transformers for Interpretable Multi-horizon Time Series Forecasting." *International Journal of Forecasting*, 37(4), 1748-1764.

## Implementation Notes

- **Computational Requirements**: Training deep neural networks requires GPUs. LSTMs train in minutes to hours on modern GPUs; Transformers may require hours to days for large universes.
- **Overfitting Mitigation**: Use dropout, weight decay, early stopping, and data augmentation (e.g., adding noise to inputs). Ensemble multiple models trained on different random seeds.
- **Retraining Frequency**: Monthly retraining is a common balance between adaptation and stability. Weekly retraining for shorter-horizon signals.
- **Interpretability**: Neural networks are black boxes. Use attention weights (Transformers) or gradient-based attribution (LSTMs) for partial interpretability.
- **Crypto Adaptation**: Crypto data has higher signal-to-noise ratio than equities for short-term prediction, potentially benefiting deep learning. However, shorter history limits training data availability.
- **Pure Zig Implementation**: Inference from pre-trained models is feasible in Zig by implementing matrix multiplication, activation functions, and attention mechanisms. LSTM and Transformer forward passes are well-defined mathematical operations. Training remains offline in Python/PyTorch/TensorFlow. Model weights are loaded from serialized files.
