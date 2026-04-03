const std = @import("std");
const pre_trade = @import("pre_trade");
const oms = @import("oms");

const PreTradeRisk = pre_trade.PreTradeRisk;
const RiskConfig = pre_trade.RiskConfig;
const Order = oms.Order;
const OrdStatus = oms.OrdStatus;
const OrderType = oms.OrderType;
const TimeInForce = oms.TimeInForce;
const Side = oms.Side;

fn defaultConfig() RiskConfig {
    return RiskConfig{
        .max_order_size = 1000,
        .max_notional = 10_000_000, // 10M
        .max_position = 5000,
        .max_order_rate = 100,
        .price_band_pct = 0.05, // 5%
        .dedup_window_ms = 1000, // 1 second
    };
}

fn makeOrder(instrument: []const u8, side: Side, order_type: OrderType, qty: i64, price: ?i64) Order {
    return Order{
        .id = 0,
        .instrument = instrument,
        .side = side,
        .order_type = order_type,
        .quantity = qty,
        .price = price,
        .tif = .gtc,
        .status = .pending_new,
        .created_at = 0,
        .parent_id = null,
        .filled_qty = 0,
    };
}

test "PreTradeRisk: order within all limits passes" {
    var risk = try PreTradeRisk.init(std.testing.allocator, defaultConfig());
    defer risk.deinit();

    const order = makeOrder("BTC/USD", .buy, .limit, 10, 50_000);
    const result = risk.validate(&order);
    try std.testing.expectEqual(pre_trade.ValidationResult.passed, result);
}

test "PreTradeRisk: over-size order rejected" {
    var risk = try PreTradeRisk.init(std.testing.allocator, defaultConfig());
    defer risk.deinit();

    const order = makeOrder("BTC/USD", .buy, .limit, 2000, 100); // qty 2000 > max 1000
    const result = risk.validate(&order);
    switch (result) {
        .passed => return error.ExpectedRejection,
        .rejected => |reason| try std.testing.expectEqual(pre_trade.RejectReason.size_exceeded, reason),
    }
}

test "PreTradeRisk: over-notional order rejected" {
    var risk = try PreTradeRisk.init(std.testing.allocator, RiskConfig{
        .max_order_size = 10_000,
        .max_notional = 1_000, // tiny notional limit
        .max_position = 100_000,
        .max_order_rate = 100,
        .price_band_pct = 0.5,
        .dedup_window_ms = 1000,
    });
    defer risk.deinit();

    const order = makeOrder("BTC/USD", .buy, .limit, 100, 100); // notional = 10,000 > 1,000
    const result = risk.validate(&order);
    switch (result) {
        .passed => return error.ExpectedRejection,
        .rejected => |reason| try std.testing.expectEqual(pre_trade.RejectReason.size_exceeded, reason),
    }
}

test "PreTradeRisk: zero quantity rejected as invalid order" {
    var risk = try PreTradeRisk.init(std.testing.allocator, defaultConfig());
    defer risk.deinit();

    const order = makeOrder("BTC/USD", .buy, .limit, 0, 100);
    const result = risk.validate(&order);
    switch (result) {
        .passed => return error.ExpectedRejection,
        .rejected => |reason| try std.testing.expectEqual(pre_trade.RejectReason.invalid_order, reason),
    }
}

test "PreTradeRisk: limit order with no price rejected as invalid" {
    var risk = try PreTradeRisk.init(std.testing.allocator, defaultConfig());
    defer risk.deinit();

    const order = makeOrder("BTC/USD", .buy, .limit, 10, null);
    const result = risk.validate(&order);
    switch (result) {
        .passed => return error.ExpectedRejection,
        .rejected => |reason| try std.testing.expectEqual(pre_trade.RejectReason.invalid_order, reason),
    }
}

test "PreTradeRisk: price too far from reference rejected" {
    var risk = try PreTradeRisk.init(std.testing.allocator, defaultConfig());
    defer risk.deinit();

    // Set reference price at 50,000; band is 5% → max allowed 52,500
    try risk.setReferencePrice("BTC/USD", 50_000);

    const order = makeOrder("BTC/USD", .buy, .limit, 1, 60_000); // way above band
    const result = risk.validate(&order);
    switch (result) {
        .passed => return error.ExpectedRejection,
        .rejected => |reason| try std.testing.expectEqual(pre_trade.RejectReason.price_unreasonable, reason),
    }
}

