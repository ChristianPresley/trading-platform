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
            // First trade — start bar
            self.bar_start = timestamp;
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
            // Start new bar
            self.bar_start = effective_ts;
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
