---
phase: 2
iteration: 01
generated: 2026-04-03
---

# Research: Professional Trading Desk with Kraken Exchange Integration

Questions source: .claude/specs/trading-desk-kraken-integration/01-questions-01.md

## 1. Kraken Spot REST and WebSocket API Endpoints, Authentication, Rate Limits, and Error Formats

### REST API Authentication
- Private endpoints require four parameters: `API-Key` header, `API-Sign` header, `nonce` (always-increasing 64-bit integer), and optional `otp` for 2FA (`docs/kraken-exchange-documentation/01-guides/04-spot-exchange/03-rest/01_Authentication.md:11-12`)
- API-Sign formula: `HMAC-SHA512(URI_path + SHA256(nonce + POST_data), base64_decode(api_secret))` (`01_Authentication.md:22-24`)
- URI path portion starts with `/0/private` (`01_Authentication.md:22`)
- Nonce must be always-increasing unsigned 64-bit integer; common approach is UNIX timestamps in milliseconds (`01_Authentication.md:41-45`)
- Too many invalid nonces (`EAPI:Invalid nonce`) can result in temporary bans (`01_Authentication.md:43`)
- For shared API keys, nonces must be coordinated through centralized store (`01_Authentication.md:45`)

### REST API Endpoints
- Trading: `POST /0/private/AddOrder` supports order types: market, limit, stop-loss, take-profit, stop-loss-limit, take-profit-limit, trailing-stop, trailing-stop-limit, settle-position (`docs/kraken-exchange-documentation/03-spot-rest/06-trading/02_Add-Order.md:24`)
- Maximum open orders: 225 for standard accounts (`02_Add-Order.md:99`)
- Market data endpoints: `/0/public/Assets`, `/0/public/AssetPairs`, `/0/public/Depth` (L2), `/0/public/OHLC`, `/0/public/Spread`, `/0/public/Trades`, `/0/public/Ticker`, `/0/public/SystemStatus` (`docs/kraken-exchange-documentation/03-spot-rest/04-market-data/README.md`)

### REST API Rate Limits
- Call counter mechanism: starts at zero, ledger/trade-history calls increment by 2, all others by 1 (`docs/kraken-exchange-documentation/01-guides/04-spot-exchange/03-rest/04_Rate-Limits.md:7-15`)
- Tier limits: Starter max 15 (decay -0.33/sec), Intermediate max 20 (decay -0.5/sec), Pro max 20 (decay -1/sec) (`04_Rate-Limits.md:9-13`)
- AddOrder and CancelOrder have separate rate limiting mechanisms (`04_Rate-Limits.md:9`)
- Error responses: `EAPI:Rate limit exceeded` for counter exceeded, `EService: Throttled: [UNIX timestamp]` for excessive concurrent requests (`04_Rate-Limits.md:25-30`)

### REST API Error Response Format
- JSON with `result` and `error` keys for success, or solely `error` for failures (`docs/kraken-exchange-documentation/01-guides/04-spot-exchange/03-rest/03_Introduction.md:24-25`)
- Error pattern: `<severity><category>: <description>` where severity is `E` (error) or `W` (warning), categories include General, Auth, API, Query, Order, Trade, Funding, Service (`03_Introduction.md:49-57`)
- Key error codes from AddOrder: `EGeneral:Invalid arguments`, `EGeneral:Permission denied`, `EOrder:Insufficient funds`, `EOrder:Minimum order volume not met`, `EOrder:Rate limit exceeded`, `EOrder:Post only order`, `EAPI:Invalid nonce` (`03_Introduction.md:81-95`)

### WebSocket API
- Endpoints: v2 public `wss://ws.kraken.com/v2`, v2 private `wss://ws-auth.kraken.com/v2`, v1 public `wss://ws.kraken.com`, v1 private `wss://ws-auth.kraken.com` (`docs/kraken-exchange-documentation/01-guides/04-spot-exchange/04-websockets/04_Introduction.md:7-14`)
- Authentication: obtain token via REST `GetWebSocketsToken` endpoint; token valid 15 minutes (`01_Authentication.md:9-11,31`)
- WebSocket v2 improvements: FIX-like design, readable pair symbols (e.g., "BTC/USD"), RFC3339 timestamps, prices as number types, optional `req_id` for response matching (`04_Introduction.md:22-43`)
- v2 add_order method supports: market, limit, iceberg, stop-loss, stop-loss-limit, take-profit, take-profit-limit, trailing-stop, trailing-stop-limit, settle-position (`docs/kraken-exchange-documentation/06-websocket-v2/04-user-trading/01_Add-Order.md:125-137`)
- Connection: TLS with SNI mandatory, ~1 minute timeout for inactive connections, Cloudflare limits ~150 reconnects per 10-minute rolling window per IP (`04_Introduction.md:56-67`)

### FIX API
- Two-layer authentication via `SenderCompID` (Tag 49); separate API keys for Spot and Futures with `DRV` suffix for derivatives (`docs/kraken-exchange-documentation/01-guides/04-spot-exchange/01-fix/01_Authentication.md:9-15`)
- FIX password: `base64(HMAC-SHA512(base64_decode(api_secret), SHA256(message_input + nonce)))` (`01_Authentication.md:26-34`)
- Message-input: concatenation of `35=A`, `34=MsgSeqNum`, `49=SENDERCOMPID`, `56=TARGETCOMPID`, `553=API_KEY` with SOH delimiter (`docs/kraken-exchange-documentation/04-spot-fix/02_Logon.md:38-44`)
- Nonce must be within 5 seconds of server time, strictly increasing (`02_Logon.md:47-51`)
- FIX NewOrderSingle (MsgType D) supports: market, limit, stop-loss, stop-loss-limit, take-profit, take-profit-limit, trailing-stop, trailing-stop-limit (`docs/kraken-exchange-documentation/04-spot-fix/08_New-Order-Single.md:13-22`)
- ExecutionReport ExecType values: `0`=New, `4`=Canceled, `5`=Replace, `A`=Pending New, `C`=Expired, `D`=Restated, `F`=Trade, `I`=Order Status (`docs/kraken-exchange-documentation/04-spot-fix/01_Execution-Report.md:11-51`)

## 2. Kraken Futures Exchange API Endpoints, WebSocket Channels, and FIX Protocol Differences

### Futures REST API
- Base URLs: REST `https://futures.kraken.com/derivatives/api/v3/`, History `https://futures.kraken.com/api/history/v2/`, Charts `https://futures.kraken.com/api/charts/v1/`, WebSocket `wss://futures.kraken.com/ws/v1`, Demo `https://demo-futures.kraken.com/` (`docs/kraken-exchange-documentation/01-guides/03-futures-exchange/01_Introduction.md:78-86`)
- 13 endpoint categories: Account, Assignment Program, Charts, Fee Schedules, General, History, Instruments, Market Data, Multi Collateral, Order Management, RFQ, Settings, Transfers (`docs/kraken-exchange-documentation/07-futures-rest/README.md`)
- Send order: `POST /sendorder` supports order types: `lmt`, `post`, `mkt`, `stp`, `take_profit`, `ioc`, `trailing_stop`, `fok` (`docs/kraken-exchange-documentation/07-futures-rest/10-order-management/10_Send-Order.md:38-39`)
- Dead man's switch: `POST /cancelallordersafter` recommended every 15-20s with 60s timeout (`10-order-management/README.md`)
- Batch orders: `POST /batchorder` with cost of 9 + batch size (`docs/kraken-exchange-documentation/01-guides/03-futures-exchange/02_Rate-Limits.md:36`)

### Futures Authentication Differences
- Headers: `APIKey`, `Authent` (signature), `Nonce` (optional but recommended) (`docs/kraken-exchange-documentation/01-guides/03-futures-exchange/03_Rest.md:7-15`)
- Authent formula: `HMAC-SHA512(base64_decode(api_secret), SHA256(postData + nonce + endpoint_path))` (`03_Rest.md:26-35`)
- PostData formatted as `&`-concatenated parameters; endpoint path is URL extension (e.g., `/api/v3/orderbook`) (`03_Rest.md:19-23`)
- As of Feb 2024, API hashes full URL-encoded parameters; backward compatible until Oct 2025 (`03_Rest.md:37-39`)

### Futures Rate Limits
- 500 cost units per 10 seconds for `/derivatives` endpoints; public endpoints cost 0 (`docs/kraken-exchange-documentation/01-guides/03-futures-exchange/02_Rate-Limits.md:7-8`)
- Key costs: sendorder=10, editorder=10, cancelorder=10, batchorder=9+batch_size, accounts=2, openpositions=2, cancelallorders=25, cancelallordersafter=25 (`02_Rate-Limits.md:10-35`)
- History endpoints: 100 token pool, replenishes at 100 per 10 minutes (`02_Rate-Limits.md:40-54`)
- WebSocket: 100 connections max, 100 requests/second (`02_Rate-Limits.md:66-74`)

