const std = @import("std");
const recon = @import("reconciliation");

test "perfect match returns zero breaks" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var engine = try recon.ReconEngine.init(alloc, .{
        .price_tolerance = 0.0001,
        .qty_tolerance = 0,
        .time_window_ms = 1000,
    });
    defer engine.deinit();

    const trade = recon.Trade{
        .id = "T001",
        .instrument = "BTC-USD",
        .side = .buy,
        .quantity = 100,
        .price = 50000,
        .timestamp_ms = 1000,
    };

    const internal = [_]recon.Trade{trade};
    const external = [_]recon.Trade{trade};

    const result = try engine.reconcileTrades(&internal, &external);
    defer alloc.free(result.breaks);

    try std.testing.expectEqual(@as(u32, 1), result.matched);
    try std.testing.expectEqual(@as(usize, 0), result.breaks.len);
    try std.testing.expectEqual(@as(u32, 0), result.unmatched_internal);
    try std.testing.expectEqual(@as(u32, 0), result.unmatched_external);
}

test "quantity mismatch is flagged" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var engine = try recon.ReconEngine.init(alloc, .{
        .price_tolerance = 0.0001,
        .qty_tolerance = 0,
        .time_window_ms = 5000,
    });
    defer engine.deinit();

    const internal_trade = recon.Trade{
        .id = "T002",
        .instrument = "ETH-USD",
        .side = .sell,
        .quantity = 200,
        .price = 3000,
        .timestamp_ms = 2000,
    };
    const external_trade = recon.Trade{
        .id = "T002",
        .instrument = "ETH-USD",
        .side = .sell,
        .quantity = 150, // different quantity
        .price = 3000,
        .timestamp_ms = 2000,
    };

    const internal = [_]recon.Trade{internal_trade};
    const external = [_]recon.Trade{external_trade};

    const result = try engine.reconcileTrades(&internal, &external);
    defer alloc.free(result.breaks);

    try std.testing.expect(result.breaks.len > 0);
    try std.testing.expectEqual(recon.BreakType.quantity_mismatch, result.breaks[0].break_type);
}

test "missing internal trade flagged" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var engine = try recon.ReconEngine.init(alloc, .{
        .price_tolerance = 0.001,
        .qty_tolerance = 0,
        .time_window_ms = 1000,
    });
    defer engine.deinit();

    const ext_trade = recon.Trade{
        .id = "T003",
        .instrument = "SOL-USD",
        .side = .buy,
        .quantity = 50,
        .price = 100,
        .timestamp_ms = 3000,
    };

    const internal = [_]recon.Trade{};
    const external = [_]recon.Trade{ext_trade};

    const result = try engine.reconcileTrades(&internal, &external);
    defer alloc.free(result.breaks);

    try std.testing.expectEqual(@as(u32, 0), result.matched);
    try std.testing.expectEqual(@as(u32, 1), result.unmatched_external);
    try std.testing.expect(result.breaks.len > 0);
    try std.testing.expectEqual(recon.BreakType.missing_internal, result.breaks[0].break_type);
}

test "missing external trade flagged" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var engine = try recon.ReconEngine.init(alloc, .{
        .price_tolerance = 0.001,
        .qty_tolerance = 0,
        .time_window_ms = 1000,
    });
    defer engine.deinit();

    const int_trade = recon.Trade{
        .id = "T004",
        .instrument = "ADA-USD",
        .side = .sell,
        .quantity = 1000,
        .price = 1,
        .timestamp_ms = 4000,
    };

    const internal = [_]recon.Trade{int_trade};
    const external = [_]recon.Trade{};

    const result = try engine.reconcileTrades(&internal, &external);
    defer alloc.free(result.breaks);

    try std.testing.expectEqual(@as(u32, 0), result.matched);
    try std.testing.expectEqual(@as(u32, 1), result.unmatched_internal);
    try std.testing.expect(result.breaks.len > 0);
    try std.testing.expectEqual(recon.BreakType.missing_external, result.breaks[0].break_type);
}

test "price within tolerance matches" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var engine = try recon.ReconEngine.init(alloc, .{
        .price_tolerance = 0.01, // 1% tolerance
        .qty_tolerance = 0,
        .time_window_ms = 5000,
    });
    defer engine.deinit();

    const int_trade = recon.Trade{
        .id = "T005",
        .instrument = "BTC-USD",
        .side = .buy,
        .quantity = 10,
        .price = 50000,
        .timestamp_ms = 5000,
    };
    const ext_trade = recon.Trade{
        .id = "T005",
        .instrument = "BTC-USD",
        .side = .buy,
        .quantity = 10,
        .price = 50400, // ~0.8% difference — within 1%
        .timestamp_ms = 5000,
    };

    const internal = [_]recon.Trade{int_trade};
    const external = [_]recon.Trade{ext_trade};

    const result = try engine.reconcileTrades(&internal, &external);
    defer alloc.free(result.breaks);

    try std.testing.expectEqual(@as(u32, 1), result.matched);
    try std.testing.expectEqual(@as(usize, 0), result.breaks.len);
}

test "price outside tolerance breaks" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var engine = try recon.ReconEngine.init(alloc, .{
        .price_tolerance = 0.001, // 0.1% tolerance
        .qty_tolerance = 0,
        .time_window_ms = 5000,
    });
    defer engine.deinit();

    const int_trade = recon.Trade{
        .id = "T006",
        .instrument = "BTC-USD",
        .side = .buy,
        .quantity = 10,
        .price = 50000,
        .timestamp_ms = 6000,
    };
    const ext_trade = recon.Trade{
        .id = "T006",
        .instrument = "BTC-USD",
        .side = .buy,
        .quantity = 10,
        .price = 50400, // 0.8% — outside 0.1%
        .timestamp_ms = 6000,
    };

    const internal = [_]recon.Trade{int_trade};
    const external = [_]recon.Trade{ext_trade};

    const result = try engine.reconcileTrades(&internal, &external);
    defer alloc.free(result.breaks);

    try std.testing.expect(result.breaks.len > 0);
    try std.testing.expectEqual(recon.BreakType.price_mismatch, result.breaks[0].break_type);
}

test "fuzzy match by instrument-side-qty-time" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var engine = try recon.ReconEngine.init(alloc, .{
        .price_tolerance = 0.01,
        .qty_tolerance = 5,
        .time_window_ms = 10000,
    });
    defer engine.deinit();

    const int_trade = recon.Trade{
        .id = "INTERNAL-007",
        .instrument = "ETH-USD",
        .side = .buy,
        .quantity = 100,
        .price = 3000,
        .timestamp_ms = 10000,
    };
    const ext_trade = recon.Trade{
        .id = "EXTERNAL-007", // different ID
        .instrument = "ETH-USD",
        .side = .buy,
        .quantity = 102, // within qty tolerance of 5
        .price = 3000,
        .timestamp_ms = 10500, // within 10s time window
    };

    const internal = [_]recon.Trade{int_trade};
    const external = [_]recon.Trade{ext_trade};

    const result = try engine.reconcileTrades(&internal, &external);
    defer alloc.free(result.breaks);

    // Should match via fuzzy logic
    try std.testing.expectEqual(@as(u32, 0), result.unmatched_internal);
    try std.testing.expectEqual(@as(u32, 0), result.unmatched_external);
}
