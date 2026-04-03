const std = @import("std");
const twap = @import("twap");

test "TWAP divides total quantity evenly across slices" {
    const params = twap.TwapParams{
        .total_qty = 1000,
        .start_time = 0,
        .end_time = 10_000_000_000, // 10 seconds in ns
        .num_slices = 10,
        .instrument = "BTC/USD",
        .side = .buy,
        .jitter_pct = 0.0,
    };

    const algo = twap.TwapAlgo.init(params);

    // Sum of all slice quantities should equal total_qty.
    var total: i64 = 0;
    for (0..10) |i| {
        total += algo.slice_qtys[i];
    }
    try std.testing.expectEqual(@as(i64, 1000), total);
}

test "TWAP each slice has expected base quantity" {
    const params = twap.TwapParams{
        .total_qty = 100,
        .start_time = 0,
        .end_time = 10_000_000_000,
        .num_slices = 10,
        .instrument = "ETH/USD",
        .side = .sell,
        .jitter_pct = 0.0,
    };

    const algo = twap.TwapAlgo.init(params);
    // Base slice qty: 100 / 10 = 10 each, last gets remainder (also 10).
    for (0..9) |i| {
        try std.testing.expectEqual(@as(i64, 10), algo.slice_qtys[i]);
    }
    try std.testing.expectEqual(@as(i64, 10), algo.slice_qtys[9]);
}

test "TWAP remainder goes to last slice" {
    const params = twap.TwapParams{
        .total_qty = 103,
        .start_time = 0,
        .end_time = 10_000_000_000,
        .num_slices = 10,
        .instrument = "BTC/USD",
        .side = .buy,
        .jitter_pct = 0.0,
    };

    const algo = twap.TwapAlgo.init(params);
    // Base: 103/10 = 10, remainder = 3 → last slice = 13.
    for (0..9) |i| {
        try std.testing.expectEqual(@as(i64, 10), algo.slice_qtys[i]);
    }
    try std.testing.expectEqual(@as(i64, 13), algo.slice_qtys[9]);
}

test "TWAP nextSlice returns order when time reached" {
    const params = twap.TwapParams{
        .total_qty = 200,
        .start_time = 0,
        .end_time = 2_000_000_000, // 2 seconds
        .num_slices = 2,
        .instrument = "BTC/USD",
        .side = .buy,
        .jitter_pct = 0.0,
    };

    var algo = twap.TwapAlgo.init(params);

    // Before any slice time — should return null.
    const no_order = algo.nextSlice(0);
    try std.testing.expect(no_order == null);

    // At or past first slice time.
    const order1 = algo.nextSlice(algo.slice_times[0] + 1);
    try std.testing.expect(order1 != null);
    try std.testing.expectEqual(@as(i64, 100), order1.?.quantity);

    // Second slice.
    const order2 = algo.nextSlice(algo.slice_times[1] + 1);
    try std.testing.expect(order2 != null);
    try std.testing.expectEqual(@as(i64, 100), order2.?.quantity);

    // No more slices.
    const no_more = algo.nextSlice(algo.slice_times[1] + 2);
    try std.testing.expect(no_more == null);
}

test "TWAP fill tracking reduces remaining quantity" {
    const params = twap.TwapParams{
        .total_qty = 500,
        .start_time = 0,
        .end_time = 5_000_000_000,
        .num_slices = 5,
        .instrument = "BTC/USD",
        .side = .buy,
        .jitter_pct = 0.0,
    };

    var algo = twap.TwapAlgo.init(params);
    try std.testing.expectEqual(@as(i64, 500), algo.remainingQty());

    algo.onFill(.{ .quantity = 100, .price = 50000 });
    try std.testing.expectEqual(@as(i64, 400), algo.remainingQty());

    algo.onFill(.{ .quantity = 200, .price = 50100 });
    try std.testing.expectEqual(@as(i64, 200), algo.remainingQty());
}

test "TWAP isComplete when all quantity filled" {
    const params = twap.TwapParams{
        .total_qty = 100,
        .start_time = 0,
        .end_time = 1_000_000_000,
        .num_slices = 2,
        .instrument = "BTC/USD",
        .side = .buy,
        .jitter_pct = 0.0,
    };

    var algo = twap.TwapAlgo.init(params);
    try std.testing.expect(!algo.isComplete());

    algo.onFill(.{ .quantity = 100, .price = 50000 });
    try std.testing.expect(algo.isComplete());
}

test "TWAP isComplete when all slices exhausted" {
    const params = twap.TwapParams{
        .total_qty = 100,
        .start_time = 0,
        .end_time = 1_000_000_000,
        .num_slices = 2,
        .instrument = "BTC/USD",
        .side = .buy,
        .jitter_pct = 0.0,
    };

    var algo = twap.TwapAlgo.init(params);

    // Fire both slices.
    _ = algo.nextSlice(algo.slice_times[0] + 1);
    _ = algo.nextSlice(algo.slice_times[1] + 1);

    try std.testing.expect(algo.isComplete());
}

test "TWAP jitter applies ±jitter to slice times" {
    const params = twap.TwapParams{
        .total_qty = 100,
        .start_time = 0,
        .end_time = 1_000_000_000,
        .num_slices = 4,
        .instrument = "BTC/USD",
        .side = .buy,
        .jitter_pct = 0.2,
    };

    const algo = twap.TwapAlgo.init(params);
    const duration: u128 = 1_000_000_000;
    const interval: u128 = duration / 4;
    const max_jitter: u128 = @intFromFloat(@as(f64, @floatFromInt(interval)) * 0.1);

    // Verify slice times are within expected jitter bounds.
    for (0..4) |i| {
        const base: u128 = interval * i + interval / 2;
        const t = algo.slice_times[i];
        // Allow ±max_jitter window.
        const low = if (base >= max_jitter) base - max_jitter else 0;
        const high = base + max_jitter;
        try std.testing.expect(t >= low and t <= high);
    }
}
