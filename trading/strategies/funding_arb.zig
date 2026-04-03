// Perpetual funding rate arbitrage strategy
// Long spot + short perp when funding positive, reverse when negative.

const std = @import("std");
const orderbook = @import("orderbook");
const L2Book = orderbook.L2Book;

pub const FundingDirection = enum { long_spot_short_perp, short_spot_long_perp, flat };

pub const Signal = struct {
    direction: FundingDirection,
    spot_qty: i64,
    perp_qty: i64,
    funding_rate: f64,
};

pub const FundingArbConfig = struct {
    min_rate_bps: f64, // minimum absolute funding rate to trigger entry
    max_position: i64,
    instrument_spot: []const u8,
    instrument_perp: []const u8,
};

pub const FundingArbStrategy = struct {
    allocator: std.mem.Allocator,
    config: FundingArbConfig,
    position: FundingDirection,
    last_funding_rate: f64,

    pub fn init(allocator: std.mem.Allocator, config: FundingArbConfig) !FundingArbStrategy {
        return FundingArbStrategy{
            .allocator = allocator,
            .config = config,
            .position = .flat,
            .last_funding_rate = 0.0,
        };
    }

    pub fn deinit(self: *FundingArbStrategy) void {
        _ = self;
    }

    /// Called when a new funding rate is published.
    /// Returns a Signal if entry/exit conditions are met.
    pub fn onFundingRate(self: *FundingArbStrategy, rate: f64, next_funding_time: u128) ?Signal {
        _ = next_funding_time;
        self.last_funding_rate = rate;
        const rate_bps = rate * 10000.0;

        const qty = self.config.max_position;

        switch (self.position) {
            .flat => {
                if (rate_bps > self.config.min_rate_bps) {
                    // Positive funding: longs pay shorts -> short perp, long spot
                    self.position = .long_spot_short_perp;
                    return Signal{
                        .direction = .long_spot_short_perp,
                        .spot_qty = qty,
                        .perp_qty = qty,
                        .funding_rate = rate,
                    };
                } else if (rate_bps < -self.config.min_rate_bps) {
                    // Negative funding: shorts pay longs -> long perp, short spot
                    self.position = .short_spot_long_perp;
                    return Signal{
                        .direction = .short_spot_long_perp,
                        .spot_qty = qty,
                        .perp_qty = qty,
                        .funding_rate = rate,
                    };
                }
                return null;
            },
            .long_spot_short_perp => {
                // Exit if funding flips to negative (shorts would now pay)
                if (rate_bps <= 0.0) {
                    self.position = .flat;
                    return Signal{
                        .direction = .flat,
                        .spot_qty = qty,
                        .perp_qty = qty,
                        .funding_rate = rate,
                    };
                }
                return null;
            },
            .short_spot_long_perp => {
                // Exit if funding flips to positive (longs would now pay)
                if (rate_bps >= 0.0) {
                    self.position = .flat;
                    return Signal{
                        .direction = .flat,
                        .spot_qty = qty,
                        .perp_qty = qty,
                        .funding_rate = rate,
                    };
                }
                return null;
            },
        }
    }

    /// Called on market data update.
    /// Monitors convergence/divergence for position management.
    pub fn onMarketData(self: *FundingArbStrategy, spot: *const L2Book, perp: *const L2Book) ?Signal {
        const spot_mid = spot.midPrice() orelse return null;
        const perp_mid = perp.midPrice() orelse return null;

        if (spot_mid == 0) return null;

        // Compute basis between perp and spot
        const basis_bps = (@as(f64, @floatFromInt(perp_mid)) - @as(f64, @floatFromInt(spot_mid))) /
            @as(f64, @floatFromInt(spot_mid)) * 10000.0;

        const qty = self.config.max_position;

        // Exit if basis has converged (near zero) and funding rate has dropped below threshold
        switch (self.position) {
            .flat => return null,
            .long_spot_short_perp => {
                // We are long spot, short perp. Basis should be positive initially.
                // Exit when basis narrows (perp converges toward spot)
                if (@abs(basis_bps) < self.config.min_rate_bps * 0.5) {
                    self.position = .flat;
                    return Signal{
                        .direction = .flat,
                        .spot_qty = qty,
                        .perp_qty = qty,
                        .funding_rate = self.last_funding_rate,
                    };
                }
                return null;
            },
            .short_spot_long_perp => {
                // We are short spot, long perp.
                if (@abs(basis_bps) < self.config.min_rate_bps * 0.5) {
                    self.position = .flat;
                    return Signal{
                        .direction = .flat,
                        .spot_qty = qty,
                        .perp_qty = qty,
                        .funding_rate = self.last_funding_rate,
                    };
                }
                return null;
            },
        }
    }
};
