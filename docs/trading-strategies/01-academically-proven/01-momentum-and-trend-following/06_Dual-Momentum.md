# Dual Momentum

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading-strategies), Gary Antonacci (2014)
> **Asset Class**: Multi-asset (Equities, Bonds, Cash)
> **Crypto/24-7 Applicable**: Adaptable — dual momentum framework applies well to crypto asset selection with appropriate universe modifications
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

Dual momentum, developed and popularized by Gary Antonacci, combines two distinct types of momentum into a single, integrated framework. Relative (cross-sectional) momentum selects the best-performing asset among a set of alternatives, while absolute (time-series) momentum determines whether the selected asset is in an uptrend or downtrend. By combining both signals, the strategy aims to capture the upside of momentum investing while providing a critical layer of downside protection that pure relative momentum lacks.

The canonical implementation, called Global Equities Momentum (GEM), chooses between US equities, international equities, and bonds each month. First, relative momentum determines which equity market has been stronger over the past 12 months. Then, absolute momentum checks whether the selected equity market has outperformed T-bills — if not, the entire allocation moves to bonds. This two-step process means the strategy is only invested in equities when they are both the best relative performer and in a positive absolute trend. The approach has been shown to produce equity-like returns with bond-like drawdowns over multi-decade backtests.

## Trading Rules

1. **Universe** (Global Equities Momentum — GEM):
   - US Equities: S&P 500 (SPY)
   - International Equities: MSCI ACWI ex-US (ACWX or EFA)
   - Bonds: US Aggregate Bonds (AGG or BND)
   - Risk-free benchmark: T-bills (BIL or 3-month T-bill rate)

2. **Step 1 — Relative Momentum**: Compare the 12-month total return of US Equities vs. International Equities. Select the equity asset with the higher return.

3. **Step 2 — Absolute Momentum**: Check whether the selected equity asset's 12-month total return exceeds the 12-month T-bill return.
   - If yes: invest 100% in the selected equity asset.
   - If no: invest 100% in US Aggregate Bonds.

4. **Portfolio**: The strategy holds exactly one asset at any given time — either US equities, international equities, or bonds. This is a concentrated, all-or-nothing approach.

5. **Rebalancing**: Monthly at month-end. Evaluate both momentum conditions and switch assets if the signal changes.

6. **No Partial Allocation**: The standard GEM implementation does not partially allocate. It is fully in one asset. Some practitioners modify this to use partial allocations for smoother transitions.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.321 (Momentum Asset Allocation variant) |
| CAGR | 10-14% (depending on period and variant) |
| Max Drawdown | -18% to -25% |
| Win Rate | 62-67% (monthly) |
| Volatility | 11% |
| Profit Factor | 1.4-1.7 |
| Rebalancing | Monthly |

The GEM strategy's primary virtue is its drawdown reduction rather than return enhancement. Over the 1974-2013 period studied by Antonacci, GEM produced a CAGR of approximately 17.4% with a maximum drawdown of -17.8%, compared to the S&P 500's CAGR of 12.3% with a maximum drawdown of -50.9%. More conservative estimates using out-of-sample data show CAGR of 10-12% with maximum drawdowns of -20% to -25%.

## Efficacy Rating

**Rating: 4/5** — Dual momentum is an elegant, well-reasoned combination of two separately documented anomalies. Its simplicity is appealing — it requires tracking only 3-4 assets and making one decision per month. The rating reflects strong backtested performance, solid theoretical grounding in behavioral finance (underreaction and herding), and practical implementability. Deductions account for: (a) the concentrated single-asset-at-a-time approach, which can produce significant tracking error relative to balanced benchmarks, (b) whipsaw risk during trendless markets causing frequent and costly switches, (c) the Sharpe ratio for the "Momentum Asset Allocation" variant from the Awesome Systematic Trading database (0.321) is somewhat lower than the backtests in Antonacci's book suggest, indicating possible overfitting to the specific backtest period.

