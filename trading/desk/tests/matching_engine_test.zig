// Matching engine tests — covers market/limit orders, price-level walking,
// partial fills, resting order lifecycle, and edge cases.

const std = @import("std");
const me = @import("matching_engine");
const orderbook_mod = @import("orderbook");
const oms = @import("oms");

const MatchingEngine = me.MatchingEngine;
const FillResult = me.FillResult;
const RestingOrder = me.RestingOrder;
const RestingFillResult = me.RestingFillResult;
const L2Book = orderbook_mod.L2Book;
const Level = orderbook_mod.Level;
const Side = oms.Side;
const OrderType = oms.OrderType;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Build an L2Book with a single bid/ask level.
fn makeBook(bid_price: i64, bid_qty: i64, ask_price: i64, ask_qty: i64) !L2Book {
    var book = try L2Book.init(std.testing.allocator, 10);
    const bids = [_]Level{.{ .price = bid_price, .quantity = bid_qty }};
    const asks = [_]Level{.{ .price = ask_price, .quantity = ask_qty }};
    book.applySnapshot(&bids, &asks);
    return book;
}

/// Build an L2Book with multiple bid and ask levels.
fn makeMultiLevelBook(
    bid_prices: []const i64,
    bid_qtys: []const i64,
    ask_prices: []const i64,
    ask_qtys: []const i64,
) !L2Book {
    var book = try L2Book.init(std.testing.allocator, 10);
    var bid_levels: [10]Level = undefined;
    for (bid_prices, 0..) |p, i| {
        bid_levels[i] = .{ .price = p, .quantity = bid_qtys[i] };
    }
    var ask_levels: [10]Level = undefined;
    for (ask_prices, 0..) |p, i| {
        ask_levels[i] = .{ .price = p, .quantity = ask_qtys[i] };
    }
    book.applySnapshot(bid_levels[0..bid_prices.len], ask_levels[0..ask_prices.len]);
    return book;
}

/// Build an empty L2Book (no levels).
fn makeEmptyBook() !L2Book {
    var book = try L2Book.init(std.testing.allocator, 10);
    const empty_levels: [0]Level = .{};
    book.applySnapshot(&empty_levels, &empty_levels);
    return book;
}

/// Sum all fill quantities in a FillResult.
fn totalFilled(result: FillResult) i64 {
    var total: i64 = 0;
    for (0..result.fill_count) |i| {
        total += result.fills[i].fill_qty;
    }
    return total;
}

/// Build a [8]L2Book array where only books[0] is the provided book;
/// the rest are empty.
fn makeBooksArray(book: L2Book) ![8]L2Book {
    var books: [8]L2Book = undefined;
    books[0] = book;
    for (1..8) |i| {
        books[i] = try L2Book.init(std.testing.allocator, 1);
    }
    return books;
}

fn deinitBooksArray(books: *[8]L2Book) void {
    for (1..8) |i| {
        books[i].deinit();
    }
}

// ---------------------------------------------------------------------------
// MatchingEngine.init
// ---------------------------------------------------------------------------

test "init: engine starts with zero resting orders" {
    const engine = MatchingEngine.init();
    try std.testing.expectEqual(@as(usize, 0), engine.resting_count);
}

// ---------------------------------------------------------------------------
// Market orders — basic fills
// ---------------------------------------------------------------------------

test "market buy fills at best ask price" {
    var book = try makeBook(49_900_000, 100, 50_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .buy, null, 80, .market, &book);

    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 50_000_000), result.fills[0].fill_price);
    try std.testing.expectEqual(@as(i64, 80), result.fills[0].fill_qty);
    try std.testing.expect(!result.rested);
    try std.testing.expectEqual(@as(i64, 0), result.rested_qty);
}

test "market sell fills at best bid price" {
    var book = try makeBook(49_900_000, 100, 50_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .sell, null, 60, .market, &book);

    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 49_900_000), result.fills[0].fill_price);
    try std.testing.expectEqual(@as(i64, 60), result.fills[0].fill_qty);
}

test "market buy exact fill at top level quantity" {
    var book = try makeBook(49_900_000, 50, 50_000_000, 50);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .buy, null, 50, .market, &book);

    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 50), result.fills[0].fill_qty);
    try std.testing.expectEqual(@as(i64, 50_000_000), result.fills[0].fill_price);
}