### Futures WebSocket
- URL: `wss://futures.kraken.com/ws/v1`; must ping at least every 60 seconds (`docs/kraken-exchange-documentation/01-guides/03-futures-exchange/04_Websockets.md:34-38`)
- Authentication via signed challenge: `base64(HMAC-SHA512(base64_decode(api_secret), SHA256(challenge)))` (`04_Websockets.md:15-20`)
- 13 channels: Account Log, Balances, Book, Challenge, Fills, Heartbeat, Notifications, Open Orders, Open Orders Verbose, Open Positions, Ticker Lite, Ticker, Trade (`docs/kraken-exchange-documentation/08-futures-websocket/README.md`)

### Futures Margin and Collateral
- Two account types: Cash Account and Multi-Collateral Margin Account (`docs/kraken-exchange-documentation/07-futures-rest/01-account/01_Get-Accounts.md:50-76`)
- Multi-collateral fields: initialMargin, maintenanceMargin, balanceValue, portfolioValue, collateralValue, availableMargin, marginEquity (`01_Get-Accounts.md:50-76`)
- Margin equity formula: `[Balance Value * (1-Haircut)] + (Total Unrealised Profit/Loss as Margin)` (`01_Get-Accounts.md:66`)
- Leverage preferences: `GET/PUT /leveragepreferences` for isolated vs cross margin with max leverage (`docs/kraken-exchange-documentation/07-futures-rest/09-multi-collateral/01_Get-Leverage-Setting.md:41-46`)
- PnL currency preferences: `GET/PUT /pnlpreferences` (`09-multi-collateral/02_Get-Pnl-Currency-Preference.md`)
- Portfolio margin parameters available in demo: crossAssetNettingFactor, extremePriceShockMultiplier, volShockMultiplicationFactor, priceShockLevels, optionsUserLimits (`docs/kraken-exchange-documentation/07-futures-rest/01-account/03_Get-Portfolio-Margining-Parameters.md:45-59`)

### Key Spot vs Futures Differences
- Separate trading engines with distinct protocols, onboarding, authentication, rate limits, error handling (`docs/kraken-exchange-documentation/01-guides/01_Kraken-Apis.md:37-39`)
- Symbol format: Spot uses pairs like "BTC/USD"; Futures uses prefixed symbols like `fi_xbtusd`, `fi_xbtusd_180615` (`01_Introduction.md:33-42`)
- Datetime: Futures use ISO8601 `yyyy-mm-ddTHH:MM:SS.sssZ` (`01_Introduction.md:28-30`)

## 3. Order Types, Lifecycle States, State Transitions, Amendment/Cancellation Workflows, and Parent-Child Relationships

### Order Types
- Basic: Market (FIX Tag 40: `1`), Limit (`2`), Stop (`3`), Stop-Limit (`4`), Trailing Stop (`P` FIX 5.0) with PegOffsetValue (tag 211) and PegOffsetType (tag 836) (`docs/trading-desk/02-order-management-system/01_Order-Types.md:5-71`)
- Time-in-Force (Tag 59): Day (`0`), GTC (`1`), IOC (`3`), FOK (`4`), GTD (`6`), At-the-Open (`2`), At-the-Close (`7`), Good-for-Auction (`A`) (`01_Order-Types.md:77-84`)
- Auction: MOO (OrdType=1, TIF=2), LOO (OrdType=2, TIF=2), MOC (OrdType=1, TIF=7, NYSE cutoff 3:50 PM ET), LOC (OrdType=2, TIF=7) (`01_Order-Types.md:93-127`)
- Hidden: Iceberg/Reserve using MaxFloor (tag 111), Hidden/Non-Displayed using DisplayMethod (tag 1084)=`4` (`01_Order-Types.md:131-154`)
- Pegged (OrdType `P`): Primary Peg, Market Peg, Midpoint Peg, D-Peg (IEX); uses PegPriceType (tag 1094) (`01_Order-Types.md:156-186`)
- Special: All-or-None (ExecInst tag 18=`G`), Minimum Quantity (MinQty tag 110), Not Held (ExecInst=`1`) (`01_Order-Types.md:190-215`)

### Order Lifecycle States (OrdStatus, Tag 39)
- States: PendingNew (`A`), New (`0`), PartiallyFilled (`1`), Filled (`2`), DoneForDay (`3`), Cancelled (`4`), Replaced (`5`), PendingCancel (`6`), Rejected (`8`), Suspended (`9`), PendingReplace (`E`), Expired (`C`) (`docs/trading-desk/02-order-management-system/02_Order-Lifecycle-And-State-Machine.md:63-74`)
- Terminal states: Filled, Cancelled, Rejected, Expired (`02_Order-Lifecycle-And-State-Machine.md:66-74`)

### State Transitions
- PendingNew -> New, Rejected; New -> PartiallyFilled, Filled, Cancelled, Replaced, Expired, Suspended, DoneForDay, PendingCancel, PendingReplace (`02_Order-Lifecycle-And-State-Machine.md:78-87`)
- Critical race conditions: fill-before-cancel (process fill first), fill-before-replace (process fill first, replace applies to leaves), unsolicited cancel (venue cancels without user request) (`02_Order-Lifecycle-And-State-Machine.md:89-100`)

### Internal OMS States (Beyond FIX)
- Staged, Validating, RoutePending, SentToAlgo, AlgoWorking, ManualReview, CancelPending (internal) (`02_Order-Lifecycle-And-State-Machine.md:103-114`)
- Order versioning: each amendment creates new version with timestamp, user, previous/new values, ClOrdID/OrigClOrdID linkage (`02_Order-Lifecycle-And-State-Machine.md:116-131`)

### Amendment and Cancellation Workflows
- Cancel Request (MsgType `F`): requires OrigClOrdID (41), ClOrdID (11), Side (54), Symbol (55), TransactTime (60) (`docs/trading-desk/02-order-management-system/05_Amendments-Cancellations-And-Parent-Child-Orders.md:5-23`)
- Cancel Reject (MsgType `9`) with CxlRejReason (102): `0` (Too late), `1` (Unknown order), `2` (Broker option), `3` (Already pending), `99` (Other) (`05_Amendments.md:5-23`)
- Cancel/Replace (MsgType `G`): atomic cancel-and-submit; time priority retention depends on venue and change nature (`05_Amendments.md:25-46`)
- Mass Cancel: iterative, venue mass cancel, or kill switch (SEC 15c3-5) (`05_Amendments.md:48-62`)
- Cancel-on-Disconnect (FIX Tag 8013): session-level, cascades to child orders for algos (`05_Amendments.md:64-77`)

### Parent-Child Order Relationships
- Algo decomposition: parent order spawned into child orders; invariants: sum(child qty) <= parent qty, parent CumQty = sum(child CumQty), parent AvgPx = qty-weighted avg of child fills (`05_Amendments.md:83-104`)
- FIX linkage: ClOrdLinkID (583), ParentOrderID (custom), ChildOrderCount (custom) (`05_Amendments.md:83-104`)
- Bracket Orders: primary + take-profit + stop-loss; take-profit and stop-loss form OCO pair (`05_Amendments.md:114-124`)
- OCO: ContingencyType (1385)=`1`, shared ClOrdLinkID (583); partial fill handling configurable (`05_Amendments.md:126-138`)
- Contingent Orders: if-touched, if-done, if-filled, conditional on market data; OMS maintains contingency evaluation engine (`05_Amendments.md:140-155`)

## 4. Real-Time Market Data Feeds, Normalization, Tick Data Storage, Order Book Reconstruction, and Conflation

### Feed Formats
- Level 1 (Top of Book): Best Bid/Ask Price+Size, Last Trade Price/Size/Time, Cumulative Volume, VWAP, Open/High/Low/Close, Net Change (`docs/trading-desk/01-market-data-systems/01_Overview-And-Real-Time-Market-Data-Feeds.md:17-48`)
- NBBO vs BBO: BBO is single-venue best bid/ask; NBBO is cross-all-protected-US-exchanges under Reg NMS (`01_Overview.md:41-44`)
- Level 2 Market-by-Price (MBP): aggregated orders at each price level; typical depth 5/10/20 levels (`01_Overview.md:54-67`)
- Level 2 Market-by-Order (MBO): individual order-level detail with unique order ID; significantly higher bandwidth; enables queue position estimation, iceberg detection (`01_Overview.md:69-93`)
- MBO exchanges: NASDAQ TotalView-ITCH, NYSE Integrated Feed, CME MDP 3.0 MBO, LSE Full Order Book, Eurex EOBI, ASX ITCH, TMX Quantum Feed (`01_Overview.md:69-93`)

### Data Normalization
- Symbology mapping across: exchange-native (NYSE tickers, CME Globex symbols), ISIN, CUSIP, SEDOL, FIGI, MIC codes (`docs/trading-desk/01-market-data-systems/03_Data-Normalization-And-Market-Data-Protocols.md:1-49`)
- Price scaling (integer prices with implicit decimal), quantity normalization (lot sizes), currency normalization, timestamp normalization (to UTC nanoseconds since epoch), trade condition mapping, venue identification (to ISO 10383 MIC) (`03_Data-Normalization.md:50-59`)
- CME month codes: F=Jan, G=Feb, H=Mar, J=Apr, K=May, M=Jun, N=Jul, Q=Aug, U=Sep, V=Oct, X=Nov, Z=Dec (`03_Data-Normalization.md:9-16`)

