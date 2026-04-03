---
phase: 2
iteration: 01
generated: 2026-04-03
---

# Research: Trading Desk TUI Application

Questions source: .claude/specs/trading-desk-tui/01-questions-01.md

## 1. Public APIs of domain modules (orderbook, OMS, positions, market_data, risk/pre_trade)

### sdk/domain/orderbook.zig
- `Side` enum: `bid`, `ask` (`orderbook.zig:8`)
- `Level` struct: `price: i64, quantity: i64` (`orderbook.zig:10-13`)
- `L2Book` struct with fields: `allocator`, `bids_buf`, `asks_buf`, `bids_len`, `asks_len`, `depth` (`orderbook.zig:15-21`)
- `L2Book.init(allocator: std.mem.Allocator, depth: usize) !L2Book` — pre-allocates sorted arrays (`orderbook.zig:24`)
- `L2Book.applySnapshot(self, bid_levels, ask_levels) void` — replaces entire book (`orderbook.zig:39`)
- `L2Book.applyUpdate(self, side: Side, price: i64, qty: i64) void` — incremental update, qty=0 removes (`orderbook.zig:65`)
- `L2Book.bestBid(self) ?Level`, `L2Book.bestAsk(self) ?Level` — O(1) BBO access (`orderbook.zig:124,130`)
- `L2Book.spread(self) ?i64`, `L2Book.midPrice(self) ?i64` — derived metrics (`orderbook.zig:136,143`)
- `L2Book.bids(self) []const Level`, `L2Book.asks(self) []const Level` — full depth slices (`orderbook.zig:150,155`)
- `L2Book.deinit(self) void` (`orderbook.zig:159`)
- All prices use fixed-point i64 (satoshis/cents) (`orderbook.zig:4`)

### sdk/domain/orderbook_l3.zig
- `L3Book` struct with `allocator` and `orders: std.AutoHashMap(u64, OrderInfo)` (`orderbook_l3.zig:21-23`)
- `OrderInfo` struct: `order_id: u64, side: Side, price: i64, quantity: i64` (`orderbook_l3.zig:14-19`)
- `L3Book.init(allocator) !L3Book` (`orderbook_l3.zig:25`)
- `L3Book.addOrder(self, order_id, side, price, qty) !void` (`orderbook_l3.zig:33`)
- `L3Book.modifyOrder(self, order_id, new_qty) !void` (`orderbook_l3.zig:44`)
- `L3Book.deleteOrder(self, order_id) !void` (`orderbook_l3.zig:50`)
- `L3Book.getOrder(self, order_id) ?OrderInfo` — O(1) hash map lookup (`orderbook_l3.zig:55`)
- `L3Book.bestBid(self) ?Level`, `L3Book.bestAsk(self) ?Level` — O(n) scans all orders (`orderbook_l3.zig:60,81`)
- `L3Book.deinit(self) void` (`orderbook_l3.zig:101`)

### sdk/domain/oms.zig
- Re-exports from `order_types.zig`: `OrderId` (u64), `OrderType`, `TimeInForce`, `Side` (`oms.zig:4-7`)
- `OrdStatus` enum: 14 states including `pending_new`, `new`, `partially_filled`, `filled`, `cancelled`, `rejected`, etc. (`oms.zig:10-25`)
- `ExecType` enum: 11 execution event types (`oms.zig:28-40`)
- `Order` struct: `id`, `instrument`, `side`, `order_type`, `quantity`, `price`, `tif`, `status`, `created_at: u128`, `parent_id`, `filled_qty` (`oms.zig:56-68`)
- `OrderStateMachine` with `transition(current, event) !OrdStatus` and `isTerminal(status) bool` (`oms.zig:71-164`)
- `OrderManager` struct: `allocator`, `risk: *anyopaque`, `store: *anyopaque`, `orders: std.AutoHashMap(OrderId, Order)`, `next_id`, `sm` (`oms.zig:171-177`)
- `OrderManager.init(allocator, risk, store, risk_validate_fn, store_append_fn) !OrderManager` — uses function pointer injection for risk and event store (`oms.zig:183-200`)
- `OrderManager.submitOrder(self, order) !OrderId` — validates via risk, assigns ID, emits event (`oms.zig:204`)
- `OrderManager.cancelOrder(self, id) !void` — transitions to pending_cancel (`oms.zig:226`)
- `OrderManager.replaceOrder(self, id, new_params) !OrderId` — creates replacement order (`oms.zig:238`)
- `OrderManager.onExecution(self, id, exec, fill) !void` — processes execution reports from exchange (`oms.zig:270`)
- `OrderManager.getOrder(self, id) ?*const Order` (`oms.zig:285`)
- `OrderManager.deinit(self) void` (`oms.zig:289`)

