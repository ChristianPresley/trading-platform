# Sector Momentum Rotation

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading-strategies), [Quantpedia #0003](https://quantpedia.com/strategies/sector-momentum-rotational-system/)
> **Asset Class**: Equities / ETFs
> **Crypto/24-7 Applicable**: Adaptable — crypto sectors (L1s, DeFi, NFTs, L2s, AI tokens) exhibit momentum rotation patterns
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

Sector momentum rotation exploits the well-documented tendency of industry and sector returns to persist over intermediate horizons. Rather than selecting individual stocks, the strategy ranks broad sector indices (or sector ETFs) by their recent performance and concentrates capital in the top-performing sectors while avoiding or shorting the worst-performing sectors. The approach benefits from the lower idiosyncratic risk of sectors compared to individual stocks, reducing the impact of stock-specific news events.

The academic foundation rests on Moskowitz and Grinblatt (1999), who demonstrated that industry momentum is a significant driver of individual stock momentum — much of the profit from buying past winner stocks and selling past loser stocks comes from the fact that winners tend to cluster in the same industries. Sector rotation strategies capitalize on this insight directly by trading at the sector level, which reduces turnover, lowers transaction costs, and simplifies implementation. The strategy is particularly effective because sector trends tend to be driven by macroeconomic regime shifts (e.g., rising oil prices benefiting energy, falling rates benefiting growth/technology), which persist for months to years.

## Trading Rules

1. **Universe**: Sector ETFs representing the major sectors of the economy. A standard implementation uses the 11 SPDR Select Sector ETFs:
   - XLK (Technology), XLF (Financials), XLV (Health Care), XLY (Consumer Discretionary), XLP (Consumer Staples), XLE (Energy), XLI (Industrials), XLB (Materials), XLU (Utilities), XLRE (Real Estate), XLC (Communication Services)

2. **Ranking**: At month-end, rank all sector ETFs by their total return over the past N months (typically N = 6 or 12 months). The 6-month lookback tends to produce the best results for sector rotation.

3. **Selection**:
   - **Long Portfolio**: Buy the top 3 sectors (out of 11) by momentum rank.
   - **Optional Short**: Short the bottom 3 sectors for a long-short implementation.
   - The long-only version is more practical and still captures most of the alpha.

4. **Weighting**: Equal-weight among selected sectors (e.g., 33.3% each for the top 3).

5. **Trend Filter (Optional but Recommended)**: Only hold long positions in sectors whose past return is positive (absolute momentum filter). If a top-ranked sector has negative absolute momentum, allocate that portion to cash instead. This reduces drawdowns significantly.

6. **Rebalancing**: Monthly at month-end. Evaluate rankings and rotate into new top sectors as needed.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.401 |
| CAGR | 9-12% (long-only top 3) |
| Max Drawdown | -30% to -40% (without trend filter) |
| Win Rate | 58-62% (monthly) |
| Volatility | 14.1% |
| Profit Factor | 1.3-1.5 |
| Rebalancing | Monthly |

Adding the absolute momentum trend filter reduces maximum drawdown to approximately -15% to -20% while modestly reducing CAGR. The long-short version (top 3 minus bottom 3) typically produces a Sharpe ratio of 0.50-0.60 but with higher complexity and short-selling costs.

## Efficacy Rating

**Rating: 4/5** — Sector momentum rotation is well-supported by academic evidence, simple to implement, and has low transaction costs due to the use of liquid ETFs with monthly rebalancing. It captures a meaningful portion of cross-sectional momentum returns with far less turnover than stock-level momentum. The deduction from a perfect score reflects: (a) significant drawdowns during broad market crashes when all sectors decline together (the trend filter mitigates but does not eliminate this), (b) periods of sector mean-reversion that can cause whipsaw losses, and (c) limited diversification since all positions are in equities.

## Academic References

- Moskowitz, T. J., & Grinblatt, M. (1999). "Do Industries Explain Momentum?" *The Journal of Finance*, 54(4), 1249-1290.
- O'Neal, E. S. (2000). "Industry Momentum and Sector Mutual Funds." *Financial Analysts Journal*, 56(4), 37-49.
- Swinkels, L., & Tjong-A-Tjoe, L. (2007). "Can Mutual Funds Time Investment Styles?" *Journal of Asset Management*, 8(2), 123-132.
- Faber, M. T. (2007). "A Quantitative Approach to Tactical Asset Allocation." *Journal of Wealth Management*, 9(4), 69-79.
- Sassetti, P., & Tani, M. (2006). "Dynamic Asset Allocation Using Systematic Sector Rotation." *Journal of Wealth Management*, 8(4), 59-70.
- Conover, C. M., Jensen, G. R., Johnson, R. R., & Mercer, J. M. (2008). "Sector Rotation and Monetary Conditions." *Journal of Investing*, 17(1), 34-46.

## Implementation Notes

- **ETF Selection**: The SPDR Select Sector ETFs are the most liquid sector ETFs with the tightest spreads. Vanguard and iShares sector ETFs are viable alternatives. Average daily volume for the SPDR sector ETFs exceeds $500M, so capacity is not a constraint.
- **Number of Sectors Held**: Holding the top 3 out of 11 sectors provides a good balance between concentration (capturing momentum) and diversification (reducing sector-specific risk). Holding fewer than 3 increases concentration risk; holding more than 5 dilutes the momentum signal.
- **Lookback Period**: The 6-month lookback is canonical for sector rotation. Shorter lookbacks (1-3 months) capture faster rotations but increase turnover. Blending 3-month, 6-month, and 12-month lookbacks can improve robustness.
- **Earnings Season Effects**: Sector momentum is amplified during earnings season when sector-level earnings surprises drive correlated moves across constituent stocks. The strongest sector momentum signals often occur just after earnings season.
- **Crypto Adaptation**: Crypto "sectors" include L1 platforms (ETH, SOL, AVAX), DeFi protocols (UNI, AAVE, MKR), gaming/metaverse (AXS, SAND), L2 scaling (MATIC, ARB, OP), and AI tokens (FET, RNDR). Sector momentum rotation in crypto can be implemented using equal-weight sector baskets, though sector definitions are less standardized and more fluid than in equities. The higher volatility of crypto sectors means both larger gains and larger drawdowns.
- **Macroeconomic Regime Awareness**: Sector rotation is fundamentally driven by the business cycle. Technology and consumer discretionary tend to lead in early recovery, energy and materials in late expansion, utilities and consumer staples in recession. While the momentum signal captures these rotations mechanically, understanding the macro context can improve conviction and reduce false signals.
- **Platform Availability**: Trivially implementable on any brokerage with ETF access. Interactive Brokers, TD Ameritrade, and Schwab all support automated monthly rebalancing. QuantConnect and Zipline provide ready-made sector rotation templates.

## Known Risks and Limitations

- **Correlated Drawdowns**: During broad market selloffs (2008, 2020 March), all sectors decline together, and the strategy offers no protection unless combined with an absolute momentum trend filter. The long-only version without an absolute filter experienced drawdowns exceeding -30% during the 2008 crisis.
- **Sector Concentration**: Holding only 3 sectors out of 11 creates significant concentration risk. A single sector experiencing a shock (e.g., Energy in 2020 oil crash, Financials in 2008 banking crisis) can cause disproportionate portfolio losses if that sector was ranked in the top 3 before the shock.
- **Regime Sensitivity**: Sector momentum works best during trending economic regimes and poorly during regime transitions. When the economy shifts from expansion to contraction, the previously winning sectors (cyclicals) can reverse sharply while defensive sectors rally, creating losses on both the long and short sides.
- **Style Overlap**: Sector momentum can unintentionally create significant factor tilts. During growth-led markets, the strategy tends to be overweight Technology and Consumer Discretionary, effectively becoming a growth bet. During value rallies, it rotates into Energy and Financials. Investors should be aware that they may be taking implicit style bets rather than pure sector momentum bets.

## Variants and Extensions

- **Dual Lookback Blend**: Combine rankings from 3-month and 12-month lookbacks to capture both short-term sector rotation and longer-term trends. Average the rank from each lookback period to produce a composite score.
- **Equal-Sector-Risk Rotation**: Instead of equal-weighting the top sectors, allocate inversely proportional to each sector's recent volatility. This prevents high-volatility sectors (Energy, Technology) from dominating portfolio risk.
- **Global Sector Rotation**: Extend the universe beyond US sectors to include global sector ETFs or country ETFs, providing additional diversification and momentum opportunities. The MSCI World sector indices provide a global perspective.
- **Sector + Factor Overlay**: Combine sector momentum with within-sector stock selection using quality or value factors. Hold the top 3 sectors, but within each sector, overweight the highest-quality or cheapest stocks. This two-level approach captures both sector-level and stock-level alpha.
- **Crypto Sector Adaptation**: In cryptocurrency markets, sector definitions are evolving but include: Layer 1 platforms (ETH, SOL, AVAX, ADA), DeFi protocols (UNI, AAVE, CRV, MKR), Layer 2 scaling (MATIC, ARB, OP), AI/compute tokens (FET, RNDR, TAO), and meme/culture tokens (DOGE, SHIB). Sector rotation in crypto tends to be faster (weekly to monthly cycles) than in equities, requiring shorter lookback periods and more frequent rebalancing.

## Behavioral and Risk-Based Explanations

- **Slow Information Diffusion**: Sector-level momentum arises because macroeconomic information that favors certain sectors diffuses gradually through the market. When oil prices rise, it takes weeks for the full implications to be reflected in Energy sector valuations as analysts update models, companies report results, and institutional investors adjust allocations.
- **Herding and Narrative Momentum**: Sector rotation is amplified by media narratives and analyst herding. When a sector begins outperforming, it attracts media coverage, which drives retail flows, which further drives outperformance — creating a self-reinforcing cycle that persists for months.
- **Institutional Rebalancing Lag**: Large institutional investors (pension funds, sovereign wealth funds) adjust sector allocations slowly due to committee approval processes, benchmark tracking considerations, and risk management constraints. This institutional sluggishness allows sector trends to persist longer than they would in a frictionless market.
- **Business Cycle Linkage**: Sector performance is fundamentally linked to the business cycle. Technology and consumer discretionary lead in early recovery, energy and materials in late expansion, utilities and healthcare in contraction. Since business cycles last years, the sector momentum signal captures these multi-month regime shifts mechanically.

## Historical Performance by Decade

- **2000s**: Sector rotation performed strongly, capturing the rotation from Technology into Energy, Materials, and Financials during the commodity supercycle, then rotating defensively ahead of the 2008 crisis (with trend filter).
- **2010s**: The decade was dominated by Technology sector outperformance, and the strategy was consistently overweight Technology. However, frequent whipsaw during the 2011 and 2015-2016 corrections reduced risk-adjusted returns.
- **2020s**: COVID-19 created extreme sector rotation — from stay-at-home beneficiaries (Technology) to reopening trades (Energy, Financials) to inflation beneficiaries. The strategy captured much of this rotation but was whipsawed during rapid regime shifts.

## Sector Momentum vs. Stock Momentum

Moskowitz and Grinblatt (1999) showed that industry momentum accounts for a substantial fraction of individual stock momentum. Trading at the sector level rather than the stock level offers several practical advantages: (a) far fewer positions to manage (3-5 ETFs vs. 100+ stocks), (b) lower transaction costs and turnover, (c) no single-stock event risk, and (d) simpler tax reporting. The trade-off is lower alpha per unit of risk — sector momentum captures the systematic component of momentum but misses the stock-specific component that residual momentum targets.
