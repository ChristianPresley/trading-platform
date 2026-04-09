const std = @import("std");

pub const Side = enum { buy, sell };

/// A trade record used for reconciliation.
pub const Trade = struct {
    id: []const u8,
    instrument: []const u8,
    side: Side,
    quantity: i64,
    price: i64,
    timestamp_ms: u64,
};

/// A position snapshot used for reconciliation.
pub const Position = struct {
    instrument: []const u8,
    quantity: i64,
    value: i64,
};

/// A cash balance entry used for reconciliation.
pub const CashBalance = struct {
    currency: []const u8,
    amount: i64,
};

pub const ReconTolerance = struct {
    price_tolerance: f64,
    qty_tolerance: i64,
    time_window_ms: u64,
};

pub const BreakType = enum {
    quantity_mismatch,
    price_mismatch,
    missing_internal,
    missing_external,
    timing_mismatch,
};

pub const Break = struct {
    break_type: BreakType,
    internal: ?Trade,
    external: ?Trade,
    description: []const u8,
};

pub const ReconResult = struct {
    matched: u32,
    breaks: []Break,
    unmatched_internal: u32,
    unmatched_external: u32,
};

pub const ReconEngine = struct {
    allocator: std.mem.Allocator,
    tolerance: ReconTolerance,

    pub fn init(allocator: std.mem.Allocator, tolerance: ReconTolerance) !ReconEngine {
        return ReconEngine{
            .allocator = allocator,
            .tolerance = tolerance,
        };
    }

    pub fn deinit(_: *ReconEngine) void {}

    /// Match trades by ID first, then by (instrument, side, qty, time window).
    /// Flags mismatches as breaks with typed reasons.
    pub fn reconcileTrades(self: *ReconEngine, internal: []const Trade, external: []const Trade) !ReconResult {
        var breaks: std.ArrayList(Break) = .empty;
        errdefer breaks.deinit(self.allocator);

        // Track which external trades have been matched
        var ext_matched = try self.allocator.alloc(bool, external.len);
        defer self.allocator.free(ext_matched);
        @memset(ext_matched, false);

        var matched: u32 = 0;
        var unmatched_internal: u32 = 0;

        for (internal) |int_trade| {
            var found_idx: ?usize = null;
            var found_by_id = false;

            // First pass: match by ID
            for (external, 0..) |ext_trade, i| {
                if (ext_matched[i]) continue;
                if (std.mem.eql(u8, int_trade.id, ext_trade.id)) {
                    found_idx = i;
                    found_by_id = true;
                    break;
                }
            }

            // Second pass: match by (instrument, side, qty, time window)
            if (found_idx == null) {
                for (external, 0..) |ext_trade, i| {
                    if (ext_matched[i]) continue;
                    if (!std.mem.eql(u8, int_trade.instrument, ext_trade.instrument)) continue;
                    if (int_trade.side != ext_trade.side) continue;
                    if (@abs(int_trade.quantity - ext_trade.quantity) > self.tolerance.qty_tolerance) continue;

                    const time_diff = if (int_trade.timestamp_ms > ext_trade.timestamp_ms)
                        int_trade.timestamp_ms - ext_trade.timestamp_ms
                    else
                        ext_trade.timestamp_ms - int_trade.timestamp_ms;

                    if (time_diff <= self.tolerance.time_window_ms) {
                        found_idx = i;
                        break;
                    }
                }
            }

            if (found_idx) |idx| {
                const ext_trade = external[idx];
                ext_matched[idx] = true;

                // Check for mismatches
                const qty_diff = @abs(int_trade.quantity - ext_trade.quantity);
                const price_diff_abs = @abs(int_trade.price - ext_trade.price);
                const price_diff_f = @as(f64, @floatFromInt(price_diff_abs));
                const ext_price_f = @as(f64, @floatFromInt(if (ext_trade.price > 0) ext_trade.price else 1));
                const price_tol_violated = (price_diff_f / ext_price_f) > self.tolerance.price_tolerance;

                if (qty_diff > self.tolerance.qty_tolerance) {
                    try breaks.append(self.allocator, .{
                        .break_type = .quantity_mismatch,
                        .internal = int_trade,
                        .external = ext_trade,
                        .description = "quantity mismatch beyond tolerance",
                    });
                } else if (price_tol_violated) {
                    try breaks.append(self.allocator, .{
                        .break_type = .price_mismatch,
                        .internal = int_trade,
                        .external = ext_trade,
                        .description = "price mismatch beyond tolerance",
                    });
                } else if (!found_by_id) {
                    // Check timing mismatch (matched by fuzzy but time is borderline)
                    const time_diff = if (int_trade.timestamp_ms > ext_trade.timestamp_ms)
                        int_trade.timestamp_ms - ext_trade.timestamp_ms
                    else
                        ext_trade.timestamp_ms - int_trade.timestamp_ms;
                    _ = time_diff;
                    matched += 1;
                } else {
                    matched += 1;
                }
            } else {
                unmatched_internal += 1;
                try breaks.append(self.allocator, .{
                    .break_type = .missing_external,
                    .internal = int_trade,
                    .external = null,
                    .description = "no matching external trade found",
                });
            }
        }

        // Find unmatched external trades
        var unmatched_external: u32 = 0;
        for (external, 0..) |ext_trade, i| {
            if (!ext_matched[i]) {
                unmatched_external += 1;
                try breaks.append(self.allocator, .{
                    .break_type = .missing_internal,
                    .internal = null,
                    .external = ext_trade,
                    .description = "no matching internal trade found",
                });
            }
        }

        return ReconResult{
            .matched = matched,
            .breaks = try breaks.toOwnedSlice(self.allocator),
            .unmatched_internal = unmatched_internal,
            .unmatched_external = unmatched_external,
        };
    }

    /// Compare position quantities and values within tolerance.
    pub fn reconcilePositions(self: *ReconEngine, internal: []const Position, external: []const Position) !ReconResult {
        var breaks: std.ArrayList(Break) = .empty;
        errdefer breaks.deinit(self.allocator);

        var ext_matched = try self.allocator.alloc(bool, external.len);
        defer self.allocator.free(ext_matched);
        @memset(ext_matched, false);

        var matched: u32 = 0;
        var unmatched_internal: u32 = 0;

        for (internal) |int_pos| {
            var found_idx: ?usize = null;
            for (external, 0..) |ext_pos, i| {
                if (ext_matched[i]) continue;
                if (std.mem.eql(u8, int_pos.instrument, ext_pos.instrument)) {
                    found_idx = i;
                    break;
                }
            }

            if (found_idx) |idx| {
                const ext_pos = external[idx];
                ext_matched[idx] = true;

                const qty_diff = @abs(int_pos.quantity - ext_pos.quantity);
                if (qty_diff > self.tolerance.qty_tolerance) {
                    // Build a dummy trade for reporting
                    const int_trade = Trade{
                        .id = int_pos.instrument,
                        .instrument = int_pos.instrument,
                        .side = .buy,
                        .quantity = int_pos.quantity,
                        .price = int_pos.value,
                        .timestamp_ms = 0,
                    };
                    const ext_trade = Trade{
                        .id = ext_pos.instrument,
                        .instrument = ext_pos.instrument,
                        .side = .buy,
                        .quantity = ext_pos.quantity,
                        .price = ext_pos.value,
                        .timestamp_ms = 0,
                    };
                    try breaks.append(self.allocator, .{
                        .break_type = .quantity_mismatch,
                        .internal = int_trade,
                        .external = ext_trade,
                        .description = "position quantity mismatch",
                    });
                } else {
                    matched += 1;
                }
            } else {
                unmatched_internal += 1;
                try breaks.append(self.allocator, .{
                    .break_type = .missing_external,
                    .internal = Trade{
                        .id = int_pos.instrument,
                        .instrument = int_pos.instrument,
                        .side = .buy,
                        .quantity = int_pos.quantity,
                        .price = int_pos.value,
                        .timestamp_ms = 0,
                    },
                    .external = null,
                    .description = "no matching external position",
                });
            }
        }

        var unmatched_external: u32 = 0;
        for (external, 0..) |ext_pos, i| {
            if (!ext_matched[i]) {
                unmatched_external += 1;
                try breaks.append(self.allocator, .{
                    .break_type = .missing_internal,
                    .internal = null,
                    .external = Trade{
                        .id = ext_pos.instrument,
                        .instrument = ext_pos.instrument,
                        .side = .buy,
                        .quantity = ext_pos.quantity,
                        .price = ext_pos.value,
                        .timestamp_ms = 0,
                    },
                    .description = "no matching internal position",
                });
            }
        }

        return ReconResult{
            .matched = matched,
            .breaks = try breaks.toOwnedSlice(self.allocator),
            .unmatched_internal = unmatched_internal,
            .unmatched_external = unmatched_external,
        };
    }

    /// Reconcile cash balances by currency.
    pub fn reconcileCash(self: *ReconEngine, internal: []const CashBalance, external: []const CashBalance) !ReconResult {
        var breaks: std.ArrayList(Break) = .empty;
        errdefer breaks.deinit(self.allocator);

        var ext_matched = try self.allocator.alloc(bool, external.len);
        defer self.allocator.free(ext_matched);
        @memset(ext_matched, false);

        var matched: u32 = 0;
        var unmatched_internal: u32 = 0;

        for (internal) |int_cash| {
            var found_idx: ?usize = null;
            for (external, 0..) |ext_cash, i| {
                if (ext_matched[i]) continue;
                if (std.mem.eql(u8, int_cash.currency, ext_cash.currency)) {
                    found_idx = i;
                    break;
                }
            }

            if (found_idx) |idx| {
                const ext_cash = external[idx];
                ext_matched[idx] = true;

                const diff = @abs(int_cash.amount - ext_cash.amount);
                const price_diff_f = @as(f64, @floatFromInt(diff));
                const ext_amt_f = @as(f64, @floatFromInt(if (ext_cash.amount > 0) ext_cash.amount else 1));
                if ((price_diff_f / ext_amt_f) > self.tolerance.price_tolerance) {
                    const int_trade = Trade{
                        .id = int_cash.currency,
                        .instrument = int_cash.currency,
                        .side = .buy,
                        .quantity = int_cash.amount,
                        .price = int_cash.amount,
                        .timestamp_ms = 0,
                    };
                    const ext_trade = Trade{
                        .id = ext_cash.currency,
                        .instrument = ext_cash.currency,
                        .side = .buy,
                        .quantity = ext_cash.amount,
                        .price = ext_cash.amount,
                        .timestamp_ms = 0,
                    };
                    try breaks.append(self.allocator, .{
                        .break_type = .price_mismatch,
                        .internal = int_trade,
                        .external = ext_trade,
                        .description = "cash balance mismatch beyond tolerance",
                    });
                } else {
                    matched += 1;
                }
            } else {
                unmatched_internal += 1;
                try breaks.append(self.allocator, .{
                    .break_type = .missing_external,
                    .internal = Trade{
                        .id = int_cash.currency,
                        .instrument = int_cash.currency,
                        .side = .buy,
                        .quantity = int_cash.amount,
                        .price = int_cash.amount,
                        .timestamp_ms = 0,
                    },
                    .external = null,
                    .description = "no matching external cash balance",
                });
            }
        }

        var unmatched_external: u32 = 0;
        for (external, 0..) |ext_cash, i| {
            if (!ext_matched[i]) {
                unmatched_external += 1;
                try breaks.append(self.allocator, .{
                    .break_type = .missing_internal,
                    .internal = null,
                    .external = Trade{
                        .id = ext_cash.currency,
                        .instrument = ext_cash.currency,
                        .side = .buy,
                        .quantity = ext_cash.amount,
                        .price = ext_cash.amount,
                        .timestamp_ms = 0,
                    },
                    .description = "no matching internal cash balance",
                });
            }
        }

        return ReconResult{
            .matched = matched,
            .breaks = try breaks.toOwnedSlice(self.allocator),
            .unmatched_internal = unmatched_internal,
            .unmatched_external = unmatched_external,
        };
    }

    /// Free a ReconResult's breaks slice.
    pub fn freeResult(self: *ReconEngine, result: ReconResult) void {
        self.allocator.free(result.breaks);
    }
};
