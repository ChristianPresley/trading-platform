---
phase: 4
iteration: 01
generated: 2026-04-04
---

# Outline: Complete and Extensive Synthetics for Demo Mode

Design: .claude/specs/demo-mode-synthetics/03-design-01.md

## Overview

Deliver demo mode synthetics in four vertical slices, each end-to-end testable. Phase 1 replaces the 2-instrument random walk with an 8-instrument correlated price model visible in the TUI. Phase 2 adds a real order pipeline (risk, matching, positions, P&L) so user orders produce actual fills. Phase 3 wires automated strategies and TWAP algo execution. Phase 4 adds live analytics (VPIN, TCA) and periodic EOD snapshots.

## Phase 1: Multi-Instrument Price Model + TUI Display
**Delivers**: 8 instruments with realistic correlated prices and candles visible in the TUI
**Layers touched**: trading/desk/synthetic.zig (rewrite), trading/desk/engine.zig (expand), trading/desk/messages.zig (instrument capacity)

### Key types / signatures introduced

```zig
// trading/desk/synthetic.zig
pub const InstrumentConfig = struct {
    symbol: []const u8,
    base_price: i64,          // fixed-point i64, 8 decimals
    volatility: i64,          // scaled tick-size units
    mean_reversion_strength: i64,
    drift: i64,
    correlation_group: u8,    // spot/perp pairs share group
};

pub const SyntheticFeed = struct {
    instruments: [8]InstrumentConfig,
    books: [8]L2Book,
    rng: std.Random,
    // ...
    pub fn init(seed: u64) SyntheticFeed;
    pub fn tick(self: *SyntheticFeed) void;  // updates all 8 instruments
};
```

```zig
// trading/desk/engine.zig — expanded from 2 to 8 instruments
bar_aggregators: [8]BarAggregator,  // was [2]
```

### Test checkpoint
- Type: Automated
- Build and run demo mode with a fixed seed; assert all 8 instruments produce L2Books with valid `bestBid()`, `bestAsk()`, `midPrice()` each tick; verify spot/perp pairs have correlated mid-prices (difference within expected basis range); verify BarAggregator produces candles for all 8 instruments

---

## Phase 2: Real Order Pipeline (Risk, Matching, Positions, P&L)
**Delivers**: User submits orders in TUI; orders are risk-checked, filled against the synthetic book, and produce real position P&L
**Layers touched**: trading/desk/matching_engine.zig (new), trading/desk/engine.zig (pipeline wiring), trading/desk/messages.zig (real fill/position data)
**Depends on**: Phase 1

### Key types / signatures introduced

```zig
// trading/desk/matching_engine.zig (new file)
pub const MatchingEngine = struct {
    resting_orders: std.ArrayList(RestingOrder),

    pub fn init(allocator: std.mem.Allocator) MatchingEngine;

    /// Process a new order against the synthetic book. Returns immediate fill(s) for
    /// market orders or BBO-crossing limits; stores non-crossing limits as resting.
    pub fn processOrder(self: *MatchingEngine, order: *const Order, book: *const L2Book) []FillInfo;

    /// Called each tick — checks resting limit orders against current BBO, returns fills.
    pub fn checkRestingOrders(self: *MatchingEngine, books: *const [8]L2Book) []FillInfo;
};

const RestingOrder = struct {
    order_id: u64,
    instrument_idx: u8,
    side: Side,
    price: i64,
    remaining_qty: i64,
};
```

```zig
// trading/desk/engine.zig — replacements
risk: PreTradeRisk,                    // replaces dummy_risk + riskValidateStub
positions: PositionManager,            // replaces SimplePosition array

fn riskValidateWrapper(risk_ptr: *anyopaque, order: *const Order) bool;  // adapts PreTradeRisk.validate() to OMS fn-ptr interface
```

Demo risk config: `max_order_size=1_000_000_00000000` (1M), `max_notional=50_000_000_00000000` (50T), `max_position=5_000_000_00000000` (5M), `max_order_rate=100`, `price_band_pct=0.10`, `dedup_window_ms=1000`

