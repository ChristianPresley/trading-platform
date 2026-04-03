const std = @import("std");
const ot = @import("order_types");

test "OrderType FIX tag round-trip: market" {
    const tag = ot.orderTypeToFixTag(.market);
    const result = try ot.fixTagToOrderType(tag);
    try std.testing.expectEqual(ot.OrderType.market, result);
}

test "OrderType FIX tag round-trip: limit" {
    const tag = ot.orderTypeToFixTag(.limit);
    const result = try ot.fixTagToOrderType(tag);
    try std.testing.expectEqual(ot.OrderType.limit, result);
}

test "OrderType FIX tag round-trip: stop" {
    const tag = ot.orderTypeToFixTag(.stop);
    const result = try ot.fixTagToOrderType(tag);
    try std.testing.expectEqual(ot.OrderType.stop, result);
}

test "OrderType FIX tag round-trip: stop_limit" {
    const tag = ot.orderTypeToFixTag(.stop_limit);
    const result = try ot.fixTagToOrderType(tag);
    try std.testing.expectEqual(ot.OrderType.stop_limit, result);
}

test "OrderType FIX tag round-trip: trailing_stop" {
    const tag = ot.orderTypeToFixTag(.trailing_stop);
    const result = try ot.fixTagToOrderType(tag);
    try std.testing.expectEqual(ot.OrderType.trailing_stop, result);
}

test "OrderType FIX tag values are correct" {
    try std.testing.expectEqualStrings("1", ot.orderTypeToFixTag(.market));
    try std.testing.expectEqualStrings("2", ot.orderTypeToFixTag(.limit));
    try std.testing.expectEqualStrings("3", ot.orderTypeToFixTag(.stop));
    try std.testing.expectEqualStrings("4", ot.orderTypeToFixTag(.stop_limit));
    try std.testing.expectEqualStrings("P", ot.orderTypeToFixTag(.trailing_stop));
}

test "fixTagToOrderType: unknown tag returns error" {
    try std.testing.expectError(error.UnknownFixTag, ot.fixTagToOrderType("Z"));
    try std.testing.expectError(error.UnknownFixTag, ot.fixTagToOrderType(""));
}

test "TimeInForce FIX tag round-trip: day" {
    const tag = ot.tifToFixTag(.day);
    const result = try ot.fixTagToTif(tag);
    try std.testing.expectEqual(ot.TimeInForce.day, result);
}

test "TimeInForce FIX tag round-trip: gtc" {
    const tag = ot.tifToFixTag(.gtc);
    const result = try ot.fixTagToTif(tag);
    try std.testing.expectEqual(ot.TimeInForce.gtc, result);
}

test "TimeInForce FIX tag round-trip: ioc" {
    const tag = ot.tifToFixTag(.ioc);
    const result = try ot.fixTagToTif(tag);
    try std.testing.expectEqual(ot.TimeInForce.ioc, result);
}

test "TimeInForce FIX tag round-trip: fok" {
    const tag = ot.tifToFixTag(.fok);
    const result = try ot.fixTagToTif(tag);
    try std.testing.expectEqual(ot.TimeInForce.fok, result);
}

test "TimeInForce FIX tag round-trip: gtd" {
    const tag = ot.tifToFixTag(.gtd);
    const result = try ot.fixTagToTif(tag);
    try std.testing.expectEqual(ot.TimeInForce.gtd, result);
}

test "TimeInForce FIX tag values are correct" {
    try std.testing.expectEqualStrings("0", ot.tifToFixTag(.day));
    try std.testing.expectEqualStrings("1", ot.tifToFixTag(.gtc));
    try std.testing.expectEqualStrings("3", ot.tifToFixTag(.ioc));
    try std.testing.expectEqualStrings("4", ot.tifToFixTag(.fok));
    try std.testing.expectEqualStrings("6", ot.tifToFixTag(.gtd));
}

test "fixTagToTif: unknown tag returns error" {
    try std.testing.expectError(error.UnknownFixTag, ot.fixTagToTif("9"));
    try std.testing.expectError(error.UnknownFixTag, ot.fixTagToTif(""));
}

test "BracketOrder: parent-child invariants — all IDs distinct" {
    const bracket = ot.BracketOrder{
        .entry_id = 1,
        .take_profit_id = 2,
        .stop_loss_id = 3,
    };
    try std.testing.expect(bracket.isValid());
}

test "BracketOrder: invalid when entry equals take_profit" {
    const bracket = ot.BracketOrder{
        .entry_id = 1,
        .take_profit_id = 1,
        .stop_loss_id = 3,
    };
    try std.testing.expect(!bracket.isValid());
}

test "BracketOrder: invalid when entry equals stop_loss" {
    const bracket = ot.BracketOrder{
        .entry_id = 1,
        .take_profit_id = 2,
        .stop_loss_id = 1,
    };
    try std.testing.expect(!bracket.isValid());
}

test "BracketOrder: invalid when take_profit equals stop_loss" {
    const bracket = ot.BracketOrder{
        .entry_id = 1,
        .take_profit_id = 2,
        .stop_loss_id = 2,
    };
    try std.testing.expect(!bracket.isValid());
}

test "OcoGroup: cancelCounterpart returns correct order" {
    var oco = ot.OcoGroup{ .orders = .{ 10, 20 } };
    try std.testing.expectEqual(@as(ot.OrderId, 20), oco.cancelCounterpart(10));
    try std.testing.expectEqual(@as(ot.OrderId, 10), oco.cancelCounterpart(20));
}

test "OcoGroup: cancelCounterpart with unrelated ID returns second order" {
    var oco = ot.OcoGroup{ .orders = .{ 10, 20 } };
    // If triggered ID is not orders[0], returns orders[0]
    try std.testing.expectEqual(@as(ot.OrderId, 10), oco.cancelCounterpart(99));
}
