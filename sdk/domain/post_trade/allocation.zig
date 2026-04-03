const std = @import("std");
const recon = @import("reconciliation");

pub const Side = recon.Side;
pub const Trade = recon.Trade;

pub const Fill = struct {
    quantity: i64,
    price: i64,
};

pub const AllocationEntry = struct {
    account: []const u8,
    ratio: f64,
};

/// Allocated trade: same as Trade but with an account field added to description.
pub const AllocatedTrade = struct {
    id: []const u8,
    instrument: []const u8,
    side: Side,
    quantity: i64,
    price: i64,
    timestamp_ms: u64,
    account: []const u8,
};

/// Split a block trade across accounts pro-rata by ratio, or by explicit amounts if ratios sum to 0.
/// Returns a slice of AllocatedTrade; caller owns the slice (freed with allocator.free).
pub fn allocateTrade(
    allocator: std.mem.Allocator,
    trade: Trade,
    accounts: []const AllocationEntry,
) ![]AllocatedTrade {
    if (accounts.len == 0) return &[_]AllocatedTrade{};

    var result = try allocator.alloc(AllocatedTrade, accounts.len);
    errdefer allocator.free(result);

    // Compute total ratio
    var total_ratio: f64 = 0.0;
    for (accounts) |a| {
        total_ratio += a.ratio;
    }

    var allocated_total: i64 = 0;

    for (accounts, 0..) |entry, i| {
        const ratio = if (total_ratio > 0.0) entry.ratio / total_ratio else 1.0 / @as(f64, @floatFromInt(accounts.len));
        const qty_f = @as(f64, @floatFromInt(trade.quantity)) * ratio;
        const qty = @as(i64, @intFromFloat(@floor(qty_f)));

        result[i] = AllocatedTrade{
            .id = trade.id,
            .instrument = trade.instrument,
            .side = trade.side,
            .quantity = qty,
            .price = trade.price,
            .timestamp_ms = trade.timestamp_ms,
            .account = entry.account,
        };
        allocated_total += qty;
    }

    // Assign remainder to last account to handle rounding errors
    const remainder = trade.quantity - allocated_total;
    if (remainder != 0) {
        result[accounts.len - 1].quantity += remainder;
    }

    return result;
}

/// Compute quantity-weighted average price from a list of fills.
/// Returns 0 if fills is empty.
pub fn averagePrice(fills: []const Fill) i64 {
    if (fills.len == 0) return 0;

    var total_qty: i64 = 0;
    var total_cost: i64 = 0;

    for (fills) |fill| {
        total_qty += fill.quantity;
        total_cost += fill.price * fill.quantity;
    }

    if (total_qty == 0) return 0;
    return @divTrunc(total_cost, total_qty);
}
