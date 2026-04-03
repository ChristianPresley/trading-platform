const std = @import("std");
const positions = @import("positions");

const PositionManager = positions.PositionManager;
const PositionConfig = positions.PositionConfig;
const PositionKey = positions.PositionKey;
const Fill = positions.Fill;
const Side = positions.Side;

fn makeKey(account: []const u8, instrument: []const u8) PositionKey {
    return .{
        .account = account,
        .instrument = instrument,
        .settlement_date = 20240101,
        .currency = "USD",
    };
}

fn makeFill(side: Side, qty: i64, price: i64, ts: u128) Fill {
    return .{
        .instrument = "AAPL",
        .side = side,
        .quantity = qty,
        .price = price,
        .timestamp = ts,
        .account = "ACC1",
        .currency = "USD",
        .settlement_date = 20240101,
    };
}

test "FIFO: buy 100@10, buy 100@12, sell 150 → correct realized P&L" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var pm = try PositionManager.init(allocator, .{
        .cost_basis_method = .fifo,
        .base_currency = "USD",
    });
    defer pm.deinit();

    // Buy 100 @ 10
    try pm.onFill(makeFill(.buy, 100, 10, 1));
    // Buy 100 @ 12
    try pm.onFill(makeFill(.buy, 100, 12, 2));
    // Sell 150: FIFO closes 100@10 first, then 50@12
    // Realized P&L on sell price of... we need a sell price. Use 15.
    try pm.onFill(makeFill(.sell, 150, 15, 3));

    const key = makeKey("ACC1", "AAPL");
    const rpnl = pm.realizedPnl(key);
    try std.testing.expect(rpnl != null);
    // FIFO: 100*(15-10) + 50*(15-12) = 500 + 150 = 650
    try std.testing.expectEqual(@as(i64, 650), rpnl.?);

    // Open position: 50 @ 12 remains
    const pos = pm.getPosition(key);
    try std.testing.expect(pos != null);
    try std.testing.expectEqual(@as(i64, 50), pos.?.quantity);
}

test "LIFO: buy 100@10, buy 100@12, sell 150 → different P&L than FIFO" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var pm = try PositionManager.init(allocator, .{
        .cost_basis_method = .lifo,
        .base_currency = "USD",
    });
    defer pm.deinit();

    try pm.onFill(makeFill(.buy, 100, 10, 1));
    try pm.onFill(makeFill(.buy, 100, 12, 2));
    // Sell 150 @ 15: LIFO closes 100@12 first, then 50@10
    try pm.onFill(makeFill(.sell, 150, 15, 3));

    const key = makeKey("ACC1", "AAPL");
    const rpnl = pm.realizedPnl(key);
    try std.testing.expect(rpnl != null);
    // LIFO: 100*(15-12) + 50*(15-10) = 300 + 250 = 550
    try std.testing.expectEqual(@as(i64, 550), rpnl.?);
}

test "average cost: buy 100@10, buy 100@12, sell 150" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var pm = try PositionManager.init(allocator, .{
        .cost_basis_method = .average_cost,
        .base_currency = "USD",
    });
    defer pm.deinit();

    try pm.onFill(makeFill(.buy, 100, 10, 1));
    try pm.onFill(makeFill(.buy, 100, 12, 2));
    // avg cost = (100*10 + 100*12) / 200 = 2200/200 = 11
    try pm.onFill(makeFill(.sell, 150, 15, 3));

    const key = makeKey("ACC1", "AAPL");
    const rpnl = pm.realizedPnl(key);
    try std.testing.expect(rpnl != null);
    // avg cost: 150 * (15 - 11) = 600
    try std.testing.expectEqual(@as(i64, 600), rpnl.?);
}

test "flat position after equal buy/sell" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var pm = try PositionManager.init(allocator, .{
        .cost_basis_method = .fifo,
        .base_currency = "USD",
    });
    defer pm.deinit();

    try pm.onFill(makeFill(.buy, 100, 10, 1));
    try pm.onFill(makeFill(.sell, 100, 12, 2));

    const key = makeKey("ACC1", "AAPL");
    const pos = pm.getPosition(key);
    try std.testing.expect(pos != null);
    try std.testing.expectEqual(@as(i64, 0), pos.?.quantity);
    // Realized: 100*(12-10) = 200
    try std.testing.expectEqual(@as(i64, 200), pos.?.realized_pnl);
}

test "unrealized P&L at mark price" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var pm = try PositionManager.init(allocator, .{
        .cost_basis_method = .average_cost,
        .base_currency = "USD",
    });
    defer pm.deinit();

    try pm.onFill(makeFill(.buy, 100, 10, 1));

    const key = makeKey("ACC1", "AAPL");
    // Mark at 15: unrealized = (15 - 10) * 100 = 500
    const upnl = pm.unrealizedPnl(key, 15);
    try std.testing.expect(upnl != null);
    try std.testing.expectEqual(@as(i64, 500), upnl.?);
}

test "multi-currency: separate positions for USD and EUR" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var pm = try PositionManager.init(allocator, .{
        .cost_basis_method = .fifo,
        .base_currency = "USD",
    });
    defer pm.deinit();

    // USD fill
    try pm.onFill(Fill{
        .instrument = "AAPL",
        .side = .buy,
        .quantity = 100,
        .price = 10,
        .timestamp = 1,
        .account = "ACC1",
        .currency = "USD",
        .settlement_date = 20240101,
    });

    // EUR fill (different currency → different position key)
    try pm.onFill(Fill{
        .instrument = "AAPL",
        .side = .buy,
        .quantity = 50,
        .price = 9,
        .timestamp = 2,
        .account = "ACC1",
        .currency = "EUR",
        .settlement_date = 20240101,
    });

    const key_usd = PositionKey{
        .account = "ACC1",
        .instrument = "AAPL",
        .settlement_date = 20240101,
        .currency = "USD",
    };
    const key_eur = PositionKey{
        .account = "ACC1",
        .instrument = "AAPL",
        .settlement_date = 20240101,
        .currency = "EUR",
    };

    const pos_usd = pm.getPosition(key_usd);
    const pos_eur = pm.getPosition(key_eur);
    try std.testing.expect(pos_usd != null);
    try std.testing.expect(pos_eur != null);
    try std.testing.expectEqual(@as(i64, 100), pos_usd.?.quantity);
    try std.testing.expectEqual(@as(i64, 50), pos_eur.?.quantity);
}

test "position crosses zero: long to short" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var pm = try PositionManager.init(allocator, .{
        .cost_basis_method = .fifo,
        .base_currency = "USD",
    });
    defer pm.deinit();

    // Buy 100
    try pm.onFill(makeFill(.buy, 100, 10, 1));
    // Sell 150: closes 100 long, opens 50 short
    try pm.onFill(makeFill(.sell, 150, 12, 2));

    const key = makeKey("ACC1", "AAPL");
    const pos = pm.getPosition(key);
    try std.testing.expect(pos != null);
    // Net: -50
    try std.testing.expectEqual(@as(i64, -50), pos.?.quantity);
    // Realized on 100: (12-10)*100 = 200
    try std.testing.expectEqual(@as(i64, 200), pos.?.realized_pnl);
}
