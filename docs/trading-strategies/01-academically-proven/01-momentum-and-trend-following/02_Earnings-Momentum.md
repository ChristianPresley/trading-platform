# Earnings Momentum (Post-Earnings Announcement Drift)

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 3
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: No — cryptocurrencies do not have earnings announcements or standardized financial reporting
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

Earnings momentum, formally known as Post-Earnings Announcement Drift (PEAD), is one of the oldest and most persistent anomalies in financial markets. First documented by Ball and Brown (1968), PEAD refers to the tendency of stock prices to continue drifting in the direction of an earnings surprise for 60-90 days following the announcement. Stocks that report earnings above analyst consensus estimates tend to continue rising, while those that miss expectations tend to continue declining.

The persistence of this anomaly is remarkable given its long history of documentation. PEAD challenges the semi-strong form of the Efficient Market Hypothesis, which predicts that all publicly available information (including earnings announcements) should be immediately incorporated into prices. The drift suggests that investors systematically underreact to earnings news, possibly due to anchoring bias, limited attention, or the gradual diffusion of information through the market. Despite decades of academic scrutiny and widespread awareness among practitioners, the effect has persisted, though its magnitude has declined somewhat over time as algorithmic trading has increased.

## Trading Rules

1. **Universe**: All stocks with analyst coverage and available earnings surprise data. Typically restricted to liquid stocks (S&P 500, S&P 1500, or Russell 1000 constituents) to ensure tradability around announcement dates.

2. **Earnings Surprise Calculation**: Compute the Standardized Unexpected Earnings (SUE) for each stock:
   - SUE = (Actual EPS - Consensus Estimate EPS) / Standard Deviation of Analyst Estimates
   - Alternatively, use the earnings surprise relative to a seasonal random walk model: SUE = (EPS_t - EPS_{t-4}) / Std(EPS_t - EPS_{t-4})

3. **Signal Generation**: After each earnings announcement:
   - **Buy Signal**: SUE in the top decile (large positive surprise)
   - **Sell/Short Signal**: SUE in the bottom decile (large negative surprise)

4. **Entry Timing**: Enter positions at the close of the first trading day following the earnings announcement (to avoid bid-ask bounce effects on the announcement day itself). Some implementations wait until the second day post-announcement.

5. **Portfolio Construction**:
   - **Long Portfolio**: Equal-weight or value-weight all stocks with top-decile SUE scores announced within the past month.
   - **Short Portfolio**: Equal-weight or value-weight all stocks with bottom-decile SUE scores announced within the past month.

6. **Holding Period**: Hold each position for 60 trading days (approximately one quarter) after the earnings announcement. Close prior to the next earnings announcement to avoid event risk.

7. **Rebalancing**: Rolling — add new positions as earnings are announced throughout the quarter. The portfolio is continuously updated as new earnings reports arrive during earnings season.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.40-0.70 |
| CAGR | 6-10% (long-short) |
| Max Drawdown | -20% to -30% |
| Win Rate | 55-62% |
| Volatility | 12-18% |
| Profit Factor | 1.3-1.6 |
| Rebalancing | Event-driven (post earnings) |

Performance metrics vary significantly based on the earnings surprise measure used, the universe of stocks, and the time period studied. The strategy tends to perform better in smaller-cap universes where analyst coverage is thinner and information diffuses more slowly. The long side (positive surprise) has historically been more profitable and more consistent than the short side.

## Efficacy Rating

**Rating: 4/5** — PEAD is one of the longest-standing and most replicated anomalies in academic finance, surviving over 50 years of scrutiny. The rating reflects its strong theoretical grounding (behavioral underreaction), persistent profitability, and the availability of clean, unambiguous signals. The deduction from a perfect score is due to: (a) inapplicability to crypto markets entirely, (b) some evidence of alpha decay in large-cap US equities as algorithmic trading has increased, (c) the requirement for timely and accurate earnings surprise data which can be expensive, and (d) concentration of trading opportunities around earnings seasons creating uneven capital deployment.

## Academic References

- Ball, R., & Brown, P. (1968). "An Empirical Evaluation of Accounting Income Numbers." *Journal of Accounting Research*, 6(2), 159-178.
- Bernard, V. L., & Thomas, J. K. (1989). "Post-Earnings-Announcement Drift: Delayed Price Response or Risk Premium?" *Journal of Accounting Research*, 27, 1-36.
- Bernard, V. L., & Thomas, J. K. (1990). "Evidence That Stock Prices Do Not Fully Reflect the Implications of Current Earnings for Future Earnings." *Journal of Accounting and Economics*, 13(4), 305-340.
- Foster, G., Olsen, C., & Shevlin, T. (1984). "Earnings Releases, Anomalies, and the Behavior of Security Returns." *The Accounting Review*, 59(4), 574-603.
- Livnat, J., & Mendenhall, R. R. (2006). "Comparing the Post-Earnings Announcement Drift for Surprises Calculated from Analyst and Time Series Forecasts." *Journal of Accounting Research*, 44(1), 177-205.
- Chordia, T., Goyal, A., Sadka, G., Sadka, R., & Shivakumar, L. (2009). "Liquidity and the Post-Earnings-Announcement Drift." *Financial Analysts Journal*, 65(4), 18-32.
- Ng, J., Rusticus, T. O., & Verdi, R. S. (2008). "Implications of Transaction Costs for the Post-Earnings-Announcement Drift." *Journal of Accounting Research*, 46(3), 661-696.

## Implementation Notes

