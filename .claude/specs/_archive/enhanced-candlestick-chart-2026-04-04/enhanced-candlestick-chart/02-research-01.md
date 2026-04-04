---
phase: 2
iteration: 01
generated: 2026-04-03
---

# Research: Enhanced Candlestick Chart

Questions source: .claude/specs/enhanced-candlestick-chart/01-questions-01.md

## How does chart_panel.zig currently render candlesticks — Unicode characters, OHLC mapping, and vertical resolution?

- `drawCandle()` function at `trading/desk/panels/chart_panel.zig:27-76` renders each candlestick
- Two Unicode characters used:
  - `│` (BOX DRAWINGS LIGHT VERTICAL, `\xe2\x94\x82`) for wicks — `chart_panel.zig:60,72`
  - `█` (FULL BLOCK, `\xe2\x96\x88`) for candle body — `chart_panel.zig:66`
- `scaleY()` function at `chart_panel.zig:14-23` maps price to terminal row:
  - Formula: `from_top = (height - 1) - ((price - min_price) * (height - 1) / range)`
  - Returns 0 (top of chart) to height-1 (bottom of chart)
- Four key rows computed per candle at `chart_panel.zig:43-46`:
  - `high_row`, `low_row`, `body_top_row` (max of open/close), `body_bot_row` (min of open/close)
- Each candle occupies 3 terminal columns (comment at `chart_panel.zig:26`), with wick and body drawn in center column at `chart_panel.zig:49`
- ANSI cursor positioning via `\x1b[{row};{col}H` escape sequences at `chart_panel.zig:60,66,72`
- Effective vertical resolution: **1 terminal cell per price unit** — no sub-cell precision
- Chart height = `inner_h - 1` (bottom row reserved for Y-axis labels) at `chart_panel.zig:117`

## How does the renderer handle character output — single vs. multi-byte UTF-8, combining characters, half-block/Braille?

- `renderer.zig:43-51` public methods:
  - `writeRawPub(data: []const u8)` — writes raw bytes, ignores overflow
  - `writeFmt(fmt, args)` — formatted output via `std.fmt.bufPrint`
  - `drawText(x, y, text)` — positioned byte-slice write
  - `drawTextFmt(x, y, fmt, args)` — positioned formatted output
- `writeRaw(data)` at `renderer.zig:48-51` is private, returns error on buffer full
- No dedicated single-character write method exists — all output uses byte slices
- Multi-byte UTF-8 handled as raw bytes; comment at `renderer.zig:89` states: "box drawing chars are 3 bytes UTF-8 each, but terminal counts them as 1 column wide"
- Box drawing characters in `drawBox()`:
  - `┌` = `\xe2\x94\x8c` (`renderer.zig:90`), `─` (`renderer.zig:97,103,111`), `┐` (`renderer.zig:105`), `└` (`renderer.zig:108`), `┘` (`renderer.zig:113`), `│` (`renderer.zig:118-119`)
- **Combining characters**: NOT supported — no zero-width or diacritic handling anywhere
- **Braille characters** (U+2800..U+28FF): NOT present in the codebase
- **Half-block characters**: Supported via sparkline rendering in orderbook_panel (see Q7)

## How is candle history stored and passed to the chart panel — ring buffers, instrument indexing, CandleUpdate flow?

- **Candle history storage** at `trading/desk/main.zig:77-78`:
  - `var candle_history: [2][64]CandleUpdate = undefined;` — 2 instruments × 64 candles
  - `var candle_counts: [2]usize = .{ 0, 0 };` — per-instrument count
  - Circular buffer: `slot = candle_counts[idx] % 64` at `main.zig:186`
- **CandleUpdate struct** at `trading/desk/messages.zig:66-74`:
  ```
  instrument: InstrumentId, open: i64, high: i64, low: i64, close: i64, volume: i64, timestamp: u64
  ```
  - `InstrumentId` (messages.zig:4-19): 32-byte buffer with length field
  - Fixed-size value type — safe for lock-free ring buffer
- **Engine→TUI ring buffer** at `main.zig:53-55`:
  - `SpscRingBuffer(EngineEvent).init(allocator, 256)` — single-producer single-consumer, capacity 256
  - Implementation at `sdk/core/containers/ring_buffer.zig:4-62`
- **EngineEvent union** at `messages.zig:76-84` includes `candle_update: CandleUpdate` variant
- **Engine pushes candles** at `trading/desk/engine.zig:163-174`:
  - When `candle_aggs[i].onTrade()` returns a completed Bar, constructs CandleUpdate and pushes via `self.to_tui.push(EngineEvent{ .candle_update = cu })`
