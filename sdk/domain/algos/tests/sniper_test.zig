const std = @import("std");
const sniper = @import("sniper");

test "SniperAlgo init sets correct defaults" {
    const params = sniper.SniperParams{
        .total_qty = 500,
        .max_price = 50000,
        .min_size_threshold = 100,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    const algo = sniper.SniperAlgo.init(params);
    try std.testing.expectEqual(@as(i64, 0), algo.filled_qty);
    try std.testing.expect(!algo.fired);
    try std.testing.expectEqual(@as(i64, 500), algo.params.total_qty);
    try std.testing.expectEqual(@as(i64, 50000), algo.params.max_price);
    try std.testing.expectEqual(@as(i64, 100), algo.params.min_size_threshold);
}

test "Sniper buy fires when sufficient ask liquidity at acceptable price" {
    const params = sniper.SniperParams{
        .total_qty = 200,
        .max_price = 50100,
        .min_size_threshold = 100,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);

    const asks = [_]sniper.BookLevel{
        .{ .price = 50000, .quantity = 80 },
        .{ .price = 50050, .quantity = 70 },
    };
    const bids = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    const order = algo.onBookUpdate(&book);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(sniper.Side.buy, order.?.side);
    try std.testing.expectEqual(sniper.OrderType.market, order.?.order_type);
    // Available = 80 + 70 = 150; remaining = 200; qty = min(200, 150) = 150.
    try std.testing.expectEqual(@as(i64, 150), order.?.quantity);
    // Best price is the first ask level.
    try std.testing.expectEqual(@as(i64, 50000), order.?.price.?);
    try std.testing.expect(algo.fired);
}

test "Sniper sell fires when sufficient bid liquidity at acceptable price" {
    const params = sniper.SniperParams{
        .total_qty = 300,
        .max_price = 49900, // min acceptable price for sells
        .min_size_threshold = 50,
        .instrument = "ETH/USD",
        .side = .sell,
    };

    var algo = sniper.SniperAlgo.init(params);

    // Bids sorted descending.
    const bids = [_]sniper.BookLevel{
        .{ .price = 50100, .quantity = 100 },
        .{ .price = 50000, .quantity = 80 },
        .{ .price = 49900, .quantity = 60 },
    };
    const asks = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    const order = algo.onBookUpdate(&book);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(sniper.Side.sell, order.?.side);
    // Available = 100 + 80 + 60 = 240; remaining = 300; qty = min(300, 240) = 240.
    try std.testing.expectEqual(@as(i64, 240), order.?.quantity);
    // Best price is the first (highest) bid level.
    try std.testing.expectEqual(@as(i64, 50100), order.?.price.?);
}

test "Sniper does not fire when liquidity below threshold" {
    const params = sniper.SniperParams{
        .total_qty = 200,
        .max_price = 50100,
        .min_size_threshold = 500,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);

    const asks = [_]sniper.BookLevel{
        .{ .price = 50000, .quantity = 100 },
        .{ .price = 50050, .quantity = 50 },
    };
    const bids = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    // Available = 150, threshold = 500 → should not fire.
    const order = algo.onBookUpdate(&book);
    try std.testing.expect(order == null);
    try std.testing.expect(!algo.fired);
}

test "Sniper buy ignores ask levels above max_price" {
    const params = sniper.SniperParams{
        .total_qty = 200,
        .max_price = 50050,
        .min_size_threshold = 50,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);

    const asks = [_]sniper.BookLevel{
        .{ .price = 50000, .quantity = 30 },
        .{ .price = 50050, .quantity = 30 },
        .{ .price = 50100, .quantity = 500 }, // above max_price — excluded
    };
    const bids = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    // Available = 30 + 30 = 60 (level at 50100 is excluded); threshold = 50 → fires.
    const order = algo.onBookUpdate(&book);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(@as(i64, 60), order.?.quantity);
}

test "Sniper sell ignores bid levels below max_price" {
    const params = sniper.SniperParams{
        .total_qty = 200,
        .max_price = 50000, // min acceptable for sells
        .min_size_threshold = 50,
        .instrument = "BTC/USD",
        .side = .sell,
    };

    var algo = sniper.SniperAlgo.init(params);

    // Bids descending.
    const bids = [_]sniper.BookLevel{
        .{ .price = 50100, .quantity = 40 },
        .{ .price = 50000, .quantity = 30 },
        .{ .price = 49900, .quantity = 500 }, // below max_price — excluded
    };
    const asks = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    // Available = 40 + 30 = 70 (level at 49900 excluded); threshold = 50 → fires.
    const order = algo.onBookUpdate(&book);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(@as(i64, 70), order.?.quantity);
}

test "Sniper does not fire twice without fill" {
    const params = sniper.SniperParams{
        .total_qty = 200,
        .max_price = 50100,
        .min_size_threshold = 50,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);

    const asks = [_]sniper.BookLevel{
        .{ .price = 50000, .quantity = 100 },
    };
    const bids = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    // First update fires.
    const order1 = algo.onBookUpdate(&book);
    try std.testing.expect(order1 != null);

    // Second update without fill — should not fire again.
    const order2 = algo.onBookUpdate(&book);
    try std.testing.expect(order2 == null);
}

test "Sniper re-fires after partial fill" {
    const params = sniper.SniperParams{
        .total_qty = 300,
        .max_price = 50100,
        .min_size_threshold = 50,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);

    const asks = [_]sniper.BookLevel{
        .{ .price = 50000, .quantity = 150 },
    };
    const bids = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    // First fire.
    const order1 = algo.onBookUpdate(&book);
    try std.testing.expect(order1 != null);
    try std.testing.expectEqual(@as(i64, 150), order1.?.quantity);

    // Partial fill: 150 of 300 done; remaining = 150.
    algo.onFill(.{ .quantity = 150, .price = 50000 });
    try std.testing.expectEqual(@as(i64, 150), algo.filled_qty);
    try std.testing.expect(!algo.fired); // Reset after partial fill.

    // Re-fires on next book update.
    const order2 = algo.onBookUpdate(&book);
    try std.testing.expect(order2 != null);
    try std.testing.expectEqual(@as(i64, 150), order2.?.quantity);
}

test "Sniper does not re-fire after complete fill" {
    const params = sniper.SniperParams{
        .total_qty = 100,
        .max_price = 50100,
        .min_size_threshold = 50,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);

    const asks = [_]sniper.BookLevel{
        .{ .price = 50000, .quantity = 200 },
    };
    const bids = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    // Fire.
    const order1 = algo.onBookUpdate(&book);
    try std.testing.expect(order1 != null);
    try std.testing.expectEqual(@as(i64, 100), order1.?.quantity);

    // Complete fill.
    algo.onFill(.{ .quantity = 100, .price = 50000 });
    try std.testing.expectEqual(@as(i64, 100), algo.filled_qty);
    try std.testing.expect(algo.fired); // Not reset — fully filled.

    // Should not fire again; remaining = 0.
    const order2 = algo.onBookUpdate(&book);
    try std.testing.expect(order2 == null);
}

test "Sniper quantity capped at remaining" {
    const params = sniper.SniperParams{
        .total_qty = 50,
        .max_price = 50100,
        .min_size_threshold = 10,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);

    const asks = [_]sniper.BookLevel{
        .{ .price = 50000, .quantity = 1000 },
    };
    const bids = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    // Available (1000) > remaining (50) → capped at 50.
    const order = algo.onBookUpdate(&book);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(@as(i64, 50), order.?.quantity);
}

test "Sniper returns null on empty book" {
    const params = sniper.SniperParams{
        .total_qty = 100,
        .max_price = 50000,
        .min_size_threshold = 10,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);

    const asks = [_]sniper.BookLevel{};
    const bids = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    const order = algo.onBookUpdate(&book);
    try std.testing.expect(order == null);
    try std.testing.expect(!algo.fired);
}

test "Sniper buy best_price is first acceptable ask level" {
    const params = sniper.SniperParams{
        .total_qty = 1000,
        .max_price = 50200,
        .min_size_threshold = 10,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);

    const asks = [_]sniper.BookLevel{
        .{ .price = 50050, .quantity = 20 },
        .{ .price = 50100, .quantity = 30 },
        .{ .price = 50200, .quantity = 50 },
    };
    const bids = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    const order = algo.onBookUpdate(&book);
    try std.testing.expect(order != null);
    // Best price should be the top-of-book ask.
    try std.testing.expectEqual(@as(i64, 50050), order.?.price.?);
}

test "Sniper sell best_price is first acceptable bid level" {
    const params = sniper.SniperParams{
        .total_qty = 1000,
        .max_price = 49800, // min acceptable
        .min_size_threshold = 10,
        .instrument = "BTC/USD",
        .side = .sell,
    };

    var algo = sniper.SniperAlgo.init(params);

    // Bids descending.
    const bids = [_]sniper.BookLevel{
        .{ .price = 50100, .quantity = 20 },
        .{ .price = 50000, .quantity = 30 },
        .{ .price = 49900, .quantity = 50 },
    };
    const asks = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    const order = algo.onBookUpdate(&book);
    try std.testing.expect(order != null);
    // Best price should be the top-of-book bid.
    try std.testing.expectEqual(@as(i64, 50100), order.?.price.?);
}

test "Sniper fill tracking across multiple fills" {
    const params = sniper.SniperParams{
        .total_qty = 500,
        .max_price = 50100,
        .min_size_threshold = 10,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);
    try std.testing.expectEqual(@as(i64, 0), algo.filled_qty);

    algo.onFill(.{ .quantity = 100, .price = 50000 });
    try std.testing.expectEqual(@as(i64, 100), algo.filled_qty);

    algo.onFill(.{ .quantity = 150, .price = 50050 });
    try std.testing.expectEqual(@as(i64, 250), algo.filled_qty);

    algo.onFill(.{ .quantity = 250, .price = 50100 });
    try std.testing.expectEqual(@as(i64, 500), algo.filled_qty);
}

test "Sniper instrument propagated to child order" {
    const params = sniper.SniperParams{
        .total_qty = 100,
        .max_price = 60000,
        .min_size_threshold = 10,
        .instrument = "SOL/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);

    const asks = [_]sniper.BookLevel{
        .{ .price = 59000, .quantity = 200 },
    };
    const bids = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    const order = algo.onBookUpdate(&book);
    try std.testing.expect(order != null);
    try std.testing.expect(std.mem.eql(u8, "SOL/USD", order.?.instrument));
}

test "Sniper multi-round lifecycle buy" {
    const params = sniper.SniperParams{
        .total_qty = 500,
        .max_price = 50200,
        .min_size_threshold = 50,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);

    const asks = [_]sniper.BookLevel{
        .{ .price = 50000, .quantity = 100 },
        .{ .price = 50100, .quantity = 100 },
    };
    const bids = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    // Round 1: fire with 200 available, remaining 500 → qty = 200.
    const order1 = algo.onBookUpdate(&book);
    try std.testing.expect(order1 != null);
    try std.testing.expectEqual(@as(i64, 200), order1.?.quantity);

    // Fill round 1.
    algo.onFill(.{ .quantity = 200, .price = 50000 });
    try std.testing.expectEqual(@as(i64, 200), algo.filled_qty);
    try std.testing.expect(!algo.fired);

    // Round 2: fire again, remaining 300, available 200 → qty = 200.
    const order2 = algo.onBookUpdate(&book);
    try std.testing.expect(order2 != null);
    try std.testing.expectEqual(@as(i64, 200), order2.?.quantity);

    // Fill round 2.
    algo.onFill(.{ .quantity = 200, .price = 50050 });
    try std.testing.expectEqual(@as(i64, 400), algo.filled_qty);
    try std.testing.expect(!algo.fired);

    // Round 3: fire again, remaining 100, available 200 → qty = 100 (capped).
    const order3 = algo.onBookUpdate(&book);
    try std.testing.expect(order3 != null);
    try std.testing.expectEqual(@as(i64, 100), order3.?.quantity);

    // Fill round 3: complete.
    algo.onFill(.{ .quantity = 100, .price = 50100 });
    try std.testing.expectEqual(@as(i64, 500), algo.filled_qty);
    try std.testing.expect(algo.fired); // Not reset — fully filled.

    // No more orders.
    const order4 = algo.onBookUpdate(&book);
    try std.testing.expect(order4 == null);
}

test "Sniper threshold exactly met fires" {
    const params = sniper.SniperParams{
        .total_qty = 200,
        .max_price = 50100,
        .min_size_threshold = 100,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);

    // Available exactly equals threshold.
    const asks = [_]sniper.BookLevel{
        .{ .price = 50000, .quantity = 100 },
    };
    const bids = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    const order = algo.onBookUpdate(&book);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(@as(i64, 100), order.?.quantity);
}

test "Sniper threshold minus one does not fire" {
    const params = sniper.SniperParams{
        .total_qty = 200,
        .max_price = 50100,
        .min_size_threshold = 100,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);

    // Available is one less than threshold.
    const asks = [_]sniper.BookLevel{
        .{ .price = 50000, .quantity = 99 },
    };
    const bids = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    const order = algo.onBookUpdate(&book);
    try std.testing.expect(order == null);
}

test "Sniper all ask levels above max_price returns null" {
    const params = sniper.SniperParams{
        .total_qty = 200,
        .max_price = 49000,
        .min_size_threshold = 10,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);

    const asks = [_]sniper.BookLevel{
        .{ .price = 50000, .quantity = 500 },
        .{ .price = 51000, .quantity = 500 },
    };
    const bids = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    const order = algo.onBookUpdate(&book);
    try std.testing.expect(order == null);
}

test "Sniper all bid levels below max_price returns null for sell" {
    const params = sniper.SniperParams{
        .total_qty = 200,
        .max_price = 51000, // min acceptable for sells
        .min_size_threshold = 10,
        .instrument = "BTC/USD",
        .side = .sell,
    };

    var algo = sniper.SniperAlgo.init(params);

    const bids = [_]sniper.BookLevel{
        .{ .price = 50000, .quantity = 500 },
        .{ .price = 49000, .quantity = 500 },
    };
    const asks = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    const order = algo.onBookUpdate(&book);
    try std.testing.expect(order == null);
}

test "Sniper child order is always market type" {
    const params = sniper.SniperParams{
        .total_qty = 100,
        .max_price = 50100,
        .min_size_threshold = 10,
        .instrument = "BTC/USD",
        .side = .buy,
    };

    var algo = sniper.SniperAlgo.init(params);

    const asks = [_]sniper.BookLevel{
        .{ .price = 50000, .quantity = 200 },
    };
    const bids = [_]sniper.BookLevel{};
    const book = sniper.L2BookView{
        .bids = &bids,
        .asks = &asks,
    };

    const order = algo.onBookUpdate(&book);
    try std.testing.expect(order != null);
    try std.testing.expectEqual(sniper.OrderType.market, order.?.order_type);
}