- **Data Requirements**: Real-time or near-real-time access to earnings announcement data, analyst consensus estimates, and actual reported EPS. Data vendors such as I/B/E/S (now Refinitiv), FactSet, Bloomberg, and Estimize provide this data. Free sources (e.g., Yahoo Finance) may have delays that reduce the strategy's effectiveness.
- **Earnings Season Concentration**: Approximately 70-80% of S&P 500 companies report earnings within a 4-6 week window each quarter. This creates bursts of trading activity followed by quieter periods, requiring careful capital management.
- **Transaction Costs**: Turnover is moderate (positions held ~60 days), but spreads may widen around earnings announcements. Implementation shortfall is a key concern for the short side, where borrowing costs can be elevated for stocks with negative surprises.
- **Enhancements**: Combining earnings momentum with price momentum (a "double sort") has been shown to improve risk-adjusted returns. The interaction between the two signals is particularly powerful — stocks with both positive earnings surprises and strong price momentum tend to substantially outperform.
- **Crypto Applicability**: This strategy has no direct crypto application since cryptocurrencies do not have earnings. However, analogous "information underreaction" effects may exist around protocol upgrade announcements, major partnership news, or on-chain metrics releases — though these are not well-studied academically.
- **Platform Availability**: Implementable on QuantConnect (with Estimize or similar data), Bloomberg Terminal (with PORT analytics), and institutional platforms with fundamental data feeds. Requires an event-driven backtesting framework rather than a simple periodic rebalance approach.

## Known Risks and Limitations

- **Data Quality and Timeliness**: The strategy is highly sensitive to the accuracy and timeliness of earnings surprise data. Stale or incorrect consensus estimates can generate false signals. Point-in-time databases (which record estimates as they existed at the time, not as later revised) are essential to avoid look-ahead bias in backtests.
- **Alpha Decay**: Several studies have documented a decline in PEAD magnitude since the early 2000s, coinciding with the growth of algorithmic trading and quantitative hedge funds. Chordia et al. (2009) found that increased liquidity reduced the drift, particularly for large-cap stocks. The effect remains strongest in less-liquid, smaller-cap names.
- **Earnings Quality Risk**: Not all earnings surprises reflect genuine fundamental improvement. Companies can beat estimates through accounting adjustments, one-time items, or lowered expectations management ("whisper numbers"). Combining the SUE signal with an earnings quality filter (e.g., accruals, cash flow confirmation) can improve signal quality.
- **Short-Side Friction**: Shorting stocks with negative earnings surprises is complicated by the fact that these stocks often have high short interest already, making shares expensive or impossible to borrow. The short leg of PEAD is less profitable net of borrowing costs than backtests suggest.
- **Concentrated Calendar Risk**: Since ~80% of companies report earnings within a 4-6 week window, the strategy has intense periods of activity followed by quiet periods. Capital sits idle between earnings seasons unless deployed elsewhere.

## Variants and Extensions

- **Earnings Surprise + Price Momentum Double Sort**: Stocks with both positive earnings surprises and high price momentum show the strongest drift, as the two signals reinforce each other. This combination is one of the most effective in factor investing.
- **Revenue Surprise**: Extending the analysis to revenue surprises (not just EPS) provides an additional signal. Revenue surprises are harder to manipulate through accounting and may carry a more persistent signal.
- **Estimate Revision Momentum**: Rather than waiting for the earnings announcement, tracking the direction and magnitude of analyst estimate revisions in real-time provides an earlier signal. Upward revisions predict positive surprises and subsequent drift.
- **Earnings Acceleration**: Looking at the change in the rate of earnings growth (acceleration vs. deceleration) rather than the level of surprise adds an additional dimension to the signal.
- **Pre-Announcement Drift**: Some evidence suggests that stocks begin drifting in the direction of the eventual earnings surprise before the announcement, reflecting informed trading or the gradual incorporation of public information. Trading the pre-announcement drift requires more sophisticated models but can front-run the post-announcement signal.

## Behavioral and Risk-Based Explanations

The persistence of PEAD is one of the strongest challenges to market efficiency:

- **Investor Inattention**: Hirshleifer, Lim, and Teoh (2009) show that PEAD is larger on days when many firms announce earnings simultaneously, suggesting that limited investor attention prevents full processing of earnings information. When investors are distracted, the underreaction is greater and the subsequent drift is larger.
- **Anchoring to Prior Expectations**: Investors anchor to their prior earnings expectations and adjust insufficiently when the actual number surprises. The larger the surprise, the greater the anchoring effect, explaining why extreme surprises produce the largest drifts.
- **Institutional Constraints**: Many institutional investors have mandate restrictions that prevent them from immediately increasing positions in response to positive surprises (e.g., sector weight limits, tracking error budgets). This institutional sluggishness contributes to the gradual price adjustment.
- **Risk Explanation**: Some researchers argue that post-surprise drift compensates for increased uncertainty following an earnings surprise. However, Bernard and Thomas (1989) provided strong evidence against risk-based explanations, showing that the drift pattern is consistent with investors failing to fully incorporate the implications of current earnings for future earnings.

## Historical Context and Longevity

PEAD is one of the longest-standing anomalies in finance, with an unbroken record of documentation:

- **1968**: Ball and Brown first document the drift, showing that earnings information is incorporated into prices over a period of months rather than days.
- **1989-1990**: Bernard and Thomas provide definitive evidence that the drift reflects investor underreaction to the time-series properties of earnings, ruling out risk-based explanations.
- **2000s**: Despite widespread awareness, the drift persists. Chordia et al. (2009) show it has narrowed but not disappeared, particularly in less-liquid stocks.
- **2010s-present**: PEAD remains one of the most reliable factor tilts in quantitative equity investing, incorporated into the signal sets of most systematic equity hedge funds.
