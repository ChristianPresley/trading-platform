---
phase: 2
iteration: 01
generated: 2026-04-04
---

# Research: Complete and Extensive Synthetics for Demo Mode

Questions source: .claude/specs/demo-mode-synthetics/01-questions-01.md

## How does `trading/desk/synthetic.zig` generate market data today?

- Two instruments hardcoded: `"BTC-USD"` and `"ETH-USD"` at `trading/desk/synthetic.zig:22`
- Fixed-point arithmetic with 8 decimal places; BTC base price 5,000,000,000,000 (=50,000 USD), ETH base price 300,000,000,000 (=3,000 USD) at `trading/desk/synthetic.zig:27-28`
- **Random walk**: tick_size = 100,000 (=0.001 USD), equal probability up/down via `rand.boolean()` at `trading/desk/synthetic.zig:75-79`
- **Incremental updates**: 1–3 price levels updated per tick via `rand.intRangeAtMost(usize, 1, 3)` at `trading/desk/synthetic.zig:84-92`; updates both bid and ask sides symmetrically around base
- **Full book snapshot refresh**: every 20 ticks via `populateBook()` at `trading/desk/synthetic.zig:95-97`
- **Book depth**: 20 levels per side (`DEPTH = 20`) at `trading/desk/synthetic.zig:9`
- L2Book from `sdk/domain/orderbook.zig` with `bids_buf`/`asks_buf` pre-allocated arrays of `Level` structs; bids sorted descending, asks sorted ascending at `sdk/domain/orderbook.zig:45-60`
- Snapshot initialization creates 20 bid/ask levels at `trading/desk/synthetic.zig:54-69`; quantity per level random between 100,000 and 10,000,000 at `trading/desk/synthetic.zig:63`
- Incremental updates via `applyUpdate()` at `sdk/domain/orderbook.zig:65-71` (upsert/remove by price level); snapshot replacement via `applySnapshot()` at `sdk/domain/orderbook.zig:39-61`
- Tick frequency: 100ms (100,000,000 ns) sleep per engine loop iteration at `trading/desk/engine.zig:217`

## How does `trading/desk/engine.zig` consume synthetic data and route it to the TUI?

- **Main loop** at `trading/desk/engine.zig:144-219`: calls `self.feed.tick()` at line 149, then `snapshotBook()` at `trading/desk/engine.zig:112-141` to convert L2Book to OrderbookSnapshot (up to 20 bids/asks)
- **Ring buffer transport**: lock-free SPSC ring buffers (capacity 256) at `trading/desk/main.zig:52-56`; `to_tui` for EngineEvent, `from_tui` for UserCommand
- Pushes `EngineEvent.orderbook_snapshot` at `trading/desk/engine.zig:158` for each instrument per tick
- **Candle aggregation**: two BarAggregators (one per instrument) at `trading/desk/engine.zig:61-62`, 1-minute intervals (60,000,000,000 ns) at line 98; fed BBO midpoint via `onTrade()` at line 163; completed bars published as `CandleUpdate` at lines 164-173

### Stub functions (demo mode markers)

- **riskValidateStub** at `trading/desk/engine.zig:24-29`: always returns `true`, discards order and risk pointer; live mode would call pre-trade risk module
- **storeAppendStub** at `trading/desk/engine.zig:31-36`: no-op returning dummy offset 0; live mode would persist audit trail
- **Dummy opaque pointers** at `trading/desk/engine.zig:39-40`: `var dummy_risk: u8 = 0` and `var dummy_store: u8 = 0` passed to OrderManager.init()

### OMS integration

- OrderManager initialized at `trading/desk/engine.zig:77-83` with injected function pointers
- Order submission flow: TUI sends OrderRequest → engine drains at line 200 → `handleOrderRequest()` at line 209 → creates Order struct at lines 223-235 → `self.oms.submitOrder(order)` at line 237 → risk stub always passes at `sdk/domain/oms.zig:206` → order assigned ID and status `pending_new` at `sdk/domain/oms.zig:209-214` → store stub discards at `sdk/domain/oms.zig:219`
- Cancel path: `self.oms.cancelOrder(id)` at `trading/desk/engine.zig:212`

### Demo vs. live mode gaps