### Market Data Protocols
- FIX: tag-value ASCII, messages 35=W (Snapshot), 35=X (Incremental), 35=V (Request) (`03_Data-Normalization.md:67-75`)
- FAST: binary FIX compression using presence maps, stop-bit encoding, delta encoding; 50-90% bandwidth reduction (`03_Data-Normalization.md:73-86`)
- SBE: fixed-layout binary for deterministic zero-copy parsing; used by CME MDP 3.0, Eurex T7 (`docs/trading-desk/06-connectivity-and-protocols/03_Market-Data-Protocols.md:14-20`)
- ITCH (NASDAQ): unidirectional binary, message types A/F (Add), E/C (Execute), X (Cancel), D (Delete), U (Replace), P (Trade); 100,000+ msgs/sec peak (`03_Data-Normalization.md:90-112`)
- OUCH: order-entry companion to ITCH (`03_Data-Normalization.md:115-117`)
- PITCH (Cboe): binary, similar to ITCH; multicast UDP with TCP gap-fill (`03_Data-Normalization.md:119-126`)
- CME MDP 3.0: SBE over multicast UDP; 10-level MBP + MBO; peak 25M+ msgs/sec (`03_Data-Normalization.md:128-137`)

### Transport
- Multicast UDP dominant; dual-line (A/B) redundancy with line arbitration and sequence-number deduplication (`03_Data-Normalization.md:159-167`)
- Kernel bypass: DPDK, Solarflare OpenOnload, FPGA NICs reduce NIC-to-app latency from ~10us to ~1-2us or sub-microsecond (`03_Data-Normalization.md:159-167`)
- TCP recovery: retransmission service, snapshot channels, re-spin for late joiners (`03_Data-Normalization.md:171-176`)

### Tick Data Storage
- Volume: single US exchange 5-10B msgs/day; all US venues >100B/day; OPRA 100B+ (`docs/trading-desk/01-market-data-systems/04_Tick-Data-Storage-And-Conflation.md:4-11`)
- Specialized: KDB+/q (industry standard, column-oriented, in-memory + memory-mapped), OneTick (`04_Tick-Data-Storage.md:15-22`)
- General-purpose: TimescaleDB (PostgreSQL extension), QuestDB (column-oriented, high-throughput), ClickHouse (exceptional compression), DuckDB (in-process OLAP over Parquet) (`04_Tick-Data-Storage.md:24-32`)
- File-based: Apache Parquet (de facto for analytical storage, column-oriented, Snappy/Zstd compression), Arrow/Feather, HDF5, flat binary (`04_Tick-Data-Storage.md:34-41`)
- KDB+ architecture: Tickerplant -> RDB (in-memory) + HDB (date-partitioned on disk) (`04_Tick-Data-Storage.md:43-51`)

### Order Book Reconstruction
- From ITCH: maintain two-sided price-level hierarchy; Add Order -> insert at price level; Replace -> modify; Execute -> reduce size; Cancel/Delete -> remove (`03_Data-Normalization.md:90-112`)
- Sequence numbers enable gap detection and recovery; full state reconstructable from SOD snapshot + incremental messages (`03_Data-Normalization.md:90-112`)

### Bar Aggregation and Conflation
- OHLCV bars at intervals: 1s, 5s, 1m, 5m, 15m, 30m, 1h, daily (`04_Tick-Data-Storage.md:57-67`)
- Alternative bars: volume bars, dollar bars, tick bars, renko bars, range bars (`04_Tick-Data-Storage.md:69-77`)
- VWAP: `Sum(Price_i * Volume_i) / Sum(Volume_i)` with trade condition filtering; continuous vs interval vs anchored (`04_Tick-Data-Storage.md:79-92`)

## 5. Risk Management Calculations, Pre-Trade Controls, Risk Limits, and Real-Time Monitoring

### VaR Calculations
- Historical VaR: N days of returns applied to current portfolio; 250 days at 99% = 2nd worst loss (`docs/trading-desk/05-risk-management/01_Market-Risk.md:18-40`)
- Parametric VaR: `VaR = z_alpha * sigma_portfolio * sqrt(T)` where z_alpha = 1.645 (95%) or 2.326 (99%) (`01_Market-Risk.md:42-73`)
- Monte Carlo VaR: 10,000-100,000 scenarios using calibrated stochastic processes with Cholesky decomposition for correlations (`01_Market-Risk.md:75-100`)
- Expected Shortfall (CVaR): `ES_alpha = E[Loss | Loss > VaR_alpha]`; coherent (satisfies subadditivity); Basel III FRTB replaced VaR with ES (`01_Market-Risk.md:102-124`)

### Greeks
- Delta: `Call Delta = N(d1)`, `Put Delta = N(d1) - 1`; portfolio delta = sum of position deltas (`docs/trading-desk/05-risk-management/05_Real-Time-Risk-Calculations-Options-Greeks.md:7-35`)
- Gamma: `N'(d1) / (S * sigma * sqrt(T))`; dollar gamma for 1% move: `0.5 * Gamma * S^2 * Qty * Multiplier / 100` (`05_Greeks.md:39-62`)
- Vega: `S * N'(d1) * sqrt(T) * exp(-q*T)`; vega matrix tracked by tenor and strike (`05_Greeks.md:64-92`)
- Theta: daily time decay; portfolio theta = sum of position thetas (`05_Greeks.md:94-113`)
- Rho: `Call Rho = K * T * exp(-r*T) * N(d2)`; significant for long-dated options (`05_Greeks.md:115-127`)

### Fixed Income Risk
- DV01: change in price for 1bp yield shift; `DV01 = ModifiedDuration * Price * 0.0001` (`docs/trading-desk/05-risk-management/06_Real-Time-Risk-Calculations-Fixed-Income-And-Architecture.md:3-25`)
- Key Rate DV01s at standard tenors: 3M, 6M, 1Y, 2Y, 3Y, 5Y, 7Y, 10Y, 15Y, 20Y, 30Y (`06_Fixed-Income.md:27-43`)
- CS01 (Credit Spread 01): `SpreadDuration * Price * 0.0001 * FaceValue` (`06_Fixed-Income.md:45-54`)
- Convexity: `dP/P = -ModifiedDuration * dy + 0.5 * Convexity * dy^2` (`06_Fixed-Income.md:56-67`)

### Pre-Trade Risk Controls
- Sequential pipeline: Order Validation -> Price Reasonability -> Size Limits -> Position Limits -> Credit/Margin Check -> Concentration Check -> Message Rate Throttle -> Duplicate Check (`docs/trading-desk/05-risk-management/04_Pre-Trade-Risk-Controls.md:7-36`)
- Size limits: max shares/order, max notional/order ($5M), max notional/day ($100M/trader), max % ADV (5%), max orders/sec (100/session) (`04_Pre-Trade.md:38-46`)
- Price checks: equity reject if >5% from NBBO mid or >10% from last trade; options reject if >50% from theoretical or implied vol >200% (`04_Pre-Trade.md:48-64`)
- Message rate throttling: exchange limits 50-300 msgs/sec (equity), internal limits 10-50 orders/sec per trader; OTR monitoring if >100:1 (`04_Pre-Trade.md:96-120`)

### Risk Limits
- Hierarchy: Board (VaR $50M, Stress $200M) -> Division (VaR $30M) -> Desk (VaR $10M, Delta ±$500M, Gamma ±$5M, Vega ±$3M, Theta -$200K) -> Trader (VaR $2M, Max Single Name $50M, Stop-loss $500K/day) -> Strategy (VaR $3M) (`docs/trading-desk/05-risk-management/07_Risk-Limits-And-Breaches.md:14-42`)
- Utilization zones: Green 0-75%, Amber 75-90%, Red 90-100%, Breach >100% (`07_Risk-Limits.md:44-57`)
- Breach escalation: T+0 risk manager, T+1 desk head, T+2 CRO, T+5 board risk committee (`07_Risk-Limits.md:59-87`)
- Stop-loss limits: daily, weekly, monthly, YTD; trigger halts risk-increasing activity (`07_Risk-Limits.md:119-134`)

### Stress Testing
- Historical scenarios: Black Monday (-22%), GFC (-57%), COVID (-34%, VIX >80), 2022 Rate Shock (`docs/trading-desk/05-risk-management/08_Stress-Testing-And-Scenario-Analysis.md:3-42`)
- Hypothetical scenarios: Sudden Rate Hike, China Devaluation, Cybersecurity Attack (`08_Stress-Testing.md:44-74`)
- Reverse stress testing: search for risk factor combinations producing target loss via optimization (`08_Stress-Testing.md:76-99`)
- Sensitivity (bump-and-reprice): spot moves -20% to +20%, vol moves -10pts to +10pts producing P&L matrix (`08_Stress-Testing.md:113-129`)

