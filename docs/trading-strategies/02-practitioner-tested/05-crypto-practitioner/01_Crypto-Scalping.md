# Crypto Scalping Strategy

> **Source**: [Quantified Strategies — Cryptocurrency Trading Strategies](https://www.quantifiedstrategies.com/cryptocurrency-trading-strategies/), [Quantified Strategies — Scalping Trading Strategies](https://www.quantifiedstrategies.com/scalping-trading-strategies/)
> **Asset Class**: Cryptocurrency
> **Crypto/24-7 Applicable**: Yes — designed specifically for 24/7 crypto markets
> **Evidence Tier**: Backtested Only
> **Complexity**: Complex

## Overview

Crypto scalping involves making numerous small-profit trades within very short timeframes (seconds to minutes), exploiting micro-movements in price. The strategy capitalizes on the high volatility and 24/7 nature of cryptocurrency markets to extract frequent small gains that compound over time.

Quantified Strategies takes a skeptical view of scalping, noting that backtested scalping strategies are "unlikely to reflect reality" because slippage, latency, and execution costs are extremely difficult to model accurately at very short timeframes. The site warns that almost all scalpers end up losing money, as they compete against better-equipped institutional participants with superior infrastructure. Any apparent edge in backtesting tends to evaporate when transaction costs, slippage, and market impact are realistically accounted for. They recommend finding edges on longer timeframes instead.

## Trading Rules

1. **Universe**: High-liquidity crypto pairs (BTC/USDT, ETH/USDT) on exchanges with low maker/taker fees and tight spreads.

2. **Timeframe**: 1-minute to 5-minute candles, or tick-level data.

3. **Entry Signals** (typical approaches):
   - Order book imbalance: Enter when bid volume significantly exceeds ask volume (or vice versa) at the top of book.
   - Micro-breakout: Enter on a break of a 5-minute high/low with volume confirmation.
   - Spread capture: Place limit orders on both sides of the spread in quiet markets.

4. **Exit**: Close position after a small fixed-pip target (e.g., 0.05-0.15%) or after 1-5 minutes, whichever comes first.

5. **Stop Loss**: Tight stops at 0.05-0.10% from entry. Risk-reward ratio is typically close to 1:1.

6. **Session Management**: Active during high-volume periods (typically overlapping with US and Asian equity market hours).

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.2-0.5 (after realistic costs) |
| CAGR | Highly variable; often negative net of costs |
| Max Drawdown | -10% to -30% (rapid, concentrated) |
| Win Rate | 50-55% (net of slippage) |
| Volatility | ~30-60% annualized |
| Profit Factor | ~0.9-1.2 (after costs) |
| Rebalancing | Continuous (hundreds of trades per day) |

Backtested gross returns can appear attractive (high win rates, smooth equity curves), but these results are misleading. Realistic transaction cost modeling — including exchange fees (0.02-0.10% per trade), slippage (0.01-0.05% per trade), and market impact — typically erodes 60-90% of gross profits. Net Sharpe ratios for manual scalpers are generally below 0.5.

## Efficacy Rating

**Rating: 2/5** — Crypto scalping faces fundamental structural challenges that make it unreliable for most participants. The strategy requires extremely low-latency infrastructure, co-located servers, and institutional-grade execution to be viable — exactly the competitive advantages that market makers and HFT firms already possess. Quantified Strategies explicitly warns that scalping is "a waste of time" for most traders. The rating reflects the theoretical possibility of profitability with sufficient infrastructure, offset by the practical reality that retail and semi-professional traders almost universally lose money scalping.

## Academic References

- Aldridge, I. (2013). *High-Frequency Trading: A Practical Guide to Algorithmic Strategies and Trading Systems*. Wiley.
- Cartea, A., Jaimungal, S., & Penalva, J. (2015). *Algorithmic and High-Frequency Trading*. Cambridge University Press.
- Makarov, I., & Schoar, A. (2020). "Trading and Arbitrage in Cryptocurrency Markets." *Journal of Financial Economics*, 135(2), 293-319.
- Hasbrouck, J., & Saar, G. (2013). "Low-Latency Trading." *Journal of Financial Markets*, 16(4), 646-679.

## Implementation Notes

- **Infrastructure Requirements**: Profitable crypto scalping requires sub-millisecond execution latency, co-located servers near exchange matching engines, and direct market access. WebSocket connections with order book streaming are mandatory; REST API polling is far too slow.
- **Fee Optimization**: Exchange fee structure is critical. Target exchanges with maker rebates (e.g., -0.01% maker fee) and use limit orders exclusively. At 100+ trades per day, even 0.01% per-trade fee difference compounds dramatically.
- **Slippage Reality**: The single largest challenge. Backtests assume fills at quoted prices, but real execution in volatile crypto markets involves regular slippage of 1-5 basis points per trade. Model slippage conservatively at 2-3x your initial estimate.
- **Zig Implementation**: If building in Zig for this platform, the performance characteristics of Zig (no GC, deterministic latency) are well-suited to the infrastructure requirements, but the strategy itself remains questionable regardless of execution speed.
- **Risk Management**: Capital preservation is paramount. Use hard daily loss limits (e.g., 2% of capital) and automatic shutdown on consecutive losses. Scalping drawdowns can accelerate extremely quickly.
- **Recommendation**: Quantified Strategies advises trading on longer timeframes where edges are more robust and transaction costs less impactful. Consider swing or trend-following crypto strategies instead.