### sdk/domain/positions.zig
- `PositionKey` struct: `account`, `instrument`, `settlement_date: u32`, `currency` (all []const u8 except date) (`positions.zig:11-16`)
- `Position` struct: `key`, `quantity: i64` (net), `avg_cost: i64`, `realized_pnl: i64`, `lots: std.ArrayList(Lot)` (`positions.zig:31-41`)
- `Lot` struct: `quantity: i64`, `price: i64`, `timestamp: u128` (`positions.zig:24-28`)
- `Fill` struct: `instrument`, `side`, `quantity`, `price`, `timestamp`, `account`, `currency`, `settlement_date` (`positions.zig:44-53`)
- `PositionManager.init(allocator, config: PositionConfig) !PositionManager` (`positions.zig:64`)
- `PositionManager.onFill(self, fill: Fill) !void` — updates position with FIFO/LIFO/avg cost basis (`positions.zig:86`)
- `PositionManager.getPosition(self, key) ?*const Position` (`positions.zig:229`)
- `PositionManager.realizedPnl(self, key) ?i64` (`positions.zig:235`)
- `PositionManager.unrealizedPnl(self, key, mark_price) ?i64` (`positions.zig:243`)
- `PositionManager.allPositions(self) []const Position` — returns all positions as a slice (`positions.zig:257`)
- `PositionManager.deinit(self) void` (`positions.zig:73`)
- `PositionConfig`: `cost_basis_method: CostBasisMethod`, `base_currency: []const u8` (`positions.zig:18-21`)

### sdk/domain/market_data.zig
- This file is actually the **symbol mapper** (Kraken symbol normalization), not a general market data bus (`market_data.zig:1-3`)
- `SymbolMapper` struct with `init(allocator) !SymbolMapper` (`market_data.zig:59-64`)
- `spotToInternal(kraken_pair) ?[]const u8`, `futurestoInternal(kraken_symbol) ?[]const u8` (`market_data.zig:68,79`)
- `internalToSpot(internal) ?[]const u8`, `internalToFutures(internal) ?[]const u8` (`market_data.zig:90,101`)
- Uses compile-time static tables `SPOT_MAP` (20 entries) and `FUTURES_MAP` (12 entries) — no heap allocation (`market_data.zig:18-55`)
- There is no general-purpose market data feed/bus/dispatcher module in the codebase

### sdk/domain/risk/pre_trade.zig
- `RiskConfig`: `max_order_size`, `max_notional`, `max_position`, `max_order_rate`, `price_band_pct`, `dedup_window_ms` (`pre_trade.zig:22-28`)
- `PreTradeRisk.init(allocator, config: RiskConfig) !PreTradeRisk` (`pre_trade.zig:59`)
- `PreTradeRisk.validate(self, order: *const Order) ValidationResult` — returns `.passed` or `.rejected: RejectReason` (`pre_trade.zig:89`)
- `PreTradeRisk.setReferencePrice(self, instrument, price) !void` (`pre_trade.zig:78`)
- `PreTradeRisk.updatePosition(self, instrument, delta) !void` (`pre_trade.zig:83`)
- `ValidationResult` is a tagged union: `passed` or `rejected: RejectReason` (`pre_trade.zig:17-19`)
- `RejectReason` enum: `invalid_order`, `size_exceeded`, `price_unreasonable`, `position_limit`, `rate_exceeded`, `duplicate_detected` (`pre_trade.zig:7-14`)
- `PreTradeRisk.deinit(self) void` (`pre_trade.zig:70`)