| Feature | Demo (Current) | Live Mode Requirement |
|---------|----------------|----------------------|
| Risk validation | Always pass (stub) | Real risk module |
| Event store | Discard (stub) | Persist to database/log |
| Fill matching | None — orders stay pending | Exchange fill callbacks |
| PnL calculation | unrealized_pnl = 0 (line 185) | Mark-to-market with ref prices |
| Position tracking | SimplePosition array at lines 43-48 | Full PositionManager with lots |
| Instruments | Hardcoded 2 | Dynamic subscription |

## What is the full set of message types in `trading/desk/messages.zig`?

### EngineEvent variants (`trading/desk/messages.zig:76-84`)

| Variant | Receives Synthetic Data? | Source / Notes |
|---------|-------------------------|----------------|
| `tick: u64` (line 77) | No — never pushed to TUI | Defined but unused; empty match at `trading/desk/main.zig:120` |
| `orderbook_snapshot: OrderbookSnapshot` (line 78) | **Yes** | SyntheticFeed random walk book, pushed at `engine.zig:158` |
| `position_update: PositionUpdate` (line 79) | **Yes** (simplified) | SimplePosition at `engine.zig:178-189`; `unrealized_pnl` hardcoded to 0 |
| `order_update: OrderUpdate` (line 80) | **Yes** | User OrderRequest + OMS; `filled_qty` hardcoded to 0 at lines 245, 260 |
| `status: StatusUpdate` (line 81) | **Partial** | `tick` = synthetic counter; `engine_time_ns = 0`, `connected = false` (placeholders) |
| `candle_update: CandleUpdate` (line 82) | **Yes** | BarAggregator computes OHLCV from synthetic book midpoints |
| `shutdown_ack: void` (line 83) | No — signal only | Sent on quit command at `engine.zig:204` |

### UserCommand variants (`trading/desk/messages.zig:86-91`)

| Variant | Status |
|---------|--------|
| `quit: void` (line 87) | Used — user presses 'q' or Ctrl+C at `main.zig:271` |
| `select_instrument: InstrumentId` (line 88) | **Never constructed** — handler exists at `engine.zig:207` but is no-op |
| `submit_order: OrderRequest` (line 89) | Used — OrderEntryPanel at `panels/order_entry_panel.zig:138-143` |
| `cancel_order: u64` (line 90) | **Never constructed** — handler exists at `engine.zig:211-212` |

## What instruments are defined and how does symbol translation work?

### Spot pairs in `sdk/domain/market_data.zig` SPOT_MAP (lines 18-39) — 20 pairs

BTC-USD→XBT/USD, BTC-EUR→XBT/EUR, BTC-GBP→XBT/GBP, BTC-JPY→XBT/JPY, ETH-USD→ETH/USD, ETH-EUR→ETH/EUR, ETH-BTC→ETH/BTC, SOL-USD→SOL/USD, SOL-EUR→SOL/EUR, SOL-BTC→SOL/BTC, ADA-USD→ADA/USD, DOT-USD→DOT/USD, USDC-USD→USDC/USD, USDT-USD→USDT/USD, LINK-USD→LINK/USD, MATIC-USD→MATIC/USD, AVAX-USD→AVAX/USD, ATOM-USD→ATOM/USD, LTC-USD→LTC/USD, XRP-USD→XRP/USD

### Spot pairs in `exchanges/kraken/common/symbol_translator.zig` SPOT_PAIRS (lines 20-42) — 21 pairs

BTC-USD→XXBTZUSD, BTC-EUR→XXBTZEUR, ETH-USD→XETHZUSD, ETH-EUR→XETHZEUR, ETH-BTC→XETHXXBT, SOL-USD→SOLUSD, SOL-EUR→SOLEUR, ADA-USD→ADAUSD, ADA-EUR→ADAEUR, DOT-USD→DOTUSD, DOT-EUR→DOTEUR, LINK-USD→LINKUSD, LINK-EUR→LINKEUR, LTC-USD→XLTCZUSD, LTC-EUR→XLTCZEUR, XRP-USD→XXRPZUSD, XRP-EUR→XXRPZEUR, USDC-USD→USDCUSD, USDT-USD→USDTZUSD, ATOM-USD→ATOMUSD, MATIC-USD→MATICUSD

- Symbol translator has SOL-EUR, ADA-EUR, DOT-EUR, LINK-EUR, LTC-EUR, XRP-EUR (not in market_data.zig); market_data.zig has BTC-GBP, BTC-JPY, SOL-BTC, AVAX-USD (not in translator). The two files are not synchronized.

