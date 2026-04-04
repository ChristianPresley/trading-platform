---
phase: 3
iteration: 01
generated: 2026-04-04
---

# Design: Complete and Extensive Synthetics for Demo Mode

Research: .claude/specs/demo-mode-synthetics/02-research-01.md

## Current State

The demo mode in `trading/desk/` generates minimal synthetic data:

- **SyntheticFeed** (`trading/desk/synthetic.zig:22-28`): random walk for 2 hardcoded instruments (BTC-USD, ETH-USD) with equal probability up/down, tick_size=0.001 USD, 20-level book depth, full snapshot every 20 ticks
- **Engine loop** (`trading/desk/engine.zig:144-219`): 100ms tick rate, pushes orderbook snapshots and candle updates to TUI via SPSC ring buffers (capacity 256)
- **Stubs**: `riskValidateStub` always passes (`engine.zig:24-29`), `storeAppendStub` discards events (`engine.zig:31-36`), `unrealized_pnl` hardcoded to 0 (`engine.zig:185`), `filled_qty` hardcoded to 0 (`engine.zig:245,260`)
- **No integration**: strategies (`trading/strategies/`), algos (`sdk/domain/algos/`), analytics (`trading/analytics/`), and post-trade (`sdk/domain/post_trade/`) are standalone modules with test coverage but no wiring into the engine loop

The platform has a rich SDK that demo mode doesn't exercise: full OMS with 14 states and state machine (`sdk/domain/oms.zig:71-164`), position tracking with FIFO/LIFO/avg_cost (`sdk/domain/positions.zig:86-226`), 6 execution algos, pre-trade risk with 6 check types (`sdk/domain/risk/pre_trade.zig:89-167`), tick store with delta encoding, 3 bar aggregator types, post-trade (recon, allocation, EOD), 2 strategies (basis, funding_arb), and 3 analytics modules (TCA, VPIN, attribution).

## Desired End State

Demo mode generates complete synthetic data that exercises the full platform pipeline visible in the TUI:

- **8 instruments** with realistic correlated price dynamics across spot, perpetual, and dated futures
- **Full order lifecycle**: submit → risk check → OMS processing → book-matched fills → position updates → P&L computation
- **Automated strategy signals**: basis and funding arb strategies detect opportunities and submit orders through TWAP algo slicing
- **Real-time analytics**: VPIN toxicity monitoring per tick, TCA reports after algo completions
- **Periodic EOD snapshots**: realized + unrealized P&L with position snapshots
- All of this running autonomously with the user able to observe and also submit manual orders that go through the same pipeline

## Patterns to Follow

- **Function-pointer DI for OMS**: found at `02-research-01.md:238-240` — `risk_validate_fn` and `store_append_fn` injected at OMS init. Replace stubs with real PreTradeRisk.validate() and a demo event store.
- **MockExchangeResponse injection**: found at `02-research-01.md:149-150` — executors already support mock fill injection. The fill sim can follow this established pattern for producing fill events.
- **L2Book as universal interface**: found at `02-research-01.md:439` — strategies, algos, and sniper all consume the same book interface. Enriching the synthetic feed automatically feeds all consumers.
- **BarAggregator already wired**: found at `02-research-01.md:281-284` — candle aggregation from midpoints is already in the engine loop. Improved price dynamics produce better candles for free.
- **Fixed-point i64 everywhere**: found at `02-research-01.md:436` — all prices are i64 with 8 decimal places. The new price model must use the same convention, no floating point.
- **Seeded PRNG**: found at `02-research-01.md:15` — current synthetic uses `rand.boolean()` from Zig stdlib. Continue using seeded PRNG for deterministic reproducibility.
- **ChildOrder output from algos**: found at `02-research-01.md:204-206` — all algos produce `ChildOrder` with instrument, side, quantity, order_type, price. TWAP's `nextSlice(now)` returns this directly.

## Patterns to Avoid

- **Hardcoded instrument list**: found at `02-research-01.md:13` — two instruments with magic number base prices. Replace with a data-driven instrument config table.
- **Always-pass risk stub**: found at `02-research-01.md:33-35` — `riskValidateStub` defeats the purpose of the risk system. Wire real PreTradeRisk instead.
- **Zero-valued positions**: found at `02-research-01.md:49-50` — `unrealized_pnl = 0` and `filled_qty = 0` make position/OMS panels meaningless. Use real position tracking from fills.
- **SimplePosition array**: found at `02-research-01.md:51` — engine uses a flat array with hardcoded 0 P&L instead of the real PositionManager (`sdk/domain/positions.zig`). Replace with real position tracking.
- **Disconnected modules**: found at `02-research-01.md:441` — strategies and analytics have no integration with the engine. This is the core gap this feature addresses.

## Resolved Design Decisions

