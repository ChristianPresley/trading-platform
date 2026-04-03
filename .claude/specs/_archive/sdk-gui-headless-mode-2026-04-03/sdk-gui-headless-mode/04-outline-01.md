---
phase: 4
iteration: 01
generated: 2026-04-03
---

# Outline: SDK GUI + Headless Mode

Design: .claude/specs/sdk-gui-headless-mode/03-design-01.md

## Overview

Extract the engine into a shared module to enable separate TUI and headless executables, then enhance the TUI with Unicode rendering, a theme system, candlestick charts, sparklines, and depth visualization. The implementation follows a 5-phase vertical slice strategy with two parallelization points: Phases 2+3 after Phase 1, and Phases 4+5 after Phase 3.

## Phase 1: Engine Module Extraction + Candle Pipeline
**Delivers**: Shared engine module importable by multiple executables; `desk-tui` executable identical in behavior to current `desk`; candle events flowing through ring buffer
**Layers touched**: build.zig, messages.zig, engine.zig, main.zig (rename to desk-tui)

### Key types / signatures introduced
```zig
// messages.zig — new variant added to EngineEvent union
pub const CandleUpdate = struct {
    instrument: InstrumentId,
    open: i64,
    high: i64,
    low: i64,
    close: i64,
    volume: i64,
    timestamp: u64,
};

// EngineEvent union gains:
candle_update: CandleUpdate,
```

### Test checkpoint
- Type: Automated
- `zig build test-desk-tui` — all existing desk tests pass under the renamed executable
- Inline test in engine.zig verifying candle events are produced and pushed to ring buffer after sufficient ticks

---

## Phase 2: Headless Executable
**Delivers**: `desk-headless` binary that runs the engine without any terminal dependency; usable for integration testing and programmatic algo control
**Layers touched**: build.zig, new trading/desk/headless_main.zig
**Depends on**: Phase 1

### Key types / signatures introduced
```zig
// headless_main.zig — public API surface
pub const HeadlessDesk = struct {
    to_engine: *SpscRingBuffer(UserCommand),
    from_engine: *SpscRingBuffer(EngineEvent),
    engine_thread: std.Thread,

    pub fn init(allocator: Allocator) HeadlessDesk;
    pub fn push(self: *HeadlessDesk, cmd: UserCommand) bool;
    pub fn pop(self: *HeadlessDesk) ?EngineEvent;
    pub fn shutdown(self: *HeadlessDesk) void;
};
```

### Test checkpoint
- Type: Automated
- `zig build test-desk-headless` — test creates HeadlessDesk, verifies tick events arrive via pop(), sends UserCommand.quit, receives EngineEvent.shutdown_ack, clean thread join

---

## Phase 3: Renderer Enhancement + Theme System
**Delivers**: Unicode box drawing, 24-bit true color, and a theme system applied to all existing panels — visually upgraded TUI with no functional changes
**Layers touched**: renderer.zig, new theme.zig, orderbook_panel.zig, positions_panel.zig, orders_panel.zig, status_panel.zig, order_entry_panel.zig
**Depends on**: Phase 1

### Key types / signatures introduced
```zig
// theme.zig
pub const Rgb = struct { r: u8, g: u8, b: u8 };

pub const Theme = struct {
    bid: Rgb,
    ask: Rgb,
    spread: Rgb,
    border: Rgb,
    title: Rgb,
    text: Rgb,
    text_dim: Rgb,
    active_field: Rgb,
    status_ok: Rgb,
    status_error: Rgb,
    candle_bull: Rgb,
    candle_bear: Rgb,
    background: Rgb,
};

pub const dark: Theme;
pub const light: Theme;
pub const classic_green: Theme;

// renderer.zig — new methods
pub fn writeColor(self: *Renderer, color: Rgb) void;
pub fn writeBgColor(self: *Renderer, color: Rgb) void;
pub fn resetColor(self: *Renderer) void;
// drawBox() updated to use Unicode │─┌┐└┘├┤┬┴┼

// All panel draw signatures gain theme parameter:
// pub fn draw(renderer: *Renderer, rect: Rect, data: *const T, theme: *const Theme) void
```

