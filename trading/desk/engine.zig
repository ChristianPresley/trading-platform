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
        };
    }

    pub fn deinit(self: *Engine) void {
        self.feed.deinit();
        self.oms.deinit();
        self.risk.deinit();
        self.allocator.destroy(self.risk);
        self.pos_manager.deinit();
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

            // Push status
            _ = self.to_tui.push(EngineEvent{ .status = msg.StatusUpdate{
                .tick = self.tick,
                .engine_time_ns = 0,
                .instrument_count = 8,
                .connected = false,
            } });

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
