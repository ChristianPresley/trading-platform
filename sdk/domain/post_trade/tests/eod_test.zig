const std = @import("std");
const eod = @import("eod");
const recon = @import("reconciliation");

test "position snapshot captures current state" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var processor = try eod.EodProcessor.init(alloc);
    defer processor.deinit();

    const positions = [_]eod.EodPositionView{
        .{ .instrument = "BTC-USD", .quantity = 10, .avg_cost = 50000, .realized_pnl = 5000 },
        .{ .instrument = "ETH-USD", .quantity = 50, .avg_cost = 3000, .realized_pnl = 1000 },
    };

    const snapshots = try processor.snapshotPositions(&positions);
    try std.testing.expectEqual(@as(usize, 2), snapshots.len);
    try std.testing.expectEqualStrings("BTC-USD", snapshots[0].instrument);
    try std.testing.expectEqual(@as(i64, 10), snapshots[0].quantity);
    try std.testing.expectEqual(@as(i64, 50000), snapshots[0].avg_cost);
    try std.testing.expectEqual(@as(i64, 5000), snapshots[0].realized_pnl);
    try std.testing.expectEqualStrings("ETH-USD", snapshots[1].instrument);
}

test "daily P&L sums correctly" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var processor = try eod.EodProcessor.init(alloc);
    defer processor.deinit();

    const positions = [_]eod.EodPositionView{
        // Long 10 BTC at avg cost 50000, realized_pnl = 5000
        .{ .instrument = "BTC-USD", .quantity = 10, .avg_cost = 50000, .realized_pnl = 5000 },
        // Short 20 ETH at avg cost 3000, realized_pnl = 0
        .{ .instrument = "ETH-USD", .quantity = -20, .avg_cost = 3000, .realized_pnl = 0 },
    };

    const marks = [_]eod.Mark{
        .{ .instrument = "BTC-USD", .price = 51000 }, // unrealized: (51000-50000)*10 = 10000
        .{ .instrument = "ETH-USD", .price = 2900 },  // unrealized short: (3000-2900)*20 = 2000
    };

    const report = try processor.computeDailyPnl(&positions, &marks);

    try std.testing.expectEqual(@as(i64, 5000), report.realized_pnl);
    try std.testing.expectEqual(@as(i64, 12000), report.unrealized_pnl); // 10000 + 2000
    try std.testing.expectEqual(@as(i64, 17000), report.total_pnl);
    try std.testing.expectEqual(@as(usize, 2), report.snapshots.len);
}

test "EOD workflow runs all steps" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var processor = try eod.EodProcessor.init(alloc);
    defer processor.deinit();

    var engine = try recon.ReconEngine.init(alloc, .{
        .price_tolerance = 0.001,
        .qty_tolerance = 0,
        .time_window_ms = 5000,
    });
    defer engine.deinit();

    const positions = [_]eod.EodPositionView{
        .{ .instrument = "BTC-USD", .quantity = 5, .avg_cost = 50000, .realized_pnl = 1000 },
    };

    const marks = [_]eod.Mark{
        .{ .instrument = "BTC-USD", .price = 52000 },
    };

    const trade = recon.Trade{
        .id = "EOD001",
        .instrument = "BTC-USD",
        .side = .buy,
        .quantity = 5,
        .price = 50000,
        .timestamp_ms = 1000,
    };
    const internal_trades = [_]recon.Trade{trade};
    const external_trades = [_]recon.Trade{trade};

    const report = try processor.runEndOfDay(&positions, &engine, &marks, &internal_trades, &external_trades);
    defer alloc.free(report.recon_result.breaks);

    // Check P&L: realized=1000, unrealized=(52000-50000)*5=10000, total=11000
    try std.testing.expectEqual(@as(i64, 1000), report.pnl.realized_pnl);
    try std.testing.expectEqual(@as(i64, 10000), report.pnl.unrealized_pnl);
    try std.testing.expectEqual(@as(i64, 11000), report.pnl.total_pnl);
    // Recon: 1 matched, 0 breaks
    try std.testing.expectEqual(@as(u32, 1), report.recon_result.matched);
    try std.testing.expectEqual(@as(usize, 0), report.recon_result.breaks.len);
    // Snapshots captured
    try std.testing.expectEqual(@as(usize, 1), report.snapshots.len);
}
