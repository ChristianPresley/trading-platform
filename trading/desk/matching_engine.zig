// Matching engine for Trading Desk demo mode.
// Fills orders against synthetic L2Books (market orders at BBO, limit orders rested or crossing).

const std = @import("std");
const L2Book = @import("orderbook").L2Book;
const Side = @import("oms").Side;
const OrderType = @import("oms").OrderType;
const FillInfo = @import("oms").FillInfo;

pub const RestingOrder = struct {
    order_id: u64,
    instrument_idx: u8,
    side: Side,
    price: i64,
    remaining_qty: i64,
    active: bool,
};

pub const FillResult = struct {
    fills: [16]FillInfo,
    fill_count: u8,
    rested: bool,
    rested_qty: i64,
};

pub const RestingFill = struct {
    order_id: u64,
    fill_qty: i64,
    fill_price: i64,
};

pub const RestingFillResult = struct {
    fills: [64]RestingFill,
    fill_count: u8,
};

pub const MatchingEngine = struct {
    resting_orders: [256]RestingOrder,
    resting_count: usize,

    pub fn init() MatchingEngine {
        return MatchingEngine{
            .resting_orders = std.mem.zeroes([256]RestingOrder),
            .resting_count = 0,
        };
    }

    /// Process a new order against the book.
    /// Market orders fill immediately at BBO, walking levels if needed.
    /// Limit orders crossing the BBO fill the crossing portion, rest the remainder.
    /// Limit orders not crossing rest entirely.
    pub fn processOrder(
        self: *MatchingEngine,
        order_id: u64,
        instrument_idx: u8,
        side: Side,
        price: ?i64,
        quantity: i64,
        order_type: OrderType,
        book: *const L2Book,
    ) FillResult {
        var result = FillResult{
            .fills = std.mem.zeroes([16]FillInfo),
            .fill_count = 0,
            .rested = false,
            .rested_qty = 0,
        };

        var remaining = quantity;

        if (order_type == .market) {
            // Fill at BBO, walk levels as needed
            remaining = self.fillAgainstBook(&result, side, remaining, book);
            // Any unfilled qty (empty book): fill at a fallback price
            if (remaining > 0) {
                // Use best available price or base fallback
                const fallback_price = self.getFallbackPrice(side, book);
                if (result.fill_count < 16) {
                    result.fills[result.fill_count] = FillInfo{
                        .fill_qty = remaining,
                        .fill_price = fallback_price,
                    };
                    result.fill_count += 1;
                }
            }
        } else if (order_type == .limit) {
            const limit_price = price orelse return result;

            // Determine if this limit order crosses the BBO
            const crosses = switch (side) {
                .buy => blk: {
                    const best_ask = book.bestAsk() orelse break :blk false;
                    break :blk limit_price >= best_ask.price;
                },
                .sell => blk: {
                    const best_bid = book.bestBid() orelse break :blk false;
                    break :blk limit_price <= best_bid.price;
                },
            };

            if (crosses) {
                // Fill the crossing portion
                remaining = self.fillAgainstBook(&result, side, remaining, book);
            }

            // Rest any remaining quantity
            if (remaining > 0) {
                self.addRestingOrder(order_id, instrument_idx, side, limit_price, remaining);
                result.rested = true;
                result.rested_qty = remaining;
            }
        }

        return result;
    }

    /// Check all resting orders against current books; fill those that have crossed.
    pub fn checkRestingOrders(self: *MatchingEngine, books: *const [8]L2Book) RestingFillResult {
        var result = RestingFillResult{
            .fills = std.mem.zeroes([64]RestingFill),
            .fill_count = 0,
        };

        for (0..self.resting_count) |i| {
            const ro = &self.resting_orders[i];
            if (!ro.active) continue;
            if (ro.instrument_idx >= 8) continue;

            const book = &books[ro.instrument_idx];

            const should_fill = switch (ro.side) {
                .buy => blk: {
                    const ask = book.bestAsk() orelse break :blk false;
                    break :blk ask.price <= ro.price;
                },
                .sell => blk: {
                    const bid = book.bestBid() orelse break :blk false;
                    break :blk bid.price >= ro.price;
                },
            };

            if (should_fill) {
                const fill_price = switch (ro.side) {
                    .buy => if (book.bestAsk()) |a| a.price else ro.price,
                    .sell => if (book.bestBid()) |b| b.price else ro.price,
                };

                if (result.fill_count < 64) {
                    result.fills[result.fill_count] = RestingFill{
                        .order_id = ro.order_id,
                        .fill_qty = ro.remaining_qty,
                        .fill_price = fill_price,
                    };
                    result.fill_count += 1;
                }
                ro.active = false;
            }
        }

        return result;
    }

    // --- Private helpers ---

    /// Walk book levels and fill as much as possible. Returns remaining unfilled quantity.
    fn fillAgainstBook(self: *MatchingEngine, result: *FillResult, side: Side, quantity: i64, book: *const L2Book) i64 {
        _ = self;
        var remaining = quantity;

        const levels = switch (side) {
            .buy => book.asks(), // Buy order consumes asks
            .sell => book.bids(), // Sell order consumes bids
        };

        for (levels) |level| {
            if (remaining <= 0) break;
            if (result.fill_count >= 16) break;

            const fill_qty = @min(remaining, level.quantity);
            result.fills[result.fill_count] = FillInfo{
                .fill_qty = fill_qty,
                .fill_price = level.price,
            };
            result.fill_count += 1;
            remaining -= fill_qty;
        }

        return remaining;
    }

    fn getFallbackPrice(self: *MatchingEngine, side: Side, book: *const L2Book) i64 {
        _ = self;
        return switch (side) {
            .buy => if (book.bestAsk()) |a| a.price else if (book.bestBid()) |b| b.price else 0,
            .sell => if (book.bestBid()) |b| b.price else if (book.bestAsk()) |a| a.price else 0,
        };
    }

    fn addRestingOrder(
        self: *MatchingEngine,
        order_id: u64,
        instrument_idx: u8,
        side: Side,
        price: i64,
        qty: i64,
    ) void {
        // Find a free slot (inactive)
        for (0..self.resting_count) |i| {
            if (!self.resting_orders[i].active) {
                self.resting_orders[i] = RestingOrder{
                    .order_id = order_id,
                    .instrument_idx = instrument_idx,
                    .side = side,
                    .price = price,
                    .remaining_qty = qty,
                    .active = true,
                };
                return;
            }
        }
        // Append if under capacity
        if (self.resting_count < 256) {
            self.resting_orders[self.resting_count] = RestingOrder{
                .order_id = order_id,
                .instrument_idx = instrument_idx,
                .side = side,
                .price = price,
                .remaining_qty = qty,
                .active = true,
            };
            self.resting_count += 1;
        }
    }
};

