---
phase: 2
iteration: 01
generated: 2026-04-03
---

# Research: SDK GUI + Headless Mode

Questions source: .claude/specs/sdk-gui-headless-mode/01-questions-01.md

## How does the engine communicate with the TUI today?

- Two `SpscRingBuffer` instances allocated in `main.zig:50-54`: `to_tui: SpscRingBuffer(EngineEvent)` capacity 256 and `from_tui: SpscRingBuffer(UserCommand)` capacity 256
- `SpscRingBuffer(T)` at `sdk/core/containers/ring_buffer.zig:10-11` uses two atomic `usize` indices (`write_idx`, `read_idx`) with acquire-release memory ordering (`ring_buffer.zig:32-33,36,42-46`)
- Capacity always power-of-two, masked with `(capacity - 1)` at `ring_buffer.zig:15,35,45`; non-blocking: `push()` returns `bool`, `pop()` returns `?T`
- **Engine thread** spawned via `std.Thread.spawn(.{}, Engine.run, .{&engine})` at `main.zig:61`; runs `Engine.run()` at `engine.zig:134-189`
- Engine is the **producer** for `to_tui` (pushes at `engine.zig:145,158,162,174,208,223`) and **consumer** of `from_tui` (drains at `engine.zig:170`)
- Engine ticks every 100ms (`engine.zig:187`: `std.Thread.sleep(100_000_000)`)
- **TUI runs on main thread**; consumes `to_tui` at `main.zig:102` in a drain loop; produces `UserCommand` at `main.zig:222,292`
- `EngineEvent` union at `messages.zig:66-73`: `.tick(u64)`, `.orderbook_snapshot(OrderbookSnapshot)`, `.position_update(PositionUpdate)`, `.order_update(OrderUpdate)`, `.status(StatusUpdate)`, `.shutdown_ack(void)`
- `UserCommand` union at `messages.zig:75-80`: `.quit(void)`, `.select_instrument(InstrumentId)`, `.submit_order(OrderRequest)`, `.cancel_order(u64)`
- All message types are fixed-size value types with no pointers or slices (`messages.zig:1-2` design note), safe for ring buffer transport
- **Shutdown sequence**: user presses 'q' → `UserCommand.quit` pushed → engine sets `running = false`, pushes `EngineEvent.shutdown_ack` (`engine.zig:172-175`) → TUI receives ack, sets `engine_stopped = true` (`main.zig:154`) → main loop exits, joins engine thread (`main.zig:235`)

## How is the TUI renderer implemented?

- `Renderer` struct at `renderer.zig:12-19` with fields: `buf: []u8`, `cursor: usize`, `rows: u16`, `cols: u16`
- Buffer size: `rows * cols * 12 + 64` bytes at `renderer.zig:18` — 12 bytes per cell for worst-case ANSI sequences
- **beginFrame()** at `renderer.zig:33-37`: resets cursor to 0, writes `\x1b[H` (cursor home) and `\x1b[2J` (clear screen)
- **writeRaw()** at `renderer.zig:45-49`: memory-copies raw bytes into buffer, increments cursor; overflow silently ignored (`renderer.zig:40-41`)
- **writeFmt()** at `renderer.zig:52-56`: formats via `std.fmt.bufPrint()` into temp 4096-byte buffer, calls `writeRaw()`
- **drawBox()** at `renderer.zig:69-98`: top/bottom borders with `+` and `-` chars, side borders with `|`, centered title
- **drawText()** at `renderer.zig:104`: positions cursor via `\x1b[{row};{col}H{text}` (1-indexed)
- **endFrame()** at `renderer.zig:115-118`: single syscall flush `terminal.stdout.write(buf[0..cursor])`
- **resize()** at `renderer.zig:121-128`: reallocates buffer when terminal size changes (called from `main.zig:94-98`)
- ANSI sequences used: bold `\x1b[1m`, reset `\x1b[0m`, red `\x1b[31m` (asks, `orderbook_panel.zig:52`), green `\x1b[32m` (bids, `orderbook_panel.zig:75`), inverse `\x1b[7m` (active field, `order_entry_panel.zig:163`)
- **Frame rate**: ~15 FPS via 66ms sleep at `main.zig:231`; engine timeout detection after 150 frames (10s) at `main.zig:161-163`; status message timeout after 45 frames (3s) at `main.zig:296`

