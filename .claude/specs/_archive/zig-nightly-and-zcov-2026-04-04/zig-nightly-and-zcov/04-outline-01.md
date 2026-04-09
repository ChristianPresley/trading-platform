---
phase: 4
iteration: 01
generated: 2026-04-04
---

# Outline: Upgrade to Zig Nightly and Add zcov

Design: .claude/specs/zig-nightly-and-zcov/03-design-01.md

## Overview

Migrate the entire 149-file, 29K LOC Zig 0.15 codebase to Zig nightly (0.16-dev) in three vertical slices following the module dependency graph (core → protocol/domain → exchanges/trading), then build a pure-Zig coverage tool (zcov) as a fourth slice. Each phase is independently testable via existing `zig build` steps.

## Phase 1: Core SDK Nightly Migration
**Delivers**: `zig build test-core` passes on Zig nightly
**Layers touched**: build.zig (core module definitions + addTest), sdk/core/

### Key types / signatures introduced

```zig
// sdk/core/memory.zig — updated VTable signatures to match nightly
const VTable = std.mem.Allocator.VTable{
    .alloc = ...,   // updated signature per nightly
    .resize = ...,
    .free = ...,
    .remap = ...,   // may be added/changed
};

// sdk/core/io/tcp.zig — std.net → std.Io.net migration
fn connect(host: []const u8, port: u16) !Socket  // internal API unchanged, impl updated

// sdk/core/io/event_loop.zig — IoUring API updates
fn init() !EventLoop  // updated std.os.linux.IoUring calls

// sdk/core/io/thread.zig — std.Thread.spawn adaptation
fn spawn(comptime func: anytype, args: anytype) !std.Thread
```

### Test checkpoint
- Type: Automated
- `zig build test-core` — all 5 core test files (memory, time, containers, crypto, event_store) pass on nightly

---

## Phase 2: Protocol + Domain SDK Migration
**Delivers**: `zig build test-protocol` passes + domain tests pass on nightly
**Layers touched**: build.zig (protocol/domain module defs + tests), sdk/protocol/, sdk/domain/
**Depends on**: Phase 1

### Key types / signatures introduced

```zig
// sdk/protocol/http/client.zig — Reader/Writer API migration
fn parseResponse(reader: std.io.AnyReader) !Response  // non-generic, buffered
fn sendRequest(writer: std.io.AnyWriter, req: Request) !void  // explicit .flush()

// sdk/protocol/fix/codec.zig — updated std.fmt usage if needed
fn encode(msg: FixMessage, buf: []u8) ![]u8
```

### Test checkpoint
- Type: Automated
- `zig build test-protocol` — all 8 protocol test files pass
- Domain tests verified via the subset of `zig build test` covering sdk/domain/tests/ (12 files)

---

## Phase 3: Exchanges + Trading + Full Test Suite
**Delivers**: `zig build test` (all 553 tests) passes on nightly; README reflects nightly version
**Layers touched**: build.zig (remaining modules, comments), exchanges/kraken/, trading/, README.md
**Depends on**: Phase 2

### Key types / signatures introduced

```zig
// No new types — this phase updates existing exchange/trading code to compile on nightly
// trading/desk/terminal.zig — posix API updates
fn setupTerminal() !void  // updated tcgetattr/tcsetattr/sigaction calls

// trading/desk/main.zig — Thread.spawn adaptation
fn main() !void  // updated spawn call at line 66
```

### Test checkpoint
- Type: Automated
- `zig build test` — all 553 test blocks across 50 files pass on nightly
- `zig build build-desk-tui` and `zig build build-desk-headless` — both executables compile

---

## Phase 4: zcov Coverage Tool + Integration
**Delivers**: `zig build zcov` produces terminal coverage report with per-module and per-file data
**Layers touched**: test/zcov/ (new), build.zig (new zcov step), .vscode/tasks.json
**Depends on**: Phase 3

### Key types / signatures introduced

```zig
// test/zcov/main.zig
pub fn main() !void  // orchestrate: compile w/ coverage, run, report

// test/zcov/coverage.zig
pub const CoverageData = struct {
    source_file: []const u8,
    lines_hit: []bool,
    total_lines: u32,
    covered_lines: u32,
};
pub fn collectCoverage(allocator: std.mem.Allocator, test_binary_path: []const u8) ![]CoverageData

// test/zcov/report.zig
pub const ModuleSummary = struct {
    name: []const u8,
    total_lines: u32,
    covered_lines: u32,
    pub fn percentage(self: ModuleSummary) f64
};
pub fn printReport(writer: std.io.AnyWriter, data: []const CoverageData) !void
```

### Test checkpoint
- Type: Automated
- `zig build zcov` — runs without error, produces non-empty terminal output with coverage percentages
- Verify VS Code "Coverage" task exists in `.vscode/tasks.json`

---

## Dependencies
- Phase 2 must complete before Phase 3 because: exchanges/ and trading/ import sdk/protocol and sdk/domain modules
- Phase 1 must complete before Phase 2 because: sdk/protocol and sdk/domain import sdk/core modules
- Phase 4 depends on Phase 3 because: zcov needs all test binaries to compile successfully
- Phases 1-3 are a linear chain; Phase 4 is independent except for needing Phase 3's output
