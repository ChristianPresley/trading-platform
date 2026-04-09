---
phase: 2
iteration: 01
generated: 2026-04-04
---

# Research: Upgrade to Zig Nightly and Add zig-cover (zcov)

Questions source: .claude/specs/zig-nightly-and-zcov/01-questions-01.md

## 1. Full structure of build.zig

`build.zig` is 1,299 lines. Entry point at `build.zig:2-4` uses standard target/optimize resolution.

**Build steps (14 total):**
- `test` (line 7) — aggregate all tests
- `test-core` (line 8) — SDK/core tests
- `test-protocol` (line 467) — SDK/protocol tests
- `test-ws` (line 708) — WebSocket tests
- `test-kraken` (line 709) — Kraken exchange tests
- `build-desk-tui` (line 1187), `run-desk-tui` (line 1192), `test-desk-tui` (line 1222)
- `build-desk` (line 1226), `run-desk` (line 1227), `test-desk` (line 1228) — aliases for TUI
- `build-desk-headless` (line 1262), `run-desk-headless` (line 1267), `test-desk-headless` (line 1297)

**Modules:** ~121 `createModule()` calls spanning all directories. Modules are wired via `addImport()` calls — crypto modules (lines 91-112: hmac, base64, aes, chacha20, x25519, rsa, ecdsa) are created once and shared across core tests, Kraken auth, and FIX client.

**Executables (2):**
- `desk-tui` at `build.zig:1180` with `installArtifact` at line 1184
- `desk-headless` at `build.zig:1255` with `installArtifact` at line 1259

**Tests:** 61 `addTest()` calls, each wrapped with `addRunArtifact()`. The main `test_step` aggregates all 61 via `dependOn` (lines 437-457, 684-694, 839-843, 947-951, 1046-1050, 1118-1120).

**`addAnonymousImport` (12 total):** Used for core tests (lines 51-87, 143) and binary protocol tests (lines 550-608: itch, sbe, fast, ouch, pitch).

**Cross-directory wiring patterns:**
- Crypto modules shared across sdk/core, exchanges/kraken, sdk/protocol/fix
- Duplicate module pattern: `orderbook_mod_p12` (line 854) avoids "file exists in multiple modules" for strategy tests
- Test modules avoid diamond dependencies: e.g., `kraken_spot_executor_tests` (line 1098-1099) links to `oms_mod` instead of `order_types` directly
- Desktop modules aggregate 17 imports each (lines 1157-1177, 1233-1253)

## 2. Zig language features and stdlib APIs with breaking changes (0.15→0.16-dev)

**std.mem usage:**
- `std.mem.zeroes()` — `trading/desk/engine.zig:249,254,257-258`, `trading/desk/matching_engine.zig:43`, `sdk/core/io/thread.zig:8`
- `std.mem.Alignment.fromByteUnits()` — `sdk/core/memory.zig:22`
- `std.mem.Allocator` with VTable — `sdk/core/memory.zig:49-94` (custom allocator: alloc/resize/free/remap)
- `std.mem.splitSequence()` — `sdk/protocol/http/client.zig:64`
- `std.mem.indexOf()` — `sdk/protocol/http/client.zig:31-33,40-42`
- `std.mem.asBytes()` — `sdk/core/io/tcp.zig:56`
- `std.mem.alignForward()` — `sdk/core/memory.zig:21`

**std.posix usage:**
- Socket APIs: `std.posix.socket()`, `connect()`, `read()`, `write()`, `setsockopt()` — `sdk/core/io/tcp.zig:19,24,39,43,52`
- Terminal APIs: `posix.tcgetattr()`, `tcsetattr()`, `isatty()` — `trading/desk/terminal.zig:34,37,53`
- Signal handling: `posix.Sigaction`, `posix.sigaction()` — `trading/desk/terminal.zig:64-70`
- `posix.system.ioctl()` — `trading/desk/terminal.zig:96`
- `posix.errno()` — `sdk/core/io/thread.zig:21`, `trading/desk/terminal.zig:97`
- Type aliases: `posix.fd_t`, `posix.socket_t` — `sdk/core/io/event_loop.zig:7,12`, `sdk/core/io/tcp.zig:7`

