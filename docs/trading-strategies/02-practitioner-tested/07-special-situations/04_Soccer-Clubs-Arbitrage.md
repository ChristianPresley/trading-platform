# Soccer Clubs' Stocks Arbitrage

> **Source**: [Awesome Systematic Trading](https://github.com/paperswithbacktest/awesome-systematic-trading), [Quantpedia — Soccer Clubs' Stocks Arbitrage](https://quantpedia.com/strategies/soccer-clubs-stocks-arbitrage)
> **Asset Class**: Equities (publicly listed soccer/football clubs)
> **Crypto/24-7 Applicable**: No — requires publicly listed sports club stocks, which are a niche equity market segment with no crypto equivalent
> **Evidence Tier**: Backtested Only
> **Complexity**: Moderate

## Overview

This strategy exploits a behavioral anomaly in publicly listed soccer club stocks: investors systematically overvalue club stocks before important matches, driven by optimistic expectations of positive outcomes. Since the probability of any individual match outcome is closer to random than investors price in, the strategy profits by shorting club stocks before important matches (when they are overvalued due to fan optimism) and covering after the match, when reality often disappoints expectations.

The academic research documents that teams frequently draw or lose matches, producing negative post-match stock returns that outweigh the positive returns from wins. A simple short-before-match strategy captures this asymmetry. A more sophisticated version hedges the equity market exposure using betting market odds, creating a purer arbitrage between the financial market (stock) and the prediction market (betting odds).

The Awesome Systematic Trading repository documents this strategy with a Sharpe ratio of 0.515 and 14.2% annualized volatility, with daily rebalancing. Independent research from Quantpedia suggests even higher returns (40%+ p.a.) with a Sharpe of approximately 0.76, though at 50% volatility.

## Trading Rules

1. **Universe**: Publicly listed soccer/football club stocks. Key listings include:
   - Manchester United (MANU — NYSE)
   - Juventus (JUVE — Borsa Italiana)
   - Borussia Dortmund (BVB — Frankfurt)
   - Ajax (AJAX — Euronext Amsterdam)
   - Benfica (SLBEN — Euronext Lisbon)
   - Various Turkish clubs (Galatasaray, Fenerbahce, Besiktas — Borsa Istanbul)

2. **Match Identification**: Monitor fixture lists for "important" matches:
   - UEFA Champions League / Europa League matches.
   - Domestic league derbies and top-of-table clashes.
   - Domestic cup finals and semi-finals.

3. **Entry (Short)**: Short the club's stock 1-2 trading days before an important match.

4. **Exit**: Cover the short position 1 trading day after the match result.

5. **Hedged Version**: Simultaneously place a bet on the team to win in the betting market. If the team wins (stock rises), the betting profit offsets the short loss. If the team loses/draws (stock falls), the short profit offsets the betting loss.

6. **Position Sizing**: Equal-weight across all active short positions. Maximum 5% of portfolio per club.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.515 |
| CAGR | ~15-40% (depending on universe and leverage) |
| Max Drawdown | -20% to -35% |
| Win Rate | ~55-60% (matches where stock declines post-match) |
| Volatility | 14.2% annualized |
| Profit Factor | ~1.3-1.6 |
| Rebalancing | Daily (match-event driven) |

The Sharpe ratio of 0.515 at 14.2% volatility reflects a meaningful edge driven by behavioral mispricing. The high estimated CAGR (Quantpedia reports 40%+) likely overstates achievable returns due to liquidity constraints in thinly traded soccer club stocks. The strategy's return is driven by the asymmetry between fan-driven optimism (which inflates pre-match prices) and the probabilistic reality that most match outcomes disappoint optimistic expectations.

## Efficacy Rating

**Rating: 2/5** — While the behavioral anomaly is well-documented and the economic logic (fan overoptimism in stock pricing) is compelling, severe practical limitations reduce the strategy's deployable value: (a) most soccer club stocks are extremely illiquid (daily volume often below $500K), making position entry/exit at quoted prices difficult, (b) the short-selling borrow market for these stocks is thin to nonexistent, (c) the universe of publicly listed clubs is small (10-15 stocks globally), limiting diversification, (d) the strategy requires monitoring global soccer fixture schedules and match results across multiple time zones, and (e) no crypto applicability. The academic Sharpe ratio is likely unachievable at any meaningful scale.

## Academic References

- Bernile, G., & Lyandres, E. (2011). "Understanding Investor Sentiment: The Case of Soccer." *Financial Management*, 40(2), 357-380.
- Edmans, A., Garcia, D., & Norli, O. (2007). "Sports Sentiment and Stock Returns." *The Journal of Finance*, 62(4), 1967-1998.
- Palomino, F., Renneboog, L., & Zhang, C. (2009). "Information Salience, Investor Sentiment, and Stock Returns: The Case of British Soccer Betting." *Journal of Corporate Finance*, 15(3), 368-387.
- Stadtmann, G. (2006). "Frequent News and Pure Signals: The Case of a Publicly Traded Football Club." *Scottish Journal of Political Economy*, 53(4), 485-504.

## Implementation Notes

- **Liquidity Constraints**: This is the primary barrier to implementation. Most soccer club stocks trade less than $1M daily. Market impact from even modest positions ($50K-$100K) can move prices. This makes the strategy a curiosity rather than a deployable system at any meaningful scale.
- **Short-Selling Availability**: Borrowing shares of thinly traded European soccer club stocks is extremely difficult. Many brokers will not have shares available for short selling. The hedged version (pairing stock shorts with betting market longs) partially addresses this but introduces betting market counterparty risk.
- **Betting Market Integration**: The hedged version requires simultaneous execution in equity and betting markets. Betting odds for soccer matches are highly liquid and efficient, but regulatory restrictions on sports betting vary by jurisdiction.
- **Seasonal Pattern**: Soccer seasons run from August to May (European leagues), with a mid-season break. The strategy generates no signals during the summer off-season, creating extended idle periods.
- **Turkish Market Opportunity**: Turkish soccer club stocks (Galatasaray, Fenerbahce, Besiktas) tend to have higher volatility and more pronounced fan-driven mispricing, but also face additional risks including currency volatility (TRY) and political/regulatory uncertainty.
- **No Crypto Application**: There is no crypto equivalent to publicly listed sports clubs. Fan tokens (e.g., Chiliz/CHZ ecosystem) are conceptually related but have different pricing dynamics and are not tied to match outcomes in the same way as equity shares.
