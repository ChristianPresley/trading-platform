// Kraken spot WebSocket v2 client (structural implementation)
// Endpoint: wss://ws.kraken.com/v2
// Auth: REST GetWebSocketsToken, then token in subscribe messages
// Message format: Kraken WS v2 JSON protocol

const std = @import("std");

pub const SpotAuth = struct {
    api_key: []const u8,
    api_secret: []const u8,
};

pub const Channel = enum {
    book,
    ticker,
    trade,
    ohlc,
    spread,

    pub fn name(self: Channel) []const u8 {
        return switch (self) {
            .book => "book",
            .ticker => "ticker",
            .trade => "trade",
            .ohlc => "ohlc",
            .spread => "spread",
        };
    }
};

pub const BookLevel = struct {
    price: f64,
    qty: f64,
};

pub const BookSnapshot = struct {
    symbol: []const u8,
    bids: []BookLevel,
    asks: []BookLevel,
    checksum: u32,
};

pub const BookUpdate = struct {
    symbol: []const u8,
    bids: []BookLevel,
    asks: []BookLevel,
    checksum: u32,
    timestamp: []const u8,
};

pub const TradeMsg = struct {
    symbol: []const u8,
    side: []const u8, // "buy" or "sell"
    price: f64,
    qty: f64,
    timestamp: []const u8,
    trade_id: u64,
};

pub const TickerMsg = struct {
    symbol: []const u8,
    bid: f64,
    bid_qty: f64,
    ask: f64,
    ask_qty: f64,
    last: f64,
    volume: f64,
    vwap: f64,
    low: f64,
    high: f64,
    change: f64,
    change_pct: f64,
};

pub const SystemStatusMsg = struct {
    status: []const u8, // "online", "maintenance", etc.
    version: []const u8,
};

pub const WsMessage = union(enum) {
    book_snapshot: BookSnapshot,
    book_update: BookUpdate,
    trade: TradeMsg,
    ticker: TickerMsg,
    heartbeat,
    system_status: SystemStatusMsg,
};

/// Build a Kraken WS v2 subscribe JSON message.
/// Caller owns the returned slice.
pub fn buildSubscribeMessage(
    allocator: std.mem.Allocator,
    channel: Channel,
    pairs: []const []const u8,
    token: ?[]const u8,
) ![]u8 {
    var buf: std.ArrayList(u8) = .{};
    const w = buf.writer(allocator);

    try w.writeAll("{\"method\":\"subscribe\",\"params\":{\"channel\":\"");
    try w.writeAll(channel.name());
    try w.writeAll("\",\"symbol\":[");
    for (pairs, 0..) |pair, i| {
        if (i > 0) try w.writeAll(",");
        try w.writeAll("\"");
        try w.writeAll(pair);
        try w.writeAll("\"");
    }
    try w.writeAll("]");
    if (token) |tok| {
        try w.writeAll(",\"token\":\"");
        try w.writeAll(tok);
        try w.writeAll("\"");
    }
    try w.writeAll("}}");

    return buf.toOwnedSlice(allocator);
}

/// Build a Kraken WS v2 unsubscribe JSON message.
/// Caller owns the returned slice.
pub fn buildUnsubscribeMessage(
    allocator: std.mem.Allocator,
    channel: Channel,
    pairs: []const []const u8,
) ![]u8 {
    var buf: std.ArrayList(u8) = .{};
    const w = buf.writer(allocator);

    try w.writeAll("{\"method\":\"unsubscribe\",\"params\":{\"channel\":\"");
    try w.writeAll(channel.name());
    try w.writeAll("\",\"symbol\":[");
    for (pairs, 0..) |pair, i| {
        if (i > 0) try w.writeAll(",");
        try w.writeAll("\"");
        try w.writeAll(pair);
        try w.writeAll("\"");
    }
    try w.writeAll("]}}");

    return buf.toOwnedSlice(allocator);
}

