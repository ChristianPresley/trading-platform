# Ichimoku Cloud (Ichimoku Kinko Hyo)

> **Source**: [QuantConnect](https://www.quantconnect.com/research/9031/ichimoku-clouds-in-the-energy-sector/) / [Quantified Strategies](https://www.quantifiedstrategies.com/ichimoku-strategy/)
> **Asset Class**: US Equities (S&P 500, Nasdaq 100, Midcap), Crypto (Bitcoin)
> **Crypto/24-7 Applicable**: Adaptable — trend-following nature suits crypto well; Bitcoin backtests show significantly better results than equities
> **Evidence Tier**: Backtested Only
> **Complexity**: Complex

## Overview

Ichimoku Kinko Hyo ("one glance equilibrium chart") is a comprehensive trend identification system developed by Goichi Hosoda in the 1930s. It uses five calculated lines to define trend direction, momentum, and support/resistance. The "cloud" (Kumo) formed between Senkou Span A and B provides a visual trend bias. The strategy goes long when price is above the cloud and short (or flat) when below. While it effectively reduces drawdowns, backtests show it generally underperforms buy-and-hold on equities, with the notable exception of Bitcoin.

## Trading Rules

1. **Calculate Five Lines**:
   - **Tenkan-sen** (Conversion): (9-period high + 9-period low) / 2
   - **Kijun-sen** (Base): (26-period high + 26-period low) / 2
   - **Senkou Span A** (Leading Span A): (Tenkan-sen + Kijun-sen) / 2, plotted 26 periods ahead
   - **Senkou Span B** (Leading Span B): (52-period high + 52-period low) / 2, plotted 26 periods ahead
   - **Chikou Span** (Lagging): Close plotted 26 periods behind
2. **Entry Signal**: Buy when price closes above the cloud AND Tenkan-sen is above Kijun-sen.
3. **Exit Signal**: Sell when price closes below the cloud OR Tenkan-sen crosses below Kijun-sen.
4. **Cloud Color**: Bullish when Senkou Span A > Senkou Span B (green cloud); bearish when reversed.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | -0.23 (energy sector, QuantConnect) / ~0.5 (S&P 500) |
| CAGR | 5.2% (S&P 500) / 7.7% (QQQ) / 78% (Bitcoin) |
| Max Drawdown | ~25% (50%+ reduction vs buy-and-hold on midcaps) |
| Win Rate | ~55% |
| Volatility | Lower than buy-and-hold across all timeframes |
| Profit Factor | ~1.3 (equities) |
| Rebalancing | Event-driven (signal-based) |

*Note: S&P 500 CAGR of 5.2% underperforms buy-and-hold (6.9%). QQQ invested only 63% of the time. Bitcoin dramatically outperforms due to strong trending behavior.*

## Efficacy Rating

**2/5** — The Ichimoku system is a comprehensive framework with strong theoretical underpinnings, but backtests consistently show it underperforms simple buy-and-hold on major equity indices. Its strengths are drawdown reduction (50%+ on midcaps) and lower volatility. The Bitcoin application is a standout, with 78% CAGR significantly beating buy-and-hold. The complexity of the system (five interacting lines) makes it harder to optimize and more prone to overfitting.

## Academic References

- Hosoda, G. — *Ichimoku Kinko Hyo* (original seven-volume work, 1969)
- Patel, M. — *Trading with Ichimoku Clouds* (2010)
- Elliott, N. — *Ichimoku Charts: An Introduction to Ichimoku Kinko Clouds* (2007)

## Implementation Notes

- **Complexity cost**: Five interacting indicators mean more parameters and more ways to overfit. Consider using only the cloud (Senkou Span A/B) as the primary signal and ignoring Chikou Span.
- **Bitcoin standout**: The 78% CAGR on Bitcoin makes Ichimoku one of the best-performing trend indicators for crypto in this collection. The strong trending behavior of Bitcoin plays to Ichimoku's strengths.
- **Equity weakness**: On S&P 500 and Nasdaq, the strategy underperforms buy-and-hold. Use it for drawdown reduction rather than return enhancement.
- **Drawdown reduction**: The 50%+ reduction in max drawdown on midcap equities (MDY) is significant and may justify the CAGR underperformance for risk-averse allocations.
- **Parameter origins**: The 9/26/52 periods were designed for Japanese equity markets with 6-day trading weeks. Some practitioners adjust to 7/22/44 for modern 5-day markets.
- **Crypto parameters**: For crypto on 4-hour candles, some practitioners use 20/60/120 to approximate the original weekly cycle intent.
