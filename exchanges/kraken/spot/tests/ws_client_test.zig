// Tests for Kraken spot WS v2 client
// Verifies subscribe message format, message parsing from known JSON payloads.
// Does not make real network connections.

const std = @import("std");
const ws_client = @import("spot_ws_client");

const SpotWsClient = ws_client.SpotWsClient;
const Channel = ws_client.Channel;

test "buildSubscribeMessage: book channel, single pair" {
    const allocator = std.testing.allocator;
    const msg = try ws_client.buildSubscribeMessage(allocator, .book, &.{"XBT/USD"}, null);
    defer allocator.free(msg);

    // Verify v2 format
    try std.testing.expect(std.mem.indexOf(u8, msg, "\"method\":\"subscribe\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "\"channel\":\"book\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "\"XBT/USD\"") != null);
}

test "buildSubscribeMessage: multiple pairs" {
    const allocator = std.testing.allocator;
    const pairs = [_][]const u8{ "XBT/USD", "ETH/USD", "SOL/USD" };
    const msg = try ws_client.buildSubscribeMessage(allocator, .ticker, &pairs, null);
    defer allocator.free(msg);

    try std.testing.expect(std.mem.indexOf(u8, msg, "\"channel\":\"ticker\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "\"XBT/USD\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "\"ETH/USD\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "\"SOL/USD\"") != null);
}

test "buildSubscribeMessage: includes token when provided" {
    const allocator = std.testing.allocator;
    const msg = try ws_client.buildSubscribeMessage(allocator, .book, &.{"XBT/USD"}, "my_ws_token_123");
    defer allocator.free(msg);

    try std.testing.expect(std.mem.indexOf(u8, msg, "\"token\":\"my_ws_token_123\"") != null);
}

test "buildSubscribeMessage: no token when null" {
    const allocator = std.testing.allocator;
    const msg = try ws_client.buildSubscribeMessage(allocator, .trade, &.{"XBT/USD"}, null);
    defer allocator.free(msg);

    try std.testing.expect(std.mem.indexOf(u8, msg, "\"token\"") == null);
}

test "buildUnsubscribeMessage: correct format" {
    const allocator = std.testing.allocator;
    const msg = try ws_client.buildUnsubscribeMessage(allocator, .book, &.{"ETH/USD"});
    defer allocator.free(msg);

    try std.testing.expect(std.mem.indexOf(u8, msg, "\"method\":\"unsubscribe\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "\"channel\":\"book\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "\"ETH/USD\"") != null);
}

test "parseMessage: heartbeat detection" {
    const allocator = std.testing.allocator;
    const json =
        \\{"channel":"heartbeat","type":"heartbeat"}
    ;
    const msg = try ws_client.parseMessage(allocator, json);
    try std.testing.expect(msg == .heartbeat);
}

test "parseMessage: book snapshot detection" {
    const allocator = std.testing.allocator;
    const json =
        \\{"channel":"book","type":"snapshot","data":[{"symbol":"XBT/USD","bids":[{"price":50000.0,"qty":1.5}],"asks":[{"price":50001.0,"qty":2.0}],"checksum":12345}]}
    ;
    const msg = try ws_client.parseMessage(allocator, json);
    try std.testing.expect(msg == .book_snapshot);
}

test "parseMessage: book update detection" {
    const allocator = std.testing.allocator;
    const json =
        \\{"channel":"book","type":"update","data":[{"symbol":"XBT/USD","bids":[{"price":50005.0,"qty":0.5}],"asks":[],"checksum":99999,"timestamp":"2024-01-01T00:00:00Z"}]}
    ;
    const msg = try ws_client.parseMessage(allocator, json);
    try std.testing.expect(msg == .book_update);
}

test "parseMessage: trade detection" {
    const allocator = std.testing.allocator;
    const json =
        \\{"channel":"trade","type":"update","data":[{"symbol":"XBT/USD","side":"buy","price":50000.0,"qty":0.1,"timestamp":"2024-01-01T00:00:00Z","trade_id":123456}]}
    ;
    const msg = try ws_client.parseMessage(allocator, json);
    try std.testing.expect(msg == .trade);
}

test "parseMessage: ticker detection" {
    const allocator = std.testing.allocator;
    const json =
        \\{"channel":"ticker","type":"update","data":[{"symbol":"XBT/USD","bid":49999.0,"bid_qty":1.0,"ask":50001.0,"ask_qty":0.5}]}
    ;
    const msg = try ws_client.parseMessage(allocator, json);
    try std.testing.expect(msg == .ticker);
}

test "SpotWsClient: init and connect" {
    const allocator = std.testing.allocator;
    var client = try SpotWsClient.init(allocator, null);
    defer client.deinit();

    try std.testing.expect(!client.connected);
    try client.connect();
    try std.testing.expect(client.connected);
}

test "SpotWsClient: subscribe returns valid message" {
    const allocator = std.testing.allocator;
    var client = try SpotWsClient.init(allocator, null);
    defer client.deinit();

    const pairs = [_][]const u8{"XBT/USD"};
    const msg = try client.subscribe(.book, &pairs);
    defer allocator.free(msg);

    try std.testing.expect(std.mem.indexOf(u8, msg, "\"method\":\"subscribe\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "\"book\"") != null);
}

test "SpotWsClient: refreshToken stores token" {
    const allocator = std.testing.allocator;
    var client = try SpotWsClient.init(allocator, null);
    defer client.deinit();

    try std.testing.expect(client.ws_token == null);
    try client.refreshToken();
    try std.testing.expect(client.ws_token != null);
}

test "Channel: name returns correct string" {
    try std.testing.expectEqualStrings("book", Channel.book.name());
    try std.testing.expectEqualStrings("ticker", Channel.ticker.name());
    try std.testing.expectEqualStrings("trade", Channel.trade.name());
    try std.testing.expectEqualStrings("ohlc", Channel.ohlc.name());
    try std.testing.expectEqualStrings("spread", Channel.spread.name());
}