### Futures in `sdk/domain/market_data.zig` FUTURES_MAP (lines 42-55) — 12 symbols

10 perpetuals: BTC-USD-PERP→PI_XBTUSD, ETH-USD-PERP→PI_ETHUSD, SOL-USD-PERP→PI_SOLUSD, ADA-USD-PERP→PI_ADAUSD, DOT-USD-PERP→PI_DOTUSD, LINK-USD-PERP→PI_LINKUSD, LTC-USD-PERP→PI_LTCUSD, XRP-USD-PERP→PI_XRPUSD, AVAX-USD-PERP→PI_AVAXUSD, ATOM-USD-PERP→PI_ATOMUSD
2 dated: BTC-USD-20231229→FI_XBTUSD_231229, ETH-USD-20231229→FI_ETHUSD_231229

### Futures in `exchanges/kraken/common/symbol_translator.zig` FUTURES_SYMS (lines 45-56) — 10 symbols

BTC-USD-PERP, ETH-USD-PERP, SOL-USD-PERP, ADA-USD-PERP, DOT-USD-PERP, LINK-USD-PERP, LTC-USD-PERP, XRP-USD-PERP, BCH-USD-PERP→PI_BCHUSD (not in market_data.zig), ATOM-USD-PERP. Missing: AVAX-USD-PERP and dated futures.

### Translation methods

- `sdk/domain/market_data.zig` SymbolMapper (lines 59-113): `spotToInternal()`, `futurestoInternal()`, `internalToSpot()`, `internalToFutures()` — return `?[]const u8` (null if unknown)
- `exchanges/kraken/common/symbol_translator.zig` SymbolTranslator (lines 58-116): `toSpotPair()`, `fromSpotPair()`, `toFuturesSymbol()`, `fromFuturesSymbol()` — return `error.UnknownSymbol` if unknown

### Total platform instrument knowledge (union of both tables)

- ~24 unique spot pairs, ~11 perpetuals, 2 dated futures

## How does the Order Management System handle order lifecycle transitions?

### OrdStatus states (`sdk/domain/oms.zig:10-25`) — 14 states

`pending_new`, `new`, `partially_filled`, `filled`, `cancelled`, `replaced`, `pending_cancel`, `rejected`, `suspended`, `pending_replace`, `expired`, `staged`, `validating`, `route_pending`

### ExecType events (`sdk/domain/oms.zig:28-40`) — 11 types

`new`, `partial_fill`, `fill`, `cancelled`, `replaced`, `rejected`, `pending_cancel`, `pending_replace`, `expired`, `suspended`, `restated`

### Terminal states (`sdk/domain/oms.zig:158-163`)

`filled`, `cancelled`, `rejected`, `expired` — cannot transition further

### OrderStateMachine transition table (`sdk/domain/oms.zig:71-164`)

- `validating` → `.new`→`pending_new`, `.rejected`→`rejected`
- `staged` → `.new`→`pending_new`, `.rejected`→`rejected`
- `pending_new` → `.new`→`new`, `.rejected`→`rejected`, `.cancelled`→`cancelled`
- `route_pending` → `.new`→`new`, `.rejected`→`rejected`, `.cancelled`→`cancelled`
- `new` → `.partial_fill`→`partially_filled`, `.fill`→`filled`, `.cancelled`→`cancelled`, `.replaced`→`replaced`, `.pending_cancel`→`pending_cancel`, `.pending_replace`→`pending_replace`, `.expired`→`expired`, `.suspended`→`suspended`, `.restated`→`new`
- `partially_filled` → `.partial_fill`→`partially_filled`, `.fill`→`filled`, `.cancelled`→`cancelled`, `.replaced`→`replaced`, `.pending_cancel`→`pending_cancel`, `.pending_replace`→`pending_replace`, `.expired`→`expired`, `.suspended`→`suspended`, `.restated`→`partially_filled`
- `pending_cancel` → `.cancelled`→`cancelled`, `.partial_fill`→`partially_filled`, `.fill`→`filled`, `.rejected`→`new`, `.restated`→`pending_cancel`
- `pending_replace` → `.replaced`→`replaced`, `.partial_fill`→`partially_filled`, `.fill`→`filled`, `.rejected`→`new`, `.restated`→`pending_replace`
- `suspended` → `.new`→`new`, `.cancelled`→`cancelled`, `.restated`→`suspended`

