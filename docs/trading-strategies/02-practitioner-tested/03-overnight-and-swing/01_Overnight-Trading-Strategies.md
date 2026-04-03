# Overnight Trading Strategies (Buy at Close, Sell at Open)

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/overnight-trading-strategy/)
> **Asset Class**: US Equities (S&P 500 / SPY), Gold Miners (GDX)
> **Crypto/24-7 Applicable**: Yes — crypto trades continuously, so the "overnight" period can be defined as the US equity close-to-open window (4:00 PM - 9:30 AM ET), capturing the same informational asymmetry
> **Evidence Tier**: Backtested Only
> **Complexity**: Simple

## Overview

The overnight trading strategy exploits a well-documented market anomaly: virtually all of the S&P 500's cumulative returns since 1993 have come from overnight holds (close-to-open), while intraday returns (open-to-close) have contributed zero. The base strategy simply buys at the close and sells at the next open. Conditional variants (e.g., buy after 3 consecutive down days) concentrate exposure on higher-probability setups. The effect is even more pronounced in Gold Miners (GDX), where overnight returns dwarf intraday returns.

## Trading Rules

### Base Strategy
1. **Entry**: Buy at the close (4:00 PM ET).
2. **Exit**: Sell at the next open (9:30 AM ET).
3. **Direction**: Long only.
4. **Frequency**: Daily.

### 3-Days-Down Variant
1. **Entry Condition**: The S&P 500 must have closed lower for 3 consecutive days.
2. **Entry**: Buy at the close on the third consecutive down day.
3. **Exit**: Sell at the next open (9:30 AM ET).
4. **Performance**: 688 trades, 0.31% average gain per trade, 5% CAGR with only 8% time-in-market.

### Gold Miners (GDX) Variant
1. **Entry**: Buy GDX at the close.
2. **Exit**: Sell GDX at the next open.
3. **Performance**: 30% CAGR overnight (2007-present) vs -25% CAGR for intraday (open-to-close) holds.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.8 (3-days-down variant) |
| CAGR | 5% (3-days-down, SPY) / 30% (GDX overnight) |
| Max Drawdown | ~15% (3-days-down) |
| Win Rate | ~58% (base) / ~65% (3-days-down) |
| Volatility | Low (invested 8-15% of the time) |
| Profit Factor | ~1.6 (3-days-down) |
| Rebalancing | Daily |

*Note: Combined portfolio of three overnight strategies: 950 trades, 0.33% average gain per trade. Intraday (open-to-close) S&P 500 has returned zero cumulative since 1993.*

## Efficacy Rating

**3/5** — Built on one of the most robust anomalies in equity markets. The overnight return premium is well-documented across multiple studies and time periods. The 3-days-down variant adds meaningful signal quality (0.31% per trade, 5% CAGR with 8% time-in-market). The GDX variant is remarkably strong. Main concerns: transaction costs from daily round-trips and the possibility that the anomaly is being arbitraged away as it becomes more widely known.

## Academic References

- Cliff, M., Cooper, M. & Gulen, H. — "Return Differences between Trading and Non-Trading Hours" (2008)
- Berkman, H. et al. — "Paying Attention: Overnight Returns and the Hidden Cost of Buying at the Open" (2012)
- Lou, D., Polk, C. & Skouras, S. — "A Tug of War: Overnight Versus Intraday Expected Returns" (2019)

## Implementation Notes

- **Transaction costs are critical**: Daily round-trips (buy close, sell open) generate significant commissions and slippage. The 0.31% average gain per trade (3-days-down) must exceed all costs.
- **Overnight risk**: Positions are exposed to overnight news, earnings surprises, and geopolitical events. The strategy accepts this risk in exchange for the overnight premium.
- **GDX opportunity**: The 30% CAGR vs -25% CAGR split between overnight and intraday on GDX is dramatic and suggests strong asymmetric information dynamics in gold miners.
- **Crypto adaptation**: Define "overnight" as the US equity close-to-open window (4:00 PM - 9:30 AM ET). Crypto continues trading during this period, allowing direct exploitation of the overnight premium without the execution challenges of equity market open/close.
- **Portfolio approach**: Combining multiple overnight variants (SPY, QQQ, GDX) into a portfolio reduces per-strategy risk and increases total trade count, improving statistical reliability.
- **Margin efficiency**: Overnight holds require margin for the full position. Ensure sufficient capital to hold positions through the overnight session without margin calls.