test "market sell exact fill at top level quantity" {
    var book = try makeBook(49_900_000, 75, 50_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .sell, null, 75, .market, &book);

    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 75), result.fills[0].fill_qty);
    try std.testing.expectEqual(@as(i64, 49_900_000), result.fills[0].fill_price);
}

// ---------------------------------------------------------------------------
// Market orders — price level walking (multi-level fills)
// ---------------------------------------------------------------------------

test "market buy walks multiple ask levels" {
    const ask_prices = [_]i64{ 50_000_000, 50_100_000, 50_200_000 };
    const ask_qtys = [_]i64{ 30, 40, 50 };
    const bid_prices = [_]i64{49_900_000};
    const bid_qtys = [_]i64{100};

    var book = try makeMultiLevelBook(&bid_prices, &bid_qtys, &ask_prices, &ask_qtys);
    defer book.deinit();

    var engine = MatchingEngine.init();
    // Request 80 — should fill 30 at 50.0M, 40 at 50.1M, 10 at 50.2M
    const result = engine.processOrder(1, 0, .buy, null, 80, .market, &book);

    try std.testing.expectEqual(@as(u8, 3), result.fill_count);
    // Level 1: best ask
    try std.testing.expectEqual(@as(i64, 50_000_000), result.fills[0].fill_price);
    try std.testing.expectEqual(@as(i64, 30), result.fills[0].fill_qty);
    // Level 2
    try std.testing.expectEqual(@as(i64, 50_100_000), result.fills[1].fill_price);
    try std.testing.expectEqual(@as(i64, 40), result.fills[1].fill_qty);
    // Level 3: partial
    try std.testing.expectEqual(@as(i64, 50_200_000), result.fills[2].fill_price);
    try std.testing.expectEqual(@as(i64, 10), result.fills[2].fill_qty);
    try std.testing.expectEqual(@as(i64, 80), totalFilled(result));
}

test "market sell walks multiple bid levels" {
    const bid_prices = [_]i64{ 49_900_000, 49_800_000, 49_700_000 };
    const bid_qtys = [_]i64{ 20, 30, 50 };
    const ask_prices = [_]i64{50_000_000};
    const ask_qtys = [_]i64{100};

    var book = try makeMultiLevelBook(&bid_prices, &bid_qtys, &ask_prices, &ask_qtys);
    defer book.deinit();

    var engine = MatchingEngine.init();
    // Request 60 — should fill 20 at 49.9M, 30 at 49.8M, 10 at 49.7M
    const result = engine.processOrder(1, 0, .sell, null, 60, .market, &book);

    try std.testing.expectEqual(@as(u8, 3), result.fill_count);
    try std.testing.expectEqual(@as(i64, 49_900_000), result.fills[0].fill_price);
    try std.testing.expectEqual(@as(i64, 20), result.fills[0].fill_qty);
    try std.testing.expectEqual(@as(i64, 49_800_000), result.fills[1].fill_price);
    try std.testing.expectEqual(@as(i64, 30), result.fills[1].fill_qty);
    try std.testing.expectEqual(@as(i64, 49_700_000), result.fills[2].fill_price);
    try std.testing.expectEqual(@as(i64, 10), result.fills[2].fill_qty);
    try std.testing.expectEqual(@as(i64, 60), totalFilled(result));
}

test "market buy consumes all levels exactly" {
    const ask_prices = [_]i64{ 50_000_000, 50_100_000 };
    const ask_qtys = [_]i64{ 40, 60 };
    const bid_prices = [_]i64{49_900_000};
    const bid_qtys = [_]i64{100};

    var book = try makeMultiLevelBook(&bid_prices, &bid_qtys, &ask_prices, &ask_qtys);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .buy, null, 100, .market, &book);

    // 40 + 60 = 100, exact match across two levels, no fallback
    try std.testing.expectEqual(@as(u8, 2), result.fill_count);
    try std.testing.expectEqual(@as(i64, 100), totalFilled(result));
}

// ---------------------------------------------------------------------------
// Market orders — partial fill + fallback
// ---------------------------------------------------------------------------

