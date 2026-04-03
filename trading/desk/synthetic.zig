// Synthetic market data feed for Trading Desk TUI demo.
// Generates random-walk price movements for 2 instruments.

const std = @import("std");
const L2Book = @import("orderbook").L2Book;
const Level = @import("orderbook").Level;
const Side = @import("orderbook").Side;

const DEPTH = 20;

pub const SyntheticFeed = struct {
    allocator: std.mem.Allocator,
    books: [2]L2Book,
    rng: std.Random.DefaultPrng,
    tick_count: u64,

    // Base prices: BTC ~50000.00, ETH ~3000.00
    // Using 8 decimal places: multiply by 100_000_000
    // BTC: 50000 * 100_000_000 = 5_000_000_000_000
    // ETH: 3000 * 100_000_000 = 300_000_000_000
    base_prices: [2]i64,

    pub fn init(allocator: std.mem.Allocator, seed: u64) !SyntheticFeed {
        var rng = std.Random.DefaultPrng.init(seed);
        const rand = rng.random();

        const btc_base: i64 = 5_000_000_000_000;
        const eth_base: i64 = 300_000_000_000;
        const bases = [2]i64{ btc_base, eth_base };

        var books: [2]L2Book = undefined;
        for (&books, 0..) |*book, i| {
            book.* = try L2Book.init(allocator, DEPTH);
            populateBook(book, bases[i], rand);
        }

        return SyntheticFeed{
            .allocator = allocator,
            .books = books,
            .rng = rng,
            .tick_count = 0,
            .base_prices = bases,
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
        // Tick size: 1000 (= 0.000010 in 8-decimal)
        const ts: i64 = 100_000; // tick size ~$0.001 for BTC-scale

        var bid_levels: [DEPTH]Level = undefined;
        var ask_levels: [DEPTH]Level = undefined;

        for (0..DEPTH) |i| {
            const offset: i64 = @intCast(i + 1);
            const qty: i64 = @intCast(rand.intRangeAtMost(u64, 100_000, 10_000_000));
            bid_levels[i] = Level{ .price = base_price - offset * ts, .quantity = qty };
            ask_levels[i] = Level{ .price = base_price + offset * ts, .quantity = qty };
        }

        book.applySnapshot(&bid_levels, &ask_levels);
    }

    /// Advance one tick: update book prices randomly.
    pub fn tick(self: *SyntheticFeed) void {
        self.tick_count += 1;
        const rand = self.rng.random();
        const tick_size: i64 = 100_000;

        for (&self.books, 0..) |*book, i| {
            // Random walk the base price
            const delta: i64 = if (rand.boolean()) tick_size else -tick_size;
            self.base_prices[i] += delta;
            const base = self.base_prices[i];

            // Occasionally repopulate a few levels
            const num_updates: usize = rand.intRangeAtMost(usize, 1, 3);
            for (0..num_updates) |_| {
                const level_idx: i64 = @intCast(rand.intRangeAtMost(u64, 1, DEPTH - 1));
                const qty: i64 = @intCast(rand.intRangeAtMost(u64, 100_000, 10_000_000));
                const bid_price = base - level_idx * tick_size;
                const ask_price = base + level_idx * tick_size;
                book.applyUpdate(.bid, bid_price, qty);
                book.applyUpdate(.ask, ask_price, qty);
            }

            // Every 20 ticks, repopulate entire book (big move)
            if (self.tick_count % 20 == 0) {
                populateBook(book, base, rand);
            }
        }
    }

    /// Get const pointer to book at index.
    pub fn getBook(self: *const SyntheticFeed, index: usize) *const L2Book {
        return &self.books[index];
    }
};

test "synthetic_feed_init" {
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();
    try std.testing.expect(feed.books[0].bids_len >= 5);
    try std.testing.expect(feed.books[0].asks_len >= 5);
    feed.tick();
    try std.testing.expect(feed.tick_count == 1);
}
