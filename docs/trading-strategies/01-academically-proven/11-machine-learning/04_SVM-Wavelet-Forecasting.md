# SVM-Wavelet Forecasting

> **Source**: [QuantConnect Research](https://www.quantconnect.com/); Academic literature on wavelet-SVM hybrid models
> **Asset Class**: Equities (adaptable to other asset classes)
> **Crypto/24-7 Applicable**: Adaptable --- wavelet decomposition and SVM are applicable to any time series
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

Combines discrete wavelet transform (DWT) with support vector machines (SVM) for financial time series forecasting. Wavelet decomposition separates the price series into approximation (trend) and detail (noise) components at multiple frequency scales. Each component is then individually forecast using an SVM regressor, and the forecasts are recombined to produce the final prediction. This hybrid approach addresses a fundamental challenge in financial forecasting: the mixture of signal (trends) and noise (microstructure, random fluctuations) at different frequency scales. By decomposing and forecasting separately, the model avoids forcing a single model to handle both smooth trends and high-frequency noise.

## Trading Rules

1. **Wavelet Decomposition**: Apply a multi-level DWT (e.g., Daubechies-4 wavelet, 3-4 decomposition levels) to the closing price or return series over a rolling window (e.g., 120-250 days).
2. **Component Extraction**: Extract the approximation coefficient (low-frequency trend) and detail coefficients (high-frequency noise components) at each level.
3. **SVM Training**: Train separate SVM regressors (with RBF or wavelet kernel) on each decomposed component:
   - Train SVM-A on the approximation series to forecast the trend component.
   - Train SVM-D1, SVM-D2, SVM-D3 on each detail series to forecast noise components.
4. **Reconstruction**: Sum the individual SVM forecasts to produce the composite price/return prediction.
5. **Signal Generation**: Go long when the predicted return exceeds a threshold (e.g., +0.5% daily); go short when below the inverse threshold; flat otherwise.
6. **Hyperparameter Tuning**: Optimize SVM parameters (C, gamma, epsilon) and wavelet parameters (wavelet family, decomposition level) via time-series cross-validation.
7. **Risk Management**: Apply a confidence filter based on SVM prediction margin. Reduce position size when the prediction is close to zero. Stop-loss at 2x ATR.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.5 - 1.0 |
| CAGR | 8% - 15% |
| Max Drawdown | -15% to -25% |
| Win Rate | 55% - 65% |
| Volatility | 12% - 18% annualized |
| Profit Factor | 1.1 - 1.4 |
| Rebalancing | Daily |

## Efficacy Rating

**2/5** --- The wavelet-SVM approach is theoretically elegant and produces strong in-sample results, but practical performance is disappointing. Wavelet decomposition reduces forecast errors by 20-40% compared to raw-series SVM, and directional accuracy can reach 80% in controlled studies. However, these results are heavily influenced by look-ahead bias in the wavelet decomposition step (boundary effects at the end of the series), overfitting in the multi-component SVM training, and unrealistic assumptions about transaction costs. The complexity of the approach (wavelet family selection, decomposition level, SVM parameters per component) creates a large hyperparameter space prone to overfitting. Simpler methods (gradient boosting, trend following) tend to outperform on a risk-adjusted basis in live trading.

## Academic References

- Huang, W. et al. (2005). "Forecasting stock market movement direction with support vector machine." *Computers & Operations Research*, 32(10), 2513-2522.
- Hsieh, T. J., Hsiao, H. F., & Yeh, W. C. (2011). "Forecasting stock markets using wavelet transforms and recurrent neural networks." *Expert Systems with Applications*, 38(3), 3600-3607.
- Li, J. & Chen, W. (2014). "Forecasting macroeconomic time series: LASSO-based approaches and their forecast combinations with dynamic factor models." *International Journal of Forecasting*, 30(4), 996-1015.
- Fan, G. F. et al. (2008). "Forecasting of stock returns by using manifold wavelet support vector machine." *Journal of Shanghai Jiaotong University (Science)*, 15, 250-254. [Springer](https://link.springer.com/article/10.1007/s12204-010-9707-0)

## Implementation Notes

- **Wavelet Boundary Effects**: The most critical implementation issue. DWT at the boundaries of a finite time series produces artifacts that can create false signals. Use symmetric padding or stationary wavelet transform (SWT) to mitigate.
- **Computational Cost**: Training multiple SVMs per instrument per day is expensive. SVM training is O(N^2) to O(N^3) in the number of training samples.
- **Wavelet Selection**: Daubechies-4 (db4) is most commonly used in finance. Haar wavelets are simpler but less smooth. The choice materially affects results.
- **Decomposition Level**: 3-4 levels for daily data is typical. Too few levels fail to separate signal from noise; too many create overly smooth approximations that lag.
- **Crypto Adaptation**: Applicable to crypto time series but the higher noise level and regime changes in crypto may reduce the benefit of wavelet decomposition.
- **Pure Zig Implementation**: DWT is a series of convolutions with filter coefficients, implementable in Zig. SVM inference requires computing kernel function values against support vectors, which is matrix arithmetic. Training would remain offline. The overall pipeline is more complex than simpler strategies but entirely feasible in Zig.
