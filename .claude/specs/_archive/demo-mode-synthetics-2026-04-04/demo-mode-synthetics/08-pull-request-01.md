---
phase: 8
iteration: 01
generated: 2026-04-04
---

PR Title: Add complete synthetic demo mode with full trading pipeline

Closes: #49

## What problem does this solve?

Demo mode previously generated minimal synthetic data — 2 hardcoded instruments with a simple random walk, stub risk checks that always pass, zero-valued positions, and no integration with the platform's strategy, analytics, or post-trade modules. This made the TUI demo useless for showcasing the platform's capabilities.

This feature rewrites demo mode to exercise the full trading pipeline: realistic multi-instrument price generation, real order lifecycle (risk → OMS → matching → positions → P&L), automated strategy signals with algo execution, and real-time analytics — all running autonomously and visible in the TUI.

## User-facing changes

- **8 instruments** visible in TUI (was 2): BTC-USD, ETH-USD, SOL-USD, ADA-USD, BTC-USD-PERP, ETH-USD-PERP, SOL-USD-PERP, BTC-USD-20231229
- **Realistic price dynamics**: correlated GBM + mean-reversion model produces realistic candles and cross-instrument spreads
- **Real order pipeline**: manual orders now go through pre-trade risk checks, book matching, and real position tracking with P&L
- **Automated trading**: basis and funding arb strategies detect opportunities and execute via TWAP algo slicing
- **Live analytics**: VPIN toxicity scores per instrument, TCA reports on algo completion, periodic EOD P&L snapshots
- **Real positions**: position panel shows actual quantities, average costs, and unrealized/realized P&L (was all zeros)

## Implementation summary

**Key design decisions** (from Phase 3):

- **8 instruments (4 spot + 3 perps + 1 dated)**: covers all strategy/analytics needs; enables basis, funding arb, and multi-asset portfolio without straining 100ms tick budget
- **GBM + mean-reversion price model**: produces realistic candles and spreads; correlated spot/perp pairs enable meaningful strategy signals; all integer math (i64 fixed-point)
- **Book-matching fill simulation**: market orders fill at BBO, limit orders rest and fill on price cross; synthetic book is read-only (standard paper-trading model)
- **Real PreTradeRisk with demo config**: generous limits (10 BTC max order, 50 BTC position, 10% price band); rejected orders visible in TUI
- **Basis + funding_arb strategies, TWAP algo**: full signal→algo→order→fill→position pipeline; TWAP is simplest algo (time-based)
- **TCA + VPIN analytics**: TCA measures algo execution quality; VPIN monitors per-tick toxicity
- **EOD P&L snapshots**: periodic P&L from real positions + synthetic marks
- **Funding rate derived from spot/perp basis**: `rate = k * (perp_mid - spot_mid) / spot_mid` — natural and observable

**Edge cases handled** (from Phase 5):

- Negative price after mean-reversion overshoot: clamped to `base_price / 10` minimum
- Market order on empty book: fills at base_price as fallback
- Position reversal (long → short): PositionManager handles natively
- Risk self-pointer stability: PreTradeRisk heap-allocated so pointer is stable for OMS lifetime
- Strategy signal with full algo array (16 concurrent): gracefully skipped
- VPIN not yet ready (first bucket unfilled): `vpin_valid[i] = false` in StatusUpdate
- TCA with zero fills (all slices risk-rejected): report with fill_rate=0

**Test checkpoints passed** (from Phase 7):

- Phase 1 — `zig build test-desk 2>&1`: passed (9/9 tests)
- Phase 2 — `zig build test-desk 2>&1`: passed (13/13 tests)
- Phase 3 — `zig build test-desk 2>&1`: passed (13/13 tests)
- Phase 4 — `zig build test-desk 2>&1`: passed (13/13 tests)

## Implementation approach

**Phase 1 — Multi-Instrument Price Model**: Rewrote `synthetic.zig` from a 2-instrument random walk to an 8-instrument correlated GBM + mean-reversion model with `InstrumentConfig` structs. Expanded `engine.zig` arrays from [2] to [8]. Added `computeFundingRate()` for perp/spot basis derivation. Added integration tests to `main.zig` (Zig 0.15 `addTest` only collects from root module file).

**Phase 2 — Real Order Pipeline**: Created `matching_engine.zig` with `MatchingEngine` supporting market fills at BBO, limit order crossing/resting, and `checkRestingOrders()` per tick. Replaced `riskValidateStub` with real `PreTradeRisk.validate()` via function-pointer DI. Replaced `SimplePosition` array with real `PositionManager`. 4 matching engine tests.

**Phase 3 — Strategy + Algo Automation**: Wired `BasisStrategy` and `FundingArbStrategy` into the engine loop. Added `ActiveAlgo` tracking with TWAP instances. Created desk-specific module wrappers (`basis_desk_mod`, `funding_arb_desk_mod`) to resolve Zig multi-module orderbook import conflicts. Added `strategy_state` to `StatusUpdate`.

**Phase 4 — Analytics + Post-Trade**: Added 8 `VpinCalculator` instances, `TcaEngine`, and `EodProcessor` to the engine. Wired VPIN scoring per tick, TCA reporting on algo completion, and periodic EOD P&L snapshots (every 6000 ticks). Added `TcaReportEvent` and `EodReportEvent` variants to `EngineEvent` with no-op handlers in `main.zig`.

## Exceptions and deviations

- **Zig 0.15 test collection**: `addTest` only collects tests from the root module file, not transitively. Integration tests were added to `main.zig` instead of relying on transitive collection from imported modules.
- **Instrument index correction**: Plan specified BTC-USD-PERP at index 4, but the actual `INSTRUMENTS` array has it at index 1 (after reordering). Used correct indices from the actual array.
- **Desk-specific module wrappers**: Build conflict with `orderbook_mod` resolved by creating `basis_desk_mod` and `funding_arb_desk_mod` that share the same orderbook module instance as the desk build targets.

## How to verify

### Automated
- [ ] `zig build test-desk 2>&1` — all 13 tests pass
- [ ] `zig build` — full project builds without errors

### Manual
- [ ] Run `zig build run-desk` and observe 8 instruments in the TUI orderbook panel
- [ ] Observe realistic price movements with correlated spot/perp pairs
- [ ] Submit a manual order and verify it goes through risk → matching → position update
- [ ] Watch for automated strategy signals (basis/funding arb) appearing in status
- [ ] Verify position panel shows non-zero quantities and P&L after fills

## Breaking changes / migration notes

None — all changes are internal to the demo mode engine. The TUI receives more data through existing event channels. New `EngineEvent` variants (`tca_report`, `eod_report`) have no-op handlers.

## Changelog entry

Add complete synthetic demo mode with 8-instrument correlated price model, real order pipeline (risk, matching, positions, P&L), automated basis/funding-arb strategies with TWAP execution, and live VPIN/TCA/EOD analytics
