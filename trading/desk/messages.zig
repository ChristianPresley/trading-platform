// Message types for TUI <-> Engine ring buffer communication.
// All types are fixed-size value types (no pointers, no slices) — safe for SpscRingBuffer.

pub const InstrumentId = struct {
    buf: [32]u8,
    len: u8,

    pub fn fromSlice(s: []const u8) InstrumentId {
        var id = InstrumentId{ .buf = undefined, .len = 0 };
        const n = @min(s.len, 32);
        @memcpy(id.buf[0..n], s[0..n]);
        id.len = @intCast(n);
        return id;
    }

    pub fn slice(self: *const InstrumentId) []const u8 {
        return self.buf[0..self.len];
    }
};

pub const PriceLevel = struct {
    price: i64,
    quantity: i64,
};

pub const OrderbookSnapshot = struct {
    instrument: InstrumentId,
    bids: [20]PriceLevel,
    asks: [20]PriceLevel,
    bid_count: u8,
    ask_count: u8,
};

pub const PositionUpdate = struct {
    instrument: InstrumentId,
    quantity: i64,
    avg_cost: i64,
    unrealized_pnl: i64,
    realized_pnl: i64,
};

pub const OrderUpdate = struct {
    id: u64,
    instrument: InstrumentId,
    side: u8, // 0=buy, 1=sell
    quantity: i64,
    price: i64,
    status: u8, // 0=pending, 1=new, 2=filled, 3=cancelled, 4=rejected
    filled_qty: i64,
};

pub const OrderRequest = struct {
    instrument: InstrumentId,
    side: u8, // 0=buy, 1=sell
    quantity: i64,
    price: i64,
};

pub const StatusUpdate = struct {
    tick: u64,
    engine_time_ns: u128,
    instrument_count: u8,
    connected: bool,
    strategy_state: [64]u8,
    strategy_state_len: u8,
    vpin_scores: [8]i64,
    vpin_valid: [8]bool,
};

pub const TcaReportEvent = struct {
    instrument: InstrumentId,
    is_cost_bps: i64,       // scaled by 100
    fill_rate_pct: u8,      // 0-100
    market_impact_bps: i64, // scaled by 100
};

pub const EodReportEvent = struct {
    realized_pnl: i64,
    unrealized_pnl: i64,
    total_pnl: i64,
    tick: u64,
};

pub const CandleUpdate = struct {
    instrument: InstrumentId,
    open: i64,
    high: i64,
    low: i64,
    close: i64,
    volume: i64,
    timestamp: u64,
};

pub const TradeUpdate = struct {
    instrument: InstrumentId,
    side: u8, // 0=buy, 1=sell
    quantity: i64,
    price: i64,
    tick: u64,
    trader_tag: [8]u8, // e.g. "MM", "MOM", "MEAN", "NOISE", "WHALE"
    trader_tag_len: u8,
};

/// A single price level within a volume footprint candle.
pub const FootprintLevel = struct {
    price: i64,
    bid_volume: i64, // volume hitting the bid (sellers / market sells)
    ask_volume: i64, // volume lifting the ask (buyers / market buys)
};

/// Volume footprint data for one completed candle bar.
/// Shows bid vs ask volume at each price level within the bar's range.
pub const FootprintUpdate = struct {
    instrument: InstrumentId,
    timestamp: u64,
    levels: [MAX_FOOTPRINT_LEVELS]FootprintLevel,
    level_count: u8,
    delta: i64, // total ask_volume - total bid_volume
    total_volume: i64,
    tick_size: i64, // price bucketing granularity
};

pub const MAX_FOOTPRINT_LEVELS: usize = 24;

pub const EngineEvent = union(enum) {
    tick: u64,
    orderbook_snapshot: OrderbookSnapshot,
    position_update: PositionUpdate,
    order_update: OrderUpdate,
    status: StatusUpdate,
    candle_update: CandleUpdate,
    trade_update: TradeUpdate,
    footprint_update: FootprintUpdate,
    shutdown_ack: void,
    tca_report: TcaReportEvent,
    eod_report: EodReportEvent,
};

pub const UserCommand = union(enum) {
    quit: void,
    select_instrument: InstrumentId,
    submit_order: OrderRequest,
    cancel_order: u64,
};

test "messages_sizes" {
    const std = @import("std");
    // Verify fixed-size types are reasonably sized
    try std.testing.expect(@sizeOf(EngineEvent) > 0);
    try std.testing.expect(@sizeOf(UserCommand) > 0);
    try std.testing.expect(@sizeOf(OrderbookSnapshot) > 0);
    try std.testing.expect(@sizeOf(CandleUpdate) > 0);
}
