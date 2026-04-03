---
phase: 4
iteration: 01
generated: 2026-04-03
---

# Outline: Trading Desk TUI Application

Design: .claude/specs/trading-desk-tui/03-design-01.md

## Overview

Build the first executable target in the trading platform monorepo — a terminal-based trading desk in pure Zig. The implementation proceeds in seven vertical slices: (1) build system + minimal executable, (2) terminal management, (3) rendering framework with panel layout, (4) dual-thread engine with ring buffer communication, (5) domain integration with synthetic data, (6) keyboard input and order entry, (7) VS Code developer tooling. Each phase produces a runnable binary that demonstrates incremental progress.

---

## Phase 1: Build System and Minimal Executable
**Delivers**: A `zig build run-desk` command that compiles and runs a "hello world" binary from `trading/desk/main.zig`
**Layers touched**: build.zig, trading/desk/main.zig

### Key types / signatures introduced
```zig
// trading/desk/main.zig
pub fn main() !void
```

### Build system additions
- `b.addExecutable(.{ .name = "desk", .root_source_file = b.path("trading/desk/main.zig") })` — first executable target in the repo
- Build steps: `run-desk`, `build-desk`, `build-desk-release`, `test-desk`
- Wire SDK module imports (orderbook, oms, positions, risk, memory, time, containers, thread) for use in later phases

### Test checkpoint
- Type: Automated
- `zig build run-desk` prints a message and exits 0
- `zig build test-desk` passes (empty test block)

---

## Phase 2: Terminal Management
**Delivers**: Binary enters raw mode, switches to alternate screen, displays a static message, waits for 'q' keypress, then cleanly restores the terminal
**Layers touched**: trading/desk/terminal.zig, trading/desk/main.zig
**Depends on**: Phase 1

### Key types / signatures introduced
```zig
// trading/desk/terminal.zig
pub const Terminal = struct {
    pub fn init() !Terminal               // tcgetattr, set raw mode, enter alternate screen
    pub fn deinit(self: *Terminal) void    // restore original termios, exit alternate screen
    pub fn getSize() !Size                // ioctl TIOCGWINSZ
    pub fn readByte(self: *Terminal) ?u8   // non-blocking stdin read via poll()
    pub fn writer(self: *Terminal) Writer  // stdout writer
};
pub const Size = struct { rows: u16, cols: u16 };
```

### Test checkpoint
- Type: Manual
- `zig build run-desk` enters alternate screen, shows "Trading Desk — press q to quit", pressing 'q' exits cleanly with terminal restored
- `zig build test-desk` passes unit tests for Terminal (test raw mode flag manipulation on a mock fd)

---

## Phase 3: Rendering Framework and Panel Layout
**Delivers**: Binary renders a five-panel layout with box-drawing borders and placeholder text at a fixed frame rate, resizable with terminal
**Layers touched**: trading/desk/renderer.zig, trading/desk/layout.zig, trading/desk/main.zig
**Depends on**: Phase 2

### Key types / signatures introduced
```zig
// trading/desk/renderer.zig
pub const Renderer = struct {
    pub fn init(allocator: std.mem.Allocator, terminal: *Terminal) !Renderer
    pub fn deinit(self: *Renderer) void
    pub fn beginFrame(self: *Renderer) void           // reset frame buffer
    pub fn drawBox(self: *Renderer, rect: Rect, title: []const u8) void
    pub fn drawText(self: *Renderer, x: u16, y: u16, text: []const u8) void
    pub fn drawTextFmt(self: *Renderer, x: u16, y: u16, comptime fmt: []const u8, args: anytype) void
    pub fn endFrame(self: *Renderer) !void             // single write() to stdout
};
pub const Rect = struct { x: u16, y: u16, w: u16, h: u16 };

// trading/desk/layout.zig
pub const Layout = struct {
    pub fn compute(terminal_size: Size) Panels
};
pub const Panels = struct {
    orderbook: Rect,
    positions: Rect,
    order_entry: Rect,
    recent_orders: Rect,
    status_bar: Rect,
};
```

### Test checkpoint
- Type: Manual + Automated
- `zig build run-desk` displays five bordered panels with placeholder titles at ~15 FPS; resizing the terminal reflows the layout; 'q' exits cleanly
- `zig build test-desk` passes unit tests for Layout.compute (given known Size, verify Rect positions) and Renderer buffer logic

---

## Phase 4: Engine Thread and Ring Buffer Communication
**Delivers**: Dual-thread architecture running — engine thread sends tick counter via SpscRingBuffer, TUI thread displays it in the status bar, proving cross-thread communication works
**Layers touched**: trading/desk/engine.zig, trading/desk/messages.zig, trading/desk/main.zig
**Depends on**: Phase 3

### Key types / signatures introduced
```zig
// trading/desk/messages.zig
pub const EngineEvent = union(enum) {
    tick: u64,
    orderbook_snapshot: OrderbookSnapshot,
    position_update: PositionUpdate,
    order_update: OrderUpdate,
    status: StatusUpdate,
    shutdown_ack: void,
};
pub const UserCommand = union(enum) {
    quit: void,
    select_instrument: []const u8,
    submit_order: OrderRequest,
    cancel_order: u64,
};
pub const OrderbookSnapshot = struct { ... };
pub const PositionUpdate = struct { ... };
pub const OrderUpdate = struct { ... };
pub const OrderRequest = struct { ... };
pub const StatusUpdate = struct { ... };

// trading/desk/engine.zig
pub const Engine = struct {
    pub fn init(allocator: std.mem.Allocator, to_tui: *RingBuffer(EngineEvent), from_tui: *RingBuffer(UserCommand)) !Engine
    pub fn deinit(self: *Engine) void
    pub fn run(self: *Engine) void    // entry point for engine thread; loops until quit
};
```

