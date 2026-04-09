const std = @import("std");
const is = @import("implementation_shortfall");

test "IS init sets arrival price and zeroes fill state" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    const algo = is.IsAlgo.init(params, 50000);
    try std.testing.expectEqual(@as(i64, 50000), algo.arrival_price);
    try std.testing.expectEqual(@as(i64, 0), algo.filled_qty);
    try std.testing.expectEqual(@as(i64, 0), algo.avg_fill_price);
    try std.testing.expectEqual(@as(i64, 1000), algo.params.total_qty);
}

test "IS onMarketData returns child order at base urgency when price unchanged" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);

    // Mid price equals arrival price — no adverse or favorable move.
    // Urgency = base_urgency = 0.1 → qty = 1000 * 0.1 = 100.
    const order = algo.onMarketData(50000, 10, 0.2, 0);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(@as(i64, 100), order.?.quantity);
    try std.testing.expectEqual(is.Side.buy, order.?.side);
    try std.testing.expectEqual(is.OrderType.market, order.?.order_type);
    try std.testing.expect(order.?.price == null);
}

test "IS buy increases urgency on adverse move (price up)" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);

    // Mid price moves up by 50 ticks on arrival of 50000.
    // adverse_bps = 50 * 10000 / 50000 = 10 bps.
    // urgency = 0.1 + 0.01 * 10 = 0.2 → qty = 1000 * 0.2 = 200.
    const order = algo.onMarketData(50050, 10, 0.2, 0);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(@as(i64, 200), order.?.quantity);
}

test "IS buy decreases urgency on favorable move (price down)" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);

    // Mid price moves down by 50 ticks — favorable for buyer.
    // favorable_bps = 50 * 10000 / 50000 = 10 bps.
    // urgency = 0.1 - 0.01 * 10 * 0.5 = 0.1 - 0.05 = 0.05 → qty = 1000 * 0.05 = 50.
    const order = algo.onMarketData(49950, 10, 0.2, 0);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(@as(i64, 50), order.?.quantity);
}

test "IS sell increases urgency on adverse move (price down)" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "ETH/USD",
        .side = .sell,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);

    // Mid price drops by 50 ticks — adverse for seller.
    // adverse_bps = 50 * 10000 / 50000 = 10 bps.
    // urgency = 0.1 + 0.01 * 10 = 0.2 → qty = 1000 * 0.2 = 200.
    const order = algo.onMarketData(49950, 10, 0.2, 0);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(@as(i64, 200), order.?.quantity);
    try std.testing.expectEqual(is.Side.sell, order.?.side);
}

test "IS sell decreases urgency on favorable move (price up)" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "ETH/USD",
        .side = .sell,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);

    // Mid price rises by 50 ticks — favorable for seller.
    // favorable_bps = 50 * 10000 / 50000 = 10 bps.
    // urgency = 0.1 - 0.01 * 10 * 0.5 = 0.05 → qty = 50.
    const order = algo.onMarketData(50050, 10, 0.2, 0);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(@as(i64, 50), order.?.quantity);
}

test "IS urgency clamps to minimum 0.01" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.02,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);

    // Large favorable move: 500 ticks down → favorable_bps = 100 bps.
    // urgency = 0.02 - 0.01 * 100 * 0.5 = 0.02 - 0.5 = -0.48 → clamped to 0.01.
    // qty = 1000 * 0.01 = 10.
    const order = algo.onMarketData(47500, 10, 0.2, 0);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(@as(i64, 10), order.?.quantity);
}

test "IS urgency clamps to maximum 1.0" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.5,
        .urgency_per_bps = 0.1,
    };

    var algo = is.IsAlgo.init(params, 50000);

    // Large adverse move: 500 ticks up → adverse_bps = 100 bps.
    // urgency = 0.5 + 0.1 * 100 = 10.5 → clamped to 1.0.
    // qty = 1000 * 1.0 = 1000.
    const order = algo.onMarketData(50500, 10, 0.2, 0);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(@as(i64, 1000), order.?.quantity);
}

