const std = @import("std");
const sor = @import("sor");

fn makeBook(allocator: std.mem.Allocator, ask_price: i64, ask_qty: i64) !*sor.L2Book {
    const book = try allocator.create(sor.L2Book);
    const bids = try allocator.alloc(sor.Level, 1);
    bids[0] = .{ .price = ask_price - 10, .quantity = ask_qty };
    const asks = try allocator.alloc(sor.Level, 1);
    asks[0] = .{ .price = ask_price, .quantity = ask_qty };
    book.* = sor.L2Book{ .bids = bids, .asks = asks };
    return book;
}

test "SOR routes to lowest-fee venue when prices equal" {
    const allocator = std.testing.allocator;

    const venues = [_]sor.VenueConfig{
        .{
            .name = "kraken",
            .fee_model = .maker_taker,
            .priority = 1,
            .taker_fee_bps = 26, // 0.26%
            .maker_fee_bps = 16,
        },
        .{
            .name = "binance",
            .fee_model = .maker_taker,
            .priority = 1,
            .taker_fee_bps = 10, // 0.10% — cheaper
            .maker_fee_bps = 5,
        },
    };

    var router = try sor.SmartOrderRouter.init(allocator, &venues);
    defer router.deinit();

    // Both venues have same price.
    const kraken_book = try makeBook(allocator, 50000, 1000);
    defer {
        allocator.free(kraken_book.bids);
        allocator.free(kraken_book.asks);
        allocator.destroy(kraken_book);
    }
    const binance_book = try makeBook(allocator, 50000, 1000);
    defer {
        allocator.free(binance_book.bids);
        allocator.free(binance_book.asks);
        allocator.destroy(binance_book);
    }

    const books = [_]sor.VenueBook{
        .{ .venue = "kraken", .book = kraken_book },
        .{ .venue = "binance", .book = binance_book },
    };
    const market_state = sor.MarketState{ .books = &books };

    const order = sor.Order{
        .instrument = "BTC/USD",
        .side = .buy,
        .order_type = .market,
        .quantity = 100,
        .price = null,
    };

    const decision = try router.route(&order, &market_state);
    // Binance has lower fee → should be chosen.
    try std.testing.expectEqualStrings("binance", decision.venue);
}

test "SOR routes to best-price venue when fees equal" {
    const allocator = std.testing.allocator;

    const venues = [_]sor.VenueConfig{
        .{
            .name = "venue_a",
            .fee_model = .flat,
            .priority = 1,
            .taker_fee_bps = 10,
            .maker_fee_bps = 10,
        },
        .{
            .name = "venue_b",
            .fee_model = .flat,
            .priority = 1,
            .taker_fee_bps = 10,
            .maker_fee_bps = 10,
        },
    };

    var router = try sor.SmartOrderRouter.init(allocator, &venues);
    defer router.deinit();

    // venue_b has better (lower) ask price.
    const book_a = try makeBook(allocator, 50100, 1000);
    defer {
        allocator.free(book_a.bids);
        allocator.free(book_a.asks);
        allocator.destroy(book_a);
    }
    const book_b = try makeBook(allocator, 49900, 1000);
    defer {
        allocator.free(book_b.bids);
        allocator.free(book_b.asks);
        allocator.destroy(book_b);
    }

    const books = [_]sor.VenueBook{
        .{ .venue = "venue_a", .book = book_a },
        .{ .venue = "venue_b", .book = book_b },
    };
    const market_state = sor.MarketState{ .books = &books };

    const order = sor.Order{
        .instrument = "BTC/USD",
        .side = .buy,
        .order_type = .market,
        .quantity = 100,
        .price = null,
    };

    const decision = try router.route(&order, &market_state);
    try std.testing.expectEqualStrings("venue_b", decision.venue);
}

