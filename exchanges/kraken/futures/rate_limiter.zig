// Kraken futures rate limiter — cost-unit based.
// Futures API uses a simple cost-unit counter with no decay (token bucket style).

const std = @import("std");

pub const FuturesRateLimiter = struct {
    counter: u32,
    max_counter: u32,

    pub fn init() FuturesRateLimiter {
        return FuturesRateLimiter{
            .counter = 0,
            .max_counter = 500, // Kraken futures allows 500 cost-units per 10 minutes
        };
    }

    /// Returns true if a call with the given cost can be made without exceeding max.
    pub fn canCall(self: *FuturesRateLimiter, cost: u8) bool {
        return @as(u32, self.counter) + @as(u32, cost) <= self.max_counter;
    }

    /// Increment counter by cost.
    pub fn recordCall(self: *FuturesRateLimiter, cost: u8) void {
        const new_val = self.counter + @as(u32, cost);
        self.counter = @min(new_val, self.max_counter);
    }

    /// Reset counter (called periodically, e.g., every 10 minutes).
    pub fn reset(self: *FuturesRateLimiter) void {
        self.counter = 0;
    }
};