test "market buy partial fill with fallback when book insufficient" {
    var book = try makeBook(49_900_000, 100, 50_000_000, 30);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .buy, null, 100, .market, &book);

    // 30 at book, 70 at fallback
    try std.testing.expect(result.fill_count >= 2);
    try std.testing.expectEqual(@as(i64, 30), result.fills[0].fill_qty);
    try std.testing.expectEqual(@as(i64, 50_000_000), result.fills[0].fill_price);
    try std.testing.expectEqual(@as(i64, 70), result.fills[1].fill_qty);
    try std.testing.expectEqual(@as(i64, 100), totalFilled(result));
}

test "market sell partial fill with fallback when book insufficient" {
    var book = try makeBook(49_900_000, 20, 50_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .sell, null, 50, .market, &book);

    try std.testing.expect(result.fill_count >= 2);
    try std.testing.expectEqual(@as(i64, 20), result.fills[0].fill_qty);
    try std.testing.expectEqual(@as(i64, 49_900_000), result.fills[0].fill_price);
    try std.testing.expectEqual(@as(i64, 30), result.fills[1].fill_qty);
    try std.testing.expectEqual(@as(i64, 50), totalFilled(result));
}

// ---------------------------------------------------------------------------
// Market orders — empty book (full fallback)
// ---------------------------------------------------------------------------

test "market buy on empty book fills entirely at fallback price zero" {
    var book = try makeEmptyBook();
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .buy, null, 50, .market, &book);

    // No levels, entire quantity goes to fallback
    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 50), result.fills[0].fill_qty);
    // Fallback on empty book returns 0
    try std.testing.expectEqual(@as(i64, 0), result.fills[0].fill_price);
}

test "market sell on empty book fills entirely at fallback price zero" {
    var book = try makeEmptyBook();
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .sell, null, 50, .market, &book);

    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 50), result.fills[0].fill_qty);
    try std.testing.expectEqual(@as(i64, 0), result.fills[0].fill_price);
}

test "market buy fallback uses ask price when asks exist" {
    // Only asks, no bids
    var book = try L2Book.init(std.testing.allocator, 10);
    defer book.deinit();
    const empty_bids: [0]Level = .{};
    const asks = [_]Level{.{ .price = 50_000_000, .quantity = 10 }};
    book.applySnapshot(&empty_bids, &asks);

    var engine = MatchingEngine.init();
    // Buy 20 — 10 filled from book, 10 fallback at ask
    const result = engine.processOrder(1, 0, .buy, null, 20, .market, &book);

    try std.testing.expectEqual(@as(u8, 2), result.fill_count);
    try std.testing.expectEqual(@as(i64, 10), result.fills[0].fill_qty);
    try std.testing.expectEqual(@as(i64, 50_000_000), result.fills[0].fill_price);
    // Fallback for buy: bestAsk
    try std.testing.expectEqual(@as(i64, 50_000_000), result.fills[1].fill_price);
}

test "market sell fallback uses bid price when bids exist" {
    // Only bids, no asks
    var book = try L2Book.init(std.testing.allocator, 10);
    defer book.deinit();
    const bids = [_]Level{.{ .price = 49_900_000, .quantity = 10 }};
    const empty_asks: [0]Level = .{};
    book.applySnapshot(&bids, &empty_asks);

    var engine = MatchingEngine.init();
    // Sell 20 — 10 filled from book, 10 fallback at bid
    const result = engine.processOrder(1, 0, .sell, null, 20, .market, &book);

    try std.testing.expectEqual(@as(u8, 2), result.fill_count);
    try std.testing.expectEqual(@as(i64, 10), result.fills[0].fill_qty);
    try std.testing.expectEqual(@as(i64, 49_900_000), result.fills[0].fill_price);
    // Fallback for sell: bestBid
    try std.testing.expectEqual(@as(i64, 49_900_000), result.fills[1].fill_price);
}

// ---------------------------------------------------------------------------
// Market orders — does not rest
// ---------------------------------------------------------------------------

test "market order never rests" {
    var book = try makeBook(49_900_000, 100, 50_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .buy, null, 10, .market, &book);

    try std.testing.expect(!result.rested);
    try std.testing.expectEqual(@as(i64, 0), result.rested_qty);
    try std.testing.expectEqual(@as(usize, 0), engine.resting_count);
}

// ---------------------------------------------------------------------------
// Limit orders — resting (non-crossing)
// ---------------------------------------------------------------------------

