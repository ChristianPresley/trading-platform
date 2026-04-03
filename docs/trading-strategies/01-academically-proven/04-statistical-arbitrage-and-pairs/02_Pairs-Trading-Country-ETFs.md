# Pairs Trading — Country ETFs

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading-strategies), [Quantpedia — Pairs Trading with Country ETFs](https://quantpedia.com/strategies/pairs-trading-with-country-etfs)
> **Asset Class**: Equities (International ETFs)
> **Crypto/24-7 Applicable**: No — strategy is specific to country-level equity index ETFs with distinct trading hours and macroeconomic drivers
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

This strategy applies the cointegration-based pairs trading framework to country-level equity ETFs rather than individual stocks. The economic rationale is that countries with similar economic structures, trade linkages, or geographic proximity should exhibit correlated equity market returns. When the spread between two cointegrated country ETFs diverges significantly from its historical equilibrium, the strategy bets on convergence.

Country ETFs offer several advantages over single-stock pairs: they are less susceptible to idiosyncratic corporate events (earnings surprises, M&A), they have deep liquidity with tight bid-ask spreads, and they provide exposure to macro-level mean reversion that operates on a more persistent timescale. However, the smaller universe of tradeable country ETFs (typically 30-50 liquid instruments) limits the number of viable pairs, and macroeconomic regime shifts can cause permanent relationship breakdowns.

The strategy is typically implemented using iShares MSCI country ETFs (e.g., EWJ for Japan, EWG for Germany, EWA for Australia) or similar products. Pair selection relies on both statistical tests (cointegration) and economic logic (similar GDP composition, trade relationships, regional proximity).

## Trading Rules

1. **Universe**: Liquid country equity ETFs with at least $500M in AUM and 5 years of price history. Typical universe includes 25-40 ETFs (iShares MSCI series, SPDR country ETFs).

2. **Pair Formation** (12-month formation period):
   - Test all possible pairs for cointegration using the Engle-Granger two-step method or Johansen trace test.
   - Filter pairs by economic rationale: prefer pairs within the same geographic region (Europe-Europe, Asia-Asia) or with similar sector compositions.
   - Select the top 5-15 pairs ranked by cointegration strength (lowest p-value on ADF test of residuals).

3. **Spread Construction**:
   - Compute the spread using the cointegrating regression: `Spread = log(ETF_A) - beta * log(ETF_B) - alpha`
   - Standardize to z-score using rolling 60-day mean and standard deviation.

4. **Entry Signal**: Open when z-score exceeds +/- 2.0 standard deviations:
   - Z > +2.0: Short ETF A, Long ETF B.
   - Z < -2.0: Long ETF A, Short ETF B.

5. **Exit Signal**: Close when z-score reverts to within +/- 0.25 of zero, or after a maximum holding period of 3 months.

6. **Stop-Loss**: Close if z-score reaches +/- 3.5, suggesting structural break.

7. **Position Sizing**: Equal notional on each leg. Allocate across 5-10 active pairs.

8. **Rebalancing**: Reform pairs every 6 months. Run monthly cointegration stability checks.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.257 |
| CAGR | 3-5% (excess, self-financing) |
| Max Drawdown | -12% to -18% |
| Win Rate | 50-55% |
| Volatility | 5.7% annualized |
| Profit Factor | 1.1-1.3 |
| Rebalancing | Daily (monitoring), Semi-annual (pair reformation) |

The modest Sharpe ratio of 0.257 reflects the limited number of tradeable pairs in the country ETF universe and the slower convergence dynamics of macro-level spreads compared to single-stock pairs. Volatility is low at 5.7% due to the diversification inherent in country indices and the market-neutral construction. The strategy's value lies more in portfolio diversification than standalone returns.

## Efficacy Rating

**Rating: 3/5** — The strategy is conceptually sound and supported by academic evidence, but its practical application is constrained by a small universe of liquid country ETFs, lower signal frequency, and vulnerability to macroeconomic regime shifts (e.g., Brexit permanently altered UK-EU equity relationships). The moderate Sharpe and low absolute returns make it most useful as a diversifying allocation within a broader multi-strategy portfolio rather than a standalone approach.

## Academic References

- Galenko, A., Popova, E., & Popova, I. (2012). "Trading in the Presence of Cointegration." *Journal of Alternative Investments*, 15(1), 85-97.
- Huck, N., & Afawubo, K. (2015). "Pairs Trading and Selection Methods: Is Cointegration Superior?" *Applied Economics*, 47(6), 599-613.
- Bock, M., & Mestel, R. (2009). "A Regime-Switching Relative Value Arbitrage Rule." *Operations Research Proceedings 2008*, Springer, 9-14.
- Jacobs, H., & Weber, M. (2015). "On the Determinants of Pairs Trading Profitability." *Journal of Financial Markets*, 23, 75-97.

## Implementation Notes

- **Data Requirements**: Daily closing prices for country ETFs, adjusted for dividends and currency effects. Consider using currency-hedged ETF variants or explicitly hedging FX exposure, as currency movements can dominate the spread dynamics.
- **Currency Risk**: A major source of noise in country ETF pairs. Two approaches: (a) use currency-hedged ETFs when available, or (b) add an FX hedge leg to the trade. Unhedged implementation introduces currency risk that can overwhelm the equity convergence signal.
- **Time Zone Effects**: Country ETFs trade on US exchanges but track foreign markets that close at different times. Stale pricing creates artificial spread movements at the open. Use adjusted close prices and avoid trading at the US open.
- **Macro Event Risk**: Central bank decisions, elections, and trade policy changes can permanently shift country equity valuations. Monitor for known catalysts and consider reducing exposure ahead of major scheduled events.
- **Universe Expansion**: The strategy benefits from a larger universe. Consider supplementing iShares MSCI ETFs with regional ETFs (e.g., VGK for Europe, AAXJ for Asia ex-Japan) and frontier market ETFs to increase the number of testable pairs.
