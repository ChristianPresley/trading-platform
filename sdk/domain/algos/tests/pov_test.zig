const std = @import("std");
const pov = @import("pov");

test "POV targets configured percentage of market volume" {
    const params = pov.PovParams{
        .total_qty = 10000,
        .target_pct = 0.2,
        .max_pct = 0.4,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = pov.PovAlgo.init(params);

    // 1000 units of market volume → target 20% = 200.
    const order = algo.onMarketData(1000, 0);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(@as(i64, 200), order.?.quantity);
}

test "POV caps at max_pct" {
    const params = pov.PovParams{
        .total_qty = 10000,
        .target_pct = 0.5, // 50% target
        .max_pct = 0.3, // 30% max
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = pov.PovAlgo.init(params);

    // 1000 market volume → target 500 but max 300.
    const order = algo.onMarketData(1000, 0);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(@as(i64, 300), order.?.quantity);
}

test "POV does not exceed remaining total quantity" {
    const params = pov.PovParams{
        .total_qty = 50,
        .target_pct = 0.5,
        .max_pct = 1.0,
        .instrument = "BTC/USD",
        .side = .sell,
    };

    var algo = pov.PovAlgo.init(params);

    // 1000 market volume → target 500, but only 50 remain.
    const order = algo.onMarketData(1000, 0);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(@as(i64, 50), order.?.quantity);
}

test "POV returns null when total quantity exhausted" {
    const params = pov.PovParams{
        .total_qty = 100,
        .target_pct = 0.2,
        .max_pct = 0.4,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = pov.PovAlgo.init(params);
    algo.onFill(.{ .quantity = 100, .price = 50000 });

    const order = algo.onMarketData(1000, 0);
    try std.testing.expect(order == null);
}

test "POV returns null for zero market volume" {
    const params = pov.PovParams{
        .total_qty = 1000,
        .target_pct = 0.2,
        .max_pct = 0.4,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = pov.PovAlgo.init(params);
    const order = algo.onMarketData(0, 0);
    try std.testing.expect(order == null);
}

test "POV fill tracking" {
    const params = pov.PovParams{
        .total_qty = 1000,
        .target_pct = 0.2,
        .max_pct = 0.4,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = pov.PovAlgo.init(params);

    // Send first order.
    const order1 = algo.onMarketData(500, 0);
    try std.testing.expect(order1 != null);
    algo.onFill(.{ .quantity = order1.?.quantity, .price = 50000 });

    // Second event: remaining = 1000 - 100 = 900.
    const order2 = algo.onMarketData(500, 1);
    try std.testing.expect(order2 != null);
    // qty = min(500*0.2, 500*0.4, 900) = 100.
    try std.testing.expectEqual(@as(i64, 100), order2.?.quantity);
}