## How does the terminal abstraction work?

- `Terminal` struct at `terminal.zig:22-28`: fields `original_termios`, `stdin_fd`, `stdout: std.fs.File`, `buf: [65536]u8`, `buf_pos: usize`
- **Headless detection**: `posix.isatty(stdin_fd)` check at `terminal.zig:37-39`; returns `error.NotATerminal` if false
- **Headless handling** in `main.zig:40-46`: catches `error.NotATerminal`, prints version string to stdout, and returns (no TUI rendering)
- **Raw mode** at `terminal.zig:41-53`: saves original termios via `posix.tcgetattr()`, disables ICRNL, IXON, ECHO, ICANON, ISIG, IEXTEN; sets CS8; VMIN=0, VTIME=0 for non-blocking
- **Signal handling** at `terminal.zig:63-70`: registers `signalHandler` for SIGINT and SIGTERM via `posix.sigaction()`; sets global `signal_received: bool` at `terminal.zig:15`; main loop checks `!terminal_mod.signal_received` at `main.zig:92`
- **Size detection** via `getSize()` at `terminal.zig:89-103`: uses `posix.system.ioctl(STDOUT_FILENO, T.IOCGWINSZ, ...)` for `winsize` struct; returns minimum bounds rows≥10, cols≥40 at `terminal.zig:100-101`
- **Non-blocking input** via `readByte()` at `terminal.zig:107-119`: uses `posix.poll()` with timeout 0 (immediate return); returns `?u8`, null if no data ready
- **Alternate screen**: enters with `\x1b[?1049h\x1b[?25l` on init (`terminal.zig:73`); exits with `\x1b[?25h\x1b[?1049l` on deinit (`terminal.zig:81`)
- **Output buffering**: `writeStr()` at `terminal.zig:122-133` accumulates into 65536-byte internal buffer; `flushBuf()` at `terminal.zig:143-147` writes to stdout; `beginWrite()` at `terminal.zig:150-152` resets buffer position

## How does the input handling system work?

- `Action` union at `input.zig:4-17`: `tab`, `shift_tab`, `arrow_up`, `arrow_down`, `arrow_left`, `arrow_right`, `enter`, `escape`, `char(u8)`, `backspace`, `quit`, `delete_line`
- `InputHandler` struct at `input.zig:25-36` with 3-state FSM: `State` enum at `input.zig:19-23` — `normal`, `escape`, `escape_bracket`
- **feed()** method at `input.zig:40-91` decodes one byte at a time:
  - Normal state: `0x1b`→escape, `0x09`→tab, `0x0d/0x0a`→enter, `0x7f/0x08`→backspace, `0x15`→delete_line (Ctrl+U), `0x03`→quit (Ctrl+C), printable `0x20..0x7e`→char or quit based on text_mode
  - Escape state: `[`→escape_bracket, another `0x1b`→emit escape, `Z`→shift_tab, other→escape
  - Escape_bracket state: `A`→arrow_up, `B`→arrow_down, `C`→arrow_right, `D`→arrow_left, `Z`→shift_tab
- **Text mode vs navigation mode**: determined by `active_panel == PANEL_ORDER_ENTRY` at `main.zig:217`; in text mode 'q'/'Q' are regular chars, not quit
- **frameReset()** at `input.zig:94-100`: called each frame at `main.zig:210`; if in non-normal state, transitions to normal and emits `.escape` (timeout for incomplete sequences)
- Input processing at `main.zig:209-227`: drains all available bytes per frame via `term.readByte()`, feeds each through `input_handler.feed()`, dispatches complete actions immediately

## How are the TUI panels structured?

