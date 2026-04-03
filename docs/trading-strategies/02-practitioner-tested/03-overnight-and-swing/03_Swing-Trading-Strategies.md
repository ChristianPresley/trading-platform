# Swing Trading Strategies

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/swing-trading-strategies/)
> **Asset Class**: US Equities (S&P 500 / SPY, Nasdaq 100 / QQQ, sector ETFs)
> **Crypto/24-7 Applicable**: Adaptable — multi-day holding periods work naturally in 24/7 crypto markets
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

Swing trading strategies hold positions for multiple days to weeks, capturing intermediate price moves between the ultra-short-term (intraday) and long-term (position trading) horizons. Quantified Strategies has published and backtested multiple swing trading approaches since 2012, with many continuing to perform well out-of-sample years after publication. The strategies generally combine a mean reversion entry signal with a trend-aligned regime filter and a time-based or indicator-based exit.

## Trading Rules

Swing trading encompasses multiple sub-strategies. The common framework includes:

### General Swing Framework
1. **Regime Filter**: Price must be above the 200-day SMA (bullish regime) for long entries.
2. **Entry Signal**: Look for a short-term oversold condition using RSI, Williams %R, Bollinger %B, or similar oscillator.
3. **Entry Execution**: Buy at the close when the entry conditions are met.
4. **Exit Signal**: Exit when:
   - The oscillator reaches overbought levels, OR
   - A fixed number of days have passed (typically 3-10 days), OR
   - Price reaches a profit target (e.g., previous swing high).
5. **Stop Loss**: Optional; many swing strategies use time-based exits rather than price-based stops.

### Example: RSI-Based Swing
1. **Entry**: Buy when 2-day RSI < 10 and price > 200 DMA.
2. **Exit**: Sell when 2-day RSI > 70.
3. **Typical hold**: 3-7 days.

### Example: Bollinger-Based Swing
1. **Entry**: Buy when %B < 0.05 for 2 consecutive days and price > 200 DMA.
2. **Exit**: Sell when %B > 0.80.
3. **Typical hold**: 3-10 days.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.8-1.5 (varies by sub-strategy) |
| CAGR | 6-12% (varies; invested 15-35% of the time) |
| Max Drawdown | 15-25% (varies by sub-strategy) |
| Win Rate | 65-80% |
| Volatility | Low to moderate (limited time-in-market) |
| Profit Factor | 1.8-3.0 |
| Rebalancing | Event-driven (signal-based, multi-day holds) |

*Note: Ranges reflect multiple sub-strategies. The best swing strategies published since 2012 have held up well in out-of-sample testing. Portfolio diversification across multiple swing strategies reduces overall risk.*

## Efficacy Rating

**3/5** — Swing trading as a category has a strong track record in quantified backtests. The multi-day holding period provides a practical balance between trade frequency and per-trade edge. The key advantage is that multiple swing strategies can be combined into a portfolio with diversification benefits. Quantified Strategies' published strategies have shown durability, with many performing well years after initial publication. The main risk is that mean reversion strategies can suffer during sustained directional moves or regime changes.

## Academic References

- Connors, L. & Alvarez, C. — *Short Term Trading Strategies That Work* (2008) — swing trading foundations
- Connors, L. & Raschke, L. — *Street Smarts* (1995) — classic swing patterns
- Clenow, A. — *Stocks on the Move* (2015) — systematic position management

## Implementation Notes

- **Portfolio approach**: Individual swing strategies are low-frequency. Running 5-10 swing strategies simultaneously as a portfolio provides diversification and more consistent returns.
- **Out-of-sample durability**: Quantified Strategies notes their published swing strategies (some since 2012) have continued to work out-of-sample, suggesting these are robust rather than overfit patterns.
- **Mean reversion bias**: Most swing strategies in this framework are mean reversion (buy oversold, sell on reversion). This means they can suffer during prolonged bear markets even with the 200 DMA filter.
- **Regime filter is critical**: The 200 DMA filter prevents buying into sustained downtrends. Without it, mean reversion entries during bear markets can produce significant losses.
- **Crypto adaptation**: Multi-day crypto swings work naturally since markets are continuous. Use the same oscillators (RSI, Williams %R, Bollinger %B) on daily candles. Consider a 100-day MA regime filter instead of 200-day for crypto's faster cycles.
- **Position sizing**: With multiple strategies running simultaneously, size each position to limit aggregate portfolio risk. If 3-4 strategies trigger simultaneously, total allocation should not exceed the portfolio's risk budget.
- **Execution**: Entry at the close means the signal is known before execution. This is execution-friendly and avoids the gap risk of next-open entries.
