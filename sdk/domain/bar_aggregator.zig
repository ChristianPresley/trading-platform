// OHLCV bar aggregation
// Supports time-based, volume-based, and tick-based bars.

const std = @import("std");

pub const Bar = struct {
    open: i64,
    high: i64,
    low: i64,
    close: i64,
    volume: i64,
    timestamp: u128, // bar open timestamp (ns)
};

/// Time-based bar aggregator.
/// Emits a completed Bar when the interval boundary is crossed.
pub const BarAggregator = struct {
    interval_ns: u128,
    bar_start: u128,
    open: i64,
    high: i64,
    low: i64,
    close: i64,
    volume: i64,
    has_data: bool,

    /// interval_ns: bar duration in nanoseconds (e.g. 60_000_000_000 for 1-minute bars).
    pub fn init(interval_ns: u128) BarAggregator {
        return BarAggregator{
            .interval_ns = interval_ns,
            .bar_start = 0,
            .open = 0,
            .high = 0,
            .low = 0,
            .close = 0,
            .volume = 0,
            .has_data = false,
        };
    }

    /// Feed a trade. Returns a completed Bar if the interval boundary was crossed,
    /// otherwise returns null and accumulates the trade into the current bar.
    pub fn onTrade(self: *BarAggregator, price: i64, qty: i64, timestamp: u128) ?Bar {
        if (!self.has_data) {
            // First trade — start bar aligned to interval boundary
            self.bar_start = (timestamp / self.interval_ns) * self.interval_ns;
            self.open = price;
            self.high = price;
            self.low = price;
            self.close = price;
            self.volume = qty;
            self.has_data = true;
            return null;
        }

        // Use latest timestamp — do not rewind for out-of-order timestamps
        const effective_ts = @max(timestamp, self.bar_start);

        if (effective_ts >= self.bar_start + self.interval_ns) {
            // Interval boundary crossed — emit completed bar
            const completed = Bar{
                .open = self.open,
                .high = self.high,
                .low = self.low,
                .close = self.close,
                .volume = self.volume,
                .timestamp = self.bar_start,
            };
            // Start new bar aligned to interval boundary
            self.bar_start = (effective_ts / self.interval_ns) * self.interval_ns;
            self.open = price;
            self.high = price;
            self.low = price;
            self.close = price;
            self.volume = qty;
            return completed;
        }

        // Accumulate into current bar
        if (price > self.high) self.high = price;
        if (price < self.low) self.low = price;
        self.close = price;
        self.volume += qty;
        return null;
    }

    /// Peek at the current in-progress bar without consuming it.
    pub fn peek(self: *const BarAggregator) ?Bar {
        if (!self.has_data) return null;
        return Bar{
            .open = self.open,
            .high = self.high,
            .low = self.low,
            .close = self.close,
            .volume = self.volume,
            .timestamp = self.bar_start,
        };
    }

    /// Flush the current incomplete bar (useful at shutdown).
    /// Returns null if no data has been accumulated.
    pub fn flush(self: *BarAggregator) ?Bar {
        if (!self.has_data) return null;
        const bar = Bar{
            .open = self.open,
            .high = self.high,
            .low = self.low,
            .close = self.close,
            .volume = self.volume,
            .timestamp = self.bar_start,
        };
        self.has_data = false;
        return bar;
    }
};