## Academic References

- Antonacci, G. (2014). *Dual Momentum Investing: An Innovative Strategy for Higher Returns with Lower Risk*. McGraw-Hill Education.
- Antonacci, G. (2012). "Risk Premia Harvesting Through Dual Momentum." *Portfolio Management Consultants*.
- Jegadeesh, N., & Titman, S. (1993). "Returns to Buying Winners and Selling Losers: Implications for Stock Market Efficiency." *The Journal of Finance*, 48(1), 65-91.
- Moskowitz, T. J., Ooi, Y. H., & Pedersen, L. H. (2012). "Time Series Momentum." *Journal of Financial Economics*, 104(2), 228-250.
- Asness, C. S., Moskowitz, T. J., & Pedersen, L. H. (2013). "Value and Momentum Everywhere." *The Journal of Finance*, 68(3), 929-985.
- Geczy, C. C., & Samonov, M. (2016). "Two Centuries of Price-Return Momentum." *Financial Analysts Journal*, 72(5), 32-56.

## Implementation Notes

- **Extreme Simplicity**: GEM is one of the simplest systematic strategies to implement. It requires tracking 3 ETFs, computing 12-month returns, and making one trade per month at most. A spreadsheet is more than sufficient.
- **Concentration Risk**: Holding a single asset creates significant tracking error. Months where the strategy is in bonds while equities rally (or vice versa) can be psychologically difficult. Practitioners sometimes split between the GEM signal and a static allocation to reduce tracking error.
- **Variants**: Antonacci also developed "Dual Momentum Sector Rotation," which applies the same dual momentum logic to sector ETFs rather than geographic equity markets. Other variants include applying dual momentum to commodity sectors, bond sectors, or factor portfolios.
- **Lookback Sensitivity**: The 12-month lookback is standard but not necessarily optimal. Some research suggests that blending 6-month and 12-month signals or using shorter lookbacks (3-6 months) can reduce whipsaw while maintaining most of the trend-following benefit.
- **Tax Implications**: The strategy's concentration and monthly rebalancing can generate significant capital gains, including short-term gains when assets are held for less than 12 months. Tax-advantaged accounts are strongly preferred.
- **Crypto Adaptation**: Dual momentum can be applied to crypto by comparing, for example, Bitcoin vs. Ethereum (relative momentum) and checking whether the winner has outperformed stablecoins (absolute momentum). If neither crypto asset is in an uptrend, allocate to stablecoins or yield-bearing stablecoin strategies. The higher volatility of crypto assets means larger potential returns but also larger whipsaw losses during range-bound markets.
- **Behavioral Advantage**: The strategy's greatest practical value may be behavioral — it provides a mechanical, emotion-free rule for exiting risk assets during bear markets. Many investors who would otherwise panic-sell at the bottom find it easier to follow a systematic rule.
- **Platform Availability**: Implementable on any brokerage platform. Automated implementations available on QuantConnect, Composer (formerly Torto), and various robo-advisor platforms that support custom strategies. Antonacci's website (optimalmomentum.com) provides monthly signal updates.

## Known Risks and Limitations

- **Single-Asset Concentration**: The all-or-nothing approach creates extreme concentration risk. The portfolio is 100% in one asset at all times, which means a single bad month in the selected asset translates directly to a portfolio-level loss with no diversification buffer.
- **Tracking Error vs. Benchmarks**: Because GEM holds only one asset at a time, its returns can deviate dramatically from any standard benchmark (60/40, S&P 500) in either direction. Multi-year periods of underperformance relative to a simple balanced portfolio are not uncommon and can erode investor confidence.
- **Whipsaw at Signal Boundaries**: When the 12-month return of the selected equity is close to the T-bill rate, small random fluctuations can trigger frequent switches between equities and bonds, generating transaction costs and tax events without adding value. A buffer zone (e.g., require a 1% margin above T-bills) can mitigate this.
- **Lookback Window Sensitivity**: The 12-month lookback is a single-parameter choice that may not be optimal across all market regimes. Shorter lookbacks (6 months) respond faster to trend changes but increase whipsaw, while longer lookbacks (18 months) are smoother but miss more of the initial move.
- **Historical Period Dependence**: Antonacci's reported performance covers a period (1974-2013) that included strong secular bull markets in both US and international equities. Out-of-sample performance from 2014 onward has been less impressive, with the strategy frequently in US equities due to persistent US outperformance, effectively becoming a buy-and-hold US equity strategy.