test "SOR splits across venues for large orders" {
    const allocator = std.testing.allocator;

    const venues = [_]sor.VenueConfig{
        .{
            .name = "venue_a",
            .fee_model = .flat,
            .priority = 1,
            .taker_fee_bps = 10,
            .maker_fee_bps = 10,
        },
        .{
            .name = "venue_b",
            .fee_model = .flat,
            .priority = 1,
            .taker_fee_bps = 10,
            .maker_fee_bps = 10,
        },
    };

    var router = try sor.SmartOrderRouter.init(allocator, &venues);
    defer router.deinit();

    // venue_a has slightly better price but limited liquidity (300 only).
    const book_a = try makeBook(allocator, 49900, 300);
    defer {
        allocator.free(book_a.bids);
        allocator.free(book_a.asks);
        allocator.destroy(book_a);
    }
    const book_b = try makeBook(allocator, 50000, 1000);
    defer {
        allocator.free(book_b.bids);
        allocator.free(book_b.asks);
        allocator.destroy(book_b);
    }

    const books = [_]sor.VenueBook{
        .{ .venue = "venue_a", .book = book_a },
        .{ .venue = "venue_b", .book = book_b },
    };
    const market_state = sor.MarketState{ .books = &books };

    // Order larger than available at best venue.
    const order = sor.Order{
        .instrument = "BTC/USD",
        .side = .buy,
        .order_type = .market,
        .quantity = 700,
        .price = null,
    };

    const decision = try router.route(&order, &market_state);
    // Should split: 300 to venue_a, 400 to venue_b.
    try std.testing.expectEqual(@as(usize, 2), decision.child_orders.len);

    var total_qty: i64 = 0;
    for (decision.child_orders) |co| {
        total_qty += co.quantity;
    }
    try std.testing.expectEqual(@as(i64, 700), total_qty);
}

test "SOR venue with high reject rate scored lower" {
    const allocator = std.testing.allocator;

    const venues = [_]sor.VenueConfig{
        .{
            .name = "reliable",
            .fee_model = .flat,
            .priority = 1,
            .taker_fee_bps = 10,
            .maker_fee_bps = 10,
        },
        .{
            .name = "unreliable",
            .fee_model = .flat,
            .priority = 1,
            .taker_fee_bps = 10,
            .maker_fee_bps = 10,
        },
    };

    var router = try sor.SmartOrderRouter.init(allocator, &venues);
    defer router.deinit();

    // Set unreliable venue stats: high reject rate.
    router.updateVenueStats("unreliable", .{
        .avg_latency_ns = 1_000_000,
        .fill_rate = 0.3,
        .reject_rate = 0.7,
    });

    // Same price at both venues.
    const book_r = try makeBook(allocator, 50000, 1000);
    defer {
        allocator.free(book_r.bids);
        allocator.free(book_r.asks);
        allocator.destroy(book_r);
    }
    const book_u = try makeBook(allocator, 50000, 1000);
    defer {
        allocator.free(book_u.bids);
        allocator.free(book_u.asks);
        allocator.destroy(book_u);
    }

    const books = [_]sor.VenueBook{
        .{ .venue = "reliable", .book = book_r },
        .{ .venue = "unreliable", .book = book_u },
    };
    const market_state = sor.MarketState{ .books = &books };

    const order = sor.Order{
        .instrument = "BTC/USD",
        .side = .buy,
        .order_type = .market,
        .quantity = 100,
        .price = null,
    };

    const decision = try router.route(&order, &market_state);
    try std.testing.expectEqualStrings("reliable", decision.venue);
}

test "SOR uses latency as tiebreaker when price and fee equal" {
    const allocator = std.testing.allocator;

    const venues = [_]sor.VenueConfig{
        .{
            .name = "slow",
            .fee_model = .flat,
            .priority = 1,
            .taker_fee_bps = 10,
            .maker_fee_bps = 10,
        },
        .{
            .name = "fast",
            .fee_model = .flat,
            .priority = 1,
            .taker_fee_bps = 10,
            .maker_fee_bps = 10,
        },
    };

    var router = try sor.SmartOrderRouter.init(allocator, &venues);
    defer router.deinit();

    router.updateVenueStats("slow", .{
        .avg_latency_ns = 10_000_000, // 10ms
        .fill_rate = 0.9,
        .reject_rate = 0.01,
    });
    router.updateVenueStats("fast", .{
        .avg_latency_ns = 100_000, // 0.1ms
        .fill_rate = 0.9,
        .reject_rate = 0.01,
    });

    const book_slow = try makeBook(allocator, 50000, 1000);
    defer {
        allocator.free(book_slow.bids);
        allocator.free(book_slow.asks);
        allocator.destroy(book_slow);
    }
    const book_fast = try makeBook(allocator, 50000, 1000);
    defer {
        allocator.free(book_fast.bids);
        allocator.free(book_fast.asks);
        allocator.destroy(book_fast);
    }

    const books = [_]sor.VenueBook{
        .{ .venue = "slow", .book = book_slow },
        .{ .venue = "fast", .book = book_fast },
    };
    const market_state = sor.MarketState{ .books = &books };

    const order = sor.Order{
        .instrument = "BTC/USD",
        .side = .buy,
        .order_type = .market,
        .quantity = 100,
        .price = null,
    };

    const decision = try router.route(&order, &market_state);
    try std.testing.expectEqualStrings("fast", decision.venue);
}