- Five panels in `trading/desk/panels/`: orderbook, positions, orders, status, order_entry
- **Stateless panels** share a common draw signature pattern: `pub fn draw(renderer: *Renderer, rect: Rect, data: *const T) void`
  - `orderbook_panel.zig:25`: `draw(renderer, rect, snapshot: *const OrderbookSnapshot)`
  - `positions_panel.zig:10`: `draw(renderer, rect, positions: []const PositionUpdate)`
  - `orders_panel.zig:13`: `draw(renderer, rect, orders: []const OrderUpdate)`
  - `status_panel.zig:10`: `draw(renderer, rect, status: *const StatusUpdate)`
- **Stateful panel** — `OrderEntryPanel` struct at `order_entry_panel.zig:50-68`: maintains `fields: [4]TextField` (32-byte buffer + len + cursor each), `active_field: u8`, `side: u8`
  - `draw(self: *const OrderEntryPanel, renderer, rect, active: bool)` at `order_entry_panel.zig:145`
  - `handleAction(self: *OrderEntryPanel, action: Action) ?UserCommand` at `order_entry_panel.zig:71` — returns optional UserCommand (e.g., order submission)
- All panels consume fixed-size value types from `messages.zig` — `OrderbookSnapshot`, `PositionUpdate`, `OrderUpdate`, `StatusUpdate`
- Panel rendering called from main loop at `main.zig:177,184,188,192,204` with layout-computed `Rect` for each

## How does the layout system compute panel positions?

- `Rect` struct at `layout.zig:7-12`: `x: u16, y: u16, w: u16, h: u16` — generic rectangle, not terminal-specific
- `Panels` struct at `layout.zig:14-20`: named fields `orderbook`, `positions`, `order_entry`, `recent_orders`, `status_bar` — each a `Rect`
- `compute(size: Size) Panels` at `layout.zig:24-47`:
  - Clamps to minimum 80×24 at `layout.zig:25-26`
  - Status bar: 1 row at bottom (`y = rows - 1`, full width) at `layout.zig:29,45`
  - Content area: `content_h = rows - 1` at `layout.zig:30`
  - Top half (50%): orderbook (left 50%) + positions (right 50%) at `layout.zig:33-34,41-42`
  - Bottom half (remaining): order entry (left) + recent orders (right) at `layout.zig:38,43-44`
  - Column split: `left_w = cols / 2`, `right_w = cols - left_w` at `layout.zig:34-35`
- `Size` struct imported from `terminal.zig:9-12`: `rows: u16, cols: u16`
- Layout recomputed every frame at `main.zig:168`: `const panels = layout_mod.compute(size)`
- Renderer bridges Rect to terminal via 1-indexed ANSI cursor positioning at `renderer.zig:104`
- Test at `layout.zig:49-57`: verifies horizontal coverage and status bar position for 80×24

## What SDK domain modules exist and how does the desk use them?

- **Domain modules** under `sdk/domain/`:
  - `orderbook.zig`: `L2Book`, `Level`, `Side` — sorted bid/ask arrays, O(1) BBO queries
  - `oms.zig`: `OrderManager`, `Order`, `OrderId`, `OrdStatus` (13 states), `ExecType`, `OrderStateMachine` — imports `order_types.zig`
  - `order_types.zig`: `OrderType`, `TimeInForce`, `Side`, `OrderId`, `BracketOrder`, `OcoGroup` with FIX tag mappings
  - `positions.zig`: `PositionManager`, `Position`, `Fill`, `CostBasisMethod` (fifo/lifo/average_cost)
  - `risk/pre_trade.zig`: `PreTradeRisk`, `RiskConfig`, `RejectReason`, `ValidationResult` — imports `oms`
  - `market_data.zig`: `SymbolMapper` with static Kraken↔internal lookup tables
  - `algos/`: `twap.zig`, `vwap.zig`, `pov.zig`, `iceberg.zig` — standalone, redefine types locally
  - `sor.zig`: Smart order router — redefines types locally to avoid cross-directory imports
  - `post_trade/`: `reconciliation.zig`, `eod.zig`, `allocation.zig`
  - `tick_store.zig`, `parquet_writer.zig`, `bar_aggregator.zig`