test "PreTradeRisk: price within band passes" {
    var risk = try PreTradeRisk.init(std.testing.allocator, defaultConfig());
    defer risk.deinit();

    try risk.setReferencePrice("BTC/USD", 50_000);

    const order = makeOrder("BTC/USD", .buy, .limit, 1, 51_000); // within 5%
    const result = risk.validate(&order);
    try std.testing.expectEqual(pre_trade.ValidationResult.passed, result);
}

test "PreTradeRisk: market order skips price reasonability check" {
    var risk = try PreTradeRisk.init(std.testing.allocator, defaultConfig());
    defer risk.deinit();

    try risk.setReferencePrice("BTC/USD", 50_000);

    // Market order with no price — should pass price check
    const order = makeOrder("BTC/USD", .buy, .market, 1, null);
    const result = risk.validate(&order);
    try std.testing.expectEqual(pre_trade.ValidationResult.passed, result);
}

test "PreTradeRisk: rate throttle triggers after burst" {
    var risk = try PreTradeRisk.init(std.testing.allocator, RiskConfig{
        .max_order_size = 10_000,
        .max_notional = 1_000_000_000,
        .max_position = 100_000,
        .max_order_rate = 3, // only 3 per second
        .price_band_pct = 1.0,
        .dedup_window_ms = 0, // disable dedup
    });
    defer risk.deinit();

    // First 3 orders should pass
    var i: usize = 0;
    while (i < 3) : (i += 1) {
        const order = makeOrder("ETH/USD", .buy, .market, 1, null);
        const result = risk.validate(&order);
        switch (result) {
            .passed => {},
            .rejected => return error.UnexpectedRejection,
        }
    }

    // 4th order should be rate-throttled
    const order4 = makeOrder("ETH/USD", .buy, .market, 1, null);
    const result4 = risk.validate(&order4);
    switch (result4) {
        .passed => return error.ExpectedRejection,
        .rejected => |reason| try std.testing.expectEqual(pre_trade.RejectReason.rate_exceeded, reason),
    }
}

test "PreTradeRisk: duplicate detection within window rejects" {
    var risk = try PreTradeRisk.init(std.testing.allocator, RiskConfig{
        .max_order_size = 10_000,
        .max_notional = 1_000_000_000,
        .max_position = 100_000,
        .max_order_rate = 1000,
        .price_band_pct = 1.0,
        .dedup_window_ms = 60_000, // 60 second window
    });
    defer risk.deinit();

    const order1 = makeOrder("BTC/USD", .buy, .limit, 10, 50_000);
    const r1 = risk.validate(&order1);
    try std.testing.expectEqual(pre_trade.ValidationResult.passed, r1);

    // Same params — should be detected as duplicate
    const order2 = makeOrder("BTC/USD", .buy, .limit, 10, 50_000);
    const r2 = risk.validate(&order2);
    switch (r2) {
        .passed => return error.ExpectedDuplicateRejection,
        .rejected => |reason| try std.testing.expectEqual(pre_trade.RejectReason.duplicate_detected, reason),
    }
}

test "PreTradeRisk: different quantity is not a duplicate" {
    var risk = try PreTradeRisk.init(std.testing.allocator, RiskConfig{
        .max_order_size = 10_000,
        .max_notional = 1_000_000_000,
        .max_position = 100_000,
        .max_order_rate = 1000,
        .price_band_pct = 1.0,
        .dedup_window_ms = 60_000,
    });
    defer risk.deinit();

    const order1 = makeOrder("BTC/USD", .buy, .limit, 10, 50_000);
    _ = risk.validate(&order1);

    // Different quantity — NOT a duplicate
    const order2 = makeOrder("BTC/USD", .buy, .limit, 20, 50_000);
    const r2 = risk.validate(&order2);
    try std.testing.expectEqual(pre_trade.ValidationResult.passed, r2);
}

test "PreTradeRisk: position limit exceeded rejects" {
    var risk = try PreTradeRisk.init(std.testing.allocator, RiskConfig{
        .max_order_size = 10_000,
        .max_notional = 1_000_000_000,
        .max_position = 100, // very small position limit
        .max_order_rate = 1000,
        .price_band_pct = 1.0,
        .dedup_window_ms = 0,
    });
    defer risk.deinit();

    // Simulate existing position of 90
    try risk.updatePosition("BTC/USD", 90);

    // Order for 20 would put position at 110 > 100
    const order = makeOrder("BTC/USD", .buy, .market, 20, null);
    const result = risk.validate(&order);
    switch (result) {
        .passed => return error.ExpectedRejection,
        .rejected => |reason| try std.testing.expectEqual(pre_trade.RejectReason.position_limit, reason),
    }
}