## 2. Event loop (sdk/core/io/event_loop.zig) — API and design constraints

- `EventLoop` struct: `allocator`, `ring: std.os.linux.IoUring`, `sockets: std.ArrayList(SocketEntry)`, `timers: std.ArrayList(TimerEntry)`, `running: bool`, `read_buf: [65536]u8` (`event_loop.zig:21-27`)
- `EventLoop.init(allocator) !EventLoop` — creates io_uring with 256 SQ entries (`event_loop.zig:29-30`)
- `Handler` struct: function pointers `onRead(*const fn(fd, data) void)` and `onError(*const fn(fd, err) void)` (`event_loop.zig:6-9`)
- `EventLoop.addSocket(self, fd, handler) !void` — registers a socket with a handler (`event_loop.zig:41`)
- `EventLoop.addTimer(self, timeout_ms, callback) !void` — registers a timer callback (`event_loop.zig:45`)
- `EventLoop.removeSocket(self, fd) void` (`event_loop.zig:49`)
- `EventLoop.run(self) !void` — blocking loop: submits io_uring read requests for all registered sockets, waits for CQEs (`event_loop.zig:60-96`)
- `EventLoop.stop(self) void` — sets `running = false` (`event_loop.zig:98`)
- `EventLoop.deinit(self) void` (`event_loop.zig:102`)
- **Linux-only**: depends on `std.os.linux.IoUring` (`event_loop.zig:2,23,30`)
- **Single read buffer**: shared `read_buf: [65536]u8` across all sockets — reads are serialized (`event_loop.zig:27`)
- **Blocking**: `run()` blocks the calling thread in a while loop until `stop()` is called (`event_loop.zig:60-96`)
- Uses `copy_cqe()` which waits for a single completion — one event at a time processing (`event_loop.zig:90`)

## 3. Memory allocation (sdk/core/memory.zig)

- `PoolAllocator` — fixed-slot slab allocator with 64-byte aligned slots (`memory.zig:6-90`)
  - `init(backing: std.mem.Allocator, slot_size: usize, slot_count: usize) !PoolAllocator` (`memory.zig:18`)
  - `allocator(self) std.mem.Allocator` — returns `std.mem.Allocator` interface via vtable (`memory.zig:49-53`)
  - Uses free-list for O(1) alloc/free (`memory.zig:14-16,56-64,75-83`)
  - `deinit(self) void` — frees backing slab (`memory.zig:45`)
- `ArenaAllocator` — bump allocator wrapping `std.heap.ArenaAllocator` (`memory.zig:93-111`)
  - `init(backing: std.mem.Allocator) ArenaAllocator` (`memory.zig:96`)
  - `allocator(self) std.mem.Allocator` (`memory.zig:104`)
  - `reset(self) void` — resets with `.retain_capacity` (`memory.zig:108`)
  - `deinit(self) void` (`memory.zig:100`)
- `cache_line_size: usize = 64` — public constant (`memory.zig:3`)
- **Pattern in existing modules**: All domain modules (OMS, orderbook, positions, PreTradeRisk) accept `std.mem.Allocator` as first parameter to `init()`. No module creates its own allocator — they receive one from the caller.
  - `L2Book.init(allocator, depth)` (`orderbook.zig:24`)
  - `L3Book.init(allocator)` (`orderbook_l3.zig:25`)
  - `OrderManager.init(allocator, ...)` (`oms.zig:183`)
  - `PositionManager.init(allocator, config)` (`positions.zig:64`)
  - `PreTradeRisk.init(allocator, config)` (`pre_trade.zig:59`)

## 4. Kraken exchange executors and OMS integration

