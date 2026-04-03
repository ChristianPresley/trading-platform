# Distressed Debt Strategy

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) (Kakushadze & Serur, 2018), Chapter 15
> **Asset Class**: Fixed Income / Credit
> **Crypto/24-7 Applicable**: Adaptable — the concept of buying distressed assets at a discount applies to crypto tokens from failed/struggling projects, though the legal framework and recovery mechanisms differ fundamentally
> **Evidence Tier**: Backtested Only
> **Complexity**: Complex

## Overview

Distressed debt investing involves purchasing the debt obligations (bonds, loans, trade claims) of companies in financial distress, bankruptcy, or default at a significant discount to face value. The strategy profits when the company restructures and the debt recovers to a higher value, when the distressed debt is converted to equity in a reorganization, or when the investor acquires sufficient debt to control the restructuring outcome (loan-to-own).

As documented in *151 Trading Strategies*, distressed debt encompasses two primary sub-strategies: passive distressed (buy and hold at a discount, wait for recovery) and active distressed (acquire enough debt to influence the restructuring process, potentially converting to equity ownership). Active distressed investing is practiced by specialized hedge funds (Oaktree, Elliott, Cerberus) and requires deep legal, financial, and operational expertise.

The strategy's returns are driven by the illiquidity premium and information complexity premium — most investors cannot or will not hold defaulted securities, creating persistent mispricing for those with the expertise and willingness to invest in distress.

## Trading Rules

1. **Universe**: Corporate bonds, bank loans, and trade claims trading below 50 cents on the dollar (for passive) or specific target companies in active restructuring (for active).

2. **Screening Criteria (Passive)**:
   - Debt trading at 20-60% of face value.
   - Company has identifiable asset value exceeding the discounted debt purchase price.
   - Restructuring or bankruptcy filing is in progress or imminent.
   - Sufficient liquidity to establish a position.

3. **Entry (Passive)**: Buy distressed debt when the market price reflects excessive pessimism relative to estimated recovery value.

4. **Entry (Active/Loan-to-Own)**: Acquire a blocking position in a specific tranche of the capital structure (typically 33%+ of a class) to control the restructuring outcome.

5. **Exit**: Sell after restructuring completion (debt recovery to par or near-par), or convert to equity and sell the reorganized company's shares.

6. **Holding Period**: 6 months to 3+ years. This is a patient, illiquid strategy.

7. **Risk Management**: Maximum 5-10% of portfolio per situation. Diversify across 10-20 distressed situations.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.5-0.8 |
| CAGR | ~8-15% (unlevered, through-cycle) |
| Max Drawdown | -20% to -40% (concentrated, correlated with credit cycles) |
| Win Rate | ~55-65% (per distressed situation) |
| Volatility | ~10-18% annualized |
| Profit Factor | ~1.5-2.5 |
| Rebalancing | Event-driven (restructuring milestones) |

Distressed debt returns are highly cyclical: the best opportunities arise during and immediately after credit crises (2008-2009, 2020), when forced selling by investment-grade mandates creates extreme discounts. Through-cycle returns for diversified distressed funds have historically averaged 8-15% annually with Sharpe ratios in the 0.5-0.8 range. Individual situations can produce 50-200%+ returns (buying at 20 cents, recovering at 60-80 cents) or total losses.

## Efficacy Rating

**Rating: 3/5** — Distressed debt investing has a genuine, persistent economic rationale: the illiquidity premium and complexity premium compensate investors for bearing default risk and navigating complex legal/financial restructurings. Top-tier distressed funds have generated strong long-term returns. The deduction reflects: (a) extreme complexity requiring legal, financial, and operational expertise beyond quantitative analysis, (b) illiquidity — positions can take years to resolve and cannot be easily exited, (c) high minimum investment sizes ($1M+ per situation for meaningful positions), (d) severe cyclicality — the best opportunities are concentrated in credit crises, creating long idle periods, and (e) the crypto adaptation is speculative and lacks the legal recovery framework that underpins traditional distressed investing.

## Academic References

- Altman, E. I. (1998). "Market Dynamics and Investment Performance of Distressed and Defaulted Debt Securities." NYU Salomon Center Working Paper.
- Hotchkiss, E. S., & Mooradian, R. M. (1997). "Vulture Investors and the Market for Control of Distressed Firms." *Journal of Financial Economics*, 43(3), 401-432.
- Jiang, W., Li, K., & Wang, W. (2012). "Hedge Funds and Chapter 11." *The Journal of Finance*, 67(2), 513-560.
- Kakushadze, Z., & Serur, J. A. (2018). *151 Trading Strategies*. Palgrave Macmillan.
- Moyer, S. G. (2004). *Distressed Debt Analysis: Strategies for Speculative Investors*. J. Ross Publishing.
- Altman, E. I., & Hotchkiss, E. (2005). *Corporate Financial Distress and Bankruptcy*. John Wiley & Sons.

## Implementation Notes

- **Expertise Requirements**: This is the most skill-intensive strategy in this collection. Successful distressed investing requires understanding bankruptcy law (Chapter 11 in the US, equivalent processes in other jurisdictions), capital structure analysis, asset valuation, and often operational turnaround expertise.
- **Information Edge**: Distressed situations are information-intensive. Access to restructuring advisors, legal counsel, and management teams provides a significant advantage. Quantitative-only approaches are unlikely to succeed in this space.
- **Illiquidity**: Distressed debt markets are highly illiquid. Bid-ask spreads of 5-15% are common. Position exits may require months of negotiation or waiting for restructuring resolution.
- **Credit Cycle Timing**: The best entry points occur during credit crises when forced selling creates extreme discounts. Building a framework for identifying these windows (e.g., high-yield spreads above 800bp, default rates above 5%) is essential.
- **Crypto Adaptation**: The concept of buying "distressed tokens" at a discount is conceptually appealing but structurally different. Unlike corporate debt, crypto tokens typically have no legal claim on assets, no bankruptcy protection, and no restructuring framework. When a crypto project fails, token recovery is typically zero. The few cases where distressed crypto tokens recovered (e.g., FTT to some extent through legal proceedings) are exceptions driven by unique circumstances.
- **Minimum Scale**: Meaningful distressed debt investing requires $10M+ in capital to achieve adequate diversification across situations. This is not suitable for smaller portfolios.
