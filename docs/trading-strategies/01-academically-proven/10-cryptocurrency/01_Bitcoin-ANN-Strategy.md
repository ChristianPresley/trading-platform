# Bitcoin ANN Strategy

> **Source**: [151 Trading Strategies, Ch. 18](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) (Kakushadze & Serur, 2018)
> **Asset Class**: Cryptocurrency
> **Crypto/24-7 Applicable**: Yes --- native cryptocurrency strategy
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

Uses artificial neural networks (ANNs) to predict Bitcoin price direction based on technical indicators derived from historical price and volume data. A multi-layered deep neural network ingests features such as moving averages, RSI, MACD, and Bollinger Bands computed at intraday intervals (typically 15-minute bars), outputting a directional forecast that drives long/short position sizing. The approach exploits the non-linear, regime-dependent dynamics of BTC markets that linear models fail to capture.

## Trading Rules

1. **Feature Engineering**: Compute a set of technical indicators (e.g., SMA, EMA, RSI, MACD, Bollinger Band width, OBV) from rolling windows of 15-minute OHLCV bars.
2. **Model Architecture**: Train a 5-to-7-layer feedforward neural network on a rolling window of historical data (e.g., 90-180 days). Use dropout and batch normalization to reduce overfitting.
3. **Signal Generation**: The network outputs a probability of positive return over the next N bars. Go long when probability exceeds a threshold (e.g., 0.55), go short when below the inverse threshold (e.g., 0.45), remain flat otherwise.
4. **Position Sizing**: Scale position size proportionally to signal confidence (probability distance from 0.5).
5. **Retraining**: Retrain the model weekly or monthly on an expanding or sliding window to adapt to regime changes.
6. **Risk Management**: Apply a maximum position size cap. Use a trailing stop-loss at 2-3x ATR. Close all positions if drawdown exceeds a predefined threshold (e.g., 10%).

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 1.2 - 2.5 (varies by architecture and period) |
| CAGR | 30% - 90% (highly period-dependent) |
| Max Drawdown | -20% to -40% |
| Win Rate | 52% - 58% |
| Volatility | 30% - 60% annualized |
| Profit Factor | 1.3 - 1.8 |
| Rebalancing | Intraday (15-min to 1-hour signals) |

## Efficacy Rating

**3/5** --- Strong in-sample performance but faces significant out-of-sample degradation. Neural networks are prone to overfitting on noisy crypto data. Performance is highly sensitive to hyperparameter selection, retraining frequency, and market regime. Transaction costs and slippage at high-frequency intervals erode returns. Requires continuous model maintenance and monitoring. Academic evidence supports the approach conceptually, but live trading results are less consistent than backtests suggest.

## Academic References

- Nakano, M., Takahashi, A., & Takahashi, S. (2018). "Bitcoin technical trading with artificial neural network." *Physica A: Statistical Mechanics and its Applications*, 510, 587-609. [ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S0378437118308811)
- Kakushadze, Z. & Serur, J. A. (2018). "151 Trading Strategies." *Palgrave Macmillan*. [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865)
- Gu, S., Kelly, B., & Xiu, D. (2020). "Empirical Asset Pricing via Machine Learning." *Review of Financial Studies*, 33(5), 2223-2273.
- Akyildirim, E., Goncu, A., & Sensoy, A. (2023). "A profitable trading algorithm for cryptocurrencies using a Neural Network model." *Expert Systems with Applications*. [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S0957417423023084)

## Implementation Notes

- **Data Requirements**: High-quality intraday OHLCV data with minimal gaps. Kraken REST API provides 1-minute to 1-hour candles suitable for feature computation.
- **Computational Cost**: Training deep networks on rolling windows is computationally intensive. Consider GPU acceleration or pre-computed feature stores.
- **Latency Sensitivity**: Moderate. Signals update on 15-min to 1-hour bars, so sub-second execution is not critical, but fills should complete within the bar window.
- **Regime Awareness**: Crypto markets exhibit distinct regimes (trending, mean-reverting, low-volatility). The ANN may need separate models or regime detection layers to handle transitions.
- **Pure Zig Consideration**: Inference-only deployment is feasible in Zig using pre-trained weight matrices with manual forward-pass implementation. Training would remain offline in Python/Julia.
