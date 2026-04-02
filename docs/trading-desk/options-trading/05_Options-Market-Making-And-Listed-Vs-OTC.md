## Options Market Making

### Delta Hedging

The core activity of options market makers. After selling an option, the market maker buys delta-equivalent shares to neutralize directional risk.

**Process:**
1. Sell a call with delta = 0.45. Buy 45 shares per contract (assuming equity options with 100 multiplier).
2. As the underlying moves, delta changes. Rebalance by buying or selling shares.
3. The frequency of rehedging is a function of: gamma exposure, transaction costs, and risk tolerance.

**Hedging frequency:**
- High gamma positions near expiration: hedge continuously (every few minutes).
- Low gamma positions: hedge daily or when delta drift exceeds a threshold (e.g., re-hedge when position delta changes by more than $X or Y% of notional).

**Discrete hedging error:** In practice, hedging is not continuous. The P&L from a delta-hedged option position over one hedging interval is approximately:

```
P&L = 0.5 * Gamma * (realized_move^2 - implied_move^2)
```

Where implied_move = IV * S * sqrt(dt). This is the gamma P&L.

### Gamma Scalping

A strategy where the market maker is long gamma (long options) and repeatedly rebalances the delta hedge.

- When the underlying rises, delta increases. Sell shares to rebalance (sell high).
- When the underlying falls, delta decreases. Buy shares to rebalance (buy low).
- Each rebalancing cycle locks in a small profit proportional to gamma x move^2.
- The cost of the strategy is theta decay. Profitability depends on realized volatility exceeding implied volatility.

**Break-even realized vol:** The annualized realized volatility at which gamma scalping P&L exactly offsets theta decay. Equals the implied volatility at which the options were purchased.

### Volatility Trading

Market makers and volatility traders are ultimately trading the spread between implied and realized volatility.

- **Long volatility (long gamma):** Buy options, delta-hedge. Profit if realized vol > implied vol.
- **Short volatility (short gamma):** Sell options, delta-hedge. Profit if realized vol < implied vol.
- **Variance swaps:** A pure play on realized vs implied variance, traded OTC. The payoff is (realized_variance - strike_variance) x notional. No path dependency in terms of skew — depends only on the final realized variance.
- **VIX futures and options:** Trade the market's expectation of 30-day forward implied volatility.

### Skew Trading

Exploiting relative mispricings in the volatility surface.

- **Risk reversal:** Sell an OTM put and buy an OTM call (or vice versa) to trade the skew level. A negative risk reversal (selling puts richer than calls) profits if skew decreases.
- **Butterfly:** A long 25-delta butterfly (buy wings, sell body) is a play on the curvature of the smile. Profits if realized kurtosis exceeds implied kurtosis.
- **Calendar skew trade:** Differences in skew between near-dated and far-dated expirations.
- **Dispersion trading:** Sell index options (expensive due to correlation premium) and buy single-stock options. Profits if realized correlation is lower than implied correlation.

---

## Listed Options vs OTC Options

### Exchange-Traded (Listed) Options

#### Major U.S. Options Exchanges

| Exchange | Code | Notes |
|---|---|---|
| **Cboe Options Exchange** | CBOE | Largest options exchange. Home of VIX, SPX options. |
| **Cboe BZX Options** | BATS | Electronic-only. Competitive pricing. |
| **Cboe EDGX Options** | EDGX | Price-time priority. |
| **Cboe C2 Options** | C2 | Pro-rata allocation model. |
| **NYSE Arca Options** | ARCA | Price-time priority with directed orders. |
| **NYSE American Options** | AMEX | Pro-rata allocation for certain classes. |
| **Nasdaq PHLX** | PHLX | Specialist model. Key for FX options. |
| **Nasdaq ISE** | ISE | Electronic pro-rata model. |
| **Nasdaq GEMX** | GEMX | Price-time priority. |
| **Nasdaq MRX** | MRX | Price-time priority. |
| **MIAX Options** | MIAX | Price-time priority. |
| **MIAX Pearl** | PEARL | Electronic-only. |
| **MIAX Emerald** | EMERALD | Pro-rata allocation. |
| **BOX Options** | BOX | Price Improvement Period (PIP) mechanism. |
| **Cboe EDGX Options** | EDGX | Retail priority. |
| **MEMX Options** | MEMX | Newest entrant (2024). |

#### Key Features of Listed Options

- **Standardized contracts:** Fixed multiplier (100 shares for equity options), standard expirations (monthly, weekly, daily for high-volume underlyings).
- **Central clearing:** All trades cleared through the OCC. Counterparty risk is eliminated.
- **Transparency:** Real-time quotes, volume, open interest. OPRA (Options Price Reporting Authority) disseminates data.
- **Penny increments:** Most actively traded options quote in $0.01 increments. Less active names may quote in $0.05 or $0.10.
- **NBBO compliance:** Best bid and offer across all exchanges must be respected. Exchanges cannot trade through a better price on another exchange.

#### SPX Options Specifics

- European-style exercise.
- Cash-settled based on the Special Opening Quotation (SOQ) for AM-settled, or closing price for PM-settled.
- Multiplier: $100.
- SPX weeklys (SPXW) expire Monday, Wednesday, and Friday.
- Section 1256 tax treatment: 60% long-term / 40% short-term capital gains regardless of holding period.

#### VIX Options

- Based on the Cboe Volatility Index.
- European-style, cash-settled.
- Settlement is based on a Special Opening Quotation of the VIX on expiration morning (VIX SOQ), which can differ significantly from the prior close.
- No direct arbitrage relationship to VIX futures — VIX options are priced off VIX futures, not the VIX index itself.

### OTC Options

#### ISDA Documentation

OTC options are governed by ISDA (International Swaps and Derivatives Association) documentation:

- **ISDA Master Agreement** — The overarching legal framework covering all OTC derivatives between two counterparties. Includes default provisions, netting, and termination events.
- **Schedule** — Customizes the Master Agreement (e.g., choice of law, credit support details).
- **Credit Support Annex (CSA)** — Governs collateral/margin requirements. Specifies eligible collateral, haircuts, minimum transfer amounts, and thresholds.
- **Confirmation** — The specific trade terms for each transaction. For options: underlying, strike, premium, expiration, exercise style, settlement type.
- **ISDA Definitions** — Standardized definitions referenced in confirmations. The 2006 ISDA Definitions cover interest rate products; the 2002/2021 Equity Definitions cover equity options.

#### OTC vs Listed Comparison

| Feature | Listed | OTC |
|---|---|---|
| **Standardization** | Fixed strikes, expirations, multipliers | Fully customizable |
| **Counterparty risk** | Eliminated via CCP (OCC) | Bilateral, mitigated by CSA |
| **Transparency** | Public quotes, volume, OI | Private; no public reporting (pre-2024 SFTR/EMIR) |
| **Liquidity** | Quote-driven on exchanges | Relationship-driven; RFQ to dealer banks |
| **Settlement** | T+1, standard | Negotiated (T+2 typical for FX, T+1 for equity) |
| **Regulation** | SEC/CFTC regulated exchanges | Dodd-Frank Title VII; EMIR in EU |
| **Margin** | OCC-determined; standardized | CSA-determined; bilateral or cleared through CCP |
| **Size** | Standardized (100 shares) | Any notional amount |

#### OTC Exotic Options

OTC markets are where exotic options primarily trade. See the [Exotic Options](#exotic-options) section below.
