// Tests for Kraken spot rate limiter

const std = @import("std");
const rate_limiter_mod = @import("spot_rate_limiter");

test "starter tier: max is 15" {
    const rl = rate_limiter_mod.SpotRateLimiter.init(.starter);
    try std.testing.expectEqual(@as(f64, 0), rl.counter);
    try std.testing.expectEqual(@as(f64, 15), rl.max_counter);
}

test "intermediate tier: max is 20" {
    const rl = rate_limiter_mod.SpotRateLimiter.init(.intermediate);
    try std.testing.expectEqual(@as(f64, 20), rl.max_counter);
}

test "pro tier: max is 20 with faster decay" {
    const rl = rate_limiter_mod.SpotRateLimiter.init(.pro);
    try std.testing.expectEqual(@as(f64, 20), rl.max_counter);
    try std.testing.expectEqual(@as(f64, 2.0), rl.decay_rate);
}

test "canCall returns true when counter + cost <= max" {
    var rl = rate_limiter_mod.SpotRateLimiter.init(.intermediate);
    rl.counter = 18.0;
    try std.testing.expect(rl.canCall(2)); // 18+2=20 == max, should be allowed
}

test "canCall returns false when counter + cost > max" {
    var rl = rate_limiter_mod.SpotRateLimiter.init(.intermediate);
    rl.counter = 18.0;
    try std.testing.expect(!rl.canCall(3)); // 18+3=21 > 20
}

test "canCall at exact boundary" {
    var rl = rate_limiter_mod.SpotRateLimiter.init(.starter);
    rl.counter = 14.0;
    try std.testing.expect(rl.canCall(1));  // 14+1=15=max, ok
    try std.testing.expect(!rl.canCall(2)); // 14+2=16>15, fail
}

test "recordCall increments counter" {
    var rl = rate_limiter_mod.SpotRateLimiter.init(.intermediate);
    rl.recordCall(5);
    try std.testing.expectEqual(@as(f64, 5), rl.counter);
    rl.recordCall(3);
    try std.testing.expectEqual(@as(f64, 8), rl.counter);
}

test "recordCall caps at max" {
    var rl = rate_limiter_mod.SpotRateLimiter.init(.intermediate);
    rl.counter = 19.0;
    rl.recordCall(5); // would be 24, caps at 20
    try std.testing.expectEqual(@as(f64, 20), rl.counter);
}

test "decay reduces counter" {
    var rl = rate_limiter_mod.SpotRateLimiter.init(.intermediate); // decay=1.0/s
    rl.counter = 10.0;
    rl.decay(3.0); // 10 - 3 = 7
    try std.testing.expectEqual(@as(f64, 7), rl.counter);
}

test "decay floors at 0" {
    var rl = rate_limiter_mod.SpotRateLimiter.init(.intermediate);
    rl.counter = 2.0;
    rl.decay(10.0); // 2 - 10 = -8, floor to 0
    try std.testing.expectEqual(@as(f64, 0), rl.counter);
}

test "after full decay, canCall succeeds" {
    var rl = rate_limiter_mod.SpotRateLimiter.init(.intermediate);
    rl.counter = 20.0;
    try std.testing.expect(!rl.canCall(1));
    rl.decay(1.0); // decay by 1
    try std.testing.expect(rl.canCall(1)); // now 19, can do 1
}

test "tier-based decay rates differ" {
    var starter = rate_limiter_mod.SpotRateLimiter.init(.starter);
    var pro = rate_limiter_mod.SpotRateLimiter.init(.pro);
    starter.counter = 10.0;
    pro.counter = 10.0;
    starter.decay(1.0);
    pro.decay(1.0);
    // Pro decays at 2/s, starter at 0.33/s
    try std.testing.expect(pro.counter < starter.counter);
}