- **Core modules** under `sdk/core/`:
  - `containers/ring_buffer.zig`: `SpscRingBuffer(T)` — lock-free SPSC with atomics
  - `containers/mpsc_queue.zig`, `containers/hash_map.zig`, `containers/sorted_array.zig`
  - `memory.zig`: `PoolAllocator` (64-byte aligned slots), `ArenaAllocator`
  - `time.zig`: `Timestamp` with `now()` (CLOCK_MONOTONIC), `wallClock()` (CLOCK_REALTIME), format conversions
  - `event_store.zig`: append-only event store with file persistence
  - `io/event_loop.zig`, `io/tcp.zig`, `io/thread.zig` (CPU pinning via `sched_setaffinity`)
  - `crypto/`: hmac, base64, aes, chacha20, x25519, rsa, ecdsa
- **Desk import chain** via `build.zig:1131-1158`:
  - `desk_main_mod.addImport("ring_buffer", ring_buffer_mod)` at `build.zig:1158`
  - `desk_main_mod.addImport("orderbook", orderbook_mod)` at `build.zig:1151`
  - `desk_main_mod.addImport("oms", oms_mod)` at `build.zig:1152`
  - `desk_main_mod.addImport("order_types", order_types_mod)` at `build.zig:1153`
  - `desk_main_mod.addImport("positions", positions_mod)` at `build.zig:1154`
  - `desk_main_mod.addImport("pre_trade", pre_trade_mod)` at `build.zig:1155`
  - `desk_main_mod.addImport("memory", memory_mod)` at `build.zig:1156`
  - `desk_main_mod.addImport("time", time_mod)` at `build.zig:1157`
- **Actual usage in desk**:
  - `main.zig:6`: `@import("ring_buffer").SpscRingBuffer` for both ring buffers
  - `engine.zig:5`: `@import("ring_buffer").SpscRingBuffer`
  - `engine.zig:14-17`: `@import("orderbook").L2Book`, `@import("oms").OrderManager/Order`
  - `synthetic.zig:14-16`: `@import("orderbook").L2Book/Level/Side`

## How does build.zig wire up modules and tests?

- **Module creation pattern**: `b.createModule(.{ .root_source_file = b.path("...") })` — e.g., `order_types_mod` at `build.zig:148-150`
- **Module dependencies**: `oms_mod.addImport("order_types", order_types_mod)` at `build.zig:154`; `pre_trade_mod.addImport("oms", oms_mod)` at `build.zig:159`
- **Cross-directory imports**: two patterns —
  - Named: `mod.addImport("name", other_mod)` for shared modules (e.g., `build.zig:151-158`)
  - Anonymous: `tests.root_module.addAnonymousImport("name", .{ .root_source_file = ... })` for test fixtures (e.g., `build.zig:78-89`)
- **Duplicate prevention**: `build.zig:1098-1099` comment documents avoiding "file exists in multiple modules" by importing `oms_mod` which re-exports `order_types` instead of importing both
- **Desk executable** at `build.zig:1161-1165`: `b.addExecutable(.{ .name = "desk", .root_module = desk_main_mod })`
- **Build steps**: `build-desk` → builds exe; `run-desk` → runs exe; `test-desk` → runs desk tests (`build.zig:1176-1196`)
- **Test target structure**: each test creates fresh module context with explicit imports; no transitive import pollution
- **Test step hierarchy**: `test` (master) includes `test-core`, `test-protocol`, `test-kraken`, all domain tests; subset steps for focused testing
- **Module reuse**: e.g., `oms_mod` added to domain tests, risk tests, kraken executor tests, desk main, and desk tests — single definition, multiple consumers

## What exists under sdk/protocol/?

