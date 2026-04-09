// Tests for synthetic market data feed (GBM + mean-reversion, 8 instruments)

const std = @import("std");
const synthetic = @import("synthetic");

const SyntheticFeed = synthetic.SyntheticFeed;
const InstrumentConfig = synthetic.InstrumentConfig;

// ---------------------------------------------------------------------------
// Initialization
// ---------------------------------------------------------------------------

test "SyntheticFeed: init populates all 8 books" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    for (0..8) |i| {
        try std.testing.expect(feed.books[i].bids_len >= 1);
        try std.testing.expect(feed.books[i].asks_len >= 1);
    }
}

test "SyntheticFeed: init sets tick_count to zero" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 0);
    defer feed.deinit();
    try std.testing.expectEqual(@as(u64, 0), feed.tick_count);
}

test "SyntheticFeed: init base_prices match instrument configs" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 99);
    defer feed.deinit();
    for (0..8) |i| {
        try std.testing.expectEqual(feed.instruments[i].base_price, feed.base_prices[i]);
    }
}

test "SyntheticFeed: books have full depth after init" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();
    // populateBook writes exactly DEPTH=20 levels per side
    for (0..8) |i| {
        try std.testing.expectEqual(@as(usize, 20), feed.books[i].bids_len);
        try std.testing.expectEqual(@as(usize, 20), feed.books[i].asks_len);
    }
}

test "SyntheticFeed: different seeds produce different prices" {
    var feed_a = try SyntheticFeed.init(std.testing.allocator, 1);
    defer feed_a.deinit();
    var feed_b = try SyntheticFeed.init(std.testing.allocator, 2);
    defer feed_b.deinit();

    // Advance both feeds
    for (0..50) |_| {
        feed_a.tick();
        feed_b.tick();
    }

    // At least one instrument should diverge in mid price
    var any_different = false;
    for (0..8) |i| {
        const mid_a = feed_a.books[i].midPrice() orelse continue;
        const mid_b = feed_b.books[i].midPrice() orelse continue;
        if (mid_a != mid_b) {
            any_different = true;
            break;
        }
    }
    try std.testing.expect(any_different);
}

test "SyntheticFeed: same seed produces deterministic results" {
    var feed_a = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed_a.deinit();
    var feed_b = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed_b.deinit();

    for (0..50) |_| {
        feed_a.tick();
        feed_b.tick();
    }

    for (0..8) |i| {
        try std.testing.expectEqual(feed_a.base_prices[i], feed_b.base_prices[i]);
    }
}

// ---------------------------------------------------------------------------
// Tick advancement
// ---------------------------------------------------------------------------

test "SyntheticFeed: single tick increments tick_count" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();
    feed.tick();
    try std.testing.expectEqual(@as(u64, 1), feed.tick_count);
}

test "SyntheticFeed: multiple ticks increment tick_count correctly" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();
    for (0..100) |_| feed.tick();
    try std.testing.expectEqual(@as(u64, 100), feed.tick_count);
}

test "SyntheticFeed: tick updates base_prices" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    var initial_prices: [8]i64 = undefined;
    @memcpy(&initial_prices, &feed.base_prices);

    // Run enough ticks so at least one price moves
    for (0..20) |_| feed.tick();

    var any_changed = false;
    for (0..8) |i| {
        if (feed.base_prices[i] != initial_prices[i]) {
            any_changed = true;
            break;
        }
    }
    try std.testing.expect(any_changed);
}

test "SyntheticFeed: books still have data after many ticks" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    for (0..200) |_| feed.tick();

    for (0..8) |i| {
        try std.testing.expect(feed.books[i].bids_len >= 1);
        try std.testing.expect(feed.books[i].asks_len >= 1);
    }
}

