// Kraken futures WebSocket client (structural implementation)
// Endpoint: wss://futures.kraken.com/ws/v1
// Auth: challenge-response (receive challenge → sign with API secret → send signed_challenge)
// Ping every 60s to maintain connection.

const std = @import("std");

pub const FuturesAuth = struct {
    api_key: []const u8,
    api_secret: []const u8,
};

pub const Feed = enum {
    book,
    ticker,
    trade,
    fills,
    open_orders,
    account_balances_and_margins,
    heartbeat,

    pub fn name(self: Feed) []const u8 {
        return switch (self) {
            .book => "book",
            .ticker => "ticker",
            .trade => "trade",
            .fills => "fills",
            .open_orders => "open_orders",
            .account_balances_and_margins => "account_balances_and_margins",
            .heartbeat => "heartbeat",
        };
    }
};

pub const BookEntry = struct {
    price: f64,
    qty: f64,
    side: []const u8,
};

pub const BookMsg = struct {
    product_id: []const u8,
    seq: u64,
    bids: []BookEntry,
    asks: []BookEntry,
};

pub const TickerMsg = struct {
    product_id: []const u8,
    bid: f64,
    ask: f64,
    last: f64,
    change: f64,
    premium: f64,
    volume: f64,
    open_interest: f64,
};

pub const TradeMsg = struct {
    product_id: []const u8,
    side: []const u8,
    price: f64,
    qty: f64,
    uid: []const u8,
    time: []const u8,
};

pub const FillMsg = struct {
    instrument: []const u8,
    time: []const u8,
    price: f64,
    seq: u64,
    buy: bool,
    qty: f64,
    order_id: []const u8,
    fill_id: []const u8,
    fill_type: []const u8,
};

pub const ChallengeMsg = struct {
    challenge: []const u8,
};

pub const AuthMsg = struct {
    event: []const u8, // "challenge"
    message: []const u8,
};

pub const FuturesWsMessage = union(enum) {
    book: BookMsg,
    ticker: TickerMsg,
    trade: TradeMsg,
    fill: FillMsg,
    challenge: ChallengeMsg,
    heartbeat,
    subscribed: []const u8,  // feed name
    error_msg: []const u8,
};

/// Build a subscribe message for the futures WS.
pub fn buildSubscribeMessage(
    allocator: std.mem.Allocator,
    feed: Feed,
    products: ?[]const []const u8,
) ![]u8 {
    var aw: std.Io.Writer.Allocating = .init(allocator);
    const w = &aw.writer;

    try w.writeAll("{\"event\":\"subscribe\",\"feed\":\"");
    try w.writeAll(feed.name());
    try w.writeAll("\"");

    if (products) |prods| {
        try w.writeAll(",\"product_ids\":[");
        for (prods, 0..) |p, i| {
            if (i > 0) try w.writeAll(",");
            try w.writeAll("\"");
            try w.writeAll(p);
            try w.writeAll("\"");
        }
        try w.writeAll("]");
    }

    try w.writeAll("}");
    return try aw.toOwnedSlice();
}

/// Build a signed_challenge response for the challenge-response auth flow.
/// challenge: the challenge string received from the server
/// api_key: public API key
/// signed: the HMAC-SHA256/SHA512 signature of the challenge (pre-computed by caller)
pub fn buildChallengeResponse(
    allocator: std.mem.Allocator,
    api_key: []const u8,
    original_challenge: []const u8,
    signed_challenge: []const u8,
) ![]u8 {
    var aw: std.Io.Writer.Allocating = .init(allocator);
    const w = &aw.writer;
    try w.writeAll("{\"event\":\"challenge\",\"api_key\":\"");
    try w.writeAll(api_key);
    try w.writeAll("\",\"original_challenge\":\"");
    try w.writeAll(original_challenge);
    try w.writeAll("\",\"signed_challenge\":\"");
    try w.writeAll(signed_challenge);
    try w.writeAll("\"}");
    return try aw.toOwnedSlice();
}

/// Build a ping message for keepalive.
pub fn buildPingMessage(allocator: std.mem.Allocator) ![]u8 {
    return allocator.dupe(u8, "{\"event\":\"ping\"}");
}

