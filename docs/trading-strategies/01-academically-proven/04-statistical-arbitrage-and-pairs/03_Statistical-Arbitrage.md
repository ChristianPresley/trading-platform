# Statistical Arbitrage (Multi-Factor)

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 3, [Avellaneda & Lee (2010)](https://jeremywhittaker.com/wp-content/uploads/2021/03/AvellanedaLeeStatArb071108.pdf)
> **Asset Class**: Equities (primarily), extensible to other liquid asset classes
> **Crypto/24-7 Applicable**: Adaptable — factor-based mean reversion documented in crypto cross-sections, though factor stability is weaker and data history is shorter
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

Statistical arbitrage (stat arb) is a broad class of quantitative, market-neutral strategies that exploit temporary mispricings identified through statistical models applied across large cross-sections of securities. Unlike simple pairs trading, stat arb operates on portfolios of hundreds to thousands of positions simultaneously, using multi-factor models to decompose returns into systematic and idiosyncratic components, then trading the idiosyncratic residuals when they deviate from model-implied fair values.

The canonical implementation follows Avellaneda and Lee (2010): estimate a factor model (PCA-based or fundamental) on a universe of equities, compute the residual return for each stock after removing factor exposures, model the residual as a mean-reverting Ornstein-Uhlenbeck process, and trade stocks whose residuals have deviated significantly from zero. The portfolio is constructed to be neutral to all identified factors, isolating pure idiosyncratic mean reversion.

Modern stat arb has evolved well beyond simple mean reversion. Contemporary implementations incorporate momentum signals, fundamental factors (earnings revisions, analyst recommendations), event-driven signals (earnings surprises, index rebalancing), and alternative data (sentiment, satellite imagery, web traffic). The common thread is systematic, model-driven position construction with factor-neutral portfolio constraints.

## Trading Rules

1. **Universe**: All liquid equities in the target market (typically S&P 500 or Russell 1000 for US). Minimum average daily volume of $5M. Exclude recent IPOs (< 6 months of trading history).

2. **Factor Model Estimation**:
   - Estimate a k-factor model using PCA on the trailing 252-day return covariance matrix, retaining factors explaining ~60-70% of cross-sectional variance (typically k = 15-20 for US equities).
   - Alternatively, use fundamental risk factors (market, size, value, momentum, quality, low-vol) from models like Barra or Axioma.

3. **Residual Calculation**:
   - For each stock, compute the residual return: `e_i(t) = r_i(t) - sum(beta_ij * F_j(t))` where F_j are factor returns.
   - Accumulate residuals into a cumulative residual series (the "s-score" in Avellaneda-Lee terminology).

4. **Signal Generation**:
   - Fit an Ornstein-Uhlenbeck process to each stock's cumulative residual: `ds = kappa * (m - s) * dt + sigma * dW`
   - Compute the s-score: `s-score = (s - m) / sigma_eq` where sigma_eq = sigma / sqrt(2 * kappa)
   - Generate signals when |s-score| > 1.25 (entry), close when |s-score| < 0.5 (exit).

5. **Portfolio Construction**:
   - Long stocks with s-score < -1.25 (undervalued residuals), short stocks with s-score > +1.25 (overvalued residuals).
   - Apply factor-neutrality constraints: portfolio beta to each PCA factor must be within +/- 0.05.
   - Apply sector-neutrality: net exposure per sector within +/- 2% of total GMV.
   - Position size inversely proportional to residual volatility (risk parity within the portfolio).

6. **Risk Limits**: Gross market value (GMV) leverage of 4-8x. Net market exposure within +/- 5%. Single-position limit of 2% of GMV.

7. **Holding Period**: Average holding period of 1-15 days depending on mean-reversion speed (kappa).

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 1.0-1.5+ (before costs), 0.5-1.0 (after costs) |
| CAGR | 8-15% (varies by leverage and period) |
| Max Drawdown | -10% to -25% (strategy dependent) |
| Win Rate | 52-58% |
| Volatility | 5-12% annualized |
| Profit Factor | 1.3-1.8 |
| Rebalancing | Daily |

Reported Sharpe ratios vary widely with implementation quality, leverage, and market regime. Avellaneda and Lee reported a PCA-based strategy with an average annual Sharpe of 1.44 over 1997-2007 after transaction costs. More recent implementations show lower but still positive Sharpe ratios as the strategy space has become more crowded. The August 2007 quant crisis demonstrated that crowded stat arb positions can experience correlated drawdowns far exceeding historical norms.

## Efficacy Rating

**Rating: 4/5** — Statistical arbitrage is the workhorse strategy of quantitative hedge funds, with decades of live trading evidence and deep academic foundations. The deduction reflects the strategy's sensitivity to crowding risk (August 2007 quant crisis), the significant infrastructure requirements (data, execution, risk systems), ongoing performance decay as more capital competes for the same signals, and the complexity of maintaining factor-neutral portfolios in real time.

## Academic References

- Avellaneda, M., & Lee, J.-H. (2010). "Statistical Arbitrage in the U.S. Equities Market." *Quantitative Finance*, 10(7), 761-782.
- Pole, A. (2007). *Statistical Arbitrage: Algorithmic Trading Insights and Techniques*. John Wiley & Sons.
- Khandani, A. E., & Lo, A. W. (2011). "What Happened to the Quants in August 2007? Evidence from Factors and Transactions Data." *Journal of Financial Markets*, 14(1), 1-46.
- Kakushadze, Z. (2015). "151 Trading Strategies." Working Paper. Available at SSRN.
- Montana, G., Triantafyllopoulos, K., & Tsagaris, T. (2009). "Flexible Least Squares for Temporal Data Mining and Statistical Arbitrage." *Expert Systems with Applications*, 36(2), 2819-2830.

## Implementation Notes

- **Data Requirements**: Daily or intraday price data for 500+ securities. Fundamental data (earnings, analyst estimates) for hybrid models. Minimum 1-2 years of history for factor estimation. Real-time data essential for daily rebalancing.
- **Infrastructure**: Stat arb requires a complete quantitative trading stack: data pipeline, factor model estimation, portfolio optimizer with linear constraints, order management system, real-time risk monitoring, and transaction cost analysis. This is not a strategy that can be run from a spreadsheet.
- **Transaction Costs**: High turnover (200-500% annualized per side) makes execution quality critical. Transaction cost models must account for market impact, which is non-linear in position size. Optimal execution algorithms (VWAP, TWAP, arrival price) are essential.
- **Capacity Constraints**: Individual stat arb strategies typically have capacity limits of $500M-$5B before market impact erodes returns. Larger allocations require diversification across universes (international), factors, or holding periods.
- **Crypto Adaptation**: Cross-sectional mean reversion has been documented in crypto markets, though the smaller universe (~50-100 liquid tokens) limits diversification. Factor models for crypto are less mature — common factors include market beta, size, momentum, and liquidity. The 24/7 market and higher volatility may provide more frequent signals but also higher noise.
