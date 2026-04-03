# Risk Parity

> **Source**: [Bridgewater Associates - All Weather Strategy](https://www.bridgewater.com/research-and-insights/the-all-weather-story); [Asness, Frazzini & Pedersen (2012)](https://www.aqr.com/-/media/AQR/Documents/Insights/White-Papers/Understanding-Risk-Parity.pdf)
> **Asset Class**: Multi-Asset (Equities, Bonds, Commodities, Inflation-Linked)
> **Crypto/24-7 Applicable**: Adaptable --- can include crypto as an asset class within the risk parity framework
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

Allocates capital across asset classes such that each contributes equally to total portfolio risk, rather than allocating equal capital. Traditional portfolios (e.g., 60/40 stocks/bonds) are dominated by equity risk because equities are far more volatile than bonds. Risk parity equalizes risk contributions by overweighting lower-volatility assets (bonds) and underweighting higher-volatility assets (equities), then optionally applying leverage to reach a target return. Pioneered by Bridgewater Associates' All Weather fund (1996), risk parity has become one of the most widely adopted institutional allocation frameworks. Academic research demonstrates superior Sharpe ratios compared to traditional balanced portfolios over long periods.

## Trading Rules

1. **Asset Universe**: Select broad asset classes: equities (global developed + emerging), government bonds (long-term + short-term), commodities (diversified basket), inflation-linked bonds (TIPS), and optionally gold and crypto.
2. **Risk Estimation**: Compute the annualized volatility of each asset class using a rolling window (e.g., 60-day or 120-day realized volatility) or an exponentially weighted moving average.
3. **Risk Parity Weights**: Allocate weights inversely proportional to each asset's volatility:
   - `Weight_i = (1 / Vol_i) / Sum(1 / Vol_j)` for all assets j
   - This ensures each asset contributes approximately equal risk to the portfolio.
4. **Leverage (Optional)**: If the unlevered risk parity portfolio has lower expected return than the target, apply leverage to scale up to the desired risk/return level (e.g., 10-12% target volatility).
5. **Rebalancing**: Monthly. Recompute volatilities and adjust weights. More frequent rebalancing (weekly) provides tighter risk control but increases turnover.
6. **Correlation Adjustment (Advanced)**: Use a full covariance matrix rather than just volatilities to account for correlations. This produces a "true" risk parity (equal risk contribution) portfolio, solved via optimization.
7. **Risk Management**: Cap leverage at 2-3x. Monitor drawdowns; reduce leverage if portfolio drawdown exceeds 10%. Rebalance immediately after volatility regime shifts.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.6 - 0.8 (unlevered); 0.7 - 1.0 (levered to target vol) |
| CAGR | 6% - 10% (unlevered); 8% - 14% (levered) |
| Max Drawdown | -10% to -20% (levered) |
| Win Rate | 60% - 65% (monthly) |
| Volatility | 6% - 8% (unlevered); 10% - 12% (levered to target) |
| Profit Factor | 1.4 - 1.8 |
| Rebalancing | Monthly |

## Efficacy Rating

**5/5** --- Risk parity is one of the most robust and well-evidenced allocation strategies in finance. Asness, Frazzini, and Pedersen (2012) found that risk parity delivered Sharpe ratios of 0.6-0.7 compared to 0.3-0.4 for traditional 60/40 portfolios over 1926-2010. Bridgewater's All Weather fund returned approximately 14% in 2008 while the S&P 500 lost 37%, demonstrating exceptional crisis resilience. The strategy benefits from genuine diversification across economic regimes (growth, recession, inflation, deflation). The main risk is interest rate normalization reducing the historical bond tailwind. Leverage introduces borrowing costs and margin risk. Despite these caveats, risk parity remains the gold standard for multi-asset allocation.

## Academic References

- Asness, C. S., Frazzini, A., & Pedersen, L. H. (2012). "Leverage Aversion and Risk Parity." *Financial Analysts Journal*, 68(1), 47-59. [AQR](https://www.aqr.com/-/media/AQR/Documents/Insights/White-Papers/Understanding-Risk-Parity.pdf)
- Maillard, S., Roncalli, T., & Teiletche, J. (2010). "The Properties of Equally Weighted Risk Contribution Portfolios." *Journal of Portfolio Management*, 36(4), 60-70.
- Qian, E. (2005). "Risk Parity Portfolios: Efficient Portfolios Through True Diversification." *PanAgora Asset Management White Paper*.
- Bridgewater Associates. "The All Weather Story." [Bridgewater](https://www.bridgewater.com/research-and-insights/the-all-weather-story)

## Implementation Notes

- **Simplicity of Core Logic**: The inverse-volatility weighting is trivially computed. The full covariance-based risk parity requires a numerical optimizer (quadratic programming) but is still relatively simple.
- **Data Requirements**: Daily returns for each asset class to compute rolling volatilities. ETFs (SPY, TLT, GLD, DBC, TIPS) provide convenient proxies for backtesting. For live trading, futures provide better leverage efficiency.
- **Leverage Implementation**: In practice, leverage is achieved through futures (inherently levered via margin) rather than borrowing cash. Futures also allow precise asset class exposure without needing to hold the physical assets.
- **Crypto Inclusion**: Crypto's high volatility means it receives a very small weight in risk parity. A 60% vol asset might get a 1-2% allocation vs. 20-30% for bonds. This is appropriate --- it limits crypto exposure while still capturing diversification benefits.
- **Pure Zig Implementation**: Inverse-volatility weighting is basic division and normalization. Rolling volatility calculation is standard deviation over an array. The advanced covariance-based version requires matrix inversion or a simple optimization loop, both feasible in Zig.
- **Interest Rate Regime**: Risk parity's historical outperformance benefited from a 40-year bond bull market (1980-2020). In a rising rate environment, the large bond allocation may drag on returns. Dynamic risk parity that adjusts to interest rate regimes is an area of active research.
