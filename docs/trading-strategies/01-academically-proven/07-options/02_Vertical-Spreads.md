# Vertical Spreads (Bull/Bear Call/Put Spreads)

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 2
> **Asset Class**: Equities / Multi-Asset (any asset with listed options)
> **Crypto/24-7 Applicable**: Adaptable — vertical spreads are available on Deribit and other crypto derivatives exchanges for BTC and ETH; wider strikes recommended due to higher crypto volatility
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

Vertical spreads are directional options strategies that combine two options of the same type (both calls or both puts), same expiration date, but different strike prices. The four canonical vertical spreads — bull call spread, bear call spread, bull put spread, and bear put spread — provide defined-risk, defined-reward exposure to directional price moves with lower capital requirements and more precise risk management than outright option purchases or sales.

The term "vertical" refers to the strike price axis on an options chain, distinguishing these from calendar (horizontal) and diagonal spreads. Vertical spreads reduce the cost of directional option positions by sacrificing some profit potential, and they reduce the margin requirement of short option positions by capping the maximum loss. The bull put spread (selling a higher-strike put and buying a lower-strike put) is the most commonly backtested credit spread strategy, with research showing win rates of 80-93% on indices when strikes are placed 5-6% out-of-the-money with 30-45 day expirations.

From a theoretical perspective, vertical spreads represent a position on the probability distribution of the underlying's price at expiration. A bull put spread profits if the underlying stays above the short strike — the trader is selling a bet that the underlying will fall below a specific level. The spread's P&L is bounded between the net credit received (maximum profit) and the width of the strikes minus the credit (maximum loss), creating a binary-like payoff at expiration.

## Trading Rules

1. **Bull Call Spread** (debit spread, moderately bullish):
   - **Buy** a call at a lower strike (typically ATM or slightly ITM).
   - **Sell** a call at a higher strike (OTM).
   - Same expiration for both legs.
   - Maximum profit: (strike width - net debit paid). Maximum loss: net debit paid.
   - Optimal when expecting moderate upside with declining implied volatility.

2. **Bear Put Spread** (debit spread, moderately bearish):
   - **Buy** a put at a higher strike (ATM or slightly ITM).
   - **Sell** a put at a lower strike (OTM).
   - Maximum profit: (strike width - net debit paid). Maximum loss: net debit paid.

3. **Bull Put Spread** (credit spread, neutral to bullish):
   - **Sell** a put at a higher strike (OTM).
   - **Buy** a put at a lower strike (further OTM).
   - Maximum profit: net credit received. Maximum loss: (strike width - net credit).
   - Win rate historically 80-93% on indices with 5-6% OTM strikes at 30-45 DTE.

4. **Bear Call Spread** (credit spread, neutral to bearish):
   - **Sell** a call at a lower strike (OTM).
   - **Buy** a call at a higher strike (further OTM).
   - Maximum profit: net credit received. Maximum loss: (strike width - net credit).

5. **Strike Selection**:
   - Credit spreads: short strike at 1-2 standard deviations OTM (delta 0.15-0.30). Strike width of $2-$5 for stocks, $5-$25 for indices.
   - Debit spreads: long strike ATM or slightly ITM, short strike 3-5% OTM.

6. **Expiration**: 30-45 DTE for credit spreads (theta decay acceleration). 45-60 DTE for debit spreads (more time for directional move).

7. **Risk Management**: Maximum position size = 2-5% of portfolio per spread. Close credit spreads at 50% of maximum profit to reduce gamma risk near expiration. Close at 200% of credit received as stop-loss.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.4-0.8 (credit spreads on indices, managed) |
| CAGR | 10-25% (on capital at risk, varies by management) |
| Max Drawdown | -15% to -30% (of capital at risk) |
| Win Rate | 80-93% (credit spreads, 5-6% OTM, 30-45 DTE) |
| Volatility | 10-20% (annualized, on capital at risk) |
| Profit Factor | 1.5-2.5 (with profit target management) |
| Rebalancing | Monthly (new spread at each expiration cycle) |

Credit spreads have high win rates but asymmetric payoffs — individual trades profit small amounts most of the time but lose larger amounts occasionally. Introducing profit targets (close at 50% of max profit) and stop-losses (close at 2x credit received) dramatically lowers volatility and shrinks maximum losses, improving the Sharpe ratio significantly relative to holding to expiration. Backtests on SPY show that active management rules convert a marginally profitable hold-to-expiration strategy into a consistently profitable managed approach.

## Efficacy Rating

**Rating: 5/5** — Vertical spreads are among the most fundamental and widely used options strategies, offering defined risk, capital efficiency, and flexibility to express directional views with precision. The theoretical foundation (option pricing theory, put-call parity) is rock-solid, and extensive backtesting confirms their effectiveness when managed with disciplined profit targets and stop-losses. The perfect rating reflects the strategies' universal applicability, simplicity, liquidity, and the depth of both academic theory and empirical evidence supporting their use.

## Academic References

- Hull, J. C. (2018). *Options, Futures, and Other Derivatives*. 10th Edition, Pearson, Ch. 12.
- Natenberg, S. (1994). *Option Volatility and Pricing*. McGraw-Hill.
- Merton, R. C., Scholes, M. S., & Gladstein, M. L. (1982). "The Returns and Risks of Alternative Put-Option Portfolio Investment Strategies." *The Journal of Business*, 55(1), 1-55.
- Chaput, J. S., & Ederington, L. H. (2003). "Option Spread and Combination Trading." *The Journal of Derivatives*, 10(4), 70-88.
- Israelov, R., & Nielsen, L. N. (2014). "Covered Calls Uncovered." *Financial Analysts Journal*, 70(6), 45-57.

## Implementation Notes

- **Data Requirements**: Real-time options chain data with bid-ask quotes for multiple strikes and expirations. Greeks (delta, theta, gamma, vega) for position management.
- **Liquidity Considerations**: Trade vertical spreads on highly liquid underlyings (SPY, QQQ, IWM, AAPL, etc.) where tight bid-ask spreads minimize execution costs. Penny-increment options are preferred.
- **Strike Width vs. Risk-Reward**: Wider spreads have higher maximum loss but collect more credit and have better risk-reward ratios. Narrower spreads limit risk but have lower expected returns per trade.
- **Earnings and Events**: Avoid initiating credit spreads ahead of binary events (earnings, FDA decisions) where the underlying can gap beyond the spread strikes. Debit spreads can be appropriate for event plays.
- **Crypto Adaptation**: Vertical spreads are available on Deribit for BTC and ETH. Use wider strike widths (10-20% rather than 3-5%) to account for crypto volatility. The higher implied volatility in crypto generates larger credit on spreads but also higher probability of the short strike being breached. Liquidity is thinner than equity options, so limit order execution is essential.
- **Assignment Risk**: For credit spreads using American-style options, early assignment on the short leg is possible (especially near ex-dividend dates for equity options). This is manageable but should be monitored, particularly for spreads where the short leg is ITM near expiration.
