// Basis trading strategy tests
const std = @import("std");
const basis_mod = @import("basis");
const BasisStrategy = basis_mod.BasisStrategy;
const BasisConfig = basis_mod.BasisConfig;
const Direction = basis_mod.Direction;
const orderbook_mod = @import("orderbook");
const L2Book = orderbook_mod.L2Book;

fn makeBook(allocator: std.mem.Allocator, bid_price: i64, ask_price: i64) !L2Book {
    var book = try L2Book.init(allocator, 10);
    book.applyUpdate(.bid, bid_price, 100);
    book.applyUpdate(.ask, ask_price, 100);
    return book;
}

test "enter_long_basis signal when futures premium exceeds threshold" {
    var strategy = try BasisStrategy.init(std.testing.allocator, BasisConfig{
        .entry_threshold_bps = 50.0,
        .exit_threshold_bps = 10.0,
        .max_position = 1000,
        .instrument_spot = "BTC/USD",
        .instrument_futures = "BTC/USD:2025-06",
        .days_to_expiry = 30.0,
    });
    defer strategy.deinit();

    // Spot mid = 50000, futures mid = 50300
    // basis = (50300 - 50000) / 50000 * (365/30) * 10000
    // = 0.006 * 12.167 * 10000 = 730 bps > 50 bps threshold
    var spot = try makeBook(std.testing.allocator, 49990, 50010);
    defer spot.deinit();
    var futures = try makeBook(std.testing.allocator, 50290, 50310);
    defer futures.deinit();

    const signal = strategy.onMarketData(&spot, &futures);
    try std.testing.expect(signal != null);
    try std.testing.expectEqual(Direction.enter_long_basis, signal.?.direction);
}

test "no signal when basis within band" {
    var strategy = try BasisStrategy.init(std.testing.allocator, BasisConfig{
        .entry_threshold_bps = 500.0, // very high threshold
        .exit_threshold_bps = 100.0,
        .max_position = 1000,
        .instrument_spot = "BTC/USD",
        .instrument_futures = "BTC/USD:2025-06",
        .days_to_expiry = 30.0,
    });
    defer strategy.deinit();

    // Small premium: basis = ~73 bps < 500 bps threshold
    var spot = try makeBook(std.testing.allocator, 49990, 50010);
    defer spot.deinit();
    var futures = try makeBook(std.testing.allocator, 50040, 50060);
    defer futures.deinit();

    const signal = strategy.onMarketData(&spot, &futures);
    try std.testing.expect(signal == null);
}

test "signal quantities maintain hedge ratio (spot_qty == futures_qty)" {
    var strategy = try BasisStrategy.init(std.testing.allocator, BasisConfig{
        .entry_threshold_bps = 50.0,
        .exit_threshold_bps = 10.0,
        .max_position = 500,
        .instrument_spot = "BTC/USD",
        .instrument_futures = "BTC/USD:2025-06",
        .days_to_expiry = 30.0,
    });
    defer strategy.deinit();

    var spot = try makeBook(std.testing.allocator, 49990, 50010);
    defer spot.deinit();
    var futures = try makeBook(std.testing.allocator, 50290, 50310);
    defer futures.deinit();

    const signal = strategy.onMarketData(&spot, &futures);
    try std.testing.expect(signal != null);
    try std.testing.expectEqual(signal.?.spot_qty, signal.?.futures_qty);
    try std.testing.expectEqual(@as(i64, 500), signal.?.spot_qty);
}

test "exit signal when basis narrows" {
    var strategy = try BasisStrategy.init(std.testing.allocator, BasisConfig{
        .entry_threshold_bps = 50.0,
        .exit_threshold_bps = 100.0, // exit threshold: basis < 100 bps
        .max_position = 1000,
        .instrument_spot = "BTC/USD",
        .instrument_futures = "BTC/USD:2025-06",
        .days_to_expiry = 30.0,
    });
    defer strategy.deinit();

    // First enter with large basis
    var spot1 = try makeBook(std.testing.allocator, 49990, 50010);
    defer spot1.deinit();
    var futures1 = try makeBook(std.testing.allocator, 50290, 50310);
    defer futures1.deinit();

    const entry = strategy.onMarketData(&spot1, &futures1);
    try std.testing.expect(entry != null);
    try std.testing.expectEqual(Direction.enter_long_basis, entry.?.direction);

    // Now narrow the basis (futures close to spot, basis < exit_threshold)
    var spot2 = try makeBook(std.testing.allocator, 49995, 50005);
    defer spot2.deinit();
    var futures2 = try makeBook(std.testing.allocator, 50000, 50010); // ~tiny basis
    defer futures2.deinit();

    const exit_signal = strategy.onMarketData(&spot2, &futures2);
    try std.testing.expect(exit_signal != null);
    try std.testing.expectEqual(Direction.exit, exit_signal.?.direction);
}

test "enter_short_basis when futures discount exceeds threshold" {
    var strategy = try BasisStrategy.init(std.testing.allocator, BasisConfig{
        .entry_threshold_bps = 50.0,
        .exit_threshold_bps = 10.0,
        .max_position = 1000,
        .instrument_spot = "BTC/USD",
        .instrument_futures = "BTC/USD:2025-06",
        .days_to_expiry = 30.0,
    });
    defer strategy.deinit();

    // Spot mid = 50000, futures mid = 49700 -> large negative basis
    var spot = try makeBook(std.testing.allocator, 49990, 50010);
    defer spot.deinit();
    var futures = try makeBook(std.testing.allocator, 49690, 49710);
    defer futures.deinit();

    const signal = strategy.onMarketData(&spot, &futures);
    try std.testing.expect(signal != null);
    try std.testing.expectEqual(Direction.enter_short_basis, signal.?.direction);
}