### Test checkpoint
- Type: Automated
- Submit a market buy order for BTC-USD via engine; verify OMS transitions: `pending_new` → `new` → `filled`; verify `PositionManager` has nonzero quantity and `unrealizedPnl(mark)` returns nonzero value; submit an order exceeding `max_order_size` and verify risk rejection (OMS status = `rejected`)

---

## Phase 3: Strategy + Algo Automation
**Delivers**: Basis and funding arb strategies autonomously detect opportunities and trade through the full pipeline; user observes strategy activity in TUI
**Layers touched**: trading/desk/engine.zig (strategy/algo wiring)
**Depends on**: Phase 1 (correlated spot/perp prices produce meaningful basis), Phase 2 (order pipeline processes strategy-generated orders)

### Key types / signatures introduced

```zig
// trading/desk/engine.zig — new fields
basis_strategy: basis.BasisStrategy,
funding_arb: funding_arb.FundingArbStrategy,
active_algos: std.ArrayList(ActiveAlgo),

const ActiveAlgo = struct {
    twap: Twap,
    parent_order_id: u64,
    instrument_idx: u8,
    side: Side,
    arrival_price: i64,       // for TCA benchmark
};

/// Called each tick after price update
fn runStrategies(self: *Engine) void;

/// Called each tick — advances TWAP slices, submits child orders through pipeline
fn runAlgos(self: *Engine) void;
```

Funding rate derivation (per tick, per perp):
```zig
fn computeFundingRate(spot_mid: i64, perp_mid: i64) f64;
// rate = k * (perp_mid - spot_mid) / spot_mid, clamped to [-0.01, 0.01]
```

### Test checkpoint
- Type: Automated
- Initialize with a seed that produces BTC spot/futures basis > entry threshold; run N ticks; verify basis strategy emits a Signal; verify TWAP creates child orders; verify at least one child order reaches `filled` status in OMS; verify PositionManager has positions in both spot and futures instruments

---

## Phase 4: Analytics + Post-Trade
**Delivers**: Live VPIN toxicity scores in TUI, TCA reports after algo completions, periodic EOD P&L snapshots
**Layers touched**: trading/desk/engine.zig (analytics/post-trade wiring), trading/desk/messages.zig (new event data)
**Depends on**: Phase 3 (algo completions generate TCA data, trade flow feeds VPIN)

### Key types / signatures introduced

```zig
// trading/desk/engine.zig — new fields
vpin: [8]Vpin,                        // one per instrument
tca_pending: std.ArrayList(TcaPending),
eod_tick_counter: u64,

const TcaPending = struct {
    algo_idx: usize,
    fills: std.ArrayList(tca.Execution),
    benchmark: tca.Benchmark,
};

/// Called each tick — feeds trade data to VPIN for each instrument
fn runVpin(self: *Engine) void;

/// Called when a TWAP completes — computes TCA report from collected fills
fn completeTca(self: *Engine, pending: *TcaPending) tca.TcaReport;

/// Called every N ticks (simulated EOD interval)
fn runEod(self: *Engine) void;
```

```zig
// trading/desk/messages.zig — extended StatusUpdate or new variants
pub const StatusUpdate = struct {
    tick: u64,
    engine_time_ns: u64,
    connected: bool,
    vpin_scores: [8]?f64,             // per-instrument VPIN (null until first bucket)
    strategy_state: []const u8,       // e.g. "basis:long_basis funding:flat"
};
// EOD and TCA reports pushed via existing or new EngineEvent variants
```

### Test checkpoint
- Type: Automated
- Run enough ticks (with known seed) to fill at least one VPIN bucket; verify `vpin.onTrade()` returns non-null score; trigger a TWAP completion and verify `TcaReport` has nonzero `is_cost_bps` and `fill_rate > 0`; run past EOD tick threshold and verify `DailyPnlReport` is produced with `realized_pnl + unrealized_pnl = total_pnl`

---

## Dependencies
- Phase 2 must complete before Phase 3 because: strategies generate orders that require the matching engine, real risk, and position tracking from Phase 2
- Phase 1 must complete before Phase 2 because: the matching engine fills orders against the 8-instrument synthetic books from Phase 1
- Phase 3 must complete before Phase 4 because: TCA requires algo completions from Phase 3, and VPIN needs the trade volume generated by strategy activity to produce meaningful scores
