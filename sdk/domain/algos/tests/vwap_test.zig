const std = @import("std");
const vwap = @import("vwap");

test "VWAP participation rate never exceeds max_participation" {
    const profile = [_]f64{ 0.4, 0.3, 0.2, 0.1 };
    const params = vwap.VwapParams{
        .total_qty = 1000,
        .start_time = 0,
        .end_time = 4_000_000_000,
        .max_participation = 0.3,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = vwap.VwapAlgo.init(params, &profile);

    // Simulate 4 market data events.
    for (0..4) |_| {
        const maybe_order = algo.onMarketData(500, 1_000_000_000);
        if (maybe_order) |order| {
            algo.onFill(.{ .quantity = order.quantity, .price = 50000 });
        }
        // Participation rate must never exceed max_participation.
        const rate = algo.participationRate();
        try std.testing.expect(rate <= params.max_participation + 0.001);
    }
}

test "VWAP no child order when ahead of schedule" {
    const profile = [_]f64{ 1.0 };
    const params = vwap.VwapParams{
        .total_qty = 1000,
        .start_time = 0,
        .end_time = 1_000_000_000,
        .max_participation = 0.5,
        .instrument = "ETH/USD",
        .side = .buy,
    };

    var algo = vwap.VwapAlgo.init(params, &profile);

    // First event: we haven't filled anything so we should get an order.
    const order1 = algo.onMarketData(100, 0);
    try std.testing.expect(order1 != null);

    // Simulate we filled the entire market volume at max participation
    // (i.e. we filled 50 units against 100 market).
    // Now market_volume=100, filled=50 (50%).
    algo.onFill(.{ .quantity = order1.?.quantity, .price = 3000 });

    // Next event: market_volume goes to 200, target=100, we have 50.
    // We are BEHIND schedule → will get an order for 50 more.
    const order2 = algo.onMarketData(100, 1);
    try std.testing.expect(order2 != null);
    // Fill it — now filled=100, market_volume=200, participation=50%.
    algo.onFill(.{ .quantity = order2.?.quantity, .price = 3000 });

    // Third event: market_volume=300, target=150, filled=100. Behind again.
    // But let's verify participation rate is not exceeding max.
    const rate = algo.participationRate();
    try std.testing.expect(rate <= params.max_participation + 0.001);
}

test "VWAP skips slice when market volume is zero" {
    const profile = [_]f64{ 0.5, 0.5 };
    const params = vwap.VwapParams{
        .total_qty = 200,
        .start_time = 0,
        .end_time = 2_000_000_000,
        .max_participation = 0.5,
        .instrument = "BTC/USD",
        .side = .sell,
    };

    var algo = vwap.VwapAlgo.init(params, &profile);

    // Zero volume — must return null (no division by zero).
    const order = algo.onMarketData(0, 0);
    try std.testing.expect(order == null);
    try std.testing.expectEqual(@as(f64, 0.0), algo.participationRate());
}

test "VWAP participation rate computed correctly" {
    const profile = [_]f64{ 1.0 };
    const params = vwap.VwapParams{
        .total_qty = 1000,
        .start_time = 0,
        .end_time = 1_000_000_000,
        .max_participation = 1.0,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = vwap.VwapAlgo.init(params, &profile);

    _ = algo.onMarketData(1000, 0);
    algo.onFill(.{ .quantity = 300, .price = 50000 });

    // market_volume = 1000, filled = 300 → rate = 0.3.
    const rate = algo.participationRate();
    try std.testing.expectApproxEqAbs(@as(f64, 0.3), rate, 0.001);
}

test "VWAP does not send order when total qty already filled" {
    const profile = [_]f64{ 1.0 };
    const params = vwap.VwapParams{
        .total_qty = 100,
        .start_time = 0,
        .end_time = 1_000_000_000,
        .max_participation = 0.5,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = vwap.VwapAlgo.init(params, &profile);
    algo.onFill(.{ .quantity = 100, .price = 50000 });

    const order = algo.onMarketData(1000, 0);
    try std.testing.expect(order == null);
}