### Order struct (`sdk/domain/oms.zig:56-68`)

Fields: `id: OrderId`, `instrument: []const u8`, `side: Side`, `order_type: OrderType` (market, limit, stop, stop_limit, trailing_stop), `quantity: i64`, `price: ?i64`, `tif: TimeInForce` (day, gtc, ioc, fok, gtd), `status: OrdStatus`, `created_at: u128`, `parent_id: ?OrderId`, `filled_qty: i64`

### FillInfo struct (`sdk/domain/oms.zig:50-53`)

Fields: `fill_qty: i64`, `fill_price: i64`

### OrderManager (`sdk/domain/oms.zig:171-292`)

- `submitOrder()` (lines 204-223): calls `risk_validate_fn` → assigns ID → sets `pending_new` → calls `store_append_fn` → inserts into orders hashmap
- `onExecution()` (lines 270-282): validates transition via state machine → updates status → increments `filled_qty` if fill provided → appends event to store
- `cancelOrder()` (lines 226-229): transitions via state machine

### Exchange executors — mock response injection

- **Spot** (`exchanges/kraken/spot/executor.zig:55-62`): `MockExchangeResponse` with `accepted: bool`, `txid`, `exec_type`, `fill_qty`, `fill_price`; `injectResponse()` at lines 99-102; `placeOrder()` mock path at lines 152-162
- **Futures** (`exchanges/kraken/futures/executor.zig:60-66`): identical pattern with `order_id` instead of `txid`; includes Dead Man's Switch at lines 37-57, 163-182

### Test coverage

- OMS state machine: `sdk/domain/tests/oms_test.zig` — valid transitions, terminal enforcement, race conditions (fill during cancel/replace)
- Executor mocks: `exchanges/kraken/spot/tests/executor_test.zig` — acceptance, rejection, cancel, amend paths via injected MockExchangeResponse

## How does the position tracking system compute position state from fills?

### Position struct (`sdk/domain/positions.zig:31-41`)

Fields: `key: PositionKey` (account, instrument, settlement_date, currency), `quantity: i64` (positive=long, negative=short), `avg_cost: i64`, `realized_pnl: i64`, `lots: std.ArrayList(Lot)`

### Lot struct (`sdk/domain/positions.zig:24-28`)

Fields: `quantity: i64`, `price: i64`, `timestamp: u128`

### Fill struct (`sdk/domain/positions.zig:44-53`)

Fields: `instrument`, `side: Side`, `quantity: i64`, `price: i64`, `timestamp: u128`, `account`, `currency`, `settlement_date: u32`

### CostBasisMethod (`sdk/domain/positions.zig:5-9`)

Three methods: `fifo`, `lifo`, `average_cost`

### onFill logic (`sdk/domain/positions.zig:86-226`)

- **Opening detection** (lines 107-116): opening if position is flat, or adding in same direction
- **Opening path** (lines 117-129): appends new Lot, updates quantity, recomputes avg_cost
- **Closing — average_cost** (lines 132-178): P&L = `(fill_price - avg) * close_qty` for long close (vice versa for short); reduces lots proportionally; handles position reversal if overshoot
- **Closing — FIFO/LIFO** (lines 179-224): FIFO closes index 0 (oldest), LIFO closes index len-1 (newest); P&L per lot = `(fill_price - lot.price) * close_qty`; handles reversal if remaining qty after closing all lots
- **computeAvgCost** (lines 269-291): `sum(lot.price * lot.quantity) / sum(lot.quantity)`
- **unrealizedPnl** (lines 243-254): long = `(mark - avg_cost) * qty`, short = `(avg_cost - mark) * |qty|`

### Test coverage (`sdk/domain/tests/positions_test.zig`)

- FIFO (lines 32-61): Buy 100@10, 100@12, sell 150@15 → pnl 650, remaining 50 @ avg 12
- LIFO (lines 63-84): same fills → pnl 550, remaining 50 @ avg 10
- Average cost (lines 86-107): same fills → pnl 600, remaining 50 @ avg 11
- Position reversal (lines 207-230): Buy 100, sell 150 → closes 100, opens 50 short

## What data do the execution algorithms require and produce?

### Summary table