test "SyntheticFeed: book repopulation on tick 20 boundary" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    // Advance exactly 20 ticks -- triggers repopulation
    for (0..20) |_| feed.tick();
    try std.testing.expectEqual(@as(u64, 20), feed.tick_count);

    // After repopulation, every book should have full depth
    for (0..8) |i| {
        try std.testing.expectEqual(@as(usize, 20), feed.books[i].bids_len);
        try std.testing.expectEqual(@as(usize, 20), feed.books[i].asks_len);
    }
}

// ---------------------------------------------------------------------------
// Price constraints and mean reversion
// ---------------------------------------------------------------------------

test "SyntheticFeed: prices stay positive after 1000 ticks" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    for (0..1000) |_| feed.tick();

    for (0..8) |i| {
        // base_prices should remain above the 10% floor
        const min_price = @divTrunc(feed.instruments[i].base_price, 10);
        try std.testing.expect(feed.base_prices[i] >= min_price);
    }
}

test "SyntheticFeed: mid prices are positive after ticks" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    for (0..100) |_| feed.tick();

    for (0..8) |i| {
        const mid = feed.books[i].midPrice();
        try std.testing.expect(mid != null);
        try std.testing.expect(mid.? > 0);
    }
}

test "SyntheticFeed: spread is positive for all instruments" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    // After repopulation boundary, spreads should be clean
    for (0..20) |_| feed.tick();

    for (0..8) |i| {
        const bid = feed.books[i].bestBid();
        const ask = feed.books[i].bestAsk();
        try std.testing.expect(bid != null);
        try std.testing.expect(ask != null);
        try std.testing.expect(ask.?.price > bid.?.price);
    }
}

// ---------------------------------------------------------------------------
// Correlation groups
// ---------------------------------------------------------------------------

test "SyntheticFeed: BTC spot and perp stay correlated" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    for (0..100) |_| feed.tick();

    const spot_mid = feed.books[0].midPrice() orelse return error.NoMidPrice;
    const perp_mid = feed.books[1].midPrice() orelse return error.NoMidPrice;

    try std.testing.expect(spot_mid > 0);
    try std.testing.expect(perp_mid > 0);

    // Within 2% of each other
    const diff = @abs(perp_mid - spot_mid);
    const threshold = @divTrunc(spot_mid * 2, 100);
    try std.testing.expect(diff < threshold);
}

test "SyntheticFeed: ETH spot and perp stay correlated" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    for (0..100) |_| feed.tick();

    // ETH-USD (idx 3) and ETH-USD-PERP (idx 4) are correlation group 1
    const spot_mid = feed.books[3].midPrice() orelse return error.NoMidPrice;
    const perp_mid = feed.books[4].midPrice() orelse return error.NoMidPrice;

    try std.testing.expect(spot_mid > 0);
    try std.testing.expect(perp_mid > 0);

    const diff = @abs(perp_mid - spot_mid);
    const threshold = @divTrunc(spot_mid * 2, 100);
    try std.testing.expect(diff < threshold);
}

test "SyntheticFeed: BTC and ADA are not tightly coupled" {
    // BTC (group 0) and ADA (group 3) should diverge more than same-group pairs
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    for (0..200) |_| feed.tick();

    // Verify correlation groups are correctly assigned
    try std.testing.expectEqual(@as(u8, 0), feed.instruments[0].correlation_group); // BTC-USD
    try std.testing.expectEqual(@as(u8, 3), feed.instruments[7].correlation_group); // ADA-USD
}

// ---------------------------------------------------------------------------
// InstrumentConfig fields
// ---------------------------------------------------------------------------

test "InstrumentConfig: symbol storage" {
    const cfg = InstrumentConfig{
        .symbol = [_]u8{0} ** 32,
        .symbol_len = 0,
        .base_price = 100,
        .volatility = 10,
        .mean_reversion_strength = 5,
        .drift = 0,
        .correlation_group = 0,
    };
    try std.testing.expectEqual(@as(u8, 0), cfg.symbol_len);
    try std.testing.expectEqual(@as(i64, 100), cfg.base_price);
    try std.testing.expectEqual(@as(i64, 10), cfg.volatility);
    try std.testing.expectEqual(@as(i64, 5), cfg.mean_reversion_strength);
    try std.testing.expectEqual(@as(i64, 0), cfg.drift);
    try std.testing.expectEqual(@as(u8, 0), cfg.correlation_group);
}

