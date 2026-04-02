## Small Cap vs Large Cap Trading Considerations

### Liquidity Differences

| Characteristic | Large Cap | Small Cap |
|---|---|---|
| Average daily volume | High (millions of shares) | Low (tens of thousands) |
| Bid-ask spread | Tight (1-2 cents) | Wide (5-50+ cents) |
| Market depth | Deep (large size at each level) | Shallow |
| Number of market makers | Many | Few |
| Dark pool availability | Extensive | Limited |
| Analyst coverage | Broad | Sparse |
| Index inclusion | Major indices (S&P 500, etc.) | Russell 2000, small-cap indices |
| Institutional ownership | High | Variable |

### Execution Challenges in Small Caps

- **Market impact**: even modest order sizes can move the price significantly. A $500,000 order may represent several days of volume.
- **Information leakage**: fewer participants means orders are more easily detected.
- **Limited algo effectiveness**: standard participation algorithms may not find enough liquidity. Dark pool hit rates are low.
- **Wider benchmarking uncertainty**: VWAP and other volume-based benchmarks are noisier with lower volume.

### Small Cap Execution Strategies

- **Patience**: use very low participation rates (1-5% of volume) and extend the execution horizon.
- **Natural block matching**: use platforms like Liquidnet where other institutional holders may provide natural contra-side liquidity.
- **Limit-order strategies**: work orders passively at the bid or midpoint, avoiding taking liquidity.
- **Avoid momentum signals**: do not rush to complete orders in small caps, as this creates price momentum that works against the position.
- **Broker selection**: choose brokers with strong small-cap coverage and market-making activity, as they may have natural other-side flow.

### Large Cap Execution

- Rich venue selection: dark pools, lit exchanges, wholesale market makers all compete for order flow.
- Algorithmic execution highly effective due to predictable volume profiles and deep liquidity.
- Primary challenge is minimizing information leakage in very large orders (multiple days of ADV).
- Electronic market making is most competitive in large caps; spreads are at their tightest.

---

## Pre/Post Market Trading (Extended Hours)

### US Extended Hours Sessions

**Pre-market:**
- Available on most exchanges and ECNs from 4:00 AM ET to 9:30 AM ET (some venues open as early as 4:00 AM, others at 7:00 AM or 8:00 AM).
- Key period: 8:00-9:30 AM ET when economic data releases and pre-market earnings reactions create meaningful volume.

**Post-market (After Hours):**
- Available from 4:00 PM ET to 8:00 PM ET.
- Driven by after-hours earnings announcements and news events.

### Characteristics of Extended Hours Trading

- **Lower liquidity**: significantly less volume than regular trading hours. Bid-ask spreads are wider.
- **Higher volatility**: prices can move sharply on relatively small volume, especially around earnings announcements.
- **Limit orders only**: most venues only accept limit orders during extended hours (no market orders) to protect participants from adverse fills in thin markets.
- **No auction mechanism**: extended hours are continuous trading only; there are no opening/closing auctions.
- **Fragmentation**: fewer participants, fewer venues active, and no Reg NMS order protection (trade-through protection does not apply outside regular trading hours).

### Use Cases

- **Earnings reaction**: trading immediately after earnings announcements (most US companies report before the open or after the close).
- **News response**: reacting to corporate news, M&A announcements, geopolitical events, or economic data releases.
- **International overlap**: pre-market session overlaps with European trading hours, allowing cross-market hedging and reaction to European developments.
- **Risk management**: closing or hedging positions in response to post-market news without waiting for the next day's open.

### Implementation Considerations

- **Order routing**: must specify extended-hours eligibility when submitting orders. Not all venues accept extended-hours orders.
- **Risk controls**: wider price bands for limit checks, as extended-hours prices can diverge significantly from regular-session closes.
- **Market data**: extended-hours trades are reported to the consolidated tape but distinguished from regular-session trades.
- **Gap risk**: the opening auction on the following day may gap significantly from extended-hours prices as broader participation arrives.
- **Settlement**: extended-hours trades settle on the same cycle as regular-session trades (T+1 in US equities as of May 2024).

---

## Key Data Requirements for an Equities Trading Platform

A comprehensive equities trading system requires integration with the following data sources:

| Data Type | Sources | Latency Requirements |
|---|---|---|
| Real-time quotes and trades | Direct exchange feeds (e.g., NYSE Pillar, NASDAQ ITCH), SIP (CTA/UTP) | Microseconds to milliseconds |
| Depth of book | Exchange direct feeds, Level 2 / TotalView | Microseconds |
| Short locate availability | Internal inventory, EquiLend, broker APIs | Real-time to minutes |
| Corporate actions | Bloomberg, Refinitiv, ISO 15022/20022 feeds | Daily/event-driven |
| Index compositions | Index providers (S&P, MSCI, FTSE Russell) | Daily with event-driven updates |
| ETF creation baskets | ETF issuers, NSCC | Daily |
| IPO/offering calendars | Underwriter allocations, Bloomberg, Dealogic | Daily/event-driven |
| Regulatory thresholds | Reg SHO threshold list, short sale circuit breaker status | Real-time |
| Reference data | CUSIP, ISIN, SEDOL, FIGI, ticker symbology | Daily |
| Trading calendars | Exchange holiday/half-day schedules by market | Annually with updates |
