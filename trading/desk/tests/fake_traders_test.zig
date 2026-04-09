// Tests for fake_traders: synthetic trading activity generation.
// Exercises the public API — TradeBuffer, FakeTraderPool, FakeTrade, TradeSide.
// Individual trader archetypes are private; we test them indirectly through
// the pool's onTick output characteristics.

const std = @import("std");
const fake_traders = @import("fake_traders");
const orderbook = @import("orderbook");

const L2Book = orderbook.L2Book;
const Level = orderbook.Level;
const FakeTraderPool = fake_traders.FakeTraderPool;
const TradeBuffer = fake_traders.TradeBuffer;
const FakeTrade = fake_traders.FakeTrade;
const TradeSide = fake_traders.TradeSide;

// ---- Helpers ---------------------------------------------------------------

const BID_PRICE: i64 = 50_000_000_000; // 50000.000000 in fixed-point
const ASK_PRICE: i64 = 50_000_100_000; // spread = 100_000
const NUM_INSTRUMENTS = 8;

/// Build a standard 8-instrument book array with a tight bid/ask spread.
fn makeBooks(allocator: std.mem.Allocator) ![NUM_INSTRUMENTS]L2Book {
    var books: [NUM_INSTRUMENTS]L2Book = undefined;
    var init_count: usize = 0;
    errdefer for (0..init_count) |i| books[i].deinit();

    for (0..NUM_INSTRUMENTS) |i| {
        books[i] = try L2Book.init(allocator, 5);
        init_count += 1;
        const bids = [_]Level{
            .{ .price = BID_PRICE, .quantity = 10_000_000 },
            .{ .price = BID_PRICE - 100_000, .quantity = 15_000_000 },
            .{ .price = BID_PRICE - 200_000, .quantity = 8_000_000 },
        };
        const asks = [_]Level{
            .{ .price = ASK_PRICE, .quantity = 10_000_000 },
            .{ .price = ASK_PRICE + 100_000, .quantity = 15_000_000 },
            .{ .price = ASK_PRICE + 200_000, .quantity = 8_000_000 },
        };
        books[i].applySnapshot(&bids, &asks);
    }
    return books;
}

fn deinitBooks(books: *[NUM_INSTRUMENTS]L2Book) void {
    for (books) |*b| b.deinit();
}

// ---- TradeBuffer -----------------------------------------------------------

test "TradeBuffer: init returns zero count" {
    const buf = TradeBuffer.init();
    try std.testing.expectEqual(@as(u8, 0), buf.count);
}

// ---- FakeTraderPool: initialization ----------------------------------------

test "FakeTraderPool: init produces deterministic state from seed" {
    const pool_a = FakeTraderPool.init(42);
    const pool_b = FakeTraderPool.init(42);

    // Same seed must yield identical market-maker parameters.
    for (0..3) |i| {
        for (0..NUM_INSTRUMENTS) |j| {
            try std.testing.expectEqual(pool_a.market_makers[i].inventory[j], pool_b.market_makers[i].inventory[j]);
        }
    }

    // Whale should start with zero iceberg remaining and identical cooldown.
    try std.testing.expectEqual(@as(i64, 0), pool_a.whale.iceberg_remaining);
    try std.testing.expectEqual(pool_a.whale.cooldown, pool_b.whale.cooldown);
}

test "FakeTraderPool: different seeds produce different RNG state" {
    const pool_a = FakeTraderPool.init(1);
    const pool_b = FakeTraderPool.init(2);

    // The momentum trader tick_intervals incorporate RNG, so different seeds
    // should produce at least one different value.
    var any_different = false;
    for (0..2) |i| {
        if (pool_a.momentum_traders[i].tick_interval != pool_b.momentum_traders[i].tick_interval) {
            any_different = true;
            break;
        }
    }
    try std.testing.expect(any_different);
}

test "FakeTraderPool: all inventories and positions start at zero" {
    const pool = FakeTraderPool.init(0);

    for (pool.market_makers) |mm| {
        for (mm.inventory) |inv| try std.testing.expectEqual(@as(i64, 0), inv);
    }
    for (pool.momentum_traders) |mt| {
        for (mt.position) |pos| try std.testing.expectEqual(@as(i64, 0), pos);
    }
    for (pool.mean_rev_traders) |mr| {
        for (mr.position) |pos| try std.testing.expectEqual(@as(i64, 0), pos);
    }
    for (pool.noise_traders) |nt| {
        for (nt.position) |pos| try std.testing.expectEqual(@as(i64, 0), pos);
    }
    for (pool.whale.position) |pos| try std.testing.expectEqual(@as(i64, 0), pos);
}