/// Volume-based bar aggregator.
/// Emits a bar when accumulated volume reaches the threshold.
pub const VolumeBarAggregator = struct {
    threshold: i64,
    open: i64,
    high: i64,
    low: i64,
    close: i64,
    volume: i64,
    bar_start: u128,
    has_data: bool,

    pub fn init(threshold: i64) VolumeBarAggregator {
        return VolumeBarAggregator{
            .threshold = threshold,
            .open = 0,
            .high = 0,
            .low = 0,
            .close = 0,
            .volume = 0,
            .bar_start = 0,
            .has_data = false,
        };
    }

    pub fn onTrade(self: *VolumeBarAggregator, price: i64, qty: i64, timestamp: u128) ?Bar {
        if (!self.has_data) {
            self.bar_start = timestamp;
            self.open = price;
            self.high = price;
            self.low = price;
            self.close = price;
            self.volume = qty;
            self.has_data = true;
        } else {
            if (price > self.high) self.high = price;
            if (price < self.low) self.low = price;
            self.close = price;
            self.volume += qty;
        }

        if (self.volume >= self.threshold) {
            const bar = Bar{
                .open = self.open,
                .high = self.high,
                .low = self.low,
                .close = self.close,
                .volume = self.volume,
                .timestamp = self.bar_start,
            };
            self.has_data = false;
            self.volume = 0;
            return bar;
        }
        return null;
    }
};

/// Volume footprint aggregator.
/// Tracks bid vs ask volume at each price level within a time-based bar.
/// Emits a completed Footprint when the interval boundary is crossed.
pub const FootprintAggregator = struct {
    pub const MAX_LEVELS: usize = 24;

    pub const FootprintLevel = struct {
        price: i64,
        bid_volume: i64,
        ask_volume: i64,
    };

    pub const Footprint = struct {
        levels: [MAX_LEVELS]FootprintLevel,
        level_count: u8,
        delta: i64, // total ask - total bid
        total_volume: i64,
        timestamp: u128,
        tick_size: i64,
    };

    interval_ns: u128,
    tick_size: i64,
    bar_start: u128,
    has_data: bool,

    // Price level buckets — sorted by price descending (highest first)
    prices: [MAX_LEVELS]i64,
    bid_vols: [MAX_LEVELS]i64,
    ask_vols: [MAX_LEVELS]i64,
    count: u8,

    pub fn init(interval_ns: u128, tick_size: i64) FootprintAggregator {
        return FootprintAggregator{
            .interval_ns = interval_ns,
            .tick_size = tick_size,
            .bar_start = 0,
            .has_data = false,
            .prices = std.mem.zeroes([MAX_LEVELS]i64),
            .bid_vols = std.mem.zeroes([MAX_LEVELS]i64),
            .ask_vols = std.mem.zeroes([MAX_LEVELS]i64),
            .count = 0,
        };
    }

    /// Quantize price to the nearest tick_size bucket.
    fn bucket(self: *const FootprintAggregator, price: i64) i64 {
        if (self.tick_size <= 0) return price;
        return @divTrunc(price, self.tick_size) * self.tick_size;
    }

    /// Find or insert a price level bucket. Returns index, or null if full.
    fn findOrInsert(self: *FootprintAggregator, bucketed_price: i64) ?usize {
        // Search existing levels
        for (self.prices[0..self.count], 0..) |p, i| {
            if (p == bucketed_price) return i;
        }
        // Insert new level
        if (self.count < MAX_LEVELS) {
            const idx = self.count;
            self.prices[idx] = bucketed_price;
            self.bid_vols[idx] = 0;
            self.ask_vols[idx] = 0;
            self.count += 1;
            return idx;
        }
        // Full — merge into nearest existing level
        var best_idx: usize = 0;
        var best_dist: u64 = std.math.maxInt(u64);
        for (self.prices[0..self.count], 0..) |p, i| {
            const dist = @abs(p - bucketed_price);
            if (dist < best_dist) {
                best_dist = dist;
                best_idx = i;
            }
        }
        return best_idx;
    }

    /// Reset the current bar state.
    fn reset(self: *FootprintAggregator) void {
        self.count = 0;
        self.has_data = false;
    }

    /// Build a Footprint from current state, sorting levels by price descending.
    fn buildFootprint(self: *const FootprintAggregator) Footprint {
        var fp = Footprint{
            .levels = undefined,
            .level_count = self.count,
            .delta = 0,
            .total_volume = 0,
            .timestamp = self.bar_start,
            .tick_size = self.tick_size,
        };

        // Copy and sort by price descending (highest at index 0)
        var indices: [MAX_LEVELS]u8 = undefined;
        for (0..self.count) |i| indices[i] = @intCast(i);

        // Simple insertion sort (max 24 elements)
        var i: usize = 1;
        while (i < self.count) : (i += 1) {
            var j = i;
            while (j > 0 and self.prices[indices[j]] > self.prices[indices[j - 1]]) {
                const tmp = indices[j];
                indices[j] = indices[j - 1];
                indices[j - 1] = tmp;
                j -= 1;
            }
        }

        for (0..self.count) |k| {
            const si = indices[k];
            fp.levels[k] = FootprintLevel{
                .price = self.prices[si],
                .bid_volume = self.bid_vols[si],
                .ask_volume = self.ask_vols[si],
            };
            fp.delta += self.ask_vols[si] - self.bid_vols[si];
            fp.total_volume += self.bid_vols[si] + self.ask_vols[si];
        }

        return fp;
    }

    /// Feed a trade with side information.
    /// side: 0 = buy (lifts ask), 1 = sell (hits bid)
    /// Returns a completed Footprint if the interval boundary was crossed.
    pub fn onTrade(self: *FootprintAggregator, price: i64, qty: i64, side: u8, timestamp: u128) ?Footprint {
        if (!self.has_data) {
            self.bar_start = (timestamp / self.interval_ns) * self.interval_ns;
            self.has_data = true;
            const bp = self.bucket(price);
            if (self.findOrInsert(bp)) |idx| {
                if (side == 0) {
                    self.ask_vols[idx] += qty;
                } else {
                    self.bid_vols[idx] += qty;
                }
            }
            return null;
        }

        const effective_ts = @max(timestamp, self.bar_start);

        if (effective_ts >= self.bar_start + self.interval_ns) {
            // Emit completed footprint
            const completed = self.buildFootprint();
            // Reset and start new bar aligned to interval boundary
            self.reset();
            self.bar_start = (effective_ts / self.interval_ns) * self.interval_ns;
            self.has_data = true;
            const bp = self.bucket(price);
            if (self.findOrInsert(bp)) |idx| {
                if (side == 0) {
                    self.ask_vols[idx] += qty;
                } else {
                    self.bid_vols[idx] += qty;
                }
            }
            return completed;
        }

        // Accumulate into current bar
        const bp = self.bucket(price);
        if (self.findOrInsert(bp)) |idx| {
            if (side == 0) {
                self.ask_vols[idx] += qty;
            } else {
                self.bid_vols[idx] += qty;
            }
        }
        return null;
    }
};

