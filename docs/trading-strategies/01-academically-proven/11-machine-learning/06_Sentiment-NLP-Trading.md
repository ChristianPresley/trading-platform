# Sentiment NLP Trading

> **Source**: Academic research on NLP sentiment analysis for financial markets
> **Asset Class**: Equities (adaptable to other asset classes)
> **Crypto/24-7 Applicable**: Adaptable --- sentiment analysis applies to any asset class with sufficient text data (news, social media, forums)
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

Uses natural language processing to extract sentiment signals from financial text sources --- news articles, earnings call transcripts, analyst reports, and social media --- to generate trading signals. Unlike the Lexical Density strategy (which analyzes SEC filing structure), this approach directly classifies the emotional tone and opinion polarity of financial text. Positive sentiment predicts positive short-term returns; negative sentiment predicts negative returns. Modern approaches use pre-trained language models (FinBERT, GPT-based models) that significantly outperform earlier dictionary-based methods (Loughran-McDonald) and simple classifiers (Naive Bayes).

## Trading Rules

1. **Data Sources**: Ingest financial news (Reuters, Bloomberg, financial news APIs), earnings call transcripts, analyst reports, and optionally social media (Twitter/X, StockTwits, Reddit).
2. **Sentiment Extraction**: Apply a financial sentiment model to each text document:
   - **Dictionary-Based**: Score using Loughran-McDonald financial sentiment dictionary (simple, interpretable, but limited).
   - **ML-Based**: Use FinBERT or a fine-tuned BERT model for more accurate sentiment classification (positive, negative, neutral, with confidence score).
3. **Aggregation**: For each asset, aggregate sentiment scores over a rolling window (e.g., past 24 hours for news, past 1-4 hours for social media). Compute: net sentiment score, sentiment volume, and sentiment change rate.
4. **Signal Generation**: Go long when the aggregate sentiment score exceeds a positive threshold and sentiment is improving (positive rate of change). Go short or exit when sentiment is negative and deteriorating.
5. **Multi-Source Fusion**: Weight different sources by their historical predictive power. News tends to be more predictive than social media for equities; the reverse may be true for crypto.
6. **Decay Factor**: Apply an exponential decay to older texts. Recent sentiment matters more than sentiment from 24 hours ago.
7. **Risk Management**: Maximum 2% portfolio risk per trade. Reduce positions during earnings blackout periods when sentiment signals are unreliable. Stop-loss at 1.5x ATR.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.6 - 1.3 |
| CAGR | 8% - 20% |
| Max Drawdown | -12% to -25% |
| Win Rate | 53% - 60% |
| Volatility | 10% - 18% annualized |
| Profit Factor | 1.2 - 1.5 |
| Rebalancing | Daily to intraday |

## Efficacy Rating

**3/5** --- Sentiment analysis is one of the most researched areas in financial ML, and academic evidence confirms predictive power for short-term returns. Modern transformer-based models (FinBERT) achieve significantly higher accuracy than dictionary methods, and integrating textual data consistently improves Sharpe ratios in backtests. However, several practical challenges limit efficacy: data acquisition costs are high, sentiment signals are crowded (many funds now use NLP), alpha decays quickly (within hours for news), and the models require continuous updating as language and market narratives evolve. False signals from sarcasm, market manipulation, and bot activity are ongoing challenges.

## Academic References

- Loughran, T. & McDonald, B. (2011). "When is a Liability Not a Liability? Textual Analysis, Dictionaries, and 10-Ks." *Journal of Finance*, 66(1), 35-65.
- Araci, D. (2019). "FinBERT: Financial Sentiment Analysis with Pre-Trained Language Models." [arXiv:1908.10063](https://arxiv.org/abs/1908.10063)
- Tetlock, P. C. (2007). "Giving Content to Investor Sentiment: The Role of Media in the Stock Market." *Journal of Finance*, 62(3), 1139-1168.
- Huang, A., Wang, H., & Yang, Y. (2023). "FinGPT: Open-Source Financial Large Language Models." [arXiv:2306.06031](https://arxiv.org/abs/2306.06031)

## Implementation Notes

- **Model Selection Trade-offs**: Dictionary methods (Loughran-McDonald) are fast, transparent, and require no training but have limited accuracy. FinBERT is more accurate but requires GPU for efficient inference. LLM-based approaches (GPT) are the most accurate but have the highest latency and cost.
- **Data Pipeline**: Building a reliable, low-latency news and social media ingestion pipeline is the primary engineering challenge. Consider financial data providers (e.g., Benzinga, NewsAPI) for structured feeds.
- **Latency**: Sentiment alpha decays within hours. For news-based signals, processing within minutes of publication is ideal. Social media signals may be even more time-sensitive.
- **Crypto Adaptation**: Highly applicable. Crypto markets are heavily influenced by social media sentiment, and text data from Twitter/X, Reddit, and Telegram is abundant. Crypto-specific fine-tuned models may be needed.
- **Pure Zig Implementation**: The trading signal logic (aggregation, thresholds, portfolio management) is straightforward in Zig. Sentiment model inference is the challenge: dictionary-based scoring is trivially implementable; transformer model inference would require implementing matrix operations and attention mechanisms, or using a pre-computed sentiment score feed from an offline Python service.
- **Crowding Risk**: As NLP-based trading becomes ubiquitous, the alpha from sentiment signals compresses. Differentiation requires proprietary data sources, faster processing, or more nuanced models.
