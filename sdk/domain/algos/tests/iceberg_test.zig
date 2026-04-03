const std = @import("std");
const iceberg = @import("iceberg");

test "Iceberg display qty matches configured size" {
    const params = iceberg.IcebergParams{
        .total_qty = 1000,
        .display_qty = 100,
        .price = 50000,
        .instrument = "BTC/USD",
        .side = .buy,
        .variance_pct = 0.0,
    };

    var algo = iceberg.IcebergAlgo.init(params);
    const slice = algo.currentSlice();
    try std.testing.expect(slice != null);
    try std.testing.expectEqual(@as(i64, 100), slice.?.quantity);
}

test "Iceberg refills after fill" {
    const params = iceberg.IcebergParams{
        .total_qty = 300,
        .display_qty = 100,
        .price = 50000,
        .instrument = "BTC/USD",
        .side = .buy,
        .variance_pct = 0.0,
    };

    var algo = iceberg.IcebergAlgo.init(params);
    _ = algo.currentSlice();

    // Fill the first slice entirely.
    const next = algo.onFill(.{ .quantity = 100, .price = 50000 });
    try std.testing.expect(next != null);
    try std.testing.expectEqual(@as(i64, 100), next.?.quantity);
}

test "Iceberg no refill on partial fill" {
    const params = iceberg.IcebergParams{
        .total_qty = 300,
        .display_qty = 100,
        .price = 50000,
        .instrument = "BTC/USD",
        .side = .sell,
        .variance_pct = 0.0,
    };

    var algo = iceberg.IcebergAlgo.init(params);
    _ = algo.currentSlice();

    // Partial fill — should not trigger refill.
    const next = algo.onFill(.{ .quantity = 50, .price = 50000 });
    try std.testing.expect(next == null);
}

test "Iceberg total quantity tracked correctly" {
    const params = iceberg.IcebergParams{
        .total_qty = 250,
        .display_qty = 100,
        .price = 50000,
        .instrument = "BTC/USD",
        .side = .buy,
        .variance_pct = 0.0,
    };

    var algo = iceberg.IcebergAlgo.init(params);
    _ = algo.currentSlice();

    // Fill first slice.
    _ = algo.onFill(.{ .quantity = 100, .price = 50000 });
    // Fill second slice.
    _ = algo.onFill(.{ .quantity = 100, .price = 50000 });
    // Third slice: only 50 remain.
    const last = algo.onFill(.{ .quantity = 50, .price = 50000 });
    // 250 - 100 - 100 - 50 = 0 → no more slices.
    try std.testing.expect(last == null);
    try std.testing.expectEqual(@as(i64, 250), algo.filled_qty);
}

test "Iceberg last slice capped at remaining qty" {
    const params = iceberg.IcebergParams{
        .total_qty = 150,
        .display_qty = 100,
        .price = 50000,
        .instrument = "BTC/USD",
        .side = .buy,
        .variance_pct = 0.0,
    };

    var algo = iceberg.IcebergAlgo.init(params);
    _ = algo.currentSlice();

    // Fill first slice.
    const second = algo.onFill(.{ .quantity = 100, .price = 50000 });
    try std.testing.expect(second != null);
    // Second slice should be capped at remaining 50, not full display_qty 100.
    try std.testing.expectEqual(@as(i64, 50), second.?.quantity);
}

test "Iceberg variance within bounds" {
    const params = iceberg.IcebergParams{
        .total_qty = 10000,
        .display_qty = 100,
        .price = 50000,
        .instrument = "BTC/USD",
        .side = .buy,
        .variance_pct = 0.1, // ±10%
    };

    var algo = iceberg.IcebergAlgo.init(params);

    // Fire several slices and check each is within ±10% of display_qty.
    for (0..10) |_| {
        const slice = algo.currentSlice();
        if (slice == null) break;
        const qty = slice.?.quantity;
        try std.testing.expect(qty >= 90 and qty <= 110);
        algo.filled_qty += qty;
        algo.slice_remaining = 0;
    }
}
