---
phase: 1
iteration: 01
generated: 2026-04-03
---

# Research Questions: SDK GUI + Headless Mode

Source issue: Feature request — add a graphical user interface to the trading platform while preserving existing TUI and headless capabilities
Feature slug: sdk-gui-headless-mode

## Questions

1. How does the engine communicate with the TUI today? Trace the full lifecycle of `EngineEvent` and `UserCommand` through the SPSC ring buffers — what thread boundaries exist, what are the message types, and how are they produced/consumed in `trading/desk/engine.zig` and `trading/desk/main.zig`?

2. How is the TUI renderer implemented? What does `trading/desk/renderer.zig` depend on (terminal, layout, ANSI escape sequences), and how does the frame-buffer-then-flush rendering model work? What is the current frame rate and timing model?

3. How does the terminal abstraction (`trading/desk/terminal.zig`) work? What platform-specific syscalls or APIs does it use for raw mode, input reading, signal handling, and size detection? How does the existing code handle the "not a terminal" case (headless mode)?

4. How does the input handling system work in `trading/desk/input.zig`? What is the `InputHandler` / `Action` abstraction, how are keyboard events decoded, and how does text-mode vs. navigation-mode input work?

5. How are the TUI panels (`trading/desk/panels/`) structured? What interface does each panel expose (draw function signatures, state management), and how do they consume the shared message types from `messages.zig`?

6. How does the layout system (`trading/desk/layout.zig`) compute panel positions? What is the `Rect`/`Panels` model, and how tightly is it coupled to terminal dimensions vs. being a generic rectangle-based layout?

7. What SDK domain modules exist under `sdk/domain/` and `sdk/core/`, and how does the trading desk currently import and use them? Trace the import chain from `build.zig` through to the desk's usage of OMS, orderbook, ring_buffer, and other SDK types.

8. How does `build.zig` wire up modules, test targets, and executables? What patterns does it use for cross-directory imports (anonymous imports, module roots), and how are the trading desk and SDK test suites structured?

9. What exists under `sdk/protocol/`? How do the protocol definitions relate to the message types in `trading/desk/messages.zig` — are they shared, duplicated, or independent?

10. What test patterns and test infrastructure exist across the codebase? How are tests organized (inline vs. separate test files), what naming conventions are used, and what is the current `zig build test` coverage across sdk/ and trading/?

11. What exists under `exchanges/` and how does exchange connectivity integrate with the SDK domain layer? How would a GUI need to interact with exchange state (connection status, live vs. synthetic feeds)?

12. How does the synthetic market data feed (`trading/desk/synthetic.zig`) work, and how is it wired into the engine? What would need to change for a GUI to consume the same feed infrastructure?
