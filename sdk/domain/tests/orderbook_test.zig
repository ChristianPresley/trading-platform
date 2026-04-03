// Tests for L2 and L3 order books

const std = @import("std");
const orderbook = @import("orderbook");
const orderbook_l3 = @import("orderbook_l3");

const L2Book = orderbook.L2Book;
const Level = orderbook.Level;
const Side = orderbook.Side;

const L3Book = orderbook_l3.L3Book;

// ---- L2 Book Tests ----

test "L2Book: empty book returns null for BBO" {
    var book = try L2Book.init(std.testing.allocator, 10);
    defer book.deinit();
    try std.testing.expect(book.bestBid() == null);
    try std.testing.expect(book.bestAsk() == null);
    try std.testing.expect(book.spread() == null);
    try std.testing.expect(book.midPrice() == null);
}

test "L2Book: applySnapshot populates bids and asks" {
    var book = try L2Book.init(std.testing.allocator, 10);
    defer book.deinit();

    const bids = [_]Level{
        .{ .price = 4000000, .quantity = 100 },
        .{ .price = 3999000, .quantity = 200 },
        .{ .price = 4001000, .quantity = 50 },
    };
    const asks = [_]Level{
        .{ .price = 4002000, .quantity = 80 },
        .{ .price = 4003000, .quantity = 120 },
        .{ .price = 4001500, .quantity = 60 },
    };

    book.applySnapshot(&bids, &asks);

    // Best bid should be highest bid
    const bb = book.bestBid() orelse unreachable;
    try std.testing.expectEqual(@as(i64, 4001000), bb.price);
    try std.testing.expectEqual(@as(i64, 50), bb.quantity);

    // Best ask should be lowest ask
    const ba = book.bestAsk() orelse unreachable;
    try std.testing.expectEqual(@as(i64, 4001500), ba.price);
    try std.testing.expectEqual(@as(i64, 60), ba.quantity);
}

test "L2Book: bids sorted descending, asks sorted ascending" {
    var book = try L2Book.init(std.testing.allocator, 10);
    defer book.deinit();

    const bids = [_]Level{
        .{ .price = 100, .quantity = 1 },
        .{ .price = 300, .quantity = 1 },
        .{ .price = 200, .quantity = 1 },
    };
    const asks = [_]Level{
        .{ .price = 600, .quantity = 1 },
        .{ .price = 400, .quantity = 1 },
        .{ .price = 500, .quantity = 1 },
    };
    book.applySnapshot(&bids, &asks);

    const all_bids = book.bids();
    try std.testing.expectEqual(@as(usize, 3), all_bids.len);
    try std.testing.expectEqual(@as(i64, 300), all_bids[0].price);
    try std.testing.expectEqual(@as(i64, 200), all_bids[1].price);
    try std.testing.expectEqual(@as(i64, 100), all_bids[2].price);

    const all_asks = book.asks();
    try std.testing.expectEqual(@as(usize, 3), all_asks.len);
    try std.testing.expectEqual(@as(i64, 400), all_asks[0].price);
    try std.testing.expectEqual(@as(i64, 500), all_asks[1].price);
    try std.testing.expectEqual(@as(i64, 600), all_asks[2].price);
}

test "L2Book: spread and midPrice are correct" {
    var book = try L2Book.init(std.testing.allocator, 10);
    defer book.deinit();

    const bids = [_]Level{ .{ .price = 1000, .quantity = 1 } };
    const asks = [_]Level{ .{ .price = 1010, .quantity = 1 } };
    book.applySnapshot(&bids, &asks);

    const s = book.spread() orelse unreachable;
    try std.testing.expectEqual(@as(i64, 10), s);

    const m = book.midPrice() orelse unreachable;
    try std.testing.expectEqual(@as(i64, 1005), m);
}

test "L2Book: applyUpdate inserts new level" {
    var book = try L2Book.init(std.testing.allocator, 10);
    defer book.deinit();

    const bids = [_]Level{ .{ .price = 1000, .quantity = 5 } };
    const asks = [_]Level{ .{ .price = 1010, .quantity = 5 } };
    book.applySnapshot(&bids, &asks);

    // Insert a better bid
    book.applyUpdate(.bid, 1005, 10);

    const bb = book.bestBid() orelse unreachable;
    try std.testing.expectEqual(@as(i64, 1005), bb.price);
    try std.testing.expectEqual(@as(i64, 10), bb.quantity);
}

test "L2Book: applyUpdate qty=0 removes level" {
    var book = try L2Book.init(std.testing.allocator, 10);
    defer book.deinit();

    const bids = [_]Level{
        .{ .price = 1005, .quantity = 10 },
        .{ .price = 1000, .quantity = 5 },
    };
    const asks = [_]Level{ .{ .price = 1010, .quantity = 5 } };
    book.applySnapshot(&bids, &asks);

    // Remove best bid
    book.applyUpdate(.bid, 1005, 0);

    const bb = book.bestBid() orelse unreachable;
    try std.testing.expectEqual(@as(i64, 1000), bb.price);
}

test "L2Book: applyUpdate qty=0 for non-existent level is no-op" {
    var book = try L2Book.init(std.testing.allocator, 10);
    defer book.deinit();

    const bids = [_]Level{ .{ .price = 1000, .quantity = 5 } };
    const asks = [_]Level{ .{ .price = 1010, .quantity = 5 } };
    book.applySnapshot(&bids, &asks);

    // Remove a non-existent price level — should not error or panic
    book.applyUpdate(.bid, 9999, 0);

    // Book should be unchanged
    const bb = book.bestBid() orelse unreachable;
    try std.testing.expectEqual(@as(i64, 1000), bb.price);
}

