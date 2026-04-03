# 200-Day Moving Average Regime Filter

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/200-day-moving-average-trading-strategy/)
> **Asset Class**: US Equities (S&P 500)
> **Crypto/24-7 Applicable**: Adaptable — the 200 DMA is widely tracked in crypto markets and serves as a reliable regime indicator
> **Evidence Tier**: Backtested Only
> **Complexity**: Simple

## Overview

The 200-day moving average strategy uses price position relative to the 200 DMA as a binary regime filter: be invested when price is above the 200 DMA, move to cash (or reduce exposure) when below. Unlike the Golden Cross which uses two moving averages, this strategy directly compares price to a single MA, producing faster signals. It reduces max drawdown by roughly half compared to buy-and-hold while capturing most of the upside.

## Trading Rules

### Base Strategy
1. **Calculate**: 200-day simple moving average.
2. **Entry Signal**: Buy at the close when the closing price crosses above the 200-day SMA.
3. **Exit Signal**: Sell at the close when the closing price crosses below the 200-day SMA.
4. **Direction**: Long only; cash when out of market.

### Fixed Holding Period Variant
1. **Entry Signal**: Buy when close crosses above the 200-day SMA.
2. **Exit Signal**: Hold for 200 trading days (approximately 1 year), then exit.
3. **Performance**: Average gain of 10.93% per trade (best-performing variant).

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.7 |
| CAGR | 6.7% (base) / 7.84% (optimized) |
| Max Drawdown | 26% (vs 56% buy-and-hold) |
| Win Rate | ~65% |
| Volatility | Lower than buy-and-hold |
| Profit Factor | ~1.8 |
| Rebalancing | Event-driven (signal-based) |

*Note: Average gain per trade is 2.5% (base). The 200-day fixed hold variant returns 10.93% per trade. Backtested on S&P 500 from 1960.*

## Efficacy Rating

**3/5** — The 200 DMA is perhaps the most widely followed technical level in all of finance. As a standalone strategy, it slightly underperforms buy-and-hold on CAGR but cuts max drawdown by more than half (26% vs 56%). Its primary value is as a regime filter that enhances other strategies. The fixed holding period variant shows the strongest results.

## Academic References

- Faber, M. — "A Quantitative Approach to Tactical Asset Allocation" (2007) — foundational 200 DMA regime work
- Kilgallen, T. — "Testing the Simple Moving Average across Commodities, Global Stock Indices, and Currencies" (2012)
- Zakamulin, V. — "Market Timing with Moving Averages: Anatomy and Performance of Trading Rules" (2017)

## Implementation Notes

- **Regime filter, not strategy**: The 200 DMA's greatest value is as a filter for other strategies. Most mean reversion strategies in this collection (Triple RSI, Williams %R, Bollinger Bands) use it as a prerequisite condition.
- **Signal frequency**: More frequent signals than the Golden Cross, since price crosses the 200 DMA more often than the 50 DMA crosses the 200 DMA.
- **Drawdown reduction**: The 26% max drawdown (vs 56% for buy-and-hold) is the key selling point. Investors who cannot tolerate a 50%+ drawdown should strongly consider this filter.
- **Whipsaw mitigation**: Add a buffer zone (e.g., require price to be 1-2% above/below the 200 DMA before triggering) to reduce false signals.
- **Crypto adaptation**: The 200 DMA is widely watched in Bitcoin and major crypto assets. It has historically served as a reliable bull/bear regime boundary. No parameter changes needed for crypto.
- **EMA variant**: Substituting a 200-day EMA for the SMA produces faster signals with similar overall performance.