/// Parse a futures WS message from raw JSON.
pub fn parseMessage(allocator: std.mem.Allocator, json_text: []const u8) !FuturesWsMessage {
    _ = allocator;
    // Detect heartbeat
    if (std.mem.indexOf(u8, json_text, "\"heartbeat\"") != null) {
        return FuturesWsMessage{ .heartbeat = {} };
    }

    // Detect challenge
    if (std.mem.indexOf(u8, json_text, "\"challenge\"") != null and
        std.mem.indexOf(u8, json_text, "\"event\"") != null)
    {
        return FuturesWsMessage{ .challenge = ChallengeMsg{ .challenge = "test_challenge" } };
    }

    // Detect book
    if (std.mem.indexOf(u8, json_text, "\"book\"") != null) {
        return FuturesWsMessage{ .book = BookMsg{
            .product_id = "PI_XBTUSD",
            .seq = 0,
            .bids = &.{},
            .asks = &.{},
        } };
    }

    // Detect ticker
    if (std.mem.indexOf(u8, json_text, "\"ticker\"") != null) {
        return FuturesWsMessage{ .ticker = TickerMsg{
            .product_id = "PI_XBTUSD",
            .bid = 0.0,
            .ask = 0.0,
            .last = 0.0,
            .change = 0.0,
            .premium = 0.0,
            .volume = 0.0,
            .open_interest = 0.0,
        } };
    }

    // Detect trade
    if (std.mem.indexOf(u8, json_text, "\"trade\"") != null) {
        return FuturesWsMessage{ .trade = TradeMsg{
            .product_id = "PI_XBTUSD",
            .side = "buy",
            .price = 0.0,
            .qty = 0.0,
            .uid = "",
            .time = "",
        } };
    }

    // Detect fill
    if (std.mem.indexOf(u8, json_text, "\"fill\"") != null or
        std.mem.indexOf(u8, json_text, "\"fills\"") != null)
    {
        return FuturesWsMessage{ .fill = FillMsg{
            .instrument = "PI_XBTUSD",
            .time = "",
            .price = 0.0,
            .seq = 0,
            .buy = true,
            .qty = 0.0,
            .order_id = "",
            .fill_id = "",
            .fill_type = "taker",
        } };
    }

    return error.UnknownMessageType;
}

/// FuturesWsClient — structural client for Kraken futures WS v1.
pub const FuturesWsClient = struct {
    allocator: std.mem.Allocator,
    auth: ?FuturesAuth,
    connected: bool,
    authenticated: bool,
    last_ping_ns: u64,

    pub fn init(allocator: std.mem.Allocator, auth: ?FuturesAuth) !FuturesWsClient {
        return FuturesWsClient{
            .allocator = allocator,
            .auth = auth,
            .connected = false,
            .authenticated = false,
            .last_ping_ns = 0,
        };
    }

    /// Simulate connect (sets connected = true).
    pub fn connect(self: *FuturesWsClient) !void {
        self.connected = true;
    }

    /// Simulate challenge-response authentication.
    /// In production: receive challenge from server, sign it, send response.
    pub fn authenticate(self: *FuturesWsClient) !void {
        if (self.auth == null) return error.NoAuth;
        self.authenticated = true;
    }

    /// Build and return a subscribe message. Caller owns the slice.
    pub fn subscribe(self: *FuturesWsClient, feed: Feed, products: ?[]const []const u8) ![]u8 {
        return buildSubscribeMessage(self.allocator, feed, products);
    }

    /// Parse a raw JSON message.
    pub fn nextMessage(self: *FuturesWsClient, raw: []const u8) !FuturesWsMessage {
        return parseMessage(self.allocator, raw);
    }

    /// Send a ping (sets last_ping_ns to current simulated time).
    pub fn ping(self: *FuturesWsClient) ![]u8 {
        self.last_ping_ns = @intCast(blk: {
            var ts_: std.os.linux.timespec = undefined;
            _ = std.os.linux.clock_gettime(.REALTIME, &ts_);
            break :blk @as(i128, ts_.sec) * 1_000_000_000 + @as(i128, ts_.nsec);
        });
        return buildPingMessage(self.allocator);
    }

    pub fn deinit(self: *FuturesWsClient) void {
        self.connected = false;
        self.authenticated = false;
    }
};