/// Tick-based bar aggregator.
/// Emits a bar every N trades.
pub const TickBarAggregator = struct {
    tick_count: u64,
    ticks_per_bar: u64,
    open: i64,
    high: i64,
    low: i64,
    close: i64,
    volume: i64,
    bar_start: u128,
    has_data: bool,

    pub fn init(ticks_per_bar: u64) TickBarAggregator {
        return TickBarAggregator{
            .tick_count = 0,
            .ticks_per_bar = ticks_per_bar,
            .open = 0,
            .high = 0,
            .low = 0,
            .close = 0,
            .volume = 0,
            .bar_start = 0,
            .has_data = false,
        };
    }

    pub fn onTrade(self: *TickBarAggregator, price: i64, qty: i64, timestamp: u128) ?Bar {
        if (!self.has_data) {
            self.bar_start = timestamp;
            self.open = price;
            self.high = price;
            self.low = price;
            self.close = price;
            self.volume = qty;
            self.has_data = true;
            self.tick_count = 1;
        } else {
            if (price > self.high) self.high = price;
            if (price < self.low) self.low = price;
            self.close = price;
            self.volume += qty;
            self.tick_count += 1;
        }

        if (self.tick_count >= self.ticks_per_bar) {
            const bar = Bar{
                .open = self.open,
                .high = self.high,
                .low = self.low,
                .close = self.close,
                .volume = self.volume,
                .timestamp = self.bar_start,
            };
            self.has_data = false;
            self.tick_count = 0;
            return bar;
        }
        return null;
    }
};
