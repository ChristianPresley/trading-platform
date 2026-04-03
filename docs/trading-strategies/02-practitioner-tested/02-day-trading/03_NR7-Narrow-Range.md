# NR7 Narrow Range Strategy

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/nr7-trading-strategy/)
> **Asset Class**: US Equities (S&P 500 / SPY)
> **Crypto/24-7 Applicable**: Adaptable — volatility contraction/expansion cycles exist in all liquid markets including crypto
> **Evidence Tier**: Backtested Only
> **Complexity**: Simple

## Overview

The NR7 (Narrow Range 7) strategy, developed by Toby Crabel, identifies days when the daily price range (high minus low) is the narrowest of the last seven trading days. This volatility contraction signals that a significant directional move is imminent. The strategy enters on the NR7 day and holds for several days to capture the subsequent volatility expansion. Quantified Strategies improved the original strategy by adding a single filtering parameter that increased average gain per trade and reduced drawdown.

## Trading Rules

### Original Strategy
1. **Identify NR7 Day**: Today's range (high - low) is the smallest of the last 7 trading days.
2. **Entry Signal**: Buy at the close on the NR7 day.
3. **Exit Signal**: Sell after N days (holding period varies; typically 3-5 days).
4. **Direction**: Long only (on S&P 500).

### Improved Strategy (Quantified Strategies Enhancement)
1. **Identify NR7 Day**: Same as above.
2. **Additional Filter**: One additional parameter is added (specific parameter not publicly disclosed, but described as improving average gain per trade from 0.27% to 0.45%).
3. **Entry Signal**: Buy at the close when both NR7 and the filter condition are met.
4. **Exit Signal**: Sell after the designated holding period.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.7 (original) / ~0.9 (improved) |
| CAGR | 7.8% (original) / ~9% (improved, estimated) |
| Max Drawdown | 25% (original) / 19% (improved) |
| Win Rate | ~65% (original) / ~70% (improved, high) |
| Volatility | Moderate (invested ~35% of time, original) |
| Profit Factor | ~1.7 (original) / 2.3 (improved) |
| Rebalancing | Event-driven (signal-based, multi-day holds) |

*Note: Original: 899 trades, $100K invested since 1993, average gain 0.27% per trade. Improved: fewer trades, average gain 0.45% per trade, drawdown reduced from 25% to 19%.*

## Efficacy Rating

**3/5** — A sound volatility-based concept with strong theoretical backing (volatility contraction precedes expansion). The original strategy produces acceptable but unspectacular results. The improved version with the additional filter is genuinely better (profit factor 2.3, drawdown reduced to 19%). The strategy generates enough trades (hundreds over the backtest period) to be statistically meaningful. Simple enough to implement reliably.

## Academic References

- Crabel, T. — *Day Trading with Short Term Price Patterns and Opening Range Breakout* (1990) — original NR7 definition
- Connors, L. & Raschke, L. — *Street Smarts* (1995) — NR7 pattern trading
- Mandelbrot, B. — "The Variation of Certain Speculative Prices" (1963) — volatility clustering theory

## Implementation Notes

- **Volatility contraction principle**: NR7 works because volatility is mean-reverting and clustered. Low-volatility days tend to precede high-volatility days. This principle is universal across asset classes.
- **Not a day trade**: Despite being in the "day trading" section, the holding period is multiple days. The NR7 identification happens intraday, but the trade itself is a swing trade.
- **Improved version**: The single additional filter (undisclosed) lifts average gain from 0.27% to 0.45% and reduces drawdown by 6 percentage points. The filter likely involves a trend or oversold condition.
- **Crypto adaptation**: Look for the narrowest daily range in 7 days on crypto daily candles. The concept transfers directly. Consider also NR4 (4-day) for crypto's faster volatility cycles.
- **Position sizing**: With a 19% max drawdown and 2.3 profit factor (improved version), Kelly criterion suggests moderate position sizes. Do not go full allocation.
- **Complementary signals**: NR7 signals can be combined with other indicators (RSI, Williams %R, Bollinger Bandwidth) for additional confirmation.