| Algorithm | File | Input | Trigger | Output | Tests? |
|-----------|------|-------|---------|--------|--------|
| TWAP | `sdk/domain/algos/twap.zig` | TwapParams (total_qty, start/end time, num_slices, jitter_pct) | Time-based: `nextSlice(now)` | Market ChildOrder with scheduled qty | Yes (`algos/tests/twap_test.zig`) |
| VWAP | `sdk/domain/algos/vwap.zig` | VwapParams (total_qty, max_participation) + volume_profile | Market volume: `onMarketData(volume, now)` | Market ChildOrder, catch-up qty | Yes (`algos/tests/vwap_test.zig`) |
| Iceberg | `sdk/domain/algos/iceberg.zig` | IcebergParams (total_qty, display_qty, price, variance_pct) | Fill event: `onFill(fill)` or `currentSlice()` | Limit ChildOrder at fixed price | Yes (`algos/tests/iceberg_test.zig`) |
| POV | `sdk/domain/algos/pov.zig` | PovParams (total_qty, target_pct, max_pct) | Market volume: `onMarketData(volume, now)` | Market ChildOrder, target_pct of vol | Yes (`algos/tests/pov_test.zig`) |
| Impl. Shortfall | `sdk/domain/algos/implementation_shortfall.zig` | IsParams (total_qty, base_urgency, urgency_per_bps) + mid_price, spread, volatility | Market data: `onMarketData(mid, spread, vol, now)` | Market ChildOrder, urgency-based qty | **No** |
| Sniper | `sdk/domain/algos/sniper.zig` | SniperParams (total_qty, max_price, min_size_threshold) + L2BookView | Book update: `onBookUpdate(book)` | Market ChildOrder when sufficient liquidity | **No** |

### Common output: ChildOrder struct

All algorithms produce `ChildOrder` with: instrument, side, quantity, order_type (market or limit), price (optional)

### Common input: Fill event

All algorithms accept `onFill(fill: Fill)` to update `filled_qty` state; `isComplete()` checks if target qty reached

### Notable: Implementation Shortfall and Sniper have NO test harnesses

## How do pre-trade risk checks validate orders?

### RiskConfig (`sdk/domain/risk/pre_trade.zig:21-28`)

Fields: `max_order_size: i64`, `max_notional: i64`, `max_position: i64`, `max_order_rate: u32`, `price_band_pct: f64`, `dedup_window_ms: u64`

### Six check types in validation pipeline (lines 89-167)

1. **Basic validation** (lines 90-96): quantity > 0, price present and positive for non-market/trailing-stop orders, instrument not empty → `invalid_order`
2. **Size check** (lines 98-101): quantity ≤ max_order_size AND notional (qty×price) ≤ max_notional → `size_exceeded`
3. **Price band** (lines 103-112): for limit/stop/stop_limit orders, `|price - ref_price| ≤ ref_price * price_band_pct` → `price_unreasonable`
4. **Position limit** (lines 114-118): `|current_pos + delta| ≤ max_position` → `position_limit`
5. **Rate throttle** (lines 120-133): sliding 1-second window, count < max_order_rate → `rate_exceeded`
6. **Duplicate detection** (lines 135-164): DedupKey = hash(instrument) + side + qty + price; within dedup_window_ms → `duplicate_detected`

### PreTradeRisk state (`sdk/domain/risk/pre_trade.zig:38-57`)

- `positions: std.StringHashMap(i64)` — per-instrument position deltas
- `rate_window: std.ArrayList(u64)` — sliding window timestamps
- `dedup_entries: std.ArrayList(DedupEntry)` — duplicate detection history (DedupKey = instrument_hash + side + qty + price)
- `ref_prices: std.StringHashMap(i64)` — reference prices per instrument

### Function-pointer integration with OrderManager (`sdk/domain/oms.zig:171-199`)

- `risk_validate_fn: *const fn(risk: *anyopaque, order: *const Order) bool` injected at init
- Called at `sdk/domain/oms.zig:206` during `submitOrder()`; returns `error.RiskRejected` on failure
- PreTradeRisk.validate() returns `ValidationResult.passed` or `.rejected` — wrapper needed to convert to bool for OMS interface

### Test coverage (`sdk/domain/risk/tests/risk_test.zig`)

All six check types tested: invalid_order (lines 80-102), size_exceeded (lines 49-78), price_unreasonable (lines 104-127), position_limit (lines 217-238), rate_exceeded (lines 142-171), duplicate_detected (lines 173-195)