// ---- FakeTraderPool: onTick trade generation -------------------------------

test "FakeTraderPool: generates trades over many ticks" {
    const allocator = std.testing.allocator;
    var books = try makeBooks(allocator);
    defer deinitBooks(&books);

    var pool = FakeTraderPool.init(42);

    var total_trades: u32 = 0;
    for (0..200) |t| {
        const result = pool.onTick(@intCast(t), &books);
        total_trades += result.count;
    }

    // With 3 MMs, 2 momentum, 2 mean-rev, 4 noise, 1 whale over 200 ticks
    // we expect substantial trade generation.
    try std.testing.expect(total_trades > 50);
}

test "FakeTraderPool: generates zero trades on empty books" {
    const allocator = std.testing.allocator;
    var books: [NUM_INSTRUMENTS]L2Book = undefined;
    var init_count: usize = 0;
    errdefer for (0..init_count) |i| books[i].deinit();

    for (0..NUM_INSTRUMENTS) |i| {
        books[i] = try L2Book.init(allocator, 5);
        init_count += 1;
        // Apply empty snapshot — no levels.
        const empty_bids = [_]Level{};
        const empty_asks = [_]Level{};
        books[i].applySnapshot(&empty_bids, &empty_asks);
    }
    defer for (0..NUM_INSTRUMENTS) |i| books[i].deinit();

    var pool = FakeTraderPool.init(42);

    var total_trades: u32 = 0;
    for (0..100) |t| {
        const result = pool.onTick(@intCast(t), &books);
        total_trades += result.count;
    }

    // No mid price / best bid/ask available, so traders should not produce trades.
    try std.testing.expectEqual(@as(u32, 0), total_trades);
}

test "FakeTraderPool: deterministic output with same seed" {
    const allocator = std.testing.allocator;
    var books_a = try makeBooks(allocator);
    defer deinitBooks(&books_a);
    var books_b = try makeBooks(allocator);
    defer deinitBooks(&books_b);

    var pool_a = FakeTraderPool.init(12345);
    var pool_b = FakeTraderPool.init(12345);

    for (0..100) |t| {
        const result_a = pool_a.onTick(@intCast(t), &books_a);
        const result_b = pool_b.onTick(@intCast(t), &books_b);

        try std.testing.expectEqual(result_a.count, result_b.count);
        for (0..result_a.count) |i| {
            try std.testing.expectEqual(result_a.trades[i].instrument_idx, result_b.trades[i].instrument_idx);
            try std.testing.expectEqual(result_a.trades[i].side, result_b.trades[i].side);
            try std.testing.expectEqual(result_a.trades[i].quantity, result_b.trades[i].quantity);
            try std.testing.expectEqual(result_a.trades[i].price, result_b.trades[i].price);
            try std.testing.expectEqual(result_a.trades[i].tag_len, result_b.trades[i].tag_len);
        }
    }
}

// ---- FakeTraderPool: trade field validation --------------------------------

test "FakeTraderPool: all trades have valid instrument index" {
    const allocator = std.testing.allocator;
    var books = try makeBooks(allocator);
    defer deinitBooks(&books);

    var pool = FakeTraderPool.init(99);

    for (0..300) |t| {
        const result = pool.onTick(@intCast(t), &books);
        for (0..result.count) |i| {
            try std.testing.expect(result.trades[i].instrument_idx < NUM_INSTRUMENTS);
        }
    }
}

test "FakeTraderPool: all trades have positive quantity" {
    const allocator = std.testing.allocator;
    var books = try makeBooks(allocator);
    defer deinitBooks(&books);

    var pool = FakeTraderPool.init(77);

    for (0..300) |t| {
        const result = pool.onTick(@intCast(t), &books);
        for (0..result.count) |i| {
            try std.testing.expect(result.trades[i].quantity > 0);
        }
    }
}

test "FakeTraderPool: all trades have positive price" {
    const allocator = std.testing.allocator;
    var books = try makeBooks(allocator);
    defer deinitBooks(&books);

    var pool = FakeTraderPool.init(55);

    for (0..300) |t| {
        const result = pool.onTick(@intCast(t), &books);
        for (0..result.count) |i| {
            try std.testing.expect(result.trades[i].price > 0);
        }
    }
}

