// Synthetic market data feed for Trading Desk TUI demo.
// Generates correlated GBM + mean-reversion price movements for 8 instruments.

const std = @import("std");
const L2Book = @import("orderbook").L2Book;
const Level = @import("orderbook").Level;
const Side = @import("orderbook").Side;

const DEPTH = 20;

pub const InstrumentConfig = struct {
    symbol: [32]u8,
    symbol_len: u8,
    base_price: i64,
    volatility: i64, // tick-size multiplier for random step amplitude
    mean_reversion_strength: i64, // pull-back factor (0 = pure random walk)
    drift: i64, // per-tick drift component
    correlation_group: u8, // spot/perp pairs share a group
};

fn makeConfig(comptime sym: []const u8, base: i64, vol: i64, mr: i64, drift: i64, group: u8) InstrumentConfig {
    var cfg = InstrumentConfig{
        .symbol = [_]u8{0} ** 32,
        .symbol_len = @intCast(sym.len),
        .base_price = base,
        .volatility = vol,
        .mean_reversion_strength = mr,
        .drift = drift,
        .correlation_group = group,
    };
    @memcpy(cfg.symbol[0..sym.len], sym);
    return cfg;
}

// 8 instrument configurations
// Group 0 (BTC): indices 0, 1, 2
// Group 1 (ETH): indices 3, 4, 5
// Group 2 (SOL): index 6
// Group 3 (ADA): index 7
const INSTRUMENT_CONFIGS = [8]InstrumentConfig{
    makeConfig("BTC-USD", 5_000_000_000_000, 500_000, 100_000, 0, 0),
    makeConfig("BTC-USD-PERP", 5_002_000_000_000, 50_000, 50_000, 0, 0),
    makeConfig("BTC-USD-20231229", 5_010_000_000_000, 50_000, 30_000, 0, 0),
    makeConfig("ETH-USD", 300_000_000_000, 300_000, 80_000, 0, 1),
    makeConfig("ETH-USD-PERP", 300_100_000_000, 30_000, 40_000, 0, 1),
    makeConfig("SOL-USD-PERP", 10_000_000_000, 20_000, 40_000, 0, 1),
    makeConfig("SOL-USD", 10_000_000_000, 200_000, 60_000, 0, 2),
    makeConfig("ADA-USD", 50_000_000, 5_000, 20_000, 0, 3),
};

// Base volatility used to normalize group steps
const BASE_VOLATILITY: i64 = 100_000;

