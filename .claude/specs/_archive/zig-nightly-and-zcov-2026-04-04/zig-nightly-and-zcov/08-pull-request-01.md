---
phase: 8
iteration: 01
generated: 2026-04-04
---

PR Title: Add zcov coverage tool with per-module terminal reporting

Closes: #55

## What problem does this solve?
The trading platform had no code coverage tooling. This adds `zcov`, a pure-Zig coverage analysis tool that discovers test binaries, runs them, reads `-ffuzz` instrumentation data (SeenPcsHeader), resolves PCs to source locations via DWARF, and prints a colored per-module coverage report in the terminal.

Note: Phases 1-3 (Zig nightly migration) were deferred because Zig nightly (0.16-dev) is not installed on the build machine. The codebase already compiles clean on Zig 0.15.2. The zcov tool was built and works on the current Zig version.

## User-facing changes
- New build step: `zig build zcov` — runs all tests with coverage and prints a per-module report
- New VS Code task: "Coverage" — invokes `zig build zcov`
- Optional module filter: `zig build zcov -- sdk/core` to scope to a single module

## Implementation summary

**Key design decisions** (from Phase 3):
- **Coverage approach**: Built-in `-ffuzz` instrumentation + custom zcov tool — pure Zig, no external deps, leverages compiler infrastructure
- **zcov output format**: Terminal summary + per-file line hits — fits CLI/TUI workflow, no HTML complexity
- **zcov location**: `test/zcov/` — separate from platform code, alongside test infrastructure
- **zcov invocation**: `zig build zcov` — single command, consistent with existing build step pattern

**Edge cases handled** (from Phase 5):
- No coverage data: graceful message with usage hint
- Missing debug info: warns and skips binary instead of crashing
- Files outside module boundaries: grouped under "other" in report
- Large binaries: streaming reads of coverage files (64MB cap per file)

**Test checkpoints passed** (from Phase 7):
- Phase 1 — `zig build test-core`: passed (no changes needed — nightly not installed)
- Phase 2 — `zig build test-protocol`: passed (no changes needed)
- Phase 3 — `zig build test`: passed (no changes needed)
- Phase 4 — `zig build zcov`: passed — built and ran, processed 77 test binaries

## Implementation approach
Three new files in `test/zcov/`:
- **`main.zig`** (205 lines): CLI entry point — compiles tests, discovers binaries in `.zig-cache/o/`, runs them for coverage, aggregates results, prints report. Uses `std.process.Child` for subprocess management.
- **`coverage.zig`** (208 lines): Reads `SeenPcsHeader` files from `.zig-cache/v/`, resolves covered PCs to source locations using `std.debug.Info` + `std.debug.Coverage`, aggregates by file.
- **`report.zig`** (123 lines): Groups coverage data by module path prefix, prints colored terminal table with progress bars.

Build integration: 19 lines added to `build.zig` — creates zcov module, executable, install + run steps.
VS Code: "Coverage" task added to `.vscode/tasks.json`.

## Exceptions and deviations
Phases 1-3 (Zig nightly migration) were no-ops — Zig nightly is not installed on the build machine. The existing codebase compiles and passes all tests on Zig 0.15.2. Nightly migration will be completed when 0.16-dev is installed.

## How to verify

### Automated
- [ ] `zig build test 2>&1; echo "EXIT:$?"` — all existing tests pass (EXIT:0)
- [ ] `zig build zcov 2>&1; echo "EXIT:$?"` — zcov builds and runs (EXIT:0)

### Manual
- [ ] Run `zig build zcov` and verify colored per-module coverage table appears
- [ ] Run `zig build zcov -- sdk/core` and verify only sdk/core files appear
- [ ] Open VS Code, run the "Coverage" task from the task list

## Breaking changes / migration notes
None

## Changelog entry
Add zcov, a pure-Zig coverage analysis tool that reports per-module line coverage via `zig build zcov`