test "L2Book: applyUpdate modifies existing level quantity" {
    var book = try L2Book.init(std.testing.allocator, 10);
    defer book.deinit();

    const bids = [_]Level{ .{ .price = 1000, .quantity = 5 } };
    const asks = [_]Level{ .{ .price = 1010, .quantity = 5 } };
    book.applySnapshot(&bids, &asks);

    book.applyUpdate(.bid, 1000, 99);
    const bb = book.bestBid() orelse unreachable;
    try std.testing.expectEqual(@as(i64, 99), bb.quantity);
}

test "L2Book: BBO invariant — best_bid.price < best_ask.price after snapshot" {
    var book = try L2Book.init(std.testing.allocator, 10);
    defer book.deinit();

    const bids = [_]Level{
        .{ .price = 500, .quantity = 1 },
        .{ .price = 490, .quantity = 1 },
    };
    const asks = [_]Level{
        .{ .price = 510, .quantity = 1 },
        .{ .price = 520, .quantity = 1 },
    };
    book.applySnapshot(&bids, &asks);

    const bb = book.bestBid() orelse unreachable;
    const ba = book.bestAsk() orelse unreachable;
    try std.testing.expect(bb.price < ba.price);
}

test "L2Book: snapshot with depth limit truncates levels" {
    var book = try L2Book.init(std.testing.allocator, 2);
    defer book.deinit();

    const bids = [_]Level{
        .{ .price = 300, .quantity = 1 },
        .{ .price = 200, .quantity = 1 },
        .{ .price = 100, .quantity = 1 },
    };
    const asks = [_]Level{
        .{ .price = 400, .quantity = 1 },
        .{ .price = 500, .quantity = 1 },
        .{ .price = 600, .quantity = 1 },
    };
    book.applySnapshot(&bids, &asks);

    // Only 2 levels per side due to depth limit
    try std.testing.expectEqual(@as(usize, 2), book.bids().len);
    try std.testing.expectEqual(@as(usize, 2), book.asks().len);
}

// ---- L3 Book Tests ----

test "L3Book: empty book returns null for BBO" {
    var book = try L3Book.init(std.testing.allocator);
    defer book.deinit();
    try std.testing.expect(book.bestBid() == null);
    try std.testing.expect(book.bestAsk() == null);
}

test "L3Book: addOrder and getOrder" {
    var book = try L3Book.init(std.testing.allocator);
    defer book.deinit();

    try book.addOrder(1001, .bid, 50000, 100);
    const info = book.getOrder(1001) orelse unreachable;
    try std.testing.expectEqual(@as(u64, 1001), info.order_id);
    try std.testing.expectEqual(@as(i64, 50000), info.price);
    try std.testing.expectEqual(@as(i64, 100), info.quantity);
}

test "L3Book: bestBid returns highest bid price" {
    var book = try L3Book.init(std.testing.allocator);
    defer book.deinit();

    try book.addOrder(1, .bid, 100, 10);
    try book.addOrder(2, .bid, 200, 20);
    try book.addOrder(3, .bid, 150, 5);

    const bb = book.bestBid() orelse unreachable;
    try std.testing.expectEqual(@as(i64, 200), bb.price);
}

test "L3Book: bestAsk returns lowest ask price" {
    var book = try L3Book.init(std.testing.allocator);
    defer book.deinit();

    try book.addOrder(1, .ask, 300, 10);
    try book.addOrder(2, .ask, 100, 20);
    try book.addOrder(3, .ask, 200, 5);

    const ba = book.bestAsk() orelse unreachable;
    try std.testing.expectEqual(@as(i64, 100), ba.price);
}

test "L3Book: modifyOrder updates quantity" {
    var book = try L3Book.init(std.testing.allocator);
    defer book.deinit();

    try book.addOrder(42, .bid, 500, 10);
    try book.modifyOrder(42, 99);

    const info = book.getOrder(42) orelse unreachable;
    try std.testing.expectEqual(@as(i64, 99), info.quantity);
}

test "L3Book: deleteOrder removes order" {
    var book = try L3Book.init(std.testing.allocator);
    defer book.deinit();

    try book.addOrder(100, .bid, 500, 10);
    try book.deleteOrder(100);
    try std.testing.expect(book.getOrder(100) == null);
}

test "L3Book: deleteOrder on missing order returns error" {
    var book = try L3Book.init(std.testing.allocator);
    defer book.deinit();

    try std.testing.expectError(error.OrderNotFound, book.deleteOrder(9999));
}

test "L3Book: modifyOrder on missing order returns error" {
    var book = try L3Book.init(std.testing.allocator);
    defer book.deinit();

    try std.testing.expectError(error.OrderNotFound, book.modifyOrder(9999, 1));
}

test "L3Book: bestBid reflects deletion" {
    var book = try L3Book.init(std.testing.allocator);
    defer book.deinit();

    try book.addOrder(1, .bid, 200, 5);
    try book.addOrder(2, .bid, 100, 10);

    try book.deleteOrder(1); // remove best bid

    const bb = book.bestBid() orelse unreachable;
    try std.testing.expectEqual(@as(i64, 100), bb.price);
}
