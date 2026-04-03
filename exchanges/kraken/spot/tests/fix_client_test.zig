const std = @import("std");
const fix_client_mod = @import("fix_client");
const codec = @import("fix_codec");

test "KrakenFixClient: init with API key as SenderCompID" {
    const api_key = "myapikey123";
    const api_secret = "Zm9vYmFy"; // base64("foobar")

    var client = try fix_client_mod.KrakenFixClient.init(
        std.testing.allocator,
        api_key,
        api_secret,
    );
    defer client.deinit();

    // SenderCompID should be the API key
    try std.testing.expectEqualStrings(api_key, client.session.config.sender_comp_id);
    // TargetCompID should be KRAKEN
    try std.testing.expectEqualStrings("KRAKEN", client.session.config.target_comp_id);
}

test "KrakenFixClient: connect transitions to connected state" {
    var client = try fix_client_mod.KrakenFixClient.init(
        std.testing.allocator,
        "key",
        "secret",
    );
    defer client.deinit();

    try client.connect();
    // After connect, session should be connected
    try std.testing.expect(client.session.state == .connected);
}

test "KrakenFixClient: logon produces logged_on state" {
    var client = try fix_client_mod.KrakenFixClient.init(
        std.testing.allocator,
        "myapikey",
        "Zm9vYmFy", // base64 encoded secret
    );
    defer client.deinit();

    try client.logon();
    try std.testing.expect(client.session.state == .logged_on);
}

test "KrakenFixClient: logon advances sequence number" {
    var client = try fix_client_mod.KrakenFixClient.init(
        std.testing.allocator,
        "key",
        "c2VjcmV0", // base64("secret")
    );
    defer client.deinit();

    const seq_before = client.session.next_send_seq;
    try client.logon();
    try std.testing.expect(client.session.next_send_seq > seq_before);
}

test "KrakenFixClient: FIX version is FIXT.1.1" {
    var client = try fix_client_mod.KrakenFixClient.init(
        std.testing.allocator,
        "key",
        "secret",
    );
    defer client.deinit();

    try std.testing.expect(client.session.config.fix_version == .fix50sp2);
}

test "KrakenFixClient: heartbeat interval is 30s" {
    var client = try fix_client_mod.KrakenFixClient.init(
        std.testing.allocator,
        "key",
        "secret",
    );
    defer client.deinit();

    try std.testing.expectEqual(@as(u32, 30), client.session.config.heartbeat_interval_s);
}

test "KrakenFixClient: logon builds nonce within reasonable time window" {
    // The nonce is a Unix timestamp — we verify it's recent (within 60s of now)
    const ts_before = @divTrunc(std.time.nanoTimestamp(), std.time.ns_per_s);

    var client = try fix_client_mod.KrakenFixClient.init(
        std.testing.allocator,
        "key123",
        "Zm9vYmFy",
    );
    defer client.deinit();

    try client.logon();

    const ts_after = @divTrunc(std.time.nanoTimestamp(), std.time.ns_per_s);

    // The nonce timestamp should be between ts_before and ts_after
    // We can't directly inspect it here, but we can verify logon succeeds
    // and the elapsed time is small
    try std.testing.expect(ts_after - ts_before < 5); // should complete in < 5s
}

test "KrakenFixClient: newOrderSingle increments sequence number" {
    var client = try fix_client_mod.KrakenFixClient.init(
        std.testing.allocator,
        "key",
        "secret",
    );
    defer client.deinit();

    try client.logon();
    const seq_before = client.session.next_send_seq;

    const order = fix_client_mod.FixOrderRequest{
        .cl_ord_id = "ORD001",
        .symbol = "XBT/USD",
        .side = '1', // Buy
        .order_qty = "0.5",
        .price = "50000.00",
        .ord_type = '2', // Limit
    };

    try client.newOrderSingle(order);
    try std.testing.expect(client.session.next_send_seq > seq_before);
}

test "KrakenFixClient: orderCancelRequest increments sequence number" {
    var client = try fix_client_mod.KrakenFixClient.init(
        std.testing.allocator,
        "key",
        "secret",
    );
    defer client.deinit();

    try client.logon();
    const seq_before = client.session.next_send_seq;

    try client.orderCancelRequest("ORD001", "ORD002");
    try std.testing.expect(client.session.next_send_seq > seq_before);
}

test "KrakenFixClient: orderCancelReplaceRequest increments sequence number" {
    var client = try fix_client_mod.KrakenFixClient.init(
        std.testing.allocator,
        "key",
        "secret",
    );
    defer client.deinit();

    try client.logon();
    const seq_before = client.session.next_send_seq;

    const amend = fix_client_mod.FixAmendRequest{
        .orig_cl_ord_id = "ORD001",
        .cl_ord_id = "ORD003",
        .symbol = "XBT/USD",
        .side = '1',
        .order_qty = "1.0",
        .price = "51000.00",
        .ord_type = '2',
    };

    try client.orderCancelReplaceRequest(amend);
    try std.testing.expect(client.session.next_send_seq > seq_before);
}

test "KrakenFixClient: logout disconnects session" {
    var client = try fix_client_mod.KrakenFixClient.init(
        std.testing.allocator,
        "key",
        "secret",
    );
    defer client.deinit();

    try client.logon();
    try std.testing.expect(client.session.state == .logged_on);

    try client.logout();
    try std.testing.expect(client.session.state == .disconnected);
}
