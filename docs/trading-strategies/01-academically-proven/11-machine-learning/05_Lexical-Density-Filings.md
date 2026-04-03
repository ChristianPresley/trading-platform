# Lexical Density of Company Filings

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading); [Hanicova, Kalus & Vojtko (2021)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3921091)
> **Asset Class**: Equities (US large/mid-cap)
> **Crypto/24-7 Applicable**: No --- requires SEC filings (10-K, 10-Q) which are equity-specific
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

Applies natural language processing to SEC filings (10-K and 10-Q reports) to extract lexical metrics --- specifically lexical density and specific density --- as predictive signals for future stock returns. Lexical density measures the proportion of content-carrying words (nouns, verbs, adjectives, adverbs) relative to total words, indicating the information richness and complexity of the document. Higher lexical density suggests more substantive, information-rich filings, while lower density may indicate evasive or boilerplate language. The strategy uses the Brain Language Metrics on Company Filings (BLMCF) dataset and sorts stocks into portfolios based on these linguistic features.

## Trading Rules

1. **Data Source**: Obtain lexical metrics from SEC EDGAR filings (10-K annual, 10-Q quarterly reports). Use the BLMCF dataset or compute metrics from raw filings.
2. **Metric Calculation**: For each company filing, compute:
   - **Lexical Density**: Content words / Total words
   - **Specific Density**: Unique content words / Total content words
   - **Readability Score**: Flesch-Kincaid or Gunning-Fog index (optional supplement)
3. **Universe**: Top 500 US stocks by market capitalization (approximating the S&P 500).
4. **Sorting**: Rank stocks by lexical density and specific density. Form quintile portfolios: long the top quintile (highest density = most informative filings), short the bottom quintile (lowest density = least informative).
5. **Rebalancing**: Monthly, aligned with filing release dates. Earnings season quarters (Q1, Q3) produce the most signal.
6. **Weighting**: Equal-weight within each quintile.
7. **Risk Management**: Sector neutrality constraints to avoid unintended sector bets. Maximum 5% position size per stock.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.688 |
| CAGR | ~7% (estimated from Sharpe and volatility) |
| Max Drawdown | -15% to -20% |
| Win Rate | 52% - 55% |
| Volatility | 10.4% annualized |
| Profit Factor | 1.1 - 1.3 |
| Rebalancing | Monthly |

## Efficacy Rating

**3/5** --- The strategy is grounded in a compelling behavioral hypothesis: managers who use more substantive, information-dense language in filings are signaling genuine confidence and transparency, while those who rely on boilerplate or vague language may be obfuscating poor performance. Backtested results show a meaningful Sharpe ratio of 0.688 with moderate volatility of 10.4%. However, the alpha is relatively small and may be partially explained by other factors (quality, profitability). The strategy is slow-moving (monthly rebalancing on quarterly filings) and cannot be applied to crypto or non-US markets. NLP preprocessing quality significantly impacts results.

## Academic References

- Hanicova, D., Kalus, F., & Vojtko, R. (2021). "How to Use Lexical Density of Company Filings." *SSRN Working Paper*. [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3921091)
- Loughran, T. & McDonald, B. (2011). "When is a Liability Not a Liability? Textual Analysis, Dictionaries, and 10-Ks." *Journal of Finance*, 66(1), 35-65.
- Bonsall, S. B. et al. (2017). "A Plain English Measure of Financial Reporting Readability." *Journal of Accounting and Economics*, 63(2-3), 329-357.
- Cohen, L., Malloy, C., & Nguyen, Q. (2020). "Lazy Prices." *Journal of Finance*, 75(3), 1371-1415.

## Implementation Notes

- **Data Acquisition**: SEC EDGAR provides free access to all filings. Parsing 10-K/10-Q HTML or XBRL documents requires robust text extraction. The BLMCF dataset provides pre-computed metrics for those who prefer not to build the NLP pipeline.
- **NLP Pipeline**: Tokenization, POS tagging, and lexical categorization are required. Libraries like spaCy or NLTK can handle this, though the pipeline would run offline.
- **Filing Lag**: Filings are released on specific dates. The strategy must only use filing data after its public release date to avoid look-ahead bias.
- **Signal Decay**: Lexical metrics from a given filing remain relevant until the next filing period (quarterly). The signal is inherently slow-moving.
- **Not Crypto Applicable**: This strategy is fundamentally tied to SEC filings and the US equity market. There is no crypto equivalent of standardized corporate filings.
- **Pure Zig Implementation**: The trading logic (sorting, portfolio construction, rebalancing) is trivially implementable in Zig. The NLP preprocessing would run offline in Python, producing a simple lookup table of lexical metrics per stock per quarter.
