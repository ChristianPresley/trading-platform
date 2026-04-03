# 12 - Multi-Asset and Macro Strategies

Strategies that operate across multiple asset classes (equities, bonds, commodities, currencies) and/or use macroeconomic signals for allocation and timing decisions. These strategies focus on the asset allocation level rather than individual security selection, typically offering high capacity, lower turnover, and genuine diversification across economic regimes.

## Strategies

| # | Strategy | Rating | Complexity | Key Concept |
|---|----------|--------|------------|-------------|
| 01 | [Risk Parity](01_Risk-Parity.md) | 5/5 | Moderate | Allocate by inverse volatility for equal risk contribution |
| 02 | [Global Macro Momentum](02_Global-Macro-Momentum.md) | 4/5 | Complex | Macro factor momentum across countries and asset classes |
| 03 | [Value and Momentum Across Assets](03_Value-And-Momentum-Across-Assets.md) | 5/5 | Moderate | Asness-Moskowitz-Pedersen combined value+momentum factors |
| 04 | [Alpha Rotation](04_Alpha-Rotation.md) | 3/5 | Moderate | Rotate among asset classes based on alpha signals |
| 05 | [Paired Switching](05_Paired-Switching.md) | 4/5 | Simple | Switch between two negatively correlated assets |
| 06 | [FED Model](06_FED-Model.md) | 3/5 | Simple | Equity earnings yield vs. bond yield valuation signal |

## Key Themes

- **Risk parity and value-momentum are gold standards**: Both carry 5/5 ratings with decades of academic support. Risk parity provides robust diversified allocation, while value-momentum captures persistent factor premia across asset classes.
- **Simplicity often wins**: Paired switching (4/5) achieves strong risk-adjusted returns with minimal complexity. The FED Model, despite theoretical flaws, provides useful valuation context. Over-engineering allocation strategies frequently underperforms simple, robust rules.
- **Macro strategies have high capacity**: These strategies operate through liquid futures markets, supporting billions in AUM without material market impact. This makes them particularly suitable for institutional or large-portfolio implementation.
- **Negative correlation is the key to diversification**: The best multi-asset strategies exploit the negative correlation between equities and bonds (risk parity, paired switching) and between value and momentum factors (Asness et al.).

## Crypto Applicability

| Strategy | Crypto Applicable | Notes |
|----------|-------------------|-------|
| Risk Parity | Adaptable | Crypto gets small weight due to high volatility; genuine diversification benefit |
| Global Macro Momentum | No | Requires sovereign macro data with no crypto equivalent |
| Value and Momentum Across Assets | Adaptable | Momentum directly applicable; value requires proxy metrics (NVT, etc.) |
| Alpha Rotation | Adaptable | BTC can be one of the rotational asset classes |
| Paired Switching | Adaptable | Pair BTC with bonds or gold |
| FED Model | No | Requires equity earnings yield and bond yield data |

## Portfolio Construction Notes

These strategies are designed to be combined. A suggested multi-asset portfolio framework:

1. **Core Allocation (60%)**: Risk parity across equities, bonds, commodities, and inflation-linked assets.
2. **Factor Tilt (25%)**: Value and momentum across assets, rebalanced monthly.
3. **Tactical Overlay (15%)**: Alpha rotation or paired switching for dynamic allocation adjustment.
4. **Valuation Context**: FED Model and related valuation metrics inform the equity weight within the core allocation.

This layered approach provides diversification at multiple levels: across asset classes (risk parity), across factors (value + momentum), and across time horizons (strategic core + tactical overlay).