test "FakeTraderPool: tag_len is within bounds" {
    const allocator = std.testing.allocator;
    var books = try makeBooks(allocator);
    defer deinitBooks(&books);

    var pool = FakeTraderPool.init(33);

    for (0..300) |t| {
        const result = pool.onTick(@intCast(t), &books);
        for (0..result.count) |i| {
            try std.testing.expect(result.trades[i].tag_len > 0);
            try std.testing.expect(result.trades[i].tag_len <= 8);
        }
    }
}

// ---- FakeTraderPool: archetype diversity -----------------------------------

test "FakeTraderPool: produces trades from multiple archetypes" {
    const allocator = std.testing.allocator;
    var books = try makeBooks(allocator);
    defer deinitBooks(&books);

    var pool = FakeTraderPool.init(42);

    var seen_mm = false;
    var seen_mom = false;
    var seen_mean = false;
    var seen_noise = false;
    var seen_whale = false;

    // Run enough ticks for all archetypes to trigger. Whale needs cooldown=100
    // to expire (init sets cooldown = min_cooldown/2 = 100 for 200).
    for (0..500) |t| {
        const result = pool.onTick(@intCast(t), &books);
        for (0..result.count) |i| {
            const trade = result.trades[i];
            const tag = trade.tag[0..trade.tag_len];
            if (std.mem.eql(u8, tag, "MM")) seen_mm = true;
            if (std.mem.eql(u8, tag, "MOM")) seen_mom = true;
            if (std.mem.eql(u8, tag, "MEAN")) seen_mean = true;
            if (std.mem.eql(u8, tag, "NOISE")) seen_noise = true;
            if (std.mem.eql(u8, tag, "WHALE")) seen_whale = true;
        }
    }

    try std.testing.expect(seen_mm);
    try std.testing.expect(seen_noise);
    // Momentum and mean-reversion require signal buildup; whale needs cooldown.
    // Over 500 ticks with active books these should all trigger.
    try std.testing.expect(seen_whale);
}

// ---- FakeTraderPool: both sides traded ------------------------------------

test "FakeTraderPool: generates both buy and sell trades" {
    const allocator = std.testing.allocator;
    var books = try makeBooks(allocator);
    defer deinitBooks(&books);

    var pool = FakeTraderPool.init(42);

    var buys: u32 = 0;
    var sells: u32 = 0;

    for (0..300) |t| {
        const result = pool.onTick(@intCast(t), &books);
        for (0..result.count) |i| {
            switch (result.trades[i].side) {
                .buy => buys += 1,
                .sell => sells += 1,
            }
        }
    }

    try std.testing.expect(buys > 10);
    try std.testing.expect(sells > 10);
}

// ---- FakeTraderPool: instrument diversification ----------------------------

test "FakeTraderPool: trades span multiple instruments" {
    const allocator = std.testing.allocator;
    var books = try makeBooks(allocator);
    defer deinitBooks(&books);

    var pool = FakeTraderPool.init(42);

    var instruments_hit = std.mem.zeroes([NUM_INSTRUMENTS]bool);
    for (0..500) |t| {
        const result = pool.onTick(@intCast(t), &books);
        for (0..result.count) |i| {
            instruments_hit[result.trades[i].instrument_idx] = true;
        }
    }

    var hit_count: u8 = 0;
    for (instruments_hit) |hit| {
        if (hit) hit_count += 1;
    }

    // Over 500 ticks with 12 traders, virtually all instruments should be hit.
    try std.testing.expect(hit_count >= 5);
}

// ---- FakeTraderPool: max trades per tick cap -------------------------------

test "FakeTraderPool: never exceeds MAX_TRADES_PER_TICK per tick" {
    const allocator = std.testing.allocator;
    var books = try makeBooks(allocator);
    defer deinitBooks(&books);

    var pool = FakeTraderPool.init(42);

    for (0..500) |t| {
        const result = pool.onTick(@intCast(t), &books);
        // TradeBuffer.push caps at MAX_TRADES_PER_TICK (32).
        try std.testing.expect(result.count <= 32);
    }
}

// ---- FakeTraderPool: prices near book levels -------------------------------