### exchanges/kraken/spot/executor.zig
- `SpotExecutor` struct: `allocator`, `rest: ?*SpotRestClient`, `ws: ?*SpotWsClient`, `fix: ?*FixSession`, `oms: *OrderManager`, `preferred_channel: RouteChannel`, `mock_response`, `next_txid_counter` (`executor.zig:67-77`)
- `SpotExecutor.init(allocator, rest, ws, fix, oms) !SpotExecutor` — determines preferred channel as FIX > WS > REST based on which are non-null (`executor.zig:78-97`)
- `SpotExecutor.placeOrder(self, order: *const Order) !ExchangeOrderId` — translates to Kraken format, routes via preferred channel, calls `oms.onExecution(id, .new, null)` on success or `oms.onExecution(id, .rejected, null)` on failure (`executor.zig:115-169`)
- `SpotExecutor.cancelOrder(self, oms_id, exchange_id) !void` — calls `oms.onExecution(oms_id, .cancelled, null)` (`executor.zig:172-187`)
- `SpotExecutor.amendOrder(self, oms_id, exchange_id, params) !ExchangeOrderId` — calls `oms.onExecution(oms_id, .replaced, null)` (`executor.zig:191-214`)
- `SpotExecutor.processExecutionReport(self, oms_id, exec, fill) !void` — thin wrapper around `oms.onExecution()` (`executor.zig:218-225`)
- `SpotExecutor.injectResponse(self, resp) void` — test mock injection (`executor.zig:100`)
- `ExchangeOrderId` struct: fixed `[32]u8` array with `len: u8`, methods `fromSlice()` and `asSlice()` (`executor.zig:25-40`)
- `RouteChannel` enum: `fix`, `ws`, `rest` (`executor.zig:49-53`)
- Opaque client types: `SpotRestClient`, `SpotWsClient`, `FixSession` — all are `opaque {}` (`executor.zig:18-22`)
- When all clients are null, executor still works — generates synthetic txids (`executor.zig:166-168`)