## How does the tick store persist and query tick data, and how does the bar aggregator produce OHLCV candles?

### Tick struct (`sdk/domain/tick_store.zig:5-10`)

Fields: `timestamp: u128` (nanoseconds), `price: i64`, `quantity: i64`, `side: Side` (enum(u8): buy=0, sell=1)

### TickStore persistence (`sdk/domain/tick_store.zig:132-333`)

- `open_partitions: std.StringHashMap(Partition)` — one partition per (instrument, date) pair at line 136
- **File path format**: `{base_path}/{instrument}/{YYYYMMDD}.ticks` at line 181
- **Date tag computation** (`dateTagFromNs()`, lines 161-178): nanoseconds → Gregorian → `year * 10000 + month * 100 + day`

### Delta encoding (`sdk/domain/tick_store.zig:240-248`)

Each tick written as: delta_timestamp (LEB128 varint) + delta_price (zigzag varint) + quantity (zigzag varint) + side (1 byte)

- `writeVarint()` at lines 14-28: LEB128 variable-length encoding
- `zigzagEncode(i64)` at lines 47-50: maps negative integers to positive space
- Partition tracks `last_timestamp` and `last_price` for delta state

### Query and TickIterator (`sdk/domain/tick_store.zig:70-130, 266-312`)

- `query(instrument, from_ns, to_ns)` returns `TickIterator` spanning date range
- Iterates date partitions via `nextDate()` at line 284, loads file contents into memory
- `TickIterator.next()` (lines 83-129): decodes delta fields, reconstructs absolute values, applies time-range filter

### Bar aggregator (`sdk/domain/bar_aggregator.zig`)

**Bar struct** (lines 6-13): `open: i64`, `high: i64`, `low: i64`, `close: i64`, `volume: i64`, `timestamp: u128`

**Three aggregator types:**
- **BarAggregator** (time-based, lines 17-102): `onTrade(price, qty, timestamp)` → emits Bar when `effective_ts >= bar_start + interval_ns`; handles out-of-order ticks via `max(timestamp, bar_start)` at line 57
- **VolumeBarAggregator** (lines 104-160): emits when `volume >= threshold`
- **TickBarAggregator** (lines 162-222): emits every N trades

### Engine integration

- Two BarAggregator instances (one per instrument) at `trading/desk/engine.zig:61-62`
- 1-minute intervals at line 98; fed BBO midpoint at line 163; completed bars → `CandleUpdate` event

### Test coverage

- `sdk/domain/tests/tick_store_test.zig`: round-trip write/read, time-range queries, delta encoding precision, multi-tick partitions
- `sdk/domain/tests/bar_aggregator_test.zig`: OHLCV correctness, bar boundary rollover, out-of-order timestamps, multiple boundaries

## What do the post-trade modules expect as inputs?

### Reconciliation (`sdk/domain/post_trade/reconciliation.zig`)

**Inputs:**
- `Trade` (lines 6-13): id, instrument, side, quantity, price, timestamp_ms
- `Position` (lines 16-20): instrument, quantity, value
- `CashBalance` (lines 23-26): currency, amount
- `ReconTolerance` (lines 28-32): price_tolerance (f64), qty_tolerance (i64), time_window_ms (u64)

**Outputs:**
- `ReconResult` (lines 49-54): matched (u32), breaks ([]Break), unmatched_internal (u32), unmatched_external (u32)
- `Break` (lines 42-47): break_type (quantity_mismatch, price_mismatch, missing_internal, missing_external, timing_mismatch), internal (?Trade), external (?Trade), description

**Methods:**
- `reconcileTrades(internal, external)` (lines 71-184): two-pass matching (exact ID then fuzzy by instrument/side/qty/time)
- `reconcilePositions(internal, external)` (lines 187-284): matches by instrument name
- `reconcileCash(internal, external)` (lines 287-385): matches by currency

### Allocation (`sdk/domain/post_trade/allocation.zig`)

**Inputs:**
- `AllocationEntry` (lines 12-15): account ([]const u8), ratio (f64)
- `Fill` (lines 7-10): quantity (i64), price (i64)

**Outputs:**
- `AllocatedTrade` (lines 18-26): id, instrument, side, quantity, price, timestamp_ms, account

**Methods:**
- `allocateTrade(trade, accounts)` (lines 30-72): pro-rata split, remainder to last account
- `averagePrice(fills)` (lines 76-89): quantity-weighted average

