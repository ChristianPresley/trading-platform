# trading-platform

High-performance cryptocurrency trading platform written in pure Zig with zero external dependencies. Designed for deterministic latency and no garbage collection pauses.

## Prerequisites

- [Zig](https://ziglang.org/download/) 0.13.x

No other dependencies are required — all networking, cryptography, protocol, and data structure code is implemented from scratch in this repository.

## Repository Layout

```
sdk/
  core/         Memory allocators, containers, crypto, I/O, time
  domain/       Order types, OMS, risk, positions, algos, post-trade
  protocol/     JSON, TLS, HTTP, WebSocket, FIX, ITCH, SBE, FAST, OUCH, PITCH
exchanges/
  kraken/       Kraken spot + futures clients (REST, WebSocket, FIX)
trading/
  analytics/    TCA, attribution, VPIN
  strategies/   Basis, funding arbitrage
docs/           Exchange documentation and trading desk reference
```

## Build

This project is a library — there is no standalone executable yet. To compile and verify everything builds:

```sh
zig build
```

Pass optimization flags for release builds:

```sh
zig build -Doptimize=ReleaseFast    # maximum performance
zig build -Doptimize=ReleaseSafe    # performance with safety checks
zig build -Doptimize=ReleaseSmall   # optimize for binary size
```

## Test

Run the full test suite:

```sh
zig build test
```

Run tests for a specific module:

```sh
zig build test-core       # sdk/core — memory, time, containers, crypto, event store
zig build test-protocol   # sdk/protocol — JSON, TLS, HTTP, ITCH, SBE, FAST, OUCH, PITCH, FIX
zig build test-ws         # WebSocket frame tests
zig build test-kraken     # Kraken exchange tests (spot + futures auth, rate limiter, REST)
```

## Debug

Zig builds in `Debug` mode by default (no `-Doptimize` flag), which includes:

- Full runtime safety checks (bounds checking, integer overflow detection)
- Debug symbols for stack traces
- No optimizations — predictable stepping in debuggers

To debug a specific test failure, run its test file directly:

```sh
zig test sdk/core/tests/memory_test.zig
```

For GDB/LLDB, build the test binary and run it under a debugger:

```sh
zig build test-core 2>&1  # check for compile errors first
# Then attach your debugger to the test binary in zig-cache
```

## Run

There is no runnable application yet. The platform is currently a set of libraries and tests. As executable targets (e.g., a trading gateway or TUI) are added, they will be documented here.