# Day Trading Strategies

Intraday strategies that open and close positions within a single trading session. These exploit session-specific patterns such as opening range breakouts, intraday momentum persistence, and volatility contraction/expansion cycles.

## Contents

| # | Strategy | Pattern Type | Rating | Crypto Applicable |
|---|----------|-------------|--------|-------------------|
| 01 | [Opening Range Breakout](01_Opening-Range-Breakout.md) | Breakout | 3/5 | Adaptable (use session opens) |
| 02 | [Intraday Momentum](02_Intraday-Momentum.md) | Momentum Persistence | 3/5 | Adaptable |
| 03 | [NR7 Narrow Range](03_NR7-Narrow-Range.md) | Volatility Contraction | 3/5 | Adaptable |
| 04 | [Dynamic Breakout II](04_Dynamic-Breakout-II.md) | Adaptive Breakout | 2/5 | Adaptable |

## Common Themes

- **Session structure matters**: Most strategies depend on the auction process at market open. Crypto adaptation requires defining synthetic "sessions" (e.g., US equity open, Asian open).
- **Volatility contraction precedes expansion**: NR7 and Dynamic Breakout II both exploit the principle that compressed ranges lead to directional moves.
- **Intraday momentum is persistent**: The first 30 minutes of trading contain predictive information for the rest of the session.
- **Transaction costs are critical**: High trade frequency means commissions and slippage have outsized impact on net returns. All backtests should be evaluated net of realistic costs.