test "IS returns null when fully filled" {
    const params = is.IsParams{
        .total_qty = 100,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);
    algo.onFill(.{ .quantity = 100, .price = 50100 });

    const order = algo.onMarketData(50000, 10, 0.2, 0);
    try std.testing.expect(order == null);
}

test "IS onFill tracks weighted average fill price" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);

    // First fill: 100 @ 50100 → avg = 50100.
    algo.onFill(.{ .quantity = 100, .price = 50100 });
    try std.testing.expectEqual(@as(i64, 100), algo.filled_qty);
    try std.testing.expectEqual(@as(i64, 50100), algo.avg_fill_price);

    // Second fill: 100 @ 50300.
    // avg = (50100 * 100 + 50300 * 100) / 200 = 10040000 / 200 = 50200.
    algo.onFill(.{ .quantity = 100, .price = 50300 });
    try std.testing.expectEqual(@as(i64, 200), algo.filled_qty);
    try std.testing.expectEqual(@as(i64, 50200), algo.avg_fill_price);
}

test "IS onFill ignores zero quantity fill" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);

    algo.onFill(.{ .quantity = 0, .price = 50000 });
    try std.testing.expectEqual(@as(i64, 0), algo.filled_qty);
    try std.testing.expectEqual(@as(i64, 0), algo.avg_fill_price);
}

test "IS onFill ignores negative quantity fill" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);

    algo.onFill(.{ .quantity = -10, .price = 50000 });
    try std.testing.expectEqual(@as(i64, 0), algo.filled_qty);
    try std.testing.expectEqual(@as(i64, 0), algo.avg_fill_price);
}

test "IS shortfall zero when no fills" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    const algo = is.IsAlgo.init(params, 50000);
    try std.testing.expectEqual(@as(f64, 0.0), algo.shortfall());
}

test "IS buy shortfall positive when avg fill above arrival" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);
    algo.onFill(.{ .quantity = 100, .price = 50050 });

    // shortfall = (50050 - 50000) / 50000 * 10000 = 10 bps.
    const sf = algo.shortfall();
    try std.testing.expectApproxEqAbs(@as(f64, 10.0), sf, 0.01);
}

test "IS buy shortfall negative when avg fill below arrival (favorable)" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);
    algo.onFill(.{ .quantity = 100, .price = 49950 });

    // shortfall = (49950 - 50000) / 50000 * 10000 = -10 bps (favorable).
    const sf = algo.shortfall();
    try std.testing.expectApproxEqAbs(@as(f64, -10.0), sf, 0.01);
}

test "IS sell shortfall positive when avg fill below arrival (adverse)" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "ETH/USD",
        .side = .sell,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);
    algo.onFill(.{ .quantity = 100, .price = 49950 });

    // raw_bps = (49950 - 50000) / 50000 * 10000 = -10.
    // For sell: shortfall = -(-10) = 10 bps (adverse).
    const sf = algo.shortfall();
    try std.testing.expectApproxEqAbs(@as(f64, 10.0), sf, 0.01);
}

test "IS sell shortfall negative when avg fill above arrival (favorable)" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "ETH/USD",
        .side = .sell,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);
    algo.onFill(.{ .quantity = 100, .price = 50050 });

    // raw_bps = (50050 - 50000) / 50000 * 10000 = 10.
    // For sell: shortfall = -(10) = -10 bps (favorable).
    const sf = algo.shortfall();
    try std.testing.expectApproxEqAbs(@as(f64, -10.0), sf, 0.01);
}

test "IS shortfall zero when arrival price is zero" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 0);
    algo.onFill(.{ .quantity = 100, .price = 50000 });

    try std.testing.expectEqual(@as(f64, 0.0), algo.shortfall());
}