- **TUI drains events** at `main.zig:176-189`:
  - Matches instrument by name comparison against orderbook snapshots
  - Stores in `candle_history[idx][slot]`, increments `candle_counts[idx]`
- **Chart panel receives** at `main.zig:221-222`:
  - `candle_len = @min(candle_counts[active_instrument], 64)`
  - `chart_panel.draw(&renderer, panels.chart, candle_history[active_instrument][0..candle_len], theme)`

## How does the layout system allocate space to the chart panel — Rect size, resizing, volume sub-panel room?

- **Rect struct** at `trading/desk/layout.zig:7-12`: `x: u16, y: u16, w: u16, h: u16`
- **6 panels defined** at `layout.zig:14-21`: orderbook, chart, order_entry, recent_orders, status_bar, positions_overlay
- **Layout computation** at `layout.zig:25-55`:
  - Terminal dimensions clamped: min 24 rows, min 80 cols (`layout.zig:26-27`)
  - Status bar: 1 row; content_h = rows - 1 (`layout.zig:30-31`)
  - Top/bottom split: `top_h = content_h / 2`, `bottom_h = content_h - top_h` (`layout.zig:34-35`)
  - Left/right split: `left_w = cols / 2`, `right_w = cols - left_w` (`layout.zig:36-37`)
  - **Chart panel**: `Rect{x: left_w, y: 0, w: right_w, h: top_h}` (`layout.zig:49`)
- **Example 80×24 terminal**: chart rect = {x:40, y:0, w:40, h:11}; inner area = 38×9; chart drawing = 38×8 (1 row for labels); max 12 candles (38/3)
- **Resizing** is fully dynamic:
  - `Terminal.getSize()` via TIOCGWINSZ ioctl every frame (`terminal.zig:89-103`)
  - Size change detection at `main.zig:104-108`, triggers `renderer.resize()` (`renderer.zig:149-156`)
  - Layout recomputed every frame: `layout_mod.compute(size)` at `main.zig:205`
- **Volume sub-panel space**: Currently no sub-division exists — chart receives a single monolithic Rect. The chart_panel.draw() function uses the entire inner area minus 1 row for labels. Vertical or horizontal subdivision is architecturally possible but requires: (1) layout changes or internal chart splitting, (2) volume data passthrough (not currently passed at `main.zig:222`)

## How does the BarAggregator work — bar types, 1-minute config, volume data in CandleUpdate?

- **Bar output struct** at `sdk/domain/bar_aggregator.zig:6-13`: `open, high, low, close, volume` (all i64) + `timestamp` (u128 ns)
- **Three bar aggregator types**, all separate structs:
  1. **BarAggregator** (time-based) at `bar_aggregator.zig:17-102`:
     - Fields: `interval_ns: u128, bar_start: u128, open, high, low, close, volume: i64, has_data: bool`
     - `onTrade(price, qty, timestamp)` at line 43: emits Bar when `effective_ts >= bar_start + interval_ns` (line 59)
     - Volume accumulation: first trade `self.volume = qty` (line 51), subsequent `self.volume += qty` (line 83)
  2. **VolumeBarAggregator** at `bar_aggregator.zig:106-160`:
     - Emits bar when `self.volume >= self.threshold` (line 145)
     - NOT used in engine
  3. **TickBarAggregator** at `bar_aggregator.zig:164-222`:
     - Emits bar every N trades: `self.tick_count >= self.ticks_per_bar` (line 207)
     - NOT used in engine
- **1-minute configuration** at `trading/desk/engine.zig:97-100`:
  ```
  .candle_aggs = .{ BarAggregator.init(60_000_000_000), BarAggregator.init(60_000_000_000) }
  ```
  - Hard-coded 60 billion nanoseconds = 60 seconds per bar, two instances for two instruments
- **Engine feeds BBO midpoint** at `engine.zig:160-162`:
  - `midpoint = @divTrunc(snap.bids[0].price + snap.asks[0].price, 2)`
  - `onTrade(midpoint, 1, timestamp_ns)` — qty always 1 (hardcoded)
- **Volume data in CandleUpdate**: YES — `volume: i64` field exists at `messages.zig:72`, populated from `bar.volume` at `engine.zig:170`. However, since engine passes qty=1 per tick, volume represents tick count within the bar interval, not actual traded volume

## How does the input handling system work — keybindings, arrow/modifier keys, mechanism for new actions?

- **Action union enum** at `trading/desk/input.zig:4-18` — 13 current variants:
  - Navigation: `tab`, `shift_tab`, `arrow_up`, `arrow_down`, `arrow_left`, `arrow_right`
  - Control: `enter`, `escape`, `backspace`, `quit`, `delete_line`
  - Other: `char(u8)`, `toggle_positions`
