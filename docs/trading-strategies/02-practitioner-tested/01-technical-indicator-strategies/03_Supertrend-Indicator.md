# Supertrend Indicator Strategy

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/supertrend-indicator-trading-strategy/)
> **Asset Class**: US Equities (S&P 500, weekly timeframe)
> **Crypto/24-7 Applicable**: Adaptable — trend-following logic works on any trending asset, but whipsaw risk is higher in ranging crypto markets
> **Evidence Tier**: Backtested Only
> **Complexity**: Simple

## Overview

The Supertrend indicator, originally proposed by Oliver Seban, uses the Average True Range (ATR) to create dynamic support/resistance bands around price. When price closes above the upper band, the trend is bullish; when it closes below the lower band, the trend is bearish. The strategy captures the majority of directional moves while avoiding the worst drawdowns. It performs best on instruments that maintain sustained directional trends.

## Trading Rules

1. **Calculate ATR**: Use a 10-period ATR (default).
2. **Calculate Supertrend Bands**:
   - Upper Band = (High + Low) / 2 + (3 x ATR)
   - Lower Band = (High + Low) / 2 - (3 x ATR)
3. **Entry Signal**: Go long when the close crosses above the Supertrend upper band.
4. **Exit Signal**: Close the position when the close crosses below the Supertrend lower band.
5. **Timeframe**: Weekly bars (as tested).
6. **Parameters**: ATR period = 10, multiplier = 3 (Oliver Seban defaults).

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.8 (estimated from weekly S&P 500) |
| CAGR | ~7% (S&P 500, 60-year backtest) |
| Max Drawdown | ~25% (significantly less than buy-and-hold) |
| Win Rate | 65.79% |
| Volatility | ~13% annualized |
| Profit Factor | ~1.8 |
| Rebalancing | Event-driven (weekly signal check) |

*Note: Average profit per trade is 11.07%. Strategy captures most upside returns while avoiding the worst drawdowns.*

## Efficacy Rating

**2/5** — Decent trend-following tool that reduces drawdowns versus buy-and-hold, but the weekly timeframe produces few signals and the strategy is prone to whipsaws in ranging markets. The 65.8% win rate is acceptable for trend-following but not exceptional. Works best on assets with strong, sustained trends.

## Academic References

- Seban, O. — Original Supertrend indicator specification
- Wilder, J.W. — *New Concepts in Technical Trading Systems* (1978) — ATR definition
- Hurst, B. et al. — "A Century of Evidence on Trend-Following Investing" (AQR, 2017)

## Implementation Notes

- **Timeframe matters**: The 60-year backtest uses weekly bars. Daily bars produce more whipsaws and lower win rates.
- **Asset selection**: The Supertrend works best on trending instruments. Applying it to range-bound assets or pairs will underperform.
- **Crypto adaptation**: Use 4-hour or daily candles. Consider reducing the multiplier from 3 to 2 for crypto's higher ATR values, or the bands will be too wide to generate timely signals.
- **Whipsaw filter**: Consider requiring 2 consecutive closes beyond the band before entry, or combining with a trend confirmation indicator.
- **Not mean reversion**: Unlike most other strategies in this section, Supertrend is purely trend-following. It pairs well with mean reversion strategies for portfolio diversification.
