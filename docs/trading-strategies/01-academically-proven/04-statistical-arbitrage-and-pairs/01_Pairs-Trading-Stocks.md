# Pairs Trading — Stocks

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading-strategies), [Gatev, Goetzmann, Rouwenhorst (2006)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=141615)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: Adaptable — cointegrated crypto pairs exist (e.g., BTC/ETH, stablecoin pairs), though relationships are less stable and require shorter formation windows
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

Pairs trading is a market-neutral strategy that identifies two stocks whose prices have historically moved together, then trades the spread when it diverges from its equilibrium. The foundational academic work by Gatev, Goetzmann, and Rouwenhorst (2006) demonstrated that a simple distance-based pairs trading rule generated average annualized excess returns of up to 11% on self-financing portfolios over the 1962-2002 period, with profits exceeding conservative transaction cost estimates.

The strategy exploits temporary mispricings between close economic substitutes. Unlike directional strategies, pairs trading profits from the convergence of the spread rather than the direction of either individual stock. The economic rationale rests on the law of one price: securities with similar fundamental characteristics should trade at similar valuations, and deviations represent exploitable inefficiencies.

Two primary methodological approaches dominate the literature. The **distance method** (Gatev et al.) selects pairs by minimizing the sum of squared deviations between normalized price series during a formation period. The **cointegration method** (Engle-Granger or Johansen) tests whether a linear combination of two price series is stationary, providing a more rigorous statistical foundation for mean-reversion. The cointegration approach is generally preferred in modern implementations because it explicitly models the long-run equilibrium relationship and provides a framework for dynamic hedge ratios.

## Trading Rules

1. **Universe**: All common stocks on major exchanges with sufficient liquidity (average daily volume above $1M) and market cap above the 20th percentile. Exclude ADRs, REITs, and closed-end funds unless sector-specific implementation is desired.

2. **Pair Formation** (12-month formation period):
   - Normalize all price series to start at $1 at the beginning of the formation period.
   - For each possible pair, compute the sum of squared deviations (distance method) or test for cointegration using the Engle-Granger two-step procedure.
   - Select the top 20-50 pairs ranked by minimum distance or strongest cointegration (lowest ADF test p-value on residuals).

3. **Spread Construction**:
   - Compute the spread as: `Spread = Price_A - (hedge_ratio * Price_B)`
   - Hedge ratio estimated via OLS regression during the formation period, or dynamically via Kalman filter.
   - Standardize the spread by subtracting its mean and dividing by its standard deviation to obtain a z-score.

4. **Entry Signal**: Open a position when the z-score crosses +/- 2.0 standard deviations from the mean:
   - If z-score > +2.0: Short stock A, Long stock B (spread expected to narrow).
   - If z-score < -2.0: Long stock A, Short stock B (spread expected to widen back).

5. **Exit Signal**: Close the position when the spread reverts to within +/- 0.5 standard deviations of the mean, or after a maximum holding period of 6 months.

6. **Stop-Loss**: Close the position if the spread diverges further to +/- 4.0 standard deviations, indicating potential structural break in the relationship.

7. **Position Sizing**: Equal dollar amounts on each leg. Total portfolio allocated across 15-25 active pairs to diversify idiosyncratic pair risk.

8. **Rebalancing**: Reform pairs at the end of each 12-month formation period. Monitor cointegration stability monthly using rolling ADF tests.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.634 |
| CAGR | 8-11% (excess returns, self-financing) |
| Max Drawdown | -15% to -25% |
| Win Rate | 55-65% (per pair trade) |
| Volatility | 8.5% annualized |
| Profit Factor | 1.3-1.6 |
| Rebalancing | Daily (monitoring), Annual (pair reformation) |

The Sharpe ratio of 0.634 reflects the strategy's moderate but consistent risk-adjusted returns. Volatility is notably low at 8.5% because the market-neutral construction eliminates systematic risk. Performance has shown some decay since the early 2000s as the strategy has become more widely adopted by quantitative funds, though it remains profitable after transaction costs in less liquid market segments.

## Efficacy Rating

**Rating: 4/5** — One of the most thoroughly researched relative-value strategies with a 40+ year track record in academic literature. The deduction reflects documented performance decay since 2002 (Zhu, 2024), sensitivity to transaction costs on the short side, and vulnerability to regime changes that permanently break cointegration relationships. The strategy remains viable but requires careful pair selection and robust risk management to maintain profitability in modern markets.

## Academic References

- Gatev, E., Goetzmann, W. N., & Rouwenhorst, K. G. (2006). "Pairs Trading: Performance of a Relative-Value Arbitrage Rule." *The Review of Financial Studies*, 19(3), 797-827.
- Vidyamurthy, G. (2004). *Pairs Trading: Quantitative Methods and Analysis*. John Wiley & Sons.
- Krauss, C. (2017). "Statistical Arbitrage Pairs Trading Strategies: Review and Outlook." *Journal of Economic Surveys*, 31(2), 513-545.
- Do, B., & Faff, R. (2010). "Does Simple Pairs Trading Still Work?" *Financial Analysts Journal*, 66(4), 83-95.
- Zhu, X. (2024). "Examining Pairs Trading Profitability." Yale University Working Paper.
- Engle, R. F., & Granger, C. W. J. (1987). "Co-integration and Error Correction: Representation, Estimation, and Testing." *Econometrica*, 55(2), 251-276.

## Implementation Notes

- **Data Requirements**: Daily closing prices with corporate action adjustments (splits, dividends). Intraday data preferred for execution timing. Minimum 12 months of history for formation period.
- **Transaction Costs**: The strategy generates moderate turnover (~100-150% annually). Gatev et al. found profits survive conservative cost estimates of 50 bps per leg, but tighter spreads in modern markets make this less constraining. Short borrowing costs remain a significant drag on the short leg.
- **Pair Stability**: Approximately 30-40% of cointegrated pairs lose stationarity within 6 months. Rolling cointegration tests and half-life of mean reversion are essential monitoring tools.
- **Sector Constraints**: Pairs within the same sector (e.g., Coca-Cola/PepsiCo, Exxon/Chevron) tend to have more stable cointegration than cross-sector pairs, though same-sector concentration increases exposure to sector-specific shocks.
- **Crypto Adaptation**: BTC/ETH and other large-cap crypto pairs show cointegration over certain regimes, but with shorter half-lives of mean reversion (days vs. weeks for equities). Higher transaction costs on-chain and wider spreads on smaller exchanges reduce net profitability. CEX-to-CEX pairs trading across venues offers a more natural crypto analog.