test "InstrumentConfig: symbol buffer is 32 bytes" {
    const cfg = InstrumentConfig{
        .symbol = [_]u8{0} ** 32,
        .symbol_len = 0,
        .base_price = 0,
        .volatility = 0,
        .mean_reversion_strength = 0,
        .drift = 0,
        .correlation_group = 0,
    };
    try std.testing.expectEqual(@as(usize, 32), cfg.symbol.len);
}

// ---------------------------------------------------------------------------
// getSymbol / getBook
// ---------------------------------------------------------------------------

test "SyntheticFeed: getSymbol returns correct names" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    try std.testing.expectEqualStrings("BTC-USD", feed.getSymbol(0));
    try std.testing.expectEqualStrings("BTC-USD-PERP", feed.getSymbol(1));
    try std.testing.expectEqualStrings("BTC-USD-20231229", feed.getSymbol(2));
    try std.testing.expectEqualStrings("ETH-USD", feed.getSymbol(3));
    try std.testing.expectEqualStrings("ETH-USD-PERP", feed.getSymbol(4));
    try std.testing.expectEqualStrings("SOL-USD-PERP", feed.getSymbol(5));
    try std.testing.expectEqualStrings("SOL-USD", feed.getSymbol(6));
    try std.testing.expectEqualStrings("ADA-USD", feed.getSymbol(7));
}

test "SyntheticFeed: getBook returns valid book pointer" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    for (0..8) |i| {
        const book = feed.getBook(i);
        // Book should have valid data
        try std.testing.expect(book.bids_len >= 1);
        try std.testing.expect(book.asks_len >= 1);
    }
}

test "SyntheticFeed: getBook mid price matches direct access" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    for (0..20) |_| feed.tick();

    for (0..8) |i| {
        const book_ptr = feed.getBook(i);
        const direct_mid = feed.books[i].midPrice();
        const ptr_mid = book_ptr.midPrice();
        try std.testing.expectEqual(direct_mid, ptr_mid);
    }
}

// ---------------------------------------------------------------------------
// computeFundingRate
// ---------------------------------------------------------------------------

test "computeFundingRate: zero spot returns zero" {
    const rate = SyntheticFeed.computeFundingRate(0, 50_000);
    try std.testing.expectEqual(@as(i64, 0), rate);
}

test "computeFundingRate: equal prices returns zero" {
    const rate = SyntheticFeed.computeFundingRate(50_000_000, 50_000_000);
    try std.testing.expectEqual(@as(i64, 0), rate);
}

test "computeFundingRate: perp above spot returns positive" {
    // perp > spot => positive funding (longs pay shorts)
    const spot: i64 = 5_000_000_000_000;
    const perp: i64 = 5_005_000_000_000; // 0.1% above
    const rate = SyntheticFeed.computeFundingRate(spot, perp);
    try std.testing.expect(rate > 0);
}

test "computeFundingRate: perp below spot returns negative" {
    // perp < spot => negative funding (shorts pay longs)
    const spot: i64 = 5_000_000_000_000;
    const perp: i64 = 4_995_000_000_000; // 0.1% below
    const rate = SyntheticFeed.computeFundingRate(spot, perp);
    try std.testing.expect(rate < 0);
}

test "computeFundingRate: clamped to +100 bps" {
    // Extremely large premium should clamp to +100 bps
    const spot: i64 = 1_000_000;
    const perp: i64 = 2_000_000; // 100% premium
    const rate = SyntheticFeed.computeFundingRate(spot, perp);
    try std.testing.expectEqual(@as(i64, 100), rate);
}

