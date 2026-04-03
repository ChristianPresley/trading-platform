# Crypto Arbitrage

> **Source**: [151 Trading Strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865) (Kakushadze & Serur, 2018; triangular arbitrage adapted)
> **Asset Class**: Cryptocurrency
> **Crypto/24-7 Applicable**: Yes --- 24/7 markets with fragmented liquidity create persistent arbitrage opportunities
> **Evidence Tier**: Academic + Backtested
> **Complexity**: Complex

## Overview

Exploits price discrepancies across cryptocurrency exchanges (cross-exchange arbitrage), between related trading pairs on the same exchange (triangular arbitrage), and between centralized and decentralized exchanges (CEX/DEX arbitrage). Crypto markets are uniquely fragmented: hundreds of exchanges with varying liquidity, fee structures, and settlement speeds create persistent mispricings. While arbitrage opportunities have narrowed significantly since 2018, they remain non-trivial in less liquid pairs and during high-volatility events.

## Trading Rules

### Cross-Exchange Arbitrage
1. **Monitoring**: Continuously poll order books on 3+ exchanges (e.g., Kraken, Binance, Coinbase) for the same trading pair.
2. **Signal**: When the best ask on Exchange A is lower than the best bid on Exchange B by more than the round-trip cost (fees + withdrawal fees + slippage estimate), a signal triggers.
3. **Execution**: Simultaneously buy on Exchange A and sell on Exchange B using pre-funded accounts on both exchanges.
4. **Settlement**: Periodically rebalance inventory across exchanges via on-chain transfers.

### Triangular Arbitrage
1. **Monitor three pairs**: e.g., BTC/USD, ETH/USD, ETH/BTC on the same exchange.
2. **Detect mispricing**: If BTC/USD * (1/ETH_BTC) differs from ETH/USD by more than 3x the trading fee, execute the triangular cycle.
3. **Execute atomically**: Place all three trades as rapidly as possible (ideally within milliseconds).

### CEX/DEX Arbitrage
1. **Compare prices** between centralized exchanges and DEX AMMs (e.g., Uniswap, Curve).
2. **Account for gas costs** and DEX slippage in profitability calculation.
3. **Execute** via on-chain transactions when profit exceeds gas + fees.

## Performance Metrics

| Metric | Value |
|--------|-------|
| Sharpe Ratio | 2.0 - 5.0+ (when opportunities exist) |
| CAGR | 5% - 30% (declining as markets mature) |
| Max Drawdown | -5% to -15% (primarily from inventory/exchange risk) |
| Win Rate | 75% - 90% |
| Volatility | 5% - 15% annualized |
| Profit Factor | 3.0 - 10.0 |
| Rebalancing | Continuous (tick-by-tick) |

## Efficacy Rating

**3/5** --- Theoretically near-riskless but operationally challenging. Cross-exchange arbitrage opportunities dropped substantially after 2018 as markets matured. Remaining alpha is concentrated in less liquid pairs, exotic exchanges, and during volatility spikes. CEX/DEX arbitrage faces MEV (Miner Extractable Value) competition from sophisticated on-chain bots. Infrastructure costs (pre-funded accounts on multiple exchanges, low-latency connections, on-chain monitoring) are significant. Exchange counterparty risk (insolvency, withdrawal freezes) is a material tail risk. The strategy is a technology and infrastructure arms race.

## Academic References

- Makarov, I. & Schoar, A. (2020). "Trading and Arbitrage in Cryptocurrency Markets." *Journal of Financial Economics*, 135(2), 293-319.
- Kakushadze, Z. & Serur, J. A. (2018). "151 Trading Strategies." *Palgrave Macmillan*. [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3247865)
- Shu, M. et al. (2023). "Arbitrage across different Bitcoin exchange venues." *Accounting & Finance*. [Wiley](https://onlinelibrary.wiley.com/doi/full/10.1111/acfi.13102)
- Heimbach, L. et al. (2024). "Cross-Chain Arbitrage: The Next Frontier of MEV in Decentralized Finance." [arXiv:2501.17335](https://arxiv.org/abs/2501.17335)

## Implementation Notes

- **Infrastructure Requirements**: Pre-funded accounts on multiple exchanges. Low-latency WebSocket connections for real-time order book data. Co-location or proximity hosting near exchange data centers.
- **Capital Efficiency**: Capital must be pre-positioned on each exchange, reducing overall capital efficiency. Periodic rebalancing via on-chain transfers incurs fees and time delays.
- **Exchange Risk**: Counterparty risk is the largest risk factor. FTX collapse in 2022 demonstrated that funds on exchanges are not safe. Diversify across exchanges and minimize on-exchange balances.
- **Latency**: This is the most latency-sensitive strategy in the crypto category. Sub-100ms order book processing and execution is desirable.
- **Pure Zig Advantage**: Zig's deterministic performance and zero-overhead abstractions are well-suited for the latency-critical order book processing and arbitrage detection loop. No GC pauses during critical path execution.
- **Regulatory Considerations**: Some jurisdictions restrict automated trading or require registration. CEX/DEX arbitrage may interact with front-running regulations in DeFi.
