# 04 — Candlestick Patterns

Strategies based on Japanese candlestick patterns, systematically backtested rather than relying on traditional chart-reading lore. These strategies attempt to extract quantifiable edges from single-candle and multi-candle formations.

## Key Themes

- **Mean-Reversion Dominance**: The most effective candlestick strategies derive their edge from mean-reversion dynamics rather than the patterns themselves. Bearish patterns paradoxically work best as bullish entry signals.
- **Low Signal Frequency**: Individual candlestick patterns generate very few trades per year on any single instrument, limiting standalone CAGR contributions.
- **Filter Dependency**: Nearly all patterns perform significantly better when combined with additional filters (oversold conditions, moving average context) than when traded in isolation.

## Strategies

| # | Strategy | Rating | Crypto | Source |
|---|----------|--------|--------|--------|
| 01 | [Doji Strategy](01_Doji-Strategy.md) | 2/5 | Adaptable | Quantified Strategies |
| 02 | [Heikin-Ashi](02_Heikin-Ashi.md) | 2/5 | Adaptable | Quantified Strategies |
| 03 | [Key Reversal Day](03_Key-Reversal-Day.md) | 2/5 | Adaptable | Quantified Strategies |
| 04 | [Top Candlestick Patterns](04_Top-Candlestick-Patterns.md) | 3/5 | Adaptable | Quantified Strategies |

## Overall Assessment

Candlestick patterns are among the most widely taught but least empirically validated areas of technical analysis. The Quantified Strategies backtests reveal that most of the 75 recognized patterns have negligible predictive power. A small subset produces genuine but modest edges, primarily through mean-reversion mechanics. The combined top-5 pattern approach (documented in strategy 04) is the most practical implementation, generating enough signals for a meaningful equity curve while maintaining statistical significance.

For implementation purposes, candlestick signals are best used as supplementary confirmation within a broader trading system rather than as standalone entry triggers.
