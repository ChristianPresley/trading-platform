# IBS (Internal Bar Strength) Mean Reversion

> **Source**: [Quantified Strategies — IBS Indicator](https://www.quantifiedstrategies.com/internal-bar-strength-ibs-indicator-strategy/), [Alvarez Quant Trading — IBS for Mean Reversion](https://alvarezquanttrading.com/blog/internal-bar-strength-for-mean-reversion/)
> **Asset Class**: ETFs / Equities
> **Crypto/24-7 Applicable**: Adaptable — IBS can be applied to any instrument with OHLC data, though the edge is strongest in equity indices with daily close dynamics
> **Evidence Tier**: Backtested Only
> **Complexity**: Simple

## Overview

The Internal Bar Strength (IBS) indicator is a simple mean-reversion tool that measures where the closing price falls relative to the day's high-low range. IBS is calculated as (Close - Low) / (High - Low), yielding a value between 0 and 1. When IBS is near 0, the close is near the day's low (suggesting oversold conditions); when IBS is near 1, the close is near the day's high (suggesting overbought conditions). The strategy buys when IBS is extremely low and sells when IBS reverts to neutral or high levels.

The IBS indicator has been remarkably effective on equity indices and broad ETFs for over two decades. The stock market's strong mean-reverting tendency at the daily frequency provides a favorable environment for IBS-based strategies. The indicator works best on diversified indices (S&P 500, NASDAQ 100, global equity ETFs) where intraday selling pressure that pushes the close near the low tends to be followed by a bounce the next day. The effect is weaker on individual stocks and largely absent in trending asset classes like commodities and currencies.

## Trading Rules

1. **Universe**: Broad equity index ETFs (SPY, QQQ, IWM, FXI, EEM) or equity index futures. The strategy works best on instruments with strong daily mean-reversion characteristics.

2. **IBS Calculation**: At the daily close, compute IBS = (Close - Low) / (High - Low).

3. **Entry Rules**:
   - **Long Entry**: Buy at the close when IBS < 0.2 (or more aggressively, < 0.1). Some implementations add a secondary filter: RSI(21) < 45.
   - The lower the IBS threshold, the fewer trades but the higher the win rate and average return per trade.

4. **Exit Rules**:
   - **Primary Exit**: Sell at the close when the closing price is higher than yesterday's close (i.e., the next up-close day).
   - **Alternative Exit**: Sell when IBS > 0.8 (close near the high of the day).
   - **Time Stop**: Close the position after a maximum of 5-7 trading days if neither exit condition is met.

5. **Position Sizing**: Full position (100% of allocated capital) per trade, as the strategy is designed for short holding periods with high win rates.

6. **No Short Side**: The strategy is most effective as a long-only approach. Short-side mean reversion (selling when IBS > 0.8) is less reliable and often produces weaker risk-adjusted returns.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~1.0-1.3 (instrument-dependent) |
| CAGR | 14.8% (backtested on FXI) |
| Max Drawdown | -47% (FXI backtest) |
| Win Rate | 65-75% |
| Volatility | 12-18% annualized |
| Profit Factor | 1.75 (FXI backtest) |
| Rebalancing | Daily (event-driven signals) |

Performance varies significantly by instrument. The FXI (China Large-Cap ETF) backtest showed a CAGR of 14.8% with a profit factor of 1.75, though with a substantial max drawdown of 47%. On SPY, the win rate tends to be higher (70%+) but the CAGR is lower. The high max drawdown reflects the strategy's full exposure during severe market selloffs when IBS remains low for extended periods.

## Efficacy Rating

**Rating: 3/5** — A practical, easy-to-implement strategy with strong backtested results on equity indices. The simplicity of the indicator is both a strength (robustness, interpretability) and a limitation (no adaptation to changing regimes). The primary concerns are the large max drawdown during extended bear markets, the concentration of performance on a narrow set of instruments (equity indices), and limited academic backing compared to more rigorously studied anomalies. The strategy is best used as a component signal within a broader system rather than as a standalone approach.

## Academic References

- Connors, L. A., & Alvarez, C. (2009). "Short Term Trading Strategies That Work." *TradingMarkets Publishing*.
- Connors, L. A., & Raschke, L. B. (1995). "Street Smarts: High Probability Short-Term Trading Strategies." *M. Gordon Publishing Group*.
- Kinlay, J. (2019). "The Internal Bar Strength Indicator." *Systematic Strategies Research*.
- Quantified Strategies (2023). "Internal Bar Strength (IBS) Indicator Strategies, Trading Rules and Backtests." *QuantifiedStrategies.com*.

## Implementation Notes

- **Simplicity Advantage**: IBS requires only OHLC (Open, High, Low, Close) data, making it one of the simplest indicators to compute. No lookback period, no parameters to optimize beyond the threshold — this reduces overfitting risk substantially.
- **Instrument Selection Matters**: IBS works well on: SPY, QQQ, IWM, FXI, EEM (equity index ETFs). It works poorly on: GLD, TLT, USO, UNG (commodities, bonds) and individual stocks with idiosyncratic risk.
- **Combining with RSI**: Adding a secondary filter (e.g., RSI(21) < 45) reduces the number of trades but improves quality. The combined IBS + RSI filter produces higher Sharpe ratios than IBS alone.
- **Drawdown Management**: The strategy's largest drawdowns occur during extended market declines (2008-2009, March 2020) when IBS signals keep firing but the market continues lower. Consider adding a trend filter (e.g., price above the 200-day SMA) to avoid buying into bear markets.
- **Crypto Adaptation**: IBS can be computed on crypto daily bars, but the 24/7 market structure changes the dynamics. The "close" in crypto is arbitrary (midnight UTC on most exchanges), and the concept of "near the daily low" carries less meaning without a fixed session. Testing on crypto suggests weaker and less consistent results than on equity indices.
- **Latency**: The strategy requires execution at or near the daily close, which is straightforward for equity ETFs but requires careful handling of the close auction process for large position sizes.