### EOD (`sdk/domain/post_trade/eod.zig`)

**Inputs:**
- `Mark` (lines 5-8): instrument, price
- `EodPositionView` (lines 36-41): instrument, quantity, avg_cost, realized_pnl

**Outputs:**
- `DailyPnlReport` (lines 20-25): realized_pnl, unrealized_pnl, total_pnl, snapshots
- `EodReport` (lines 28-33): date_ms, pnl (DailyPnlReport), recon_result (ReconResult), snapshots
- `PositionSnapshot` (lines 11-17): instrument, quantity, avg_cost, realized_pnl, timestamp_ms

**Methods:**
- `snapshotPositions(positions)` (lines 59-75): captures current state with timestamp
- `computeDailyPnl(positions, marks)` (lines 78-108): realized + unrealized P&L; long unrealized = `(mark - avg_cost) * qty`
- `runEndOfDay(positions, recon_engine, marks, internal_trades, external_trades)` (lines 111-129): computes P&L + reconciliation → EodReport

### Test coverage

- `reconciliation_test.zig`: perfect match, quantity mismatch, missing trades, price tolerance, fuzzy matching
- `allocation_test.zig`: pro-rata splits, equal splits, weighted avg price, rounding
- `eod_test.zig`: position snapshot, daily P&L, full EOD workflow

## How do the trading strategies consume market data and emit order signals?

### Existing strategies: only 2 of 4 referenced strategies exist

- `trading/strategies/basis.zig` — Basis trading (spot vs. futures)
- `trading/strategies/funding_arb.zig` — Funding rate arbitrage
- **Market making** — does NOT exist in codebase
- **Pairs trade** — does NOT exist in codebase

### Basis strategy (`trading/strategies/basis.zig`)

**Interface:** `onMarketData(spot: *const L2Book, futures: *const L2Book) ?Signal` at line 71

**Config** (BasisConfig, lines 21-28): `entry_threshold_bps`, `exit_threshold_bps`, `max_position`, `instrument_spot`, `instrument_futures`, `days_to_expiry`

**Market conditions needed:**
- Two L2Book orderbooks (spot + futures) with valid midPrice()
- Computes annualized basis: `(futures_mid - spot_mid) / spot_mid * (365 / days_to_expiry) * 10000` bps (lines 54-69)
- Entry when basis exceeds ±entry_threshold_bps; exit when basis narrows below ±exit_threshold_bps

**Signal output** (lines 14-19): `direction` (enter_long_basis, enter_short_basis, exit), `spot_qty`, `futures_qty`, `expected_basis_bps`

**State machine** (lines 75-124): flat → long_basis (when basis > threshold) or short_basis (when basis < -threshold); exit on convergence

### Funding arb strategy (`trading/strategies/funding_arb.zig`)

**Dual interfaces:**
1. `onFundingRate(rate: f64, next_funding_time: u128) ?Signal` at line 45 — entry/exit on funding rate sign
2. `onMarketData(spot: *const L2Book, perp: *const L2Book) ?Signal` at line 106 — convergence monitoring

**Config** (FundingArbConfig, lines 17-22): `min_rate_bps`, `max_position`, `instrument_spot`, `instrument_perp`

**Market conditions needed:**
- Funding rate (percentage as decimal), converted to bps internally (line 48)
- Two L2Book orderbooks (spot + perpetual) for convergence monitoring
- Entry when `|rate_bps| > min_rate_bps`; exit on rate sign flip or basis convergence below `min_rate_bps * 0.5`

**Signal output** (lines 10-15): `direction` (long_spot_short_perp, short_spot_long_perp, flat), `spot_qty`, `perp_qty`, `funding_rate`

### L2Book interface consumed by both strategies (`sdk/domain/orderbook.zig`)

- `midPrice()` → `?i64` at line 143 (O(1))
- `spread()` → `?i64` at line 136 (O(1))
- `bestBid()` → `?Level` at line 124
- `bestAsk()` → `?Level` at line 130
- `bids()` / `asks()` → `[]const Level` at lines 150, 155

## What do the analytics modules require as historical input data?

### TCA — Transaction Cost Analysis (`trading/analytics/tca.zig`)

**Inputs:**
- `Execution` (lines 8-14): price, quantity, timestamp (u128), side, venue
- `Benchmark` (lines 16-21): arrival_price, market_vwap, close_price, attempted_qty

