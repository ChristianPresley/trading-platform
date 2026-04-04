---
phase: 3
iteration: 01
generated: 2026-04-04
---

# Design: Enhanced Candlestick Chart

Research: .claude/specs/enhanced-candlestick-chart/02-research-01.md

## Current State

The chart panel (`trading/desk/panels/chart_panel.zig:27-76`) renders candlesticks at 1-cell-per-row vertical resolution using `│` for wicks and `█` for bodies. Each candle occupies 3 terminal columns with wick and body drawn in the center column only (`chart_panel.zig:49`). The `scaleY()` function at `chart_panel.zig:14-23` maps price to terminal row with no sub-cell precision.

Candle history is stored as a fixed `[2][64]CandleUpdate` array in `main.zig:77-78` — 64 candles max per instrument, no scroll or zoom capability. Volume data flows through the full pipeline (BarAggregator → CandleUpdate at `messages.zig:72` → `main.zig:186`) but is never rendered.

The theme provides only `candle_bull` and `candle_bear` colors at `theme.zig:23-24`. Y-axis labels show whole numbers only, no decimal places (`chart_panel.zig:133-138`), with 10 columns reserved from the right edge (`chart_panel.zig:126`).

Sub-cell rendering exists in orderbook sparklines using 8-level half-block characters (`orderbook_panel.zig:27-38`) but these are private to that module. No shared rendering primitives exist.

Input supports arrows and basic keys (`input.zig:4-18`) but has no zoom, scroll, or crosshair bindings. The `seq_buf` at `input.zig:28` is allocated but unused.

## Desired End State

A candlestick chart with:
- **2x vertical resolution** using half-block characters, with visually distinct wicks (1-col, dimmed) and bodies (3-col, solid)
- **Volume bars** in the bottom ~25% of the chart panel, aligned with candles
- **SMA indicator** overlaid on the price chart, with a lightweight indicator framework for adding more
- **512-candle history** with viewport scrolling (←→) and zoom (+/- changing candle width between 1, 3, 5 columns)
- **Crosshair mode** toggled with 'c' — vertical highlight line with OHLCV data readout
- **Decimal Y-axis labels** showing 2 decimal places
- **4 new theme colors** for volume, indicator lines, crosshair, and grid

## Patterns to Follow

- **Half-block sparkline rendering**: found at `orderbook_panel.zig:27-38` in research — 8-level lower-block characters (`▁▂▃▄▅▆▇█`) for sub-cell vertical precision. Extract into shared module and extend with upper-half-block (`▀`) for body boundary compositing via fg/bg colors.

- **Ring buffer circular storage**: found at `main.zig:77-78, 186` in research — `slot = candle_counts[idx] % 64` pattern. Scale from 64 to 512 with same modulo arithmetic. Fixed-size array, zero allocation, deterministic.

- **Action enum extension**: found at `input.zig:4-18` in research — add new variants (`zoom_in`, `zoom_out`, `toggle_crosshair`), add key mappings in `feed()`, add dispatch cases in `processAction()`. Established 3-step pattern.

- **Context-dependent action dispatch**: found at `main.zig:332-336` in research — `arrow_up/down` only active in order entry panel. Same pattern for scroll: `arrow_left/right` controls chart viewport when chart panel is focused.

- **ANSI cursor positioning + true-color**: found at `renderer.zig:168-176` and `chart_panel.zig:60,66,72` in research — `\x1b[{row};{col}H` for positioning, `\x1b[38;2;{r};{g};{b}m` for fg color, `\x1b[48;2;{r};{g};{b}m` for bg color. Fg+bg compositing enables two half-block "pixels" per cell with different colors.

- **Fixed-point price arithmetic**: found at `chart_panel.zig:133-138` in research — prices as `i64` with 8 decimal places. Extend formatting to show 2 decimals: `divTrunc` for whole, `@mod / 1_000_000` for fractional.

## Patterns to Avoid

- **Single-column candle rendering**: found at `chart_panel.zig:49` in research — current code draws wick and body in the same center column, making them visually indistinguishable. Bodies should span all 3 columns while wicks remain in the center column only.

- **Whole-number-only price labels**: found at `chart_panel.zig:133-138` in research — `bufPrint("{d}", .{whole})` drops all decimal precision. For crypto prices, this loses significant information (e.g., BTC 98234 vs 98234.75).

- **Private character constants**: found at `orderbook_panel.zig:27-38` in research — `SPARKLINE_CHARS` and `DEPTH_CHARS` are private `const` arrays, not importable. Shared rendering characters should live in a common module.

