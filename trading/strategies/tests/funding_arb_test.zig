// Funding rate arbitrage strategy tests
const std = @import("std");
const funding_mod = @import("funding_arb");
const FundingArbStrategy = funding_mod.FundingArbStrategy;
const FundingArbConfig = funding_mod.FundingArbConfig;
const FundingDirection = funding_mod.FundingDirection;

fn makeConfig() FundingArbConfig {
    return FundingArbConfig{
        .min_rate_bps = 5.0, // 0.05% minimum funding rate
        .max_position = 1000,
        .instrument_spot = "BTC/USD",
        .instrument_perp = "BTC/USD-PERP",
    };
}

test "positive funding rate -> long spot / short perp signal" {
    var strategy = try FundingArbStrategy.init(std.testing.allocator, makeConfig());
    defer strategy.deinit();

    // 0.1% funding rate = 10 bps > 5 bps threshold
    const signal = strategy.onFundingRate(0.001, 1_000_000_000);
    try std.testing.expect(signal != null);
    try std.testing.expectEqual(FundingDirection.long_spot_short_perp, signal.?.direction);
    try std.testing.expectEqual(@as(i64, 1000), signal.?.spot_qty);
    try std.testing.expectEqual(@as(i64, 1000), signal.?.perp_qty);
}

test "negative funding rate -> short spot / long perp signal" {
    var strategy = try FundingArbStrategy.init(std.testing.allocator, makeConfig());
    defer strategy.deinit();

    // -0.1% funding rate = -10 bps < -5 bps threshold
    const signal = strategy.onFundingRate(-0.001, 1_000_000_000);
    try std.testing.expect(signal != null);
    try std.testing.expectEqual(FundingDirection.short_spot_long_perp, signal.?.direction);
}

test "no signal when rate below threshold" {
    var strategy = try FundingArbStrategy.init(std.testing.allocator, makeConfig());
    defer strategy.deinit();

    // 0.0003 = 3 bps < 5 bps threshold
    const signal = strategy.onFundingRate(0.00003, 1_000_000_000);
    try std.testing.expect(signal == null);
}

test "funding rate flips sign while positioned -> exit signal" {
    var strategy = try FundingArbStrategy.init(std.testing.allocator, makeConfig());
    defer strategy.deinit();

    // Enter with positive funding
    const entry = strategy.onFundingRate(0.001, 1_000_000_000);
    try std.testing.expect(entry != null);
    try std.testing.expectEqual(FundingDirection.long_spot_short_perp, entry.?.direction);

    // Funding flips negative -> exit
    const exit_signal = strategy.onFundingRate(-0.0001, 2_000_000_000);
    try std.testing.expect(exit_signal != null);
    try std.testing.expectEqual(FundingDirection.flat, exit_signal.?.direction);
}

test "no signal when already positioned and rate stays positive" {
    var strategy = try FundingArbStrategy.init(std.testing.allocator, makeConfig());
    defer strategy.deinit();

    // Enter
    _ = strategy.onFundingRate(0.001, 1_000_000_000);

    // Same direction update, still positive
    const signal = strategy.onFundingRate(0.002, 2_000_000_000);
    try std.testing.expect(signal == null);
}
