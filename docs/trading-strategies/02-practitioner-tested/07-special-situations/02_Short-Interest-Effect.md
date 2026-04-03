# Short Interest Effect Strategy

> **Source**: [Awesome Systematic Trading](https://github.com/paperswithbacktest/awesome-systematic-trading), [Quantpedia — Short Interest Effect (Long-Short Version)](https://quantpedia.com/strategies/short-interest-effect-long-short-version)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: No — requires short interest data from equity markets, which has no direct crypto equivalent (crypto funding rates are conceptually related but structurally different)
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

The short interest effect exploits the observation that stocks with high levels of short interest tend to underperform subsequently. High short interest reflects bearish conviction from informed traders (hedge funds, institutional short sellers) who have taken the costly and risky step of borrowing and selling shares they expect to decline. The strategy constructs a long-short portfolio: long stocks with the lowest short interest (indicating bullish consensus) and short stocks with the highest short interest (indicating bearish consensus).

The academic rationale is that short sellers are generally more informed and sophisticated than average market participants, and their aggregate positioning contains predictive information about future returns. However, the Awesome Systematic Trading backtest reveals a Sharpe ratio of only 0.079, indicating that while the signal exists in-sample, its out-of-sample implementation produces negligible risk-adjusted returns. The alpha has likely been arbitraged away as the signal became widely known and short interest data became freely available.

## Trading Rules

1. **Universe**: All common stocks on NYSE, AMEX, and NASDAQ with sufficient liquidity (minimum daily volume >$1M).

2. **Short Interest Data**: Obtain bi-monthly short interest reports (published by exchanges, typically on the 15th and last day of each month).

3. **Ranking**: Calculate the short interest ratio (short interest / shares outstanding) for all stocks. Sort into deciles.

4. **Portfolio Construction**:
   - **Long**: Equal-weight all stocks in the lowest short interest decile.
   - **Short**: Equal-weight all stocks in the highest short interest decile.

5. **Rebalancing**: Monthly, following the release of short interest data.

6. **Holding Period**: Hold positions for one full month until the next rebalancing.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.079 |
| CAGR | ~1-2% (long-short spread) |
| Max Drawdown | -20% to -35% |
| Win Rate | ~50-52% (monthly) |
| Volatility | 6.6% annualized |
| Profit Factor | ~1.0-1.1 |
| Rebalancing | Monthly |

The Sharpe ratio of 0.079 is barely distinguishable from zero, indicating the strategy does not reliably generate risk-adjusted returns in the out-of-sample backtest. The low volatility (6.6%) reflects the diversified long-short construction across many stocks. The near-zero alpha suggests that the well-documented short interest signal has been largely arbitraged away, with the remaining spread insufficient to cover transaction costs and short borrow fees in practice.

## Efficacy Rating

**Rating: 2/5** — The short interest effect has strong academic documentation (Desai et al. 2002, Asquith et al. 2005), and the economic logic is sound — short sellers tend to be informed. However, the near-zero Sharpe ratio in backtesting indicates the strategy is not practically profitable. The deduction reflects: (a) the signal has been widely known for 20+ years and appears to have been arbitraged away, (b) short borrow costs for high-short-interest stocks can be substantial (sometimes 5-20% annualized), further eroding returns, (c) short squeezes in high-short-interest stocks create significant tail risk, (d) the Sharpe of 0.079 is below any reasonable threshold for deployment, and (e) the strategy has no crypto applicability.

## Academic References

- Desai, H., Ramesh, K., Thiagarajan, S. R., & Balachandran, B. V. (2002). "An Investigation of the Informational Role of Short Interest in the Nasdaq Market." *The Journal of Finance*, 57(5), 2263-2287.
- Asquith, P., Pathak, P. A., & Ritter, J. R. (2005). "Short Interest, Institutional Ownership, and Stock Returns." *Journal of Financial Economics*, 78(2), 243-276.
- Boehmer, E., Jones, C. M., & Zhang, X. (2008). "Which Shorts Are Informed?" *The Journal of Finance*, 63(2), 491-527.
- Dechow, P. M., Hutton, A. P., Meulbroek, L., & Sloan, R. G. (2001). "Short-Sellers, Fundamental Analysis, and Stock Returns." *Journal of Financial Economics*, 61(1), 77-106.
- Rapach, D. E., Ringgenberg, M. C., & Zhou, G. (2016). "Short Interest and Aggregate Stock Returns." *Journal of Financial Economics*, 121(1), 46-65.

## Implementation Notes

- **Data Timeliness**: Short interest data is published with a ~10 business day lag. By the time the data is available, the market may have already adjusted. This lag is a structural disadvantage that cannot be overcome.
- **Short Borrow Costs**: The stocks you need to short (high short interest) are precisely the stocks with the highest borrow costs. Factor in realistic borrow costs of 3-20% annualized for hard-to-borrow stocks, which can easily exceed the strategy's gross return.
- **Short Squeeze Risk**: High short interest stocks are vulnerable to short squeezes (as demonstrated by GME in January 2021). A single short squeeze event can produce losses exceeding an entire year's expected return. Position sizing must account for this tail risk.
- **Signal Decay**: The short interest signal appears to have weakened significantly over time as it became widely known and data became more accessible. Consider this strategy as a case study in alpha decay rather than a deployable strategy.
- **Alternative Use**: While not profitable as a standalone strategy, short interest data retains value as a supplementary signal within a multi-factor model. Stocks with high short interest and deteriorating fundamentals are stronger short candidates than either signal alone.
- **No Crypto Equivalent**: While crypto perpetual futures have funding rates that reflect bearish/bullish sentiment, the mechanics are sufficiently different (funding rates affect all holders, not just directional bets) that the short interest framework does not transfer.