### Test checkpoint
- Type: Manual + Automated
- `zig build run-desk` shows a live tick counter incrementing in the status bar (proves engine thread is running and ring buffer is delivering events)
- `zig build test-desk` passes unit tests for message serialization and Engine init/deinit

---

## Phase 5: Domain Integration and Synthetic Data
**Delivers**: Live demo mode — orderbook panel shows moving bid/ask levels, positions panel shows holdings, recent orders panel shows order history, all driven by synthetic data from the engine thread
**Layers touched**: trading/desk/engine.zig, trading/desk/synthetic.zig, trading/desk/panels/*.zig, trading/desk/main.zig
**Depends on**: Phase 4

### Key types / signatures introduced
```zig
// trading/desk/synthetic.zig
pub const SyntheticFeed = struct {
    pub fn init(allocator: std.mem.Allocator, instruments: []const []const u8) !SyntheticFeed
    pub fn deinit(self: *SyntheticFeed) void
    pub fn tick(self: *SyntheticFeed) void    // advance prices by one random-walk step
    pub fn getBook(self: *SyntheticFeed, instrument: []const u8) ?*const L2Book
};

// trading/desk/panels/orderbook_panel.zig
pub fn draw(renderer: *Renderer, rect: Rect, snapshot: *const OrderbookSnapshot) void

// trading/desk/panels/positions_panel.zig
pub fn draw(renderer: *Renderer, rect: Rect, positions: []const PositionUpdate) void

// trading/desk/panels/orders_panel.zig
pub fn draw(renderer: *Renderer, rect: Rect, orders: []const OrderUpdate) void

// trading/desk/panels/status_panel.zig
pub fn draw(renderer: *Renderer, rect: Rect, status: *const StatusUpdate) void
```

### Engine integration
- Engine.init wires up: L2Book, OrderManager, PositionManager, PreTradeRisk, SpotExecutor (null clients)
- Engine.run loop: SyntheticFeed.tick() -> snapshot L2Book -> push EngineEvent.orderbook_snapshot
- Instruments: BTC-USD, ETH-USD (hardcoded for demo)

### Test checkpoint
- Type: Manual + Automated
- `zig build run-desk` shows a live orderbook with moving prices, position panel, and order history — all synthetic
- `zig build test-desk` passes unit tests for SyntheticFeed (deterministic seed produces expected price sequence) and panel draw functions (verify output contains expected content)

---

## Phase 6: Input Handling and Order Entry
**Delivers**: Full interactive trading desk — user can Tab between panels, type in the order entry form, submit orders with Enter, cancel orders, and switch instruments
**Layers touched**: trading/desk/input.zig, trading/desk/panels/order_entry_panel.zig, trading/desk/main.zig, trading/desk/engine.zig
**Depends on**: Phase 5

### Key types / signatures introduced
```zig
// trading/desk/input.zig
pub const InputHandler = struct {
    pub fn init() InputHandler
    pub fn feed(self: *InputHandler, byte: u8) ?Action
};
pub const Action = union(enum) {
    tab: void,
    shift_tab: void,
    arrow_up: void,
    arrow_down: void,
    enter: void,
    escape: void,
    char: u8,
    backspace: void,
    quit: void,          // Ctrl+C or 'q' when not in text field
};

// trading/desk/panels/order_entry_panel.zig
pub const OrderEntryPanel = struct {
    pub fn init() OrderEntryPanel
    pub fn handleAction(self: *OrderEntryPanel, action: Action) ?UserCommand
    pub fn draw(self: *const OrderEntryPanel, renderer: *Renderer, rect: Rect, active: bool) void
};
```

### Test checkpoint
- Type: Manual + Automated
- `zig build run-desk` — user can Tab to order entry, type quantity/price, press Enter to submit; order appears in recent orders panel with status updates from mock executor
- `zig build test-desk` passes unit tests for InputHandler (byte sequences map to correct Actions) and OrderEntryPanel (action sequences produce correct UserCommands)

---

## Phase 7: VS Code Integration
**Delivers**: VS Code tasks.json and launch.json for build, run, test, and debug workflows
**Layers touched**: .vscode/tasks.json, .vscode/launch.json
**Depends on**: Phase 1 (build steps must exist)

### Files created
```jsonc
// .vscode/tasks.json — tasks: Build Desk, Build Desk (Release), Run Desk, Test Desk
// .vscode/launch.json — debug config: Debug Desk (lldb, desk executable)
```

### Test checkpoint
- Type: Manual
- Open VS Code, run "Build Desk" task (Ctrl+Shift+B), verify it compiles
- Run "Debug Desk" launch config (F5), verify breakpoints work in main.zig

---

## Dependencies

- Phase 2 depends on Phase 1: needs the executable target and build steps to exist
- Phase 3 depends on Phase 2: needs Terminal for raw mode and stdout writer
- Phase 4 depends on Phase 3: needs Renderer and Layout to display engine output
- Phase 5 depends on Phase 4: needs Engine thread and ring buffer to deliver domain data
- Phase 6 depends on Phase 5: needs live domain state to make input meaningful (placing orders against the synthetic orderbook)
- Phase 7 is independent of Phases 2-6 (only needs Phase 1 build steps) but is sequenced last because it is lowest priority and benefits from the final build step names being stable