pub const SyntheticFeed = struct {
    allocator: std.mem.Allocator,
    books: [8]L2Book,
    rng: std.Random.DefaultPrng,
    tick_count: u64,
    instruments: [8]InstrumentConfig,
    base_prices: [8]i64,

    pub fn init(allocator: std.mem.Allocator, seed: u64) !SyntheticFeed {
        var rng = std.Random.DefaultPrng.init(seed);
        const rand = rng.random();

        const instruments = INSTRUMENT_CONFIGS;
        var base_prices: [8]i64 = undefined;
        for (0..8) |i| {
            base_prices[i] = instruments[i].base_price;
        }

        var books: [8]L2Book = undefined;
        var initialized: usize = 0;
        errdefer {
            for (0..initialized) |i| {
                books[i].deinit();
            }
        }
        for (0..8) |i| {
            books[i] = try L2Book.init(allocator, DEPTH);
            initialized += 1;
            populateBook(&books[i], base_prices[i], rand);
        }

        return SyntheticFeed{
            .allocator = allocator,
            .books = books,
            .rng = rng,
            .tick_count = 0,
            .instruments = instruments,
            .base_prices = base_prices,
        };
    }

    pub fn deinit(self: *SyntheticFeed) void {
        for (&self.books) |*book| {
            book.allocator.free(book.bids_buf);
            book.allocator.free(book.asks_buf);
        }
    }

    /// Populate book with initial levels around base price.
    fn populateBook(book: *L2Book, base_price: i64, rand: std.Random) void {
        const ts: i64 = 100_000; // tick size

        var bid_levels: [DEPTH]Level = undefined;
        var ask_levels: [DEPTH]Level = undefined;

        for (0..DEPTH) |i| {
            const offset: i64 = @intCast(i + 1);
            const qty: i64 = @intCast(rand.intRangeAtMost(u64, 10_000_000, 1_000_000_000));
            bid_levels[i] = Level{ .price = base_price - offset * ts, .quantity = qty };
            ask_levels[i] = Level{ .price = base_price + offset * ts, .quantity = qty };
        }

        book.applySnapshot(&bid_levels, &ask_levels);
    }

    /// Advance one tick: update all 8 instruments using correlated GBM + mean reversion.
    pub fn tick(self: *SyntheticFeed) void {
        self.tick_count += 1;
        const rand = self.rng.random();
        const tick_size: i64 = 100_000;

        // Generate one group step per correlation group (groups 0–3)
        var group_steps: [4]i64 = undefined;
        for (&group_steps) |*step| {
            step.* = if (rand.boolean()) tick_size else -tick_size;
        }

        for (&self.books, 0..) |*book, i| {
            const cfg = &self.instruments[i];
            const group_step = group_steps[cfg.correlation_group];

            // Combine group step (scaled by volatility) with independent noise
            const group_contribution = @divTrunc(group_step * cfg.volatility, BASE_VOLATILITY);
            const noise: i64 = if (rand.boolean()) tick_size / 10 else -(tick_size / 10);
            const delta = group_contribution + noise;

            // Apply mean reversion: pull toward base_price
            const current_price = self.base_prices[i];
            const pull = @divTrunc(cfg.mean_reversion_strength * (cfg.base_price - current_price), cfg.base_price);

            // Compute new price
            var new_price = current_price + delta + pull + cfg.drift;

            // Clamp to prevent negative prices
            const min_price = @divTrunc(cfg.base_price, 10);
            new_price = @max(new_price, min_price);

            self.base_prices[i] = new_price;
            const base = new_price;

            // Update 1–3 random levels
            const num_updates: usize = rand.intRangeAtMost(usize, 1, 3);
            for (0..num_updates) |_| {
                const level_idx: i64 = @intCast(rand.intRangeAtMost(u64, 1, DEPTH - 1));
                const qty: i64 = @intCast(rand.intRangeAtMost(u64, 10_000_000, 1_000_000_000));
                const bid_price = base - level_idx * tick_size;
                const ask_price = base + level_idx * tick_size;
                book.applyUpdate(.bid, bid_price, qty);
                book.applyUpdate(.ask, ask_price, qty);
            }

            // Every 20 ticks, repopulate entire book
            if (self.tick_count % 20 == 0) {
                populateBook(book, base, rand);
            }
        }
    }

    /// Compute funding rate: k * (perp_mid - spot_mid) * SCALE / spot_mid
    /// Returns result in basis points (scaled i64), clamped to ±1%.
    pub fn computeFundingRate(spot_mid: i64, perp_mid: i64) i64 {
        if (spot_mid == 0) return 0;
        const k: i64 = 100;
        const scale: i64 = 10_000; // basis points scale
        const raw = @divTrunc(k * (perp_mid - spot_mid) * scale, spot_mid);
        // Clamp to ±1% = ±100 basis points
        const max_rate: i64 = 100;
        if (raw > max_rate) return max_rate;
        if (raw < -max_rate) return -max_rate;
        return raw;
    }

    /// Get const pointer to book at index (0..7).
    pub fn getBook(self: *const SyntheticFeed, index: usize) *const L2Book {
        return &self.books[index];
    }

    /// Get symbol slice for instrument at index.
    pub fn getSymbol(self: *const SyntheticFeed, index: usize) []const u8 {
        const cfg = &self.instruments[index];
        return cfg.symbol[0..cfg.symbol_len];
    }
};

test "synthetic_feed_init" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();
    try std.testing.expect(feed.books[0].bids_len >= 5);
    try std.testing.expect(feed.books[0].asks_len >= 5);
    feed.tick();
    try std.testing.expect(feed.tick_count == 1);
    // Verify all 8 books are initialized
    for (0..8) |i| {
        try std.testing.expect(feed.books[i].bids_len >= 1);
        try std.testing.expect(feed.books[i].asks_len >= 1);
    }
}

test "synthetic_feed_8_instrument_correlation" {
    // Seed=42, run 100 ticks, verify BTC spot (idx 0) and BTC-USD-PERP (idx 1)
    // mid prices remain within 2% of each other.
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();

    for (0..100) |_| {
        feed.tick();
    }

    const btc_spot = feed.getBook(0);
    const btc_perp = feed.getBook(1);

    const spot_mid = btc_spot.midPrice() orelse return error.NoMidPrice;
    const perp_mid = btc_perp.midPrice() orelse return error.NoMidPrice;

    // Both should be positive
    try std.testing.expect(spot_mid > 0);
    try std.testing.expect(perp_mid > 0);

    // Prices should be within 2% of each other (200 bps)
    // |perp - spot| / spot < 0.02
    const diff = @abs(perp_mid - spot_mid);
    const threshold = @divTrunc(spot_mid * 2, 100);
    try std.testing.expect(diff < threshold);
}
