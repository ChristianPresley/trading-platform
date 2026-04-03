// VPIN: Volume-Synchronized Probability of Informed Trading
// Classifies trades using tick rule, buckets by volume, computes informed trading probability.

const std = @import("std");

pub const Side = enum { buy, sell };

pub const VpinCalculator = struct {
    bucket_size: i64,
    num_buckets: u32,

    // Ring buffer of (V_buy - V_sell) / bucket_size for completed buckets
    bucket_imbalances: []f64,
    bucket_count: u32,
    bucket_head: u32, // circular buffer head

    // Current bucket accumulation
    current_buy_vol: i64,
    current_sell_vol: i64,
    current_vol: i64,

    // Last price for tick rule
    last_price: i64,

    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, bucket_size: i64, num_buckets: u32) !VpinCalculator {
        const buf = try allocator.alloc(f64, num_buckets);
        @memset(buf, 0.0);
        return VpinCalculator{
            .bucket_size = bucket_size,
            .num_buckets = num_buckets,
            .bucket_imbalances = buf,
            .bucket_count = 0,
            .bucket_head = 0,
            .current_buy_vol = 0,
            .current_sell_vol = 0,
            .current_vol = 0,
            .last_price = 0,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *VpinCalculator) void {
        self.allocator.free(self.bucket_imbalances);
    }

    /// Process an incoming trade.
    /// If the current bucket is complete, returns a VPIN estimate.
    /// `side` overrides tick-rule classification when provided.
    /// Use tick rule if side == null.
    pub fn onTrade(self: *VpinCalculator, price: i64, volume: i64, side: Side) ?f64 {
        // Classify using provided side (tick rule can be applied externally)
        // Tick rule: uptick -> buy, downtick -> sell, same -> use last classification
        const classified_side: Side = if (self.last_price == 0)
            side
        else if (price > self.last_price)
            .buy
        else if (price < self.last_price)
            .sell
        else
            side; // same price: use provided side as tie-breaker

        if (price != 0) self.last_price = price;

        var remaining_vol = volume;

        while (remaining_vol > 0) {
            const space_in_bucket = self.bucket_size - self.current_vol;
            const vol_to_add = if (remaining_vol < space_in_bucket) remaining_vol else space_in_bucket;

            if (classified_side == .buy) {
                self.current_buy_vol += vol_to_add;
            } else {
                self.current_sell_vol += vol_to_add;
            }
            self.current_vol += vol_to_add;
            remaining_vol -= vol_to_add;

            if (self.current_vol >= self.bucket_size) {
                // Bucket complete: compute imbalance
                const total = self.current_buy_vol + self.current_sell_vol;
                const imbalance: f64 = if (total > 0)
                    @as(f64, @floatFromInt(@abs(self.current_buy_vol - self.current_sell_vol))) /
                        @as(f64, @floatFromInt(total))
                else
                    0.0;

                // Store in ring buffer
                const idx = self.bucket_head % self.num_buckets;
                self.bucket_imbalances[idx] = imbalance;
                self.bucket_head = (self.bucket_head + 1) % self.num_buckets;
                if (self.bucket_count < self.num_buckets) {
                    self.bucket_count += 1;
                }

                // Reset current bucket
                self.current_buy_vol = 0;
                self.current_sell_vol = 0;
                self.current_vol = 0;
            }
        }

        // Return VPIN if we have at least one full bucket
        if (self.bucket_count == 0) return null;

        var sum: f64 = 0.0;
        const n = self.bucket_count;
        for (0..n) |i| {
            sum += self.bucket_imbalances[i];
        }
        return sum / @as(f64, @floatFromInt(n));
    }
};