### Test checkpoint
- Type: Automated
- `zig build test-desk-tui` — inline tests for Theme field access, renderer Unicode box output bytes, renderer color sequence output
- All existing panel tests updated and passing with theme parameter

---

## Phase 4: Candlestick Chart + Layout Restructure
**Delivers**: OHLC candlestick chart in top-right panel, positions summary in status bar, 'p' hotkey for full positions overlay
**Layers touched**: new chart_panel.zig, layout.zig, status_panel.zig, input.zig, main.zig
**Depends on**: Phase 1 (candle data), Phase 3 (theme colors)

### Key types / signatures introduced
```zig
// chart_panel.zig
pub fn draw(renderer: *Renderer, rect: Rect, candles: []const CandleUpdate, theme: *const Theme) void;

// Internal helpers (not public):
// scaleY(price: i64, min: i64, max: i64, height: u16) u16
// drawCandle(renderer, x: u16, rect: Rect, candle: CandleUpdate, y_min: i64, y_max: i64, theme) void

// input.zig — Action union gains:
toggle_positions,  // 'p' key

// layout.zig — Panels struct updated:
// .positions field removed, .chart field added (top-right)
// positions overlay computed separately when toggled
```

### Test checkpoint
- Type: Automated
- `zig build test-desk-tui` — inline tests: chart_panel renders known OHLC data to expected buffer output (body chars, wick chars, colors); layout.zig tests updated for chart rect in top-right; input.zig test for 'p' → toggle_positions action

---

## Phase 5: Sparklines, Depth Visualization + Animations
**Delivers**: BBO sparklines and depth bars in orderbook panel, fill/reject flash highlights in orders panel, status message fade animation
**Layers touched**: orderbook_panel.zig, orders_panel.zig, status_panel.zig, renderer.zig
**Depends on**: Phase 3 (theme colors)

### Key types / signatures introduced
```zig
// orderbook_panel.zig — draw signature extended:
pub fn draw(renderer: *Renderer, rect: Rect, snapshot: *const OrderbookSnapshot, history: []const i64, theme: *const Theme) void;
// history: ring buffer of recent BBO midpoints for sparkline

// Internal helpers:
// sparkline(values: []const i64, width: u16) []const u8  — maps to ▁▂▃▄▅▆▇█
// depthBar(quantity: i64, max_quantity: i64, width: u16) []const u8  — maps to ░▒▓█

// orders_panel.zig — draw signature extended:
pub fn draw(renderer: *Renderer, rect: Rect, orders: []const OrderUpdate, frame_count: u64, theme: *const Theme) void;
// frame_count used for flash animation timing (highlight rows where age < 3 frames)

// status_panel.zig — fade support:
pub fn draw(renderer: *Renderer, rect: Rect, status: *const StatusUpdate, msg_age_frames: u32, theme: *const Theme) void;
// msg_age_frames drives brightness interpolation over 45 frames
```

### Test checkpoint
- Type: Automated
- `zig build test-desk-tui` — inline tests: sparkline quantization maps values to correct Unicode block chars; depth bar scales correctly to max quantity; orders panel flash logic (age < 3 → highlighted, age >= 3 → normal)
- Type: Manual
- Visual verification: run `zig build run-desk-tui`, confirm sparklines animate with price movement, depth bars scale with quantity, fills flash briefly

## Dependencies
- Phase 2 must complete after Phase 1 because: headless imports the extracted engine module
- Phase 3 must complete after Phase 1 because: renderer/theme changes apply to desk-tui (renamed in Phase 1)
- Phase 4 must complete after Phases 1 + 3 because: chart panel needs candle data (Phase 1) and theme colors (Phase 3)
- Phase 5 must complete after Phase 3 because: sparklines/depth/animations need theme colors
- Phases 2 and 3 are independent (parallelizable after Phase 1)
- Phases 4 and 5 are independent (parallelizable after Phase 3)
