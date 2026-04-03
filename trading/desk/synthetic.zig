const std = @import("std");
const orderbook = @import("orderbook");
const L2Book = orderbook.L2Book;
const Level = orderbook.Level;

pub const SyntheticFeed = struct {
    books: [2]L2Book,
    base_prices: [2]i64,
    rng: std.Random.DefaultPrng,
    tick_count: u64,

    /// Instrument names (fixed for demo)
    pub const instruments = [_][]const u8{ "BTC-USD", "ETH-USD" };

    pub fn init(allocator: std.mem.Allocator, seed: u64) !SyntheticFeed {
        var books: [2]L2Book = undefined;
        books[0] = try L2Book.init(allocator, 20);
        errdefer books[0].deinit();
        books[1] = try L2Book.init(allocator, 20);
        errdefer books[1].deinit();

        var feed = SyntheticFeed{
            .books = books,
            .base_prices = .{ 5_000_000_000_000, 300_000_000_000 }, // BTC ~50000, ETH ~3000 (8 decimal places)
            .rng = std.Random.DefaultPrng.init(seed),
            .tick_count = 0,
        };

        // Initialize with snapshot
        feed.initSnapshot(0);
        feed.initSnapshot(1);

        return feed;
    }

    pub fn deinit(self: *SyntheticFeed) void {
        self.books[0].deinit();
        self.books[1].deinit();
    }

    fn initSnapshot(self: *SyntheticFeed, idx: usize) void {
        const base = self.base_prices[idx];
        const tick_size: i64 = if (idx == 0) 100_000_000 else 10_000_000; // BTC: $1, ETH: $0.10

        var bids: [20]Level = undefined;
        var asks: [20]Level = undefined;

        for (0..20) |i| {
            const offset: i64 = @intCast(i + 1);
            bids[i] = Level{
                .price = base - offset * tick_size,
                .quantity = @intCast(self.rng.random().intRangeAtMost(i64, 100_000_000, 10_000_000_000)),
            };
            asks[i] = Level{
                .price = base + offset * tick_size,
                .quantity = @intCast(self.rng.random().intRangeAtMost(i64, 100_000_000, 10_000_000_000)),
            };
        }

        self.books[idx].applySnapshot(&bids, &asks);
    }

    pub fn tick(self: *SyntheticFeed) void {
        self.tick_count += 1;

        for (0..2) |idx| {
            const tick_size: i64 = if (idx == 0) 100_000_000 else 10_000_000;
            const random = self.rng.random();

            // Update 1-3 random levels per side
            const num_updates = random.intRangeAtMost(usize, 1, 3);
            for (0..num_updates) |_| {
                // Random bid update
                const bid_offset: i64 = @intCast(random.intRangeAtMost(usize, 1, 15));
                const bid_price = self.base_prices[idx] - bid_offset * tick_size;
                const bid_qty: i64 = @intCast(random.intRangeAtMost(i64, 0, 10_000_000_000));
                self.books[idx].applyUpdate(.bid, bid_price, bid_qty);

                // Random ask update
                const ask_offset: i64 = @intCast(random.intRangeAtMost(usize, 1, 15));
                const ask_price = self.base_prices[idx] + ask_offset * tick_size;
                const ask_qty: i64 = @intCast(random.intRangeAtMost(i64, 0, 10_000_000_000));
                self.books[idx].applyUpdate(.ask, ask_price, ask_qty);
            }

            // Occasionally shift base price (1 in 20 ticks)
            if (random.intRangeAtMost(u32, 0, 19) == 0) {
                const shift: i64 = if (random.boolean()) tick_size else -tick_size;
                self.base_prices[idx] += shift;
            }
        }
    }

    pub fn getBook(self: *SyntheticFeed, index: usize) *const L2Book {
        return &self.books[index];
    }
};

test "synthetic_feed_init_deinit" {
    const allocator = std.testing.allocator;
    var feed = try SyntheticFeed.init(allocator, 42);
    defer feed.deinit();

    // Should have levels after init
    const book = feed.getBook(0);
    try std.testing.expect(book.bids_len > 0);
    try std.testing.expect(book.asks_len > 0);

    // Tick should not crash
    feed.tick();
    try std.testing.expect(feed.tick_count == 1);
}
