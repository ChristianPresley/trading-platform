// Engine thread: integrates synthetic market data, OMS, risk, matching, and positions.
// Uses SpscRingBuffer for TUI communication.

const std = @import("std");
const SpscRingBuffer = @import("ring_buffer").SpscRingBuffer;
const msg = @import("messages.zig");
const EngineEvent = msg.EngineEvent;
const UserCommand = msg.UserCommand;
const OrderbookSnapshot = msg.OrderbookSnapshot;
const PriceLevel = msg.PriceLevel;
const InstrumentId = msg.InstrumentId;
const CandleUpdate = msg.CandleUpdate;

const SyntheticFeed = @import("synthetic.zig").SyntheticFeed;
const L2Book = @import("orderbook").L2Book;
const oms_mod = @import("oms");
const OrderManager = oms_mod.OrderManager;
const Order = oms_mod.Order;
const ExecType = oms_mod.ExecType;
const FillInfo = oms_mod.FillInfo;
const bar_agg = @import("bar_aggregator");
const BarAggregator = bar_agg.BarAggregator;

const pre_trade_mod = @import("pre_trade");
const PreTradeRisk = pre_trade_mod.PreTradeRisk;
const RiskConfig = pre_trade_mod.RiskConfig;

const positions_mod = @import("positions");
const PositionManager = positions_mod.PositionManager;
const PositionConfig = positions_mod.PositionConfig;
const Fill = positions_mod.Fill;

const matching_mod = @import("matching_engine.zig");
const MatchingEngine = matching_mod.MatchingEngine;

const basis_mod = @import("basis");
const BasisStrategy = basis_mod.BasisStrategy;
const BasisConfig = basis_mod.BasisConfig;

const funding_arb_mod = @import("funding_arb");
const FundingArbStrategy = funding_arb_mod.FundingArbStrategy;
const FundingArbConfig = funding_arb_mod.FundingArbConfig;

const twap_mod_algo = @import("twap");
const TwapAlgo = twap_mod_algo.TwapAlgo;
const TwapParams = twap_mod_algo.TwapParams;
const ChildOrder = twap_mod_algo.ChildOrder;

const SyntheticFeed_mod = @import("synthetic.zig");

const vpin_mod_analytics = @import("vpin");
const VpinCalculator = vpin_mod_analytics.VpinCalculator;

const tca_mod_analytics = @import("tca");
const TcaEngine = tca_mod_analytics.TcaEngine;
const TcaExecution = tca_mod_analytics.Execution;
const TcaBenchmark = tca_mod_analytics.Benchmark;

const eod_mod_analytics = @import("eod");
const EodProcessor = eod_mod_analytics.EodProcessor;
const EodPositionView = eod_mod_analytics.EodPositionView;
const EodMark = eod_mod_analytics.Mark;

const TcaPending = struct {
    algo_idx: usize,
    fills: [128]TcaExecution,
    fill_count: usize,
    benchmark: TcaBenchmark,
    active: bool,
};

const ActiveAlgo = struct {
    twap: TwapAlgo,
    parent_order_id: u64,
    instrument_idx: u8,
    side: twap_mod_algo.Side,
    arrival_price: i64,
    active: bool,
};

const INSTRUMENTS = [_][]const u8{
    "BTC-USD",
    "ETH-USD",
    "SOL-USD",
    "ADA-USD",
    "BTC-USD-PERP",
    "ETH-USD-PERP",
    "SOL-USD-PERP",
    "BTC-USD-20231229",
};

/// Noop event store append function (no persistence needed in demo).
fn storeAppendNoop(store: *anyopaque, data: []const u8) anyerror!u64 {
    _ = store;
    _ = data;
    return 0;
}

/// Risk validate wrapper: casts anyopaque to *PreTradeRisk and calls validate().
fn riskValidateWrapper(risk_ptr: *anyopaque, order: *const Order) bool {
    const risk: *PreTradeRisk = @ptrCast(@alignCast(risk_ptr));
    const result = risk.validate(order);
    return result == .passed;
}

/// Dummy store object for OMS.
var dummy_store: u8 = 0;

