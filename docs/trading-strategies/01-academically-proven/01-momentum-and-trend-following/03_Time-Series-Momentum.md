# Time-Series Momentum

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading-strategies), Moskowitz, Ooi & Pedersen (2012)
> **Asset Class**: Multi-asset (Equities, Bonds, Commodities, Currencies)
> **Crypto/24-7 Applicable**: Adaptable — time-series momentum has been documented in Bitcoin and major altcoins with strong results
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

Time-series momentum (TSMOM) differs fundamentally from cross-sectional momentum. Rather than ranking assets against each other and going long winners relative to losers, time-series momentum evaluates each asset independently based on its own past performance. If an asset's return over the lookback period is positive, go long; if negative, go short. This absolute approach means the strategy can be net long or net short the entire market, providing valuable diversification benefits, particularly during sustained bear markets.

Moskowitz, Ooi, and Pedersen (2012) demonstrated the pervasiveness of TSMOM across 58 liquid futures contracts spanning equities, bonds, currencies, and commodities over more than 25 years of data. The effect is remarkably consistent: past 12-month returns positively predict future returns for 1 to 12 months across virtually all asset classes tested. The strategy's returns are partially explained by its option-like payoff profile — it tends to perform well during extreme market moves in either direction (the "long straddle" property) and underperforms during trend reversals.

## Trading Rules

1. **Universe**: Liquid futures contracts across multiple asset classes. The original study used 58 instruments including equity index futures (S&P 500, FTSE, Nikkei, etc.), government bond futures (US, UK, Germany, Japan), commodity futures (oil, gold, copper, wheat, etc.), and currency forwards (major pairs).

2. **Signal Calculation**: For each instrument, compute the cumulative excess return over the past h months (typically h = 12 months):
   - If the 12-month excess return is positive, the signal is +1 (go long).
   - If the 12-month excess return is negative, the signal is -1 (go short).

3. **Position Sizing**: Scale each position to target a constant annualized volatility (typically 40% per instrument in the original paper, which is then diversified across the portfolio):
   - Position size = (Target Volatility) / (Estimated Volatility of Instrument)
   - Volatility is estimated using an exponentially weighted moving average of daily returns with a 60-day half-life.

4. **Portfolio Construction**: Equal risk-weight across all instruments. Each position is sized to contribute equal risk to the portfolio, then the overall portfolio is scaled to a target annualized volatility (typically 10-15%).

5. **Rebalancing**: Monthly at month-end. Some implementations use daily signal updates with monthly position adjustments.

6. **Exit Rules**: Positions are reversed when the signal flips (12-month return changes sign). No stop-loss in the canonical implementation, though volatility scaling provides implicit risk management.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.576 |
| CAGR | 11.2% (at 10% target vol) |
| Max Drawdown | -25% |
| Win Rate | 57% (monthly) |
| Volatility | 20.5% |
| Profit Factor | 1.4 |
| Rebalancing | Monthly |

These metrics reflect the diversified multi-asset TSMOM portfolio from the original Moskowitz, Ooi, and Pedersen study. Performance varies by asset class — commodities and currencies tend to show the strongest time-series momentum, while equity indices show somewhat weaker but still significant effects.

## Efficacy Rating

**Rating: 4/5** — Time-series momentum is one of the most robust systematic strategies available, with strong academic evidence across multiple asset classes and long time horizons. Its key advantage over cross-sectional momentum is the ability to go net short, providing crisis alpha during sustained downturns. The deduction from a perfect score reflects: (a) performance degradation during whipsaw markets and trend reversals, (b) the challenge of maintaining short positions in rising markets for extended periods (behavioral difficulty for discretionary overlays), and (c) some evidence of capacity constraints and crowding in the most liquid futures markets.

## Academic References

