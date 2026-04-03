# Covered Call and Protective Put

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 2
> **Asset Class**: Equities / Multi-Asset (any asset with listed options)
> **Crypto/24-7 Applicable**: Adaptable — covered calls and protective puts are available on BTC and ETH via Deribit, OKX, and Bybit options markets; crypto's higher implied volatility makes premium collection particularly attractive
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

The covered call and protective put are the two foundational option overlay strategies, representing the simplest applications of options for income generation and portfolio hedging, respectively. Both strategies modify the risk-return profile of an existing long position in the underlying asset.

A **covered call** (buy-write) involves holding a long position in the underlying and selling a call option against it. The sold call generates premium income in exchange for capping the upside at the strike price. The strategy is equivalent to a short put (by put-call parity), providing a slightly cushioned downside with limited upside. The CBOE BuyWrite Index (BXM), which tracks a systematic ATM covered call strategy on the S&P 500, has delivered an annualized return of 8.5% with 10.7% volatility and a Sharpe ratio of 0.54 since 1986 — comparable risk-adjusted performance to the S&P 500 (11.1% return, 15.2% volatility, Sharpe 0.56) but with approximately 30% less volatility and a significantly shallower maximum drawdown (-35.8% vs. -50.9%).

A **protective put** involves holding a long position and buying a put option as insurance against downside moves. This strategy preserves full upside participation (minus the put premium) while truncating losses at the strike price. The strategy is equivalent to a long call (by put-call parity). The cost of protection is the put premium, which typically reduces annual returns by 2-5% depending on strike selection and market volatility. Dynamic covered call strategies that vary strike selection based on implied volatility have shown Sharpe ratios of 0.85-0.93, outperforming static ATM approaches.

## Trading Rules

1. **Covered Call**:
   - **Underlying**: Hold 100 shares (or equivalent delta exposure) of the underlying asset per option contract.
   - **Strike Selection**: Sell a call option 1-2 standard deviations OTM (typically 5-10% above current price) for growth-oriented strategies, or ATM for maximum income.
   - **Expiration**: 30-45 days to expiration (DTE) to maximize theta decay in the steepest part of the time decay curve.
   - **Rolling**: If the option approaches expiration worthless, sell a new call for the next cycle. If the underlying approaches the strike, either let assignment occur or roll up and out (buy back the current call, sell a higher-strike, later-expiration call).
   - **Delta Target**: Sell calls with delta of 0.20-0.30 for growth bias, 0.40-0.50 for income maximization.

2. **Protective Put**:
   - **Underlying**: Hold 100 shares per put contract.
   - **Strike Selection**: Buy a put option 5-15% below current price (OTM) to balance cost against protection level.
   - **Expiration**: 60-90 DTE or longer to reduce the annualized cost of protection (longer-dated puts have lower daily theta).
   - **Rolling**: Roll the put forward before expiration to maintain continuous protection.
   - **Cost Management**: Finance the put purchase by selling OTM calls (creating a collar — see Strategy 06).

3. **Rebalancing**: Roll options at or before expiration. Adjust strikes based on changes in the underlying price and implied volatility.

4. **Risk Management**: For covered calls, maintain willingness to have shares called away at the strike price. For protective puts, set a maximum annual budget for protection costs (e.g., 3% of portfolio value).

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.54 (BXM ATM), 0.85-0.93 (dynamic covered call) |
| CAGR | 8.5% (BXM), 10-14% (OTM covered call on S&P 500) |
| Max Drawdown | -35.8% (BXM vs. -50.9% S&P 500) |
| Win Rate | 65-75% (covered call monthly), 25-35% (protective put payoff) |
| Volatility | 10.7% (BXM vs. 15.2% S&P 500) |
| Profit Factor | 1.5-2.0 (covered call), < 1.0 standalone (protective put) |
| Rebalancing | Monthly (option rolling) |

The covered call consistently reduces portfolio volatility by 25-35% relative to the underlying, at the cost of capping upside. The protective put is not designed to be profitable on its own — it is an insurance cost that reduces maximum drawdown. The BXM index data (through December 2025) shows the covered call strategy achieves similar risk-adjusted returns to buy-and-hold with substantially lower volatility and shallower drawdowns.

## Efficacy Rating

**Rating: 5/5** — The covered call and protective put are the most fundamental and widely used options strategies, supported by decades of live index performance data (BXM since 1986), extensive academic research, and universal institutional adoption. The covered call's persistent ability to deliver equity-like risk-adjusted returns with lower volatility is one of the most robust findings in options research. The protective put provides a mathematically precise hedging tool. The perfect rating reflects the strategies' simplicity, transparency, liquidity, and the depth of empirical evidence supporting their effectiveness.

## Academic References

- Whaley, R. E. (2002). "Return and Risk of CBOE BuyWrite Monthly Index." *The Journal of Derivatives*, 10(2), 35-42.
- Ibbotson Associates (2004). "Case Study on BXM Buy-Write Options Strategy." *CBOE Research*.
- Feldman, B. E., & Roy, D. (2005). "Passive Options-Based Investment Strategies: The Case of the CBOE S&P 500 BuyWrite Index." *The Journal of Investing*, 14(2), 66-76.
- Merton, R. C., Scholes, M. S., & Gladstein, M. L. (1978). "The Returns and Risk of Alternative Call Option Portfolio Investment Strategies." *The Journal of Business*, 51(2), 183-242.
- Black, F., & Scholes, M. (1973). "The Pricing of Options and Corporate Liabilities." *Journal of Political Economy*, 81(3), 637-654.
- Israelov, R., & Klein, M. (2016). "Risk and Return of Equity Index Collar Strategies." *The Journal of Alternative Investments*, 19(1), 41-52.

## Implementation Notes

- **Data Requirements**: Real-time or delayed options chain data (strikes, expirations, bid-ask, implied volatility, Greeks) for the underlying. Historical implied volatility data for strike selection optimization.
- **Strike Selection Optimization**: The optimal strike depends on the investor's objective. ATM covered calls maximize income but cap more upside; 5-10% OTM covered calls sacrifice some premium for higher upside participation. Dynamic strategies that adjust strike based on IV rank (sell closer to ATM when IV is high, further OTM when IV is low) achieve the best Sharpe ratios.
- **Transaction Costs**: Options bid-ask spreads on liquid underlyings (SPY, QQQ, major stocks) are typically 1-5 cents. Monthly rolling creates 12+ round-trip transactions per year, so spread costs are material. Use limit orders at the mid-price.
- **Crypto Adaptation**: Deribit offers European-style BTC and ETH options with sufficient liquidity for covered call strategies. Crypto implied volatility (60-100%+) is substantially higher than equities, generating larger premiums but also larger potential assignment losses. The 24/7 market means theta decay is continuous, and options can be rolled at any time. Strike selection should be wider (10-20% OTM) to account for crypto's higher realized volatility.
- **Tax Implications**: Covered calls can create complex tax situations (short-term gains on premium, potential loss of long-term capital gains treatment on underlying). Consult tax guidance for jurisdiction-specific treatment.
- **Assignment Risk**: American-style options can be assigned early, particularly near ex-dividend dates. This is a minor nuisance rather than a material risk but should be monitored.
