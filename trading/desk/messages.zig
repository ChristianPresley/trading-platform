const std = @import("std");

/// Fixed-size instrument identifier — no heap allocation, safe for ring buffer.
pub const InstrumentId = struct {
    buf: [32]u8 = [_]u8{0} ** 32,
    len: u8 = 0,

    pub fn fromSlice(s: []const u8) InstrumentId {
        var id = InstrumentId{};
        const copy_len = @min(s.len, 32);
        @memcpy(id.buf[0..copy_len], s[0..copy_len]);
        id.len = @intCast(copy_len);
        return id;
    }

    pub fn asSlice(self: *const InstrumentId) []const u8 {
        return self.buf[0..self.len];
    }
};

pub const PriceLevel = struct {
    price: i64 = 0,
    quantity: i64 = 0,
};

pub const OrderbookSnapshot = struct {
    instrument: InstrumentId = .{},
    bids: [20]PriceLevel = [_]PriceLevel{.{}} ** 20,
    asks: [20]PriceLevel = [_]PriceLevel{.{}} ** 20,
    bid_count: u8 = 0,
    ask_count: u8 = 0,
};

pub const PositionUpdate = struct {
    instrument: InstrumentId = .{},
    quantity: i64 = 0,
    avg_cost: i64 = 0,
    unrealized_pnl: i64 = 0,
    realized_pnl: i64 = 0,
};

pub const OrderUpdate = struct {
    id: u64 = 0,
    instrument: InstrumentId = .{},
    side: u8 = 0, // 0=buy, 1=sell
    quantity: i64 = 0,
    price: i64 = 0,
    status: u8 = 0, // maps to OrdStatus
    filled_qty: i64 = 0,
};

pub const OrderRequest = struct {
    instrument: InstrumentId = .{},
    side: u8 = 0, // 0=buy, 1=sell
    quantity: i64 = 0,
    price: i64 = 0,
};

pub const StatusUpdate = struct {
    tick: u64 = 0,
    engine_time_ns: u128 = 0,
    instrument_count: u8 = 0,
    connected: bool = false,
};

/// Events sent from engine thread to TUI thread.
pub const EngineEvent = union(enum) {
    tick: u64,
    orderbook_snapshot: OrderbookSnapshot,
    position_update: PositionUpdate,
    order_update: OrderUpdate,
    status: StatusUpdate,
    shutdown_ack: void,
};

/// Commands sent from TUI thread to engine thread.
pub const UserCommand = union(enum) {
    quit: void,
    select_instrument: InstrumentId,
    submit_order: OrderRequest,
    cancel_order: u64,
};

test "instrument_id_roundtrip" {
    const id = InstrumentId.fromSlice("BTC-USD");
    try std.testing.expectEqualStrings("BTC-USD", id.asSlice());
}

test "engine_event_size" {
    // Verify EngineEvent is a reasonable size for ring buffer
    try std.testing.expect(@sizeOf(EngineEvent) < 4096);
}
