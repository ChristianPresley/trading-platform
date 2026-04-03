# Funding Rate Carry

> **Source**: [BIS Working Papers No. 1087 - Crypto Carry](https://www.bis.org/publ/work1087.pdf); Academic research on crypto basis
> **Asset Class**: Cryptocurrency (Derivatives)
> **Crypto/24-7 Applicable**: Yes --- perpetual futures trade 24/7 with funding every 8 hours
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Moderate

## Overview

Captures the funding rate premium embedded in cryptocurrency perpetual futures contracts. Perpetual futures use a periodic funding mechanism (typically every 8 hours) to anchor the futures price to the spot price. When the funding rate is positive (the common case in bull markets), long holders pay short holders. The carry strategy goes short the perpetual while holding long spot, earning the funding rate as income. This is a delta-neutral strategy that profits from the structural demand imbalance for leveraged long exposure in crypto markets.

## Trading Rules

1. **Monitor Funding Rates**: Track the predicted and historical funding rates across perpetual futures exchanges (e.g., Kraken Futures, Binance, Bybit).
2. **Entry Condition**: Enter the trade when the annualized funding rate exceeds a threshold (e.g., > 15% annualized) that justifies the operational costs and risks.
3. **Position Construction**: Buy spot BTC/ETH (or deposit as collateral) and simultaneously open an equal-sized short perpetual futures position. The net delta exposure should be approximately zero.
4. **Funding Collection**: Collect funding payments every 8 hours as long as the rate remains positive.
5. **Exit Condition**: Unwind the position when the funding rate drops below breakeven (e.g., < 5% annualized) or turns negative for sustained periods.
6. **Rebalancing**: Adjust position sizes as mark-to-market changes create delta drift. Rebalance when delta deviates more than 5% from neutral.
7. **Risk Management**: Monitor exchange margin requirements carefully. A sharp price move can trigger margin calls on the short futures leg even though the spot leg offsets it economically.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 1.5 - 3.0 |
| CAGR | 15% - 40% (depends on funding rate environment) |
| Max Drawdown | -5% to -15% (primarily from basis risk and margin events) |
| Win Rate | 70% - 85% |
| Volatility | 8% - 20% annualized |
| Profit Factor | 2.5 - 5.0 |
| Rebalancing | Every 8 hours (funding intervals) |

## Efficacy Rating

**4/5** --- One of the most reliable alpha sources in crypto. Funding rates have been persistently positive due to structural demand for leveraged long exposure from retail speculators. Academic research (BIS, CMU) documents annualized funding rates exceeding 40% during bull markets. The strategy has clear economic rationale (carry/risk premium) and is well-understood in traditional finance (similar to FX carry). Primary risks are exchange counterparty risk, margin liquidation during flash crashes (when cross-margining is unavailable), and funding rate regime changes. Performance degrades significantly during bear markets when funding rates turn negative.

## Academic References

- Schmeling, M. et al. (2023). "Crypto Carry." *BIS Working Papers No. 1087*. [BIS](https://www.bis.org/publ/work1087.pdf)
- He, S. & Manela, A. (2022). "Fundamentals of Perpetual Futures." [arXiv:2212.06888](https://arxiv.org/html/2212.06888v5)
- Ackerer, D., Hugonnier, J., & Jermann, U. (2025). "Perpetual Futures Pricing." *Mathematical Finance*. [Wiley](https://onlinelibrary.wiley.com/doi/10.1111/mafi.70018)
- Alexander, C., Choi, J., Park, H., & Sohn, S. (2020). "BitMEX Bitcoin Derivatives: Price Discovery, Informational Efficiency, and Hedging Effectiveness." *Journal of Futures Markets*, 40(1), 23-43.

## Implementation Notes

- **Cross-Margining**: The absence of cross-margining between spot and futures on most exchanges is a critical friction. Capital must effectively fund both legs separately, reducing capital efficiency.
- **Exchange Selection**: Choose exchanges with transparent funding rate formulas, reliable margin systems, and strong solvency. Prefer exchanges with portfolio margining if available.
- **Monitoring**: Requires 24/7 monitoring of margin ratios and funding rate changes. Automated alerts for margin threshold breaches are essential.
- **Funding Rate Variability**: Rates can swing from +100% annualized to -30% annualized within days. The strategy needs clear rules for when to enter, hold, and exit based on rate regime.
- **Pure Zig Implementation**: Well-suited for Zig. The strategy logic (funding rate comparison, delta calculation, rebalancing triggers) is straightforward arithmetic. WebSocket connections to track real-time funding rates use Zig std lib networking.
- **Tax Considerations**: Funding payments may have different tax treatment than trading gains in some jurisdictions. Consult tax advisors.