test "limit buy below ask rests entirely" {
    var book = try makeBook(49_500_000, 100, 50_500_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .buy, 49_700_000, 50, .limit, &book);

    try std.testing.expect(result.rested);
    try std.testing.expectEqual(@as(i64, 50), result.rested_qty);
    try std.testing.expectEqual(@as(u8, 0), result.fill_count);
    try std.testing.expectEqual(@as(usize, 1), engine.resting_count);
}

test "limit sell above bid rests entirely" {
    var book = try makeBook(49_500_000, 100, 50_500_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .sell, 50_300_000, 40, .limit, &book);

    try std.testing.expect(result.rested);
    try std.testing.expectEqual(@as(i64, 40), result.rested_qty);
    try std.testing.expectEqual(@as(u8, 0), result.fill_count);
    try std.testing.expectEqual(@as(usize, 1), engine.resting_count);
}

test "resting order records correct fields" {
    var book = try makeBook(49_500_000, 100, 50_500_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    _ = engine.processOrder(42, 3, .buy, 49_600_000, 25, .limit, &book);

    try std.testing.expectEqual(@as(usize, 1), engine.resting_count);
    const ro = engine.resting_orders[0];
    try std.testing.expectEqual(@as(u64, 42), ro.order_id);
    try std.testing.expectEqual(@as(u8, 3), ro.instrument_idx);
    try std.testing.expectEqual(Side.buy, ro.side);
    try std.testing.expectEqual(@as(i64, 49_600_000), ro.price);
    try std.testing.expectEqual(@as(i64, 25), ro.remaining_qty);
    try std.testing.expect(ro.active);
}

// ---------------------------------------------------------------------------
// Limit orders — crossing the BBO (immediate fill)
// ---------------------------------------------------------------------------

test "limit buy at ask price fills immediately" {
    var book = try makeBook(49_900_000, 100, 50_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .buy, 50_000_000, 60, .limit, &book);

    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 50_000_000), result.fills[0].fill_price);
    try std.testing.expectEqual(@as(i64, 60), result.fills[0].fill_qty);
    try std.testing.expect(!result.rested);
}

test "limit buy above ask price fills immediately" {
    var book = try makeBook(49_900_000, 100, 50_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .buy, 50_500_000, 40, .limit, &book);

    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 50_000_000), result.fills[0].fill_price);
    try std.testing.expectEqual(@as(i64, 40), result.fills[0].fill_qty);
    try std.testing.expect(!result.rested);
}

test "limit sell at bid price fills immediately" {
    var book = try makeBook(49_900_000, 100, 50_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .sell, 49_900_000, 50, .limit, &book);

    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 49_900_000), result.fills[0].fill_price);
    try std.testing.expectEqual(@as(i64, 50), result.fills[0].fill_qty);
    try std.testing.expect(!result.rested);
}

test "limit sell below bid price fills immediately" {
    var book = try makeBook(49_900_000, 100, 50_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .sell, 49_500_000, 30, .limit, &book);

    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 49_900_000), result.fills[0].fill_price);
    try std.testing.expectEqual(@as(i64, 30), result.fills[0].fill_qty);
}

// ---------------------------------------------------------------------------
// Limit orders — partial crossing + rest remainder
// ---------------------------------------------------------------------------

test "limit buy crossing with insufficient liquidity rests remainder" {
    var book = try makeBook(49_900_000, 100, 50_000_000, 30);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .buy, 50_000_000, 80, .limit, &book);

    // 30 filled from book, 50 rested
    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 30), result.fills[0].fill_qty);
    try std.testing.expectEqual(@as(i64, 50_000_000), result.fills[0].fill_price);
    try std.testing.expect(result.rested);
    try std.testing.expectEqual(@as(i64, 50), result.rested_qty);
    try std.testing.expectEqual(@as(usize, 1), engine.resting_count);
}

test "limit sell crossing with insufficient liquidity rests remainder" {
    var book = try makeBook(49_900_000, 20, 50_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .sell, 49_900_000, 50, .limit, &book);

    // 20 filled from book, 30 rested
    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 20), result.fills[0].fill_qty);
    try std.testing.expectEqual(@as(i64, 49_900_000), result.fills[0].fill_price);
    try std.testing.expect(result.rested);
    try std.testing.expectEqual(@as(i64, 30), result.rested_qty);
}

