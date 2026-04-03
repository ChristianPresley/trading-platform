// Kraken spot API request/response types

const std = @import("std");

pub const SystemStatus = struct {
    status: []const u8, // "online", "cancel_only", "post_only", "maintenance"
    timestamp: []const u8,
};

pub const ServerTime = struct {
    unixtime: i64,
    rfc1123: []const u8,
};

pub const AssetInfo = struct {
    altname: []const u8,
    decimals: u8,
    display_decimals: u8,
};

pub const AssetPairsResult = struct {
    allocator: std.mem.Allocator,
    // Simplified: store raw pair names found
    pairs: [][]const u8,

    pub fn deinit(self: *AssetPairsResult) void {
        for (self.pairs) |p| self.allocator.free(p);
        self.allocator.free(self.pairs);
    }
};

pub const TickerData = struct {
    ask: [3][]const u8,  // price, whole lot volume, lot volume
    bid: [3][]const u8,
    last: [2][]const u8, // price, lot volume
    volume: [2][]const u8,
    vwap: [2][]const u8,
    trades: [2]u64,
    low: [2][]const u8,
    high: [2][]const u8,
    open: []const u8,
};

pub const TickerResult = struct {
    allocator: std.mem.Allocator,
    pair: []const u8,
    // Simplified ticker fields (just the ask/bid price strings)
    ask_price: []const u8,
    bid_price: []const u8,
    last_price: []const u8,

    pub fn deinit(self: *TickerResult) void {
        self.allocator.free(self.pair);
        self.allocator.free(self.ask_price);
        self.allocator.free(self.bid_price);
        self.allocator.free(self.last_price);
    }
};

pub const OhlcEntry = struct {
    time: i64,
    open: []const u8,
    high: []const u8,
    low: []const u8,
    close: []const u8,
    vwap: []const u8,
    volume: []const u8,
    count: u64,
};

pub const OhlcResult = struct {
    allocator: std.mem.Allocator,
    pair: []const u8,
    entries: []OhlcEntry,
    last: i64,

    pub fn deinit(self: *OhlcResult) void {
        for (self.entries) |e| {
            self.allocator.free(e.open);
            self.allocator.free(e.high);
            self.allocator.free(e.low);
            self.allocator.free(e.close);
            self.allocator.free(e.vwap);
            self.allocator.free(e.volume);
        }
        self.allocator.free(self.entries);
        self.allocator.free(self.pair);
    }
};

pub const OrderBookEntry = struct {
    price: []const u8,
    volume: []const u8,
    timestamp: i64,
};

pub const OrderBookResult = struct {
    allocator: std.mem.Allocator,
    pair: []const u8,
    asks: []OrderBookEntry,
    bids: []OrderBookEntry,

    pub fn deinit(self: *OrderBookResult) void {
        for (self.asks) |e| {
            self.allocator.free(e.price);
            self.allocator.free(e.volume);
        }
        for (self.bids) |e| {
            self.allocator.free(e.price);
            self.allocator.free(e.volume);
        }
        self.allocator.free(self.asks);
        self.allocator.free(self.bids);
        self.allocator.free(self.pair);
    }
};

pub const BalanceResult = struct {
    allocator: std.mem.Allocator,
    // currency -> balance string pairs
    currencies: [][]const u8,
    balances: [][]const u8,

    pub fn deinit(self: *BalanceResult) void {
        for (self.currencies) |c| self.allocator.free(c);
        for (self.balances) |b| self.allocator.free(b);
        self.allocator.free(self.currencies);
        self.allocator.free(self.balances);
    }
};

pub const TradeBalanceResult = struct {
    allocator: std.mem.Allocator,
    eb: []const u8, // equivalent balance
    tb: []const u8, // trade balance
    m: []const u8,  // margin amount
    n: []const u8,  // unrealized net P&L
    c: []const u8,  // cost basis
    v: []const u8,  // floating valuation
    e: []const u8,  // equity
    mf: []const u8, // free margin

    pub fn deinit(self: *TradeBalanceResult) void {
        self.allocator.free(self.eb);
        self.allocator.free(self.tb);
        self.allocator.free(self.m);
        self.allocator.free(self.n);
        self.allocator.free(self.c);
        self.allocator.free(self.v);
        self.allocator.free(self.e);
        self.allocator.free(self.mf);
    }
};

pub const OrderInfo = struct {
    txid: []const u8,
    status: []const u8,
    pair: []const u8,
    type_: []const u8,    // "buy" or "sell"
    ordertype: []const u8, // "market", "limit", etc.
    price: []const u8,
    vol: []const u8,
};

pub const OpenOrdersResult = struct {
    allocator: std.mem.Allocator,
    orders: []OrderInfo,

    pub fn deinit(self: *OpenOrdersResult) void {
        for (self.orders) |o| {
            self.allocator.free(o.txid);
            self.allocator.free(o.status);
            self.allocator.free(o.pair);
            self.allocator.free(o.type_);
            self.allocator.free(o.ordertype);
            self.allocator.free(o.price);
            self.allocator.free(o.vol);
        }
        self.allocator.free(self.orders);
    }
};

pub const ClosedOrdersResult = struct {
    allocator: std.mem.Allocator,
    orders: []OrderInfo,
    count: u64,

    pub fn deinit(self: *ClosedOrdersResult) void {
        for (self.orders) |o| {
            self.allocator.free(o.txid);
            self.allocator.free(o.status);
            self.allocator.free(o.pair);
            self.allocator.free(o.type_);
            self.allocator.free(o.ordertype);
            self.allocator.free(o.price);
            self.allocator.free(o.vol);
        }
        self.allocator.free(self.orders);
    }
};

pub const OrderRequest = struct {
    pair: []const u8,
    type_: []const u8,     // "buy" or "sell"
    ordertype: []const u8, // "market", "limit", "stop-loss", etc.
    price: ?[]const u8,    // required for limit orders
    volume: []const u8,
    leverage: ?[]const u8,
    oflags: ?[]const u8,   // comma-separated order flags
    starttm: ?i64,
    expiretm: ?i64,
    validate: bool,        // if true, validate only, don't submit
};

pub const AddOrderResult = struct {
    allocator: std.mem.Allocator,
    descr: []const u8, // order description
    txids: [][]const u8,

    pub fn deinit(self: *AddOrderResult) void {
        self.allocator.free(self.descr);
        for (self.txids) |t| self.allocator.free(t);
        self.allocator.free(self.txids);
    }
};

pub const CancelResult = struct {
    count: u32,
    pending: bool,
};

pub const CancelAllResult = struct {
    count: u32,
};
