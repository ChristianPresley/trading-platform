// L2 order book (market-by-price)
// Bids sorted descending, asks sorted ascending.
// BBO is O(1): index [0] of each sorted side.
// Fixed-point prices (i64 — satoshis/cents).

const std = @import("std");

pub const Side = enum { bid, ask };

pub const Level = struct {
    price: i64,
    quantity: i64,
};

pub const L2Book = struct {
    allocator: std.mem.Allocator,
    bids_buf: []Level,
    asks_buf: []Level,
    bids_len: usize,
    asks_len: usize,
    depth: usize,

    /// Pre-allocates sorted arrays for bids/asks up to `depth` levels.
    pub fn init(allocator: std.mem.Allocator, depth: usize) !L2Book {
        const bids_buf = try allocator.alloc(Level, depth);
        const asks_buf = try allocator.alloc(Level, depth);
        return L2Book{
            .allocator = allocator,
            .bids_buf = bids_buf,
            .asks_buf = asks_buf,
            .bids_len = 0,
            .asks_len = 0,
            .depth = depth,
        };
    }

    /// Replaces the entire book with the given snapshot.
    /// Bids are sorted descending, asks ascending.
    pub fn applySnapshot(self: *L2Book, bid_levels: []const Level, ask_levels: []const Level) void {
        // Copy bids
        const bid_count = @min(bid_levels.len, self.depth);
        @memcpy(self.bids_buf[0..bid_count], bid_levels[0..bid_count]);
        self.bids_len = bid_count;
        // Sort bids descending
        std.sort.insertion(Level, self.bids_buf[0..self.bids_len], {}, struct {
            fn lessThan(_: void, a: Level, b: Level) bool {
                return a.price > b.price; // descending
            }
        }.lessThan);

        // Copy asks
        const ask_count = @min(ask_levels.len, self.depth);
        @memcpy(self.asks_buf[0..ask_count], ask_levels[0..ask_count]);
        self.asks_len = ask_count;
        // Sort asks ascending
        std.sort.insertion(Level, self.asks_buf[0..self.asks_len], {}, struct {
            fn lessThan(_: void, a: Level, b: Level) bool {
                return a.price < b.price; // ascending
            }
        }.lessThan);
    }

    /// Apply an incremental update.
    /// qty=0 removes the price level; otherwise upserts.
    pub fn applyUpdate(self: *L2Book, side: Side, price: i64, qty: i64) void {
        if (side == .bid) {
            self.upsertLevel(self.bids_buf, &self.bids_len, price, qty, true);
        } else {
            self.upsertLevel(self.asks_buf, &self.asks_len, price, qty, false);
        }
    }

    fn upsertLevel(self: *L2Book, buf: []Level, len: *usize, price: i64, qty: i64, descending: bool) void {
        // Find existing level
        var found_idx: ?usize = null;
        for (0..len.*) |i| {
            if (buf[i].price == price) {
                found_idx = i;
                break;
            }
        }

        if (qty == 0) {
            // Remove level if found
            if (found_idx) |idx| {
                // Shift remaining elements left
                var i = idx;
                while (i + 1 < len.*) : (i += 1) {
                    buf[i] = buf[i + 1];
                }
                len.* -= 1;
            }
            // If not found, no-op
            return;
        }

        if (found_idx) |idx| {
            // Update existing level
            buf[idx].quantity = qty;
        } else {
            // Insert new level if capacity available
            if (len.* < self.depth) {
                buf[len.*] = Level{ .price = price, .quantity = qty };
                len.* += 1;
                // Re-sort
                if (descending) {
                    std.sort.insertion(Level, buf[0..len.*], {}, struct {
                        fn lessThan(_: void, a: Level, b: Level) bool {
                            return a.price > b.price;
                        }
                    }.lessThan);
                } else {
                    std.sort.insertion(Level, buf[0..len.*], {}, struct {
                        fn lessThan(_: void, a: Level, b: Level) bool {
                            return a.price < b.price;
                        }
                    }.lessThan);
                }
            }
        }
    }

    /// Best bid (highest price). O(1).
    pub fn bestBid(self: *const L2Book) ?Level {
        if (self.bids_len == 0) return null;
        return self.bids_buf[0];
    }

    /// Best ask (lowest price). O(1).
    pub fn bestAsk(self: *const L2Book) ?Level {
        if (self.asks_len == 0) return null;
        return self.asks_buf[0];
    }

    /// Spread = bestAsk.price - bestBid.price.
    pub fn spread(self: *const L2Book) ?i64 {
        const b = self.bestBid() orelse return null;
        const a = self.bestAsk() orelse return null;
        return a.price - b.price;
    }

    /// Mid price = (bestBid.price + bestAsk.price) / 2.
    pub fn midPrice(self: *const L2Book) ?i64 {
        const b = self.bestBid() orelse return null;
        const a = self.bestAsk() orelse return null;
        return @divTrunc(b.price + a.price, 2);
    }

    /// All bid levels sorted descending by price.
    pub fn bids(self: *const L2Book) []const Level {
        return self.bids_buf[0..self.bids_len];
    }

    /// All ask levels sorted ascending by price.
    pub fn asks(self: *const L2Book) []const Level {
        return self.asks_buf[0..self.asks_len];
    }

    pub fn deinit(self: *L2Book) void {
        self.allocator.free(self.bids_buf);
        self.allocator.free(self.asks_buf);
        self.bids_len = 0;
        self.asks_len = 0;
    }
};