- **InputHandler** at `input.zig:26-37`: 3-state machine (`normal`, `escape`, `escape_bracket`) with unused `seq_buf: [8]u8`
- **Direct byte mappings** at `input.zig:41-68`:
  - 0x1b (ESC) → enters escape state; 0x09 (TAB) → `tab`; 0x0d/0x0a → `enter`; 0x7f/0x08 → `backspace`; 0x15 (^U) → `delete_line`; 0x03 (^C) → `quit`
  - Printable ASCII 0x20-0x7e: 'q'/'Q' → `quit` (unless text_mode), 'p' → `toggle_positions` (unless text_mode), others → `char(c)`
- **Arrow key decoding** at `input.zig:84-93`: ESC [ A/B/C/D → `arrow_up/down/right/left`
- **Shift+Tab**: ESC [ Z (modern) at line 91, ESC Z (legacy) at line 80
- **Text mode** at `main.zig:260`: `text_mode = (active_panel == PANEL_ORDER_ENTRY)` — 'q'/'p' become regular `char` actions
- **processAction()** at `main.zig:284-362` dispatches:
  - `quit`: exit or blur order entry (299-305)
  - `tab`/`shift_tab`: cycle through 3 panels mod 3 (311-320)
  - `toggle_positions`: toggle overlay (321-323)
  - `arrow_up/down`: only active in order entry panel (332-336)
  - `char`/`enter`/`backspace`/`delete_line`: delegated to order_entry panel when active
- **Frame timeout** at `input.zig:99-105`: `frameReset()` emits `escape` if mid-sequence, called at `main.zig:252-256`
- **Modifier key support**: Only Ctrl+C, Ctrl+U, and Shift+Tab. No Alt, Ctrl+arrow, or multi-key chords. The `seq_buf` at line 28 is allocated but unused — reserved for extended sequences
- **Mechanism for new actions**: (1) add variant to Action enum, (2) add byte/sequence mapping in `feed()`, (3) add case in `processAction()`

## How do existing sparkline panels render sub-cell-resolution graphics — Braille vs. half-block, reusable helpers?

- **Sparkline characters** at `trading/desk/panels/orderbook_panel.zig:27-38`:
  - `SPARKLINE_CHARS`: array of 8 lower-block characters (U+2581..U+2588), each 3 bytes UTF-8
  - Levels: ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ — 8 vertical levels per cell
- **Depth bar characters** at `orderbook_panel.zig:39-44`:
  - `DEPTH_CHARS`: 4 shade levels: ░ ▒ ▓ █ (U+2591..U+2593 + U+2588)
- **sparkline() function** at `orderbook_panel.zig:46-80`:
  - Takes `values: []const i64`, `width: u16`, `buf: []u8`
  - Finds min/max, quantizes each value to 0-7 level: `level = min(7, max(0, (v - min) * 7 / range))` (line 71)
  - Writes 3 bytes per character from SPARKLINE_CHARS (lines 74-76)
  - Used at `orderbook_panel.zig:113-124` for BBO midpoint sparkline above orderbook table
- **depthBar() function** at `orderbook_panel.zig:82-101`:
  - Takes quantity, max_quantity, width, buf; fills columns with full block only (no sub-block variation)
- **Character type**: ALL half-block characters (lower block variants). NO Braille characters exist anywhere in the codebase
- **Reusability**: SPARKLINE_CHARS and DEPTH_CHARS are private `const` arrays in orderbook_panel.zig — NOT exported, NOT imported by chart_panel.zig. No shared rendering helpers module exists
- **Tests**: `sparkline_quantization` at `orderbook_panel.zig:204-220` verifies byte-level output; `depth_bar_scaling` at `orderbook_panel.zig:222-237` verifies width calculation

## How does the theme system define colors for chart elements?

- **Rgb type** at `trading/desk/theme.zig:6-10`: `struct { r: u8, g: u8, b: u8 }`
- **Theme struct** at `theme.zig:12-26` — 13 color fields:
  - `bid`, `ask`, `spread`, `border`, `title`, `text`, `text_dim`, `active_field`, `status_ok`, `status_error`, `candle_bull`, `candle_bear`, `background`
- **Candle colors** defined in three themes:
  - Dark: `candle_bull = {0x00, 0xC8, 0x53}`, `candle_bear = {0xFF, 0x17, 0x44}` (`theme.zig:40-41`)
  - Light: `candle_bull = {0x00, 0x7E, 0x33}`, `candle_bear = {0xCC, 0x00, 0x00}` (`theme.zig:57-58`)
  - Classic green: `candle_bull = {0x00, 0xFF, 0x00}`, `candle_bear = {0x00, 0x88, 0x00}` (`theme.zig:74-75`)
- **Usage** in chart_panel.zig: `renderer.writeColor(theme.candle_bull)` at line 52, `renderer.writeColor(theme.candle_bear)` at line 54
- **Color rendering** at `renderer.zig:168-176`: writes ANSI 24-bit true-color sequence `\x1b[38;2;{r};{g};{b}m`
- **Missing color fields**: No fields for volume bars, indicator lines, crosshair overlays, or grid/axis colors

## What test patterns exist for the chart panel and renderer?

- **Chart panel tests** at `trading/desk/panels/chart_panel.zig:147-174`:
  - `chart_scaleY` (lines 147-159): verifies Y-axis scaling top/bottom/midpoint mapping
  - `chart_scaleY_flat` (lines 161-165): edge case when min == max (division by zero guard)
  - `chart_empty_candles` (lines 167-174): empty candle slice handling, max_candles calculation
- **Renderer tests** at `trading/desk/renderer.zig:159-177`:
  - `renderer_drawbox_no_crash` (lines 159-166): tests Rect data, NOT actual rendering
  - `renderer_color_sequence` (lines 168-176): verifies ANSI 24-bit color format string
- **Orderbook panel tests** at `orderbook_panel.zig:204-237`:
  - `sparkline_quantization`: byte-level UTF-8 character output verification
  - `depth_bar_scaling`: width calculation verification
- **HeadlessDesk harness** at `trading/desk/headless_main.zig:111-155`:
  - `headless_init_shutdown`, `headless_push_pop`, `headless_quit_ack` — programmatic testing without terminal
- **Testing API**: `std.testing` (expect, expectEqual, expectEqualStrings)
- **Mock pattern** in exchanges: `MockExchangeResponse` in `exchanges/kraken/spot/executor.zig` with `injectResponse()` for dependency injection
- **NOT available**: No mock renderer, no snapshot testing, no visual regression testing, no buffer capture/inspection mechanism. Renderer requires Terminal pointer (`renderer.zig:16`), making isolated testing difficult

## How does the Y-axis price label system work — formatting, positioning, horizontal space?

- **Price formatting** at `chart_panel.zig:133-138`:
  - Prices stored as i64 with 8 decimal places (fixed-point)
  - Division by `100_000_000` to get whole number: `divTrunc(price, 100_000_000)`
  - Formatted as integer: `bufPrint(&pbuf, "{d}", .{whole})` — currently shows whole numbers only, no decimal places
  - Buffers: 20 bytes each for max/min/mid labels (`chart_panel.zig:130-132`)
- **Three labels positioned** at `chart_panel.zig:141-143`:
  - Top (max price): `drawText(label_col, rect.y + 1, max_str)`
  - Middle (midpoint): `drawText(label_col, rect.y + 1 + chart_h / 2, mid_str)`
  - Bottom (min price): `drawText(label_col, rect.y + 1 + chart_h -| 1, min_str)`
- **Midpoint calculation** at `chart_panel.zig:127`: `mid_price = divTrunc(y_max + y_min, 2)`
- **Horizontal space**: Labels positioned at `label_col = rect.x + rect.w -| 10` (`chart_panel.zig:126`) — **10 columns reserved** from right edge of chart rect
- **Color**: Labels drawn in `theme.text_dim` color, reset after (`chart_panel.zig:140-143`)

## Cross-cutting observations

- All UTF-8 multi-byte characters are written as raw 3-byte arrays throughout the codebase — no Unicode abstraction layer (`renderer.zig:89`, `orderbook_panel.zig:27-44`, `chart_panel.zig:60-72`)
- Sub-cell rendering exists only in orderbook sparklines (8-level half-blocks at `orderbook_panel.zig:27-38`); chart uses 1-cell-per-row resolution (`chart_panel.zig:14-23`)
- Volume data flows through the full pipeline (BarAggregator → Bar → CandleUpdate → candle_history) but is never rendered — present in struct at `messages.zig:72`, stored in history at `main.zig:186`, unused by `chart_panel.draw()` at `main.zig:222`
- Layout is a simple 2×2 grid + status bar with 50/50 splits (`layout.zig:34-37`); no proportional or configurable allocation
- Input system has an unused `seq_buf[8]` (`input.zig:28`) reserved for extended escape sequences; currently only single-byte and 3-byte ESC sequences decoded
- Theme has exactly 2 chart-related colors (`candle_bull`, `candle_bear` at `theme.zig:23-24`); all other visual elements (borders, labels) use generic theme colors
- All tests verify internal logic only (scaling, quantization, format strings); no tests verify actual rendered output or ANSI sequences written to buffer

## Coverage gaps

- None — all 10 questions fully covered with file:line references
