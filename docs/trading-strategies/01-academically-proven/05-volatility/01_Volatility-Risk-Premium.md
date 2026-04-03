# Volatility Risk Premium

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading-strategies), [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 7, [Carr & Wu (2009)](https://engineering.nyu.edu/sites/default/files/2019-01/CarrReviewofFinStudiesMarch2009-a.pdf)
> **Asset Class**: Equity Options / Volatility / Multi-Asset
> **Crypto/24-7 Applicable**: Adaptable — a volatility risk premium exists in crypto options markets (Deribit), though it is less stable, more episodic, and subject to higher tail risk than in equity markets
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

The volatility risk premium (VRP) is the systematic tendency for option-implied volatility to exceed subsequent realized volatility. This wedge exists because investors are willing to pay above actuarial fair value for portfolio insurance (protective puts, index options), creating a structural transfer of wealth from hedgers to volatility sellers. The VRP is one of the most persistent and well-documented risk premia in financial markets, observable across equities, fixed income, currencies, and commodities.

Carr and Wu (2009) provided the theoretical framework by showing that variance swap rates consistently exceed realized variance, with the difference — the variance risk premium — being large, negative (from the perspective of the variance buyer), and time-varying. Empirically, the S&P 500 implied volatility (as measured by VIX) has exceeded subsequent 30-day realized volatility approximately 85-90% of the time since 1990, with the average gap being 3-5 volatility points.

The simplest implementation sells short-term ATM options (puts or straddles) on a broad equity index and delta-hedges to isolate the volatility component. More sophisticated implementations use variance swaps, which provide pure exposure to the difference between implied and realized variance without the complications of discrete delta hedging. The strategy generates steady positive returns in calm markets but is subject to severe losses during volatility spikes, creating a return profile similar to selling insurance.

Academic research has documented that shorting volatility across multiple asset classes produces a composite Sharpe ratio of approximately 1.0, dramatically higher than the equity risk premium's Sharpe of ~0.4. However, the return distribution is highly negatively skewed — put sellers have historically incurred losses of up to 800% of premium collected in extreme events.

## Trading Rules

1. **Core Position**: At each monthly options expiration, sell 1-month ATM straddles on the S&P 500 (SPX options) or equivalent broad index.

2. **Delta Hedging**: Delta-hedge daily using S&P 500 futures or ETF (SPY). This isolates the volatility exposure, converting the position from directional to a pure bet on implied vs. realized volatility.

3. **Position Sizing**:
   - Size the position so that the maximum loss in a 2008-style event (VIX to 80, realized vol 70%) would not exceed 25% of portfolio equity.
   - Typical notional: 0.5-1.0x portfolio equity in straddle notional.

4. **Entry Timing**: The VRP is time-varying and partially predictable. Larger positions when:
   - VIX-RV spread (VIX minus 20-day realized vol) exceeds 5 points.
   - VIX is above its 6-month median (higher VIX = higher VRP historically).
   - Reduce or skip when VIX-RV spread is negative (implied below realized — no premium to harvest).

5. **Maturity Selection**: 1-month options offer the best risk-adjusted VRP capture due to faster time decay (theta). Weekly options have higher VRP per day but also higher gamma risk and transaction costs.

6. **Exit/Roll**: Hold to expiration and roll to the next monthly cycle. Close early only if VIX spikes above 40 (crisis regime where VRP turns negative and realized vol can exceed implied).

7. **Multi-Asset Extension**: Diversify VRP capture across asset classes — sell straddles on Treasury bond futures (TY), EUR/USD, gold (GC), and crude oil (CL). Cross-asset diversification reduces peak drawdowns by ~30% with minimal Sharpe reduction.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.637 |
| CAGR | 8-12% (single-asset), 10-15% (multi-asset) |
| Max Drawdown | -30% to -50% (single-asset, 2008/2020) |
| Win Rate | 70-80% (monthly) |
| Volatility | 13.2% annualized |
| Profit Factor | 1.5-2.0 |
| Rebalancing | Monthly (option roll) |

The Sharpe of 0.637 reflects single-asset (equity) VRP capture. Multi-asset implementations achieve Sharpe ratios of 0.8-1.2 due to the diversification benefit — VRP shocks in equities, rates, and commodities are imperfectly correlated. The 70-80% monthly win rate reflects the consistency of the VRP, but the strategy's negative skewness means that losing months are significantly larger than winning months.

## Efficacy Rating

**Rating: 4/5** — The VRP is one of the most robust and economically rational risk premia, supported by decades of academic research and a clear economic mechanism (demand for portfolio insurance). The deduction reflects the severe tail risk (the strategy lost 30-50% in both 2008 and March 2020), the negative skewness of returns that makes drawdown timing unpredictable, and evidence that the premium has compressed somewhat as more systematic capital targets it. Risk management (position sizing, timing, multi-asset diversification) is critical to long-term survival.

## Academic References

- Carr, P., & Wu, L. (2009). "Variance Risk Premiums." *The Review of Financial Studies*, 22(3), 1311-1341.
- Coval, J. D., & Shumway, T. (2001). "Expected Option Returns." *The Journal of Finance*, 56(3), 983-1009.
- Bakshi, G., & Kapadia, N. (2003). "Delta-Hedged Gains and the Negative Market Volatility Risk Premium." *The Review of Financial Studies*, 16(2), 527-566.
- Dew-Becker, I., Giglio, S., Le, A., & Rodriguez, M. (2017). "The Price of Variance Risk." *Journal of Financial Economics*, 123(2), 225-250.
- Ilmanen, A. (2012). "Do Financial Markets Reward Buying or Selling Insurance and Lottery Tickets?" *Financial Analysts Journal*, 68(5), 26-36.
- Egloff, D., Leippold, M., & Wu, L. (2010). "The Term Structure of Variance Swap Rates and Optimal Variance Swap Investments." *Journal of Financial and Quantitative Analysis*, 45(5), 1279-1310.

## Implementation Notes

- **Data Requirements**: Options chain data (implied volatilities, Greeks) for all target underlyings. Historical realized volatility series. VIX and term structure data for timing signals.
- **Delta Hedging Frequency**: Daily hedging is standard, but the discrete hedging error introduces variance in P&L. More frequent hedging (2-4x daily) reduces this variance but increases transaction costs. The optimal frequency depends on the gamma of the position and the bid-ask spread of the hedging instrument.
- **Tail Risk Management**: The single most important factor in VRP strategy survival is tail risk management. Approaches include: (a) always buy far-OTM puts as a hedge (reduces net VRP but caps losses), (b) use VRP timing signals to reduce exposure in high-risk regimes, (c) diversify across uncorrelated asset classes, (d) use variance swaps with a cap (capped variance swaps limit maximum loss).
- **Crypto Adaptation**: The VRP exists in crypto options (primarily on Deribit), with Bitcoin implied volatility typically exceeding realized by 10-15 points. However, the VRP is more episodic — it can turn sharply negative during rapid rallies. Shorter tenors (weekly) and smaller position sizes are advisable. The lack of liquid multi-leg options markets in crypto limits sophisticated implementations.
- **Tax Considerations**: In many jurisdictions, options premium received is taxed at ordinary income rates, while delta-hedging gains/losses may be taxed differently. The strategy's high frequency of expiring options creates numerous taxable events.
