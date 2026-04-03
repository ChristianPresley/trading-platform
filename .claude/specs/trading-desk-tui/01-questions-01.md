---
phase: 1
iteration: 01
generated: 2026-04-03
---

# Research Questions: Trading Desk TUI Application

Source issue: Feature request — build a runnable trading desk application with terminal UI, executable targets, and VS Code dev tasks
Feature slug: trading-desk-tui

## Questions

1. What are the public APIs (struct types, init/deinit signatures, and key methods) exposed by `sdk/domain/orderbook.zig`, `sdk/domain/orderbook_l3.zig`, `sdk/domain/oms.zig`, `sdk/domain/positions.zig`, `sdk/domain/market_data.zig`, and `sdk/domain/risk/pre_trade.zig` that a consuming application would need to instantiate and drive?

2. How does the existing `sdk/core/io/event_loop.zig` work — what is its public API for registering sockets, timers, and running the loop, and what are the constraints of its io_uring-based design (e.g., Linux-only, blocking vs non-blocking)?

3. How does `sdk/core/memory.zig` provide allocation — what allocator types and patterns does it expose, and how do existing modules (OMS, orderbook, positions) obtain their allocators?

4. How do the Kraken exchange executors (`exchanges/kraken/spot/executor.zig` and `exchanges/kraken/futures/executor.zig`) interface with the OMS — what are their public init/submit/cancel signatures, and what callback or event mechanisms do they use to report fills and status changes?

5. How does the existing `build.zig` structure its module graph — what is the pattern for creating modules, wiring inter-module imports (e.g., `addImport`), and registering build steps, and what are the existing named steps (`test`, `test-core`, `test-protocol`, `test-ws`, `test-kraken`)?

6. What terminal I/O primitives does Zig's `std` library provide — specifically `std.posix.tcgetattr`/`tcsetattr` for raw mode, `std.io.getStdIn()`/`getStdOut()` for file descriptors, and `std.os.linux.IoUring` for non-blocking stdin reads — that would be needed to build a TUI without external dependencies?

7. How do the trading strategies (`trading/strategies/basis.zig`, `trading/strategies/funding_arb.zig`) consume orderbook and market data — what types do they import, and what is their interface for receiving updates and emitting signals?

8. What are the public types and methods in `sdk/domain/risk/var.zig`, `sdk/domain/risk/greeks.zig`, and `sdk/domain/risk/stress.zig` that expose risk metrics a dashboard would display?

9. How do the analytics modules (`trading/analytics/tca.zig`, `trading/analytics/vpin.zig`, `trading/analytics/attribution.zig`) expose their computed metrics — what are their public result types and computation entry points?

10. What does the existing `.vscode/trading-platform.code-workspace` contain, and what Zig-specific VS Code task and launch configuration patterns exist for `zig build` executables (task problemMatchers, debug adapter type, etc.)?

11. How does `sdk/core/time.zig` provide timestamps — what clock sources and types does it expose, and how do other modules (OMS, positions, event_loop) consume time values?

12. What is the structure and API of `sdk/core/containers/ring_buffer.zig` and `sdk/core/containers/mpsc_queue.zig` — and how could they serve as the communication mechanism between an event loop thread and a TUI rendering thread?
