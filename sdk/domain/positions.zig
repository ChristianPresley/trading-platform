const std = @import("std");

pub const Side = enum { buy, sell };

pub const CostBasisMethod = enum {
    fifo,
    lifo,
    average_cost,
};

pub const PositionKey = struct {
    account: []const u8,
    instrument: []const u8,
    settlement_date: u32,
    currency: []const u8,
};

pub const PositionConfig = struct {
    cost_basis_method: CostBasisMethod,
    base_currency: []const u8,
};

/// A lot represents a single fill that contributed to the position.
pub const Lot = struct {
    quantity: i64,
    price: i64,
    timestamp: u128,
};

/// Current position state for a PositionKey.
pub const Position = struct {
    key: PositionKey,
    /// Net open quantity (positive = long, negative = short)
    quantity: i64,
    /// Average cost of open position in base currency (integer price units)
    avg_cost: i64,
    /// Cumulative realized P&L (in integer price units × quantity)
    realized_pnl: i64,
    /// Open lots for FIFO/LIFO cost basis tracking
    lots: std.ArrayList(Lot),
};

/// Fill event that drives position updates.
pub const Fill = struct {
    instrument: []const u8,
    side: Side,
    quantity: i64,
    price: i64,
    timestamp: u128,
    account: []const u8,
    currency: []const u8,
    settlement_date: u32,
};