- Moskowitz, T. J., Ooi, Y. H., & Pedersen, L. H. (2012). "Time Series Momentum." *Journal of Financial Economics*, 104(2), 228-250.
- Baltas, N., & Kosowski, R. (2013). "Momentum Strategies in Futures Markets and Trend-Following Funds." Working Paper, Imperial College London.
- Hurst, B., Ooi, Y. H., & Pedersen, L. H. (2017). "A Century of Evidence on Trend-Following Investing." *Journal of Portfolio Management*, 44(1), 15-29.
- Levine, A., & Pedersen, L. H. (2016). "Which Trend Is Your Friend?" *Financial Analysts Journal*, 72(3), 51-66.
- Lemperi`ere, Y., Deremble, C., Seager, P., Potters, M., & Bouchaud, J. P. (2014). "Two Centuries of Trend Following." *Journal of Investment Strategies*, 3(3), 41-61.
- Kim, A. Y., Tse, Y., & Wald, J. K. (2016). "Time Series Momentum and Volatility Scaling." *Journal of Financial Markets*, 30, 103-124.

## Implementation Notes

- **Data Requirements**: Daily settlement prices for futures contracts with continuous front-month or back-adjusted series. Roll methodology matters — using excess returns (subtracting the risk-free rate and accounting for roll yield) is important for commodities and bonds.
- **Volatility Estimation**: The choice of volatility estimator significantly affects performance. Exponentially weighted moving averages (EWMA) with 20-60 day half-lives are standard. Using realized volatility from intraday data can improve signal quality.
- **Diversification Benefit**: The key insight is that TSMOM applied across many uncorrelated assets produces a far better Sharpe ratio than any single-asset application. A portfolio of 20-60 futures contracts captures significant diversification benefits.
- **Lookback Sensitivity**: While 12 months is canonical, blending multiple lookback periods (1, 3, 6, 12 months) has been shown to produce more robust performance. AQR and other managed futures firms typically use blended signals.
- **Crypto Adaptation**: Time-series momentum has shown strong results in crypto markets. Bitcoin's trending nature makes it particularly amenable to TSMOM strategies, with optimal lookback periods typically shorter (20-60 days) than in traditional markets. The 24/7 trading environment eliminates overnight gaps but introduces continuous monitoring requirements.
- **Relationship to CTAs**: Time-series momentum is the primary driver of returns for managed futures / CTA funds. The SG CTA Index and Barclay CTA Index track the performance of this strategy class. Understanding TSMOM is understanding the core of the managed futures industry.
- **Platform Availability**: Implementable on any platform with futures data. QuantConnect, Backtrader, and Zipline all support futures backtesting. For crypto, CCXT provides unified access to exchange data for implementation.

## Known Risks and Limitations

- **Whipsaw in Trendless Markets**: The primary risk is extended periods without clear trends, during which the strategy repeatedly goes long and short as the 12-month return oscillates around zero. These whipsaw periods can produce significant cumulative losses despite each individual loss being modest.
- **Crowding and Capacity**: The managed futures industry manages approximately $350 billion in AUM, much of it deployed in TSMOM-like strategies. Crowding risk is real — when many trend followers hold similar positions, forced liquidation during drawdowns can amplify losses. The "flash crash" of October 2014 in US Treasuries may have been partially driven by trend-following crowding.
- **Roll Yield Drag**: For commodity and bond futures, the cost of rolling contracts from one expiry to the next can create significant drag on returns. Commodities in contango (upward-sloping futures curve) impose a rolling cost that must be overcome by the trend signal.
- **Correlation Spikes in Crisis**: While TSMOM provides crisis alpha on average, correlation between assets can spike during market dislocations, reducing the diversification benefit precisely when it is most needed. The "diversified" portfolio can behave like a single bet during correlated drawdowns.

## Variants and Extensions

- **Blended Lookback**: Rather than using a single 12-month lookback, blend signals from 1-month, 3-month, 6-month, and 12-month lookbacks. This creates a more robust signal that captures trends at multiple frequencies and reduces sensitivity to any single parameter.
- **Breakout-Based TSMOM**: Replace the sign-of-past-return signal with a channel breakout (e.g., Donchian channel) — go long when price exceeds the N-day high, go short when it breaks the N-day low. This variant is popular among managed futures practitioners.
- **Carry + Trend**: Combining time-series momentum with the carry signal (going long high-carry assets, short low-carry assets) has been shown to improve risk-adjusted returns, as the two signals are largely uncorrelated.
- **Machine Learning Enhancement**: Recent research explores using machine learning to dynamically select the optimal lookback period or to combine multiple trend indicators, though out-of-sample evidence for ML-enhanced TSMOM remains mixed.

## Behavioral and Risk-Based Explanations

- **Behavioral Foundations**: TSMOM profits arise from initial underreaction to news and information, followed by delayed overreaction as herding investors pile into established trends. The strategy profits during the intermediate phase — after the underreaction but before the overreaction peaks and reverses.
- **Option-Like Payoff**: Moskowitz et al. (2012) documented that TSMOM has a "long straddle" payoff profile — it performs well during extreme market moves in either direction (because it aligns with the prevailing trend) and poorly during trend reversals. This convex payoff is valuable for portfolio construction, as it provides implicit tail-risk hedging.
- **Hedging Pressure**: In commodity and currency markets, TSMOM profits may partially compensate for providing liquidity to hedgers. Commercial hedgers (e.g., farmers selling futures to lock in crop prices) create persistent order flow imbalances that trend followers can exploit.
- **Adaptive Markets Hypothesis**: Andrew Lo's Adaptive Markets Hypothesis provides a framework for understanding why TSMOM persists — the strategy exploits the slow adaptation of market participants to changing environments. When new trends begin (due to policy changes, technology shifts, or regime transitions), most participants are slow to adapt, creating profitable opportunities for systematic trend followers.

## Comparison with Cross-Sectional Momentum

| Dimension | Time-Series Momentum | Cross-Sectional Momentum |
|-----------|---------------------|-------------------------|
| Signal | Own past return sign | Relative rank vs. peers |
| Net Exposure | Can be long, short, or flat | Always market-neutral |
| Crisis Behavior | Provides crisis alpha | Subject to crashes |
| Best Asset Classes | Futures (all classes) | Equities |
| Diversification | Across asset classes | Within asset class |
| Capacity | Large (futures markets) | Moderate (equity markets) |
| Key Risk | Whipsaw | Momentum crash |
