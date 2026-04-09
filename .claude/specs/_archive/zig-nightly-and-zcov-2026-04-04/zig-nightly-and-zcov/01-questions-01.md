---
phase: 1
iteration: 01
generated: 2026-04-04
---

# Research Questions: Upgrade to Zig Nightly and Add zig-cover (zcov)

Source issue: User request — upgrade from Zig 0.15.2 to nightly and integrate zig-cover (zcov) for code coverage
Feature slug: zig-nightly-and-zcov

## Questions

1. What is the full structure of the current `build.zig`? Enumerate every build step, every module created via `createModule`, every `addTest`/`addExecutable`/`addStaticLibrary` call, and every `addAnonymousImport`. What patterns are used for wiring modules together across directory boundaries (sdk/core, sdk/domain, sdk/protocol, exchanges/, trading/)?

2. What Zig language features and standard library APIs are used across the codebase that have known breaking changes between Zig 0.15.x and Zig nightly (0.16-dev)? Specifically, look for uses of `@import("builtin")`, `std.mem`, `std.fmt`, `std.os`, `std.net`, `std.http`, `std.Thread`, `std.posix`, and any `@` builtins that may have changed signatures.

3. What is the current test infrastructure? How are tests organized (file locations, naming conventions), how are they invoked (build steps, CI scripts, VS Code tasks), and what is the total count of test blocks across the codebase?

4. How does the current `build.zig` handle target resolution, optimization modes, and any conditional compilation or platform-specific code paths? Are there any `.build_options` or comptime feature flags?

5. What external dependencies exist, if any — including `.zig.zon` files, git submodules, vendored code, or system library linkage (libc, libssl, etc.)? What does the `.gitignore` exclude related to build artifacts and caches?

6. What are the VS Code workspace configurations (`.vscode/launch.json`, `.vscode/tasks.json`, `.vscode/settings.json`) that reference Zig, the build system, or test execution? How would these need updating for a new Zig version or coverage tooling?

7. What is zig-cover (zcov) — how is it typically integrated into a Zig build? Does it require a `.zig.zon` dependency, a separate binary, build flags, or instrumentation in `build.zig`? What output formats does it produce?

8. Are there any uses of inline assembly, `@cImport`, `@embedFile`, SIMD builtins, or other low-level features that tend to break across Zig versions? Enumerate all occurrences.

9. What CI/CD configuration exists (GitHub Actions workflows, scripts, Makefiles) that invokes `zig build`, `zig test`, or references a specific Zig version? How is the Zig toolchain installed in CI?

10. How large is the codebase in terms of `.zig` source files and lines of code? What are the top-level module boundaries and their approximate sizes, to estimate the scope of any migration changes?