/// Manages positions across multiple keys, supporting FIFO, LIFO, and average cost basis methods.
pub const PositionManager = struct {
    allocator: std.mem.Allocator,
    config: PositionConfig,
    /// Keyed by a string representation of PositionKey
    positions: std.StringHashMap(Position),
    /// Storage for formatted keys (to keep ownership)
    key_buf: std.ArrayList([]u8),

    pub fn init(allocator: std.mem.Allocator, config: PositionConfig) !PositionManager {
        return PositionManager{
            .allocator = allocator,
            .config = config,
            .positions = std.StringHashMap(Position).init(allocator),
            .key_buf = .{},
        };
    }

    pub fn deinit(self: *PositionManager) void {
        var it = self.positions.iterator();
        while (it.next()) |entry| {
            entry.value_ptr.lots.deinit(self.allocator);
        }
        self.positions.deinit();
        for (self.key_buf.items) |kb| {
            self.allocator.free(kb);
        }
        self.key_buf.deinit(self.allocator);
    }

    /// Process a fill event, updating position quantity, lots, and realized P&L.
    pub fn onFill(self: *PositionManager, fill: Fill) !void {
        const key = PositionKey{
            .account = fill.account,
            .instrument = fill.instrument,
            .settlement_date = fill.settlement_date,
            .currency = fill.currency,
        };

        const key_str = try self.formatKey(key);
        const gop = try self.positions.getOrPut(key_str);
        if (!gop.found_existing) {
            gop.value_ptr.* = Position{
                .key = key,
                .quantity = 0,
                .avg_cost = 0,
                .realized_pnl = 0,
                .lots = .{},
            };
        }
        const pos = gop.value_ptr;

        const is_buy = fill.side == .buy;
        const fill_qty = fill.quantity;

        // Determine if this fill is in the same direction as open position or opposite
        const position_is_long = pos.quantity > 0;
        const position_is_short = pos.quantity < 0;
        const opening = pos.quantity == 0 or
            (is_buy and position_is_long) or
            (!is_buy and position_is_short);

        if (opening) {
            // Opening or adding to position: add lot
            try pos.lots.append(self.allocator, .{
                .quantity = fill_qty,
                .price = fill.price,
                .timestamp = fill.timestamp,
            });
            if (is_buy) {
                pos.quantity += fill_qty;
            } else {
                pos.quantity -= fill_qty;
            }
            pos.avg_cost = self.computeAvgCost(pos);
        } else {
            // Closing: reduce existing lots and realize P&L
            if (self.config.cost_basis_method == .average_cost) {
                // Average cost: realize P&L at avg_cost basis for the entire closing quantity
                const avg = pos.avg_cost;
                const close_qty = fill_qty; // assume we close at most |pos.quantity| from the open side
                const actual_close = @min(close_qty, if (pos.quantity > 0) pos.quantity else -pos.quantity);

                const pnl: i64 = if (!is_buy)
                    (fill.price - avg) * actual_close
                else
                    (avg - fill.price) * actual_close;

                pos.realized_pnl += pnl;

                // Remove lots proportionally (we reduce total open qty)
                var to_remove: i64 = actual_close;
                var idx: usize = 0;
                while (idx < pos.lots.items.len and to_remove > 0) {
                    const lot = &pos.lots.items[idx];
                    if (lot.quantity <= to_remove) {
                        to_remove -= lot.quantity;
                        _ = pos.lots.orderedRemove(idx);
                        // Don't increment idx — the next item slides into place
                    } else {
                        lot.quantity -= to_remove;
                        to_remove = 0;
                        idx += 1;
                    }
                }

                // Update net quantity
                if (is_buy) {
                    pos.quantity += fill_qty;
                } else {
                    pos.quantity -= fill_qty;
                }

                // If position crossed zero, open new lot in opposite direction
                const overshoot = fill_qty - actual_close;
                if (overshoot > 0) {
                    try pos.lots.append(self.allocator, .{
                        .quantity = overshoot,
                        .price = fill.price,
                        .timestamp = fill.timestamp,
                    });
                }

                pos.avg_cost = if (pos.lots.items.len > 0) self.computeAvgCost(pos) else 0;
            } else {
                // FIFO / LIFO: close lots one by one at their individual cost basis
                var remaining = fill_qty;

                while (remaining > 0 and pos.lots.items.len > 0) {
                    const lot_idx: usize = switch (self.config.cost_basis_method) {
                        .fifo => 0,
                        .lifo => pos.lots.items.len - 1,
                        .average_cost => unreachable,
                    };

                    const lot = &pos.lots.items[lot_idx];
                    const close_qty = @min(remaining, lot.quantity);

                    const pnl: i64 = if (!is_buy)
                        (fill.price - lot.price) * close_qty
                    else
                        (lot.price - fill.price) * close_qty;

                    pos.realized_pnl += pnl;
                    lot.quantity -= close_qty;
                    remaining -= close_qty;

                    if (lot.quantity == 0) {
                        _ = pos.lots.orderedRemove(lot_idx);
                    }
                }

                // Update net quantity
                if (is_buy) {
                    pos.quantity += fill_qty;
                } else {
                    pos.quantity -= fill_qty;
                }

                // If position crossed zero (remaining qty), open new lot in opposite direction
                if (remaining > 0) {
                    try pos.lots.append(self.allocator, .{
                        .quantity = remaining,
                        .price = fill.price,
                        .timestamp = fill.timestamp,
                    });
                }

                pos.avg_cost = if (pos.lots.items.len > 0) self.computeAvgCost(pos) else 0;
            }
        }
    }

    /// Get position by key (returns null if not found).
    pub fn getPosition(self: *PositionManager, key: PositionKey) ?*const Position {
        const key_str = self.formatKeyStatic(key) catch return null;
        return self.positions.getPtr(key_str);
    }

    /// Sum of realized P&L for a position key.
    pub fn realizedPnl(self: *PositionManager, key: PositionKey) ?i64 {
        const key_str = self.formatKeyStatic(key) catch return null;
        const pos = self.positions.getPtr(key_str) orelse return null;
        return pos.realized_pnl;
    }

    /// Unrealized P&L: (mark_price - avg_cost) * open_qty for longs,
    ///                  (avg_cost - mark_price) * |open_qty| for shorts.
    pub fn unrealizedPnl(self: *PositionManager, key: PositionKey, mark_price: i64) ?i64 {
        const key_str = self.formatKeyStatic(key) catch return null;
        const pos = self.positions.getPtr(key_str) orelse return null;
        if (pos.quantity == 0) return 0;
        if (pos.quantity > 0) {
            return (mark_price - pos.avg_cost) * pos.quantity;
        } else {
            // Short position
            const abs_qty = -pos.quantity;
            return (pos.avg_cost - mark_price) * abs_qty;
        }
    }

    /// Returns all positions as a slice (valid until next mutation).
    pub fn allPositions(self: *PositionManager) []const Position {
        // Collect into an array via iterator — caller does NOT own this memory
        // We return a slice of the internal values (single-threaded safe)
        // Note: StringHashMap does not guarantee order, but the slice is valid.
        // We use a simple approach: collect value pointers.
        // Since we cannot return a stable slice from the hash map internals,
        // we use a cached approach: the caller must not mutate during iteration.
        return self.positions.values();
    }

    // --- Private helpers ---

    /// Compute average cost from open lots (weighted average).
    fn computeAvgCost(self: *PositionManager, pos: *Position) i64 {
        if (self.config.cost_basis_method == .average_cost) {
            // Recompute weighted average from all lots
            var total_qty: i64 = 0;
            var total_cost: i64 = 0;
            for (pos.lots.items) |lot| {
                total_qty += lot.quantity;
                total_cost += lot.price * lot.quantity;
            }
            if (total_qty == 0) return 0;
            return @divTrunc(total_cost, total_qty);
        }
        // For FIFO/LIFO: compute weighted average of remaining lots
        var total_qty: i64 = 0;
        var total_cost: i64 = 0;
        for (pos.lots.items) |lot| {
            total_qty += lot.quantity;
            total_cost += lot.price * lot.quantity;
        }
        if (total_qty == 0) return 0;
        return @divTrunc(total_cost, total_qty);
    }

    /// Format position key as a string for use as hash map key (allocated, owned by key_buf).
    fn formatKey(self: *PositionManager, key: PositionKey) ![]const u8 {
        const s = try std.fmt.allocPrint(
            self.allocator,
            "{s}|{s}|{d}|{s}",
            .{ key.account, key.instrument, key.settlement_date, key.currency },
        );
        try self.key_buf.append(self.allocator, s);
        return s;
    }

    /// Format position key into a stack buffer (no allocation).
    /// The buffer must outlive the returned slice.
    fn formatKeyStatic(_: *PositionManager, key: PositionKey) ![]const u8 {
        // Use thread-local buffer for lookups (single-threaded)
        const Static = struct {
            var buf: [512]u8 = undefined;
        };
        return std.fmt.bufPrint(&Static.buf, "{s}|{s}|{d}|{s}", .{
            key.account, key.instrument, key.settlement_date, key.currency,
        });
    }
};