**std.os.linux usage:**
- `std.os.linux.IoUring` — `sdk/core/io/event_loop.zig:23,30`
- `std.os.linux.kernel_timespec` — `sdk/core/io/event_loop.zig:76-79`
- `std.os.linux.syscall3(.sched_setaffinity, ...)` — `sdk/core/io/thread.zig:15`

**std.net usage:**
- `std.net.getAddressList()` — `sdk/core/io/tcp.zig:12` (moving to `std.Io.net` in 0.16)

**std.Thread usage:**
- `std.Thread.spawn(.{}, ...)` — `sdk/core/io/thread.zig:45`, `trading/desk/main.zig:66`, `trading/desk/headless_main.zig:34` (Thread.Pool removed in 0.16, replaced by std.Io)

**std.fmt usage:**
- `std.fmt.parseInt()` — `sdk/protocol/http/client.zig:51,81`
- `std.fmt.bufPrint()` — `trading/desk/engine.zig:441-442`

**std.heap usage:**
- `std.heap.ArenaAllocator` — `sdk/core/memory.zig:100-115`

**Key 0.16 breaking changes from web research:**
- `std.net` moves to `std.Io.net`
- `std.Thread.Pool` removed, replaced by `std.Io` multiprocessing
- Reader/Writer APIs redesigned (non-generic, buffered by default, requires explicit `.flush()`)
- `std.mem.Allocator.VTable` signatures may change

## 3. Current test infrastructure

**Test files:** 50 test files following `*_test.zig` naming in `tests/` subdirectories at each module level.

**Test block count:** 553 total `test "..."` blocks across the codebase.

**Test file locations:**
- `sdk/core/tests/` — 5 files (memory, time, containers, crypto, event_store)
- `sdk/domain/tests/` — 12 files (oms, order_types, risk, positions, var, greeks, orderbook, bar_aggregator, market_data, parquet, tick_store, sor)
- `sdk/domain/post_trade/tests/` — 3 files (reconciliation, eod, allocation)
- `sdk/domain/algos/tests/` — 4 files (iceberg, pov, twap, vwap)
- `sdk/protocol/tests/` — 8 files (fast, itch, ouch, pitch, sbe, json, http, tls)
- `sdk/protocol/websocket/tests/` — 1 file (frame_test)
- `sdk/protocol/fix/tests/` — 2 files (codec, session)
- `exchanges/kraken/common/tests/` — 1 file (symbol_translator)
- `exchanges/kraken/spot/tests/` — 6 files (auth, rate_limiter, rest_client, fix_client, executor, ws_client)
- `exchanges/kraken/futures/tests/` — 3 files (auth, executor, ws_client)
- `trading/analytics/tests/` — 3 files (attribution, tca, vpin)
- `trading/strategies/tests/` — 2 files (basis, funding_arb)

**Build step invocation:**
- `zig build test` — all tests (step at line 7)
- `zig build test-core` — core only (line 8)
- `zig build test-protocol` (line 467), `test-ws` (line 708), `test-kraken` (line 709)
- `zig build test-desk-tui` (line 1222), `test-desk-headless` (line 1297)

**VS Code tasks:** "Test All" task at `.vscode/tasks.json:103-117` runs `zig build test` (default test task). Individual test tasks for each subsystem (lines 118-189).

**No CI scripts exist** — tests are run locally via VS Code tasks or direct `zig build` invocation.

## 4. Target resolution, optimization, and conditional compilation

**Target/optimize resolution** at `build.zig:3-4`:
```
const target = b.standardTargetOptions(.{});
const optimize = b.standardOptimizeOption(.{});
```
Passed to all 121 modules and 63 test/executable artifacts.

**No `.build_options`** — no `b.addOptions()` calls found.

**No comptime feature flags** — no `@import("build_options")` usage anywhere.

**No conditional compilation in build.zig** — no platform-specific branches. Platform-specific code is in source files (e.g., `std.os.linux` usage in `sdk/core/io/`).

**Comments reference Zig 0.15:**
- `build.zig:1156`: "Zig 0.15: addExecutable requires root_module"
- `build.zig:1195`: "Zig 0.15: addTest requires root_module"
- `build.zig:1231`: "Release builds: zig build build-desk -Doptimize=ReleaseFast"

