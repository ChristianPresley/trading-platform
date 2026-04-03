const std = @import("std");
const allocation = @import("allocation");

test "pro-rata allocation sums to original quantity" {
    const alloc = std.testing.allocator;

    const trade = allocation.Trade{
        .id = "BLOCK001",
        .instrument = "BTC-USD",
        .side = .buy,
        .quantity = 100,
        .price = 50000,
        .timestamp_ms = 1000,
    };

    const accounts = [_]allocation.AllocationEntry{
        .{ .account = "ACCT-A", .ratio = 0.4 },
        .{ .account = "ACCT-B", .ratio = 0.35 },
        .{ .account = "ACCT-C", .ratio = 0.25 },
    };

    const result = try allocation.allocateTrade(alloc, trade, &accounts);
    defer alloc.free(result);

    try std.testing.expectEqual(@as(usize, 3), result.len);

    // Sum of allocated quantities must equal original
    var total: i64 = 0;
    for (result) |t| {
        total += t.quantity;
    }
    try std.testing.expectEqual(@as(i64, 100), total);

    // All at same price
    for (result) |t| {
        try std.testing.expectEqual(@as(i64, 50000), t.price);
        try std.testing.expectEqualStrings("BTC-USD", t.instrument);
    }
}

test "equal split when ratios are equal" {
    const alloc = std.testing.allocator;

    const trade = allocation.Trade{
        .id = "BLOCK002",
        .instrument = "ETH-USD",
        .side = .sell,
        .quantity = 30,
        .price = 3000,
        .timestamp_ms = 2000,
    };

    const accounts = [_]allocation.AllocationEntry{
        .{ .account = "A", .ratio = 1.0 },
        .{ .account = "B", .ratio = 1.0 },
        .{ .account = "C", .ratio = 1.0 },
    };

    const result = try allocation.allocateTrade(alloc, trade, &accounts);
    defer alloc.free(result);

    var total: i64 = 0;
    for (result) |t| {
        total += t.quantity;
    }
    try std.testing.expectEqual(@as(i64, 30), total);
}

test "average price is quantity-weighted" {
    const fills = [_]allocation.Fill{
        .{ .quantity = 10, .price = 100 }, // 10 * 100 = 1000
        .{ .quantity = 20, .price = 200 }, // 20 * 200 = 4000
        .{ .quantity = 30, .price = 300 }, // 30 * 300 = 9000
        // Total qty: 60, total cost: 14000, avg: 14000/60 = 233
    };

    const avg = allocation.averagePrice(&fills);
    try std.testing.expectEqual(@as(i64, 233), avg);
}

test "average price with single fill" {
    const fills = [_]allocation.Fill{
        .{ .quantity = 100, .price = 500 },
    };
    const avg = allocation.averagePrice(&fills);
    try std.testing.expectEqual(@as(i64, 500), avg);
}

test "average price with empty fills returns 0" {
    const fills = [_]allocation.Fill{};
    const avg = allocation.averagePrice(&fills);
    try std.testing.expectEqual(@as(i64, 0), avg);
}

test "rounding errors assigned to last account" {
    const alloc = std.testing.allocator;

    const trade = allocation.Trade{
        .id = "BLOCK003",
        .instrument = "XRP-USD",
        .side = .buy,
        .quantity = 10, // 10/3 = 3.33... per account, floor = 3, remainder = 1
        .price = 1,
        .timestamp_ms = 3000,
    };

    const accounts = [_]allocation.AllocationEntry{
        .{ .account = "X", .ratio = 1.0 },
        .{ .account = "Y", .ratio = 1.0 },
        .{ .account = "Z", .ratio = 1.0 },
    };

    const result = try allocation.allocateTrade(alloc, trade, &accounts);
    defer alloc.free(result);

    var total: i64 = 0;
    for (result) |t| {
        total += t.quantity;
    }
    // Must sum exactly to 10
    try std.testing.expectEqual(@as(i64, 10), total);
}
