---
phase: 3
iteration: 01
generated: 2026-04-03
---

# Design: Trading Desk TUI Application

Research: .claude/specs/trading-desk-tui/02-research-01.md

## Current State

The codebase is a pure-Zig trading platform with a complete SDK layer and Kraken exchange integration, but **no application entry point** — `build.zig` contains zero `b.addExecutable` calls (research: build.zig has 972 lines, only test steps and modules). All code exists as libraries exercised through test targets.

**Domain modules available for consumption:**
- `L2Book` — sorted bid/ask arrays with O(1) BBO, `midPrice()`, `spread()` (research: `orderbook.zig:24-155`)
- `OrderManager` — full order lifecycle with state machine, risk injection, event store injection (research: `oms.zig:171-289`)
- `PositionManager` — FIFO/LIFO/avg cost basis tracking with realized/unrealized P&L (research: `positions.zig:64-257`)
- `PreTradeRisk` — size, notional, position, rate, and price band checks (research: `pre_trade.zig:59-89`)
- `SpotExecutor` / `FuturesExecutor` — exchange routing with built-in mock mode when all clients are null (research: `executor.zig:67-169`, `futures/executor.zig:69-142`)

**Infrastructure available:**
- `SpscRingBuffer(T)` — lock-free SPSC ring buffer with atomic acquire/release (research: `ring_buffer.zig:4-46`)
- `MpscQueue(T)` — lock-free MPSC intrusive queue (research: `mpsc_queue.zig:5-66`)
- `PoolAllocator` — fixed-slot slab with O(1) alloc/free (research: `memory.zig:6-90`)
- `ArenaAllocator` — bump allocator with reset (research: `memory.zig:93-111`)
- `spawnPinned` — CPU-affinity thread spawning (research: `thread.zig:37`)
- `Timestamp` — monotonic and wall-clock time with RFC 3339 formatting (research: `time.zig:3-59`)
- `EventLoop` — io_uring-based event loop, Linux-only, blocking (research: `event_loop.zig:21-102`)

**No existing TUI code, no event bus, no central message dispatcher.** Modules communicate via direct function calls (research: cross-cutting observations).

**VS Code workspace** exists but has no tasks.json or launch.json (research: `trading-platform.code-workspace:1-7`).

## Desired End State

A runnable trading desk terminal application at `trading/desk/main.zig` that:

1. Launches into an alternate-screen TUI showing five panels: orderbook, positions, order entry, recent orders, and a status bar.
2. Runs in demo mode out of the box with synthetic market data (no exchange credentials required).
3. Allows the user to place, cancel, and view orders via keyboard interaction.
4. Uses a dual-thread architecture: an engine thread driving market data and order management, and a TUI thread handling rendering and input.
5. Provides VS Code tasks and debug configuration for build/run/test workflows.
6. Is the **first executable target** in the repository's build system.

## Patterns to Follow

