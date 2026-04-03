// Implementation Shortfall — arrival price benchmark algorithm.
// Adaptive urgency: trades faster when price moves adversely, slower when favorable.

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

pub const IsParams = struct {
    total_qty: i64,
    instrument: []const u8,
    side: Side,
    /// Base urgency fraction per market-data event (0..1).
    base_urgency: f64,
    /// Extra urgency added per basis point of adverse move.
    urgency_per_bps: f64,
};

pub const IsAlgo = struct {
    params: IsParams,
    arrival_price: i64,
    filled_qty: i64,
    /// Weighted average fill price in fixed-point (same units as arrival_price).
    avg_fill_price: i64,

    pub fn init(params: IsParams, arrival_price: i64) IsAlgo {
        return IsAlgo{
            .params = params,
            .arrival_price = arrival_price,
            .filled_qty = 0,
            .avg_fill_price = 0,
        };
    }

    /// Called on each market data update.
    /// Returns a child order sized by adaptive urgency.
    pub fn onMarketData(
        self: *IsAlgo,
        mid_price: i64,
        spread: i64,
        volatility: f64,
        now: u128,
    ) ?ChildOrder {
        _ = spread;
        _ = volatility;
        _ = now;

        const remaining = self.params.total_qty - self.filled_qty;
        if (remaining <= 0) return null;

        // Compute adverse move in basis points.
        const price_diff = mid_price - self.arrival_price;
        // For a buy order, adverse move is price going UP (positive diff).
        // For a sell order, adverse move is price going DOWN (negative diff).
        const adverse_bps: f64 = switch (self.params.side) {
            .buy => if (price_diff > 0)
                @as(f64, @floatFromInt(price_diff)) * 10000.0 / @as(f64, @floatFromInt(self.arrival_price))
            else
                0.0,
            .sell => if (price_diff < 0)
                @as(f64, @floatFromInt(-price_diff)) * 10000.0 / @as(f64, @floatFromInt(self.arrival_price))
            else
                0.0,
        };

        // When price moves favorably (adverse_bps == 0), slow down execution.
        // When adversely, accelerate.
        const favorable_bps: f64 = switch (self.params.side) {
            .buy => if (price_diff < 0)
                @as(f64, @floatFromInt(-price_diff)) * 10000.0 / @as(f64, @floatFromInt(self.arrival_price))
            else
                0.0,
            .sell => if (price_diff > 0)
                @as(f64, @floatFromInt(price_diff)) * 10000.0 / @as(f64, @floatFromInt(self.arrival_price))
            else
                0.0,
        };

        var urgency = self.params.base_urgency + self.params.urgency_per_bps * adverse_bps;
        // Slow down when favorable.
        urgency -= self.params.urgency_per_bps * favorable_bps * 0.5;
        if (urgency < 0.01) urgency = 0.01;
        if (urgency > 1.0) urgency = 1.0;

        var qty: i64 = @intFromFloat(@as(f64, @floatFromInt(remaining)) * urgency);
        if (qty <= 0) qty = 1;
        if (qty > remaining) qty = remaining;

        return ChildOrder{
            .instrument = self.params.instrument,
            .side = self.params.side,
            .quantity = qty,
            .order_type = .market,
            .price = null,
        };
    }

    pub fn onFill(self: *IsAlgo, fill: Fill) void {
        if (fill.quantity <= 0) return;
        const total_filled_before = self.filled_qty;
        self.filled_qty += fill.quantity;
        // Update weighted average fill price.
        if (total_filled_before == 0) {
            self.avg_fill_price = fill.price;
        } else {
            // Weighted average.
            const total = self.filled_qty;
            self.avg_fill_price = @divTrunc(
                self.avg_fill_price * total_filled_before + fill.price * fill.quantity,
                total,
            );
        }
    }

    /// Implementation shortfall in basis points vs arrival price.
    /// Shortfall = (avg_fill_price - arrival_price) / arrival_price * 10000
    /// For buy orders positive means we paid more than arrival (bad).
    /// For sell orders negative means we received less (bad) — returned as positive.
    pub fn shortfall(self: *const IsAlgo) f64 {
        if (self.filled_qty == 0) return 0.0;
        if (self.arrival_price == 0) return 0.0;

        const diff = self.avg_fill_price - self.arrival_price;
        const raw_bps = @as(f64, @floatFromInt(diff)) * 10000.0 /
            @as(f64, @floatFromInt(self.arrival_price));

        return switch (self.params.side) {
            .buy => raw_bps,
            .sell => -raw_bps,
        };
    }
};
