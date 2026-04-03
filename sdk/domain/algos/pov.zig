// POV — Percentage of Volume execution algorithm.
// Targets a configured percentage of market volume, capped at max_pct.

const std = @import("std");

pub const Side = enum { buy, sell };

pub const OrderType = enum { market, limit };

pub const Fill = struct {
    quantity: i64,
    price: i64,
};

pub const ChildOrder = struct {
    instrument: []const u8,
    side: Side,
    quantity: i64,
    order_type: OrderType,
    price: ?i64,
};

pub const PovParams = struct {
    total_qty: i64,
    target_pct: f64,
    max_pct: f64,
    instrument: []const u8,
    side: Side,
};

pub const PovAlgo = struct {
    params: PovParams,
    filled_qty: i64,
    market_volume: i64,

    pub fn init(params: PovParams) PovAlgo {
        return PovAlgo{
            .params = params,
            .filled_qty = 0,
            .market_volume = 0,
        };
    }

    /// Called on each market volume update.
    /// Returns a child order targeting `target_pct` of the incoming volume,
    /// capped at `max_pct` and the remaining total quantity.
    pub fn onMarketData(self: *PovAlgo, market_volume: i64, now: u128) ?ChildOrder {
        _ = now;

        if (market_volume <= 0) return null;

        self.market_volume += market_volume;

        const remaining = self.params.total_qty - self.filled_qty;
        if (remaining <= 0) return null;

        // Target this slice: market_volume * target_pct.
        var target: i64 = @intFromFloat(
            @as(f64, @floatFromInt(market_volume)) * self.params.target_pct,
        );

        // Apply max_pct cap.
        const max_this_slice: i64 = @intFromFloat(
            @as(f64, @floatFromInt(market_volume)) * self.params.max_pct,
        );
        if (target > max_this_slice) target = max_this_slice;

        // Don't exceed remaining.
        if (target > remaining) target = remaining;

        if (target <= 0) return null;

        return ChildOrder{
            .instrument = self.params.instrument,
            .side = self.params.side,
            .quantity = target,
            .order_type = .market,
            .price = null,
        };
    }

    pub fn onFill(self: *PovAlgo, fill: Fill) void {
        self.filled_qty += fill.quantity;
    }
};