| Decision | Choice | Reason |
| --- | --- | --- |
| Instrument count | 8 (4 spot + 3 perps + 1 dated) | Covers all strategy/analytics needs; sufficient for basis, funding arb, and multi-asset portfolio without straining 100ms tick budget or ring buffer |
| Price model | GBM + mean-reversion, cross-instrument correlation | Produces realistic candles and spreads; correlated spot/perp pairs enable meaningful strategy signals; all integer math |
| Fill simulation | Book-matching against synthetic book | Market orders fill at BBO, limit orders rest and fill on price cross; does not modify synthetic book (standard paper-trading); exercises full OMS state machine |
| Risk integration | Real PreTradeRisk with demo config | ~20 lines to wire; generous limits (10 BTC max order, 50 BTC position, 10% price band); rejected orders visible in TUI |
| Strategy/algo scope | Basis + funding_arb strategies, TWAP algo | Full signal→algo→order→fill→position pipeline; TWAP is simplest algo (time-based only); other algos deferred |
| Analytics scope | TCA + VPIN | TCA measures algo execution quality from natural fill data; VPIN monitors toxicity per tick; attribution skipped (needs artificial benchmark) |
| Post-trade scope | EOD P&L snapshots only | Periodic P&L from real positions + synthetic marks; reconciliation (needs two data sources) and allocation (needs multi-account) skipped |
| Architecture | Expand trading/desk/ in place | Rewrite synthetic.zig, add matching_engine.zig, expand engine.zig loop; desk-specific code stays in desk directory |
| Funding rate | Derived from spot/perp basis | `rate = k * (perp_mid - spot_mid) / spot_mid`; natural, observable, user can see why funding arb triggers |

## Approach

### Phase 1: Synthetic Market Model Rewrite

Rewrite `trading/desk/synthetic.zig` from a simple random walk to a multi-instrument GBM + mean-reversion model. Define an `InstrumentConfig` struct per instrument (base_price, volatility, mean_reversion_strength, drift) and a correlation structure for spot/perp pairs. The 8 instruments are: BTC-USD, ETH-USD, SOL-USD, ADA-USD (spot), BTC-USD-PERP, ETH-USD-PERP, SOL-USD-PERP (perpetuals), BTC-USD-20231229 (dated future).

Price updates use fixed-point i64 arithmetic: `new_price = price + drift + mean_reversion_pull + volatility_scaled_random_step`. Spot/perp correlation is implemented by sharing the base price random step with a small independent noise component for the basis. The funding rate for each perp is derived as `k * (perp_mid - spot_mid) / spot_mid`, clamped to a realistic range. Book depth remains 20 levels per side with quantities derived from the price model's volatility state.

### Phase 2: Fill Simulation Engine

Create `trading/desk/matching_engine.zig` — a synthetic matching engine that processes orders against the synthetic book. Market orders fill immediately at the book's best bid (sells) or best ask (buys), walking price levels if order quantity exceeds top-of-book. Limit orders are stored in a resting order list and checked against BBO each tick; when the synthetic price crosses the limit price, the order fills. Partial fills occur when book liquidity at a level is less than order quantity.

The matching engine produces `FillInfo` structs (`sdk/domain/oms.zig:50-53`) that feed into the real OMS via `onExecution()` with appropriate `ExecType` (fill, partial_fill). The synthetic book is read-only — fills do not deplete synthetic liquidity (standard paper-trading model).

### Phase 3: Engine Loop Integration

Expand `trading/desk/engine.zig` to wire the full pipeline:

1. Replace `riskValidateStub` with real `PreTradeRisk.validate()` using demo config (max_order_size=1M, max_notional=50T, max_position=5M, max_order_rate=100, price_band_pct=0.10, dedup_window_ms=1000)
2. Replace `SimplePosition` array with real `PositionManager` from `sdk/domain/positions.zig`
3. After each tick: feed L2Books to basis strategy (`basis.onMarketData(spot, futures)`) and funding arb strategy (`funding_arb.onFundingRate(rate, time)` + `funding_arb.onMarketData(spot, perp)`)
4. When a strategy returns a Signal: create a parent order, initialize a TWAP instance with appropriate params, add to an active-algos list
5. Each tick: call `twap.nextSlice(now)` on active algos; each returned ChildOrder goes through risk → OMS → matching engine → position update
6. Each tick per instrument: call `vpin.onTrade(mid_price, volume, side)` for real-time toxicity
7. When a TWAP algo completes: compute TCA report from collected fills and benchmark (arrival price at signal time, market VWAP during execution)
8. Every N ticks (simulated EOD): call `eod.computeDailyPnl(positions, marks)` for P&L snapshot
9. Push enriched events to TUI: real position updates with P&L, order updates with fill quantities, strategy signals, analytics scores

### Phase 4: Message Types and TUI Events

Extend `trading/desk/messages.zig` EngineEvent as needed for new event types (strategy signals, analytics scores, EOD reports) or pack them into existing variants (status updates). The `position_update` variant switches from hardcoded zeros to real PositionManager output. The `order_update` variant includes real fill quantities and prices. The `status` variant includes VPIN score and strategy state.

## Open Questions

(none — all resolved during design discussion)