- **Top-level protocols**: `json.zig` (JSON streaming parser), `ouch.zig` (OUCH 4.2), `pitch.zig` (Cboe PITCH 2.x), `itch.zig` (NASDAQ ITCH 5.0), `sbe.zig` (CME MDP 3.0 SBE), `fast.zig` (FAST decoder)
- **Subdirectories**: `fix/` (codec, seq_store, session), `http/` (client, url, chunked), `tls/` (client, record, x509), `websocket/` (frame, client)
- **Protocol message types are INDEPENDENT from desk messages**: each protocol defines its own wire-format-specific types
  - OUCH: `EnterOrder`, `ReplaceOrder`, `Accepted`, `Executed`, `Rejected` at `ouch.zig`
  - PITCH: `AddOrderLong`, `AddOrderShort`, `Execute`, `Trade` at `pitch.zig`
  - ITCH: `AddOrder`, `Delete`, `Trade`, `CrossTrade`, `Noii` at `itch.zig`
  - SBE: `FieldValue`, `SbeMessage` at `sbe.zig`
  - FAST: `FastFieldValue`, `FastMessage` at `fast.zig`
- `messages.zig` defines internal TUI↔engine communication types — no imports from `sdk/protocol/`; no shared definitions
- Both use fixed-size value types (no pointers/slices), but schemas are completely independent

## What test patterns exist across the codebase?

- **Naming convention**: `<module>_test.zig` suffix for separate test files
- **Organization**: SDK uses separate test files in `tests/` subdirectories; desk uses inline `test "name" {}` blocks in source files
- **SDK/Core**: 5 test modules — `memory_test.zig`, `time_test.zig`, `containers_test.zig`, `crypto_test.zig`, `event_store_test.zig` in `sdk/core/tests/`
- **SDK/Protocol**: 10+ test modules in `sdk/protocol/tests/` and protocol-specific `tests/` subdirs (fix, websocket)
- **SDK/Domain**: 20+ test modules in `sdk/domain/tests/`, `sdk/domain/algos/tests/`, `sdk/domain/post_trade/tests/`
- **Trading/Desk inline tests**: `messages.zig:82-88` (`test "messages_sizes"`), `input.zig:103-129` (3 tests), `main.zig:316` (`test "desk_smoke"`), `engine.zig`, `layout.zig:49-57`, `renderer.zig`, `synthetic.zig:107-114`, `terminal.zig`, `order_entry_panel.zig` (2 tests)
- **Test infrastructure**: Zig's built-in test runner, no custom harness; uses `std.testing.expect`, `expectEqual`, `expectError`, `expectEqualSlices`, `expectApproxEqAbs`
- **Build commands**: `zig build test` (all), `zig build test-core`, `zig build test-protocol`, `zig build test-desk`, `zig build test-kraken`
- **Total**: ~52+ test artifacts registered in `build.zig`

## What exists under exchanges/ and how does it integrate?

- `exchanges/kraken/` with spot and futures subdirectories
- **Spot**: `rest_client.zig`, `ws_client.zig`, `fix_client.zig`, `executor.zig`, `auth.zig`, `rate_limiter.zig`, `types.zig`
- **Futures**: `rest_client.zig`, `ws_client.zig`, `executor.zig`, `auth.zig`, `rate_limiter.zig`, `types.zig`
- **Common**: `symbol_translator.zig` — compile-time static maps: `"BTC-USD"` ↔ `"XXBTZUSD"`, `"ETH-USD"` ↔ `"XETHZUSD"` for spot; `"BTC-USD-PERP"` ↔ `"PI_XBTUSD"` for futures (`symbol_translator.zig:20-56`)
- **Spot executor** at `executor.zig:67-230`: takes optional `SpotRestClient`, `SpotWsClient`, `FixSession`, `OrderManager`; channel precedence FIX > WS > REST (`executor.zig:86`); calls `oms.onExecution()` on success/rejection (`executor.zig:156,160`)
- **Futures executor**: same pattern with dead man's switch (`executor.zig:163-182` — `cancelAllOrdersAfter`, 15-20s refresh)
- **FIX session state** at `sdk/protocol/fix/session.zig:26-31`: `disconnected`, `connected`, `logged_on`, `logging_out`
- **Rate limiting** at `rate_limiter.zig:13-57`: tier-based (starter 15/0.33, intermediate 20/1.0, pro 20/2.0) with time-based decay
- **WS message types** at `ws_client.zig:80-87`: `book_snapshot`, `book_update`, `trade`, `ticker`, `heartbeat`, `system_status`
- **StatusUpdate.connected** field at `messages.zig:64` exists but is hardcoded `false` in `engine.zig:166` (demo mode)

