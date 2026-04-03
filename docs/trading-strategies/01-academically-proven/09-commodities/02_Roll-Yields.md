# Roll Yields (Backwardation/Contango)

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading) / [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 9
> **Asset Class**: Commodity futures (cross-sectional)
> **Crypto/24-7 Applicable**: Adaptable — perpetual futures funding rates are the crypto analog of roll yield; positive funding (contango-like) means longs pay shorts, and vice versa
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

Roll yield arises from the shape of the commodity futures term structure. When a market is in backwardation (futures price below spot), rolling from an expiring contract to a further-dated contract generates positive roll return. When in contango (futures above spot), rolling generates negative return. Erb and Harvey (2006) find that roll yield explains 91% of the cross-sectional variance in commodity futures returns over a 21-year horizon. The strategy goes long commodities in backwardation and short those in contango, effectively harvesting the insurance premium that producers pay to hedge their output.

## Trading Rules

1. **Universe**: 20-30 liquid commodity futures spanning energy, metals, agriculture, and livestock
2. **Signal**: Compute roll yield as (near-month price - next-month price) / near-month price for each commodity
3. **Long leg**: Buy commodities with the highest positive roll yield (deepest backwardation), top tercile
4. **Short leg**: Sell commodities with the most negative roll yield (deepest contango), bottom tercile
5. **Holding period**: 1 month (rebalance at each contract roll)
6. **Weighting**: Equal-weight within each leg
7. **Risk management**: Volatility-target each leg to equalize risk contribution

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | ~0.4-0.6 |
| CAGR | ~6-10% (long-short) |
| Max Drawdown | ~20-30% |
| Win Rate | ~55-60% |
| Volatility | ~12-18% |
| Profit Factor | ~1.4-1.6 |
| Rebalancing | Monthly (at contract roll) |

## Efficacy Rating

**4/5** — One of the most economically grounded commodity strategies. The risk transfer mechanism (producers paying for price insurance) provides a durable structural rationale. Gorton and Rouwenhorst (2006) confirm that backwardated commodities systematically outperform contangoed ones. The strategy is well-diversified across commodity sectors and has low correlation to equities and bonds. Performance weakened during the financialization of commodities (2005-2015) as index fund inflows pushed many markets into persistent contango.

## Academic References

- Gorton, G. & Rouwenhorst, K. G. (2006). "Facts and Fantasies About Commodity Futures." *Financial Analysts Journal*, 62(2), 47-68.
- Erb, C. B. & Harvey, C. R. (2006). "The Strategic and Tactical Value of Commodity Futures." *Financial Analysts Journal*, 62(2), 69-97.
- Gorton, G., Hayashi, F., & Rouwenhorst, K. G. (2013). "The Fundamentals of Commodity Futures Returns." *Review of Finance*, 17(1), 35-105.
- Bhardwaj, G., Gorton, G., & Rouwenhorst, K. G. (2015). "Facts and Fantasies About Commodity Futures Ten Years Later." NBER Working Paper No. 21243.
- Koijen, R. S. J., Moskowitz, T. J., Pedersen, L. H., & Vrugt, E. B. (2018). "Carry." *Journal of Financial Economics*, 127(2), 197-225.

## Implementation Notes

- **Roll mechanics**: The exact roll date and methodology materially affect returns; avoid rolling on the same day as commodity index funds (Goldman Roll)
- **Term structure measurement**: Use the ratio of first and second nearby contracts; alternatively, use the slope of the full futures curve for a more robust signal
- **Financialization impact**: Post-2004, massive inflows into commodity index products pushed many markets into persistent contango, reducing long-only returns but potentially improving the long-short spread
- **Crypto adaptation**: Perpetual futures funding rates on exchanges like Binance, Bybit, and Deribit are directly analogous to roll yield. When funding is positive (longs pay shorts), the market is in effective contango; when negative, backwardation. A strategy that shorts high-funding-rate perpetuals and longs negative-funding-rate perpetuals captures the same economic premium. Funding rate collection occurs every 8 hours, making this a high-frequency analog of the commodity roll yield strategy
- **Capacity**: Lower capacity than equity strategies due to commodity futures market size; avoid concentrated positions in illiquid agricultural contracts
- **Correlation benefit**: Roll yield strategies have near-zero correlation with equities and bonds, making them valuable portfolio diversifiers
