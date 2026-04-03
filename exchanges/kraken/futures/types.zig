// Kraken futures API request/response types

const std = @import("std");

pub const InstrumentInfo = struct {
    symbol: []const u8,
    underlying: []const u8,
    last_price: []const u8,
    mark_price: []const u8,
    contract_size: f64,
    tradeable: bool,
};

pub const InstrumentsResult = struct {
    allocator: std.mem.Allocator,
    instruments: []InstrumentInfo,

    pub fn deinit(self: *InstrumentsResult) void {
        for (self.instruments) |inst| {
            self.allocator.free(inst.symbol);
            self.allocator.free(inst.underlying);
            self.allocator.free(inst.last_price);
            self.allocator.free(inst.mark_price);
        }
        self.allocator.free(self.instruments);
    }
};

pub const FuturesTicker = struct {
    symbol: []const u8,
    bid: []const u8,
    ask: []const u8,
    last: []const u8,
    vol24h: []const u8,
    open_interest: []const u8,
};

pub const TickersResult = struct {
    allocator: std.mem.Allocator,
    tickers: []FuturesTicker,

    pub fn deinit(self: *TickersResult) void {
        for (self.tickers) |t| {
            self.allocator.free(t.symbol);
            self.allocator.free(t.bid);
            self.allocator.free(t.ask);
            self.allocator.free(t.last);
            self.allocator.free(t.vol24h);
            self.allocator.free(t.open_interest);
        }
        self.allocator.free(self.tickers);
    }
};

pub const FuturesOrderBookEntry = struct {
    price: f64,
    size: f64,
};

pub const FuturesOrderBookResult = struct {
    allocator: std.mem.Allocator,
    symbol: []const u8,
    bids: []FuturesOrderBookEntry,
    asks: []FuturesOrderBookEntry,

    pub fn deinit(self: *FuturesOrderBookResult) void {
        self.allocator.free(self.symbol);
        self.allocator.free(self.bids);
        self.allocator.free(self.asks);
    }
};

pub const AccountBalance = struct {
    currency: []const u8,
    balance: f64,
};

pub const AccountsResult = struct {
    allocator: std.mem.Allocator,
    balances: []AccountBalance,

    pub fn deinit(self: *AccountsResult) void {
        for (self.balances) |b| self.allocator.free(b.currency);
        self.allocator.free(self.balances);
    }
};

pub const FuturesOrderRequest = struct {
    order_type: []const u8, // "lmt", "mkt", "stp", "take_profit"
    symbol: []const u8,
    side: []const u8,       // "buy" or "sell"
    size: f64,
    limit_price: ?f64,
    stop_price: ?f64,
    client_order_id: ?[]const u8,
    reduce_only: bool,
};

pub const SendOrderResult = struct {
    allocator: std.mem.Allocator,
    order_id: []const u8,
    status: []const u8,

    pub fn deinit(self: *SendOrderResult) void {
        self.allocator.free(self.order_id);
        self.allocator.free(self.status);
    }
};

pub const FuturesCancelResult = struct {
    allocator: std.mem.Allocator,
    status: []const u8,

    pub fn deinit(self: *FuturesCancelResult) void {
        self.allocator.free(self.status);
    }
};

pub const FuturesCancelAllResult = struct {
    cancelled_count: u32,
};

pub const DeadManResult = struct {
    allocator: std.mem.Allocator,
    status: []const u8,
    trigger_time: i64,

    pub fn deinit(self: *DeadManResult) void {
        self.allocator.free(self.status);
    }
};