## 5. External dependencies

**Zero external dependencies.** `README.md:3`: "High-performance cryptocurrency trading platform written in pure Zig with zero external dependencies."

- No `.zig.zon` file exists
- No git submodules
- No vendored code directories (vendor/, third_party/, deps/, extern/)
- No `linkLibC()`, `linkSystemLibrary()`, or any link directives in `build.zig`
- All networking, cryptography, protocol, and data structure code is implemented from scratch (`README.md:8`)

**.gitignore** (34 lines) excludes:
- `.zig-cache/`, `zig-out/` — build artifacts (lines 3-4)
- `*.o`, `*.so`, `*.dylib`, `*.dll`, `*.a` — compiled objects (lines 5-12)
- `.worktrees/` — git worktrees (line 28)
- `.env`, `*.pem`, `*.key` — secrets (lines 30-34)
- OS/editor files (lines 14-24)

## 6. VS Code workspace configurations

**`.vscode/launch.json`** (26 lines) — 2 debug configurations:
- "Debug Desk TUI" (lines 4-13): lldb, program `zig-out/bin/desk-tui`, preLaunchTask "Build Desk TUI"
- "Debug Desk Headless" (lines 14-23): lldb, program `zig-out/bin/desk-headless`, preLaunchTask "Build Desk Headless"

**`.vscode/tasks.json`** (216 lines) — 17 tasks referencing `zig build`:
- 4 build tasks: desk-tui, desk-tui release, desk-headless, desk-headless release (lines 5-54)
- 4 run tasks: same variants (lines 55-102)
- 7 test tasks: Test All (default, line 103), Test Desk TUI, Test Desk Headless, Test Core, Test Protocol, Test WebSocket, Test Kraken (lines 118-189)
- 2 cleanup tasks: Clean (`rm -rf .zig-cache zig-out`), Clean Build (lines 190-213)
- All use `problemMatcher: "$gcc"`

**`.vscode/settings.json`** does not exist.

**`.vscode/trading-platform.code-workspace`** (7 lines) — minimal, single folder, no Zig-specific settings.

## 7. zig-cover (zcov) — what it is and how it integrates

**No existing coverage tooling in the codebase.** Grep for "coverage", "zcov", "zig-cover", "kcov" returned zero results in all `.zig` source files and `build.zig`.

**Web research findings:**

The original `zcov` (github.com/ddunbar/zcov, github.com/kren1/zcov) is a general-purpose C/C++ coverage tool wrapping gcov — not Zig-specific.

**Zig code coverage options:**
1. **kcov** — most common approach. Works with Zig binaries via DWARF debug info. Integrated into `build.zig` via `--test-cmd kcov` flag. A PR to integrate kcov into Zig's build system (ziglang/zig#20362) was drafted June 2024 but closed October 2024 without merging.
2. **Zig built-in coverage** — `ziglang/zig#352` (open since 2017) tracks native coverage support. `ziglang/zig#18860` proposes test coverage output format. No built-in `--coverage` flag exists in 0.15.x.
3. **grindcov** (github.com/squeek972/grindcov) — uses Valgrind/Callgrind for coverage, works with Zig binaries.

**Integration pattern for kcov:**
- Requires kcov binary installed on the system (external dependency)
- Build.zig adds test executables with `--test-cmd kcov --test-cmd <output-dir>` flags
- Produces HTML coverage reports and Cobertura XML
- Works with `zig build test -Dtest-coverage` convention

## 8. Low-level features that break across Zig versions

**No `@cImport`, `@embedFile`, inline assembly (`asm`), or SIMD builtins (`@Vector`, `@shuffle`, `@splat`)** found anywhere in the codebase.

**Builtins used extensively:**

