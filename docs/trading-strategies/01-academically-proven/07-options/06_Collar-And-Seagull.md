# Collar and Seagull

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 2
> **Asset Class**: Equities / Multi-Asset (any asset with listed options)
> **Crypto/24-7 Applicable**: Adaptable — collars are constructable on Deribit for BTC and ETH holdings; seagull structures require sufficient strike granularity which is available for major crypto assets
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

The collar and seagull are protective option structures designed to limit downside risk on an existing long position while managing the cost of protection. Both strategies build on the protective put concept (Strategy 01) by adding sold options to offset the cost of the purchased protection.

A **collar** (also called a fence or risk reversal when applied to an existing position) combines a long position in the underlying with a purchased OTM put (downside protection) and a sold OTM call (to finance the put). The result is a bounded payoff: downside is limited at the put strike, upside is capped at the call strike, and the net cost can be zero or near-zero if the strikes are chosen so that the call premium received equals the put premium paid (a "zero-cost collar"). The collar is equivalent to a bull vertical spread (by put-call parity), making it one of the most capital-efficient hedging structures available.

A **seagull** extends the collar concept by adding a third leg — typically selling a further OTM put below the protective put, creating a three-legged structure. This reduces the cost of protection further (or generates a net credit) by accepting some downside exposure below the second put strike. The seagull combines a collar with a short put spread on the downside, creating a payoff that provides protection within a defined range but exposes the holder to losses below the sold put strike. The structure is popular in currency hedging and commodity risk management, where the cost of full protection is prohibitive.

## Trading Rules

1. **Zero-Cost Collar**:
   - **Hold** the underlying asset (100 shares per contract).
   - **Buy** an OTM put (e.g., 5-10% below current price, delta -0.25 to -0.35).
   - **Sell** an OTM call with premium approximately equal to the put cost (e.g., 5-10% above current price, delta 0.25-0.35).
   - Same expiration for both options: 60-90 DTE for efficient cost.
   - Net cost: approximately zero (adjust strikes to equalize premiums).
   - Roll both options at or before expiration to maintain continuous protection.

2. **Collar with Net Credit** (asymmetric, income-oriented):
   - Sell the call closer to ATM than the put (e.g., 5% OTM call, 10% OTM put).
   - Generates net credit but caps upside more aggressively.
   - Suitable when the investor is willing to sacrifice upside for premium income plus downside protection.

3. **Seagull** (cost-reduced protection):
   - **Hold** the underlying.
   - **Buy** an OTM put at strike K1 (e.g., 5% below current price).
   - **Sell** an OTM call at strike K3 (e.g., 8% above current price).
   - **Sell** a further OTM put at strike K0 (e.g., 12% below current price).
   - The sold put finances the protective put but introduces downside exposure below K0.
   - Net cost: zero or small credit (three-way structure).
   - Protection range: between K0 and K1, losses are capped. Below K0, losses resume.

4. **Strike Selection**:
   - Collar: choose strikes where the underlying has a 70-80% probability of remaining between them at expiration (based on implied volatility).
   - Seagull: sold put should be placed at a level where the holder accepts the tail risk (e.g., below a key support level).

5. **Expiration**: 60-120 DTE for cost efficiency. Quarterly rolling is common for institutional programs.

6. **Risk Management**: Monitor delta and adjust if the underlying moves significantly toward either strike. For seagulls, track the risk below the sold put and be prepared to close if approaching that level.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.4-0.6 (collar on equity indices) |
| CAGR | 6-9% (collared S&P 500, varying by strike selection) |
| Max Drawdown | -10% to -20% (vs. -35% to -50% for unhedged equity) |
| Win Rate | 60-70% (annual, total return basis) |
| Volatility | 8-12% (vs. 15% for unhedged equity) |
| Profit Factor | 1.3-1.8 |
| Rebalancing | Quarterly (option rolling) |

The collar reduces portfolio volatility by 30-50% and maximum drawdown by 40-60% relative to an unhedged position, at the cost of capping upside returns. The zero-cost collar achieves this with no out-of-pocket premium cost. The seagull further reduces the hedging cost but introduces gap risk below the sold put, making it less effective during severe market crashes.

## Efficacy Rating

**Rating: 4/5** — The collar is one of the most practical and widely used hedging strategies, employed by institutions, corporate treasuries, and individual investors to protect concentrated positions and portfolios. The zero-cost feature makes it particularly attractive, and the strategy's performance during market downturns is well-documented. The seagull adds flexibility for cost management. The deduction reflects the significant upside sacrifice (which can create meaningful opportunity cost in bull markets), the complexity of managing three-legged seagull structures, and the seagull's reintroduction of tail risk through the sold put.

## Academic References

- Israelov, R., & Klein, M. (2016). "Risk and Return of Equity Index Collar Strategies." *The Journal of Alternative Investments*, 19(1), 41-52.
- Hull, J. C. (2018). *Options, Futures, and Other Derivatives*. 10th Edition, Pearson.
- Shan, Y., & Yang, D. (2012). "Equity Collars as Hedging Instruments." *Journal of Investment Management*, 10(3), 5-24.
- Szado, E., & Schneeweis, T. (2010). "Loosening Your Collar: Alternative Implementations of QQQ Collars." *The Journal of Trading*, 5(2), 35-56.
- McMillan, L. G. (2012). *Options as a Strategic Investment*. 5th Edition, Prentice Hall.

## Implementation Notes

- **Data Requirements**: Options chain data with sufficient strike granularity for the underlying. Implied volatility skew data to evaluate the relative cost of OTM puts vs. OTM calls.
- **Skew Advantage**: Equity index options typically exhibit negative skew (OTM puts are more expensive than equidistant OTM calls). This means a symmetric zero-cost collar will have the call strike closer to ATM than the put strike, creating an asymmetric payoff that slightly favors the upside. In low-skew environments, the collar becomes more symmetric.
- **Rolling Strategy**: When rolling collars, evaluate whether to maintain the same moneyness or adjust based on the new price level. "Rolling up" both strikes after a rally locks in gains; "rolling down" after a decline resets protection at a lower level.
- **Tax Implications**: Collars on individual stock positions can trigger complex tax treatment (constructive sale rules in the US if the collar is too tight). Consult tax guidance when the put and call strikes are close to the current stock price.
- **Crypto Adaptation**: Collars on BTC/ETH positions protect against the large drawdowns characteristic of crypto markets (50-80% peak-to-trough). The high implied volatility in crypto means OTM puts are expensive — the zero-cost collar will require selling a relatively close OTM call, significantly capping upside. A seagull structure may be more appropriate for crypto, accepting tail risk below a distant put strike in exchange for retaining more upside. Deribit provides sufficient strike granularity for monthly expirations on BTC and ETH.
- **Concentrated Position Hedging**: The collar is the standard institutional tool for hedging concentrated stock positions (e.g., executive equity compensation). The structure provides auditable risk limits while maintaining long exposure, making it suitable for regulatory and compliance purposes.
