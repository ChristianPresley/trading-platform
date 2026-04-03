# 06 — Sector Rotation

Strategies that rotate capital among sectors, asset classes, or factor exposures based on relative momentum or other ranking criteria. These approaches exploit the tendency of outperforming sectors to continue outperforming in the near term.

## Key Themes

- **Momentum-Based Rotation**: All strategies in this section use some form of momentum ranking to select the allocation. The strength of the momentum signal varies by the dimension being rotated.
- **Diminishing Returns with Complexity**: Simpler rotation approaches (ETF rotation across 3 asset classes) tend to outperform more complex ones (style rotation across growth/value). Adding dimensions does not reliably add return.
- **Regime Vulnerability**: All rotation strategies are vulnerable to regime changes where all available rotation targets decline simultaneously (e.g., 2022's simultaneous equity and bond bear market).

## Strategies

| # | Strategy | Rating | Sharpe | Crypto | Source |
|---|----------|--------|--------|--------|--------|
| 01 | [ETF Rotation](01_ETF-Rotation.md) | 3/5 | ~0.6-0.8 | Adaptable | Quantified Strategies |
| 02 | [Smart Factors Rotation](02_Smart-Factors-Rotation.md) | 3/5 | 0.388 | No | Awesome Systematic Trading |
| 03 | [Style Rotation](03_Style-Rotation.md) | 2/5 | -0.056 | No | Awesome Systematic Trading |

## Overall Assessment

Sector and factor rotation is one of the most accessible areas of systematic trading, requiring only monthly rebalancing and liquid ETFs. The ETF rotation approach has the strongest track record and simplest implementation. Smart factors rotation offers a modest edge with low volatility. Style rotation on the growth/value axis is not recommended based on the available evidence.

For crypto adaptation, the ETF rotation concept translates well to rotating among crypto sectors (L1 platforms, DeFi protocols, infrastructure tokens), though with significantly higher volatility and correlation risk. Factor-based and style-based rotation have no meaningful crypto equivalents.
