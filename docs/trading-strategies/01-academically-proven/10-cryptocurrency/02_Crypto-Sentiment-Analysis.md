# Crypto Sentiment Analysis

> **Source**: [151 Trading Strategies, Ch. 18](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) (Kakushadze & Serur, 2018)
> **Asset Class**: Cryptocurrency
> **Crypto/24-7 Applicable**: Yes --- social media and news operate 24/7 like crypto markets
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

Applies natural language processing (NLP) techniques, primarily Naive Bayes and related classifiers, to social media posts (Twitter/X, Reddit), news articles, and forum discussions to generate trading signals for cryptocurrencies. Sentiment scores are aggregated over rolling windows and used as directional indicators. The strategy exploits the strong correlation between retail sentiment and short-term crypto price movements, a relationship well-documented in academic literature.

## Trading Rules

1. **Data Collection**: Continuously ingest text data from Twitter/X (hashtags: #Bitcoin, #BTC, #ETH), Reddit (r/Bitcoin, r/CryptoCurrency), and crypto news feeds.
2. **Preprocessing**: Tokenize, remove stop words, stem/lemmatize. Extract features using TF-IDF or Count Vectorizer.
3. **Classification**: Apply Multinomial Naive Bayes or Bernoulli Naive Bayes to classify each text as positive, negative, or neutral sentiment.
4. **Aggregation**: Compute a rolling sentiment score (e.g., net positive ratio over the past 1-4 hours).
5. **Signal Generation**: Go long when the sentiment score exceeds a threshold (e.g., > 0.6 net positive) and the rate of change in sentiment is positive. Go short or exit when sentiment drops below a threshold (e.g., < 0.4).
6. **Confirmation Filter**: Optionally combine with a price-based trend filter (e.g., price above 20-period EMA) to avoid counter-trend sentiment trades.
7. **Risk Management**: Position size inversely proportional to recent BTC realized volatility. Maximum 2% portfolio risk per trade. Stop-loss at 1.5x ATR.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.8 - 1.5 |
| CAGR | 20% - 50% (highly variable) |
| Max Drawdown | -25% to -45% |
| Win Rate | 55% - 62% |
| Volatility | 35% - 55% annualized |
| Profit Factor | 1.2 - 1.6 |
| Rebalancing | Intraday (1-hour to 4-hour signals) |

## Efficacy Rating

**3/5** --- Sentiment analysis shows genuine predictive power for short-term crypto movements, particularly around major events and narrative shifts. However, the signal-to-noise ratio in social media data is low. Naive Bayes classifiers achieve approximately 62% accuracy on crypto sentiment classification, which is meaningful but not overwhelming. The strategy is vulnerable to bot activity, coordinated manipulation, and sentiment regime changes. Alpha decays rapidly as more participants adopt similar NLP approaches. Data pipeline reliability is a significant operational risk.

## Academic References

- Abraham, J., Higdon, D., Nelson, J., & Ibarra, J. (2018). "Cryptocurrency Price Prediction Using Tweet Volumes and Sentiment Analysis." *SMU Data Science Review*, 1(3).
- Liu, Y. & Tsyvinski, A. (2021). "Risks and Returns of Cryptocurrency." *Review of Financial Studies*, 34(6), 2689-2727. [Oxford Academic](https://academic.oup.com/rfs/article-abstract/34/6/2689/5912024)
- Kakushadze, Z. & Serur, J. A. (2018). "151 Trading Strategies." *Palgrave Macmillan*. [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865)
- Pano, T. & Kashef, R. (2020). "A Complete VADER-Based Sentiment Analysis of Bitcoin (BTC) Tweets during the Era of COVID-19." *Big Data and Cognitive Computing*, 4(4), 33.

## Implementation Notes

- **Data Pipeline Complexity**: The primary challenge is building a reliable, low-latency text ingestion pipeline. Twitter/X API rate limits and Reddit API changes can disrupt data flow.
- **Model Drift**: Sentiment vocabulary evolves rapidly in crypto. Slang, memes, and context shift frequently. Models require periodic retraining on fresh labeled data.
- **Latency**: Sentiment signals are useful on 1-hour to 4-hour horizons. Sub-second latency is not critical for signal generation, but timely data ingestion matters.
- **Pure Zig Consideration**: Naive Bayes inference is straightforward to implement in Zig (log-probability lookups against a vocabulary). The trained model is just a probability table that can be loaded from a file. Data ingestion (HTTP, JSON parsing) would use the Zig std lib HTTP client and JSON parser.
- **False Signal Risk**: Major coordinated social media campaigns (pump-and-dump schemes) can generate false positive sentiment. Consider anomaly detection on message volume spikes.
