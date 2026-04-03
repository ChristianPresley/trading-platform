---
phase: 8
iteration: 01
generated: 2026-04-03
---

PR Title: Add SDK GUI headless mode + TUI visual overhaul with charts and themes

Closes: #36

## What problem does this solve?

The trading desk was a single monolithic executable with the engine tightly coupled to the TUI. There was no way to drive the engine programmatically for algo trading or integration testing, and the TUI used basic ASCII rendering with hardcoded ANSI colors. This feature:

1. Extracts the engine into a shared module and creates a separate `desk-headless` executable with a push/pop ring buffer API for programmatic control
2. Overhauls the TUI with Unicode box drawing, 24-bit true color, a theme system, candlestick charts, sparklines, depth visualization, and smooth animations

## User-facing changes

- **New `desk-headless` executable**: programmatic engine control via `HeadlessDesk.push(UserCommand)` / `pop() ?EngineEvent` API — enables algo trading and integration testing without a terminal
- **Candlestick chart panel**: OHLC chart in the top-right panel showing 1-minute candles with bullish/bearish coloring, auto-scaled Y axis
- **Unicode box drawing**: all panels use `│─┌┐└┘` instead of ASCII `+|-`
- **True color theme system**: 3 built-in themes (dark, light, classic_green) with semantic color roles
- **Sparklines**: BBO price history visualization in the orderbook panel using `▁▂▃▄▅▆▇█` block characters
- **Depth bars**: quantity visualization at each price level using `░▒▓█` gradient
- **Order flash highlights**: new fills/rejects flash for 2-3 frames with inverse video
- **Status fade animation**: status messages fade from full brightness to dim over 45 frames
- **Positions overlay**: press `p` to toggle a full positions overlay (positions moved from dedicated panel to status bar summary)
- **Executable renamed**: `desk` → `desk-tui` (backward-compat aliases `build-desk`, `run-desk`, `test-desk` preserved)

## Implementation summary

**Key design decisions** (from Phase 3):
- **Frontend architecture**: separate executables sharing engine module — ring buffers are the interface; each frontend has fundamentally different main loops; avoids forced abstraction
- **Headless control**: in-process ring buffer API — zero-copy, lock-free, sub-microsecond latency; reuses existing infrastructure
- **Candle data source**: engine-side aggregation via bar_aggregator.zig — keeps TUI panels stateless; works for both real and synthetic feeds
- **Chart placement**: replaces positions panel (top-right) — chart is the most important view for active trading
- **Candle coloring**: green/red matching bid/ask — consistent color semantics across all panels
- **Box drawing**: Unicode replacing ASCII — better visual quality at zero performance cost
- **Color**: 24-bit true color with theme system — enables rich theming and precise color matching

**Edge cases handled** (from Phase 5):
- BBO midpoint when book is empty: skip candle aggregation (don't feed price 0)
- Zero candles: chart displays "Waiting for data..." — no division by zero
- Flat market (all same price): scaleY guard prevents division by zero
- Empty BBO history: sparkline renders nothing
- UTF-8 multi-byte chars: buffer sizing accounts for 3-byte box/block characters
- Double shutdown in headless: guarded with `stopped` flag
- Shutdown timeout: force-stop after 1000 drain iterations

**Test checkpoints passed** (from Phase 7):
- Phase 1 — `zig build test-desk-tui`: passed
- Phase 2 — `zig build test-desk-headless`: passed
- Phase 3 — `zig build test-desk-tui`: passed
- Phase 4 — `zig build test-desk-tui`: passed
- Phase 5 — `zig build test-desk-tui`: passed

## Implementation approach

The work was split into 5 phases executed across 4 parallel worktrees:

1. **Engine extraction + candle pipeline**: Added `CandleUpdate` message type, wired `BarAggregator` into engine with BBO midpoint aggregation, renamed executable `desk` → `desk-tui` with backward-compat aliases
2. **Headless executable**: Created `headless_main.zig` with `HeadlessDesk` struct (push/pop/shutdown API, engine thread management, double-shutdown guard), 3 inline tests
3. **Renderer + themes**: Created `theme.zig` with 3 presets, added `writeColor`/`writeBgColor`/`resetColor`/`drawBoxThemed` to renderer, updated all 5 panels to accept theme parameter, replaced hardcoded ANSI with theme colors
4. **Candlestick chart**: Created `chart_panel.zig` with OHLC rendering (scaleY, drawCandle helpers), updated layout (positions→chart), added `toggle_positions` action with 'p' key, reduced tab cycle 4→3
5. **Visual polish**: Added sparkline/depthBar helpers to orderbook panel, frame-based flash highlights on orders, lerpColor fade animation on status messages, wired BBO history and frame counter

One minor deviation: `snapshotBook` was made `pub` in Phase 1 to allow inline test access — minimal, non-breaking change.

## Exceptions and deviations

- Phase 1: `snapshotBook` made `pub` for test access — minor visibility change, no behavioral impact

## How to verify

### Automated
- [ ] `zig build test-desk-tui` — all TUI tests pass
- [ ] `zig build test-desk-headless` — all headless tests pass

### Manual
- [ ] Run `zig build run-desk-tui` — verify Unicode box drawing, colored themes, candlestick chart in top-right panel
- [ ] Press `p` to toggle positions overlay on/off
- [ ] Press `Tab` to cycle through 3 panels (orderbook → order entry → orders)
- [ ] Observe sparklines in orderbook panel header
- [ ] Observe depth bars next to bid/ask levels
- [ ] Watch for flash highlights on new order fills
- [ ] Watch status message fade over ~3 seconds
- [ ] Run `zig build run-desk-headless` — verify it runs without terminal, prints event count, exits cleanly
- [ ] Verify backward-compat aliases work: `zig build build-desk`, `zig build run-desk`, `zig build test-desk`

## Breaking changes / migration notes

- Executable renamed from `desk` to `desk-tui`. Backward-compat aliases (`build-desk`, `run-desk`, `test-desk`) are provided.
- All panel `draw()` signatures gained a `theme` parameter — internal API only, no external consumers.
- `Panels.positions` field renamed to `Panels.chart` in layout.zig — internal only.
- Tab cycle reduced from 4 to 3 panels (positions panel replaced by chart; positions available via 'p' overlay).

## Changelog entry

Add headless engine API for programmatic trading and overhaul TUI with candlestick charts, Unicode rendering, true color themes, sparklines, depth bars, and animations