- **Runtime allocation for history buffers**: the existing `SpscRingBuffer` at `main.zig:53-55` uses allocator-backed storage. For candle history, prefer compile-time-sized arrays to maintain deterministic latency with zero allocation.

## Resolved Design Decisions

| Decision | Choice | Reason |
| --- | --- | --- |
| Rendering technique | Half-block characters (▄▀█) | 2x vertical resolution, proven in codebase sparklines, universal terminal compatibility |
| Wick vs body distinction | 1-col wicks (center), 3-col bodies, dimmed wick color | Visual differentiation without needing Braille; fg/bg compositing at boundaries |
| Half-cell wick tips | ▀/▄ at wick extremes | High and low prices get same 2x precision as body edges |
| Volume layout | Internal 75/25 split within chart Rect | No layout.zig changes needed; perfect candle-volume x-alignment |
| Candle history size | [512]CandleUpdate per instrument | ~83KB, covers ~8.5 hours at 1-min bars, power-of-2 for modulo, deterministic |
| Zoom mechanism | Variable candle width: 1, 3, or 5 columns | Width 1 = max density, 3 = default, 5 = detail view; visible candles = panel_width / candle_width |
| Scroll mechanism | viewport_offset into ring buffer, auto-follow at right edge | Left/right arrows shift offset; snaps to newest when at edge |
| Indicators | SMA-20 first, lightweight indicator framework | Framework: struct with compute fn pointer + period + color; SMA computed on-the-fly from candle buffer |
| Crosshair | Vertical line + OHLCV text readout, toggle with 'c' | Data readout is the primary value; vertical-only avoids clutter in small terminal |
| Keybindings | Chart-context: ←→ scroll, +/- zoom, 'c' crosshair | Reuses existing per-panel dispatch pattern; no conflicts with order entry |
| Shared rendering code | New chart_primitives.zig module | Houses half-block chars, sub-cell scaleY, indicator framework types |
| Theme additions | volume, indicator_line, crosshair, grid colors | Near-zero cost (4×Rgb); avoids future Theme struct changes |
| Y-axis precision | 2 decimal places | Essential for crypto price precision; fits within existing 10-col label reserve |

## Approach

**Phase 1 — Shared primitives and theme foundation.** Create `trading/desk/panels/chart_primitives.zig` containing: the half-block character array (8 levels), a `SubCell` type representing sub-cell coordinates, a `scaleYSub()` function that maps price to sub-cell position (doubling effective resolution), and the `Indicator` struct (name, period, color, compute function pointer). Add 4 new color fields (`volume`, `indicator_line`, `crosshair`, `grid`) to the `Theme` struct in `theme.zig` with appropriate values for all 3 themes. Implement `smaCompute()` as the first indicator.

**Phase 2 — History expansion and viewport state.** Expand `candle_history` in `main.zig` from `[2][64]` to `[2][512]`. Add `viewport_offset: usize` and `candle_width: u8 = 3` state variables. Update the circular buffer slot calculation for the new size. Modify `chart_panel.draw()` signature to accept viewport parameters. Pass volume data through to the chart panel (currently omitted at `main.zig:222`).

**Phase 3 — Enhanced candlestick rendering.** Rewrite `drawCandle()` to use half-block characters with sub-cell precision. Bodies span 3 columns (using `scaleYSub` for top/bottom boundaries), wicks span 1 column (center) with dimmed color variant. Use fg/bg color compositing at half-block cell boundaries. Wick tips use ▀/▄ for half-cell precision at high/low extremes. Add the internal 75/25 split: compute `chart_h` and `volume_h` from the panel's inner height, render volume bars below candles using the same half-block sparkline approach with the `volume` theme color.

**Phase 4 — Zoom, scroll, crosshair, and indicators.** Add `zoom_in`, `zoom_out`, `toggle_crosshair` variants to the `Action` enum in `input.zig` with key mappings (+/-, 'c'). In `processAction()`, handle zoom by cycling `candle_width` through 1→3→5→1, and scroll by adjusting `viewport_offset` with bounds clamping. Implement crosshair mode: track `crosshair_active: bool` and `crosshair_idx: usize` state, render vertical line in crosshair color, display OHLCV data for selected candle. Render SMA-20 overlay using the indicator framework — one half-block dot per candle column at the computed SMA price level in `indicator_line` color. Fix Y-axis labels to show 2 decimal places.

## Open Questions

(None — all decisions resolved during design discussion.)
