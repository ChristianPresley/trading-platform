---
phase: 3
iteration: 01
generated: 2026-04-03
---

# Design: SDK GUI + Headless Mode

Research: .claude/specs/sdk-gui-headless-mode/02-research-01.md

## Current State

The trading desk is a single executable (`desk`) with engine and TUI tightly coupled in one `main()`:

- Two `SpscRingBuffer` instances created in `main.zig:50-54` connect the engine thread to the TUI main thread
- Engine thread (`engine.zig:134-189`) produces `EngineEvent` and consumes `UserCommand` via ring buffers — it has no knowledge of the TUI
- TUI runs on the main thread: polls terminal input at ~15 FPS (`main.zig:231`), drains engine events, renders 5 panels into a single ANSI buffer, flushes with one syscall (`renderer.zig:115-118`)
- Headless detection exists (`terminal.zig:37-39`, `main.zig:40-46`) but only prints a version string and exits — no headless operation mode
- Layout uses terminal-independent `Rect{x,y,w,h}` (`layout.zig:7-12`); coupling to the terminal occurs only in renderer ANSI positioning (`renderer.zig:104`)
- 4 of 5 panels are stateless pure functions `draw(renderer, rect, data)` — only `OrderEntryPanel` (`order_entry_panel.zig:50-68`) holds mutable state
- All message types are fixed-size value types with no pointers/slices (`messages.zig:1-2`)
- Rendering uses basic ANSI: bold, reset, red (`\x1b[31m` at `orderbook_panel.zig:52`), green (`\x1b[32m` at `orderbook_panel.zig:75`), inverse (`\x1b[7m` at `order_entry_panel.zig:163`). ASCII box drawing with `+`, `-`, `|` (`renderer.zig:69-98`)
- `bar_aggregator.zig` exists in `sdk/domain/` but is not wired into the desk engine

## Desired End State

1. **Separate executables** sharing a common engine module: `desk-tui` (enhanced TUI), `desk-headless` (programmatic control), and eventually `desk-gui` (pixel-buffer GUI, future feature)
2. **Headless mode** where the engine runs with a ring buffer API for in-process algo trading and integration testing — no rendering, no terminal dependency
3. **Visually rich TUI** with Unicode box drawing, 24-bit true color, color themes, sparklines, candlestick chart, and smooth animations
4. **Candlestick chart panel** replacing the positions panel (top-right), with proper OHLC rendering (bodies + wicks), trend-aware hollow/filled styling, and colors consistent with orderbook bid/ask
5. **Positions summary** moved to the status bar, with a 'p' toggle for a full overlay

## Patterns to Follow

- **Message-driven architecture**: `messages.zig:1-2`, `ring_buffer.zig:10-11` — engine and UI communicate exclusively through lock-free ring buffers with fixed-size value types. No shared mutable state, no locks. The ring buffer IS the frontend interface.
- **Stateless panel pattern**: `orderbook_panel.zig:25`, `positions_panel.zig:10`, `orders_panel.zig:13`, `status_panel.zig:10` — pure `draw(renderer, rect, data)` functions. New panels (chart, enhanced status) must follow this pattern.
- **Rect-based layout abstraction**: `layout.zig:7-12` — `Rect` is terminal-independent. Layout computation is pure and decoupled from rendering.
- **Module composition via build.zig**: `build.zig:1131-1158` — modules are created independently and composed via `addImport()`. New executables follow the same pattern.
- **Fixed-point pricing**: i64 with 8 decimal places used throughout `messages.zig`, `orderbook.zig`, `synthetic.zig`, panels. Candlestick data must use the same representation.
- **Single-buffer-single-flush rendering**: `renderer.zig:115-118` — all panel draws accumulate into one buffer per frame, single `stdout.write()` syscall. Maintain this for enhanced rendering.
- **Inline tests**: desk modules use inline `test "name" {}` blocks (`messages.zig:82-88`, `input.zig:103-129`, `layout.zig:49-57`). New desk code follows this pattern.

## Patterns to Avoid

- **Forced frontend abstraction**: The comptime trait/vtable approach was considered and rejected. The ring buffer is already the interface (`ring_buffer.zig:10-11`). Adding a `Frontend` trait wraps an already-clean boundary with unnecessary ceremony. Each frontend has fundamentally different main loops (TUI polls at 15 FPS, headless runs tight algo loops, GUI would be event-driven).
- **Shared mutable state between threads**: `messages.zig:1-2` design note — all inter-thread communication uses value types through ring buffers. No mutexes, no shared pointers.
- **Cross-directory type imports**: `build.zig:1098-1099` — avoid "file exists in multiple modules" errors by importing modules that re-export, not importing multiple modules with shared files.
- **Runtime vtable dispatch**: Against the project's performance philosophy. Function pointer indirection on hot paths (every event dispatch, every render call) is not acceptable.

