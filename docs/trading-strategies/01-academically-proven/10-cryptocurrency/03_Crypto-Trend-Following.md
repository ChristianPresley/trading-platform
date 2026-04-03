# Crypto Trend Following

> **Source**: [Quantified Strategies](https://www.quantifiedstrategies.com/trend-following-and-momentum-on-bitcoin/)
> **Asset Class**: Cryptocurrency
> **Crypto/24-7 Applicable**: Yes --- designed for BTC/ETH and other major crypto assets
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

Applies classic moving average-based trend following to Bitcoin and Ethereum. The strategy enters long positions when price crosses above a moving average and exits when it crosses below, capturing the large directional moves that characterize crypto markets. Crypto assets exhibit strong trending behavior due to narrative-driven momentum, reflexivity, and retail participation, making them well-suited for trend following despite high volatility. The approach trades infrequently with a low win rate but achieves outsized gains on winning trades.

## Trading Rules

1. **Indicator Setup**: Compute a short-term moving average (e.g., 5-day or 10-day SMA) and a long-term moving average (e.g., 50-day or 200-day SMA) on daily close prices.
2. **Entry Signal**: Enter a long position when the short-term MA crosses above the long-term MA (golden cross) or when price closes above the long-term MA.
3. **Exit Signal**: Exit the long position when the short-term MA crosses below the long-term MA (death cross) or when price closes below the long-term MA.
4. **Position Sizing**: Fixed fractional position sizing (e.g., risk 1-2% of portfolio per trade based on distance to stop-loss).
5. **Stop-Loss**: Trail a stop-loss at 2x ATR(14) below the highest close since entry. Alternatively, use the long-term MA as a trailing stop.
6. **No Short Positions**: The basic version is long-only, moving to cash (or stablecoins) when the trend filter is negative. Short selling is optional and adds complexity.
7. **Universe**: BTC/USD and ETH/USD as primary instruments. Can extend to top-10 crypto by market cap.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.9 - 1.3 |
| CAGR | 87% - 145% (period-dependent, includes BTC secular bull) |
| Max Drawdown | -39% to -66% |
| Win Rate | 39% - 42% |
| Volatility | 50% - 70% annualized |
| Profit Factor | 2.0 - 3.5 |
| Rebalancing | Daily |

## Efficacy Rating

**4/5** --- Strong empirical evidence that trend following works in crypto markets. The strategy significantly reduces maximum drawdown compared to buy-and-hold (which suffered -80%+ drawdowns in 2018 and 2022) while capturing the majority of bull market returns. The low win rate is offset by an excellent win/loss ratio (average winner ~21% vs. average loser ~4%). Simplicity is a major advantage: the strategy is robust across parameter choices and resistant to overfitting. The main risk is whipsaw losses during extended sideways markets. Transaction costs are minimal due to infrequent trading.

## Academic References

- Moskowitz, T., Ooi, Y. H., & Pedersen, L. H. (2012). "Time Series Momentum." *Journal of Financial Economics*, 104(2), 228-250.
- Baur, D. G. & Dimpfl, T. (2021). "The Volatility of Bitcoin and Its Role as a Medium of Exchange and a Store of Value." *Empirical Economics*, 61, 2663-2683.
- Quantified Strategies. "Trend Following and Momentum Strategies on Bitcoin." [Link](https://www.quantifiedstrategies.com/trend-following-and-momentum-on-bitcoin/)
- Bianchi, D. (2020). "Cryptocurrencies as an Asset Class? An Empirical Assessment." *Journal of Alternative Investments*, 23(2), 162-179.

## Implementation Notes

- **Simplicity**: This is one of the easiest strategies to implement. Requires only daily OHLCV data and a moving average calculation.
- **Data Source**: Kraken REST API OHLC endpoint provides daily candles. A single API call per day per instrument is sufficient.
- **Execution**: Trades occur at most a few times per month. Market orders at daily close are acceptable; no need for sophisticated execution algorithms.
- **Parameter Robustness**: The strategy works across a wide range of MA lengths (5-day to 20-day short, 50-day to 200-day long). Avoid over-optimizing exact periods.
- **Drawdown Management**: Even with trend following, crypto drawdowns of 40-66% are possible. Position sizing relative to total portfolio (not just crypto allocation) is essential.
- **Pure Zig Implementation**: Trivially implementable. Moving average computation, comparison logic, and order generation are basic arithmetic operations well-suited to Zig.
