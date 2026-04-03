# 10 - Cryptocurrency Strategies

Strategies designed for or primarily applicable to cryptocurrency markets, exploiting the unique characteristics of digital assets: 24/7 trading, high volatility, market fragmentation, perpetual futures mechanics, and sentiment-driven price dynamics.

## Strategies

| # | Strategy | Rating | Complexity | Key Concept |
|---|----------|--------|------------|-------------|
| 01 | [Bitcoin ANN Strategy](01_Bitcoin-ANN-Strategy.md) | 3/5 | Complex | Neural network price prediction using technical indicators |
| 02 | [Crypto Sentiment Analysis](02_Crypto-Sentiment-Analysis.md) | 3/5 | Complex | NLP/Naive Bayes sentiment signals from social media |
| 03 | [Crypto Trend Following](03_Crypto-Trend-Following.md) | 4/5 | Simple | Moving average trend following adapted for BTC/ETH |
| 04 | [Crypto Mean Reversion](04_Crypto-Mean-Reversion.md) | 3/5 | Moderate | Bollinger Band/RSI mean reversion on short timeframes |
| 05 | [Crypto Arbitrage](05_Crypto-Arbitrage.md) | 3/5 | Complex | Cross-exchange, triangular, and CEX/DEX arbitrage |
| 06 | [Funding Rate Carry](06_Funding-Rate-Carry.md) | 4/5 | Moderate | Delta-neutral perpetual futures funding rate capture |
| 07 | [Crypto Momentum](07_Crypto-Momentum.md) | 3/5 | Moderate | Cross-sectional momentum across crypto assets |
| 08 | [Perpetual Futures Basis](08_Perpetual-Futures-Basis.md) | 4/5 | Moderate | Spot-perp basis cash-and-carry trade |

## Key Themes

- **Trend Following and Carry dominate**: The highest-rated strategies (Trend Following, Funding Rate Carry, Perpetual Futures Basis) exploit structural features of crypto markets --- strong trends and persistent leveraged demand creating carry opportunities.
- **Mean reversion is weaker in crypto**: Unlike equities, crypto assets trend more than they revert on most timeframes. Mean reversion strategies require careful regime detection.
- **Arbitrage alpha is decaying**: Cross-exchange price discrepancies have narrowed substantially since 2018. Remaining opportunities require sophisticated infrastructure and speed.
- **ML/NLP strategies face overfitting risk**: ANN and sentiment strategies show promise but are highly sensitive to model choices, data quality, and regime changes.

## Portfolio Construction Notes

The strategies in this section have varying correlation structures that enable diversification:

- **Trend Following + Mean Reversion**: Negatively correlated; combine for smoother equity curve.
- **Funding Rate Carry + Basis Trade**: Complementary; capture both funding payments and price convergence.
- **Momentum + Trend Following**: Positively correlated; provides concentrated directional exposure.
- **Arbitrage**: Low correlation with all other strategies; provides uncorrelated returns but requires separate infrastructure.