### exchanges/kraken/futures/executor.zig
- `FuturesExecutor` struct: `allocator`, `rest: ?*FuturesRestClient`, `ws: ?*FuturesWsClient`, `oms: *OrderManager`, `dms: DeadManSwitch`, `mock_response` (`futures/executor.zig:69-78`)
- `FuturesExecutor.init(allocator, rest, ws, oms) !FuturesExecutor` — no FIX channel for futures (`futures/executor.zig:80-96`)
- `FuturesExecutor.placeOrder(self, order) !ExchangeOrderId` — same OMS integration pattern as spot (`futures/executor.zig:112-142`)
- `FuturesExecutor.cancelOrder(self, oms_id, exchange_id) !void` (`futures/executor.zig:145-158`)
- `FuturesExecutor.processExecutionReport(self, oms_id, exec, fill) !void` (`futures/executor.zig:185-192`)
- `DeadManSwitch` struct: `enabled`, `timeout_s`, `last_refresh_ns` with `needsRefresh(now_ns) bool` (`futures/executor.zig:37-57`)
- `FuturesExecutor.setDeadManSwitch(self, timeout_s) !void` (`futures/executor.zig:163`)
- `FuturesExecutor.refreshDeadManSwitch(self) !void` (`futures/executor.zig:175`)
- ExchangeOrderId uses `[48]u8` (larger than spot's `[32]u8`) (`futures/executor.zig:19-34`)
- Both executors can operate with null client references (mock/demo mode) and generate synthetic IDs

## 5. Build system structure (build.zig)

- File is 972 lines (`build.zig:1-972`)
- Uses `b.standardTargetOptions(.{})` and `b.standardOptimizeOption(.{})` at the top (`build.zig:4-5`)
- **No executable targets** — only test steps and modules exist
- **Named build steps**:
  - `test` — "Run all tests" (`build.zig:8`)
  - `test-core` — "Run sdk/core tests" (`build.zig:9`)
  - `test-protocol` — "Run sdk/protocol tests" (`build.zig:401`)
  - `test-ws` — "Run WebSocket tests" (`build.zig:609`)
  - `test-kraken` — "Run Kraken exchange tests" (`build.zig:610`)
- **Module creation pattern**: `b.createModule(.{ .root_source_file = b.path("path/to/file.zig") })` (`build.zig:80-100`)
- **Inter-module imports**: `module.addImport("name", other_module)` (`build.zig:108,136,141,etc.`)
- **Anonymous imports for tests**: `test_exe.root_module.addAnonymousImport("name", .{ .root_source_file = ... })` (`build.zig:46-48`)
- **Test pattern**: `b.addTest(.{...})` -> `b.addRunArtifact(test_exe)` -> `test_step.dependOn(&run.step)` (`build.zig:39-44,346-392`)
- Modules are created once and shared across multiple test targets (e.g., `oms_mod` used by both oms_test and executor_test) (`build.zig:133-136,169,922,947`)
- Some modules have duplicate definitions for different build phases (e.g., `orderbook_mod_p12` at line 740 and `orderbook_mod` at line 827)

## 6. Terminal I/O primitives available in Zig's std library

- **Note**: This question asks about Zig stdlib capabilities, not files in this repo. Findings are based on Zig 0.13 standard library knowledge.
- `std.io.getStdIn() std.fs.File` — returns the stdin file descriptor
- `std.io.getStdOut() std.fs.File` — returns the stdout file descriptor
- `std.posix.tcgetattr(fd) !std.posix.termios` — reads terminal attributes
- `std.posix.tcsetattr(fd, optional_actions, termios) !void` — sets terminal attributes (for raw mode: disable ICANON, ECHO, ISIG, etc.)
- `std.fs.File.reader()` and `std.fs.File.writer()` — buffered I/O
- `std.os.linux.IoUring` — can register stdin fd for non-blocking reads via `IORING_OP_READ`
- `std.posix.poll()` — alternative to io_uring for multiplexing stdin + other fds
- `std.Thread.spawn()` — for running TUI rendering on a separate thread
- `std.fmt.bufPrint()` — for formatting ANSI escape sequences into buffers
- The codebase already uses `std.os.linux.IoUring` in `sdk/core/io/event_loop.zig:30`
- The codebase already uses `std.posix.clock_gettime` for time in `sdk/core/time.zig:9`
- The codebase already uses `std.Thread` via `sdk/core/io/thread.zig:37` (`spawnPinned`)
- No existing terminal/TUI code exists in the codebase

## 7. Trading strategies: orderbook and market data consumption

### trading/strategies/basis.zig
- Imports `orderbook` module and uses `L2Book` type (`basis.zig:5-6`)
- `BasisStrategy.init(allocator, config: BasisConfig) !BasisStrategy` (`basis.zig:40`)
- `BasisStrategy.onMarketData(self, spot: *const L2Book, futures: *const L2Book) ?Signal` — primary entry point (`basis.zig:71`)
- Reads `L2Book.midPrice()` from both spot and futures books to compute annualized basis (`basis.zig:57-58`)
- `BasisConfig` fields: `entry_threshold_bps`, `exit_threshold_bps`, `max_position`, `instrument_spot`, `instrument_futures`, `days_to_expiry` (`basis.zig:21-28`)
- `Signal` struct: `direction: Direction`, `spot_qty`, `futures_qty`, `expected_basis_bps` (`basis.zig:14-19`)
- `Direction` enum: `enter_long_basis`, `enter_short_basis`, `exit` (`basis.zig:8-12`)
- `PositionState` enum: `flat`, `long_basis`, `short_basis` — tracked internally (`basis.zig:30`)

### trading/strategies/funding_arb.zig
- Also imports `orderbook` module and uses `L2Book` (`funding_arb.zig:4-5`)
- `FundingArbStrategy.init(allocator, config: FundingArbConfig) !FundingArbStrategy` (`funding_arb.zig:30`)
- Two entry points:
  - `onFundingRate(self, rate: f64, next_funding_time: u128) ?Signal` — triggered by funding rate updates (`funding_arb.zig:45`)
  - `onMarketData(self, spot: *const L2Book, perp: *const L2Book) ?Signal` — monitors basis convergence (`funding_arb.zig:106`)
- Uses `L2Book.midPrice()` to compute perp-spot basis (`funding_arb.zig:107-108`)
- `FundingArbConfig`: `min_rate_bps`, `max_position`, `instrument_spot`, `instrument_perp` (`funding_arb.zig:17-22`)
- `FundingDirection` enum: `long_spot_short_perp`, `short_spot_long_perp`, `flat` (`funding_arb.zig:8`)
- Neither strategy directly imports or depends on exchange clients — they receive L2Book references and return Signal structs

## 8. Risk metrics modules (var, greeks, stress)

### sdk/domain/risk/var.zig
- `historicalVar(returns: []const f64, confidence: f64) !f64` — sorts return distribution, picks percentile loss (`var.zig:7-30`)
- `parametricVar(sigma, z_alpha, horizon_days, position_value) f64` — variance-covariance VaR (`var.zig:34`)
- `monteCarloVar(allocator, covariance, weights, simulations, confidence) !f64` — Cholesky-correlated normal returns (`var.zig:43-108`)
- `expectedShortfall(returns: []const f64, confidence: f64) !f64` — CVaR, average of tail losses (`var.zig:112-142`)
- All functions are free-standing (not methods on a struct) — stateless computations (`var.zig:7,34,43,112`)
- Uses `math.sortAscending`, `math.choleskyDecomposition`, `math.normalRandom` from `risk/math.zig` (`var.zig:2`)

### sdk/domain/risk/greeks.zig
- `BlackScholes` struct (namespace, no instance state) with static methods (`greeks.zig:30`)
- `BlackScholes.price(spot, strike, r, sigma, t, is_call) f64` — option price (`greeks.zig:43`)
- `BlackScholes.delta(spot, strike, r, sigma, t, is_call) f64` (`greeks.zig:77`)
- `BlackScholes.gamma(spot, strike, r, sigma, t) f64` (`greeks.zig:103`)
- `BlackScholes.vega(spot, strike, r, sigma, t) f64` (`greeks.zig:111`)
- `BlackScholes.theta(spot, strike, r, sigma, t, is_call) f64` (`greeks.zig:119`)
- `BlackScholes.rho(spot, strike, r, sigma, t, is_call) f64` (`greeks.zig:133`)
- `BlackScholes.impliedVolatility(market_price, spot, strike, r, t, is_call) !f64` — Newton-Raphson (`greeks.zig:147`)
- Helper functions: `normalPdf(x) f64`, `normalCdf(x) f64` — standard normal distribution (`greeks.zig:4,10`)

### sdk/domain/risk/stress.zig
- `Position` struct: `instrument: []const u8`, `quantity: i64` (`stress.zig:3-6`)
- `Shock` struct: `instrument: []const u8`, `price_change_pct: f64` (`stress.zig:8-11`)
- `StressResult` struct: `scenario: []const u8`, `pnl_impact: f64` (`stress.zig:13-16`)
- `StressTest.init(allocator) !StressTest` (`stress.zig:27`)
- `StressTest.addScenario(self, name, shocks: []const Shock) !void` — adds named scenario (`stress.zig:42`)
- `StressTest.run(self, positions: []const Position, mark_prices: []const i64) ![]StressResult` — runs all scenarios, returns results (`stress.zig:53`)
- `StressTest.deinit(self) void` (`stress.zig:34`)

## 9. Analytics modules: computed metrics and entry points

### trading/analytics/tca.zig
- `Execution` struct: `price: i64`, `quantity: i64`, `timestamp: u128`, `side: Side`, `venue: []const u8` (`tca.zig:8-14`)
- `Benchmark` struct: `arrival_price`, `market_vwap`, `close_price`, `attempted_qty` (all i64) (`tca.zig:16-21`)
- `TcaReport` struct: `is_cost_bps`, `timing_cost_bps`, `market_impact_bps`, `opportunity_cost_bps`, `vwap_slippage_bps`, `spread_capture`, `fill_rate` (all f64) (`tca.zig:23-31`)
- `TcaEngine.init(allocator) !TcaEngine` (`tca.zig:36`)
- `TcaEngine.analyze(self, executions: []const Execution, benchmark: Benchmark) !TcaReport` — main entry point (`tca.zig:47`)

### trading/analytics/vpin.zig
- `VpinCalculator.init(allocator, bucket_size: i64, num_buckets: u32) !VpinCalculator` (`vpin.zig:27`)
- `VpinCalculator.onTrade(self, price: i64, volume: i64, side: Side) ?f64` — processes trade, returns VPIN estimate when bucket completes (`vpin.zig:52`)
- Uses tick rule for trade classification internally (`vpin.zig:55-62`)
- Maintains ring buffer of bucket imbalances (`vpin.zig:14-15`)
- `VpinCalculator.deinit(self) void` (`vpin.zig:44`)

### trading/analytics/attribution.zig
- `Holding` struct: `sector: []const u8`, `weight: f64`, `return_pct: f64` (`attribution.zig:6-10`)
- `AttributionResult` struct: `allocation: f64`, `selection: f64`, `interaction: f64`, `total: f64` (`attribution.zig:12-17`)
- `BrinsonAttribution.compute(portfolio: []const Holding, benchmark: []const Holding) AttributionResult` — static, no instance state (`attribution.zig:28`)
- Brinson-Fachler model: decomposes active return into allocation, selection, and interaction effects (`attribution.zig:25-27`)

## 10. VS Code configuration and Zig task/launch patterns

- `.vscode/trading-platform.code-workspace` contains only a folder reference pointing to `..` (the repo root) (`trading-platform.code-workspace:1-7`)
- No `tasks.json` exists in `.vscode/`
- No `launch.json` exists in `.vscode/`
- The workspace file has no tasks, settings, or launch configurations embedded
- **Zig build system context**: `build.zig` uses `b.standardTargetOptions(.{})` and `b.standardOptimizeOption(.{})` (`build.zig:4-5`), meaning executables support `-Doptimize=ReleaseFast` and `-Dtarget=...` CLI flags
- The Zig build steps are invoked via `zig build <step-name>`, e.g., `zig build test`, `zig build test-core`

## 11. Time module (sdk/core/time.zig)

- `Timestamp` struct with single field `nanos: u128` (`time.zig:3-4`)
- `Timestamp.now() Timestamp` — reads `CLOCK_MONOTONIC` (comment says MONOTONIC_RAW but code uses `CLOCK.MONOTONIC`) (`time.zig:7-11`)
- `Timestamp.wallClock() Timestamp` — reads `CLOCK_REALTIME` (`time.zig:14-18`)
- `Timestamp.fromUnixNanos(n: u128) Timestamp` — construct from raw nanos (`time.zig:26`)
- `Timestamp.toRfc3339(self, buf) []const u8` — formats as ISO 8601 with nanoseconds (`time.zig:31`)
- `Timestamp.toIso8601(self, buf) []const u8` — formats as `YYYYMMDD-HH:MM:SS.nnn` (`time.zig:42`)
- `Timestamp.toFixUtc(self, buf) []const u8` — alias for toIso8601 (`time.zig:54`)
- `Timestamp.fromRfc3339(s: []const u8) !Timestamp` — parses RFC 3339 strings (`time.zig:59`)
- Uses Howard Hinnant's civil_from_days algorithm for date decomposition (`time.zig:117-131`)
- **Usage by other modules**:
  - OMS `Order.created_at` is `u128` (raw nanoseconds, not Timestamp struct) (`oms.zig:66`)
  - Positions `Lot.timestamp` and `Fill.timestamp` are `u128` (`positions.zig:27,49`)
  - EventLoop does not reference time.zig — it uses `std.os.linux.kernel_timespec` directly (`event_loop.zig:76-79`)
  - PreTradeRisk uses `std.posix.clock_gettime(CLOCK.MONOTONIC)` directly, not time.zig (`pre_trade.zig:170-172`)
  - FuturesExecutor uses `std.time.nanoTimestamp()` directly (`futures/executor.zig:166,178`)
- Time values across the codebase are raw `u128` nanoseconds or `u64` nanoseconds — the `Timestamp` struct is not universally used

## 12. Container data structures (ring_buffer, mpsc_queue)

### sdk/core/containers/ring_buffer.zig
- `SpscRingBuffer(comptime T: type)` — generic single-producer single-consumer lock-free ring buffer (`ring_buffer.zig:4`)
- `init(allocator, capacity: usize) !Self` — rounds capacity to next power of 2 (`ring_buffer.zig:14`)
- `push(self, item: T) bool` — non-blocking, returns false if full (`ring_buffer.zig:31`)
- `pop(self) ?T` — non-blocking, returns null if empty (`ring_buffer.zig:41`)
- Uses `std.atomic.Value(usize)` for `write_idx` and `read_idx` with acquire/release ordering (`ring_buffer.zig:11-12,32-33,42-43`)
- `deinit(self) void` (`ring_buffer.zig:26`)
- Masking via `capacity - 1` for power-of-2 indexing (`ring_buffer.zig:35,46`)

### sdk/core/containers/mpsc_queue.zig
- `MpscQueue(comptime T: type)` — generic multi-producer single-consumer intrusive queue (`mpsc_queue.zig:5`)
- `Node` struct: `next: std.atomic.Value(?*Node)`, `data: T` with `init(data) Node` (`mpsc_queue.zig:9-18`)
- `initAlloc(allocator) !Self` — allocates a sentinel node (`mpsc_queue.zig:30`)
- `push(self, node: *Node) void` — lock-free via atomic swap on tail; safe for multiple producers (`mpsc_queue.zig:50-53`)
- `pop(self) ?*Node` — single-consumer, returns null if empty (`mpsc_queue.zig:58-66`)
- Uses `seq_cst` ordering for push, `acquire` for pop (`mpsc_queue.zig:51-52,60`)
- `deinit(self) void` — frees sentinel (`mpsc_queue.zig:44`)
- Intrusive design: callers must allocate `Node` instances externally
- **Thread safety profile**: SpscRingBuffer supports exactly one producer and one consumer thread; MpscQueue supports multiple producer threads and one consumer thread

## Cross-cutting observations

- **Allocator injection pattern**: Every domain module accepts `std.mem.Allocator` as first parameter to `init()`. None create allocators internally. This allows a top-level application to provide either `PoolAllocator.allocator()`, `ArenaAllocator.allocator()`, or any other `std.mem.Allocator` implementation (`memory.zig:49,104`, `orderbook.zig:24`, `oms.zig:183`, `positions.zig:64`)
- **Fixed-point pricing**: All prices and quantities are `i64` throughout the codebase — orderbook, OMS, positions, executors all use integer arithmetic. Kraken executors format as decimal with 8 decimal places for exchange communication (`orderbook.zig:4`, `executor.zig:131-135`)
- **Init/deinit convention**: Every struct follows `init() !T` / `deinit(*T) void` pattern consistently (`orderbook.zig:24,159`, `oms.zig:183,289`, etc.)
- **No application entry point**: There are no executable targets in `build.zig` (line 972 total, no `b.addExecutable` calls). The codebase is entirely libraries and test targets.
- **No event bus / message dispatcher**: There is no central event routing system. Modules communicate via direct function calls (e.g., executor calls `oms.onExecution()` directly, strategies receive `L2Book` references directly). There is no pub/sub or event queue infrastructure.
- **Mock/demo mode built into executors**: Both `SpotExecutor` and `FuturesExecutor` accept null client references and generate synthetic exchange IDs, meaning they can operate without live connections (`executor.zig:86-87,166-168`, `futures/executor.zig:139-141`)
- **Thread utilities available**: `sdk/core/io/thread.zig` provides `pinToCore()` and `spawnPinned()` for CPU-affinity thread management (`thread.zig:6,37`)
- **TCP available**: `sdk/core/io/tcp.zig` provides `TcpConnection.connect(allocator, host, port)` for network connections (`tcp.zig:10`)

## Coverage gaps

- 12 of 12 questions covered, 0 gaps.
- Question 6 (terminal I/O primitives) is answered based on Zig stdlib knowledge rather than codebase files, since no TUI code exists yet. All other questions are answered with direct file:line references.
