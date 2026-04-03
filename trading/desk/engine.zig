// Engine thread: integrates synthetic market data, OMS, and basic positions.
// Uses SpscRingBuffer for TUI communication.

const std = @import("std");
const SpscRingBuffer = @import("ring_buffer").SpscRingBuffer;
const msg = @import("messages.zig");
const EngineEvent = msg.EngineEvent;
const UserCommand = msg.UserCommand;
const OrderbookSnapshot = msg.OrderbookSnapshot;
const PriceLevel = msg.PriceLevel;
const InstrumentId = msg.InstrumentId;

const SyntheticFeed = @import("synthetic.zig").SyntheticFeed;
const L2Book = @import("orderbook").L2Book;
const oms_mod = @import("oms");
const OrderManager = oms_mod.OrderManager;
const Order = oms_mod.Order;

const INSTRUMENTS = [_][]const u8{ "BTC-USD", "ETH-USD" };

/// Stub risk validate function (always passes — demo mode).
fn riskValidateStub(risk: *anyopaque, order: *const Order) bool {
    _ = risk;
    _ = order;
    return true;
}

/// Stub event store append function.
fn storeAppendStub(store: *anyopaque, data: []const u8) anyerror!u64 {
    _ = store;
    _ = data;
    return 0;
}

/// Dummy objects for function pointer injection.
var dummy_risk: u8 = 0;
var dummy_store: u8 = 0;

/// Simple position tracking (fixed array, avoids ArrayList API issues).
const SimplePosition = struct {
    instrument: InstrumentId,
    quantity: i64,
    avg_cost: i64,
    realized_pnl: i64,
};

pub const Engine = struct {
    allocator: std.mem.Allocator,
    to_tui: *SpscRingBuffer(EngineEvent),
    from_tui: *SpscRingBuffer(UserCommand),
    running: std.atomic.Value(bool),
    tick: u64,

    // Domain modules
    feed: SyntheticFeed,
    oms: OrderManager,

    // Simple position tracking
    positions: [16]SimplePosition,
    position_count: usize,

    pub fn init(
        allocator: std.mem.Allocator,
        to_tui: *SpscRingBuffer(EngineEvent),
        from_tui: *SpscRingBuffer(UserCommand),
    ) !Engine {
        const now_seed: u64 = @intCast(std.time.milliTimestamp());
        var feed = try SyntheticFeed.init(allocator, now_seed);
        errdefer feed.deinit();

        const oms = try OrderManager.init(
            allocator,
            &dummy_risk,
            &dummy_store,
            riskValidateStub,
            storeAppendStub,
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
            .positions = undefined,
            .position_count = 0,
        };
    }

    pub fn deinit(self: *Engine) void {
        self.feed.deinit();
        self.oms.deinit();
    }

    /// Snapshot the L2Book into an OrderbookSnapshot message.
    fn snapshotBook(book: *const L2Book, instrument: []const u8) OrderbookSnapshot {
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

            // Push orderbook snapshots for each instrument
            for (0..2) |i| {
                const book = self.feed.getBook(i);
                const snap = snapshotBook(book, INSTRUMENTS[i]);
                _ = self.to_tui.push(EngineEvent{ .orderbook_snapshot = snap });
            }

            // Push position updates
            for (0..self.position_count) |i| {
                const pos = &self.positions[i];
                const update = msg.PositionUpdate{
                    .instrument = pos.instrument,
                    .quantity = pos.quantity,
                    .avg_cost = pos.avg_cost,
                    .unrealized_pnl = 0, // simplified: no mark prices in demo
                    .realized_pnl = pos.realized_pnl,
                };
                _ = self.to_tui.push(EngineEvent{ .position_update = update });
            }

            // Push status
            _ = self.to_tui.push(EngineEvent{ .status = msg.StatusUpdate{
                .tick = self.tick,
                .engine_time_ns = 0,
                .instrument_count = 2,
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
        const order = Order{
            .id = 0, // will be assigned by OMS
            .instrument = instrument_slice,
            .side = if (req.side == 0) .buy else .sell,
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

        // Update position (simple average cost)
        self.updatePosition(req.instrument, req.side, req.quantity, req.price);

        _ = self.to_tui.push(EngineEvent{ .order_update = msg.OrderUpdate{
            .id = order_id,
            .instrument = req.instrument,
            .side = req.side,
            .quantity = req.quantity,
            .price = req.price,
            .status = 1, // new
            .filled_qty = 0,
        } });
    }

    fn updatePosition(self: *Engine, instrument: InstrumentId, side: u8, quantity: i64, price: i64) void {
        // Find existing position
        for (0..self.position_count) |i| {
            if (std.mem.eql(u8, self.positions[i].instrument.slice(), instrument.slice())) {
                const pos = &self.positions[i];
                const delta: i64 = if (side == 0) quantity else -quantity;
                pos.quantity += delta;
                // Simple avg cost update
                if (pos.quantity != 0) {
                    pos.avg_cost = price; // simplified
                }
                return;
            }
        }
        // New position
        if (self.position_count < 16) {
            const delta: i64 = if (side == 0) quantity else -quantity;
            self.positions[self.position_count] = SimplePosition{
                .instrument = instrument,
                .quantity = delta,
                .avg_cost = price,
                .realized_pnl = 0,
            };
            self.position_count += 1;
        }
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