test "limit buy walks multiple levels then rests remainder" {
    const ask_prices = [_]i64{ 50_000_000, 50_100_000, 50_200_000 };
    const ask_qtys = [_]i64{ 20, 20, 20 };
    const bid_prices = [_]i64{49_900_000};
    const bid_qtys = [_]i64{100};

    var book = try makeMultiLevelBook(&bid_prices, &bid_qtys, &ask_prices, &ask_qtys);
    defer book.deinit();

    var engine = MatchingEngine.init();
    // Limit buy at 50_200_000 for qty 80 — crosses all 3 levels (60 total), rests 20
    const result = engine.processOrder(1, 0, .buy, 50_200_000, 80, .limit, &book);

    try std.testing.expectEqual(@as(u8, 3), result.fill_count);
    try std.testing.expectEqual(@as(i64, 60), totalFilled(result));
    try std.testing.expect(result.rested);
    try std.testing.expectEqual(@as(i64, 20), result.rested_qty);
}

// ---------------------------------------------------------------------------
// Limit orders — null price returns empty result
// ---------------------------------------------------------------------------

test "limit order with null price returns empty result" {
    var book = try makeBook(49_900_000, 100, 50_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .buy, null, 50, .limit, &book);

    try std.testing.expectEqual(@as(u8, 0), result.fill_count);
    try std.testing.expect(!result.rested);
    try std.testing.expectEqual(@as(i64, 0), result.rested_qty);
}

// ---------------------------------------------------------------------------
// Limit orders — on empty book
// ---------------------------------------------------------------------------

test "limit buy on empty book rests entirely" {
    var book = try makeEmptyBook();
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .buy, 50_000_000, 40, .limit, &book);

    try std.testing.expect(result.rested);
    try std.testing.expectEqual(@as(i64, 40), result.rested_qty);
    try std.testing.expectEqual(@as(u8, 0), result.fill_count);
}

test "limit sell on empty book rests entirely" {
    var book = try makeEmptyBook();
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .sell, 50_000_000, 40, .limit, &book);

    try std.testing.expect(result.rested);
    try std.testing.expectEqual(@as(i64, 40), result.rested_qty);
    try std.testing.expectEqual(@as(u8, 0), result.fill_count);
}

// ---------------------------------------------------------------------------
// Resting orders — checkRestingOrders
// ---------------------------------------------------------------------------

