# 05 — Crypto Practitioner Strategies

Trading strategies designed specifically for or adapted to cryptocurrency markets, leveraging the unique characteristics of 24/7 trading, high volatility, on-chain transparency, and blockchain-specific events.

## Key Themes

- **Trend Following Over Mean Reversion**: Quantified Strategies' research consistently finds that trend following outperforms mean reversion in crypto due to the asset class's tendency to make large directional moves.
- **Infrastructure Demands**: Several strategies (scalping, whale watching) require sophisticated technical infrastructure to execute, where Zig's performance characteristics offer genuine advantages.
- **Regime Sensitivity**: All crypto strategies exhibit extreme performance variation across market regimes (bull, bear, ranging). No single strategy works well in all conditions.
- **Declining Opportunity**: Some strategies (fork trading) have seen their edge erode as markets mature and become more efficient.

## Strategies

| # | Strategy | Rating | Complexity | Key Characteristic |
|---|----------|--------|------------|-------------------|
| 01 | [Crypto Scalping](01_Crypto-Scalping.md) | 2/5 | Complex | High-frequency small-profit trades |
| 02 | [Crypto Grid Trading](02_Crypto-Grid-Trading.md) | 3/5 | Moderate | Automated buy/sell grid in ranges |
| 03 | [Whale Watching](03_Whale-Watching.md) | 2/5 | Complex | On-chain large-wallet flow signals |
| 04 | [Crypto Breakout](04_Crypto-Breakout.md) | 2/5 | Moderate | Volatility contraction breakouts |
| 05 | [Fork Trading](05_Fork-Trading.md) | 2/5 | Moderate | Blockchain fork event trading |
| 06 | [Range Trading](06_Range-Trading.md) | 3/5 | Moderate | Support/resistance oscillation |

## Overall Assessment

Crypto-specific strategies range from conceptually sound (grid trading, range trading) to speculative (whale watching, fork trading). The strongest evidence supports grid trading and range trading (Bollinger Band variant), both of which exploit the well-documented ranging behavior of crypto markets. Scalping is explicitly cautioned against by Quantified Strategies due to unrealistic backtest assumptions and structural disadvantages for non-institutional participants.

For this platform's Zig-based implementation, grid trading and range trading are the most promising candidates — both are fully automatable, have clear rule sets, and benefit from low-latency execution without requiring the extreme infrastructure demands of scalping.
