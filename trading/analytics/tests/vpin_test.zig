// VPIN calculator tests
const std = @import("std");
const vpin_mod = @import("vpin");
const VpinCalculator = vpin_mod.VpinCalculator;
const Side = vpin_mod.Side;

test "all buys -> VPIN = 1.0" {
    // bucket_size = 100, num_buckets = 3
    var calc = try VpinCalculator.init(std.testing.allocator, 100, 3);
    defer calc.deinit();

    // Feed 3 full buckets of all-buy volume
    var result: ?f64 = null;
    var i: u32 = 0;
    while (i < 3) : (i += 1) {
        result = calc.onTrade(10000 + @as(i64, @intCast(i)), 100, .buy);
    }

    try std.testing.expect(result != null);
    try std.testing.expectApproxEqAbs(1.0, result.?, 0.001);
}

test "balanced buys and sells -> VPIN = 0.0" {
    var calc = try VpinCalculator.init(std.testing.allocator, 100, 3);
    defer calc.deinit();

    // Feed 3 full buckets of 50 buy + 50 sell each
    var result: ?f64 = null;
    var i: u32 = 0;
    while (i < 3) : (i += 1) {
        _ = calc.onTrade(10000, 50, .buy);
        result = calc.onTrade(9999, 50, .sell);
    }

    try std.testing.expect(result != null);
    try std.testing.expectApproxEqAbs(0.0, result.?, 0.001);
}

test "bucket rollover triggers recalculation" {
    var calc = try VpinCalculator.init(std.testing.allocator, 100, 2);
    defer calc.deinit();

    // Fill bucket 1: all buys
    const r1 = calc.onTrade(10000, 100, .buy);
    try std.testing.expect(r1 != null);
    try std.testing.expectApproxEqAbs(1.0, r1.?, 0.001);

    // Fill bucket 2: all sells
    const r2 = calc.onTrade(9990, 100, .sell);
    try std.testing.expect(r2 != null);
    // Average over 2 buckets: (1.0 + 1.0) / 2 = 1.0 (both have |V_b - V_s| = bucket_size)
    try std.testing.expectApproxEqAbs(1.0, r2.?, 0.001);

    // Fill bucket 3: all buys (overwrites bucket 1 in ring buffer)
    const r3 = calc.onTrade(10010, 100, .buy);
    try std.testing.expect(r3 != null);
    // Still average of 2 buckets: bucket2 (all sells = 1.0) + bucket3 (all buys = 1.0) = 1.0
    try std.testing.expectApproxEqAbs(1.0, r3.?, 0.001);
}

test "returns null when no bucket completed yet" {
    var calc = try VpinCalculator.init(std.testing.allocator, 1000, 3);
    defer calc.deinit();

    // Only 50 out of 1000 volume: no bucket complete
    const result = calc.onTrade(10000, 50, .buy);
    try std.testing.expect(result == null);
}

test "equal buy sell volume in one bucket -> VPIN = 0.0" {
    var calc = try VpinCalculator.init(std.testing.allocator, 200, 1);
    defer calc.deinit();

    _ = calc.onTrade(10000, 100, .buy);
    const result = calc.onTrade(9990, 100, .sell);

    try std.testing.expect(result != null);
    try std.testing.expectApproxEqAbs(0.0, result.?, 0.001);
}
