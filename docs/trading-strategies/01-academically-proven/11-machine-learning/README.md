# 11 - Machine Learning Strategies

Strategies that use machine learning and natural language processing techniques to generate trading signals. These approaches learn patterns from historical data rather than relying on pre-specified rules, offering the potential to discover non-obvious relationships but also introducing risks of overfitting and model degradation.

## Strategies

| # | Strategy | Rating | Complexity | Key Concept |
|---|----------|--------|------------|-------------|
| 01 | [K-Nearest Neighbors](01_K-Nearest-Neighbors.md) | 3/5 | Moderate | Predict returns by finding similar historical market states |
| 02 | [Gradient Boosting Models](02_Gradient-Boosting-Models.md) | 3/5 | Moderate | XGBoost/LightGBM for factor selection and return prediction |
| 03 | [Neural Network Strategies](03_Neural-Network-Strategies.md) | 3/5 | Complex | LSTM/Transformer deep learning for price forecasting |
| 04 | [SVM-Wavelet Forecasting](04_SVM-Wavelet-Forecasting.md) | 2/5 | Complex | Wavelet decomposition + SVM for denoised time series prediction |
| 05 | [Lexical Density of Filings](05_Lexical-Density-Filings.md) | 3/5 | Moderate | NLP on SEC filings to predict returns from linguistic features |
| 06 | [Sentiment NLP Trading](06_Sentiment-NLP-Trading.md) | 3/5 | Complex | NLP sentiment analysis from news and social media |

## Key Themes

- **Gradient boosting is the practical workhorse**: Among pure ML approaches, gradient boosting (XGBoost, LightGBM) offers the best trade-off between performance, robustness, and implementation complexity. It consistently outperforms simpler methods and is more robust than deep learning in most financial applications.
- **Deep learning has highest potential but highest risk**: Neural networks achieve the best in-sample performance but face severe overfitting challenges. Ensemble approaches combining neural networks with tree-based methods tend to be most robust.
- **NLP strategies exploit alternative data**: Sentiment and linguistic analysis tap into information not captured by price and volume alone. However, data acquisition and pipeline reliability are significant operational challenges.
- **All ML strategies require offline training**: The training/retraining phase is computationally intensive and best done offline. Only the inference/scoring phase needs to run in real-time within the trading system.
- **Simpler is often better**: KNN and gradient boosting frequently outperform complex deep learning architectures on a risk-adjusted basis after accounting for transaction costs and model maintenance overhead.

## Crypto Applicability

| Strategy | Crypto Applicable | Notes |
|----------|-------------------|-------|
| K-Nearest Neighbors | Adaptable | Replace equity features with crypto-specific features |
| Gradient Boosting Models | Adaptable | Add on-chain metrics, funding rates as features |
| Neural Network Strategies | Adaptable | Higher signal-to-noise in crypto may benefit deep learning |
| SVM-Wavelet Forecasting | Adaptable | Higher noise in crypto may reduce wavelet benefit |
| Lexical Density of Filings | No | SEC filings are equity-specific; no crypto equivalent |
| Sentiment NLP Trading | Adaptable | Crypto is heavily sentiment-driven; high applicability |

## Implementation Architecture

For this trading platform, ML strategies follow a two-tier architecture:

1. **Offline Training Tier** (Python/Julia): Model training, hyperparameter tuning, backtesting, and feature engineering. Produces serialized model artifacts.
2. **Online Inference Tier** (Zig): Loads pre-trained model weights, computes features from real-time market data, scores predictions, and generates trading signals with deterministic latency.

This separation allows the platform to benefit from the rich ML ecosystem (PyTorch, scikit-learn, XGBoost) for model development while maintaining the performance guarantees of Zig for production inference.