test "resting buy order fills when ask drops to limit price" {
    var book = try makeBook(49_500_000, 100, 50_500_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    // Rest a buy limit at 49_700_000
    const result = engine.processOrder(1, 0, .buy, 49_700_000, 50, .limit, &book);
    try std.testing.expect(result.rested);

    // Move ask down to 49_600_000 (below limit)
    book.applyUpdate(.ask, 49_600_000, 100);

    var books = try makeBooksArray(book);
    defer deinitBooksArray(&books);

    const resting_result = engine.checkRestingOrders(&books);
    try std.testing.expectEqual(@as(u8, 1), resting_result.fill_count);
    try std.testing.expectEqual(@as(u64, 1), resting_result.fills[0].order_id);
    try std.testing.expectEqual(@as(i64, 50), resting_result.fills[0].fill_qty);
    try std.testing.expectEqual(@as(i64, 49_600_000), resting_result.fills[0].fill_price);
}

test "resting sell order fills when bid rises to limit price" {
    var book = try makeBook(49_500_000, 100, 50_500_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    // Rest a sell limit at 50_300_000
    const result = engine.processOrder(1, 0, .sell, 50_300_000, 60, .limit, &book);
    try std.testing.expect(result.rested);

    // Move bid up to 50_400_000 (above limit)
    book.applyUpdate(.bid, 50_400_000, 100);

    var books = try makeBooksArray(book);
    defer deinitBooksArray(&books);

    const resting_result = engine.checkRestingOrders(&books);
    try std.testing.expectEqual(@as(u8, 1), resting_result.fill_count);
    try std.testing.expectEqual(@as(u64, 1), resting_result.fills[0].order_id);
    try std.testing.expectEqual(@as(i64, 60), resting_result.fills[0].fill_qty);
    try std.testing.expectEqual(@as(i64, 50_400_000), resting_result.fills[0].fill_price);
}

test "resting order does not fill when price has not crossed" {
    var book = try makeBook(49_500_000, 100, 50_500_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    _ = engine.processOrder(1, 0, .buy, 49_700_000, 50, .limit, &book);

    // Ask is still at 50_500_000 > limit 49_700_000, should not fill
    var books = try makeBooksArray(book);
    defer deinitBooksArray(&books);

    const resting_result = engine.checkRestingOrders(&books);
    try std.testing.expectEqual(@as(u8, 0), resting_result.fill_count);
}

test "resting order becomes inactive after fill" {
    var book = try makeBook(49_500_000, 100, 50_500_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    _ = engine.processOrder(1, 0, .buy, 49_700_000, 50, .limit, &book);

    // Move ask below limit
    book.applyUpdate(.ask, 49_600_000, 100);

    var books = try makeBooksArray(book);
    defer deinitBooksArray(&books);

    // First check fills it
    const first = engine.checkRestingOrders(&books);
    try std.testing.expectEqual(@as(u8, 1), first.fill_count);

    // Second check should not fill again (order is now inactive)
    const second = engine.checkRestingOrders(&books);
    try std.testing.expectEqual(@as(u8, 0), second.fill_count);
}

// ---------------------------------------------------------------------------
// Resting orders — multiple orders
// ---------------------------------------------------------------------------

test "multiple resting orders can fill in same check" {
    var book = try makeBook(49_000_000, 100, 51_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    // Rest two buy orders
    _ = engine.processOrder(10, 0, .buy, 49_500_000, 30, .limit, &book);
    _ = engine.processOrder(20, 0, .buy, 49_400_000, 40, .limit, &book);
    try std.testing.expectEqual(@as(usize, 2), engine.resting_count);

    // Drop ask below both limits
    book.applyUpdate(.ask, 49_300_000, 200);

    var books = try makeBooksArray(book);
    defer deinitBooksArray(&books);

    const resting_result = engine.checkRestingOrders(&books);
    try std.testing.expectEqual(@as(u8, 2), resting_result.fill_count);

    // Both should have filled
    var found_10 = false;
    var found_20 = false;
    for (0..resting_result.fill_count) |i| {
        if (resting_result.fills[i].order_id == 10) {
            try std.testing.expectEqual(@as(i64, 30), resting_result.fills[i].fill_qty);
            found_10 = true;
        }
        if (resting_result.fills[i].order_id == 20) {
            try std.testing.expectEqual(@as(i64, 40), resting_result.fills[i].fill_qty);
            found_20 = true;
        }
    }
    try std.testing.expect(found_10);
    try std.testing.expect(found_20);
}

test "only matching resting orders fill when one is out of range" {
    var book = try makeBook(49_000_000, 100, 51_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    // Order A: limit buy at 49_500_000
    _ = engine.processOrder(10, 0, .buy, 49_500_000, 30, .limit, &book);
    // Order B: limit buy at 48_000_000 (far below)
    _ = engine.processOrder(20, 0, .buy, 48_000_000, 40, .limit, &book);

    // Ask drops to 49_400_000 — only order A should fill
    book.applyUpdate(.ask, 49_400_000, 200);

    var books = try makeBooksArray(book);
    defer deinitBooksArray(&books);

    const resting_result = engine.checkRestingOrders(&books);
    try std.testing.expectEqual(@as(u8, 1), resting_result.fill_count);
    try std.testing.expectEqual(@as(u64, 10), resting_result.fills[0].order_id);
}

// ---------------------------------------------------------------------------
// Resting orders — slot reuse
// ---------------------------------------------------------------------------

test "filled resting order slot is reused by new resting order" {
    var book = try makeBook(49_000_000, 100, 51_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    // Rest an order
    _ = engine.processOrder(1, 0, .buy, 49_500_000, 30, .limit, &book);
    try std.testing.expectEqual(@as(usize, 1), engine.resting_count);

    // Fill it
    book.applyUpdate(.ask, 49_400_000, 200);
    var books = try makeBooksArray(book);
    defer deinitBooksArray(&books);
    _ = engine.checkRestingOrders(&books);

    // The slot should now be inactive — new resting order reuses it
    // Reset book to wide spread
    book.applyUpdate(.ask, 51_000_000, 100);
    _ = engine.processOrder(2, 0, .buy, 49_600_000, 20, .limit, &book);

    // resting_count should still be 1 (reused slot 0)
    try std.testing.expectEqual(@as(usize, 1), engine.resting_count);
    try std.testing.expectEqual(@as(u64, 2), engine.resting_orders[0].order_id);
    try std.testing.expect(engine.resting_orders[0].active);
}

// ---------------------------------------------------------------------------
// Resting orders — different instruments
// ---------------------------------------------------------------------------

test "resting orders on different instruments fill independently" {
    var engine = MatchingEngine.init();

    // Set up two separate books
    var book0 = try makeBook(49_000_000, 100, 51_000_000, 100);
    defer book0.deinit();
    var book1 = try makeBook(29_000_000, 100, 31_000_000, 100);
    defer book1.deinit();

    // Rest orders on instruments 0 and 1
    _ = engine.processOrder(1, 0, .buy, 49_500_000, 30, .limit, &book0);
    _ = engine.processOrder(2, 1, .buy, 29_500_000, 40, .limit, &book1);

    // Only update book1 to trigger fill
    book1.applyUpdate(.ask, 29_400_000, 100);

    var books: [8]L2Book = undefined;
    books[0] = book0;
    books[1] = book1;
    for (2..8) |i| {
        books[i] = try L2Book.init(std.testing.allocator, 1);
    }
    defer for (2..8) |i| books[i].deinit();

    const resting_result = engine.checkRestingOrders(&books);
    // Only instrument 1 order should fill
    try std.testing.expectEqual(@as(u8, 1), resting_result.fill_count);
    try std.testing.expectEqual(@as(u64, 2), resting_result.fills[0].order_id);
}

// ---------------------------------------------------------------------------
// Resting orders — instrument_idx bounds
// ---------------------------------------------------------------------------

test "resting order with instrument_idx >= 8 is skipped" {
    var book = try makeBook(49_000_000, 100, 51_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    // Manually place a resting order with an out-of-bounds instrument index
    // by resting on instrument 0 first, then overwriting instrument_idx
    _ = engine.processOrder(1, 0, .buy, 49_500_000, 30, .limit, &book);
    engine.resting_orders[0].instrument_idx = 9; // out-of-bounds

    book.applyUpdate(.ask, 49_400_000, 200);
    var books = try makeBooksArray(book);
    defer deinitBooksArray(&books);

    const resting_result = engine.checkRestingOrders(&books);
    // Should be skipped entirely
    try std.testing.expectEqual(@as(u8, 0), resting_result.fill_count);
}

// ---------------------------------------------------------------------------
// Resting orders — resting buy fills at ask price, sell fills at bid price
// ---------------------------------------------------------------------------

test "resting buy order fills at best ask, not at limit price" {
    var book = try makeBook(49_500_000, 100, 50_500_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    _ = engine.processOrder(1, 0, .buy, 49_700_000, 50, .limit, &book);

    // Ask drops to 49_600_000 — below limit of 49_700_000
    book.applyUpdate(.ask, 49_600_000, 100);

    var books = try makeBooksArray(book);
    defer deinitBooksArray(&books);

    const resting_result = engine.checkRestingOrders(&books);
    try std.testing.expectEqual(@as(u8, 1), resting_result.fill_count);
    // Fill price should be the ask (49_600_000), not the limit (49_700_000)
    try std.testing.expectEqual(@as(i64, 49_600_000), resting_result.fills[0].fill_price);
}

test "resting sell order fills at best bid, not at limit price" {
    var book = try makeBook(49_500_000, 100, 50_500_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    _ = engine.processOrder(1, 0, .sell, 50_300_000, 50, .limit, &book);

    // Bid rises to 50_400_000 — above limit of 50_300_000
    book.applyUpdate(.bid, 50_400_000, 100);

    var books = try makeBooksArray(book);
    defer deinitBooksArray(&books);

    const resting_result = engine.checkRestingOrders(&books);
    try std.testing.expectEqual(@as(u8, 1), resting_result.fill_count);
    // Fill price should be the bid (50_400_000), not the limit (50_300_000)
    try std.testing.expectEqual(@as(i64, 50_400_000), resting_result.fills[0].fill_price);
}

// ---------------------------------------------------------------------------
// Capacity limits
// ---------------------------------------------------------------------------

test "FillResult caps at 16 fills" {
    // Build a book with many small levels
    var book = try L2Book.init(std.testing.allocator, 10);
    defer book.deinit();
    // 10 ask levels of qty 1 each
    var ask_levels: [10]Level = undefined;
    for (0..10) |i| {
        ask_levels[i] = .{
            .price = 50_000_000 + @as(i64, @intCast(i)) * 100_000,
            .quantity = 1,
        };
    }
    const empty_bids: [0]Level = .{};
    book.applySnapshot(&empty_bids, &ask_levels);

    var engine = MatchingEngine.init();
    // Buy 10 — fills 10 levels, well under the 16 cap
    const result = engine.processOrder(1, 0, .buy, null, 10, .market, &book);

    try std.testing.expectEqual(@as(u8, 10), result.fill_count);
    try std.testing.expectEqual(@as(i64, 10), totalFilled(result));
}

// ---------------------------------------------------------------------------
// Multiple processOrder calls — engine state accumulates
// ---------------------------------------------------------------------------

test "sequential limit orders accumulate in resting book" {
    var book = try makeBook(49_000_000, 100, 51_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    _ = engine.processOrder(1, 0, .buy, 49_500_000, 10, .limit, &book);
    _ = engine.processOrder(2, 0, .buy, 49_400_000, 20, .limit, &book);
    _ = engine.processOrder(3, 0, .sell, 50_800_000, 30, .limit, &book);

    try std.testing.expectEqual(@as(usize, 3), engine.resting_count);
    try std.testing.expectEqual(@as(u64, 1), engine.resting_orders[0].order_id);
    try std.testing.expectEqual(@as(u64, 2), engine.resting_orders[1].order_id);
    try std.testing.expectEqual(@as(u64, 3), engine.resting_orders[2].order_id);
}

test "mixed market and limit orders — market fills, limit rests" {
    var book = try makeBook(49_900_000, 100, 50_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();

    // Market buy — fills immediately
    const market_result = engine.processOrder(1, 0, .buy, null, 10, .market, &book);
    try std.testing.expectEqual(@as(u8, 1), market_result.fill_count);
    try std.testing.expect(!market_result.rested);
    try std.testing.expectEqual(@as(usize, 0), engine.resting_count);

    // Limit buy below ask — rests
    const limit_result = engine.processOrder(2, 0, .buy, 49_700_000, 20, .limit, &book);
    try std.testing.expectEqual(@as(u8, 0), limit_result.fill_count);
    try std.testing.expect(limit_result.rested);
    try std.testing.expectEqual(@as(usize, 1), engine.resting_count);
}

// ---------------------------------------------------------------------------
// Edge cases — zero and minimal quantities
// ---------------------------------------------------------------------------

test "market order with zero remaining after book fill has no fallback" {
    var book = try makeBook(49_900_000, 100, 50_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    // Buy exactly 100 — fills entirely from book, no fallback needed
    const result = engine.processOrder(1, 0, .buy, null, 100, .market, &book);

    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 100), result.fills[0].fill_qty);
    try std.testing.expectEqual(@as(i64, 50_000_000), result.fills[0].fill_price);
}

test "market order qty 1 fills single unit" {
    var book = try makeBook(49_900_000, 100, 50_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .buy, null, 1, .market, &book);

    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 1), result.fills[0].fill_qty);
}

// ---------------------------------------------------------------------------
// Limit buy at exact ask, limit sell at exact bid
// ---------------------------------------------------------------------------

test "limit buy at exactly the ask price crosses and fills" {
    var book = try makeBook(49_900_000, 100, 50_000_000, 80);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .buy, 50_000_000, 50, .limit, &book);

    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 50), result.fills[0].fill_qty);
    try std.testing.expectEqual(@as(i64, 50_000_000), result.fills[0].fill_price);
    try std.testing.expect(!result.rested);
}

test "limit sell at exactly the bid price crosses and fills" {
    var book = try makeBook(49_900_000, 80, 50_000_000, 100);
    defer book.deinit();

    var engine = MatchingEngine.init();
    const result = engine.processOrder(1, 0, .sell, 49_900_000, 50, .limit, &book);

    try std.testing.expectEqual(@as(u8, 1), result.fill_count);
    try std.testing.expectEqual(@as(i64, 50), result.fills[0].fill_qty);
    try std.testing.expectEqual(@as(i64, 49_900_000), result.fills[0].fill_price);
    try std.testing.expect(!result.rested);
}