## Resolved Design Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| GUI rendering approach | Pixel buffer abstraction deferred to GUI follow-up | Building renderer without a display backend means guessing at the API; build it alongside its first consumer |
| Headless control mechanism | In-process ring buffer API | Zero-copy, lock-free, sub-microsecond latency; reuses existing ring buffer infrastructure; foundation for IPC layer later |
| Frontend architecture | Separate executables, shared engine module | Ring buffers are the interface; each frontend has fundamentally different main loops; avoids forced abstraction |
| Candle data source | Engine-side aggregation via bar_aggregator.zig | Keeps TUI panels stateless; works for both real and synthetic feeds; bar_aggregator already exists in sdk/domain/ |
| Chart layout placement | Chart replaces positions panel (top-right) | Chart is the most important view for active trading; positions data is compact enough for status bar summary |
| Positions data display | Summary in status bar + 'p' toggle for full overlay | Covers 90% of use cases inline; full detail available on demand without consuming permanent screen real estate |
| Candle body styling | Filled (█) for with-trend, hollow (┌┐││└┘) for counter-trend | Professional trading platform convention; hollow candles signal counter-trend action at a glance |
| Candle coloring | Green (bullish) / Red (bearish), matching bid/ask colors | Consistent color semantics: green = bid = bullish, red = ask = bearish across orderbook, chart, fills, and status |
| Box drawing | Unicode (│─┌┐└┘├┤┬┴┼) replacing ASCII (+\|-) | Dramatically better visual quality with zero performance cost |
| Color support | 24-bit true color (\x1b[38;2;R;G;Bm) | Enables rich theming and precise color matching across panels |

## Approach

### Phase A: Engine Module Extraction

Extract `engine.zig`, `messages.zig`, `synthetic.zig`, and their dependencies into importable modules in `build.zig`. The existing `desk` executable becomes `desk-tui`, importing the engine module rather than owning the engine code directly. This is a pure refactoring step — no behavior changes. The engine's ring buffer contract (`SpscRingBuffer(EngineEvent)` / `SpscRingBuffer(UserCommand)`) becomes the explicit public API surface.

A new `CandleUpdate` message type is added to `messages.zig` containing OHLC data (open, high, low, close as i64 fixed-point), volume, timestamp, and instrument ID. The engine is wired to `bar_aggregator.zig` to produce 1-minute candles from the synthetic feed's price ticks, pushed as `EngineEvent.candle_update`.

### Phase B: Headless Executable

Create `desk-headless` as a new executable that imports the shared engine module. Its `main()` creates the ring buffers, spawns the engine thread, and exposes a simple library-level API: `push(UserCommand)` and `pop() ?EngineEvent`. No terminal initialization, no rendering, no ANSI output. The shutdown sequence mirrors the TUI's (`UserCommand.quit` → `EngineEvent.shutdown_ack`). This enables: (1) integration testing without a terminal, (2) algo trading where Zig code drives the engine programmatically, (3) benchmarking engine throughput in isolation.

### Phase C: TUI Visual Overhaul

Enhance the renderer and panels with:

1. **Unicode box drawing**: Replace ASCII `+`, `-`, `|` in `renderer.zig:69-98` with Unicode `│─┌┐└┘├┤┬┴┼`. The `drawBox()` function gets updated characters with no structural changes.

2. **True color support**: Add `writeColor(r, g, b)` and `writeBgColor(r, g, b)` to the renderer. Panels switch from hardcoded ANSI color codes to theme-provided RGB values.

3. **Color theme system**: A `Theme` struct mapping semantic roles (bid, ask, spread, border, title, active_field, status_ok, status_error, candle_bull, candle_bear) to RGB tuples. Ship with 2-3 built-in themes (dark, light, classic-green). Theme is selected at startup and passed to all panel draw functions.

4. **Candlestick chart panel**: New `chart_panel.zig` following the stateless `draw(renderer, rect, candles)` pattern. Renders proper OHLC candles: thin `│` wicks for high/low, bodies for open/close range. Filled `█` bodies for with-trend candles, hollow `┌┐││└┘` bodies for counter-trend. Green for bullish, red for bearish (colors from theme, matching bid/ask). Each candle is 3 chars wide. Auto-scales Y axis to visible price range. Shows instrument name and timeframe in title.

5. **Sparklines and depth visualization**: Price history sparklines using `▁▂▃▄▅▆▇█` characters in the orderbook panel (showing recent BBO movement). Depth visualization using block elements `░▒▓█` to show relative quantity at each price level.

6. **Smooth animations**: Blinking highlights on new fills/rejects (flash the row for 2-3 frames). Status message fade (full brightness → dim over 45 frames). Subtle spread bar animation when spread changes.

7. **Layout update**: Modify `layout.zig` to assign top-right rect to the chart panel instead of positions. Add positions summary rendering to the status bar panel. Add 'p' hotkey to `input.zig` Action enum for toggling a positions overlay.

### Phase D: Build System and Testing

Update `build.zig` to register the new executables (`desk-tui`, `desk-headless`) and their module dependencies. Add build steps: `build-desk-tui`, `run-desk-tui`, `test-desk-tui`, `build-desk-headless`, `run-desk-headless`, `test-desk-headless`. Ensure the existing `build-desk` / `run-desk` / `test-desk` steps continue to work (alias to `desk-tui` for backwards compatibility). Add tests for: chart panel rendering, theme color application, candle aggregation pipeline, headless API push/pop cycle, positions overlay toggle.

## Open Questions

(None — all resolved during design discussion.)
