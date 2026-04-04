---
phase: 4
iteration: 01
generated: 2026-04-04
---

# Outline: Enhanced Candlestick Chart

Design: .claude/specs/enhanced-candlestick-chart/03-design-01.md

## Overview

Enhance the TUI candlestick chart through 4 vertical slices: first upgrade rendering to half-block precision with theme expansion, then add volume bars and expand history to 512 candles, then wire zoom/scroll interaction, and finally layer on crosshair inspection and SMA indicator overlay. Each phase delivers visible, testable improvements to the running TUI.

## Phase 1: Half-Block Candlestick Rendering + Theme

**Delivers**: Visibly improved candlesticks with 2x vertical resolution, distinct 3-col bodies vs 1-col dimmed wicks, and 2-decimal Y-axis labels
**Layers touched**: Shared primitives (new module), Theme, Chart panel rendering

### Key types / signatures introduced

```zig
// trading/desk/panels/chart_primitives.zig (new)
pub const HALF_BLOCK_CHARS: [8][3]u8;  // ▁▂▃▄▅▆▇█ (lower-block)
pub const UPPER_HALF: [3]u8;           // ▀
pub const FULL_BLOCK: [3]u8;           // █

pub const SubCell = struct {
    row: u16,      // terminal row
    half: u1,      // 0 = top half, 1 = bottom half
};

pub fn scaleYSub(price: i64, min_price: i64, max_price: i64, height: u16) SubCell;

// trading/desk/theme.zig — add to Theme struct
volume: Rgb,
indicator_line: Rgb,
crosshair: Rgb,
grid: Rgb,
```

### Test checkpoint
- Type: Automated
- `zig build test` — unit tests for `scaleYSub()` (boundary mapping, midpoint, flat range), half-block character selection at sub-cell boundaries
- Manual: run TUI, verify candles show 3-col colored bodies with 1-col dimmed wicks, Y-axis shows 2 decimal places

---

## Phase 2: Volume Bars + History Expansion

**Delivers**: Volume sub-panel in bottom ~25% of chart area aligned with candles, 512-candle history capacity
**Layers touched**: Main (history arrays, data passthrough), Chart panel (internal height split, volume rendering)
**Depends on**: Phase 1 (uses half-block primitives for volume bar rendering, `volume` theme color)

### Key types / signatures introduced

```zig
// trading/desk/main.zig — expand storage
var candle_history: [2][512]CandleUpdate = undefined;  // was [2][64]

// trading/desk/panels/chart_panel.zig — updated draw signature
pub fn draw(
    renderer: *Renderer,
    rect: layout.Rect,
    candles: []const CandleUpdate,
    theme: Theme,
    viewport_offset: usize,   // 0 for now, wired in Phase 3
    candle_width: u8,          // 3 for now, wired in Phase 3
) void;

// internal to chart_panel.zig
fn drawVolumeBar(renderer: *Renderer, x: u16, y: u16, height: u16, volume: i64, max_volume: i64, color: Rgb) void;
```

### Test checkpoint
- Type: Automated
- `zig build test` — unit tests for volume bar height scaling (zero volume, max volume, proportional), 75/25 height split computation
- Manual: run TUI, verify volume bars appear below candles with correct relative sizing

---

## Phase 3: Zoom + Scroll

**Delivers**: Interactive zoom (1/3/5-column candle widths) and left/right scroll through candle history with auto-follow
**Layers touched**: Input (new actions), Main (viewport state + dispatch), Chart panel (viewport-aware rendering)
**Depends on**: Phase 2 (expanded 512-candle history makes scroll meaningful; draw signature already accepts viewport params)

### Key types / signatures introduced

```zig
// trading/desk/input.zig — add to Action enum
zoom_in,
zoom_out,
// arrow_left/arrow_right already exist — dispatch changes in main.zig

// trading/desk/main.zig — new state
var viewport_offset: [2]usize = .{ 0, 0 };  // per-instrument
var candle_width: u8 = 3;                     // shared across instruments

// trading/desk/panels/chart_panel.zig
fn visibleCandles(panel_width: u16, candle_width: u8) usize;
fn clampViewport(offset: usize, visible: usize, total: usize) usize;
```

### Test checkpoint
- Type: Automated
- `zig build test` — unit tests for `visibleCandles()` calculation at each zoom level, `clampViewport()` bounds clamping (at edges, beyond bounds, auto-follow behavior)
- Manual: run TUI, press +/- to cycle zoom levels, ←→ to scroll, verify auto-follow when new candles arrive at right edge

---

## Phase 4: Crosshair + SMA Indicator

**Delivers**: Crosshair mode with vertical highlight line and OHLCV data readout, SMA-20 overlay rendered on price chart
**Layers touched**: Shared primitives (indicator framework), Input (new action), Main (crosshair state), Chart panel (crosshair + SMA rendering)
**Depends on**: Phase 3 (crosshair indexes into viewport, SMA rendering uses zoom-aware x-positioning)

### Key types / signatures introduced

```zig
// trading/desk/panels/chart_primitives.zig — indicator framework
pub const Indicator = struct {
    name: [16]u8,
    name_len: u8,
    period: u16,
    color: Rgb,
    compute: *const fn (candles: []const CandleUpdate, index: usize, period: u16) ?i64,
};

pub fn smaCompute(candles: []const CandleUpdate, index: usize, period: u16) ?i64;

// trading/desk/input.zig — add to Action enum
toggle_crosshair,

// trading/desk/main.zig — new state
var crosshair_active: bool = false;
var crosshair_idx: [2]usize = .{ 0, 0 };  // per-instrument cursor position
```

### Test checkpoint
- Type: Automated
- `zig build test` — unit tests for `smaCompute()` (exact values, insufficient data returns null, period boundary), indicator framework compute dispatch
- Manual: run TUI, press 'c' to toggle crosshair, ←→ to move cursor, verify OHLCV readout updates; verify SMA-20 line visible on chart

---

## Dependencies
- Phase 2 must complete before Phase 3 because: scroll requires expanded 512-candle history to be meaningful, and the `draw()` signature with viewport params is established in Phase 2
- Phase 3 must complete before Phase 4 because: crosshair indexes into the viewport (needs `viewport_offset` and `candle_width` state), and SMA overlay rendering must account for zoom-aware x-positioning
- Phase 1 must complete before Phase 2 because: volume bar rendering uses half-block primitives and the `volume` theme color from Phase 1
- Partial parallelism possible: Phase 2's history expansion in `main.zig` is independent of Phase 1, but Phase 2's volume rendering depends on Phase 1's primitives
