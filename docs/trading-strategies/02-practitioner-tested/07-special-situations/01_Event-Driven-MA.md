# Event-Driven M&A Strategy

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) (Kakushadze & Serur, 2018), Chapter 3
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: No — requires corporate event data (merger announcements, regulatory filings) that are specific to public equity markets
> **Evidence Tier**: Backtested Only
> **Complexity**: Complex

## Overview

Event-driven M&A (merger arbitrage or risk arbitrage) exploits the price spread between a target company's current market price and the announced acquisition price. When a merger or acquisition is announced, the target's stock price typically jumps toward but not fully to the deal price, reflecting the market's assessment of deal completion risk. The merger arbitrageur buys the target at this discount and earns the spread if the deal closes.

In cash-for-stock deals, the arbitrageur simply buys the target stock. In stock-for-stock deals, the arbitrageur buys the target and shorts the acquirer in the exchange ratio, hedging market risk and isolating the deal spread. The strategy is fundamentally about assessing deal completion probability: the arbitrageur is paid a premium for bearing the risk that the deal falls through (antitrust rejection, financing failure, shareholder vote failure, material adverse change).

As documented in *151 Trading Strategies*, this is one of the most established event-driven strategies, practiced by dedicated merger arbitrage funds for decades. Returns are typically modest but consistent, with low correlation to equity markets and occasional large losses when deals fail.

## Trading Rules

1. **Universe**: All publicly announced mergers and acquisitions with definitive agreements (not rumors or preliminary interest).

2. **Deal Screening**:
   - Minimum deal size: $500M+ (for liquidity).
   - Definitive agreement signed (not merely proposed).
   - Regulatory filing initiated (HSR Act filing in the US).
   - Expected close date within 3-12 months.

3. **Cash Deal Entry**: Buy the target stock when the spread (deal price minus current price) exceeds a minimum threshold (typically >3% annualized).

4. **Stock-for-Stock Deal Entry**: Buy the target and simultaneously short the acquirer in the announced exchange ratio.

5. **Position Sizing**: Risk-weight positions by deal probability. Allocate 2-5% of portfolio per deal, with maximum sector concentration of 20%.

6. **Exit**:
   - **Deal closes**: Receive the cash consideration or exchange shares. Earn the spread.
   - **Deal breaks**: Close the position immediately. Accept the loss (target typically drops 15-40% on deal failure).

7. **Risk Management**: Stop-loss if the spread widens beyond 2x the entry spread, suggesting increased deal failure risk.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.6-0.9 |
| CAGR | 4-8% (unlevered), 7-12% (levered) |
| Max Drawdown | -10% to -20% (diversified portfolio) |
| Win Rate | ~85-90% (deal completion rate) |
| Volatility | ~4-8% annualized (unlevered) |
| Profit Factor | ~2.0-3.0 |
| Rebalancing | Continuous (event-driven) |

The high win rate (~85-90%) reflects that the majority of announced deals close successfully. However, the losses on deal failures are typically 5-10x the size of individual deal gains, creating a negatively skewed return distribution. The strategy's appeal lies in its low volatility and low correlation to equity markets. Most professional merger arb funds use 2-3x leverage to achieve attractive absolute returns from the modest unlevered spread.

## Efficacy Rating

**Rating: 3/5** — Merger arbitrage is one of the most established and well-understood event-driven strategies, practiced by dedicated funds for over 50 years. The deal spread represents genuine compensation for bearing deal failure risk, providing a real economic rationale for the return. The deduction reflects: (a) the strategy requires access to short-selling and leverage to generate meaningful returns, (b) occasional deal failures create outsized losses that can wipe out months of accumulated spread profits, (c) competition from large, well-resourced merger arb funds compresses spreads, (d) the strategy is capacity-constrained and spread compression accelerates as more capital enters the space, and (e) no crypto applicability.

## Academic References

- Mitchell, M., & Pulvino, T. (2001). "Characteristics of Risk and Return in Risk Arbitrage." *The Journal of Finance*, 56(6), 2135-2175.
- Baker, M., & Savasoglu, S. (2002). "Limited Arbitrage in Mergers and Acquisitions." *Journal of Financial Economics*, 64(1), 91-115.
- Jetley, G., & Ji, X. (2010). "The Shrinking Merger Arbitrage Spread." *Financial Analysts Journal*, 66(2), 54-68.
- Kakushadze, Z., & Serur, J. A. (2018). *151 Trading Strategies*. Palgrave Macmillan.
- Maheswaran, K., & Yeoh, C. (2005). "The Profitability of Merger Arbitrage." *International Review of Finance*, 5(3-4), 187-199.

## Implementation Notes

- **Data Requirements**: Real-time deal data feeds (Bloomberg, Refinitiv, FactSet) are essential. Deal terms, regulatory filings, and shareholder vote dates must be monitored continuously.
- **Legal/Regulatory Complexity**: Each deal has unique regulatory hurdles (antitrust review, CFIUS, sector-specific regulators). Assessing deal completion probability requires legal expertise beyond quantitative analysis.
- **Short-Selling Requirements**: Stock-for-stock deals require short-selling the acquirer. Ensure availability of shares to borrow and account for borrow costs, which can be significant for smaller acquirers.
- **Leverage**: Most professional merger arb funds operate with 2-3x gross leverage. Without leverage, the 4-8% CAGR may not justify the operational complexity. Leverage amplifies both returns and the impact of deal failures.
- **Deal Pipeline**: The strategy requires a continuous pipeline of 15-30 active deals to achieve adequate diversification. A single deal failure in a concentrated portfolio can produce double-digit losses.
- **No Crypto Application**: Corporate M&A events have no equivalent in cryptocurrency markets. Protocol mergers (token migrations, chain absorptions) are too rare and structurally different to support a systematic strategy.