### Real-Time Risk Monitoring Architecture
- Pipeline: Market Data -> Tick Plant -> [Equity Pricer, Rates Engine, Vol Surface, FX Engine] -> Risk Aggregation -> [Greeks Server, VaR Engine, Stress Engine] -> Dashboard/Alerts (`06_Fixed-Income.md:90-120`)
- Latency targets: Greeks <100ms after tick, Position P&L <50ms, Portfolio VaR 1-5 min refresh, Stress 1-15 min refresh (`06_Fixed-Income.md:114-118`)

### Risk Attribution
- Factor model: `Return_i = alpha_i + sum(Beta_ik * Factor_k) + epsilon_i` with Barra style/industry/country/currency factors (`docs/trading-desk/05-risk-management/10_Risk-Attribution-Factor-Models.md:1-57`)
- Marginal VaR: `dVaR/dw_i`; Component VaR: `w_i * Marginal_VaR_i` (sums to total VaR); Incremental VaR: full non-linear impact of adding/removing position (`docs/trading-desk/05-risk-management/11_Risk-Attribution-Marginal-And-Component.md:1-54`)

### Regulatory Risk
- Basel III FRTB: replaced VaR with ES at 97.5%; liquidity horizons 10-120 days by asset class; P&L Attribution Test (Spearman >0.7 AND KL divergence <0.09) (`docs/trading-desk/05-risk-management/09_Regulatory-Risk-Requirements.md:34-87`)
- ISDA SIMM for initial margin: `IM = sqrt(sum_rc[IM_rc^2] + 2*sum[psi*IM_rc1*IM_rc2])` with risk weights per factor (`09_Regulatory.md:112-143`)

## 6. Connectivity Protocols, Message Formats, and Session Management

### FIX Protocol
- Dominant versions: FIX 4.2 and 4.4 (entrenchment); new exchanges mandate FIX 5.0 SP2 (`docs/trading-desk/06-connectivity-and-protocols/01_FIX-Protocol.md:7-20`)
- Session layer (FIXT 1.1): Logon (`A`), Logout (`5`), Heartbeat (`0`, typically 30s), TestRequest (`1`), ResendRequest (`2`), SequenceReset (`4`), Reject (`3`) (`01_FIX-Protocol.md:24-52`)
- Session ID tuple: SenderCompID (49) + TargetCompID (56) + optional SenderSubID (50), TargetSubID (57), SenderLocationID (142) (`01_FIX-Protocol.md:24-52`)
- Sequence numbers: independent per side, persisted across disconnections, gap detection triggers ResendRequest, PossDupFlag (43) for retransmissions (`01_FIX-Protocol.md:46-52`)
- Order flow: NewOrderSingle (`D`), CancelReplace (`G`), CancelRequest (`F`), ExecutionReport (`8`), CancelReject (`9`), MultiLeg (`AB`), List (`E`), Cross (`s`) (`01_FIX-Protocol.md:60-71`)
- Wire format: `8=FIX.4.4|9=BodyLen|35=MsgType|...` with SOH (0x01) delimiter, tag 10 checksum always last (`01_FIX-Protocol.md:128-142`)
- FIXP: binary session protocol for low-latency, supports ordered and unordered delivery (`01_FIX-Protocol.md:144-150`)

