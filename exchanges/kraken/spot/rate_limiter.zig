// Kraken spot rate limiter — call counter with tier-based decay.
// Kraken uses a counter system where each API call has a cost, the counter
// decays at a per-tier rate, and calls are rejected when counter + cost > max.

const std = @import("std");

pub const Tier = enum {
    starter,
    intermediate,
    pro,
};

pub const SpotRateLimiter = struct {
    counter: f64,
    max_counter: f64,
    decay_rate: f64, // units per second

    pub fn init(tier: Tier) SpotRateLimiter {
        return switch (tier) {
            .starter => SpotRateLimiter{
                .counter = 0,
                .max_counter = 15,
                .decay_rate = 0.33, // 1 unit per ~3 seconds
            },
            .intermediate => SpotRateLimiter{
                .counter = 0,
                .max_counter = 20,
                .decay_rate = 1.0, // 1 unit per second
            },
            .pro => SpotRateLimiter{
                .counter = 0,
                .max_counter = 20,
                .decay_rate = 2.0, // 2 units per second
            },
        };
    }

    /// Returns true if a call with the given cost can be made without exceeding max.
    pub fn canCall(self: *SpotRateLimiter, cost: u8) bool {
        return self.counter + @as(f64, @floatFromInt(cost)) <= self.max_counter;
    }

    /// Increment counter by cost.
    pub fn recordCall(self: *SpotRateLimiter, cost: u8) void {
        self.counter += @floatFromInt(cost);
        if (self.counter > self.max_counter) {
            self.counter = self.max_counter;
        }
    }

    /// Decay counter by decay_rate * elapsed_seconds, floored at 0.
    pub fn decay(self: *SpotRateLimiter, elapsed_seconds: f64) void {
        const reduction = self.decay_rate * elapsed_seconds;
        self.counter -= reduction;
        if (self.counter < 0) self.counter = 0;
    }
};