## How does the synthetic market data feed work?

- `SyntheticFeed` struct at `synthetic.zig:11-21`: `allocator`, `books: [2]L2Book`, `rng: std.Random.DefaultPrng`, `tick_count: u64`, `base_prices: [2]i64`
- **Init** at `synthetic.zig:23-44`: two L2Books with DEPTH=20 (`synthetic.zig:9`); base prices BTC=5_000_000_000_000 (50000.00), ETH=300_000_000_000 (3000.00) — 8 decimal fixed-point
- **tick()** at `synthetic.zig:72-99`: increments tick_count; random-walks base price by ±tick_size (100_000 = 0.001); updates 1-3 random levels per tick; every 20 ticks repopulates entire book
- **populateBook()** at `synthetic.zig:54-69`: creates 20 levels centered around base_price with random quantities 100_000-10_000_000; applies via `book.applySnapshot()`
- **L2Book** at `orderbook.zig:15-22`: pre-allocated `bids_buf`/`asks_buf` arrays with `bids_len`/`asks_len` counts; `Level` = `{price: i64, quantity: i64}`
- **Engine wiring** at `engine.zig:62-94`: creates `SyntheticFeed` with millisecond timestamp seed; hardcodes `INSTRUMENTS = ["BTC-USD", "ETH-USD"]` at `engine.zig:19`
- Engine main loop (`engine.zig:134-189`): calls `feed.tick()`, snapshots each book into `OrderbookSnapshot` (20 bid/ask levels, `engine.zig:102-131`), pushes via `to_tui` ring buffer
- **Snapshot format** at `messages.zig:26-32`: `instrument: InstrumentId`, `bids: [20]PriceLevel`, `asks: [20]PriceLevel`, `bid_count: u8`, `ask_count: u8`
- TUI drains snapshots at `main.zig:107-115`, stores in `orderbook_snap[2]` array indexed by instrument
- Price display: `orderbook_panel.zig:12-17` converts i64 (8 decimals) to 2-decimal display via `whole = price / 100_000_000`, `frac2 = (frac % 100_000_000) / 1_000_000`

## Cross-cutting observations

- **Message-driven architecture**: engine and TUI communicate exclusively through lock-free `SpscRingBuffer` with fixed-size value types; no shared mutable state, no locks (`messages.zig:1-2`, `ring_buffer.zig:10-11`)
- **Stateless panel pattern**: 4 of 5 panels are pure functions `draw(renderer, rect, data)` with no state; only order_entry maintains mutable state and generates commands (`order_entry_panel.zig:50-68`)
- **Rect-based layout abstraction**: `Rect{x,y,w,h}` at `layout.zig:7-12` is terminal-independent; terminal coupling only occurs in renderer ANSI positioning (`renderer.zig:104`)
- **Single-buffer-single-flush rendering**: all panel draws accumulate into one buffer per frame; single `stdout.write()` syscall per frame (`renderer.zig:115-118`)
- **Module independence pattern**: domain modules like `algos/twap.zig` and `sor.zig` redefine types locally rather than importing across boundaries; avoids "file exists in multiple modules" errors
- **Build.zig module composition**: modules are created independently and composed via `addImport()`; no global registry; test modules get explicit, minimal import sets
- **Fixed-point pricing**: i64 with 8 decimal places used throughout — `messages.zig`, `orderbook.zig`, `synthetic.zig`, display conversion in panels
- **Headless fallback exists but is minimal**: `main.zig:40-46` catches `error.NotATerminal` from `terminal.zig:37-39` and exits with version string; no headless operation mode

## Coverage gaps

- None. All 12 questions fully answered with file:line references.
