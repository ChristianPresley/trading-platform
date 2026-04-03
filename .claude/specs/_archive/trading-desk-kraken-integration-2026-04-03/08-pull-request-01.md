---
phase: 8
iteration: 01
generated: 2026-04-03
---

PR Title: Add pure-Zig trading platform SDK with Kraken exchange integration

Closes: #9

## What problem does this solve?

This implements a complete professional trading platform SDK in pure Zig with zero external dependencies, providing every building block needed for institutional-grade trading: from low-level I/O and cryptography through wire protocols, order management, risk calculations, execution algorithms, and analytics. Kraken (spot + futures) serves as the first exchange adapter, demonstrating the full stack end-to-end.

## User-facing changes

This is a greenfield implementation — all changes are new. The SDK provides:
- **129 new source files** across 5 layers: `sdk/core/`, `sdk/protocol/`, `sdk/domain/`, `exchanges/kraken/`, `trading/`
- **23,795 lines** of pure Zig with comprehensive test coverage
- Complete Kraken spot and futures connectivity (REST, WebSocket v2, FIX)
- Order management, execution algorithms, risk calculations, and analytics ready for use

## Implementation summary

**Key design decisions** (from Phase 3):
- **Full platform scope**: All components built as native Zig — no external libraries, no C interop, no `.zon` dependencies
- **Layered module architecture**: `sdk/core` → `sdk/protocol` → `sdk/domain` with strict dependency direction; `exchanges/` and `trading/` as consumers
- **Custom TLS 1.2/1.3**: Built on `std.crypto` primitives (AES-GCM, ChaCha20-Poly1305, X25519, RSA, ECDSA, X.509) for full control
- **Arena + pool allocators**: Cache-line aligned (64 bytes), pre-allocated pools for hot-path objects, conforming to `std.mem.Allocator` interface
- **io_uring + pinned threads**: io_uring event loop for I/O; SPSC ring buffers for zero-contention inter-thread data flow
- **All wire protocols native**: JSON, FIX, SBE, FAST, ITCH, OUCH, PITCH — covers Kraken and traditional/electronic venues
- **L2 + L3 order books**: Market-by-Price for Kraken; Market-by-Order for MBO exchanges; shared `BookView` interface

**Edge cases handled** (from Phase 5):
- FIX session: PossDupFlag handling for ResendRequest/SequenceReset, sequence gap detection
- Order state machine: fill-before-cancel, fill-before-replace, unsolicited cancel race conditions
- WebSocket: Cloudflare rate limit awareness (150 reconnects/10 min), automatic ping/pong keepalive
- Kraken auth: Spot vs futures use different HMAC-SHA512 input construction despite same algorithm
- Reconciliation: configurable tolerances for trade/position/cash matching with break management

**Test checkpoints passed** (from Phase 7):
- Phase 1 — `zig build test --summary all`: passed (46/46 tests)
- Phase 2 — `zig build test --summary all`: passed (48/48 tests)
- Phase 3 — `zig build test --summary all`: passed (283/283 tests)
- Phase 4 — `zig build test --summary all`: passed (437/437 tests)
- Phase 5 — `zig build test --summary all`: passed (48/48 tests)
- Phase 6 — `zig build test --summary all`: passed (12/12 tests)
- Phase 7 — `zig build test --summary all`: passed (31 new tests)
- Phase 8 — `zig build test --summary all`: passed (266/266 tests)
- Phase 9 — `zig build test --summary all`: passed (101/101 tests)
- Phase 10 — `zig build test --summary all`: passed (5/5 tests)
- Phase 11 — `zig build test --summary all`: passed (18/18 tests)
- Phase 12 — `zig build test --summary all`: passed (218/218 tests)

## Implementation approach

The implementation was executed in 12 phases across 5 batches using parallel worktrees:

**Batch 1** — Project skeleton + core primitives (memory, time, containers, crypto)
**Batch 2** — I/O + TLS + HTTP + JSON | OMS + order types + risk + event store | Market data protocols (SBE, FAST, ITCH, OUCH, PITCH)
**Batch 3** — WebSocket + Kraken REST | FIX protocol + Kraken FIX | Position tracking + P&L + risk calcs
**Batch 4** — Kraken WS streaming + market data + order book | Post-trade + reconciliation + tick store
**Batch 5** — Kraken order execution E2E | Execution algorithms + SOR | Trading strategies + analytics

Key technical choices:
- `MpscQueue` uses allocator-based init rather than self-referential `init()` to work within Zig 0.13 constraints
- `X25519` delegates to `std.crypto.dh.X25519` (only crypto primitive using std directly)
- SBE uses compile-time layout definitions instead of XML schema parsing for zero-overhead decoding
- `OrderManager` uses `anyopaque` + function pointers to avoid circular dependency between modules
- `order_types` accessed via `oms` module to avoid multi-module file conflicts in Zig 0.13
- SOR `best_score` initialized to `-inf` for correct venue comparison
- `MarketState` inner struct extracted to named `VenueBook` for cross-module compatibility

## Exceptions and deviations

Minor deviations from the plan, all documented per phase:
- Phase 1: `MpscQueue` init pattern changed; `X25519` delegates to std; minor test vector corrections
- Phase 6: `OrderManager` uses `anyopaque` + function pointers for dependency management
- Phase 7: `order_types` accessed via `oms` module path
- Phase 9: SBE uses compile-time layouts instead of XML schema parsing
- Phase 10: SOR best_score init fixed; `VenueBook` struct extracted

No deviations affected the design goals or API surface.

## How to verify

### Automated
- [ ] `zig build test --summary all` — runs all 101 build steps and full test suite
- [ ] All 12 phase checkpoints passed with zero failures and zero recovery attempts

### Manual
- [ ] Verify layered module structure: `sdk/core/` → `sdk/protocol/` → `sdk/domain/` → `exchanges/kraken/` → `trading/`
- [ ] Verify zero external dependencies: no `.zon` dependency file, no C imports
- [ ] Spot-check Kraken auth: `exchanges/kraken/spot/auth.zig` implements HMAC-SHA512 with base64-decoded secret
- [ ] Spot-check FIX session: `sdk/protocol/fix/session.zig` handles Logon/Logout/Heartbeat/ResendRequest
- [ ] Spot-check order state machine: `sdk/domain/oms.zig` validates FIX-standard state transitions

## Breaking changes / migration notes

None — this is a greenfield implementation with no prior code.

## Changelog entry

Add complete pure-Zig trading platform SDK with Kraken spot and futures exchange integration, covering core primitives, wire protocols (TLS, HTTP, WebSocket, JSON, FIX, SBE, FAST, ITCH, OUCH, PITCH), order management, risk calculations, execution algorithms, smart order routing, position tracking, post-trade reconciliation, and trading analytics
