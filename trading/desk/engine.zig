const std = @import("std");
const ring_buffer = @import("ring_buffer");
const SpscRingBuffer = ring_buffer.SpscRingBuffer;
const messages = @import("messages.zig");
const EngineEvent = messages.EngineEvent;
const UserCommand = messages.UserCommand;
const InstrumentId = messages.InstrumentId;
const SyntheticFeed = @import("synthetic.zig").SyntheticFeed;

pub const Engine = struct {
    allocator: std.mem.Allocator,
    to_tui: *SpscRingBuffer(EngineEvent),
    from_tui: *SpscRingBuffer(UserCommand),
    running: std.atomic.Value(bool),
    tick: u64,
    feed: ?SyntheticFeed,

    // Stub risk/store for OMS — demo mode always passes
    var dummy_risk: u8 = 0;
    var dummy_store: u8 = 0;

    fn riskValidate(_: *anyopaque, _: *const anyopaque) bool {
        return true; // always pass in demo mode
    }

    fn storeAppend(_: *anyopaque, _: []const u8) anyerror!u64 {
        return 0; // no-op store
    }

    pub fn init(
        allocator: std.mem.Allocator,
        to_tui: *SpscRingBuffer(EngineEvent),
        from_tui: *SpscRingBuffer(UserCommand),
    ) Engine {
        const feed = SyntheticFeed.init(allocator, @intCast(std.time.nanoTimestamp())) catch null;

        return Engine{
            .allocator = allocator,
            .to_tui = to_tui,
            .from_tui = from_tui,
            .running = std.atomic.Value(bool).init(true),
            .tick = 0,
            .feed = feed,
        };
    }

    pub fn deinit(self: *Engine) void {
        if (self.feed) |*f| f.deinit();
    }

    /// Main engine loop — runs on the engine thread.
    pub fn run(self: *Engine) void {
        while (self.running.load(.acquire)) {
            self.tick += 1;

            // Process commands from TUI
            while (self.from_tui.pop()) |cmd| {
                switch (cmd) {
                    .quit => {
                        self.running.store(false, .release);
                        _ = self.to_tui.push(.{ .shutdown_ack = {} });
                        return;
                    },
                    .submit_order => |req| {
                        // In demo mode, create a fake order update
                        _ = self.to_tui.push(.{ .order_update = .{
                            .id = self.tick,
                            .instrument = req.instrument,
                            .side = req.side,
                            .quantity = req.quantity,
                            .price = req.price,
                            .status = 1, // "New"
                            .filled_qty = 0,
                        } });
                    },
                    .cancel_order => |id| {
                        _ = self.to_tui.push(.{ .order_update = .{
                            .id = id,
                            .status = 4, // "Cancelled"
                        } });
                    },
                    .select_instrument => {},
                }
            }

            // Advance synthetic feed
            if (self.feed) |*feed| {
                feed.tick();

                // Snapshot each book and send to TUI
                for (0..2) |idx| {
                    const book = feed.getBook(idx);
                    var snapshot = messages.OrderbookSnapshot{};
                    snapshot.instrument = InstrumentId.fromSlice(SyntheticFeed.instruments[idx]);

                    // Copy bids
                    const bids = book.bids();
                    const bid_count = @min(bids.len, @as(usize, 20));
                    for (0..bid_count) |i| {
                        snapshot.bids[i] = .{ .price = bids[i].price, .quantity = bids[i].quantity };
                    }
                    snapshot.bid_count = @intCast(bid_count);

                    // Copy asks
                    const asks = book.asks();
                    const ask_count = @min(asks.len, @as(usize, 20));
                    for (0..ask_count) |i| {
                        snapshot.asks[i] = .{ .price = asks[i].price, .quantity = asks[i].quantity };
                    }
                    snapshot.ask_count = @intCast(ask_count);

                    _ = self.to_tui.push(.{ .orderbook_snapshot = snapshot });
                }
            }

            // Push status update
            _ = self.to_tui.push(.{ .status = .{
                .tick = self.tick,
                .engine_time_ns = @intCast(std.time.nanoTimestamp()),
                .instrument_count = 2,
                .connected = false,
            } });

            std.time.sleep(100_000_000); // 100ms per tick
        }
    }

    pub fn requestStop(self: *Engine) void {
        self.running.store(false, .release);
    }
};

test "engine_init_deinit" {
    const allocator = std.testing.allocator;
    var to_tui = try SpscRingBuffer(EngineEvent).init(allocator, 256);
    defer to_tui.deinit();
    var from_tui = try SpscRingBuffer(UserCommand).init(allocator, 256);
    defer from_tui.deinit();

    var engine = Engine.init(allocator, &to_tui, &from_tui);
    defer engine.deinit();
    try std.testing.expect(engine.tick == 0);
}
