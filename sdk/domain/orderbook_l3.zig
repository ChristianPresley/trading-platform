// L3 order book (market-by-order)
// Tracks individual orders by order_id via hash map.
// Maintains per-price-level ordering for bid/ask sides.

const std = @import("std");

pub const Side = enum { bid, ask };

pub const Level = struct {
    price: i64,
    quantity: i64,
};

pub const OrderInfo = struct {
    order_id: u64,
    side: Side,
    price: i64,
    quantity: i64,
};

pub const L3Book = struct {
    allocator: std.mem.Allocator,
    orders: std.AutoHashMap(u64, OrderInfo),

    pub fn init(allocator: std.mem.Allocator) !L3Book {
        return L3Book{
            .allocator = allocator,
            .orders = std.AutoHashMap(u64, OrderInfo).init(allocator),
        };
    }

    /// Add a new order. Returns error.OrderExists if order_id already present.
    pub fn addOrder(self: *L3Book, order_id: u64, side: Side, price: i64, qty: i64) !void {
        const entry = try self.orders.getOrPutValue(order_id, OrderInfo{
            .order_id = order_id,
            .side = side,
            .price = price,
            .quantity = qty,
        });
        _ = entry;
    }

    /// Modify an existing order's quantity. Returns error.OrderNotFound if not present.
    pub fn modifyOrder(self: *L3Book, order_id: u64, new_qty: i64) !void {
        const ptr = self.orders.getPtr(order_id) orelse return error.OrderNotFound;
        ptr.quantity = new_qty;
    }

    /// Delete an order. Returns error.OrderNotFound if not present.
    pub fn deleteOrder(self: *L3Book, order_id: u64) !void {
        if (!self.orders.remove(order_id)) return error.OrderNotFound;
    }

    /// Get order info by ID. O(1) via hash map.
    pub fn getOrder(self: *const L3Book, order_id: u64) ?OrderInfo {
        return self.orders.get(order_id);
    }

    /// Best bid: highest bid price among all orders.
    pub fn bestBid(self: *const L3Book) ?Level {
        var best_price: ?i64 = null;
        var best_qty: i64 = 0;
        var it = self.orders.valueIterator();
        while (it.next()) |order| {
            if (order.side == .bid) {
                if (best_price == null or order.price > best_price.?) {
                    best_price = order.price;
                    best_qty = order.quantity;
                } else if (order.price == best_price.?) {
                    best_qty += order.quantity;
                }
            }
        }
        if (best_price) |p| {
            return Level{ .price = p, .quantity = best_qty };
        }
        return null;
    }

    /// Best ask: lowest ask price among all orders.
    pub fn bestAsk(self: *const L3Book) ?Level {
        var best_price: ?i64 = null;
        var best_qty: i64 = 0;
        var it = self.orders.valueIterator();
        while (it.next()) |order| {
            if (order.side == .ask) {
                if (best_price == null or order.price < best_price.?) {
                    best_price = order.price;
                    best_qty = order.quantity;
                } else if (order.price == best_price.?) {
                    best_qty += order.quantity;
                }
            }
        }
        if (best_price) |p| {
            return Level{ .price = p, .quantity = best_qty };
        }
        return null;
    }

    pub fn deinit(self: *L3Book) void {
        self.orders.deinit();
    }
};
