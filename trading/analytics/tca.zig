// Transaction Cost Analysis (TCA) engine
// Computes Implementation Shortfall decomposition, VWAP slippage, spread capture, fill rate.

const std = @import("std");

pub const Side = enum { buy, sell };

pub const Execution = struct {
    price: i64,
    quantity: i64,
    timestamp: u128,
    side: Side,
    venue: []const u8,
};

pub const Benchmark = struct {
    arrival_price: i64,
    market_vwap: i64,
    close_price: i64,
    attempted_qty: i64,
};

pub const TcaReport = struct {
    is_cost_bps: f64,
    timing_cost_bps: f64,
    market_impact_bps: f64,
    opportunity_cost_bps: f64,
    vwap_slippage_bps: f64,
    spread_capture: f64,
    fill_rate: f64,
};

pub const TcaEngine = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !TcaEngine {
        return TcaEngine{ .allocator = allocator };
    }

    pub fn deinit(self: *TcaEngine) void {
        _ = self;
    }

    /// Analyze executions against benchmark.
    /// IS decomposition: timing_cost + market_impact + opportunity_cost = is_cost
    /// All costs in basis points (bps = 1/100 of 1%).
    pub fn analyze(self: *TcaEngine, executions: []const Execution, benchmark: Benchmark) !TcaReport {
        _ = self;

        if (executions.len == 0) {
            return TcaReport{
                .is_cost_bps = 0.0,
                .timing_cost_bps = 0.0,
                .market_impact_bps = 0.0,
                .opportunity_cost_bps = 0.0,
                .vwap_slippage_bps = 0.0,
                .spread_capture = 0.0,
                .fill_rate = 0.0,
            };
        }

        // Compute weighted average fill price (use f64 to avoid i64 overflow
        // with large prices * quantities, e.g. BTC at 5e12 * qty 1e12).
        var total_value_f: f64 = 0.0;
        var total_qty_f: f64 = 0.0;
        for (executions) |exec| {
            total_value_f += @as(f64, @floatFromInt(exec.price)) * @as(f64, @floatFromInt(exec.quantity));
            total_qty_f += @as(f64, @floatFromInt(exec.quantity));
        }

        const avg_fill = if (total_qty_f > 0.0) total_value_f / total_qty_f else 0.0;
        const arrival = @as(f64, @floatFromInt(benchmark.arrival_price));
        const market_vwap = @as(f64, @floatFromInt(benchmark.market_vwap));
        const close = @as(f64, @floatFromInt(benchmark.close_price));

        // IS cost = (avg_fill - arrival) / arrival * 10000 bps  [for buy orders]
        // For sell orders, cost is reversed (selling below arrival is a cost)
        const is_side_sign: f64 = if (executions[0].side == .buy) 1.0 else -1.0;
        const is_cost_bps = if (arrival != 0.0)
            is_side_sign * (avg_fill - arrival) / arrival * 10000.0
        else
            0.0;

        // Timing cost: cost from decision point to start of execution
        // Approximated as (first_fill - arrival) / arrival in bps
        // With single execution, timing cost = 0 per spec edge case
        const timing_cost_bps: f64 = if (executions.len <= 1 or arrival == 0.0)
            0.0
        else blk: {
            const first_fill = @as(f64, @floatFromInt(executions[0].price));
            break :blk is_side_sign * (first_fill - arrival) / arrival * 10000.0;
        };

        // Market impact: cost from start of execution to end
        // (avg_fill - first_fill) / arrival in bps
        const market_impact_bps: f64 = if (executions.len <= 1)
            is_cost_bps
        else if (arrival == 0.0)
            0.0
        else blk: {
            const first_fill = @as(f64, @floatFromInt(executions[0].price));
            break :blk is_side_sign * (avg_fill - first_fill) / arrival * 10000.0;
        };

        // Opportunity cost: unfilled portion * (close - arrival) / arrival in bps
        const attempted = @as(f64, @floatFromInt(benchmark.attempted_qty));
        const unfilled_fraction = if (benchmark.attempted_qty > 0)
            (attempted - total_qty_f) / attempted
        else
            0.0;
        const opportunity_cost_bps = if (arrival != 0.0)
            is_side_sign * unfilled_fraction * (close - arrival) / arrival * 10000.0
        else
            0.0;

        // VWAP slippage: (avg_fill - market_vwap) / market_vwap in bps
        const vwap_slippage_bps = if (market_vwap != 0.0)
            is_side_sign * (avg_fill - market_vwap) / market_vwap * 10000.0
        else
            0.0;

        // Spread capture: ratio of spread captured vs crossed
        // 0.0 = full spread paid, 1.0 = full spread captured (passive)
        // Simple proxy: if avg fill <= arrival, we captured spread (passive), else paid spread
        const spread_capture: f64 = if (is_side_sign > 0) blk: {
            // Buy: arrival is at ask, anything below is spread captured
            break :blk if (avg_fill <= arrival) 1.0 else 0.0;
        } else blk: {
            // Sell: arrival is at bid, anything above is spread captured
            break :blk if (avg_fill >= arrival) 1.0 else 0.0;
        };

        // Fill rate: filled / attempted
        const fill_rate: f64 = if (attempted > 0.0)
            total_qty_f / attempted
        else
            1.0;

        return TcaReport{
            .is_cost_bps = is_cost_bps,
            .timing_cost_bps = timing_cost_bps,
            .market_impact_bps = market_impact_bps,
            .opportunity_cost_bps = opportunity_cost_bps,
            .vwap_slippage_bps = vwap_slippage_bps,
            .spread_capture = spread_capture,
            .fill_rate = fill_rate,
        };
    }
};
