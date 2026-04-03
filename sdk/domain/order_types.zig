const std = @import("std");

pub const OrderType = enum {
    market,
    limit,
    stop,
    stop_limit,
    trailing_stop,
};

pub const TimeInForce = enum {
    day,
    gtc,
    ioc,
    fok,
    gtd,
};

/// Returns FIX OrdType(40) value
pub fn orderTypeToFixTag(ot: OrderType) []const u8 {
    return switch (ot) {
        .market => "1",
        .limit => "2",
        .stop => "3",
        .stop_limit => "4",
        .trailing_stop => "P",
    };
}

/// Returns FIX TimeInForce(59) value
pub fn tifToFixTag(tif: TimeInForce) []const u8 {
    return switch (tif) {
        .day => "0",
        .gtc => "1",
        .ioc => "3",
        .fok => "4",
        .gtd => "6",
    };
}

/// Reverse mapping: FIX OrdType tag → OrderType
pub fn fixTagToOrderType(tag: []const u8) !OrderType {
    if (std.mem.eql(u8, tag, "1")) return .market;
    if (std.mem.eql(u8, tag, "2")) return .limit;
    if (std.mem.eql(u8, tag, "3")) return .stop;
    if (std.mem.eql(u8, tag, "4")) return .stop_limit;
    if (std.mem.eql(u8, tag, "P")) return .trailing_stop;
    return error.UnknownFixTag;
}

/// Reverse mapping: FIX TimeInForce tag → TimeInForce
pub fn fixTagToTif(tag: []const u8) !TimeInForce {
    if (std.mem.eql(u8, tag, "0")) return .day;
    if (std.mem.eql(u8, tag, "1")) return .gtc;
    if (std.mem.eql(u8, tag, "3")) return .ioc;
    if (std.mem.eql(u8, tag, "4")) return .fok;
    if (std.mem.eql(u8, tag, "6")) return .gtd;
    return error.UnknownFixTag;
}

/// Unique order identifier type
pub const OrderId = u64;

/// Side of the order
pub const Side = enum { buy, sell };

/// Bracket order: entry with take-profit and stop-loss children
pub const BracketOrder = struct {
    /// Entry order ID — parent
    entry_id: OrderId,
    /// Take-profit child order ID
    take_profit_id: OrderId,
    /// Stop-loss child order ID
    stop_loss_id: OrderId,

    /// Validate parent-child invariant: children must have different IDs from entry and from each other
    pub fn isValid(self: *const BracketOrder) bool {
        return self.entry_id != self.take_profit_id and
            self.entry_id != self.stop_loss_id and
            self.take_profit_id != self.stop_loss_id;
    }
};

/// OCO (One-Cancels-Other) group: two orders where triggering one cancels the other
pub const OcoGroup = struct {
    orders: [2]OrderId,

    /// Returns the counterpart order ID that should be cancelled when `triggered` fires
    pub fn cancelCounterpart(self: *OcoGroup, triggered: OrderId) OrderId {
        if (self.orders[0] == triggered) return self.orders[1];
        return self.orders[0];
    }
};
