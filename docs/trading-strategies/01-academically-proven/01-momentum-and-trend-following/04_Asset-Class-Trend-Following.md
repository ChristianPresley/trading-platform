# Asset Class Trend Following

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading-strategies), [Quantpedia #0001](https://quantpedia.com/strategies/asset-class-trend-following/)
> **Asset Class**: Multi-asset (Equities, Bonds, Commodities, REITs)
> **Crypto/24-7 Applicable**: Adaptable — crypto can serve as an additional asset class in the trend-following universe
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

Asset class trend following is among the simplest and most effective systematic strategies ever documented. The core idea applies a trend filter — typically a moving average rule or past return sign — to broad asset classes represented by low-cost index funds or ETFs. When an asset class is in an uptrend, hold it; when in a downtrend, move to cash or short-term bonds. By applying this filter across multiple uncorrelated asset classes (equities, bonds, commodities, REITs), the strategy achieves equity-like returns with dramatically reduced drawdowns.

The strategy's roots trace to Faber (2007), who demonstrated that a simple 10-month moving average timing system applied to five asset classes (US stocks, foreign stocks, bonds, REITs, commodities) produced a Sharpe ratio of approximately 0.50 with a maximum drawdown roughly half that of a buy-and-hold portfolio. The approach has been validated across over a century of data by Hurst, Ooi, and Pedersen (2017) and extended to dozens of asset classes by AQR, Man Group, and other institutional managers. Its simplicity is its greatest virtue — the rules are unambiguous, require minimal computation, and can be implemented with a handful of ETFs.

## Trading Rules

1. **Universe**: Five or more broad asset class ETFs or index funds. A canonical implementation:
   - US Equities (SPY or VTI)
   - International Developed Equities (EFA or VEA)
   - US Bonds (AGG or BND)
   - Real Estate (VNQ or IYR)
   - Commodities (DBC or GSG)

2. **Trend Signal**: At month-end, for each asset class, determine trend using one of:
   - **Simple Moving Average (SMA)**: If price > 10-month SMA, the asset is in an uptrend.
   - **Past Return**: If the 12-month total return is positive, the asset is in an uptrend.
   - Both methods produce similar results.

3. **Allocation Rules**:
   - If the asset is in an uptrend: allocate the full target weight (e.g., 20% for a 5-asset portfolio).
   - If the asset is in a downtrend: move that allocation to cash (T-bills or short-term Treasuries).

4. **Portfolio Weights**: Equal-weight across all asset classes (e.g., 20% each for 5 assets). Some variants use risk-parity weighting for improved diversification.

5. **Rebalancing**: Monthly, at month-end. Evaluate each asset's trend signal and adjust positions accordingly.

6. **No Leverage**: The basic implementation uses no leverage. The strategy is fully invested in risk assets only when all asset classes are trending up; otherwise, a portion sits in cash.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.502 |
| CAGR | 7-10% |
| Max Drawdown | -15% to -20% |
| Win Rate | 60-65% (monthly) |
| Volatility | 10.4% |
| Profit Factor | 1.5-1.8 |
| Rebalancing | Monthly |

The strategy's standout feature is its dramatically reduced maximum drawdown compared to buy-and-hold. While a 60/40 portfolio experienced drawdowns exceeding -30% during the 2008 financial crisis, the trend-following version typically limited losses to -10% to -15% by moving equity and real estate allocations to cash when the trend turned negative.

## Efficacy Rating

**Rating: 5/5** — This strategy receives the maximum rating due to its exceptional combination of simplicity, robustness, and risk-adjusted performance. It requires no complex modeling, works across a century of data, is implementable with a handful of low-cost ETFs, and provides meaningful drawdown reduction without sacrificing long-term returns. The strategy is transparent, low-turnover (~2-4 trades per asset per year), and has minimal capacity constraints since it trades the most liquid ETFs in existence. It is the single best "starter" systematic strategy for any investor.

## Academic References

- Faber, M. T. (2007). "A Quantitative Approach to Tactical Asset Allocation." *Journal of Wealth Management*, 9(4), 69-79. (Updated 2013 version available on SSRN.)
- Hurst, B., Ooi, Y. H., & Pedersen, L. H. (2017). "A Century of Evidence on Trend-Following Investing." *Journal of Portfolio Management*, 44(1), 15-29.
- Antonacci, G. (2012). "Risk Premia Harvesting Through Dual Momentum." *Journal of Management & Entrepreneurship*, 7(1).
- Asness, C. S., Moskowitz, T. J., & Pedersen, L. H. (2013). "Value and Momentum Everywhere." *The Journal of Finance*, 68(3), 929-985.
- Clare, A., Seaton, J., Smith, P. N., & Thomas, S. (2014). "Trend Following, Risk Parity and Momentum in Commodity Futures." *International Review of Financial Analysis*, 31, 1-12.
- Zakamulin, V. (2014). "The Real-Life Performance of Market Timing with Moving Average and Time-Series Momentum Rules." *Journal of Asset Management*, 15(4), 261-278.

## Implementation Notes

- **Simplicity of Implementation**: This is one of the easiest strategies to implement. It requires only monthly price data for a small number of ETFs, a simple moving average calculation, and a brokerage account capable of monthly rebalancing. No specialized software is needed.
- **ETF Selection**: Use the most liquid, lowest-cost ETFs for each asset class. Expense ratios of 0.03-0.10% are achievable. Avoid leveraged or inverse ETFs, which introduce tracking error.
- **Cash Instrument**: When out of a risk asset, allocate to short-term Treasury ETFs (SHY, BIL) or money market funds. In rising rate environments, this cash allocation earns meaningful returns.
- **Tax Efficiency**: Monthly rebalancing in taxable accounts generates short-term capital gains. Consider implementing in tax-advantaged accounts (IRA, 401k) or using tax-loss harvesting to offset gains.
- **Enhancements**: Adding more asset classes (e.g., TIPS, gold, emerging market equities, international bonds) improves diversification. Risk-parity weighting (allocating more to lower-volatility assets) can improve the Sharpe ratio by 0.05-0.10.
- **Crypto Adaptation**: Bitcoin and Ethereum can be added as additional asset classes in the trend-following universe. Their low correlation to traditional assets during trending periods provides diversification benefits, though their high volatility requires careful position sizing (smaller allocation weight or volatility-targeted sizing).
- **Platform Availability**: Implementable in any brokerage account with ETF access. Can be fully automated on platforms like Interactive Brokers (via API), Alpaca, or QuantConnect. Even a spreadsheet-based approach is feasible given the monthly rebalancing frequency.
- **Historical Robustness**: This strategy has been tested on data going back to the 1900s using index return data, and the trend-following signal has been profitable in every decade tested, including the Great Depression, stagflation of the 1970s, and the 2008 financial crisis.

## Known Risks and Limitations

- **Whipsaw in Sideways Markets**: When an asset class oscillates around its moving average without establishing a clear trend, the strategy generates repeated losing trades. This can persist for months or even years — US equities were range-bound from 2000-2003 and 2015-2016, creating challenging conditions for the trend filter.
- **Opportunity Cost of Cash**: When the trend filter moves an allocation to cash, the investor misses out on returns if the asset class quickly reverses and resumes its uptrend. In strong bull markets (e.g., 2013, 2017, 2019), the strategy may underperform buy-and-hold because occasional dips below the moving average trigger premature exits.
- **False Signals at Trend Transitions**: The most painful false signals occur at market bottoms, when prices briefly cross above the moving average before falling again, or at market tops, when prices briefly dip below before continuing higher. These transitions generate the majority of the strategy's losses.
- **Limited Upside Capture**: Because the strategy exits risk assets after they have already declined below the moving average, it locks in some losses during the initial drawdown phase. Similarly, it re-enters after the recovery is already underway, missing the initial bounce. The strategy's value is in avoiding the middle portion of severe bear markets.

## Variants and Extensions

- **Risk-Parity Weighting**: Instead of equal-weighting asset classes, allocate inversely proportional to each asset class's trailing volatility. Lower-volatility assets (bonds) receive larger allocations, while higher-volatility assets (commodities, equities) receive smaller allocations. This produces a more balanced risk contribution and typically improves the Sharpe ratio by 0.05-0.15.
- **Accelerating Dual Momentum**: Combine the trend filter with a relative momentum ranking — hold the top N asset classes by relative momentum, but only if each passes the absolute trend filter. This reduces the number of asset classes held during bear markets while concentrating in the strongest trends.
- **Adaptive Moving Average**: Replace the fixed 10-month SMA with an adaptive moving average that shortens during high-volatility regimes and lengthens during low-volatility periods. The Kaufman Adaptive Moving Average (KAMA) is one implementation of this idea.
- **Multi-Asset with Leverage**: Apply modest leverage (1.2-1.5x) to the trend-following portfolio during periods when multiple asset classes are in uptrends, funded by reduced leverage during periods when few asset classes are trending positively. This dynamic leverage approach can boost returns while maintaining controlled drawdowns.

## Why This Strategy Gets a 5/5 Rating

Asset class trend following earns the highest rating in this section because it uniquely combines:

1. **Simplicity**: The rules fit on an index card. No factor models, no regressions, no complex optimization. An investor with a spreadsheet and 30 minutes per month can implement this.
2. **Robustness**: The 10-month SMA rule works across a century of data without parameter re-optimization. No other strategy in this section can claim such stability across such a long period.
3. **Drawdown Reduction**: The strategy's primary value proposition is its ~50% reduction in maximum drawdown relative to buy-and-hold, achieved without sacrificing long-term CAGR. This is the rare "free lunch" in investing.
4. **Low Capacity Constraints**: The strategy trades the most liquid ETFs in the world (SPY, AGG, VNQ, etc.), making it implementable at virtually any scale.
5. **Behavioral Benefit**: The mechanical trend filter removes the most destructive investor behavior — panic selling at market bottoms. The rule-based exit during bear markets is both earlier and more disciplined than most investors achieve on their own.
6. **Diversification Across Asset Classes**: Unlike single-asset strategies, the multi-asset approach ensures that the trend filter is applied across uncorrelated return streams, dramatically reducing the impact of false signals in any single asset class.