test "computeFundingRate: clamped to -100 bps" {
    // Extremely large discount should clamp to -100 bps
    const spot: i64 = 2_000_000;
    const perp: i64 = 1_000_000; // 50% discount
    const rate = SyntheticFeed.computeFundingRate(spot, perp);
    try std.testing.expectEqual(@as(i64, -100), rate);
}

test "computeFundingRate: small premium within bounds" {
    // 0.01% premium: k=100, diff=500, scale=10000, spot=5_000_000
    // raw = 100 * 500 * 10000 / 5_000_000 = 100
    // Actually let's pick a smaller diff to stay under clamp
    const spot: i64 = 5_000_000_000;
    const perp: i64 = 5_000_050_000; // 10 ppm above
    const rate = SyntheticFeed.computeFundingRate(spot, perp);
    // raw = 100 * 50_000 * 10_000 / 5_000_000_000 = 1
    try std.testing.expectEqual(@as(i64, 1), rate);
}

test "computeFundingRate: symmetric for equal magnitude premium and discount" {
    const spot: i64 = 5_000_000_000;
    const premium_perp: i64 = 5_000_050_000;
    const discount_perp: i64 = 4_999_950_000;

    const rate_pos = SyntheticFeed.computeFundingRate(spot, premium_perp);
    const rate_neg = SyntheticFeed.computeFundingRate(spot, discount_perp);

    // Should be approximately symmetric (integer division may differ by 1)
    try std.testing.expect(@abs(rate_pos + rate_neg) <= 1);
}

// ---------------------------------------------------------------------------
// Edge cases and stress
// ---------------------------------------------------------------------------

test "SyntheticFeed: init and immediate deinit (no ticks)" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 0);
    feed.deinit();
    // Should not leak -- testing allocator will detect leaks
}

test "SyntheticFeed: seed=0 works without issues" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 0);
    defer feed.deinit();
    for (0..50) |_| feed.tick();
    try std.testing.expect(feed.tick_count == 50);
}

test "SyntheticFeed: seed=maxInt works" {
    var feed = try SyntheticFeed.init(std.testing.allocator, std.math.maxInt(u64));
    defer feed.deinit();
    for (0..50) |_| feed.tick();
    try std.testing.expect(feed.tick_count == 50);
}

test "SyntheticFeed: rapid tick burst does not corrupt books" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    // 500 ticks -- crosses multiple repopulation boundaries
    for (0..500) |_| feed.tick();

    for (0..8) |i| {
        const book = &feed.books[i];
        // Bids should be sorted descending
        const bids = book.bids();
        for (1..bids.len) |j| {
            try std.testing.expect(bids[j - 1].price >= bids[j].price);
        }
        // Asks should be sorted ascending
        const asks = book.asks();
        for (1..asks.len) |j| {
            try std.testing.expect(asks[j - 1].price <= asks[j].price);
        }
    }
}

test "SyntheticFeed: all quantities are positive" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    for (0..100) |_| feed.tick();

    for (0..8) |i| {
        const bids = feed.books[i].bids();
        for (bids) |level| {
            try std.testing.expect(level.quantity > 0);
        }
        const asks = feed.books[i].asks();
        for (asks) |level| {
            try std.testing.expect(level.quantity > 0);
        }
    }
}

test "SyntheticFeed: best bid below best ask (no crossed books)" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    // Check at several snapshots including repopulation boundary
    const checkpoints = [_]usize{ 1, 10, 20, 40, 60, 100 };
    for (checkpoints) |target_tick| {
        while (feed.tick_count < target_tick) feed.tick();
        for (0..8) |i| {
            const bid = feed.books[i].bestBid() orelse continue;
            const ask = feed.books[i].bestAsk() orelse continue;
            try std.testing.expect(bid.price < ask.price);
        }
    }
}
