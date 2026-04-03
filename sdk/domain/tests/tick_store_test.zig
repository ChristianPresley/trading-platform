const std = @import("std");
const tick_store = @import("tick_store");

test "write and read round-trip" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const alloc = std.testing.allocator;
    var path_buf: [512]u8 = undefined;
    const base_path = try tmp.dir.realpath(".", &path_buf);

    var store = try tick_store.TickStore.init(alloc, base_path);
    defer store.deinit();

    // Use a fixed timestamp: 2024-01-15 00:00:01.000000000 UTC
    // 2024-01-15 = 19737 days since epoch
    // seconds: 19737 * 86400 + 1 = 1705276801
    const ts_ns: u128 = 1705276801 * 1_000_000_000;

    const tick = tick_store.Tick{
        .timestamp = ts_ns,
        .price = 50000,
        .quantity = 100,
        .side = .buy,
    };

    try store.write("BTC-USD", tick);
    try store.flush();

    var iter = try store.query("BTC-USD", ts_ns, ts_ns + 1_000_000_000);
    defer iter.deinit();

    const read_tick = iter.next();
    try std.testing.expect(read_tick != null);
    try std.testing.expectEqual(ts_ns, read_tick.?.timestamp);
    try std.testing.expectEqual(@as(i64, 50000), read_tick.?.price);
    try std.testing.expectEqual(@as(i64, 100), read_tick.?.quantity);
    try std.testing.expectEqual(tick_store.Side.buy, read_tick.?.side);
}

test "time-range query returns correct subset" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const alloc = std.testing.allocator;
    var path_buf: [512]u8 = undefined;
    const base_path = try tmp.dir.realpath(".", &path_buf);

    var store = try tick_store.TickStore.init(alloc, base_path);
    defer store.deinit();

    // Base time: 2024-02-01 00:00:00 UTC
    // 2024-02-01 = epoch + 19754 days
    // seconds: 19754 * 86400 = 1706745600
    const base_ns: u128 = 1706745600 * 1_000_000_000;

    // Write 5 ticks at 1-second intervals
    var i: u32 = 0;
    while (i < 5) : (i += 1) {
        const ts = base_ns + @as(u128, i) * 1_000_000_000;
        try store.write("ETH-USD", .{
            .timestamp = ts,
            .price = 3000 + @as(i64, @intCast(i)) * 10,
            .quantity = @as(i64, @intCast(i + 1)) * 5,
            .side = if (i % 2 == 0) .buy else .sell,
        });
    }
    try store.flush();

    // Query only ticks 1, 2, 3 (skip tick 0 and tick 4)
    const from = base_ns + 1_000_000_000;
    const to = base_ns + 3_000_000_000;

    var iter = try store.query("ETH-USD", from, to);
    defer iter.deinit();

    var count: u32 = 0;
    while (iter.next()) |_| {
        count += 1;
    }
    try std.testing.expectEqual(@as(u32, 3), count);
}

test "empty range returns no results" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const alloc = std.testing.allocator;
    var path_buf: [512]u8 = undefined;
    const base_path = try tmp.dir.realpath(".", &path_buf);

    var store = try tick_store.TickStore.init(alloc, base_path);
    defer store.deinit();

    // Query for an instrument that was never written
    const ts_ns: u128 = 1705276801 * 1_000_000_000;
    var iter = try store.query("NEVER-WRITTEN", ts_ns, ts_ns + 1_000_000_000);
    defer iter.deinit();

    const tick = iter.next();
    try std.testing.expectEqual(@as(?tick_store.Tick, null), tick);
}

test "delta encoding preserves precision" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const alloc = std.testing.allocator;
    var path_buf: [512]u8 = undefined;
    const base_path = try tmp.dir.realpath(".", &path_buf);

    var store = try tick_store.TickStore.init(alloc, base_path);
    defer store.deinit();

    // Use nanosecond-precise timestamps
    // 2024-03-01 00:00:00 UTC
    // 19783 days since epoch, seconds = 19783 * 86400 = 1709251200
    const base_ns: u128 = 1709251200 * 1_000_000_000;

    const ticks = [_]tick_store.Tick{
        .{ .timestamp = base_ns + 123_456_789, .price = 99999, .quantity = 1, .side = .buy },
        .{ .timestamp = base_ns + 987_654_321, .price = 100001, .quantity = 2, .side = .sell },
        .{ .timestamp = base_ns + 1_000_000_001, .price = 99998, .quantity = 3, .side = .buy },
    };

    for (ticks) |t| {
        try store.write("PRECISE", t);
    }
    try store.flush();

    var iter = try store.query("PRECISE", base_ns, base_ns + 2_000_000_000);
    defer iter.deinit();

    var idx: usize = 0;
    while (iter.next()) |t| {
        try std.testing.expectEqual(ticks[idx].timestamp, t.timestamp);
        try std.testing.expectEqual(ticks[idx].price, t.price);
        try std.testing.expectEqual(ticks[idx].quantity, t.quantity);
        try std.testing.expectEqual(ticks[idx].side, t.side);
        idx += 1;
    }
    try std.testing.expectEqual(@as(usize, 3), idx);
}

test "multiple ticks same partition" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const alloc = std.testing.allocator;
    var path_buf: [512]u8 = undefined;
    const base_path = try tmp.dir.realpath(".", &path_buf);

    var store = try tick_store.TickStore.init(alloc, base_path);
    defer store.deinit();

    // 2024-04-01 00:00:00 UTC
    // 19814 days * 86400 = 1711929600 seconds
    const base_ns: u128 = 1711929600 * 1_000_000_000;

    var j: u32 = 0;
    while (j < 10) : (j += 1) {
        try store.write("SOL-USD", .{
            .timestamp = base_ns + @as(u128, j) * 500_000_000,
            .price = 150 + @as(i64, @intCast(j)),
            .quantity = 10,
            .side = .buy,
        });
    }
    try store.flush();

    var iter = try store.query("SOL-USD", base_ns, base_ns + 10_000_000_000);
    defer iter.deinit();

    var count: u32 = 0;
    while (iter.next()) |_| {
        count += 1;
    }
    try std.testing.expectEqual(@as(u32, 10), count);
}
