---
phase: 3
iteration: 01
generated: 2026-04-04
---

# Design: Upgrade to Zig Nightly and Add zcov (zig-coverage)

Research: .claude/specs/zig-nightly-and-zcov/02-research-01.md

## Current State

The platform is 149 Zig source files (29,196 LOC) plus a 1,299-line `build.zig`, running on Zig 0.15. Key facts:

- `build.zig:1156,1195` — comments reference "Zig 0.15" API patterns (`addExecutable/addTest requires root_module`)
- `build.zig:2-4` — standard target/optimize resolution, passed to all 121 modules and 63 artifacts
- `sdk/core/memory.zig:49-94` — custom allocator directly implements `std.mem.Allocator` VTable (alloc/resize/free/remap)
- `sdk/core/io/event_loop.zig:23,30` — `std.os.linux.IoUring` for async IO
- `sdk/core/io/tcp.zig:12` — `std.net.getAddressList()` for DNS resolution
- `sdk/core/io/thread.zig:15` — `std.os.linux.syscall3(.sched_setaffinity, ...)` for CPU pinning
- `sdk/core/io/thread.zig:45`, `trading/desk/main.zig:66` — `std.Thread.spawn(.{}, ...)`
- 553 test blocks across 50 test files, 61 `addTest()` calls in build.zig
- Zero external dependencies — no `.zig.zon`, no `linkLibC()`, no vendored code
- No CI/CD, no coverage tooling of any kind

## Desired End State

1. **All source compiles and all 553 tests pass on Zig nightly (0.16-dev)**
2. **`zig build zcov`** runs all tests with coverage instrumentation, then prints a colored terminal report showing:
   - Per-module coverage percentage (sdk/core, sdk/domain, sdk/protocol, exchanges/kraken, trading/desk, trading/analytics, trading/strategies)
   - Per-file line-level hit/miss data
   - Total coverage percentage
3. **zcov source lives at `test/zcov/`** as a pure-Zig tool with zero external dependencies
4. **VS Code tasks updated** to include a "Coverage" task invoking `zig build zcov`
5. **README updated** to reflect Zig nightly and zcov usage

## Patterns to Follow

- **Build step aggregation**: `test_step.dependOn()` chains at `build.zig:437-457,684-694` — zcov build step should aggregate test runs the same way, adding `-ffuzz` instrumentation flags
- **Module creation via `createModule()`**: 121 calls in `build.zig` — zcov modules follow the same pattern
- **VS Code task structure**: `.vscode/tasks.json:103-117` — coverage task follows the same `zig build` + `problemMatcher: "$gcc"` pattern
- **Test file naming**: `*_test.zig` in `tests/` subdirectories — zcov discovers test files by this convention
- **Pure Zig, zero deps**: `README.md:3,8` — zcov reads DWARF and coverage data using only `std.debug` and `std.elf`

## Patterns to Avoid

- **External tool dependency (kcov)**: research section 7 — kcov requires system package installation, violates zero-dep philosophy
- **Duplicate module proliferation**: `orderbook_mod_p12` at `build.zig:854` — zcov should not introduce additional duplicate modules; it gets its own isolated module graph

## Resolved Design Decisions

| Decision | Choice | Reason |
| --- | --- | --- |
| Zig version target | Latest nightly (0.16-dev) at implementation time | Stay current; pin version in README after upgrade |
| Coverage approach | Built-in `-ffuzz` instrumentation + custom zcov tool | Pure Zig, no external deps, leverages existing compiler infrastructure |
| zcov output format | Terminal summary + per-file line hits | Fits CLI/TUI workflow, no HTML complexity |
| zcov location | `test/zcov/` | Separate from platform code, alongside test infrastructure |
| zcov invocation | `zig build zcov` | Single command, consistent with existing build step pattern |
| Allocator VTable migration | Adapt to new interface | Preserve custom allocator functionality, just update signatures |
| IO/net API migration | Direct migration | Update calls to nightly equivalents, keep same architecture |
| Reader/Writer API changes | Direct migration | Update to non-generic buffered APIs, add `.flush()` where needed |

## Approach

**Phase 1: Nightly Upgrade.** Install Zig nightly and attempt `zig build test`. Collect all compilation errors. Fix them systematically by category:

- **std.mem.Allocator VTable** (`sdk/core/memory.zig:49-94`): update function signatures to match nightly's VTable shape. This is the highest-risk change since it's a custom implementation of an internal interface.
- **std.net → std.Io.net** (`sdk/core/io/tcp.zig:12`): update `getAddressList()` and related network calls.
- **std.posix / std.os.linux** (`sdk/core/io/event_loop.zig`, `tcp.zig`, `thread.zig`, `trading/desk/terminal.zig`): update IoUring, socket, terminal, and signal APIs to their nightly equivalents.
- **std.Thread.spawn** (`sdk/core/io/thread.zig:45`, `trading/desk/main.zig:66`): adapt to any spawn API changes.
- **Reader/Writer APIs** (`sdk/protocol/http/client.zig`): migrate to non-generic buffered APIs, add explicit `.flush()`.
- **Builtins** (`@intCast`, `@as`, `@ptrCast`, etc. across 85+ files): these are likely stable in nightly but verify. Fix any signature changes.
- **build.zig**: update any `addExecutable`/`addTest`/`createModule` API changes. Update comments referencing "Zig 0.15".

After all tests pass, update `README.md` to reflect the nightly version.

**Phase 2: zcov Tool.** Build the coverage tool at `test/zcov/`:

- **`test/zcov/main.zig`**: entry point — orchestrates test execution with `-ffuzz`, reads coverage data, produces report.
- **`test/zcov/coverage.zig`**: reads the binary coverage data (PC bitfield from `-ffuzz` instrumentation in `.zig-cache/`), maps PCs to source locations using `std.debug.Coverage` / DWARF debug info.
- **`test/zcov/report.zig`**: formats and prints the terminal report — per-module summary, per-file line hits, color coding (green=covered, red=uncovered, dim=non-executable).
- **Build integration**: add `zig build zcov` step in `build.zig` that builds the zcov executable, runs it, and depends on test compilation with `-ffuzz` flags.
- **VS Code task**: add "Coverage" task to `.vscode/tasks.json`.

The zcov tool operates in three stages: (1) compile tests with `-ffuzz` instrumentation, (2) run test binaries to generate coverage data, (3) read coverage data + DWARF info to produce the report. All three stages use only Zig stdlib — `std.debug` for DWARF parsing, `std.elf` for ELF reading, `std.fs` for file access.

## Open Questions

(None — all resolved during design discussion.)
