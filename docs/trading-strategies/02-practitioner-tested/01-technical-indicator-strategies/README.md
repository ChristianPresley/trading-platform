# Technical Indicator Strategies

Strategies built on classical and modern technical indicators, backtested primarily on equity indices (S&P 500, Nasdaq 100). Most originate from Quantified Strategies with published backtest results.

## Contents

| # | Strategy | Indicator Type | Rating | Crypto Applicable |
|---|----------|---------------|--------|-------------------|
| 01 | [Triple RSI](01_Triple-RSI.md) | Momentum / Mean Reversion | 3/5 | Adaptable |
| 02 | [Williams %R](02_Williams-Percent-R.md) | Momentum / Mean Reversion | 3/5 | Adaptable |
| 03 | [Supertrend](03_Supertrend-Indicator.md) | Trend Following | 2/5 | Adaptable |
| 04 | [Keltner Channel](04_Keltner-Channel.md) | Volatility / Breakout | 2/5 | Adaptable |
| 05 | [Bollinger Bands](05_Bollinger-Bands.md) | Volatility / Mean Reversion | 3/5 | Adaptable |
| 06 | [Golden Cross](06_Golden-Cross.md) | Trend Following | 3/5 | Adaptable |
| 07 | [200-Day Moving Average](07_200-Day-Moving-Average.md) | Trend / Regime Filter | 3/5 | Adaptable |
| 08 | [Ichimoku Cloud](08_Ichimoku-Cloud.md) | Multi-Factor Trend | 2/5 | Adaptable |
| 09 | [ATR Bands](09_ATR-Bands.md) | Volatility / Mean Reversion | 2/5 | Adaptable |

## Common Themes

- **Mean reversion dominates**: RSI, Williams %R, Bollinger Bands, and ATR Bands all exploit oversold conditions in equity indices.
- **Trend filters improve results**: Most strategies benefit from a 200-day MA regime filter.
- **Low time-in-market**: Many strategies are invested less than 25% of the time, reducing tail risk exposure.
- **S&P 500 / Nasdaq bias**: Results are primarily backtested on US large-cap equities; crypto adaptation requires volatility parameter adjustments.
