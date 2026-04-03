# Crypto Range Trading Strategy

> **Source**: [Quantified Strategies — Cryptocurrency Trading Strategies](https://www.quantifiedstrategies.com/cryptocurrency-trading-strategies/), [Quantified Strategies — Bitcoin Bollinger Bands Trading Strategy](https://www.quantifiedstrategies.com/bitcoin-bollinger-bands-trading-strategy-performance-backtest/)
> **Asset Class**: Cryptocurrency
> **Crypto/24-7 Applicable**: Yes — crypto markets frequently establish well-defined ranges between trending periods
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

Range trading identifies established support and resistance levels in crypto markets and trades the oscillation between them. When price approaches support, the strategy enters long; when price approaches resistance, it exits or goes short. The approach is fundamentally a mean-reversion strategy that profits from the tendency of prices to revert toward the center of established ranges.

Cryptocurrency markets spend an estimated 60-70% of their time in ranging conditions between major trend moves, making this a frequently applicable approach. Quantified Strategies' research on Bitcoin Bollinger Bands — a range-trading variant — showed a backtest CAGR of nearly 50% while being in the market only 34% of the time, demonstrating that capturing range-bound oscillations can be highly profitable when the entry and exit conditions are well-defined. However, the strategy suffers catastrophic losses when a range breaks down and price trends aggressively through support or resistance.

## Trading Rules

1. **Universe**: Major crypto pairs (BTC/USDT, ETH/USDT) on daily or 4-hour candles.

2. **Range Identification**:
   - Identify a horizontal range where price has tested both support and resistance at least twice over the past 20-60 days.
   - Alternatively, use Bollinger Bands (20-period, 2 standard deviations) to define dynamic range boundaries.

3. **Long Entry**: Buy when price touches or penetrates the lower support level (or lower Bollinger Band) with confirmation of a reversal candle (e.g., hammer, bullish engulfing) or RSI below 30.

4. **Short Entry / Exit**: Sell or short when price touches or penetrates the upper resistance level (or upper Bollinger Band) with confirmation of a rejection candle or RSI above 70.

5. **Stop-Loss**: Place stop 2-3% below the support level (for longs) or above the resistance level (for shorts). A stop hit signals a potential range breakdown.

6. **Target**: Middle of the range for partial profit; opposite boundary for full exit.

7. **Invalidation**: If price closes convincingly beyond the range boundary (>3% beyond with volume), the range is broken. Close all positions and wait for a new range to establish.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.6-0.9 (in ranging markets) |
| CAGR | ~20-50% (Bollinger Band variant on BTC: ~50%) |
| Max Drawdown | -15% to -35% |
| Win Rate | ~60-70% |
| Volatility | ~20-35% annualized |
| Profit Factor | ~1.5-2.2 |
| Rebalancing | Event-driven (at range boundaries) |

The Bollinger Band variant on Bitcoin demonstrated nearly 50% CAGR with only 34% time in market — one of the strongest backtest results in crypto strategy research. However, this reflects a specific parameter set on a specific instrument during a specific period; out-of-sample performance will likely be lower. The high win rate reflects the mean-reversion nature of the setup, with most range touches producing bounces.

## Efficacy Rating

**Rating: 3/5** — Range trading has a sound theoretical basis in crypto markets, where extended ranging periods are common. The Bollinger Band backtest results from Quantified Strategies are impressive and suggest a genuine edge. The deduction reflects: (a) the strategy's vulnerability to range breakdowns, which can produce outsized losses in a single trade, (b) potential overfitting in the published backtest parameters, (c) the difficulty of distinguishing "temporary range" from "range about to break" in real time, and (d) the need for rapid response when a range breaks — delayed stop execution in volatile crypto markets can turn a controlled loss into a catastrophic one.

## Academic References

- Bollinger, J. (2001). *Bollinger on Bollinger Bands*. McGraw-Hill.
- Makarov, I., & Schoar, A. (2020). "Trading and Arbitrage in Cryptocurrency Markets." *Journal of Financial Economics*, 135(2), 293-319.
- Wyckoff, R. D. (1931). *The Richard D. Wyckoff Method of Trading and Investing in Stocks*. Wyckoff Associates.
- Balvers, R. J., & Wu, Y. (2006). "Momentum and Mean Reversion Across National Equity Markets." *Journal of Empirical Finance*, 13(1), 24-48.

## Implementation Notes

- **Bollinger Band Variant**: The most backtested approach uses 20-period Bollinger Bands with 2 standard deviations on daily candles. Buy when price closes below the lower band; sell when it closes above the upper band. This simplifies range identification to a single indicator.
- **Range Validation**: Before trading, confirm the range is established: require at least 2 touches of both support and resistance over a minimum of 20 days. "Fresh" ranges with only one touch are unreliable.
- **Stop Discipline**: The single most important risk management rule. When a range breaks, losses can accelerate rapidly. Use hard stops, not mental stops. In crypto, consider using exchange-native stop-limit orders rather than relying on bot execution during volatile moves.
- **Time-in-Market Efficiency**: The 34% time-in-market figure from the Bollinger Band backtest is a feature, not a bug. Capital is deployed only during high-probability setups. The remaining time can be allocated to other strategies or held in stablecoins earning yield.
- **Zig Implementation**: Range detection (rolling high/low computation, Bollinger Band calculation) is computationally straightforward. The primary implementation challenge is reliable order execution at range boundaries, which requires robust WebSocket connection management and order state tracking.
- **Multi-Pair Deployment**: Running range trading across 5-10 crypto pairs simultaneously increases signal frequency and diversification. Different pairs enter ranging conditions at different times, providing more regular trading opportunities.
