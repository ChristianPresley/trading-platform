# Triangular Arbitrage

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) Ch. 8, [Makarov & Schoar (2020)](https://doi.org/10.1016/j.jfineco.2019.07.002)
> **Asset Class**: FX / Cryptocurrency
> **Crypto/24-7 Applicable**: Yes — crypto markets are the primary modern venue due to fragmented liquidity across exchanges and numerous trading pairs; 24/7 operation provides continuous opportunity scanning
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

Triangular arbitrage exploits pricing inconsistencies across three currency pairs that form a closed triangle. In a perfectly efficient market, the product of exchange rates around any triangle should equal 1.0 (the no-arbitrage condition). When this condition is violated — even briefly — a trader can execute three simultaneous trades to lock in a riskless profit equal to the deviation.

For example, given three currencies A, B, and C: if converting A to B, then B to C, then C back to A yields more of A than the starting amount (after fees), a triangular arbitrage exists. In mathematical terms, if `Rate(A/B) * Rate(B/C) * Rate(C/A) > 1.0`, the arbitrage is profitable in the direction A -> B -> C -> A. If the product is less than 1.0, the profitable direction is reversed.

In traditional FX markets, triangular arbitrage opportunities have been nearly eliminated by high-frequency market makers who correct mispricings within milliseconds. However, cryptocurrency markets present a more fertile environment due to: (a) fragmented liquidity across dozens of exchanges, (b) hundreds of trading pairs with varying depth, (c) slower arbitrage correction in smaller pairs, and (d) structural inefficiencies in decentralized exchanges (DEXs) where on-chain transaction latency creates windows of opportunity.

Research by Makarov and Schoar (2020) documented persistent price deviations across crypto exchanges, with arbitrage opportunities lasting minutes to hours — dramatically longer than in traditional FX where they last microseconds. However, subsequent studies (Borri & Shakhnov, 2024) have shown that once transaction costs, slippage, and limited order book depth are accounted for, the profitability of these opportunities is significantly reduced.

## Trading Rules

1. **Universe Definition**: Select a set of trading pairs that form complete triangles:
   - **FX Example**: EUR/USD, GBP/USD, EUR/GBP
   - **Crypto Example**: BTC/USDT, ETH/USDT, ETH/BTC

2. **Price Monitoring**: Continuously monitor bid/ask prices for all three pairs in the triangle. Use the bid price for sells and the ask price for buys (worst-case execution assumption).

3. **Arbitrage Detection**: For each triangle, compute the implied cross-rate and compare to the actual quoted rate:
   - **Forward path**: `product = ask(A/B) * ask(B/C) * bid(C/A)`
   - **Reverse path**: `product = bid(A/B) * bid(B/C) * ask(C/A)`
   - If either product exceeds `1.0 + threshold` (where threshold accounts for all fees), an arbitrage exists.

4. **Fee Threshold Calculation**:
   - `threshold = 3 * trading_fee_rate + estimated_slippage`
   - For a CEX with 0.1% maker/taker fee: threshold = 0.3% + slippage
   - For DEX with 0.3% swap fee: threshold = 0.9% + gas costs

5. **Execution**: Execute all three legs simultaneously (or as close to simultaneously as possible):
   - On CEX: Submit all three limit orders at observed prices in rapid succession.
   - On DEX: Use atomic multi-hop swaps (e.g., Uniswap V3 multi-pool routing) to execute all legs in a single transaction.

6. **Position Sizing**: Size based on the minimum available depth across all three order books at the quoted prices. Never exceed the quantity available at the best bid/ask.

7. **Latency Requirements**: In crypto CEX markets, execution must complete within 50-500ms to capture the opportunity before price adjustment. On DEX, the atomic transaction model eliminates timing risk but introduces gas cost and MEV (Maximal Extractable Value) risk.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | N/A (near-riskless per trade, but opportunity frequency varies) |
| CAGR | Highly variable (0.5-5% of deployed capital) |
| Max Drawdown | Near zero per trade (risk is execution failure, not directional) |
| Win Rate | 85-95% (when executed; many opportunities are missed) |
| Volatility | Very low per trade; portfolio-level depends on capital utilization |
| Profit Factor | 2.0-5.0 per executed trade |
| Rebalancing | Continuous (real-time monitoring) |

Triangular arbitrage has an unusual performance profile: individual trades have very high win rates and near-zero risk when executed successfully, but the strategy's aggregate returns depend entirely on the frequency and size of opportunities. In liquid crypto CEX markets, opportunities yielding more than 10 bps after fees are rare (a few per day) and small. In less efficient venues (smaller exchanges, DEX), opportunities are more frequent but face higher execution risk and smaller depth.

## Efficacy Rating

**Rating: 3/5** — The theoretical foundation is unassailable (no-arbitrage is a fundamental principle), and the strategy is genuinely low-risk when executed correctly. The rating reflects the practical reality that: (a) profitable opportunities after fees are increasingly rare as markets mature, (b) the strategy is an arms race where the fastest executor wins, (c) capital efficiency is very low (most capital sits idle waiting for opportunities), and (d) in crypto DEX markets, MEV bots and sandwich attacks can front-run arbitrage transactions.

## Academic References

- Makarov, I., & Schoar, A. (2020). "Trading and Arbitrage in Cryptocurrency Markets." *Journal of Financial Economics*, 135(2), 293-319.
- Borri, N., & Shakhnov, K. (2024). "Wish or Reality? On the Exploitability of Triangular Arbitrage in Cryptocurrency Markets." *Finance Research Letters*, 59.
- Aiba, Y., Hatano, N., Takayasu, H., Marumo, K., & Shimizu, T. (2002). "Triangular Arbitrage as an Interaction Among Foreign Exchange Rates." *Physica A*, 310(3-4), 467-479.
- Aloosh, A. (2014). "Global Variance Risk Premium and Forex Return Predictability." *Journal of Financial Econometrics*, 12(4), 756-781.
- Kozhan, R., & Tham, W. W. (2012). "Execution Risk in High-Frequency Arbitrage." *Management Science*, 58(11), 2131-2149.

## Implementation Notes

- **Latency is Everything**: In CEX environments, the strategy is a pure speed competition. Colocation with exchange servers, optimized network paths, and minimal-latency execution code are prerequisites. In Zig, the ability to avoid GC pauses and control memory allocation precisely is a significant advantage for this strategy.
- **Order Book Depth**: Always check depth before execution. A 10 bps opportunity on $100 of book depth is worthless. Compute profit based on the actual executable quantity at quoted prices, not just top-of-book.
- **Exchange Fee Tiers**: Many CEX offer volume-based fee discounts. At the highest tiers (0.02% maker / 0.04% taker), the fee threshold drops to ~0.12%, making more opportunities viable. BNB fee discounts on Binance, exchange tokens on others.
- **DEX Atomic Execution**: On Ethereum and L2s, multi-hop swaps via Uniswap V3 or aggregators (1inch, Paraswap) execute atomically — all three legs succeed or all fail. This eliminates partial execution risk but introduces gas costs ($0.50-$5 on L2s, $5-$50 on mainnet) that set a minimum profitable trade size.
- **MEV Protection**: On-chain triangular arbitrage is heavily competed by MEV bots. Private mempools (Flashbots Protect), MEV-aware DEX aggregators, or execution on MEV-resistant L2s can mitigate front-running risk.
- **Cross-Exchange Variant**: The most profitable modern variant involves cross-exchange arbitrage (same pair, different exchange) combined with triangular paths. This requires capital on multiple exchanges and introduces settlement risk, but opportunities are larger and more frequent than single-exchange triangular arb.
