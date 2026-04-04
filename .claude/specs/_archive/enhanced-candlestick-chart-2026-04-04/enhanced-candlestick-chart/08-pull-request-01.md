---
phase: 8
iteration: 01
generated: 2026-04-04
---

PR Title: Add enhanced candlestick chart with half-block rendering, volume, zoom/scroll, crosshair

Closes: #43

## What problem does this solve?

The terminal candlestick chart had limited visual fidelity (1-cell resolution, no wick distinction), no volume display, fixed 64-candle history with no scroll/zoom, and no way to inspect individual candle data. This makes it difficult to analyze price action in the TUI trading desk.

## User-facing changes

- **2x vertical resolution** — candlesticks render with half-block characters (▄▀█), doubling effective vertical precision
- **Distinct wicks and bodies** — bodies span 3 columns in full color, wicks are 1-column center with dimmed color
- **Volume bars** — bottom 25% of chart panel shows volume bars aligned with candles
- **512-candle history** — up from 64, covering ~8.5 hours at 1-min bars
- **Zoom** — `+`/`-` keys cycle candle width through 1, 3, 5 columns
- **Scroll** — `←`/`→` keys scroll through history, auto-follows at right edge
- **Crosshair mode** — `c` toggles vertical crosshair with OHLCV data readout
- **SMA-20 overlay** — simple moving average rendered on the price chart
- **Decimal Y-axis** — price labels now show 2 decimal places
- **4 new theme colors** — volume, indicator_line, crosshair, grid added to all 3 themes

## Implementation summary

**Key design decisions** (from Phase 3):
- Half-block characters (▄▀█) for 2x vertical resolution — proven in existing orderbook sparklines, universal terminal compatibility
- 75/25 internal height split for volume within chart panel — no layout.zig changes needed, perfect candle-volume x-alignment
- [512]CandleUpdate fixed array per instrument — ~83KB, power-of-2 for modulo, zero allocation, deterministic
- Variable candle width (1/3/5 columns) for zoom — width 1 = max density, 3 = default, 5 = detail view
- Viewport offset with auto-follow at right edge — scroll semantics: offset=0 means track newest
- New `chart_primitives.zig` module for shared rendering constants, sub-cell scaling, and indicator framework

**Edge cases handled** (from Phase 5):
- Flat market (y_max == y_min): scaleYSub guard returns height/2, body renders as single half-block at midpoint
- Doji candle (open == close): body_top == body_bot, renders single half-block character
- All volumes zero: max_volume guard prevents division by zero, all bars zero height
- Panel too short (< 8 rows): volume_h = 0, full height for candles
- Crosshair on candle with < 20 data points: SMA returns null, dot not drawn
- Fewer candles than visible: viewport forced to 0, all candles shown
- Zoom change while scrolled: clampViewport adjusts offset to prevent overrun

**Test checkpoints passed** (from Phase 7):
- Phase 1 — `zig build test-desk`: passed
- Phase 2 — `zig build test-desk`: passed
- Phase 3 — `zig build test-desk`: passed
- Phase 4 — `zig build test-desk`: passed

## Implementation approach

Built in 4 sequential phases sharing `chart_panel.zig`:

1. **Primitives + Theme** — extracted half-block characters and sub-cell scaling into `chart_primitives.zig`, added 4 theme colors, rewrote `drawCandle()` with half-block rendering and 2-decimal Y-axis labels
2. **Volume + History** — expanded history to 512, added 75/25 height split and `drawVolumeBar()`, updated `draw()` to 6-param signature with viewport/width params
3. **Zoom + Scroll** — added `zoom_in`/`zoom_out` actions, viewport state per instrument, `visibleCandles()`/`clampViewport()` helpers, auto-follow logic
4. **Crosshair + SMA** — added `toggle_crosshair` action, crosshair vertical line + OHLCV readout with smart positioning, SMA-20 overlay via indicator framework

No deviations from the design were needed.

## Exceptions and deviations

None

## How to verify

### Automated
- [ ] `zig build test-desk` — all chart primitive and viewport tests pass

### Manual
- [ ] Run `zig build run-desk`, verify candlesticks show half-block rendering with distinct wicks/bodies
- [ ] Verify volume bars appear in bottom ~25% of chart panel
- [ ] Press `+`/`-` to cycle zoom levels (1, 3, 5 column widths)
- [ ] Press `←`/`→` to scroll through candle history
- [ ] Press `c` to toggle crosshair, verify OHLCV readout appears
- [ ] Verify SMA-20 line overlays on price chart (visible after 20+ candles)
- [ ] Verify Y-axis labels show 2 decimal places
- [ ] Switch themes and verify new colors (volume, indicator, crosshair, grid) are correct

## Breaking changes / migration notes

None — all changes are additive. Theme struct gains 4 new fields but all 3 theme literals are updated in-place.

## Changelog entry

Add enhanced candlestick chart with half-block rendering, volume bars, zoom/scroll, crosshair with OHLCV readout, and SMA-20 indicator overlay