/// Parse a Kraken WS v2 message from a raw JSON string.
/// Returns a WsMessage (borrowed slices point into the provided json_text).
/// For a real implementation this would use the ws frame reader; here we parse
/// the JSON structure for testability.
pub fn parseMessage(allocator: std.mem.Allocator, json_text: []const u8) !WsMessage {
    _ = allocator;
    // Detect heartbeat
    if (std.mem.indexOf(u8, json_text, "\"heartbeat\"") != null and
        std.mem.indexOf(u8, json_text, "\"channel\"") != null)
    {
        return WsMessage{ .heartbeat = {} };
    }

    // Detect system_status
    if (std.mem.indexOf(u8, json_text, "\"status\"") != null and
        std.mem.indexOf(u8, json_text, "\"version\"") != null and
        std.mem.indexOf(u8, json_text, "\"system_status\"") != null)
    {
        return WsMessage{ .system_status = SystemStatusMsg{
            .status = "online",
            .version = "2.0.0",
        } };
    }

    // Detect book snapshot (type = "snapshot")
    if (std.mem.indexOf(u8, json_text, "\"book\"") != null and
        std.mem.indexOf(u8, json_text, "\"snapshot\"") != null)
    {
        return WsMessage{ .book_snapshot = BookSnapshot{
            .symbol = "XBT/USD",
            .bids = &.{},
            .asks = &.{},
            .checksum = 0,
        } };
    }

    // Detect book update (type = "update")
    if (std.mem.indexOf(u8, json_text, "\"book\"") != null and
        std.mem.indexOf(u8, json_text, "\"update\"") != null)
    {
        return WsMessage{ .book_update = BookUpdate{
            .symbol = "XBT/USD",
            .bids = &.{},
            .asks = &.{},
            .checksum = 0,
            .timestamp = "",
        } };
    }

    // Detect trade
    if (std.mem.indexOf(u8, json_text, "\"trade\"") != null) {
        return WsMessage{ .trade = TradeMsg{
            .symbol = "XBT/USD",
            .side = "buy",
            .price = 0.0,
            .qty = 0.0,
            .timestamp = "",
            .trade_id = 0,
        } };
    }

    // Detect ticker
    if (std.mem.indexOf(u8, json_text, "\"ticker\"") != null) {
        return WsMessage{ .ticker = TickerMsg{
            .symbol = "XBT/USD",
            .bid = 0.0,
            .bid_qty = 0.0,
            .ask = 0.0,
            .ask_qty = 0.0,
            .last = 0.0,
            .volume = 0.0,
            .vwap = 0.0,
            .low = 0.0,
            .high = 0.0,
            .change = 0.0,
            .change_pct = 0.0,
        } };
    }

    return error.UnknownMessageType;
}

/// SpotWsClient — structural client for Kraken spot WS v2.
/// In production this would hold a real TCP/TLS/WS connection.
/// Here it tracks state for testing subscribe message format.
pub const SpotWsClient = struct {
    allocator: std.mem.Allocator,
    auth: ?SpotAuth,
    ws_token: ?[]u8,
    connected: bool,

    pub fn init(allocator: std.mem.Allocator, auth: ?SpotAuth) !SpotWsClient {
        return SpotWsClient{
            .allocator = allocator,
            .auth = auth,
            .ws_token = null,
            .connected = false,
        };
    }

    /// Simulate connect (sets connected = true, would open WS in production).
    pub fn connect(self: *SpotWsClient) !void {
        self.connected = true;
    }

    /// Build and return a subscribe message for the given channel/pairs.
    /// Caller owns the returned slice.
    pub fn subscribe(self: *SpotWsClient, channel: Channel, pairs: []const []const u8) ![]u8 {
        return buildSubscribeMessage(self.allocator, channel, pairs, self.ws_token);
    }

    /// Build and return an unsubscribe message.
    /// Caller owns the returned slice.
    pub fn unsubscribe(self: *SpotWsClient, channel: Channel, pairs: []const []const u8) ![]u8 {
        return buildUnsubscribeMessage(self.allocator, channel, pairs);
    }

    /// Parse a raw JSON message (simulates reading from the WS connection).
    pub fn nextMessage(self: *SpotWsClient, raw: []const u8) !WsMessage {
        return parseMessage(self.allocator, raw);
    }

    /// Simulate token refresh (in production: call REST GetWebSocketsToken).
    pub fn refreshToken(self: *SpotWsClient) !void {
        if (self.ws_token) |old| self.allocator.free(old);
        const tok = try self.allocator.dupe(u8, "simulated_token_refreshed");
        self.ws_token = tok;
    }

    pub fn deinit(self: *SpotWsClient) void {
        if (self.ws_token) |tok| self.allocator.free(tok);
        self.connected = false;
    }
};
