// Tests for Kraken futures WS client
// Verifies challenge-response auth flow, feed message parsing.
// Does not make real network connections.

const std = @import("std");
const ws_client = @import("futures_ws_client");

const FuturesWsClient = ws_client.FuturesWsClient;
const FuturesAuth = ws_client.FuturesAuth;
const Feed = ws_client.Feed;

test "buildSubscribeMessage: book feed with products" {
    const allocator = std.testing.allocator;
    const products = [_][]const u8{"PI_XBTUSD"};
    const msg = try ws_client.buildSubscribeMessage(allocator, .book, &products);
    defer allocator.free(msg);

    try std.testing.expect(std.mem.indexOf(u8, msg, "\"event\":\"subscribe\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "\"feed\":\"book\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "\"PI_XBTUSD\"") != null);
}

test "buildSubscribeMessage: heartbeat feed without products" {
    const allocator = std.testing.allocator;
    const msg = try ws_client.buildSubscribeMessage(allocator, .heartbeat, null);
    defer allocator.free(msg);

    try std.testing.expect(std.mem.indexOf(u8, msg, "\"event\":\"subscribe\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "\"feed\":\"heartbeat\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "product_ids") == null);
}

test "buildSubscribeMessage: multiple products" {
    const allocator = std.testing.allocator;
    const products = [_][]const u8{ "PI_XBTUSD", "PI_ETHUSD", "PI_SOLUSD" };
    const msg = try ws_client.buildSubscribeMessage(allocator, .ticker, &products);
    defer allocator.free(msg);

    try std.testing.expect(std.mem.indexOf(u8, msg, "\"PI_XBTUSD\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "\"PI_ETHUSD\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "\"PI_SOLUSD\"") != null);
}

test "buildChallengeResponse: correct format" {
    const allocator = std.testing.allocator;
    const resp = try ws_client.buildChallengeResponse(
        allocator,
        "my_api_key",
        "challenge_string_from_server",
        "signed_challenge_base64",
    );
    defer allocator.free(resp);

    try std.testing.expect(std.mem.indexOf(u8, resp, "\"event\":\"challenge\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, resp, "\"api_key\":\"my_api_key\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, resp, "\"original_challenge\":\"challenge_string_from_server\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, resp, "\"signed_challenge\":\"signed_challenge_base64\"") != null);
}

test "buildPingMessage: ping format" {
    const allocator = std.testing.allocator;
    const ping = try ws_client.buildPingMessage(allocator);
    defer allocator.free(ping);

    try std.testing.expect(std.mem.indexOf(u8, ping, "\"event\":\"ping\"") != null);
}

test "parseMessage: heartbeat detection" {
    const allocator = std.testing.allocator;
    const json =
        \\{"event":"heartbeat"}
    ;
    const msg = try ws_client.parseMessage(allocator, json);
    try std.testing.expect(msg == .heartbeat);
}

test "parseMessage: challenge message detection" {
    const allocator = std.testing.allocator;
    const json =
        \\{"event":"challenge","message":"abc123challengeXYZ"}
    ;
    const msg = try ws_client.parseMessage(allocator, json);
    try std.testing.expect(msg == .challenge);
}

test "parseMessage: book message detection" {
    const allocator = std.testing.allocator;
    const json =
        \\{"feed":"book","product_id":"PI_XBTUSD","seq":12345,"bids":[{"price":50000.0,"qty":1.5,"side":"buy"}],"asks":[]}
    ;
    const msg = try ws_client.parseMessage(allocator, json);
    try std.testing.expect(msg == .book);
}

test "parseMessage: ticker message detection" {
    const allocator = std.testing.allocator;
    const json =
        \\{"feed":"ticker","product_id":"PI_XBTUSD","bid":49999.0,"ask":50001.0,"last":50000.0}
    ;
    const msg = try ws_client.parseMessage(allocator, json);
    try std.testing.expect(msg == .ticker);
}

test "parseMessage: trade message detection" {
    const allocator = std.testing.allocator;
    const json =
        \\{"feed":"trade","product_id":"PI_XBTUSD","side":"buy","price":50000.0,"qty":0.1}
    ;
    const msg = try ws_client.parseMessage(allocator, json);
    try std.testing.expect(msg == .trade);
}

test "parseMessage: fill message detection" {
    const allocator = std.testing.allocator;
    const json =
        \\{"feed":"fills","instrument":"PI_XBTUSD","price":50000.0,"qty":0.1}
    ;
    const msg = try ws_client.parseMessage(allocator, json);
    try std.testing.expect(msg == .fill);
}

test "FuturesWsClient: init and connect" {
    const allocator = std.testing.allocator;
    var client = try FuturesWsClient.init(allocator, null);
    defer client.deinit();

    try std.testing.expect(!client.connected);
    try client.connect();
    try std.testing.expect(client.connected);
}

test "FuturesWsClient: authenticate without auth returns error" {
    const allocator = std.testing.allocator;
    var client = try FuturesWsClient.init(allocator, null);
    defer client.deinit();

    try std.testing.expectError(error.NoAuth, client.authenticate());
}

test "FuturesWsClient: authenticate with auth succeeds" {
    const allocator = std.testing.allocator;
    const auth = FuturesAuth{
        .api_key = "test_key",
        .api_secret = "test_secret",
    };
    var client = try FuturesWsClient.init(allocator, auth);
    defer client.deinit();

    try std.testing.expect(!client.authenticated);
    try client.authenticate();
    try std.testing.expect(client.authenticated);
}

test "FuturesWsClient: subscribe returns valid message" {
    const allocator = std.testing.allocator;
    var client = try FuturesWsClient.init(allocator, null);
    defer client.deinit();

    const products = [_][]const u8{"PI_XBTUSD"};
    const msg = try client.subscribe(.book, &products);
    defer allocator.free(msg);

    try std.testing.expect(std.mem.indexOf(u8, msg, "\"event\":\"subscribe\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "\"PI_XBTUSD\"") != null);
}

test "FuturesWsClient: ping returns ping message" {
    const allocator = std.testing.allocator;
    var client = try FuturesWsClient.init(allocator, null);
    defer client.deinit();

    const msg = try client.ping();
    defer allocator.free(msg);

    try std.testing.expect(std.mem.indexOf(u8, msg, "\"event\":\"ping\"") != null);
}

test "Feed: name returns correct string" {
    try std.testing.expectEqualStrings("book", Feed.book.name());
    try std.testing.expectEqualStrings("ticker", Feed.ticker.name());
    try std.testing.expectEqualStrings("trade", Feed.trade.name());
    try std.testing.expectEqualStrings("fills", Feed.fills.name());
    try std.testing.expectEqualStrings("heartbeat", Feed.heartbeat.name());
}
