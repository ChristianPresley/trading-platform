# Short-Term Reversal in Stocks

> **Source**: [Awesome Systematic Trading](https://github.com/paperswithbacktest/awesome-systematic-trading), [Papers With Backtest — Short-Term Reversal](https://paperswithbacktest.com/wiki/short-term-reversal-in-stocks)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: Adaptable — reversal effects documented in crypto, though liquidity and microstructure differences require shorter windows and careful cost management
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

Short-term reversal is one of the oldest documented anomalies in equity markets. First rigorously studied by Jegadeesh (1990), the strategy exploits the observation that stocks which have experienced extreme returns over the past one to four weeks tend to reverse in the subsequent period. Buying recent losers and selling recent winners over a 1-4 week horizon generates consistent positive returns, with the reversal effect being strongest at the 1-week formation and holding period.

The economic rationale centers on two mechanisms: liquidity provision and overreaction correction. Market makers and liquidity providers demand compensation for absorbing order flow imbalances, causing temporary price dislocations that subsequently revert. Additionally, behavioral biases such as investor overreaction to news and information create short-lived mispricings. The strategy effectively acts as a systematic liquidity provider, earning the reversal premium for absorbing short-term selling pressure and buying panics.

## Trading Rules

1. **Universe**: All stocks on NYSE, AMEX, and NASDAQ with sufficient market capitalization (typically above the 20th NYSE percentile) and adequate daily volume.

2. **Formation Period**: At the end of each week, rank all stocks by their cumulative return over the past 1 week (or up to 4 weeks for longer variants).

3. **Portfolio Construction**:
   - **Long Portfolio**: Buy the bottom decile of stocks ranked by past-week returns (the "losers").
   - **Short Portfolio**: Sell short the top decile of stocks ranked by past-week returns (the "winners").
   - Equal-weight positions within each portfolio.

4. **Holding Period**: Hold the portfolio for 1 week (matching the formation period).

5. **Rebalancing**: Weekly. At each rebalance, close all existing positions and construct a new portfolio based on updated rankings.

6. **Exit Rules**: Positions are held for the full holding period. No stop-loss is applied in the canonical implementation, though practical implementations often include risk limits.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.816 |
| CAGR | ~12-15% (long-short) |
| Max Drawdown | -30% to -40% |
| Win Rate | 55-60% (weekly) |
| Volatility | 21.4% annualized |
| Profit Factor | 1.3-1.5 |
| Rebalancing | Weekly |

The Sharpe ratio of 0.816 reflects the strategy's consistent ability to capture reversal premia across market conditions. Volatility is moderate at 21.4%, driven by the diversified long-short construction across many stocks. Performance is strongest during periods of elevated market volatility and weaker during strong trending markets.

## Efficacy Rating

**Rating: 4/5** — One of the most well-documented anomalies in finance with strong academic backing spanning over three decades. The deduction reflects high turnover costs that significantly erode gross returns, capacity constraints in larger portfolios, and evidence that the premium has partially decayed as more participants have adopted the strategy. The strategy also requires short-selling capability and is sensitive to execution quality.

## Academic References

- Jegadeesh, N. (1990). "Evidence of Predictable Behavior of Security Returns." *The Journal of Finance*, 45(3), 881-898.
- Lehmann, B. N. (1990). "Fads, Martingales, and Market Efficiency." *The Quarterly Journal of Economics*, 105(1), 1-28.
- Lo, A. W., & MacKinlay, A. C. (1990). "When Are Contrarian Profits Due to Stock Market Overreaction?" *The Review of Financial Studies*, 3(2), 175-205.
- Avramov, D., Chordia, T., & Goyal, A. (2006). "Liquidity and Autocorrelations in Individual Stock Returns." *The Journal of Finance*, 61(5), 2365-2394.
- Da, Z., Liu, Q., & Schaumburg, E. (2014). "A Closer Look at the Short-Term Return Reversal." *Management Science*, 60(3), 658-674.

## Implementation Notes

- **Transaction Costs**: The primary challenge. Weekly rebalancing generates very high turnover (~5,000% annually for the full long-short portfolio). Net returns are highly sensitive to execution costs; spreads of even a few basis points can eliminate profitability for illiquid stocks.
- **Capacity**: Limited. The strategy is most profitable in smaller, less liquid stocks where institutional participation is lower, but these same stocks have the highest transaction costs.
- **Microstructure Effects**: Be cautious of bid-ask bounce effects that can inflate backtested returns. Using mid-prices or transaction-level data for formation period returns helps mitigate this bias.
- **Crypto Adaptation**: Reversal effects exist in crypto markets but with different dynamics. 24/7 trading means there is no overnight gap effect, and extreme volatility can amplify both reversals and continuation. Shorter formation periods (intraday to 2-3 days) may be more appropriate.
- **Complementary Strategies**: Short-term reversal is negatively correlated with momentum, making it a useful diversifier in multi-strategy portfolios.
