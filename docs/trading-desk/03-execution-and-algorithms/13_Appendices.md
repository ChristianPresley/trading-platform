## Appendix A: FIX Protocol Tags for Algorithmic Trading

| FIX Tag | Name | Description |
|---------|------|-------------|
| 847 | NoStrategyParameters | Number of strategy parameters |
| 958 | StrategyParameterName | Name of algorithm parameter |
| 959 | StrategyParameterType | Data type of parameter |
| 960 | StrategyParameterValue | Value of parameter |
| 7928 | StrategyName | Algorithm/strategy name (custom tag, common) |
| 168 | EffectiveTime | Start time for the algo |
| 126 | ExpireTime | End time for the algo |
| 44 | Price | Limit price |
| 110 | MinQty | Minimum fill quantity |
| 111 | MaxFloor | Display quantity for icebergs |
| 210 | MaxShow | Maximum display quantity |

## Appendix B: Common Execution Venues (US Equities MIC Codes)

| Venue | MIC Code | Type |
|-------|----------|------|
| NYSE | XNYS | Lit Exchange |
| NASDAQ | XNAS | Lit Exchange |
| NYSE Arca | ARCX | Lit Exchange |
| Cboe BZX | BATS | Lit Exchange |
| Cboe BYX | BATY | Lit Exchange |
| Cboe EDGX | EDGX | Lit Exchange |
| Cboe EDGA | EDGA | Lit Exchange |
| IEX | IEXG | Lit Exchange |
| MEMX | MEMX | Lit Exchange |
| MIAX Pearl | EPRL | Lit Exchange |
| Liquidnet | LQNT | Block ATS |
| BIDS Trading | BIDS | Block ATS |
| UBS ATS | UBSA | Dark Pool |
| Goldman Sigma-X2 | SGMA | Dark Pool |
| Morgan Stanley MS Pool | MSPL | Dark Pool |
| JP Morgan JPM-X | JPMX | Dark Pool |
| Virtu MatchIt | VFCM | Dark Pool |
| IntelligentCross | INCR | Dark Pool |

## Appendix C: Key Academic References

- **Almgren, R. and Chriss, N.** (2001). "Optimal Execution of Portfolio Transactions." *Journal of Risk*, 3(2), 5-39. — Foundation for the implementation shortfall optimization framework.
- **Bertsimas, D. and Lo, A.** (1998). "Optimal Control of Execution Costs." *Journal of Financial Markets*, 1(1), 1-50. — Dynamic programming approach to optimal execution.
- **Perold, A.** (1988). "The Implementation Shortfall: Paper vs. Reality." *Journal of Portfolio Management*, 14(3), 4-9. — Original implementation shortfall framework.
- **Kyle, A.S.** (1985). "Continuous Auctions and Insider Trading." *Econometrica*, 53(6), 1315-1335. — Foundational market microstructure model.
- **Glosten, L.R. and Milgrom, P.R.** (1985). "Bid, Ask and Transaction Prices in a Specialist Market with Heterogeneously Informed Traders." *Journal of Financial Economics*, 14(1), 71-100. — Adverse selection and bid-ask spread theory.
- **Easley, D., Lopez de Prado, M., and O'Hara, M.** (2012). "Flow Toxicity and Liquidity in a High-Frequency World." *Review of Financial Studies*, 25(5), 1457-1493. — VPIN metric for measuring flow toxicity.