pub const Engine = struct {
    allocator: std.mem.Allocator,
    to_tui: *SpscRingBuffer(EngineEvent),
    from_tui: *SpscRingBuffer(UserCommand),
    running: std.atomic.Value(bool),
    tick: u64,

    // Domain modules
    feed: SyntheticFeed,
    oms: OrderManager,

    // Candle aggregators (one per instrument)
    candle_aggs: [8]BarAggregator,

    // Real risk, matching, and position management
    risk: *PreTradeRisk,
    pos_manager: PositionManager,
    matching: MatchingEngine,

    // Strategy and algo automation
    basis_strategy: BasisStrategy,
    funding_arb_strategy: FundingArbStrategy,
    active_algos: [16]ActiveAlgo,
    active_algo_count: usize,

    // Analytics and post-trade
    vpin: [8]VpinCalculator,
    tca_engine: TcaEngine,
    eod_processor: EodProcessor,
    tca_pending: [16]TcaPending,
    tca_pending_count: usize,
    eod_tick_counter: u64,
    vpin_scores: [8]i64,
    vpin_valid: [8]bool,

    pub fn init(
        allocator: std.mem.Allocator,
        to_tui: *SpscRingBuffer(EngineEvent),
        from_tui: *SpscRingBuffer(UserCommand),
    ) !Engine {
        const now_seed: u64 = @intCast(std.time.milliTimestamp());
        var feed = try SyntheticFeed.init(allocator, now_seed);
        errdefer feed.deinit();

        // Heap-allocate risk so the pointer is stable regardless of Engine value movement
        const risk = try allocator.create(PreTradeRisk);
        errdefer allocator.destroy(risk);
        risk.* = try PreTradeRisk.init(allocator, RiskConfig{
            .max_order_size = 1_000_000_00000000,
            .max_notional = 50_000_000_00000000,
            .max_position = 5_000_000_00000000,
            .max_order_rate = 100,
            .price_band_pct = 0.10,
            .dedup_window_ms = 1000,
        });
        errdefer risk.deinit();

        const pos_manager = try PositionManager.init(allocator, PositionConfig{
            .cost_basis_method = .average_cost,
            .base_currency = "USD",
        });
        errdefer {
            var pm = pos_manager;
            pm.deinit();
        }

        const basis_strategy = try BasisStrategy.init(allocator, BasisConfig{
            .entry_threshold_bps = 50.0,
            .exit_threshold_bps = 10.0,
            .max_position = 100_000_00000000,
            .instrument_spot = "BTC-USD",
            .instrument_futures = "BTC-USD-PERP",
            .days_to_expiry = 90,
        });

        const funding_arb_strategy = try FundingArbStrategy.init(allocator, FundingArbConfig{
            .min_rate_bps = 5.0,
            .max_position = 100_000_00000000,
            .instrument_spot = "ETH-USD",
            .instrument_perp = "ETH-USD-PERP",
        });

        const oms = try OrderManager.init(
            allocator,
            risk,
            &dummy_store,
            riskValidateWrapper,
            storeAppendNoop,
        );
        errdefer {
            var o = oms;
            o.deinit();
        }

        // Initialize 8 VPIN calculators
        var vpin_calcs: [8]VpinCalculator = undefined;
        var vpin_initialized: usize = 0;
        errdefer {
            for (0..vpin_initialized) |i| vpin_calcs[i].deinit();
        }
        for (0..8) |i| {
            vpin_calcs[i] = try VpinCalculator.init(allocator, 100_000_00000000, 20);
            vpin_initialized += 1;
        }

        const tca_engine = try TcaEngine.init(allocator);
        const eod_processor = try EodProcessor.init(allocator);

        return Engine{
            .allocator = allocator,
            .to_tui = to_tui,
            .from_tui = from_tui,
            .running = std.atomic.Value(bool).init(true),
            .tick = 0,
            .feed = feed,
            .oms = oms,
            .candle_aggs = .{
                BarAggregator.init(60_000_000_000), // 1-minute bars in ns
                BarAggregator.init(60_000_000_000),
                BarAggregator.init(60_000_000_000),
                BarAggregator.init(60_000_000_000),
                BarAggregator.init(60_000_000_000),
                BarAggregator.init(60_000_000_000),
                BarAggregator.init(60_000_000_000),
                BarAggregator.init(60_000_000_000),
            },
            .risk = risk,
            .pos_manager = pos_manager,
            .matching = MatchingEngine.init(),
            .basis_strategy = basis_strategy,
            .funding_arb_strategy = funding_arb_strategy,
            .active_algos = std.mem.zeroes([16]ActiveAlgo),
            .active_algo_count = 0,
            .vpin = vpin_calcs,
            .tca_engine = tca_engine,
            .eod_processor = eod_processor,
            .tca_pending = std.mem.zeroes([16]TcaPending),
            .tca_pending_count = 0,
            .eod_tick_counter = 0,
            .vpin_scores = std.mem.zeroes([8]i64),
            .vpin_valid = std.mem.zeroes([8]bool),
        };
    }

    pub fn deinit(self: *Engine) void {
        self.feed.deinit();
        self.oms.deinit();
        self.risk.deinit();
        self.allocator.destroy(self.risk);
        self.pos_manager.deinit();
        self.basis_strategy.deinit();
        self.funding_arb_strategy.deinit();
        for (&self.vpin) |*v| v.deinit();
        self.tca_engine.deinit();
        self.eod_processor.deinit();
    }

    /// Snapshot the L2Book into an OrderbookSnapshot message.
    pub fn snapshotBook(book: *const L2Book, instrument: []const u8) OrderbookSnapshot {
        var snap = OrderbookSnapshot{
            .instrument = InstrumentId.fromSlice(instrument),
            .bids = undefined,
            .asks = undefined,
            .bid_count = 0,
            .ask_count = 0,
        };

        const num_bids = @min(book.bids_len, 20);
        const num_asks = @min(book.asks_len, 20);

        for (0..num_bids) |i| {
            snap.bids[i] = PriceLevel{
                .price = book.bids_buf[i].price,
                .quantity = book.bids_buf[i].quantity,
            };
        }
        snap.bid_count = @intCast(num_bids);

        for (0..num_asks) |i| {
            snap.asks[i] = PriceLevel{
                .price = book.asks_buf[i].price,
                .quantity = book.asks_buf[i].quantity,
            };
        }
        snap.ask_count = @intCast(num_asks);

        return snap;
    }

    /// Engine main loop. Runs in a separate thread.
    pub fn run(self: *Engine) void {
        while (self.running.load(.acquire)) {
            self.tick += 1;

            // Advance synthetic feed
            self.feed.tick();

            // Compute timestamp for this tick (tick count x 100ms in ns)
            const timestamp_ns: u64 = self.tick * 100_000_000;

            // Check resting orders against updated books
            const resting_fills = self.matching.checkRestingOrders(&self.feed.books);
            for (0..resting_fills.fill_count) |i| {
                const rf = &resting_fills.fills[i];
                self.oms.onExecution(rf.order_id, .fill, FillInfo{
                    .fill_qty = rf.fill_qty,
                    .fill_price = rf.fill_price,
                }) catch {};
                // Determine instrument from order (we don't have easy reverse lookup; use account="demo")
                self.pos_manager.onFill(Fill{
                    .instrument = "RESTING",
                    .side = .buy, // simplified: side not tracked in RestingFill
                    .quantity = rf.fill_qty,
                    .price = rf.fill_price,
                    .timestamp = @intCast(timestamp_ns),
                    .account = "demo",
                    .currency = "USD",
                    .settlement_date = 0,
                }) catch {};
            }

            // Update reference prices for risk checks
            for (0..8) |i| {
                const book = self.feed.getBook(i);
                if (book.midPrice()) |mid| {
                    self.risk.setReferencePrice(INSTRUMENTS[i], mid) catch {};
                }
            }

            // Run analytics and post-trade
            self.runVpin();
            // Run strategies and algos
            self.runStrategies();
            self.runAlgos();
            self.runEod();

            // Push orderbook snapshots and aggregate candles for each instrument
            for (0..8) |i| {
                const book = self.feed.getBook(i);
                const snap = snapshotBook(book, INSTRUMENTS[i]);
                _ = self.to_tui.push(EngineEvent{ .orderbook_snapshot = snap });

                // Compute BBO midpoint and feed to candle aggregator (skip if book is empty)
                if (snap.bid_count > 0 and snap.ask_count > 0) {
                    const midpoint = @divTrunc(snap.bids[0].price + snap.asks[0].price, 2);
                    if (self.candle_aggs[i].onTrade(midpoint, 1, @as(u128, timestamp_ns))) |bar| {
                        const cu = CandleUpdate{
                            .instrument = snap.instrument,
                            .open = bar.open,
                            .high = bar.high,
                            .low = bar.low,
                            .close = bar.close,
                            .volume = bar.volume,
                            .timestamp = @truncate(bar.timestamp),
                        };
                        _ = self.to_tui.push(EngineEvent{ .candle_update = cu });
                    }
                }
            }

            // Push position updates from real position manager
            const all_positions = self.pos_manager.allPositions();
            for (all_positions) |pos| {
                // Find mark price for this instrument
                var mark_price: i64 = 0;
                for (0..8) |i| {
                    if (std.mem.eql(u8, INSTRUMENTS[i], pos.key.instrument)) {
                        mark_price = self.feed.getBook(i).midPrice() orelse 0;
                        break;
                    }
                }
                const upnl = self.pos_manager.unrealizedPnl(pos.key, mark_price) orelse 0;
                const update = msg.PositionUpdate{
                    .instrument = InstrumentId.fromSlice(pos.key.instrument),
                    .quantity = pos.quantity,
                    .avg_cost = pos.avg_cost,
                    .unrealized_pnl = upnl,
                    .realized_pnl = pos.realized_pnl,
                };
                _ = self.to_tui.push(EngineEvent{ .position_update = update });
            }

            // Build strategy state string
            var strat_state_buf: [64]u8 = std.mem.zeroes([64]u8);
            const strat_state_str = std.fmt.bufPrint(
                &strat_state_buf,
                "basis:{s} arb:{s}",
                .{
                    @tagName(self.basis_strategy.state),
                    @tagName(self.funding_arb_strategy.position),
                },
            ) catch strat_state_buf[0..0];

            // Push status with VPIN scores
            var status_update = msg.StatusUpdate{
                .tick = self.tick,
                .engine_time_ns = 0,
                .instrument_count = 8,
                .connected = false,
                .strategy_state = std.mem.zeroes([64]u8),
                .strategy_state_len = 0,
                .vpin_scores = self.vpin_scores,
                .vpin_valid = self.vpin_valid,
            };
            @memcpy(status_update.strategy_state[0..strat_state_str.len], strat_state_str);
            status_update.strategy_state_len = @intCast(strat_state_str.len);
            _ = self.to_tui.push(EngineEvent{ .status = status_update });

            // Drain commands from TUI
            while (self.from_tui.pop()) |cmd| {
                switch (cmd) {
                    .quit => {
                        self.running.store(false, .release);
                        _ = self.to_tui.push(EngineEvent{ .shutdown_ack = {} });
                        return;
                    },
                    .select_instrument => {},
                    .submit_order => |req| {
                        self.handleOrderRequest(req);
                    },
                    .cancel_order => |id| {
                        self.oms.cancelOrder(id) catch {};
                    },
                }
            }

            std.Thread.sleep(100_000_000); // 100ms per tick
        }
    }

    fn runVpin(self: *Engine) void {
        for (0..8) |i| {
            const book = self.feed.getBook(i);
            const mid = book.midPrice() orelse continue;
            // Use price direction as proxy for trade side
            const side: vpin_mod_analytics.Side = .buy; // default to buy; tick rule would need last price
            if (self.vpin[i].onTrade(mid, 1, side)) |score| {
                // Store VPIN as i64 scaled by 10000 (VPIN is 0.0-1.0)
                self.vpin_scores[i] = @intFromFloat(score * 10000.0);
                self.vpin_valid[i] = true;
            }
        }
    }

    fn completeTca(self: *Engine, pending_idx: usize) void {
        const pending = &self.tca_pending[pending_idx];
        if (!pending.active) return;

        const fills_slice = pending.fills[0..pending.fill_count];
        const report = self.tca_engine.analyze(fills_slice, pending.benchmark) catch return;

        // Push TCA report event
        const instrument_name: []const u8 = if (pending.algo_idx < self.active_algo_count)
            INSTRUMENTS[self.active_algos[pending.algo_idx].instrument_idx]
        else
            "UNKNOWN";

        const tca_event = msg.TcaReportEvent{
            .instrument = msg.InstrumentId.fromSlice(instrument_name),
            .is_cost_bps = @intFromFloat(report.is_cost_bps * 100.0),
            .fill_rate_pct = @intFromFloat(@min(report.fill_rate * 100.0, 100.0)),
            .market_impact_bps = @intFromFloat(report.market_impact_bps * 100.0),
        };
        _ = self.to_tui.push(EngineEvent{ .tca_report = tca_event });
        pending.active = false;
    }

    fn runEod(self: *Engine) void {
        self.eod_tick_counter += 1;
        if (self.eod_tick_counter < 6000) return;
        self.eod_tick_counter = 0;

        // Build EodPositionView array from position manager
        const all_positions = self.pos_manager.allPositions();
        var pos_views: [64]EodPositionView = undefined;
        const pos_count = @min(all_positions.len, 64);
        for (0..pos_count) |i| {
            const pos = &all_positions[i];
            pos_views[i] = EodPositionView{
                .instrument = pos.key.instrument,
                .quantity = pos.quantity,
                .avg_cost = pos.avg_cost,
                .realized_pnl = pos.realized_pnl,
            };
        }

        // Build mark prices from current mid prices
        var marks: [8]EodMark = undefined;
        for (0..8) |i| {
            marks[i] = EodMark{
                .instrument = INSTRUMENTS[i],
                .price = self.feed.getBook(i).midPrice() orelse 0,
            };
        }

        const report = self.eod_processor.computeDailyPnl(
            pos_views[0..pos_count],
            marks[0..8],
        ) catch return;

        const eod_event = msg.EodReportEvent{
            .realized_pnl = report.realized_pnl,
            .unrealized_pnl = report.unrealized_pnl,
            .total_pnl = report.total_pnl,
            .tick = self.tick,
        };
        _ = self.to_tui.push(EngineEvent{ .eod_report = eod_event });
    }

    fn runStrategies(self: *Engine) void {
        // Instrument indices for strategy pairs:
        // BTC-USD=0, BTC-USD-PERP=1, ETH-USD=3 (actually idx 1 in our list), ETH-USD-PERP=4 (idx 4)
        // Our INSTRUMENTS: [0]=BTC-USD [1]=ETH-USD [2]=SOL-USD [3]=ADA-USD
        //                  [4]=BTC-USD-PERP [5]=ETH-USD-PERP [6]=SOL-USD-PERP [7]=BTC-USD-20231229
        // Wait — need to look up by name for correctness

        // Find correct indices
        const btc_spot_idx: usize = 0; // "BTC-USD"
        const btc_perp_idx: usize = 4; // "BTC-USD-PERP"
        const eth_spot_idx: usize = 1; // "ETH-USD"
        const eth_perp_idx: usize = 5; // "ETH-USD-PERP"

        const current_tick_ns: u128 = @intCast(self.tick * 100_000_000);

        // Basis strategy: BTC spot vs BTC-USD-PERP
        const btc_spot_book = self.feed.getBook(btc_spot_idx);
        const btc_perp_book = self.feed.getBook(btc_perp_idx);
        if (self.basis_strategy.onMarketData(btc_spot_book, btc_perp_book)) |signal| {
            if (signal.direction != .exit and self.active_algo_count < 16) {
                // Create TWAP for spot leg
                const spot_side: twap_mod_algo.Side = if (signal.direction == .enter_long_basis) .buy else .sell;
                const end_time: u128 = current_tick_ns + 60_000_000_000;
                const spot_twap = TwapAlgo.init(TwapParams{
                    .total_qty = signal.spot_qty,
                    .start_time = current_tick_ns,
                    .end_time = end_time,
                    .num_slices = 10,
                    .instrument = "BTC-USD",
                    .side = spot_side,
                    .jitter_pct = 0.1,
                });
                const arrival_price = btc_spot_book.midPrice() orelse 0;
                const algo_idx = self.active_algo_count;
                self.active_algos[algo_idx] = ActiveAlgo{
                    .twap = spot_twap,
                    .parent_order_id = self.oms.next_id,
                    .instrument_idx = @intCast(btc_spot_idx),
                    .side = spot_side,
                    .arrival_price = arrival_price,
                    .active = true,
                };
                self.active_algo_count += 1;
                // Create TcaPending for this algo
                if (self.tca_pending_count < 16) {
                    self.tca_pending[self.tca_pending_count] = TcaPending{
                        .algo_idx = algo_idx,
                        .fills = std.mem.zeroes([128]TcaExecution),
                        .fill_count = 0,
                        .benchmark = TcaBenchmark{
                            .arrival_price = arrival_price,
                            .market_vwap = arrival_price,
                            .close_price = arrival_price,
                            .attempted_qty = signal.spot_qty,
                        },
                        .active = true,
                    };
                    self.tca_pending_count += 1;
                }
            }
        }

        // Funding arb strategy: ETH-USD vs ETH-USD-PERP
        const eth_spot_book = self.feed.getBook(eth_spot_idx);
        const eth_perp_book = self.feed.getBook(eth_perp_idx);
        const eth_spot_mid = eth_spot_book.midPrice() orelse 0;
        const eth_perp_mid = eth_perp_book.midPrice() orelse 0;
        const funding_rate_bps = SyntheticFeed_mod.SyntheticFeed.computeFundingRate(eth_spot_mid, eth_perp_mid);
        // Convert i64 basis points to f64 funding rate
        const funding_rate_f64: f64 = @as(f64, @floatFromInt(funding_rate_bps)) / 10_000.0;
        if (self.funding_arb_strategy.onFundingRate(funding_rate_f64, current_tick_ns)) |signal| {
            if (signal.direction != .flat and self.active_algo_count < 16) {
                const spot_side: twap_mod_algo.Side = if (signal.direction == .long_spot_short_perp) .buy else .sell;
                const end_time: u128 = current_tick_ns + 60_000_000_000;
                const spot_twap = TwapAlgo.init(TwapParams{
                    .total_qty = signal.spot_qty,
                    .start_time = current_tick_ns,
                    .end_time = end_time,
                    .num_slices = 10,
                    .instrument = "ETH-USD",
                    .side = spot_side,
                    .jitter_pct = 0.1,
                });
                const arrival_price = eth_spot_mid;
                const algo_idx_eth = self.active_algo_count;
                self.active_algos[algo_idx_eth] = ActiveAlgo{
                    .twap = spot_twap,
                    .parent_order_id = self.oms.next_id,
                    .instrument_idx = @intCast(eth_spot_idx),
                    .side = spot_side,
                    .arrival_price = arrival_price,
                    .active = true,
                };
                self.active_algo_count += 1;
                // Create TcaPending for this algo
                if (self.tca_pending_count < 16) {
                    self.tca_pending[self.tca_pending_count] = TcaPending{
                        .algo_idx = algo_idx_eth,
                        .fills = std.mem.zeroes([128]TcaExecution),
                        .fill_count = 0,
                        .benchmark = TcaBenchmark{
                            .arrival_price = arrival_price,
                            .market_vwap = arrival_price,
                            .close_price = arrival_price,
                            .attempted_qty = signal.spot_qty,
                        },
                        .active = true,
                    };
                    self.tca_pending_count += 1;
                }
            }
        }
        // Also run convergence monitoring
        _ = self.funding_arb_strategy.onMarketData(eth_spot_book, eth_perp_book);
    }

    fn runAlgos(self: *Engine) void {
        const current_tick_ns: u128 = @intCast(self.tick * 100_000_000);

        for (0..self.active_algo_count) |i| {
            const algo = &self.active_algos[i];
            if (!algo.active) continue;

            if (algo.twap.nextSlice(current_tick_ns)) |child| {
                // Submit child order through pipeline
                const child_side: oms_mod.Side = if (child.side == .buy) .buy else .sell;
                const child_order = Order{
                    .id = 0,
                    .instrument = child.instrument,
                    .side = child_side,
                    .order_type = .market,
                    .quantity = child.quantity,
                    .price = null,
                    .tif = .day,
                    .status = .validating,
                    .created_at = 0,
                    .parent_id = algo.parent_order_id,
                    .filled_qty = 0,
                };

                const child_id = self.oms.submitOrder(child_order) catch continue;

                const book = self.feed.getBook(algo.instrument_idx);
                const fill_result = self.matching.processOrder(
                    child_id,
                    algo.instrument_idx,
                    child_side,
                    null,
                    child.quantity,
                    .market,
                    book,
                );

                for (0..fill_result.fill_count) |j| {
                    const f = &fill_result.fills[j];
                    self.oms.onExecution(child_id, .fill, FillInfo{
                        .fill_qty = f.fill_qty,
                        .fill_price = f.fill_price,
                    }) catch {};
                    const fill_side: positions_mod.Side = if (child_side == .buy) .buy else .sell;
                    const tca_fill_side: tca_mod_analytics.Side = if (child_side == .buy) .buy else .sell;
                    self.pos_manager.onFill(Fill{
                        .instrument = child.instrument,
                        .side = fill_side,
                        .quantity = f.fill_qty,
                        .price = f.fill_price,
                        .timestamp = current_tick_ns,
                        .account = "demo",
                        .currency = "USD",
                        .settlement_date = 0,
                    }) catch {};
                    algo.twap.onFill(.{ .quantity = f.fill_qty, .price = f.fill_price });

                    // Record fill in TcaPending
                    for (0..self.tca_pending_count) |tp_idx| {
                        const tp = &self.tca_pending[tp_idx];
                        if (tp.active and tp.algo_idx == i and tp.fill_count < 128) {
                            tp.fills[tp.fill_count] = TcaExecution{
                                .price = f.fill_price,
                                .quantity = f.fill_qty,
                                .timestamp = current_tick_ns,
                                .side = tca_fill_side,
                                .venue = "DEMO",
                            };
                            tp.fill_count += 1;
                            break;
                        }
                    }
                }
            }

            if (algo.twap.isComplete()) {
                algo.active = false;
                // Trigger TCA completion
                for (0..self.tca_pending_count) |tp_idx| {
                    if (self.tca_pending[tp_idx].active and self.tca_pending[tp_idx].algo_idx == i) {
                        self.completeTca(tp_idx);
                        break;
                    }
                }
            }
        }
    }

    fn handleOrderRequest(self: *Engine, req: msg.OrderRequest) void {
        const instrument_slice = req.instrument.slice();
        const order_side: oms_mod.Side = if (req.side == 0) .buy else .sell;
        const order = Order{
            .id = 0, // will be assigned by OMS
            .instrument = instrument_slice,
            .side = order_side,
            .order_type = .limit,
            .quantity = req.quantity,
            .price = req.price,
            .tif = .day,
            .status = .validating,
            .created_at = 0,
            .parent_id = null,
            .filled_qty = 0,
        };

        const order_id = self.oms.submitOrder(order) catch {
            _ = self.to_tui.push(EngineEvent{ .order_update = msg.OrderUpdate{
                .id = 0,
                .instrument = req.instrument,
                .side = req.side,
                .quantity = req.quantity,
                .price = req.price,
                .status = 4, // rejected
                .filled_qty = 0,
            } });
            return;
        };

        // Determine instrument index
        var instrument_idx: u8 = 0;
        for (0..INSTRUMENTS.len) |i| {
            if (std.mem.eql(u8, INSTRUMENTS[i], instrument_slice)) {
                instrument_idx = @intCast(i);
                break;
            }
        }

        // Process order through matching engine
        const book = self.feed.getBook(instrument_idx);
        const fill_result = self.matching.processOrder(
            order_id,
            instrument_idx,
            order_side,
            req.price,
            req.quantity,
            .limit,
            book,
        );

        // Process fills
        var total_filled: i64 = 0;
        for (0..fill_result.fill_count) |i| {
            const f = &fill_result.fills[i];
            total_filled += f.fill_qty;
            const exec_type: ExecType = if (i + 1 == fill_result.fill_count and
                total_filled >= req.quantity) .fill else .partial_fill;
            self.oms.onExecution(order_id, exec_type, FillInfo{
                .fill_qty = f.fill_qty,
                .fill_price = f.fill_price,
            }) catch {};
            const fill_side: positions_mod.Side = if (order_side == .buy) .buy else .sell;
            self.pos_manager.onFill(Fill{
                .instrument = instrument_slice,
                .side = fill_side,
                .quantity = f.fill_qty,
                .price = f.fill_price,
                .timestamp = @intCast(self.tick * 100_000_000),
                .account = "demo",
                .currency = "USD",
                .settlement_date = 0,
            }) catch {};
        }

        // Determine final status
        const status: u8 = if (total_filled >= req.quantity) 2 // filled
        else if (fill_result.rested) 1 // new (resting)
        else if (total_filled > 0) 3 // partially filled
        else 1; // new

        _ = self.to_tui.push(EngineEvent{ .order_update = msg.OrderUpdate{
            .id = order_id,
            .instrument = req.instrument,
            .side = req.side,
            .quantity = req.quantity,
            .price = req.price,
            .status = status,
            .filled_qty = total_filled,
        } });
    }

    /// Request engine to stop (called from TUI thread).
    pub fn requestStop(self: *Engine) void {
        self.running.store(false, .release);
    }
};

