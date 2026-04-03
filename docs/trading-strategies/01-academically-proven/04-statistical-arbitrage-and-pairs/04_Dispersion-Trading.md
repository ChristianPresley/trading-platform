# Dispersion Trading

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading-strategies), [Deng (2008) — Volatility Dispersion Trading](https://www.smallake.kr/wp-content/uploads/2014/10/University-of-Illinois-Deng-Volatility-Dispersion-Trading.pdf)
> **Asset Class**: Equity Options / Volatility
> **Crypto/24-7 Applicable**: No — requires a liquid index options market and listed options on individual constituents, which does not exist in crypto with sufficient depth
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

Dispersion trading exploits the systematic overpricing of index volatility relative to the weighted-average volatility of its constituents. The strategy sells options (typically straddles or variance swaps) on a broad equity index (e.g., S&P 500) while simultaneously buying options on the individual constituent stocks. The profit comes from the "correlation risk premium" — the tendency for implied correlation among index constituents to exceed realized correlation, causing index implied volatility to be richer than the portfolio-weighted implied volatility of the components.

The economic rationale is rooted in portfolio theory. An index's variance equals the weighted sum of constituent variances plus a covariance term. Market participants systematically overpay for index downside protection (creating demand for index puts), which inflates index implied volatility. Meanwhile, individual stock options receive less demand for hedging, keeping their implied volatilities closer to fair value. The difference represents a tradeable spread.

Academic research has documented that dispersion trading was extremely profitable in the late 1990s, with Deng (2008) reporting average monthly returns of 24% and a Sharpe ratio of 1.2 from 1996-2000. However, returns have declined significantly as the trade became more crowded, with average monthly returns near zero after 2000. More recent implementations using refined position sizing and timing signals have recovered some profitability, with Sharpe ratios in the 0.3-0.8 range.

## Trading Rules

1. **Instruments**:
   - **Short leg**: Sell 1-month ATM straddles (or variance swaps) on the S&P 500 index (SPX options).
   - **Long leg**: Buy 1-month ATM straddles (or variance swaps) on a representative basket of S&P 500 constituents (typically the 50-100 largest by weight).

2. **Position Sizing**:
   - Weight individual stock option positions proportionally to their index weight.
   - Vega-neutral construction: total long vega from constituent options should approximately equal short vega from the index option.
   - The strategy is short correlation and long idiosyncratic risk.

3. **Entry Signal**: Initiate the trade when the implied correlation (derived from index vs. constituent implied vols) exceeds its 6-month rolling average by 0.5 standard deviations or more. This indicates elevated correlation risk premium.

4. **Timing**: Enter at the beginning of each monthly options cycle (after prior month expiration). Hold to expiration.

5. **Delta Hedging**: Delta-hedge all option positions daily using the underlying securities or futures. The strategy is designed to be pure volatility/correlation exposure, not directional.

6. **Exit**: Hold to option expiration. Early exit if realized correlation spikes above 0.85 (indicating regime shift where the trade will likely lose).

7. **Portfolio**: Run on a single index (S&P 500) or diversify across multiple indices (Euro Stoxx 50, Nikkei 225) for additional diversification.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.432 |
| CAGR | 5-10% (varies by period) |
| Max Drawdown | -20% to -35% |
| Win Rate | 60-70% |
| Volatility | 8.1% annualized |
| Profit Factor | 1.3-1.6 |
| Rebalancing | Monthly (option expiration cycle) |

The Sharpe of 0.432 reflects the post-2000 era when the trade became more widely known. Earlier periods (1996-2000) produced dramatically higher risk-adjusted returns. The high win rate (60-70%) reflects the persistence of the correlation risk premium, but losses during correlation spikes (2008, 2020) can be severe, creating a negatively skewed return distribution. The strategy is profitable in most months but faces large losses during systemic crises when correlations converge toward 1.0.

## Efficacy Rating

**Rating: 4/5** — The correlation risk premium is a well-documented and economically rational phenomenon (investors demand compensation for bearing correlation risk). The deduction reflects significant performance decay since the early 2000s, high implementation complexity (managing options on 50-100 individual stocks), substantial transaction costs from frequent delta hedging, and severe losses during correlation spikes. The strategy remains viable for sophisticated institutional participants with low execution costs.

## Academic References

- Driessen, J., Maenhout, P., & Vilkov, G. (2009). "The Price of Correlation Risk: Evidence from Equity Options." *The Journal of Finance*, 64(3), 1377-1406.
- Deng, Q. (2008). "Volatility Dispersion Trading." Working Paper, University of Illinois.
- Buss, A., & Vilkov, G. (2012). "Measuring Equity Risk with Option-Implied Correlations." *Review of Financial Studies*, 25(10), 3113-3140.
- Marshall, C. (2009). "Dispersion Trading: Empirical Evidence from U.S. Options Markets." Working Paper.
- Faria, G., & Kosowski, R. (2020). "Dispersion Trading Based on the Explanatory Power of S&P 500 Stock Returns." *Mathematics*, 8(9), 1627.

## Implementation Notes

- **Data Requirements**: Real-time options chains for the index and all constituent stocks. Implied volatility surfaces, Greeks (delta, vega, gamma) for daily hedging. Historical implied and realized correlation time series.
- **Transaction Costs**: This is a cost-intensive strategy. Managing 50-100 individual stock option positions plus the index leg generates substantial commissions and bid-ask spread costs. Variance swaps (OTC) reduce the number of legs but introduce counterparty risk. Implementation on the S&P 100 (OEX) rather than S&P 500 reduces the number of legs while retaining most of the signal.
- **Margin Requirements**: Running short straddles on 50+ names requires significant margin. Portfolio margining (SPAN or similar) substantially reduces requirements by recognizing the hedged nature of the position.
- **Correlation Regime Monitoring**: The single most important risk management tool is real-time monitoring of realized correlation. When 20-day realized correlation among SPX constituents rises above 0.7, the risk of a losing month increases substantially. Consider reducing position size or closing early.
- **Simplified Implementation**: For smaller accounts, a practical approximation uses sector ETF options as the long leg rather than individual stock options, reducing the number of positions from 50-100 to 10-11 (GICS sectors). This captures most of the dispersion effect with far fewer legs.