### FIX Engines
- Open source: QuickFIX (C++), QuickFIX/J (Java), QuickFIX/N (C#/.NET), QuickFIX/Go (`docs/trading-desk/06-connectivity-and-protocols/02_FIX-Engines-And-Session-Management.md:5-16`)
- Commercial: LSEG FIX Engine, B2BITS FIX Antenna, Chronicle FIX (ultra-low-latency), Rapid Addition RA-FIX (FPGA), TransFIX (.NET-native) (`02_FIX-Engines.md:18-28`)
- Session lifecycle: TCP connect -> Logon exchange -> Sequence sync (ResendRequest if gap) -> Steady state (heartbeats) -> Disconnection handling (TestRequest) -> Logout (`02_FIX-Engines.md:63-70`)

### Gateway and Adapter Architecture
- Central abstraction: Internal Trading Core <-> Internal Protocol (Aeron/ZeroMQ/gRPC) <-> Per-venue gateways (NYSE Pillar, Nasdaq OUCH/ITCH, CME iLink3, generic FIX) (`docs/trading-desk/06-connectivity-and-protocols/11_Gateway-And-Adapter-Architecture.md:4-25`)
- Gateway responsibilities: protocol translation, session management, symbol mapping, order ID mapping, rate limiting, throttling/queuing, failover, normalization, logging (nanosecond timestamps), enrichment (`11_Gateway.md:28-39`)
- Feed handler architecture: NIC (kernel bypass) -> Line Arbitrator (A/B dedup) -> Protocol Decoder (ITCH/SBE/FAST/PITCH) -> Book Builder/Cache -> Internal Distribution (`11_Gateway.md:77-113`)
- Feed handler targets: wire-to-internal <5us (co-located), >10M msgs/sec, book update <1us, zero GC pauses (`11_Gateway.md:115-120`)

### Messaging Middleware
- Solace PubSub+: sub-100us latency in appliance mode, prevalent on sell-side (`docs/trading-desk/06-connectivity-and-protocols/05_Message-Queuing-And-Middleware.md:7-14`)
- Aeron: single-digit microsecond latency, reliable UDP, Raft-based cluster for replicated state machines; .NET wrapper available (`05_Middleware.md:45-53`)
- Kafka: NOT for low-latency order routing; used for trade capture, audit logging, event sourcing, analytics pipelines (`05_Middleware.md:24-35`)
- ZeroMQ: brokerless, microsecond latency, PUB/SUB/REQ/REP/PUSH/PULL patterns (`05_Middleware.md:37-43`)

### Network Connectivity
- Co-location: NYSE=Mahwah NJ, Nasdaq=Carteret NJ (Equinix NY5), CME=Aurora IL, LSE=Basildon UK, Eurex=Frankfurt (`docs/trading-desk/06-connectivity-and-protocols/04_Network-Connectivity.md:26-43`)
- Microwave links: ~300,000 km/s (vs fiber ~200,000 km/s); key routes Carteret-Mahwah, Carteret-Aurora, Basildon-Frankfurt (`04_Network.md:45-61`)

### Drop Copy and Trade Reporting
- Drop copy: real-time read-only FIX session for all execution reports; used by middle office for independent risk/P&L calculation (`docs/trading-desk/06-connectivity-and-protocols/07_Drop-Copy-And-Trade-Reporting.md:3-19`)
- Trade reporting: TRACE (fixed income), ORF (OTC equity), APA/ARM (MiFID II), CAT (US equities/options lifecycle) (`07_Drop-Copy.md:21-37`)
- Protocols: FpML (OTC derivatives XML), FIX TradeCaptureReport, ISO 20022, DTCC CTM/Omgeo (`07_Drop-Copy.md:21-37`)

## 7. Low-Latency Architecture Patterns, Event-Driven Designs, High-Availability, Capacity Planning, and Security

### Low-Latency Architecture
- Kernel bypass: Solarflare/Xilinx OpenOnload (2-5us vs 20-50us kernel), DPDK (poll-mode drivers), Mellanox VMA, io_uring, XDP, RDMA (`docs/trading-desk/07-infrastructure-and-architecture/01_Low-Latency-Architecture-And-Event-Driven-Architecture.md:1-34`)
- CPU optimization: busy polling (100% CPU), CPU pinning (`sched_setaffinity`/`taskset`), `isolcpus` kernel parameter, NUMA awareness (avoid 50-100ns cross-socket), IRQ affinity (`01_Low-Latency.md:35-41`)
- Lock-free structures: LMAX Disruptor (ring buffer), SPSC/MPSC queues, lock-free hash maps, atomic counters (`01_Low-Latency.md:43-62`)
- Memory optimization: huge pages (2MB/1GB), pre-allocation, object pooling, cache-line alignment (64-byte), short-string optimization (`01_Low-Latency.md:80-92`)
- GC mitigation: .NET `GC.TryStartNoGCRegion()`, server GC, pinned arrays; Java Azul Zing C4, ZGC, Shenandoah, or off-heap (`01_Low-Latency.md:80-92`)
- FPGA acceleration for protocol parsing, risk checks, order generation (`01_Low-Latency.md:80-92`)
- Latency measurement: hardware NIC timestamps (nanosecond), percentile reporting p50/p99/p99.9/p99.99 (`01_Low-Latency.md:94-102`)

### Latency Budget (Co-Located System)
- Total tick-to-trade: ~20-30us aggressive; NIC-to-app 1-3us, decode 0.5-2us, book update 0.1-0.5us, strategy 1-10us, risk check 1-5us, order encode 0.5-2us, app-to-NIC 1-3us, wire 0.1-0.5us (`docs/trading-desk/07-infrastructure-and-architecture/03_Capacity-Planning-And-Database-Considerations.md:14-28`)

### Event-Driven Architecture
- Event sourcing: immutable ordered log of all state-changing events; state derived by replay; enables audit trail, DR, testing (`01_Low-Latency.md:108-125`)
- CQRS: separate write model (command handlers) from read model (projections for blotters, risk, compliance) (`01_Low-Latency.md:127-150`)
- CEP engines: Esper, Apama (algo trading/surveillance), kdb+/q, Apache Flink, Kafka Streams; used for algo signals, risk monitoring, surveillance (`01_Low-Latency.md:160-178`)

### High Availability
- Active-Active: both sites process traffic; challenge is state sync and split-brain (`docs/trading-desk/07-infrastructure-and-architecture/02_High-Availability-And-System-Monitoring.md:7-22`)
- Active-Passive: hot standby with <30s failover; warm standby with manual activation (`02_HA.md:24-39`)
- RTO/RPO: OMS <2min/zero-loss, market data <30s, risk <1min/zero, post-trade <15min/<1min, analytics <1hr/<5min (`02_HA.md:41-49`)
- Geo-redundant: Primary (co-lo), DR (nearby facility), Tertiary (different region), Office (`02_HA.md:59-68`)
- Quarterly mandatory DR tests; chaos engineering; regulatory expectation (SEC, FCA, MAS) (`02_HA.md:70-75`)

### Monitoring
- SLA targets: 99.99% availability (<52 min/year), order ack <500us p99, market data <100us (co-lo), risk check <50us, failover <2min (`02_HA.md:129-140`)
- Stack: Prometheus/InfluxDB + Grafana (dashboards), ELK/Splunk (logs), Corvil/Pico (wire-level nanosecond), Geneos (ITRS), Alertmanager/PagerDuty (`02_HA.md:102-127`)

### Capacity Planning
- Order entry: 1K-100K orders/sec with 5-10x peak multiplier; market data ingest: 1-10M msgs/sec per exchange with 3-5x peak (`03_Capacity-Planning.md:1-11`)
- Exchange rate limits: CME iLink3 500 msgs/sec/session, Nasdaq 10K+, NYSE 1K/sec/MPID, Cboe 10K+ (`03_Capacity-Planning.md:30-40`)
- OPRA peak: 100M+ msgs/sec (highest throughput feed globally) (`03_Capacity-Planning.md:42-52`)
- Headroom: 30-50% CPU on critical path, 50% memory; hardware refresh 18-24 months (`03_Capacity-Planning.md:54-60`)

### Database Considerations
- kdb+/q: de facto standard for tick data; column-oriented, in-memory + memory-mapped; millions rows/sec ingest, billions queried in milliseconds (`03_Capacity-Planning.md:70-78`)
- Relational: SQL Server (dominant .NET), Oracle (large banks), PostgreSQL (increasingly replacing both) (`03_Capacity-Planning.md:101-117`)
- In-memory grids: Redis, Hazelcast, Oracle Coherence, Apache Ignite, Microsoft Garnet (.NET-optimized, Redis-compatible) (`03_Capacity-Planning.md:119-139`)
- Common caches: instrument cache, position cache, price cache, order state cache, risk limit cache (`03_Capacity-Planning.md:133-139`)

### Security
- Network segmentation: Internet/DMZ -> Corporate -> Trading DMZ -> Trading Core (no internet) -> Exchange Connectivity (most restricted) (`docs/trading-desk/07-infrastructure-and-architecture/04_Security-And-Configuration-Management.md:1-33`)
- Encryption: TLS 1.2+ for FIX, mTLS for internal cross-zone, TDE for data at rest, HashiCorp Vault / HSM for keys (`04_Security.md:35-43`)
- Access: RBAC, entitlement management (instruments/venues/order types), four-eyes principle, PAM (CyberArk) (`04_Security.md:45-51`)
- Audit logging: all order events, user actions, system events; 5-7 year retention; WORM storage; NTP/PTP sync to UTC (`04_Security.md:60-70`)

## 8. Position Tracking, Multi-Currency Handling, P&L Calculations, Reconciliation, and SOD/EOD Procedures

### Position Tracking
- Position key: `(Account, Instrument, Settlement Date, Currency, Legal Entity)` (`docs/trading-desk/04-position-management/01_Real-Time-Position-Tracking.md:1-21`)
- Core fields: Quantity (signed), AverageCost, MarketPrice, RealizedPnL, UnrealizedPnL, TotalPnL, Notional (`01_Position-Tracking.md:11-21`)
- Realized P&L: `(ExitPrice - EntryCost) * ClosedQuantity * ContractMultiplier`; final and does not change (`01_Position-Tracking.md:39-53`)
- Unrealized P&L: `(MarketPrice - AverageCost) * Quantity * ContractMultiplier`; changes with every tick (`01_Position-Tracking.md:55-71`)
- MTM sources by type: listed equities (last trade/mid-quote), OTC derivatives (model price), fixed income (vendor evaluated price), FX (mid-rate), illiquid (stale price with flag) (`01_Position-Tracking.md:63-71`)

### P&L Attribution
- Decomposition: `TotalPnL = TradePnL + PositionPnL + CarryPnL + FxPnL + FeesAndCommissions` (`01_Position-Tracking.md:84-98`)
- TradePnL = slippage vs arrival price; PositionPnL = market moves on SOD positions; CarryPnL = accrued interest/dividends/funding; FxPnL = currency moves on foreign positions (`01_Position-Tracking.md:84-98`)

### Position Views and Aggregation
- Dimensions: Account, Desk, Trader, Strategy, Instrument, Asset Class, Currency, Legal Entity, Sector, Geography, Counterparty, Custodian (`01_Position-Tracking.md:101-121`)
- Implementation: materialized aggregations (low latency, high memory), on-demand roll-ups, or OLAP cubes (`01_Position-Tracking.md:122-130`)
- Gross vs Net: Gross = sum(abs(qty)), Net = sum(qty signed), Gross Notional = sum(abs(qty * price * multiplier)) (`01_Position-Tracking.md:144-155`)
- Netting levels: trade-level (no netting), position, account, legal entity, counterparty (ISDA), CCP (`01_Position-Tracking.md:157-169`)

### Multi-Currency Handling
- Base currency conversion: `Value_Base = Value_Local * FxRate(Local->Base)`; EOD using WM/Reuters 4pm London fix (`docs/trading-desk/04-position-management/02_Multi-Currency-Positions.md:1-14`)
- Cross-currency P&L decomposition: `PnL_Base = (P1-P0)*FX0*Qty*Mult + P0*(FX1-FX0)*Qty*Mult + cross-term` (`02_Multi-Currency.md:32-55`)
- Multi-currency cash ladder tracks SOD balance, buys, sells, fees, EOD balance, base equivalent per currency (`02_Multi-Currency.md:58-70`)

### Margin Management
- Reg T (US equities): 50% initial, 25% maintenance (FINRA min, brokers 30-40%) (`02_Multi-Currency.md:112-122`)
- Portfolio margin: risk-based (TIMS/SPAN/OCC), typically 4-6x more buying power than Reg T for hedged portfolios (`02_Multi-Currency.md:76-100`)
- SPAN: 16 scenarios (price ±3 std dev, vol ±1 shift); margin = max loss across all scenarios with inter-commodity spread offsets (`02_Multi-Currency.md:124-147`)
- Margin call types: Reg T (T+2), Maintenance (T+3-5), Fed (T+2), Exchange (same day), House (immediate to T+3) (`02_Multi-Currency.md:149-166`)

### Cost Basis and Tax Lots
- Methods: FIFO (oldest first, default IRS), LIFO (newest first), Specific Identification (max control), Average Cost (mutual funds, UK) (`docs/trading-desk/04-position-management/05_Average-Cost-And-Tax-Lot-Tracking.md:9-65`)
- Average cost: `(OldQty * OldAvgCost + NewQty * NewPrice) / (OldQty + NewQty)` (`05_Tax-Lot-Tracking.md:54-65`)
- Wash sale (IRS Section 1091): loss disallowed if substantially identical security purchased within 30 days before/after; disallowed loss added to replacement basis (`05_Tax-Lot-Tracking.md:67-89`)
- Multi-currency tax lots: record LocalPrice, FxRateAtPurchase, BaseCurrencyCost; realized P&L includes both local price and FX changes (`05_Tax-Lot-Tracking.md:91-111`)

### Corporate Actions Impact
- Stock splits: `NewQty = OldQty * Ratio`, `NewAvgCost = OldAvgCost / Ratio`; position value unchanged (`docs/trading-desk/04-position-management/04_Corporate-Actions-Impact-On-Positions.md:9-31`)
- Cash dividends: receivable booked on ex-date, cash credited on pay-date; short sellers owe manufactured dividend (`04_Corporate-Actions.md:33-46`)

### SOD/EOD Procedures
- SOD: position snapshot from prior EOD, reconciliation against custodian/prime broker, corporate action processing, cash projection, margin requirement calculation (`docs/trading-desk/15-operational-workflows/01_Start-Of-Day-And-End-Of-Day-Procedures.md:3-30`)
- EOD: official MTM snap, P&L calculation and sign-off, position reconciliation (internal vs external), margin/collateral calculations, trade and settlement reports, regulatory reports generation, data backup, next-day preparation (`01_SOD-EOD.md:32-65`)
- SOD position: `SOD_Position = Prior_EOD_Position + Overnight_Adjustments (corporate actions, settlements, corrections)` (`01_SOD-EOD.md:3-30`)
- EOD P&L sign-off: trader review, desk head review, risk manager review, finance/accounting validation (`01_SOD-EOD.md:32-65`)

### Reconciliation
- Trade reconciliation: internal OMS/EMS vs broker confirmations, exchange/venue reports, CCP records, custodian records (`docs/trading-desk/13-post-trade-processing/03_Reconciliation-And-Trade-Lifecycle-Events.md:5-27`)
- Position reconciliation dimensions: quantity, market value, settled vs traded, tax lot (`03_Reconciliation.md:28-46`)
- Cash reconciliation: settlement flows, income, corporate action flows, fees, margin, FX (`03_Reconciliation.md:47-62`)
- Breaks management: automated matching with configurable tolerances, aging/escalation (T+1, T+3, T+5), target match rates 95%+ (`03_Reconciliation.md:63-75`)
- Platforms: SmartStream TLM, Broadridge, Gresham Clareti, Duco, Bloomberg AIM (`03_Reconciliation.md:63-75`)

## 9. Execution Algorithms, Smart Order Routing, Execution Quality, and Market Microstructure

### Execution Algorithms
- **VWAP**: targets volume-weighted average using 20-30 day rolling historical volume profile in 1-5-10 minute buckets; participation <15-20% per bucket (`docs/trading-desk/03-execution-and-algorithms/01_Execution-Algorithms-Part-1.md:5-46`)
- **TWAP**: equal slices across N intervals regardless of volume; ±20-30% randomization with catch-up logic (`01_Algos-Part-1.md:49-76`)
- **POV/Participation**: maintains target % of real-time consolidated tape volume, self-adapting (`01_Algos-Part-1.md:79-112`)
- **Implementation Shortfall**: minimizes cost vs arrival price; cost model: market impact + timing risk + opportunity cost; square-root/power-law/Almgren-Chriss impact models (`01_Algos-Part-1.md:115-162`)
- **MOC/Close**: 30-50% pre-close, 50-70% in auction; NYSE imbalance at 15:50 ET, irrevocable after 15:50 (NYSE)/15:55 (NASDAQ) (`docs/trading-desk/03-execution-and-algorithms/02_Execution-Algorithms-Part-2.md:3-34`)
- **Iceberg/Reserve**: exchange-native or algo-managed; anti-detection via display variance, random delays 50-500ms, venue rotation (`02_Algos-Part-2.md:37-71`)
- **Sniper/Liquidity Seeking**: passive monitoring then aggressive take; dark pool pinging min 100-200 shares, controlled frequency (`02_Algos-Part-2.md:74-109`)
- **Dark Pool**: dark-only or dark-preferring; fill probability models using logistic regression or gradient boosted models (`02_Algos-Part-2.md:112-140`)
- **Pairs Trading**: simultaneous execution of two correlated legs; ratio-based or spread-based; hard leg (less liquid) first (`02_Algos-Part-2.md:143-170`)
- **Adaptive/Multi-Strategy**: dynamic switching based on momentum, volatility, spread dynamics, order book imbalance; ML-driven (`02_Algos-Part-2.md:173-192`)

### Algorithm Parameters
- Urgency levels: PASSIVE (3-5% participation), LOW (5-10%), MEDIUM (10-20%), HIGH (20-35%), AGGRESSIVE (35-50%), HYPER (50%+) (`docs/trading-desk/03-execution-and-algorithms/03_Algorithm-Parameters-And-Customization.md:22-34`)
- FIX strategy params: Tag 847 (StrategyParametersGrp), Tag 958/959/960; FIXatdl XML schema for parameter definitions (`03_Algo-Params.md:69-83`)

### Smart Order Routing
- US lit venues: NYSE, NASDAQ, NYSE Arca, BATS BZX/BYX, IEX, EDGX/EDGA, NYSE American, LTSE, MEMX, MIAX Pearl (`docs/trading-desk/03-execution-and-algorithms/04_Smart-Order-Routing.md:8-23`)
- Dark pools: UBS ATS, CrossFinder, Sigma-X2, MS Pool, JPM-X, MatchIt, Citadel Connect, Level ATS, IntelligentCross (`04_SOR.md:24-35`)
- Fee optimization: standard maker-taker (NYSE Arca: -$0.0020 maker rebate, +$0.0030 taker fee) vs inverted (BATS BYX: +$0.0004 maker fee, -$0.0005 taker rebate) (`04_SOR.md:52-72`)
- SOR decision flow: determine intent -> evaluate dark pools -> if aggressive, score venues and route IOC -> if passive, evaluate queue position and route to best rebate (`04_SOR.md:125-140`)

### Execution Quality Measurement (TCA)
- Cost components: explicit (commission, fees, taxes) + implicit (spread, market impact, timing, opportunity, delay) (`docs/trading-desk/03-execution-and-algorithms/07_Execution-Quality-Measurement.md:9-24`)
- Benchmarks: Arrival Price (most popular for IS), VWAP, TWAP, Close, Open, Previous Close (`07_TCA.md:25-36`)
- IS decomposition: `Total IS = Delay Cost + Trading Cost + Opportunity Cost`; `Trading Cost = Impact + Timing + Spread` (`07_TCA.md:37-64`)
- Per-order metrics: Arrival Slippage (bps), VWAP Slippage, Spread Capture, Fill Rate, Participation Rate, Time to Fill (`07_TCA.md:65-76`)
- TCA vendors: Abel Noser, ITG/Virtu, Bloomberg BTCA, Liquidmetrix (`07_TCA.md:87-108`)

### Market Microstructure
- Spread determinants: volatility, volume, tick size, market makers, information asymmetry; intraday pattern widest at open, narrows through day (`docs/trading-desk/03-execution-and-algorithms/10_Market-Microstructure.md:3-32`)
- US tick size: $0.01 for stocks >= $1.00 (Rule 612 Sub-Penny), $0.0001 for <$1.00 (`10_Microstructure.md:3-32`)
- Order book imbalance: `(bid_size - ask_size) / (bid_size + ask_size)` predictive of short-term price direction (`10_Microstructure.md:33-54`)
- Queue priority: Price-Time/FIFO (most US), Price-Size-Time, Pro-Rata (CME Eurodollar), Price-Display-Time (`10_Microstructure.md:91-120`)
- Venue toxicity: VPIN `|buy_vol - sell_vol| / total_vol` (high = toxic); spread decomposition into adverse selection/inventory/processing components (`docs/trading-desk/03-execution-and-algorithms/08_Execution-Venue-Analysis.md:48-78`)

## 10. Post-Trade Processing, Audit Trail Requirements, and Compliance/Regulatory Reporting

### Trade Confirmation and Settlement
- Matched fields: trade date, settlement date, ISIN/CUSIP/SEDOL, side, quantity, price, currency, counterparty (BIC/LEI), accrued interest, net amount (`docs/trading-desk/13-post-trade-processing/01_Trade-Confirmation-And-Clearing-Settlement.md:5-35`)
- SEC Rule 15c6-2 (May 2024): allocations, confirmation, affirmation by end of trade date (`01_Confirmation.md:36-50`)
- DTCC/Omgeo CTM: trade submission -> central matching -> exception handling -> affirmation -> DTC settlement; SDA target >90% (`01_Confirmation.md:51-73`)
- Settlement cycles: US/Canada T+1 (May 2024), EU/UK/HK/Japan/Australia T+2 (`01_Confirmation.md:118-145`)
- Fails: CSDR penalties (EU) based on instrument type; resolution via buy-in, partial settlement, securities lending, shaping (`01_Confirmation.md:146-167`)

### CCP Clearing
- Key CCPs: NSCC (US equities), OCC (options), LCH (EU swaps/CDS), Eurex Clearing, ICE Clear Europe (`01_Confirmation.md:78-106`)
- Process: trade capture -> novation -> margining (IM + VM) -> netting -> settlement instruction (`01_Confirmation.md:78-106`)
- Bilateral clearing: ISDA confirmation, ISDA CSA collateral, UMR for uncleared OTC derivatives >$8B AANA (`01_Confirmation.md:107-117`)

### Allocation and Corporate Actions
- Block allocation: pre-trade intent -> execution -> allocation instruction -> matching -> booking; allocations by EOD per SEC 15c6-2 (`docs/trading-desk/13-post-trade-processing/02_Trade-Allocation-And-Corporate-Actions.md:3-27`)
- Average price: FINRA 5320.02 permits for institutional; all accounts receive same per-share price (`02_Allocation.md:43-58`)
- Corporate actions: cash dividends, stock splits, mergers, spinoffs tracked via DTCC GCA, SWIFT MT564-568, Bloomberg CACS (`02_Allocation.md:61-120`)

### Reconciliation
- Trade recon: OMS/EMS vs broker vs exchange vs CCP vs custodian; intraday + T+0 evening definitively for T+1 settlement (`docs/trading-desk/13-post-trade-processing/03_Reconciliation-And-Trade-Lifecycle-Events.md:5-27`)
- Breaks management: automated matching, aging/escalation (T+1/T+3/T+5), target 95%+ match rates (`03_Reconciliation.md:63-75`)
- Trade lifecycle: amendments (modify terms, counterparty agreement, audit trail), cancellations (cancel-and-rebook, downstream notification), late trades (NAV impact monitoring) (`03_Reconciliation.md:78-150`)

### STP and Middle Office
- STP rates: trade capture 99%+, allocation 95%+, confirmation 90-95%, end-to-end 85-95%; listed equities 95%+, corporate bonds 70-85%, OTC derivatives 50-70% (`docs/trading-desk/13-post-trade-processing/05_STP-Exception-Management-Middle-Office-And-Glossary.md:3-28`)
- Trade enrichment: SSI lookup, fees/commissions, accrued interest, tax lot assignment, regulatory classification, FX conversion (`05_STP.md:86-99`)

### Audit Trail Requirements
- MiFID II RTS 25: all order decisions (including algo ID), submissions, modifications, cancellations, executions with millisecond timestamps (microsecond for HFT) (`docs/trading-desk/14-compliance-and-regulatory/05_Record-Keeping-Requirements.md:1-26`)
- SEC Rule 17a-3/17a-4: blotters, customer records, order tickets, confirmations, trial balances (`05_Record-Keeping.md:1-26`)
- Clock sync: MiFID II 1us (HFT), 1ms (electronic), 1s (non-electronic); FINRA/CAT within 50ms of NIST (`05_Record-Keeping.md:22-26`)
- Communication records: telephone, Bloomberg chat, Symphony, email; off-channel (WhatsApp) subject of $2B+ enforcement fines 2021-2024 (`05_Record-Keeping.md:27-43`)
- Retention: MiFID II 5 years, SEC 17a-4 blotters 6 years / order tickets 3 years, EMIR 5 years after termination, SFTR 10 years (`05_Record-Keeping.md:44-64`)
- WORM storage required under SEC 17a-4(f) (`05_Record-Keeping.md:44-64`)

### Regulatory Reporting
- MiFID II Article 26: T+1 to NCA via ARM; 65 fields including LEI, national ID, algo ID, short sale indicator (`docs/trading-desk/14-compliance-and-regulatory/03_Regulatory-Reporting.md:5-35`)
- EMIR Refit (April 2024): 203 fields (up from 129), mandatory ISO 20022 XML, UTI/UPI alignment (`03_Regulatory-Reporting.md:36-57`)
- Dodd-Frank: CFTC Part 43 real-time within 15-30 min, Part 45 regulatory data to SDRs (`03_Regulatory-Reporting.md:59-78`)
- CAT (SEC Rule 613): every order event for US equities/options; replaces OATS; microsecond timestamps for electronic; T+3 error correction (`03_Regulatory-Reporting.md:79-94`)
- SEC Rule 606: quarterly routing disclosure for non-directed orders; customer-specific on request within 7 business days (`03_Regulatory-Reporting.md:108-122`)

### Best Execution
- Metrics: price improvement %, effective vs quoted spread, IS decomposition, VWAP slippage, fill rates, latency, reversion (5s/1m/5m/30m) (`docs/trading-desk/14-compliance-and-regulatory/04_Best-Execution-Monitoring-And-Reporting.md:1-50`)
- MiFID II RTS 28: annual report of top 5 venues by volume per instrument class, separately for retail/professional (`04_Best-Execution.md:1-50`)

## 11. Trading UI Components, Workspace Layouts, Keyboard Patterns, and Dashboard/Analytics Views

### Order Entry Tickets
- Single-stock: Symbol, Side, Quantity, Order Type, Limit/Stop Price, TIF, Account, Destination, Algo with sub-parameters panel; fat-finger and price reasonability checks (`docs/trading-desk/16-trading-ui-components/01_Order-Entry-Tickets-And-Trading-Blotter.md:5-40`)
- Multi-leg/options: strategy template, legs table, net debit/credit, greeks display (delta/gamma/theta/vega), P&L payoff diagram (`01_Order-Entry.md:42-63`)
- FX ticket: deal type (Spot/Forward/Swap/NDF), notional toggle, tenor shortcuts, streaming bid/ask (`01_Order-Entry.md:65-83`)
- Fixed income: CUSIP/ISIN/SEDOL, price type (clean/yield/spread/OAS), benchmark selection, RFQ mode (`01_Order-Entry.md:85-104`)
- Keyboard shortcuts: `F2`/`/` symbol search, `B` buy, `S` sell, `Enter` submit, `+/-` tick price, `Ctrl+Up/Down` quantity (`01_Order-Entry.md:116-130`)

### Blotters
- Order blotter columns: Order ID, Time, Symbol, Side, Qty, Filled, Remaining, Type, Limit Price, Avg Fill, TIF, Status, Account, Algo, % Complete, Trader (`01_Order-Entry.md:137-162`)
- Status colors: New (light blue), Acknowledged (blue), Partially Filled (yellow), Filled (green), Cancelled (gray), Rejected (red), Expired (dark gray), Replaced (purple), Pending Cancel (orange) (`01_Order-Entry.md:164-178`)
- Execution blotter: microsecond precision timestamps, Venue, Liquidity (Add/Remove), Avg Price formula `SUM(FillQty_i * FillPrice_i) / SUM(FillQty_i)` (`docs/trading-desk/16-trading-ui-components/02_Execution-Blotter-And-Position-Blotter.md:1-50`)
- Position blotter: net quantity, avg cost, last price, unrealized/realized/total P&L, day P&L, beta-adj exposure; flash green/red on tick; heat map treemap view (`02_Position-Blotter.md:53-115`)

### Market Data Displays
- Watchlist: symbol, last, change, bid/ask/spread, volume, VWAP, OHLC; typeahead supporting ticker/name/CUSIP/ISIN (`docs/trading-desk/16-trading-ui-components/03_Market-Data-Displays.md:4-39`)
- Level 2 / Market Depth: bid/ask sides with price/size/orders columns, size bars, click-to-trade, depth chart visualization (`03_Market-Data-Displays.md:55-84`)
- Time and Sales: microsecond timestamps, color: green (at ask/uptick), red (at bid/downtick), gray (mid); cumulative buy/sell volume (`03_Market-Data-Displays.md:86-111`)

### Charting
- Types: Candlestick, Bar, Line, Area, Heikin-Ashi, Renko, Point & Figure, Volume Profile (`docs/trading-desk/16-trading-ui-components/03_Market-Data-Displays.md` charting section)
- Timeframes: 1-tick through yearly; multi-timeframe 2x2 layout (`03_Market-Data-Displays.md` charting section)
- Indicators: SMA, EMA, VWAP, Ichimoku, RSI (14), MACD (12,26,9), Stochastic, Bollinger (20,2), ATR, Volume Profile (`03_Market-Data-Displays.md` charting section)
- Drawing tools: trend/horizontal/vertical lines, channels, Fibonacci retracement/extension, pitchfork, patterns; snap-to-price, alert-on-cross (`03_Market-Data-Displays.md` charting section)

### Workspace Management
- Layout: tabbed panels, split panes, floating windows, docking system with visual guides (`docs/trading-desk/16-trading-ui-components/06_Workspace-Keyboard-And-UX-Patterns.md:3-12`)
- Typical 6-monitor arrangement: watchlists (top-left), charts 2x2 (top-center), news (top-right), order/execution blotters (bottom-left), positions/L2 (bottom-center), risk/alerts (bottom-right) (`06_Workspace.md:14-23`)
- Symbol linking: color-coded groups (Red, Blue, Green, Yellow); components in same group share selected symbol (`06_Workspace.md:45-50`)
- Workspace save/load: named workspaces, auto-save, export/import, all component state preserved (`06_Workspace.md:25-35`)

### Keyboard-Driven Trading
- Global: `Ctrl+N` new order, `Ctrl+Shift+B` quick-buy, `Ctrl+Shift+S` quick-sell, `Ctrl+F` command palette, `Ctrl+1-9` switch workspace, `F11` fullscreen (`06_Workspace.md:64-78`)
- Order management: `Ctrl+Shift+C` cancel selected, `Ctrl+Shift+A` cancel all for symbol, `Ctrl+Shift+X` cancel all (panic), `Ctrl+Shift+F` flatten position, `Ctrl+Shift+P` flatten all (`06_Workspace.md:80-89`)
- Speed trader: pre-configured templates bound to keys, numeric pad quantity entry, price ladder (DOM) one-click trading (`06_Workspace.md:91-102`)
- Command palette: `Ctrl+Shift+P`, searches symbols/actions/components/settings/recent (`06_Workspace.md:104-112`)
- Customizable keybindings with conflict detection, context-aware, chord support (`06_Workspace.md:114-120`)

### UX Patterns
- Dark theme dominant; green=positive/buy, red=negative/sell (inversible for Asian markets) (`06_Workspace.md:126-130`)
- Cell flash 200-500ms on update, tick arrows, stale data indicator (dimmed after 5s), connection status indicator (`06_Workspace.md:132-136`)
- Performance: market data 1-5ms co-lo, blotter update 1ms after FIX, chart 60fps (16ms), startup 5-15s, memory 2-8GB (`06_Workspace.md:146-152`)

### Dashboards
- P&L dashboard: summary bar (Day/MTD/YTD P&L), intraday chart with ±1 std dev band, breakdown by strategy/trader; drill-down to position to execution (`docs/trading-desk/17-dashboard-and-analytics/01_Real-Time-Dashboards.md:1-40`)
- Risk dashboard: VaR/CVaR, net/gross exposure, greeks, limit monitoring (green/yellow/orange/red), scenario analysis panel, greeks surface (3D delta/gamma/vega) (`01_Dashboards.md:42-87`)
- Execution dashboard: fill rate, cancel rate, VWAP slippage, IS, quality by venue and by algo (`01_Dashboards.md:89-128`)

### Portfolio Analytics
- Brinson attribution: Allocation Effect + Selection Effect + Interaction Effect = Total Active Return (`docs/trading-desk/17-dashboard-and-analytics/03_Performance-Attribution.md:1-26`)
- Factor attribution: Market/Size/Value/Momentum/Quality/Industry/Country/Currency/Specific contributions (`03_Attribution.md:28-47`)
- Factor exposure: Barra/Axioma/Northfield models; factor contribution to return and risk decomposition (`docs/trading-desk/17-dashboard-and-analytics/02_Portfolio-Analytics.md:79-99`)

### Data Visualization
- Heat maps: position (size=market value, color=P&L%), correlation (blue +1 to red -1), sector (treemap) (`docs/trading-desk/17-dashboard-and-analytics/05_Data-Visualization.md:1-27`)
- Volatility surfaces: 3D plot (expiration x strike x IV), 2D slices (smile/skew, term structure) (`05_Visualization.md:102-131`)
- Yield curves: spot/forward/spread/real/breakeven; slope indicators (2s10s, 3m10y) (`05_Visualization.md:76-100`)

### Custom Analytics
- Formula columns: spreadsheet-like calculated columns in blotters/watchlists, real-time recalculation (`docs/trading-desk/17-dashboard-and-analytics/06_Custom-Analytics-And-Scripting.md:1-38`)
- Screening: universe selector, criteria builder, predefined scans (unusual volume, 52w highs, gap up/down, RSI extremes) (`06_Custom-Analytics.md:72-94`)
- Backtesting: entry/exit rules, position sizing, commission/slippage; output metrics including Sharpe, Sortino, max drawdown (`06_Custom-Analytics.md:96-125`)

### Compliance Views
- Trade surveillance: spoofing, wash trading, front-running, insider trading, marking the close; investigation workflow with timeline reconstruction (`docs/trading-desk/17-dashboard-and-analytics/07_Audit-And-Compliance-Views.md:1-63`)
- Communication monitoring: keyword detection, sentiment analysis, trade-communication correlation; 5-7 year retention (`07_Compliance-Views.md:65-87`)

### Dashboard Design Principles
- Refresh rates: prices streaming 1-50ms, P&L per tick or 1s, risk 1s-1min, attribution 15-60min or EOD (`docs/trading-desk/17-dashboard-and-analytics/08_Dashboard-Design-Principles.md:10-20`)
- Interactivity: drill-down on every number, cross-filtering, tooltip on hover, CSV/XLSX/PDF/PNG export, Ctrl+Z undo (`08_Design-Principles.md:22-29`)

## 12. Cryptocurrency-Specific Derivatives Features Related to Kraken Integration

### CME Bitcoin Futures
- Contract size: 5 BTC; tick size $5/BTC ($25/contract); cash-settled to CME CF Bitcoin Reference Rate (BRR) (`docs/trading-desk/12-futures-and-listed-derivatives/05_Cryptocurrency-Derivatives.md:3-13`)
- BRR calculated from 5 exchanges: Coinbase, Kraken, Bitstamp, Gemini, LMAX Digital at 4:00 PM London time (`05_Crypto-Derivatives.md:10`)
- Trading hours: Sun-Fri 5:00 PM - 4:00 PM CT; margin ~40-50% of notional (`05_Crypto-Derivatives.md:3-13`)
- Micro Bitcoin (MBT): 0.1 BTC, $5/BTC ($0.50/contract) (`05_Crypto-Derivatives.md:15-19`)
- CME Ether Futures: 50 ETH, $0.25/ETH ($12.50/contract), cash-settled to CME CF Ether-Dollar Reference Rate (`05_Crypto-Derivatives.md:21-24`)
- Bitcoin Options on CME: European, 5 BTC, monthly/weekly, Black-76 model (`05_Crypto-Derivatives.md:26-33`)

### Perpetual Swaps (Crypto-Native)
- No expiration; tracks spot via funding rate exchanged every 8 hours (`05_Crypto-Derivatives.md:35-56`)
- Funding rate formula: `FundingRate = PremiumIndex + clamp(InterestRate - PremiumIndex, -0.05%, 0.05%)` where `PremiumIndex = (MarkPrice - IndexPrice) / IndexPrice` (`05_Crypto-Derivatives.md:44-50`)
- Positive rate: longs pay shorts (premium to spot); negative: shorts pay longs (`05_Crypto-Derivatives.md:44-50`)
- Leverage up to 125x on some exchanges; professionals use 1-10x (`05_Crypto-Derivatives.md:35-56`)
- Liquidation: when unrealized loss exceeds maintenance margin; insurance fund covers shortfalls; auto-deleveraging (ADL) as last resort (`05_Crypto-Derivatives.md:56-58`)
- Mark price: multi-exchange index to prevent manipulation-driven liquidations (`05_Crypto-Derivatives.md:58`)

### CME vs Perpetual Comparison
- CME: monthly/quarterly expiration, cash-settled, CFTC-regulated, CCP-cleared, ~2-2.5x leverage, 23hr/5day; Perpetuals: no expiration, funding rate, largely unregulated, exchange risk, up to 125x, 24/7/365 (`05_Crypto-Derivatives.md:60-71`)

### Crypto Options
- Deribit: ~90% global crypto options volume; European, cash-settled, portfolio margining, block trading (`05_Crypto-Derivatives.md:73-83`)

### Margin and Clearing
- CME: SPAN margin with 16 scenarios, ~40-50% for crypto (higher than traditional due to volatility) (`docs/trading-desk/12-futures-and-listed-derivatives/03_Clearing-Margining-And-Settlement.md:24-32`)
- Variation margin: CME daily (often intraday for large moves); perpetuals continuous or 8-hourly (`03_Clearing.md:34-42`)

### Basis Trading (Kraken Integration)
- Basis = Futures Price - Spot Price; fair value via cost-of-carry: `Spot * e^((r-q)*T)` (`docs/trading-desk/12-futures-and-listed-derivatives/06_Cross-Margining-And-Basis-Trading.md:58-78`)
- Cash-and-carry arbitrage: buy spot on Kraken, sell CME futures, hold to expiration; profit = (Futures - Fair Value) - financing costs (`06_Basis-Trading.md:87-102`)
- Perpetual basis: no convergence date; funding rate creates carry; buy spot + short perpetual when premium exists (`06_Basis-Trading.md` implied from perpetual mechanism)
- Kraken is one of five BRR constituent exchanges, making it directly relevant to CME settlement calculations (`05_Crypto-Derivatives.md:10`)

## Cross-cutting observations

- **Authentication pattern consistency**: Both Kraken spot and futures APIs use HMAC-SHA512 with base64-decoded secrets and SHA256 intermediate hashing, but differ in input construction (spot: URI+SHA256(nonce+POST); futures: SHA256(postData+nonce+path)) (`01_Authentication.md:22-24`, `03_Rest.md:26-35`)
- **FIX protocol pervasive**: FIX protocol appears as the lingua franca across order management (`01_FIX-Protocol.md`), execution reports (`01_Execution-Report.md`), Kraken spot FIX API (`04-spot-fix/`), and market data (`03_Data-Normalization.md:67-75`), with consistent tag numbering throughout
- **Three Kraken connectivity modes**: spot exchange offers REST, WebSocket v1/v2, and FIX APIs; futures offers REST and WebSocket; no futures FIX documented in repo
- **Event sourcing alignment**: the documented event-driven architecture (`01_Low-Latency.md:108-125`) and CQRS patterns (`01_Low-Latency.md:127-150`) align with the immutable audit trail requirements from compliance (`05_Record-Keeping.md:60-70`)
- **Pure Zig constraint**: no existing source code exists in the repository; all documentation is in `docs/` directory; the CLAUDE.md notes the project targets .NET/C# but memory indicates actual direction is Zig with zero external dependencies
- **Documentation is comprehensive**: the `docs/trading-desk/` directory contains 17 major sections with detailed specifications covering all aspects of a professional trading desk; `docs/kraken-exchange-documentation/` contains 8 major sections with full API specifications

## Coverage gaps

- No gaps identified. All 12 questions have corresponding findings with file:line references from the documentation.
