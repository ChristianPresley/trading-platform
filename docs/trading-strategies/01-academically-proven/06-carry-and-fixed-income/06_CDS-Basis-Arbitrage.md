# CDS-Bond Basis Arbitrage

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 5
> **Asset Class**: Credit / Fixed Income
> **Crypto/24-7 Applicable**: Adaptable — DeFi lending spreads between protocols create analogous basis relationships, though with fundamentally different risk characteristics (smart contract risk replaces counterparty risk)
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

CDS-bond basis arbitrage exploits the spread differential between a credit default swap (CDS) and the credit spread of the underlying bond for the same reference entity and maturity. In theory, the CDS spread and the bond's asset-swap spread should be equal — both reflect the market's assessment of the issuer's credit risk. In practice, persistent deviations arise due to differences in liquidity, funding costs, counterparty risk, cheapest-to-deliver optionality, and regulatory capital treatment.

The CDS-bond basis is defined as the CDS spread minus the bond's asset-swap spread. A **negative basis** (CDS spread < bond spread) indicates that credit protection via CDS is cheaper than the credit risk embedded in the bond — the classic arbitrage involves buying the bond and buying CDS protection, locking in the positive differential. A **positive basis** (CDS spread > bond spread) can be exploited by selling the bond short and selling CDS protection, though this is harder to execute due to the difficulty of shorting corporate bonds.

Research by Bai and Collin-Dufresne (2019) demonstrates that basis deviations, while normally close to zero, expand dramatically during financial crises when arbitrage capital is constrained. The basis factor carries an annual risk premium of approximately 3% in investment-grade bonds during normal periods. The 2008 financial crisis saw CDS-bond bases blow out to historically extreme levels (-200bp to -400bp for investment-grade issuers), creating both massive arbitrage opportunities and devastating losses for leveraged basis traders who could not meet margin calls.

## Trading Rules

1. **Universe**: Investment-grade and high-yield corporate issuers with liquid CDS contracts (typically 5-year CDS) and tradeable bonds in the 3-7 year maturity range.

2. **Signal Construction**:
   - Compute the CDS-bond basis: CDS spread minus Z-spread (or asset-swap spread) for each reference entity.
   - Identify issuers where the basis deviates significantly from its historical mean (e.g., beyond 1-2 standard deviations).

3. **Negative Basis Trade** (basis < 0, most common arbitrage):
   - **Buy** the corporate bond (asset-swap package to convert to floating rate).
   - **Buy** CDS protection on the same reference entity with matching maturity.
   - Finance the bond purchase in the repo market.
   - The net carry equals the bond's asset-swap spread minus the CDS premium minus the repo funding cost.
   - Profit as the basis converges toward zero.

4. **Positive Basis Trade** (basis > 0):
   - **Short** the corporate bond (via repo) or sell the asset-swap package.
   - **Sell** CDS protection on the same reference entity.
   - Less common due to the difficulty and cost of shorting corporate bonds.

5. **Position Sizing**: Size positions based on the magnitude of the basis deviation relative to historical volatility. Limit single-name exposure to 2-5% of portfolio.

6. **Risk Management**: Set stop-losses at 2-3x the initial basis deviation. Monitor funding conditions and repo availability closely, as these drive basis blowouts during crises.

7. **Rebalancing**: Monthly. Monitor basis convergence and exit when the basis reverts to within 0.5 standard deviations of its mean.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.3-0.7 (normal periods), negative during crises |
| CAGR | 2-4% (excess return, normal conditions, unlevered) |
| Max Drawdown | -10% to -40% (2008 GFC basis blowout) |
| Win Rate | 60-70% (trade-level in normal markets) |
| Volatility | 3-8% (normal), 15-25% (crisis) |
| Profit Factor | 1.3-1.8 (normal periods) |
| Rebalancing | Monthly |

The strategy earns approximately 3% annual risk premium from the basis factor in investment-grade bonds during normal periods. However, the risk profile is highly asymmetric: the strategy collects small, steady profits most of the time but can experience catastrophic losses during financial crises when the basis diverges further rather than converging. The 2008 crisis is the defining risk event, where leveraged basis traders faced margin calls precisely when the opportunity was largest.

## Efficacy Rating

**Rating: 3/5** — CDS-bond basis arbitrage is academically well-documented and the theoretical foundation (no-arbitrage pricing of credit risk) is sound. In normal markets, the strategy reliably captures a modest risk premium from basis convergence. The significant rating deduction reflects the strategy's extreme vulnerability to funding liquidity crises — the basis can diverge far beyond historical norms precisely when capital is most constrained, and leveraged positions face margin calls before convergence occurs. This "picking up nickels in front of a steamroller" risk profile makes the strategy dangerous for undercapitalized participants.

## Academic References

- Bai, J., & Collin-Dufresne, P. (2019). "The CDS-Bond Basis." *Financial Management*, 48(2), 417-439.
- Duffie, D. (1999). "Credit Swap Valuation." *Financial Analysts Journal*, 55(1), 73-87.
- Fontana, A. (2012). "The Negative CDS-Bond Basis and Convergence Trading During the 2007/09 Financial Crisis." *Working Paper*.
- Mitchell, M., & Pulvino, T. (2012). "Arbitrage Crashes and the Speed of Capital." *Journal of Financial Economics*, 104(3), 469-490.
- BIS Working Paper No. 631. (2017). "Arbitrage Costs and the Persistent Non-Zero CDS-Bond Basis." *Bank for International Settlements*.
- Choi, J., & Shachar, O. (2014). "Did Liquidity Providers Become Liquidity Seekers? Evidence from the CDS-Bond Basis During the 2007-09 Crisis." *Federal Reserve Bank of New York Staff Reports No. 784*.

## Implementation Notes

- **Data Requirements**: Real-time CDS quotes (typically from Markit/IHS), bond prices and asset-swap spreads, repo rates, and ISDA documentation for the reference entity. The 5-year CDS is the most liquid tenor.
- **Funding Risk**: The trade's primary risk is not credit risk (which is hedged) but funding risk. If repo markets seize or haircuts increase, the cost of financing the bond position can eliminate the arbitrage profit or force liquidation.
- **Counterparty Risk**: CDS protection is only as good as the counterparty providing it. Post-2008 reforms (central clearing via ICE Clear Credit, CSA collateral agreements) have reduced but not eliminated this risk.
- **Transaction Costs**: CDS bid-ask spreads are 3-10bp for investment-grade, 10-30bp for high-yield. Bond asset-swap package execution adds another 5-15bp. These costs are material relative to the typical 20-80bp basis opportunity.
- **Crypto/DeFi Adaptation**: DeFi lending rate spreads between protocols (e.g., Aave vs. Compound vs. Morpho) create analogous basis relationships. Borrow on a low-rate protocol, lend on a high-rate protocol, and profit from the spread. Key differences: no duration risk, but smart contract risk, bridge risk, and liquidation risk replace traditional funding risk. Basis deviations tend to be larger but also more volatile.
- **Regulatory Capital**: Post-2008 Basel III rules significantly increased the capital charge for basis trades, reducing institutional capacity to arbitrage small deviations. This has made the basis more persistent, creating opportunities for less capital-constrained participants.
