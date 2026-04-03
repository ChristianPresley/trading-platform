# FX Carry Trade

> **Source**: [Awesome Systematic Trading](https://github.com/edarchimbaud/awesome-systematic-trading-strategies)
> **Asset Class**: Foreign Exchange
> **Crypto/24-7 Applicable**: Adaptable — stablecoin yield differentials (e.g., lending rates across USDT, USDC, DAI) create analogous carry opportunities, though the underlying risk drivers differ substantially from sovereign interest rates
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Simple

## Overview

The FX carry trade is one of the oldest and most widely studied currency strategies. The core idea is simple: borrow in a low-interest-rate currency (the "funding" currency) and invest in a high-interest-rate currency (the "target" currency), capturing the interest rate differential as profit. According to uncovered interest rate parity (UIP), the expected depreciation of the high-yield currency should offset the interest rate advantage, making the trade unprofitable in expectation. The carry trade's profitability directly exploits the well-documented failure of UIP — the "forward premium puzzle" — one of the most persistent anomalies in international finance.

Empirically, high-yield currencies depreciate less than UIP predicts (and sometimes appreciate), generating positive excess returns for carry traders. The strategy has been profitable across multiple decades and currency pairs, though it is punctuated by severe crash episodes during global risk-off events. The diversified carry trade, spreading exposure across multiple currency pairs, substantially improves the Sharpe ratio by reducing idiosyncratic currency risk while retaining exposure to the systematic carry premium. Academic research by Lustig and Verdelhan (2007) shows that carry trade returns compensate for consumption growth risk, while Brunnermeier, Nagel, and Pedersen (2009) link carry crashes to unwinding of leveraged positions during liquidity crises.

## Trading Rules

1. **Universe**: G10 currencies or a broader set of 20-30 liquid currencies with freely floating exchange rates and accessible forward markets.

2. **Signal Construction**: At the end of each month, rank all currencies by their short-term interest rate (or equivalently, the forward discount/premium against a base currency such as USD).

3. **Portfolio Construction**:
   - **Long Portfolio**: Go long the top 3-5 highest-yielding currencies (equal-weighted or GDP-weighted).
   - **Short Portfolio**: Go short the bottom 3-5 lowest-yielding currencies.
   - The portfolio is dollar-neutral (equal notional on long and short sides).

4. **Instrument**: Execute via 1-month or 3-month FX forwards, which embed the interest rate differential directly into the forward price.

5. **Rebalancing**: Monthly. Re-rank currencies by interest rate and adjust positions accordingly.

6. **Risk Management**: Apply volatility targeting (e.g., scale position sizes to maintain a 10% annualized volatility target). Optionally, reduce exposure when VIX exceeds a threshold (e.g., 25) to mitigate crash risk.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 0.254 (simple), 0.42-0.89 (diversified portfolios) |
| CAGR | 3-5% (excess return, unlevered) |
| Max Drawdown | -20% to -35% (2008 GFC, 2020 COVID) |
| Win Rate | 60-65% (monthly) |
| Volatility | 7.8% (simple), 5.1% (diversified) |
| Profit Factor | 1.3-1.6 |
| Rebalancing | Monthly |

The simple carry trade (single pair or small basket) shows modest risk-adjusted returns with a Sharpe of 0.254 per the Awesome Systematic Trading dataset. Diversified carry portfolios across 20+ currencies achieve materially higher Sharpe ratios of 0.78-1.02 due to imperfect correlation across currency pairs. Managed carry strategies with volatility scaling can push the Sharpe to 1.07, though these enhanced versions introduce model risk.

## Efficacy Rating

**Rating: 4/5** — The FX carry trade is among the most well-documented currency anomalies, backed by decades of academic research and live trading results. The premium persists because it compensates for crash risk (negative skewness), and the strategy's simplicity makes it accessible. The deduction reflects the strategy's severe left-tail risk: carry trades can lose years of accumulated profits in weeks during global deleveraging events (e.g., the JPY carry unwind of 2008, the CHF de-peg of 2015). The modest Sharpe of the unmanaged version also limits standalone attractiveness.

## Academic References

- Lustig, H., & Verdelhan, A. (2007). "The Cross-Section of Foreign Currency Risk Premia and Consumption Growth Risk." *American Economic Review*, 97(1), 89-117.
- Brunnermeier, M. K., Nagel, S., & Pedersen, L. H. (2009). "Carry Trades and Currency Crashes." *NBER Macroeconomics Annual*, 23, 313-347.
- Burnside, C., Eichenbaum, M., Kleshchelski, I., & Rebelo, S. (2011). "Do Peso Problems Explain the Returns to the Carry Trade?" *Review of Financial Studies*, 24(3), 853-891.
- Menkhoff, L., Sarno, L., Schmeling, M., & Schrimpf, A. (2012). "Carry Trades and Global Foreign Exchange Volatility." *The Journal of Finance*, 67(2), 681-718.
- Daniel, K., Hodrick, R. J., & Lu, Z. (2017). "The Carry Trade: Risks and Drawdowns." *Critical Finance Review*, 6, 211-262.
- Dupuy, P. (2021). "Risk-Adjusted Return Managed Carry Trade." *Journal of Banking & Finance*, 129.

## Implementation Notes

- **Data Requirements**: Daily or monthly interest rate differentials (or forward points) for each currency pair. Central bank policy rates can serve as a proxy when forward data is unavailable.
- **Transaction Costs**: FX forwards for G10 currencies are highly liquid with tight bid-ask spreads (1-3 pips). EM currencies have wider spreads (10-50 pips), which can erode a significant portion of the carry.
- **Crash Risk Mitigation**: The Barroso and Santa-Clara (2015) volatility-timing approach — scaling position sizes inversely with recent carry portfolio volatility — substantially reduces crash exposure and improves the Sharpe ratio. Combining carry with momentum signals also helps, as momentum tends to signal exits during sustained carry unwinds.
- **Crypto Adaptation**: DeFi lending rate differentials across stablecoins and protocols create analogous carry opportunities. Borrow at low rates on Aave (e.g., USDC at 2-4%) and lend at higher rates on another protocol or chain. Key differences: smart contract risk replaces sovereign risk, yield differentials are larger but more volatile, and "crashes" manifest as protocol exploits or depeg events rather than currency crashes.
- **Leverage Considerations**: Institutional carry trades typically employ 2-5x leverage to generate meaningful absolute returns from small interest rate differentials. Leverage amplifies both returns and drawdowns, making position sizing and risk management critical.