**Historical depth:** Minimum 1 execution; typical is multiple fills across execution window. No minimum time depth — operates on a single execution session.

**Output:** `TcaReport` (lines 23-31): `is_cost_bps` (total implementation shortfall), `timing_cost_bps`, `market_impact_bps`, `opportunity_cost_bps`, `vwap_slippage_bps`, `spread_capture` (0.0–1.0), `fill_rate` (0.0–1.0)

**IS decomposition** (lines 47-137): timing_cost = decision-to-first-fill, market_impact = first-fill-to-avg, opportunity_cost = unfilled fraction × price movement

### VPIN — Volume-Synchronized Probability of Informed Trading (`trading/analytics/vpin.zig`)

**Input:** Individual trades via `onTrade(price: i64, volume: i64, side: Side) ?f64` at line 52

**Historical depth:**
- Minimum: one complete volume bucket (bucket_size configurable at line 9)
- Ring buffer of `num_buckets` (u32) completed buckets at lines 13-15
- No output until first bucket completes (returns null)
- Typical: 2–50 buckets

**Trade classification:** tick rule (price > last = buy, price < last = sell, same = use provided side) at lines 52-63

**Bucketing** (lines 66-102): accumulates buy/sell volume until `current_vol >= bucket_size`; imbalance = `|V_buy - V_sell| / (V_buy + V_sell)` at lines 83-87

**Output:** `?f64` — VPIN = average of bucket imbalances (0.0 = balanced, 1.0 = all one-sided)

### Attribution — Brinson-Fachler Performance Attribution (`trading/analytics/attribution.zig`)

**Input:**
- Two arrays of `Holding` (lines 6-10): `sector`, `weight` (f64, 0.0–1.0), `return_pct` (f64, decimal)
- No timestamp requirements — static end-of-period snapshot

**Historical depth:** None — operates on a single-period portfolio and benchmark snapshot

**Output:** `AttributionResult` (lines 12-17): `allocation` (over/underweight effect), `selection` (security picking effect), `interaction` (combined effect), `total` (sum of above). Invariant: total = allocation + selection + interaction.

**Decomposition** (lines 28-91): allocation = `Σ(w_p - w_b)(r_b - r_b_total)`, selection = `Σ w_b(r_p - r_b)`, interaction = `Σ(w_p - w_b)(r_p - r_b)`

## Cross-cutting observations

- **Fixed-point price convention**: all prices are `i64` representing 8 decimal places (satoshi-level precision) throughout SDK, exchange, and strategy modules; seen in `sdk/domain/orderbook.zig:10`, `sdk/domain/oms.zig:56`, `sdk/domain/positions.zig:31`, `sdk/domain/tick_store.zig:5`
- **Timestamp convention**: `u128` nanoseconds used consistently for internal timestamps across tick store, OMS, positions, and bar aggregator; post-trade modules use `u64` milliseconds
- **Side enum**: `Side` (buy/sell) is shared across OMS, positions, tick store, strategies, algos, and analytics — defined in common domain types
- **L2Book as universal market data interface**: consumed by synthetic feed, engine, strategies, and sniper algo; provides O(1) BBO, midPrice, spread accessors at `sdk/domain/orderbook.zig:124-155`
- **Function-pointer dependency injection**: OMS uses `*const fn(*anyopaque, ...)` pattern for risk and event store at `sdk/domain/oms.zig:180-181`; executors use `MockExchangeResponse` injection for testing; engine uses stubs for demo mode
- **No integration between strategies/analytics and the engine**: strategies and analytics are standalone modules with their own test suites; the engine only uses SyntheticFeed + BarAggregator + OMS; strategies and analytics are not wired into the demo loop
- **Symbol table divergence**: `sdk/domain/market_data.zig` and `exchanges/kraken/common/symbol_translator.zig` have overlapping but non-identical symbol sets with 6+ mismatches in each direction

## Coverage gaps

- **Market making strategy**: referenced in questions but does NOT exist in codebase (`trading/strategies/` contains only `basis.zig` and `funding_arb.zig`)
- **Pairs trade strategy**: referenced in questions but does NOT exist in codebase
- **Implementation Shortfall and Sniper algorithms**: exist but have no test harnesses (unlike TWAP, VWAP, Iceberg, POV which all have tests in `sdk/domain/algos/tests/`)