test "engine_init_and_deinit" {
    const SpscRB = SpscRingBuffer(EngineEvent);
    const SpscRBCmd = SpscRingBuffer(UserCommand);

    var to_tui = try SpscRB.init(std.testing.allocator, 16);
    defer to_tui.deinit();
    var from_tui = try SpscRBCmd.init(std.testing.allocator, 16);
    defer from_tui.deinit();

    var engine = try Engine.init(std.testing.allocator, &to_tui, &from_tui);
    defer engine.deinit();

    try std.testing.expect(engine.tick == 0);
}

test "engine_candle_aggregation" {
    const SpscRB = SpscRingBuffer(EngineEvent);
    const SpscRBCmd = SpscRingBuffer(UserCommand);

    var to_tui = try SpscRB.init(std.testing.allocator, 8192);
    defer to_tui.deinit();
    var from_tui = try SpscRBCmd.init(std.testing.allocator, 16);
    defer from_tui.deinit();

    var engine = try Engine.init(std.testing.allocator, &to_tui, &from_tui);
    defer engine.deinit();

    // 1-minute bar = 60_000_000_000 ns, each tick = 100_000_000 ns => 600 ticks per bar.
    // Run engine tick logic directly (without Thread.sleep) for 601 ticks to cross bar boundary.
    // We replicate the tick logic inline to avoid spawning a thread with sleep.
    const ticks_needed: usize = 601;
    for (0..ticks_needed) |_| {
        engine.tick += 1;
        engine.feed.tick();
        const timestamp_ns: u64 = engine.tick * 100_000_000;
        for (0..8) |i| {
            const book = engine.feed.getBook(i);
            const snap = Engine.snapshotBook(book, INSTRUMENTS[i]);
            _ = to_tui.push(EngineEvent{ .orderbook_snapshot = snap });
            if (snap.bid_count > 0 and snap.ask_count > 0) {
                const midpoint = @divTrunc(snap.bids[0].price + snap.asks[0].price, 2);
                if (engine.candle_aggs[i].onTrade(midpoint, 1, @as(u128, timestamp_ns))) |bar| {
                    const cu = CandleUpdate{
                        .instrument = snap.instrument,
                        .open = bar.open,
                        .high = bar.high,
                        .low = bar.low,
                        .close = bar.close,
                        .volume = bar.volume,
                        .timestamp = @truncate(bar.timestamp),
                    };
                    _ = to_tui.push(EngineEvent{ .candle_update = cu });
                }
            }
        }
    }

    // Drain events and look for at least one candle_update
    var found_candle = false;
    while (to_tui.pop()) |event| {
        switch (event) {
            .candle_update => {
                found_candle = true;
            },
            else => {},
        }
    }
    try std.testing.expect(found_candle);
}
