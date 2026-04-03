# Dollar Carry Trade

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading-strategies)
> **Asset Class**: Foreign Exchange
> **Crypto/24-7 Applicable**: No — strategy is specific to the US dollar's reserve currency dynamics and its relationship to global interest rate differentials
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

The dollar carry trade is a distinct currency strategy that differs from the traditional FX carry trade by focusing specifically on the US dollar's position relative to a basket of foreign currencies. Rather than constructing long-short portfolios across multiple currency pairs, the dollar carry trade times exposure to the dollar itself based on the average forward discount (the difference between US interest rates and the average of foreign interest rates). When US rates are low relative to the rest of the world, the strategy goes short the dollar; when US rates are high, it goes long.

This strategy exploits a different dimension of the forward premium puzzle than the cross-sectional carry trade. Lustig, Roussanov, and Verdelhan (2014) demonstrate that the dollar carry component and the cross-sectional carry component are largely uncorrelated, meaning the dollar carry captures a distinct risk premium related to global macroeconomic conditions and the dollar's role as the world's primary reserve and funding currency. The dollar tends to appreciate during global risk-off episodes regardless of interest rate differentials, which creates the premium that this strategy harvests during calm periods.

## Trading Rules

1. **Universe**: US dollar versus a trade-weighted basket of major currencies (typically 10-20 currencies weighted by trade volume or GDP).

2. **Signal Construction**: At the end of each month, compute the average forward discount of USD against the currency basket. This equals the US short-term rate minus the average foreign short-term rate.

3. **Position Sizing**:
   - If USD forward discount is positive (US rates > foreign average): go long USD against the basket.
   - If USD forward discount is negative (US rates < foreign average): go short USD against the basket.
   - Scale position size proportionally to the magnitude of the forward discount.

4. **Instrument**: Execute via a basket of 1-month FX forwards against USD, weighted to match the target currency basket.

5. **Rebalancing**: Monthly. Recalculate the average forward discount and adjust the direction and size of the dollar position.

6. **Risk Management**: Apply volatility targeting to maintain consistent risk exposure. The dollar carry signal can be combined with the cross-sectional carry signal for diversification.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.113 |
| CAGR | 1-2% (excess return, unlevered) |
| Max Drawdown | -15% to -25% |
| Win Rate | 52-55% (monthly) |
| Volatility | 5.8% |
| Profit Factor | 1.1-1.3 |
| Rebalancing | Monthly |

The dollar carry trade exhibits a notably lower Sharpe ratio (0.113) compared to the cross-sectional FX carry trade. This reflects the strategy's reliance on a single directional bet (long or short the dollar) rather than a diversified portfolio of currency pairs. However, the strategy's low correlation with cross-sectional carry makes it a valuable diversifier in multi-strategy currency portfolios. The average forward discount forecasts up to 25% of the dollar return variation at the one-year horizon, providing meaningful predictive power despite the modest Sharpe.

## Efficacy Rating

**Rating: 3/5** — The dollar carry trade is academically well-documented and captures a distinct risk premium uncorrelated with the traditional carry trade. However, its standalone Sharpe ratio is low (0.113), making it impractical as a primary strategy without leverage or combination with other signals. The strategy's value lies primarily in its diversification benefits within a broader currency portfolio. The dollar's behavior during crises (safe-haven appreciation regardless of rates) creates periodic large losses that are difficult to hedge.

## Academic References

- Lustig, H., Roussanov, N., & Verdelhan, A. (2011). "Common Risk Factors in Currency Markets." *Review of Financial Studies*, 24(11), 3731-3777.
- Lustig, H., Roussanov, N., & Verdelhan, A. (2014). "Countercyclical Currency Risk Premia." *Journal of Financial Economics*, 111(3), 527-553.
- Verdelhan, A. (2018). "The Share of Systematic Variation in Bilateral Exchange Rates." *The Journal of Finance*, 73(1), 375-418.
- Hassan, T. A. (2013). "Country Size, Currency Unions, and International Asset Returns." *The Journal of Finance*, 68(6), 2269-2308.
- Maggiori, M. (2017). "Financial Intermediation, International Risk Sharing, and Reserve Currencies." *American Economic Review*, 107(10), 3038-3071.

## Implementation Notes

- **Data Requirements**: Monthly short-term interest rates for the US and a basket of 10-20 trading partner countries. Trade-weighted currency indices (e.g., the Federal Reserve's broad dollar index) can serve as the basket proxy.
- **Transaction Costs**: Similar to the FX carry trade — tight spreads for G10 pairs, wider for EM. The strategy has moderate turnover since the dollar carry signal changes direction infrequently.
- **Signal Enhancement**: Combining the dollar carry signal with US industrial production growth rates improves forecasting power. The dollar tends to strengthen when US growth outpaces the rest of the world, providing a complementary macroeconomic signal.
- **Correlation Structure**: The dollar carry trade has near-zero correlation with the cross-sectional FX carry trade, making it an effective portfolio diversifier. Combining both strategies improves the overall currency portfolio Sharpe by approximately 30-50%.
- **Regime Sensitivity**: The strategy performs poorly during transitions between monetary policy regimes, particularly when the Fed changes direction unexpectedly. Performance is strongest during sustained rate differential regimes.
