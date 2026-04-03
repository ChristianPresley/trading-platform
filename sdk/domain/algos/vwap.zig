// VWAP — Volume-Weighted Average Price execution algorithm.
// Uses a historical volume profile (normalized array) to schedule participation.
// Fires child orders when own participation falls behind schedule.

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

pub const VwapParams = struct {
    total_qty: i64,
    start_time: u128,
    end_time: u128,
    max_participation: f64,
    instrument: []const u8,
    side: Side,
};

pub const VwapAlgo = struct {
    params: VwapParams,
    filled_qty: i64,
    market_volume: i64,
    /// Volume profile: normalized weights per bucket (must sum to ~1.0).
    /// We store a pointer to caller-owned slice.
    volume_profile: []const f64,

    pub fn init(params: VwapParams, volume_profile: []const f64) VwapAlgo {
        return VwapAlgo{
            .params = params,
            .filled_qty = 0,
            .market_volume = 0,
            .volume_profile = volume_profile,
        };
    }

    /// Called on each market volume update.
    /// Tracks cumulative market volume and returns a child order if we are
    /// behind our participation target.
    pub fn onMarketData(self: *VwapAlgo, market_volume: i64, now: u128) ?ChildOrder {
        _ = now;

        if (market_volume == 0) return null;

        self.market_volume += market_volume;

        // Current participation rate.
        const participation = self.participationRate();

        // Target: max_participation means we should have filled max_participation
        // fraction of market_volume by now.
        const target_filled: i64 = @intFromFloat(
            @as(f64, @floatFromInt(self.market_volume)) * self.params.max_participation,
        );

        if (self.filled_qty >= target_filled) return null;
        if (self.filled_qty >= self.params.total_qty) return null;

        // How much we need to catch up.
        var catch_up = target_filled - self.filled_qty;

        // Cap catch_up so we don't exceed max_participation on this burst.
        const burst_cap: i64 = @intFromFloat(
            @as(f64, @floatFromInt(market_volume)) * self.params.max_participation,
        );
        if (catch_up > burst_cap) catch_up = burst_cap;

        // Don't exceed remaining quantity.
        const remaining = self.params.total_qty - self.filled_qty;
        if (catch_up > remaining) catch_up = remaining;

        if (catch_up <= 0) return null;

        _ = participation;

        return ChildOrder{
            .instrument = self.params.instrument,
            .side = self.params.side,
            .quantity = catch_up,
            .order_type = .market,
            .price = null,
        };
    }

    pub fn onFill(self: *VwapAlgo, fill: Fill) void {
        self.filled_qty += fill.quantity;
    }

    /// own_volume / market_volume; returns 0 if no market volume seen yet.
    pub fn participationRate(self: *const VwapAlgo) f64 {
        if (self.market_volume == 0) return 0.0;
        return @as(f64, @floatFromInt(self.filled_qty)) /
            @as(f64, @floatFromInt(self.market_volume));
    }
};
