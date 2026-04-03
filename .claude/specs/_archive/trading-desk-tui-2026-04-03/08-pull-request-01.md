---
phase: 8
iteration: 01
generated: 2026-04-03
---

PR Title: Add trading desk TUI with live orderbook, order entry, and demo mode

Closes: #26

## What problem does this solve?

The trading platform monorepo has a complete SDK (orderbook, OMS, positions, risk), exchange integrations (Kraken spot + futures), and trading strategies -- but no way to run them. There is no executable target in the entire repository. This PR adds the first runnable application: a terminal-based trading desk that ties together the existing domain modules into an interactive demo that works out of the box with zero configuration.

## User-facing changes

- New executable: `zig build run-desk` launches an interactive terminal trading desk
- Five-panel TUI: orderbook (bid/ask with color), positions, order entry, recent orders, status bar
- Demo mode with synthetic market data (BTC-USD, ETH-USD random-walk orderbooks)
- Keyboard interaction: Tab between panels, type quantity/price, Enter to submit orders
- Instrument switching: press '1' for BTC-USD, '2' for ETH-USD
- VS Code integration: Build Desk, Run Desk, Test Desk tasks and Debug Desk launch config

## Implementation summary

**Key design decisions** (from Phase 3):
- **Dual-thread architecture**: engine thread owns all domain state, TUI thread owns rendering. Communication via two SpscRingBuffers (engine->TUI for state snapshots, TUI->engine for user commands). No shared mutable state.
- **Fixed-size message types**: All ring buffer payloads (EngineEvent, UserCommand) are value-type tagged unions with fixed-size fields (InstrumentId uses [32]u8, OrderbookSnapshot uses [20]PriceLevel arrays). No heap pointers cross the thread boundary.
- **Single-write rendering**: Renderer builds entire frame in a memory buffer, then writes to stdout in one syscall to eliminate flicker.
- **Demo-first**: SyntheticFeed generates random-walk L2Book updates. Executors accept null clients for mock mode. No API keys or network needed.

**Edge cases handled** (from Phase 5):
- Terminal restore on exit: deferred deinit restores original termios and exits alternate screen
- Non-terminal stdin: graceful fallback if tcgetattr fails (piped input)
- Small terminals: layout clamps minimum to 80x24, panels skip rendering if too small
- Ring buffer full: engine drops events (latest snapshot always wins)
- Invalid order input: flash message shown, order not submitted
- Escape sequence timeout: partial sequences resolved after 2 frames

**Test checkpoints passed** (from Phase 7):
- Phase 1 -- `zig build run-desk`: passed (output: "Trading Desk v0.1.0")
- Phase 2 -- `zig build test-desk`: passed
- Phase 3 -- `zig build build-desk && zig build test-desk`: passed
- Phase 4 -- `zig build build-desk && zig build test-desk`: passed
- Phase 5 -- `zig build build-desk && zig build test-desk`: passed
- Phase 6 -- `zig build build-desk && zig build test-desk`: passed
- Phase 7 -- `.vscode/tasks.json` exists: passed

## Implementation approach

The desk application lives at `trading/desk/main.zig` with supporting modules under `trading/desk/`. It is the first `b.addExecutable` target in `build.zig` (all prior targets were test-only).

The main thread runs the TUI: raw terminal mode, 15 FPS render loop, non-blocking stdin reads. A second thread runs the engine: synthetic market data generation, order processing, and state snapshotting. The threads communicate exclusively through two `SpscRingBuffer` instances -- one for each direction.

The engine uses the existing `L2Book` from `sdk/domain/orderbook.zig` for orderbook state, driven by a `SyntheticFeed` that applies random-walk price updates. Order submission creates fake order updates (simplified demo mode rather than full OMS/PreTradeRisk/SpotExecutor wiring -- acceptable for v1, the domain module imports are already in build.zig for future integration).

New build modules were added to `build.zig` for SDK core modules (memory, time, ring_buffer, thread) that previously only had anonymous test imports.

## Exceptions and deviations

- The engine uses simplified demo-mode order handling (fake OrderUpdate responses) rather than wiring the full OMS -> PreTradeRisk -> SpotExecutor pipeline. The build.zig imports for all domain modules are in place for future integration.
- Several Zig 0.13 API quirks required adaptation during implementation: `addExecutable` uses `root_source_file` not `root_module`, `Sigaction` flags requires `std.mem.zeroes`, `winsize` fields are `ws_row`/`ws_col`.

## How to verify

### Automated
- [ ] `zig build test-desk` -- all desk tests pass
- [ ] `zig build build-desk` -- compiles without errors
- [ ] `zig build test` -- full test suite still passes (desk tests added to main test step)

### Manual
- [ ] Run `zig build run-desk` -- verify 5-panel TUI appears with bordered panels
- [ ] Wait 2-3 seconds -- verify orderbook prices are moving (synthetic data)
- [ ] Press Tab -- verify panel focus cycles (cyan highlight)
- [ ] Press '2' -- verify instrument switches to ETH-USD (status bar + orderbook)
- [ ] Tab to Order Entry, type "1" (qty), arrow down, type "50000" (price), Enter -- verify order appears in Recent Orders
- [ ] Press 'q' -- verify clean exit (terminal restored)

## Breaking changes / migration notes

None. This is purely additive -- no existing code was modified except `build.zig` (new targets and modules appended at the end).

## Changelog entry

Add terminal-based trading desk TUI as the first executable target, with live synthetic orderbook, order entry, and VS Code developer tooling.