- `@intCast()` — 45+ files; e.g., `sdk/core/io/thread.zig:11`, `sdk/core/io/event_loop.zig:66,77`, `trading/desk/messages.zig:12`, `trading/desk/engine.zig:462`
- `@ptrCast()` / `@alignCast()` — `sdk/core/memory.zig:37,58,71,78` (custom allocator)
- `@intFromPtr()` — `sdk/core/io/thread.zig:19`, `trading/desk/terminal.zig:96`, `sdk/core/tests/memory_test.zig:33`
- `@memcpy()` — `trading/desk/engine.zig:461,526`, `trading/desk/renderer.zig:50`, `trading/desk/terminal.zig:131`, `sdk/core/crypto/aes.zig:280,299,320`, `sdk/core/crypto/chacha20.zig:88`, `sdk/core/crypto/hmac.zig:89,227,286-301`, `sdk/protocol/itch.zig:144,150`, `sdk/protocol/ouch.zig:142,148,154`
- `@truncate()` — `trading/desk/engine.zig:331,410,511,962`, `sdk/protocol/fix/codec.zig:176`
- `@typeInfo()` — `sdk/core/containers/hash_map.zig:87,107`
- `@divTrunc()` — `trading/desk/engine.zig:322,401,953`, `trading/desk/panels/orderbook_panel.zig:14,22`
- `@rem()` / `@mod()` — `trading/desk/panels/orderbook_panel.zig:15`, `trading/desk/panels/chart_primitives.zig:49`
- `@call(.auto, ...)` — `sdk/core/io/thread.zig:42`
- `@intFromEnum()` — `trading/desk/terminal.zig:51-52`
- `@as()` — 85+ files
- `@min()` / `@max()` — `trading/desk/messages.zig:10`, `sdk/core/memory.zig:20`

## 9. CI/CD configuration

**No CI/CD exists.** No `.github/` directory, no GitHub Actions workflows, no Makefiles, no shell scripts, no `.gitlab-ci.yml`, no Jenkinsfile.

**Zig version:** `README.md:7` specifies "Zig 0.13.x" (outdated — build.zig comments reference 0.15). No pinned version constraint in build configuration.

**Build/test invocation is entirely local** via VS Code tasks or direct `zig build` commands.

## 10. Codebase size and module boundaries

**Total:** 149 `.zig` source files, 29,196 lines of code, plus `build.zig` at 1,299 lines.

**Module breakdown by lines:**

| Module | Files | Lines |
|--------|-------|-------|
| **sdk/** (total) | 93 | 17,438 |
| sdk/domain/ | 43 | 7,418 |
| sdk/protocol/ | 28 | 6,713 |
| sdk/core/ | 22 | 3,307 |
| **trading/** (total) | 30 | 6,058 |
| trading/desk/ | 20 | 4,938 |
| trading/analytics/ | 6 | 635 |
| trading/strategies/ | 4 | 485 |
| **exchanges/** (total) | 24 | 4,401 |
| exchanges/kraken/ | 24 | 4,401 |

**Largest directories by file count:** trading/desk (12), sdk/domain/tests (12), sdk/domain (10), trading/desk/panels (8), sdk/protocol/tests (8).

## Cross-cutting observations

- The entire codebase is pure Zig with zero external dependencies — `build.zig` has no `linkLibC()` or `linkSystemLibrary()` calls, no `.zig.zon` file exists (`README.md:3,8`)
- `build.zig` comments at lines 1156 and 1195 explicitly reference "Zig 0.15" API patterns (`addExecutable requires root_module`, `addTest requires root_module`)
- README.md line 7 still says "Zig 0.13.x" — outdated relative to actual 0.15 usage in build.zig
- The `std.os.linux.IoUring` usage in `sdk/core/io/event_loop.zig:23,30` and `std.os.linux.syscall3` in `sdk/core/io/thread.zig:15` tie the platform to Linux
- No `@cImport`, `@embedFile`, inline assembly, or SIMD builtins exist — the codebase uses only safe Zig constructs
- The custom allocator at `sdk/core/memory.zig:49-94` implements the `std.mem.Allocator` VTable interface directly, making it sensitive to any VTable signature changes
- `@intCast` (45+ files) and `@as` (85+ files) are the most pervasive builtins — stable but high migration surface area if signatures change
- The duplicate-module avoidance pattern (`orderbook_mod_p12` at `build.zig:854`, test linking via `oms_mod` instead of `order_types` at `build.zig:1098-1099`) adds complexity to the build

## Coverage gaps

- None. All 10 questions covered with file:line references.
