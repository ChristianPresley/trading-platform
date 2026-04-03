// Basis trading strategy: spot vs futures
// Computes annualized basis and generates entry/exit signals.

const std = @import("std");
const orderbook = @import("orderbook");
const L2Book = orderbook.L2Book;

pub const Direction = enum {
    enter_long_basis, // long spot, short futures (futures expensive)
    enter_short_basis, // short spot, long futures (spot expensive)
    exit,
};

pub const Signal = struct {
    direction: Direction,
    spot_qty: i64,
    futures_qty: i64,
    expected_basis_bps: f64,
};

pub const BasisConfig = struct {
    entry_threshold_bps: f64,
    exit_threshold_bps: f64,
    max_position: i64,
    instrument_spot: []const u8,
    instrument_futures: []const u8,
    days_to_expiry: f64,
};

pub const PositionState = enum { flat, long_basis, short_basis };

pub const BasisStrategy = struct {
    allocator: std.mem.Allocator,
    config: BasisConfig,
    state: PositionState,

    // Max annualized basis cap to avoid division by near-zero days_to_expiry
    const MAX_BASIS_BPS: f64 = 100_000.0;

    pub fn init(allocator: std.mem.Allocator, config: BasisConfig) !BasisStrategy {
        return BasisStrategy{
            .allocator = allocator,
            .config = config,
            .state = .flat,
        };
    }

    pub fn deinit(self: *BasisStrategy) void {
        _ = self;
    }

    /// Compute annualized basis in bps:
    /// basis = (futures_mid - spot_mid) / spot_mid * (365 / days_to_expiry) * 10000
    fn computeBasisBps(self: *const BasisStrategy, spot: *const L2Book, futures: *const L2Book) ?f64 {
        const spot_mid = spot.midPrice() orelse return null;
        const futures_mid = futures.midPrice() orelse return null;

        if (spot_mid == 0) return null;
        if (self.config.days_to_expiry <= 0.0) return MAX_BASIS_BPS;

        const raw_basis = (@as(f64, @floatFromInt(futures_mid)) - @as(f64, @floatFromInt(spot_mid))) /
            @as(f64, @floatFromInt(spot_mid));
        const annualized = raw_basis * (365.0 / self.config.days_to_expiry) * 10000.0;

        // Cap at max
        if (annualized > MAX_BASIS_BPS) return MAX_BASIS_BPS;
        if (annualized < -MAX_BASIS_BPS) return -MAX_BASIS_BPS;
        return annualized;
    }

    pub fn onMarketData(self: *BasisStrategy, spot: *const L2Book, futures: *const L2Book) ?Signal {
        const basis_bps = self.computeBasisBps(spot, futures) orelse return null;
        const qty = self.config.max_position;

        switch (self.state) {
            .flat => {
                if (basis_bps > self.config.entry_threshold_bps) {
                    // Futures expensive vs spot: long spot, short futures
                    self.state = .long_basis;
                    return Signal{
                        .direction = .enter_long_basis,
                        .spot_qty = qty,
                        .futures_qty = qty,
                        .expected_basis_bps = basis_bps,
                    };
                } else if (basis_bps < -self.config.entry_threshold_bps) {
                    // Spot expensive vs futures: short spot, long futures
                    self.state = .short_basis;
                    return Signal{
                        .direction = .enter_short_basis,
                        .spot_qty = qty,
                        .futures_qty = qty,
                        .expected_basis_bps = basis_bps,
                    };
                }
                return null;
            },
            .long_basis => {
                // Exit when basis narrows to exit_threshold
                if (basis_bps <= self.config.exit_threshold_bps) {
                    self.state = .flat;
                    return Signal{
                        .direction = .exit,
                        .spot_qty = qty,
                        .futures_qty = qty,
                        .expected_basis_bps = basis_bps,
                    };
                }
                return null;
            },
            .short_basis => {
                // Exit when basis narrows to -exit_threshold
                if (basis_bps >= -self.config.exit_threshold_bps) {
                    self.state = .flat;
                    return Signal{
                        .direction = .exit,
                        .spot_qty = qty,
                        .futures_qty = qty,
                        .expected_basis_bps = basis_bps,
                    };
                }
                return null;
            },
        }
    }
};