## Variants and Extensions

- **Multi-Asset Dual Momentum**: Extend the GEM framework beyond equities to include commodities, REITs, and other asset classes. At each rebalancing, apply relative momentum across all risk assets, then apply the absolute momentum filter to the winner. This increases the number of possible regimes the strategy can navigate.
- **Sector Dual Momentum**: Apply dual momentum to sector ETFs rather than geographic markets. Select the sector with the strongest relative momentum, then check absolute momentum before investing. This variant captures sector rotation effects within a dual momentum framework.
- **Partial Allocation Variant**: Instead of 100% in one asset, allocate 60-70% to the dual momentum signal and 30-40% to a static diversified portfolio. This reduces tracking error and concentration risk while preserving most of the downside protection benefit.
- **Crypto Dual Momentum**: Compare Bitcoin vs. Ethereum (relative momentum), then check if the winner has outperformed a stablecoin yield benchmark (absolute momentum). If neither crypto asset passes the absolute filter, allocate to stablecoin yield strategies (lending, liquidity provision). The higher volatility of crypto makes the absolute momentum filter more valuable as a drawdown reducer.

## Why Dual Momentum Works: Theoretical Foundation

The strategy's effectiveness rests on combining two distinct and well-documented sources of return predictability:

- **Relative Momentum (Cross-Sectional)**: Based on Jegadeesh and Titman (1993), relative momentum identifies which assets are likely to continue outperforming their peers. It captures herding behavior and gradual information diffusion across related assets. In the GEM context, it determines whether US or international equities have stronger trending behavior.
- **Absolute Momentum (Time-Series)**: Based on Moskowitz, Ooi, and Pedersen (2012), absolute momentum determines whether the selected asset is in a genuine uptrend or whether its "relative outperformance" is simply "less bad" during a broad bear market. This critical filter prevents the strategy from being invested in equities that are declining, just declining less than their peers.
- **The Interaction Effect**: The combination is more powerful than either component alone because it addresses the key weakness of each. Pure relative momentum can keep you in equities during bear markets (you always hold something). Pure absolute momentum can keep you in underperforming assets as long as they are trending up. Dual momentum only invests in equities when they are both the best relative performer AND in a genuine uptrend — a much higher bar that filters out most adverse market regimes.

## Historical Performance in Key Market Regimes

- **2000-2002 (Dot-Com Crash)**: GEM moved to bonds as US equities broke below their 12-month moving average, avoiding the bulk of the -45% S&P 500 decline.
- **2003-2007 (Bull Market)**: GEM rotated between US and international equities, capturing the strong international outperformance of this period. International equities significantly outperformed US equities, and GEM held EFA/ACWX for much of this period.
- **2008 (Financial Crisis)**: GEM moved to bonds by late 2007/early 2008 as equity returns turned negative, avoiding the worst of the -37% S&P 500 decline. The strategy's maximum drawdown during this period was approximately -12%.
- **2009-2013 (Recovery)**: GEM re-entered equities in mid-2009 as 12-month returns turned positive, capturing most of the recovery. The delayed re-entry (missing the March 2009 bottom) is a known limitation.
- **2020 (COVID)**: GEM moved to bonds in March 2020 as the pandemic crash pushed 12-month returns negative, then re-entered equities by late 2020 as the recovery pushed returns positive.