test "matching_engine_market_buy_fills_at_ask" {
    const orderbook_mod = @import("orderbook");
    var book = try orderbook_mod.L2Book.init(std.testing.allocator, 5);
    defer book.deinit();

    const bids = [_]orderbook_mod.Level{
        .{ .price = 49_900_000, .quantity = 100 },
    };
    const asks = [_]orderbook_mod.Level{
        .{ .price = 50_000_000, .quantity = 100 },
        .{ .price = 50_100_000, .quantity = 50 },
    };
    book.applySnapshot(&bids, &asks);

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .buy, null, 80, .market, &book);

    // Should fill at the best ask price
    try std.testing.expect(result.fill_count >= 1);
    try std.testing.expect(result.fills[0].fill_price == 50_000_000);
    try std.testing.expect(result.fills[0].fill_qty == 80);
}

test "matching_engine_market_sell_fills_at_bid" {
    const orderbook_mod = @import("orderbook");
    var book = try orderbook_mod.L2Book.init(std.testing.allocator, 5);
    defer book.deinit();

    const bids = [_]orderbook_mod.Level{
        .{ .price = 49_900_000, .quantity = 100 },
    };
    const asks = [_]orderbook_mod.Level{
        .{ .price = 50_000_000, .quantity = 100 },
    };
    book.applySnapshot(&bids, &asks);

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .sell, null, 50, .market, &book);

    // Should fill at best bid price
    try std.testing.expect(result.fill_count >= 1);
    try std.testing.expect(result.fills[0].fill_price == 49_900_000);
    try std.testing.expect(result.fills[0].fill_qty == 50);
}

test "matching_engine_limit_rests_then_fills" {
    const orderbook_mod = @import("orderbook");
    var book = try orderbook_mod.L2Book.init(std.testing.allocator, 5);
    defer book.deinit();

    const bids = [_]orderbook_mod.Level{
        .{ .price = 49_500_000, .quantity = 100 },
    };
    const asks = [_]orderbook_mod.Level{
        .{ .price = 50_500_000, .quantity = 100 },
    };
    book.applySnapshot(&bids, &asks);

    var engine = MatchingEngine.init();

    // Submit a limit buy at 49_700_000 — below current ask, should rest
    const result = engine.processOrder(1, 0, .buy, 49_700_000, 50, .limit, &book);
    try std.testing.expect(result.rested);
    try std.testing.expect(result.rested_qty == 50);
    try std.testing.expect(result.fill_count == 0);

    // Now update book so ask drops to 49_600_000 (below our limit of 49_700_000)
    book.applyUpdate(.ask, 49_600_000, 100);

    // Create a 1-book array and check resting orders
    var books: [8]orderbook_mod.L2Book = undefined;
    books[0] = book;
    // Init the other 7 books as empty
    for (1..8) |i| {
        books[i] = try orderbook_mod.L2Book.init(std.testing.allocator, 1);
    }
    defer for (1..8) |i| books[i].deinit();

    const resting_result = engine.checkRestingOrders(&books);
    try std.testing.expect(resting_result.fill_count >= 1);
    try std.testing.expect(resting_result.fills[0].order_id == 1);
}

test "matching_engine_partial_fill" {
    const orderbook_mod = @import("orderbook");
    var book = try orderbook_mod.L2Book.init(std.testing.allocator, 5);
    defer book.deinit();

    const bids = [_]orderbook_mod.Level{
        .{ .price = 49_900_000, .quantity = 30 }, // only 30 available
    };
    const asks = [_]orderbook_mod.Level{
        .{ .price = 50_000_000, .quantity = 30 }, // only 30 available
    };
    book.applySnapshot(&bids, &asks);

    var engine = MatchingEngine.init();

    // Try to buy 100 but only 30 + fallback available
    const result = engine.processOrder(1, 0, .buy, null, 100, .market, &book);
    // First fill should be 30 at 50_000_000, remainder filled at fallback
    try std.testing.expect(result.fill_count >= 1);
    var total_filled: i64 = 0;
    for (0..result.fill_count) |i| {
        total_filled += result.fills[i].fill_qty;
    }
    try std.testing.expect(total_filled == 100);
}