test "IS quantity never exceeds remaining" {
    const params = is.IsParams{
        .total_qty = 50,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.5,
        .urgency_per_bps = 0.1,
    };

    var algo = is.IsAlgo.init(params, 50000);
    algo.onFill(.{ .quantity = 40, .price = 50000 });

    // Remaining = 10. Even with urgency = 1.0 after clamping, qty <= 10.
    const order = algo.onMarketData(50500, 10, 0.2, 0);
    try std.testing.expect(order != null);
    try std.testing.expect(order.?.quantity <= 10);
    try std.testing.expect(order.?.quantity >= 1);
}

test "IS quantity at least 1 when there is remaining" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.02,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);
    algo.onFill(.{ .quantity = 999, .price = 50000 });

    // Remaining = 1. Urgency floors to 0.01, qty = 1 * 0.01 = 0 → clamped to 1.
    const order = algo.onMarketData(47500, 10, 0.2, 0);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(@as(i64, 1), order.?.quantity);
}

test "IS fill then market data cycle" {
    const params = is.IsParams{
        .total_qty = 500,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.2,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);

    // Round 1: price at arrival.
    const order1 = algo.onMarketData(50000, 10, 0.2, 0);
    try std.testing.expect(order1 != null);
    // urgency = 0.2, qty = 500 * 0.2 = 100.
    try std.testing.expectEqual(@as(i64, 100), order1.?.quantity);

    algo.onFill(.{ .quantity = 100, .price = 50000 });
    try std.testing.expectEqual(@as(i64, 100), algo.filled_qty);

    // Round 2: price moved adversely (up 25 ticks, 5 bps).
    // remaining = 400, urgency = 0.2 + 0.01*5 = 0.25, qty = 400 * 0.25 = 100.
    const order2 = algo.onMarketData(50025, 10, 0.2, 1_000_000_000);
    try std.testing.expect(order2 != null);
    try std.testing.expectEqual(@as(i64, 100), order2.?.quantity);

    algo.onFill(.{ .quantity = 100, .price = 50025 });
    try std.testing.expectEqual(@as(i64, 200), algo.filled_qty);

    // Round 3: price moved favorably (back to arrival).
    // remaining = 300, urgency = 0.2 (no adverse, no favorable since at arrival), qty = 60.
    const order3 = algo.onMarketData(50000, 10, 0.2, 2_000_000_000);
    try std.testing.expect(order3 != null);
    try std.testing.expectEqual(@as(i64, 60), order3.?.quantity);
}

test "IS weighted average fill price across multiple fills" {
    const params = is.IsParams{
        .total_qty = 1000,
        .instrument = "BTC/USD",
        .side = .buy,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 50000);

    algo.onFill(.{ .quantity = 200, .price = 50000 });
    algo.onFill(.{ .quantity = 300, .price = 50500 });

    // avg = (50000*200 + 50500*300) / 500 = (10000000 + 15150000) / 500 = 50300.
    try std.testing.expectEqual(@as(i64, 500), algo.filled_qty);
    try std.testing.expectEqual(@as(i64, 50300), algo.avg_fill_price);

    // Shortfall: (50300 - 50000) / 50000 * 10000 = 60 bps.
    const sf = algo.shortfall();
    try std.testing.expectApproxEqAbs(@as(f64, 60.0), sf, 0.1);
}

test "IS child order carries correct instrument and side" {
    const params = is.IsParams{
        .total_qty = 500,
        .instrument = "SOL/USD",
        .side = .sell,
        .base_urgency = 0.1,
        .urgency_per_bps = 0.01,
    };

    var algo = is.IsAlgo.init(params, 10000);
    const order = algo.onMarketData(10000, 5, 0.1, 0);
    try std.testing.expect(order != null);
    try std.testing.expect(std.mem.eql(u8, "SOL/USD", order.?.instrument));
    try std.testing.expectEqual(is.Side.sell, order.?.side);
}