- **Allocator injection**: Every domain module accepts `std.mem.Allocator` as first parameter to `init()` (research: `orderbook.zig:24`, `oms.zig:183`, `positions.zig:64`, `pre_trade.zig:59`). The desk app will create allocators at the top level and inject them down.
- **Init/deinit lifecycle**: All structs follow `init() !T` / `deinit(*T) void` (research: `orderbook.zig:24,159`, `oms.zig:183,289`). Every new struct in the desk will follow this pattern.
- **Fixed-point i64 pricing**: All prices and quantities are `i64` throughout the codebase (research: cross-cutting observations). The TUI will format i64 to decimal for display (divide by 10^8 for Kraken's satoshi-scale prices).
- **Null-client mock mode**: Both executors generate synthetic exchange IDs when all client refs are null (research: `executor.zig:86-87,166-168`, `futures/executor.zig:139-141`). Demo mode will pass null for all clients.
- **SpscRingBuffer for cross-thread communication**: Lock-free, single-producer single-consumer, non-blocking push/pop (research: `ring_buffer.zig:4-46`). One buffer engine->TUI, one buffer TUI->engine.
- **spawnPinned for thread management**: CPU-affinity thread spawning already in the codebase (research: `thread.zig:37`). Use for engine thread.
- **Module graph wiring**: `b.createModule()` + `module.addImport()` for inter-module dependencies (research: `build.zig:80-100,108`).

## Patterns to Avoid

- **Direct function calls across threads**: The codebase uses direct calls (e.g., executor calls `oms.onExecution()` — research: `executor.zig:115-169`), but this is unsafe across threads. All cross-thread communication must go through the SpscRingBuffer.
- **Shared mutable state**: The EventLoop uses a shared `read_buf: [65536]u8` (research: `event_loop.zig:27`). The desk will NOT share mutable buffers between threads — each thread owns its data.
- **Raw u128 timestamps**: Some modules use raw `u128` nanoseconds instead of the `Timestamp` struct (research: `oms.zig:66`, `positions.zig:27`). The desk will use `Timestamp` from `time.zig` for all new time values and convert when interfacing with modules that use raw u128.
- **EventLoop for stdin**: The EventLoop is designed for sockets with a single shared read buffer (research: `event_loop.zig:27`). The TUI thread will handle stdin directly via `std.posix.poll()` or blocking reads on its own thread, not through the EventLoop.

## Resolved Design Decisions

| Decision | Choice | Reason |
| --- | --- | --- |
| Architecture | Dual-thread (engine + TUI) | Clean separation of concerns; engine thread owns all domain state, TUI thread owns rendering. SpscRingBuffer provides lock-free communication. |
| Thread communication | Two SpscRingBuffers (bidirectional) | Engine->TUI carries state snapshots; TUI->engine carries user commands. SPSC matches the exactly-two-thread model. |
| TUI rendering | ANSI escape codes + raw terminal mode | Zero dependencies; alternate screen buffer for clean entry/exit. No external TUI library needed. |
| Frame rate | Fixed 15 FPS default (configurable 10-20) | Trading data changes fast enough to warrant smooth updates, but no need for 60 FPS. ~66ms per frame is plenty for terminal rendering. |
| Demo data generation | Synthetic random-walk orderbook + mock executors | Executors already support null-client mode. Synthetic market data generator produces realistic-looking L2Book updates. |
| Layout | 5 panels: orderbook, positions, order entry, recent orders, status bar | Covers the core trading desk workflow: see market, see positions, place orders, track orders. |
| Input model | Keyboard-driven: Tab between panels, arrows navigate, Enter submits | Terminal-native interaction. No mouse support needed for v1. |
| File location | `trading/desk/main.zig` + supporting modules under `trading/desk/` | Follows monorepo convention with `trading/` as the application layer. |
| Build integration | First `b.addExecutable` in build.zig + new build steps | `run-desk`, `build-desk`, `build-desk-release`, `test-desk` steps. |
| VS Code integration | tasks.json + launch.json in `.vscode/` | Build, run, test tasks with Zig problem matchers; debug config for lldb. |
| Price display | Format i64 as decimal with configurable precision | Default 2 decimal places for USD, 8 for BTC. Divide by scale factor. |
| Terminal cleanup | Defer restore of terminal attributes + alternate screen exit | Ensures terminal is always restored on normal exit, panic, or Ctrl+C. |

## Approach

The trading desk is a two-thread application. The **engine thread** owns all domain state: L2Book instances, OrderManager, PositionManager, PreTradeRisk, and (in demo mode) a synthetic market data generator. It runs a tick loop that advances synthetic data, processes any incoming user commands from the TUI->engine ring buffer, and pushes state snapshots into the engine->TUI ring buffer. The engine thread uses `spawnPinned` for optional CPU affinity.

The **TUI thread** runs on the main thread (the one that enters `main()`). It sets up raw terminal mode, switches to the alternate screen buffer, and enters a fixed-rate render loop. Each frame, it drains the engine->TUI ring buffer for the latest state snapshot, renders all five panels using ANSI escape codes written to a frame buffer (single `write()` call to stdout per frame to avoid flicker), reads any pending stdin bytes, parses key sequences, and pushes commands into the TUI->engine ring buffer. The frame loop sleeps to maintain the target FPS using `std.time.sleep()`.

The **message protocol** between threads uses two tagged unions: `EngineEvent` (engine->TUI) carrying orderbook snapshots, position updates, order status changes, and connection status; and `UserCommand` (TUI->engine) carrying order submissions, cancellations, instrument selection, and quit signals. These are value types sized to fit in the SpscRingBuffer without heap allocation.

**Demo mode** is the default and only mode for v1. A `SyntheticFeed` module generates random-walk price movements on a configurable set of instruments, applying them to L2Book instances. The SpotExecutor runs with null clients, generating synthetic fill responses. This means the desk is immediately runnable with `zig build run-desk` — no configuration, no API keys, no network.

**Terminal management** is careful about cleanup. The TUI stores the original termios attributes on startup and defers restoration. A signal handler for SIGINT/SIGTERM ensures the alternate screen is exited and terminal is restored even on abrupt shutdown. The renderer uses a single write buffer per frame — it builds the entire screen in memory, then writes it in one syscall to minimize flicker.

**Build system changes** add the first `b.addExecutable` target to `build.zig`, creating a `desk` executable that imports SDK modules (orderbook, oms, positions, risk, memory, time, containers, thread) and builds from `trading/desk/main.zig`. Four new build steps are added: `run-desk`, `build-desk`, `build-desk-release`, `test-desk`.

## Open Questions

(None — all design decisions resolved.)