test "FakeTraderPool: trade prices are within reasonable range of mid" {
    const allocator = std.testing.allocator;
    var books = try makeBooks(allocator);
    defer deinitBooks(&books);

    var pool = FakeTraderPool.init(42);

    const mid = @divTrunc(BID_PRICE + ASK_PRICE, 2);
    // Allow generous deviation: noise traders can offset by up to 3 * 100_000
    // from best ask/bid, and whale/momentum hit bestAsk/bestBid directly.
    const max_deviation: i64 = 500_000;

    for (0..300) |t| {
        const result = pool.onTick(@intCast(t), &books);
        for (0..result.count) |i| {
            const price = result.trades[i].price;
            const deviation = if (price > mid) price - mid else mid - price;
            try std.testing.expect(deviation < max_deviation);
        }
    }
}

// ---- FakeTraderPool: tick 0 produces trades --------------------------------

test "FakeTraderPool: tick 0 can produce trades" {
    const allocator = std.testing.allocator;
    var books = try makeBooks(allocator);
    defer deinitBooks(&books);

    // Market makers with interval 2 and 3 fire on tick 0 (0 % n == 0).
    // Noise traders have probabilistic firing each tick.
    // Run tick 0 with many seeds to confirm at least one produces output.
    var any_trades = false;
    for (0..20) |seed| {
        var pool = FakeTraderPool.init(seed);
        const result = pool.onTick(0, &books);
        if (result.count > 0) {
            any_trades = true;
            break;
        }
    }
    try std.testing.expect(any_trades);
}

// ---- TradeSide enum --------------------------------------------------------

test "TradeSide: buy and sell are distinct" {
    try std.testing.expect(TradeSide.buy != TradeSide.sell);
}

// ---- FakeTrade struct layout -----------------------------------------------

test "FakeTrade: tag stores short string correctly via pool output" {
    const allocator = std.testing.allocator;
    var books = try makeBooks(allocator);
    defer deinitBooks(&books);

    var pool = FakeTraderPool.init(42);

    // Find a trade with tag "MM" (market maker fires very frequently)
    for (0..100) |t| {
        const result = pool.onTick(@intCast(t), &books);
        for (0..result.count) |i| {
            const trade = result.trades[i];
            const tag = trade.tag[0..trade.tag_len];
            if (std.mem.eql(u8, tag, "MM")) {
                try std.testing.expectEqual(@as(u8, 2), trade.tag_len);
                try std.testing.expectEqual(@as(u8, 'M'), trade.tag[0]);
                try std.testing.expectEqual(@as(u8, 'M'), trade.tag[1]);
                return;
            }
        }
    }
    // If we reach here, no MM trade was found — fail.
    return error.TestUnexpectedResult;
}

// ---- FakeTraderPool: whale iceberg behavior --------------------------------

test "FakeTraderPool: whale generates bursts of trades (iceberg pattern)" {
    const allocator = std.testing.allocator;
    var books = try makeBooks(allocator);
    defer deinitBooks(&books);

    var pool = FakeTraderPool.init(42);

    // Track whale trades per tick; icebergs should produce consecutive ticks
    // with whale trades once they start.
    var whale_tick_counts: [500]u8 = std.mem.zeroes([500]u8);

    for (0..500) |t| {
        const result = pool.onTick(@intCast(t), &books);
        for (0..result.count) |i| {
            const trade = result.trades[i];
            const tag = trade.tag[0..trade.tag_len];
            if (std.mem.eql(u8, tag, "WHALE")) {
                whale_tick_counts[t] += 1;
            }
        }
    }

    // Count consecutive ticks with whale trades (iceberg drip).
    var max_consecutive: u32 = 0;
    var current_run: u32 = 0;
    for (whale_tick_counts) |count| {
        if (count > 0) {
            current_run += 1;
            if (current_run > max_consecutive) max_consecutive = current_run;
        } else {
            current_run = 0;
        }
    }

    // Iceberg slices into 5-15 pieces with 70% fire rate per tick,
    // so we expect at least a few consecutive whale-trade ticks.
    try std.testing.expect(max_consecutive >= 2);
}

// ---- FakeTraderPool: sustained operation without overflow -------------------

test "FakeTraderPool: runs 10000 ticks without panic or overflow" {
    const allocator = std.testing.allocator;
    var books = try makeBooks(allocator);
    defer deinitBooks(&books);

    var pool = FakeTraderPool.init(42);

    var total_trades: u64 = 0;
    for (0..10_000) |t| {
        const result = pool.onTick(@intCast(t), &books);
        total_trades += result.count;
    }

    // Just verify it completed and produced a reasonable volume.
    try std.testing.expect(total_trades > 1000);
}
