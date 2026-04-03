# Synthetic Positions

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 2
> **Asset Class**: Equities / Multi-Asset (any asset with listed options)
> **Crypto/24-7 Applicable**: Adaptable — synthetic long and short positions are constructable on Deribit for BTC and ETH, providing leveraged directional exposure without the need to hold the underlying asset
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

Synthetic positions use options to replicate the risk-return profile of an underlying asset (or a short position in it) without actually holding the asset. The theoretical foundation is put-call parity, one of the most fundamental relationships in option pricing theory, which establishes that a long call and a short put at the same strike and expiration produce an identical payoff to holding the underlying asset (adjusted for the present value of the strike and dividends).

A **synthetic long stock** is constructed by buying a call and selling a put at the same strike and expiration. The position replicates the P&L of owning 100 shares of the underlying — it profits dollar-for-dollar when the price rises and loses dollar-for-dollar when it falls. A **synthetic short stock** is the mirror image: buy a put and sell a call at the same strike. The key advantages of synthetic positions over direct stock ownership are: (1) significantly lower capital requirements (margin on the short option rather than the full stock price), (2) no need to borrow shares for short exposure, and (3) the ability to express directional views in markets where direct access to the underlying is restricted.

Synthetic positions are also the building blocks of more complex strategies. Every option strategy can be decomposed into synthetic positions and offsets. A covered call is equivalent to a short put. A protective put is equivalent to a long call. Understanding these equivalences is essential for identifying relative value opportunities when the same economic exposure can be obtained more cheaply through an alternative construction.

## Trading Rules

1. **Synthetic Long Stock**:
   - **Buy** a call option at strike K.
   - **Sell** a put option at strike K with the same expiration.
   - Net cost: approximately zero if options are ATM (the call premium paid roughly equals the put premium received, adjusted for the risk-free rate and dividends).
   - The position's delta is approximately +1.0, replicating 100 shares.
   - Margin requirement: the short put margin, substantially less than buying 100 shares outright.

2. **Synthetic Short Stock**:
   - **Buy** a put option at strike K.
   - **Sell** a call option at strike K with the same expiration.
   - Net cost: approximately zero for ATM options.
   - The position's delta is approximately -1.0, replicating a short sale of 100 shares.
   - Advantage: no need to locate and borrow shares, no short-sale restrictions, no uptick rule.

3. **Strike and Expiration Selection**:
   - Use ATM strikes for the closest replication of the underlying. The synthetic tracks the stock nearly identically when the strike equals the current forward price.
   - Longer expirations (60-180 DTE or LEAPS) reduce rolling frequency but widen the bid-ask spread and increase vega sensitivity.
   - Shorter expirations (30-45 DTE) have tighter spreads but require more frequent rolling.

4. **Rolling**: As expiration approaches, close the existing synthetic and open a new one at the current ATM strike for the next expiration cycle. Rolling is necessary because options expire — the synthetic position is time-limited unlike a direct stock position.

5. **Dividend and Interest Rate Adjustments**: Synthetic positions do not receive dividends (a cost for synthetic longs, a benefit for synthetic shorts). The risk-free rate is embedded in the forward price, so the synthetic long will be slightly cheaper than the stock price (reflecting the financing advantage), while the synthetic short will receive this implicit interest.

6. **Risk Management**: Treat the synthetic identically to the equivalent stock position for position sizing and portfolio risk management. Monitor margin requirements on the short option leg, which can increase during volatile markets.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | Equivalent to underlying (minus transaction costs) |
| CAGR | Equivalent to underlying (minus dividends, plus interest savings) |
| Max Drawdown | Equivalent to underlying |
| Win Rate | Equivalent to underlying |
| Volatility | Equivalent to underlying |
| Profit Factor | Equivalent to underlying |
| Rebalancing | Monthly to quarterly (rolling) |

Synthetic positions are replication tools, not alpha-generating strategies. Their performance tracks the underlying asset with deviations arising from: (1) foregone dividends, (2) bid-ask spreads on two option legs per roll, (3) the embedded financing rate, and (4) the occasional mispricing between options and the underlying that creates put-call parity arbitrage opportunities. In practice, the tracking error is small (< 1% annually for liquid underlyings) but nonzero.

## Efficacy Rating

**Rating: 4/5** — Synthetic positions are a fundamental building block of options theory and practice, grounded in the mathematically rigorous put-call parity relationship. They provide capital-efficient directional exposure and enable short selling in restricted markets. The deduction reflects the practical limitations: transaction costs from two-legged option executions and periodic rolling, the foregone dividend stream, time sensitivity (options expire, requiring active management), and the margin risk on the short option leg during volatile markets. These are replication tools rather than alpha sources.

## Academic References

- Stoll, H. R. (1969). "The Relationship Between Put and Call Option Prices." *The Journal of Finance*, 24(5), 801-824.
- Black, F., & Scholes, M. (1973). "The Pricing of Options and Corporate Liabilities." *Journal of Political Economy*, 81(3), 637-654.
- Merton, R. C. (1973). "Theory of Rational Option Pricing." *Bell Journal of Economics and Management Science*, 4(1), 141-183.
- Ofek, E., Richardson, M., & Whitelaw, R. F. (2004). "Limited Arbitrage and Short Sales Restrictions: Evidence from the Options Markets." *Journal of Financial Economics*, 74(2), 305-342.
- Lamont, O. A., & Thaler, R. H. (2003). "Can the Market Add and Subtract? Mispricing in Tech Stock Carve-outs." *Journal of Political Economy*, 111(2), 227-268.
- Hull, J. C. (2018). *Options, Futures, and Other Derivatives*. 10th Edition, Pearson, Ch. 11.

## Implementation Notes

- **Data Requirements**: Real-time options chain data with bid-ask quotes at multiple strikes. Forward price calculations (spot price + cost of carry - dividend present value) to identify the correct ATM strike for the synthetic.
- **Put-Call Parity Monitoring**: Deviations from put-call parity create arbitrage opportunities. If the synthetic long (long call + short put) is cheaper than the stock, buy the synthetic and sell the stock. If the synthetic is more expensive, buy the stock and sell the synthetic. These mispricings are typically small (< 10 cents) and fleeting in liquid markets, but they can be larger in crypto and less-liquid equity options.
- **Capital Efficiency**: A synthetic long on a $100 stock might require $15-20 in margin for the short put (under Reg-T) vs. $100 to buy the stock outright. Under portfolio margin, the requirement can be as low as $8-12. This 5-8x capital efficiency improvement is the primary motivation for using synthetics.
- **Short Sale Alternative**: The synthetic short is particularly valuable when shares are hard to borrow (high short interest, small float, or restricted from short selling). It provides identical economic exposure without locating shares. However, regulators have restricted synthetic shorts in some jurisdictions during market stress (e.g., short-selling bans during the 2008 crisis often extended to synthetic positions).
- **Crypto Adaptation**: Synthetic long and short positions on BTC and ETH via Deribit options provide leveraged directional exposure without holding the underlying on-exchange or posting full collateral. This is valuable for institutional traders who want crypto exposure through a derivatives-native structure. The higher implied volatility in crypto means the net cost of the synthetic may deviate more from zero than in equity markets, reflecting skew and the volatility risk premium. European-style options on Deribit eliminate early assignment risk.
- **Early Assignment Risk**: For American-style equity options, the short put in a synthetic long can be assigned early (particularly if the stock drops significantly or approaches an ex-dividend date). This is generally a minor nuisance (you receive the stock at the strike price, which is what the synthetic was replicating anyway) but should be monitored for portfolio and margin management.
