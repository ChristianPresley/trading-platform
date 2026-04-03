# Size Factor (Small-Cap Premium)

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading)
> **Asset Class**: Equities
> **Crypto/24-7 Applicable**: Adaptable — small-cap tokens exist but liquidity constraints are severe
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

The size factor captures the empirical observation that small-capitalization stocks tend to outperform large-capitalization stocks on a risk-adjusted basis. First documented by Banz (1981) and later formalized as the SMB (Small Minus Big) factor in the Fama-French three-factor model (1993), the size premium has been one of the most debated anomalies in asset pricing. The economic rationale includes greater information asymmetry, lower liquidity, higher business risk, and limited institutional coverage of smaller firms. While the raw size premium has weakened since its initial publication, it remains significant when combined with quality or value screens, and is a standard component of multi-factor asset pricing models worldwide.

## Trading Rules

1. **Universe**: All common stocks on major exchanges with sufficient liquidity (minimum daily volume thresholds).
2. **Signal**: At the end of each year (June), compute market capitalization for each stock.
3. **Breakpoint**: Use NYSE median market capitalization as the size breakpoint.
4. **Long Portfolio**: Buy stocks below the median market cap (small-cap stocks).
5. **Short Portfolio**: Sell short stocks above the median market cap (large-cap stocks).
6. **Weighting**: Value-weight positions within each portfolio leg.
7. **Rebalancing**: Annually (June).
8. **Holding Period**: One year, then re-sort and rebalance.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.747 |
| CAGR | ~8-10% (long-short spread) |
| Max Drawdown | ~30-35% |
| Win Rate | ~55% |
| Volatility | 11.1% |
| Profit Factor | ~1.4 |
| Rebalancing | Yearly |

## Efficacy Rating

**4 / 5** -- The size premium is one of the original documented anomalies and remains a core component of multi-factor models. However, it receives a 4 rather than 5 because the standalone size premium has weakened considerably since its publication in 1981, with some researchers questioning whether it was partially a data-mining artifact or has been arbitraged away. The premium is most robust among stocks with low institutional ownership, in January, and when combined with quality or value factors. Its persistence in international markets and among micro-caps supports continued relevance, but with appropriate caveats.

## Academic References

- Banz, R.W. (1981). "The Relationship Between Return and Market Value of Common Stocks." *Journal of Financial Economics*, 9(1), 3-18.
- Fama, E.F. and French, K.R. (1993). "Common Risk Factors in the Returns on Stocks and Bonds." *Journal of Financial Economics*, 33(1), 3-56.
- van Dijk, M.A. (2011). "Is Size Dead? A Review of the Size Effect in Equity Returns." *Journal of Banking & Finance*, 35(12), 3263-3274.
- Asness, C.S., Frazzini, A., Israel, R., Moskowitz, T.J., and Pedersen, L.H. (2018). "Size Matters, If You Control Your Junk." *Journal of Financial Economics*, 129(3), 479-509.
- Fama, E.F. and French, K.R. (2012). "Size, Value, and Momentum in International Stock Returns." *Journal of Financial Economics*, 105(3), 457-472.

## Implementation Notes

- **Liquidity Constraints**: Small-cap strategies face real-world capacity limits; market impact costs can erode a significant portion of the premium, especially for micro-caps.
- **January Effect**: A disproportionate share of the size premium historically concentrates in January; consider seasonal timing.
- **Quality Filter**: Combining size with quality (profitability) screens, as shown by Asness et al. (2018), substantially improves the size premium and removes "junk" small-cap exposure.
- **Crypto Adaptation**: Small-cap tokens (low market cap altcoins) often exhibit extreme volatility and liquidity risk. The size effect is plausible but position sizing must account for frequent delistings and rug pulls.
- **Capacity**: This strategy has limited capacity; institutional-scale capital will quickly move prices in small-cap names.
