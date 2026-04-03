# Market Sentiment and Overnight Anomaly

> **Source**: [Awesome Systematic Trading / Quantpedia](https://quantpedia.com/market-sentiment-and-an-overnight-anomaly/) — Vojtko & Hanicova (2021)
> **Asset Class**: US Equities (S&P 500 / SPY)
> **Crypto/24-7 Applicable**: Adaptable — sentiment indicators (VIX, news-based NLP) can be applied to crypto, but the overnight boundary must be synthetically defined
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

This strategy enhances the basic overnight anomaly (buy at close, sell at open) by conditioning entries on market sentiment indicators. The research tests three sentiment proxies: Brain Market Sentiment (BMS, an NLP-based news sentiment score), VIX level relative to its moving average, and SPY price relative to its moving average. When sentiment is favorable (bullish), overnight positions are initiated; when bearish, the strategy stays in cash. The goal is to capture the overnight premium while avoiding adverse sentiment regimes.

## Trading Rules

### Sentiment Filters (Choose One)
1. **BMS Filter**: Buy SPY at the close when BMS > 20-day MA of BMS. Sell at next open.
2. **VIX Filter**: Buy SPY at the close when VIX < 20-day MA of VIX. Sell at next open.
3. **SPY Trend Filter**: Buy SPY at the close when SPY close > 20-day MA of SPY. Sell at next open.

### Entry/Exit
1. **Entry**: Buy at the close when the chosen sentiment filter is positive.
2. **Exit**: Sell at the next open.
3. **No position** when the sentiment filter is negative.
4. **Direction**: Long only.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.369 (base overnight) / 1.71-1.92 (with sentiment filters) |
| CAGR | ~5% (base) / 15-16% (with sentiment filters) |
| Max Drawdown | ~12% (with filters) |
| Win Rate | ~55% |
| Volatility | 3.6% (daily, base) / ~8% (with filters, annualized) |
| Profit Factor | ~1.5 (with filters) |
| Rebalancing | Daily |

*Note: Sentiment-filtered variants dramatically outperform the unfiltered overnight strategy. SPY trend filter (Sharpe 1.92) slightly outperforms VIX filter (Sharpe 1.80) and BMS filter (Sharpe 1.71). Transaction costs are high, making this better as an overlay than standalone.*

## Efficacy Rating

**3/5** — The sentiment overlay meaningfully improves the overnight anomaly's risk-adjusted returns, with Sharpe ratios jumping from 0.37 to 1.7-1.9. The SPY trend filter is the simplest and most effective. However, the paper's own authors note that transaction costs make this impractical as a standalone strategy and recommend using it as an overlay for trade timing decisions. The concept of sentiment-filtered overnight positioning is valuable even if the specific implementation is cost-challenged.

## Academic References

- Vojtko, R. & Hanicova, D. — "Market Sentiment and an Overnight Anomaly" (SSRN, 2021) — primary paper
- Aboody, D. et al. — "Overnight Returns and Firm-Specific Investor Sentiment" (2018)
- Baker, M. & Wurgler, J. — "Investor Sentiment and the Cross-Section of Stock Returns" (2006)

## Implementation Notes

- **Transaction cost warning**: The authors explicitly note that daily round-trip costs make this impractical as a standalone strategy. Use it as an overlay to filter timing of existing trades.
- **SPY filter is simplest**: The SPY > 20-day MA filter produces the best Sharpe (1.92) and requires no external data feeds (BMS requires NLP sentiment data, VIX requires options data).
- **NLP sentiment access**: The Brain Market Sentiment indicator requires a subscription. For a pure Zig implementation, building an equivalent NLP sentiment score from news feeds would be a significant engineering effort.
- **Crypto adaptation**: Use a crypto-specific fear/greed index or social sentiment score as the filter. Define "overnight" as the US equity close-to-open window. The VIX filter could be replaced with a crypto implied volatility measure (e.g., Deribit DVOL).
- **Overlay approach**: Rather than trading this as a standalone strategy, use the sentiment filter to decide whether to hold existing positions overnight or close them before the session ends.
- **Regime dependence**: The sentiment filters effectively avoid holding overnight during bearish regimes, which is when the overnight premium is weakest or negative.
