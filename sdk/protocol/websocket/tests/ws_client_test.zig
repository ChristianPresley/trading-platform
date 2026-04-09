// Tests for WebSocket client: URL parsing, handshake formatting, struct init, state transitions
// Tests logic/parsing/formatting only — no actual network connections.

const std = @import("std");
const ws_client = @import("ws_client");
const frame_mod = @import("frame");

// ---- URL parsing tests ----

test "parseWsUrl: ws scheme with default port" {
    const u = try ws_client.parseWsUrl("ws://example.com/feed");
    try std.testing.expectEqualStrings("ws", u.scheme);
    try std.testing.expectEqualStrings("example.com", u.host);
    try std.testing.expectEqual(@as(u16, 80), u.port);
    try std.testing.expectEqualStrings("/feed", u.path);
}

test "parseWsUrl: wss scheme with default port" {
    const u = try ws_client.parseWsUrl("wss://ws.kraken.com/v2");
    try std.testing.expectEqualStrings("wss", u.scheme);
    try std.testing.expectEqualStrings("ws.kraken.com", u.host);
    try std.testing.expectEqual(@as(u16, 443), u.port);
    try std.testing.expectEqualStrings("/v2", u.path);
}

test "parseWsUrl: explicit port" {
    const u = try ws_client.parseWsUrl("ws://localhost:9443/stream");
    try std.testing.expectEqualStrings("ws", u.scheme);
    try std.testing.expectEqualStrings("localhost", u.host);
    try std.testing.expectEqual(@as(u16, 9443), u.port);
    try std.testing.expectEqualStrings("/stream", u.path);
}

test "parseWsUrl: wss with explicit port" {
    const u = try ws_client.parseWsUrl("wss://example.com:8443/ws");
    try std.testing.expectEqualStrings("wss", u.scheme);
    try std.testing.expectEqualStrings("example.com", u.host);
    try std.testing.expectEqual(@as(u16, 8443), u.port);
    try std.testing.expectEqualStrings("/ws", u.path);
}

test "parseWsUrl: no path defaults to /" {
    const u = try ws_client.parseWsUrl("ws://example.com");
    try std.testing.expectEqualStrings("example.com", u.host);
    try std.testing.expectEqual(@as(u16, 80), u.port);
    try std.testing.expectEqualStrings("/", u.path);
}

test "parseWsUrl: root path only" {
    const u = try ws_client.parseWsUrl("wss://example.com/");
    try std.testing.expectEqualStrings("example.com", u.host);
    try std.testing.expectEqualStrings("/", u.path);
}

test "parseWsUrl: deep path" {
    const u = try ws_client.parseWsUrl("wss://api.exchange.com/ws/v2/market/data");
    try std.testing.expectEqualStrings("api.exchange.com", u.host);
    try std.testing.expectEqualStrings("/ws/v2/market/data", u.path);
}

test "parseWsUrl: error on http scheme" {
    const result = ws_client.parseWsUrl("http://example.com/ws");
    try std.testing.expectError(error.InvalidScheme, result);
}

test "parseWsUrl: error on https scheme" {
    const result = ws_client.parseWsUrl("https://example.com/ws");
    try std.testing.expectError(error.InvalidScheme, result);
}

test "parseWsUrl: error on ftp scheme" {
    const result = ws_client.parseWsUrl("ftp://example.com");
    try std.testing.expectError(error.InvalidScheme, result);
}

test "parseWsUrl: error on missing scheme" {
    const result = ws_client.parseWsUrl("example.com/ws");
    try std.testing.expectError(error.InvalidScheme, result);
}

test "parseWsUrl: error on empty string" {
    const result = ws_client.parseWsUrl("");
    try std.testing.expectError(error.InvalidScheme, result);
}

test "parseWsUrl: error on invalid port" {
    const result = ws_client.parseWsUrl("ws://example.com:notaport/ws");
    try std.testing.expectError(error.InvalidPort, result);
}

test "parseWsUrl: error on port overflow" {
    const result = ws_client.parseWsUrl("ws://example.com:99999/ws");
    try std.testing.expectError(error.InvalidPort, result);
}

test "parseWsUrl: port zero" {
    // Port 0 is parseable as u16
    const u = try ws_client.parseWsUrl("ws://localhost:0/ws");
    try std.testing.expectEqual(@as(u16, 0), u.port);
}

test "parseWsUrl: maximum valid port" {
    const u = try ws_client.parseWsUrl("ws://localhost:65535/ws");
    try std.testing.expectEqual(@as(u16, 65535), u.port);
}

test "parseWsUrl: host with hyphens and subdomains" {
    const u = try ws_client.parseWsUrl("wss://my-api.sub.example.com/ws");
    try std.testing.expectEqualStrings("my-api.sub.example.com", u.host);
}

// ---- WebSocketClient init/deinit tests ----

test "WebSocketClient: init allocates buffers and parses URL" {
    const allocator = std.testing.allocator;
    var client = try ws_client.WebSocketClient.init(allocator, "ws://localhost:8080/feed");

    // Verify parsed URL fields
    try std.testing.expectEqualStrings("ws", client.parsed_url.scheme);
    try std.testing.expectEqualStrings("localhost", client.parsed_url.host);
    try std.testing.expectEqual(@as(u16, 8080), client.parsed_url.port);
    try std.testing.expectEqualStrings("/feed", client.parsed_url.path);

    // Verify URL was duplicated
    try std.testing.expectEqualStrings("ws://localhost:8080/feed", client.url);

    // Verify initial state
    try std.testing.expect(!client.connected);
    try std.testing.expectEqual(@as(usize, 0), client.recv_len);
    try std.testing.expect(!client.in_fragment);

    // Verify buffer sizes
    try std.testing.expectEqual(@as(usize, 1 << 20), client.recv_buf.len);
    try std.testing.expectEqual(@as(usize, 65536), client.send_buf.len);

    // Clean up — cannot call deinit directly as it tries to close socket.
    // Free manually instead.
    allocator.free(client.recv_buf);
    allocator.free(client.send_buf);
    allocator.free(client.url);
    client.frag_payload.deinit(allocator);
}

test "WebSocketClient: init with wss URL" {
    const allocator = std.testing.allocator;
    var client = try ws_client.WebSocketClient.init(allocator, "wss://ws.kraken.com/v2");

    try std.testing.expectEqualStrings("wss", client.parsed_url.scheme);
    try std.testing.expectEqualStrings("ws.kraken.com", client.parsed_url.host);
    try std.testing.expectEqual(@as(u16, 443), client.parsed_url.port);
    try std.testing.expectEqualStrings("/v2", client.parsed_url.path);

    allocator.free(client.recv_buf);
    allocator.free(client.send_buf);
    allocator.free(client.url);
    client.frag_payload.deinit(allocator);
}

test "WebSocketClient: init error on invalid URL" {
    const allocator = std.testing.allocator;
    const result = ws_client.WebSocketClient.init(allocator, "http://example.com/ws");
    try std.testing.expectError(error.InvalidScheme, result);
}

test "WebSocketClient: sendFrame returns NotConnected when not connected" {
    const allocator = std.testing.allocator;
    var client = try ws_client.WebSocketClient.init(allocator, "ws://localhost:8080/feed");
    defer {
        allocator.free(client.recv_buf);
        allocator.free(client.send_buf);
        allocator.free(client.url);
        client.frag_payload.deinit(allocator);
    }

    // Client starts not connected
    try std.testing.expect(!client.connected);

    // send should fail with NotConnected
    const result_text = client.send("hello");
    try std.testing.expectError(error.NotConnected, result_text);

    // sendBinary should also fail with NotConnected
    const result_bin = client.sendBinary("binary data");
    try std.testing.expectError(error.NotConnected, result_bin);
}

test "WebSocketClient: close is no-op when not connected" {
    const allocator = std.testing.allocator;
    var client = try ws_client.WebSocketClient.init(allocator, "ws://localhost:8080/feed");
    defer {
        allocator.free(client.recv_buf);
        allocator.free(client.send_buf);
        allocator.free(client.url);
        client.frag_payload.deinit(allocator);
    }

    // close on a non-connected client should not error
    try client.close();
    try std.testing.expect(!client.connected);
}

// ---- Message struct tests ----

test "Message: text message construction" {
    const payload = "hello world";
    const msg = ws_client.Message{
        .opcode = .text,
        .payload = payload,
    };
    try std.testing.expectEqual(ws_client.Opcode.text, msg.opcode);
    try std.testing.expectEqualStrings("hello world", msg.payload);
}

test "Message: binary message construction" {
    const payload = [_]u8{ 0x01, 0x02, 0x03 };
    const msg = ws_client.Message{
        .opcode = .binary,
        .payload = &payload,
    };
    try std.testing.expectEqual(ws_client.Opcode.binary, msg.opcode);
    try std.testing.expectEqual(@as(usize, 3), msg.payload.len);
}

test "Message: empty payload" {
    const msg = ws_client.Message{
        .opcode = .text,
        .payload = "",
    };
    try std.testing.expectEqual(@as(usize, 0), msg.payload.len);
}

// ---- Opcode re-export tests ----

test "Opcode values match RFC 6455" {
    try std.testing.expectEqual(@as(u4, 0), @intFromEnum(ws_client.Opcode.continuation));
    try std.testing.expectEqual(@as(u4, 1), @intFromEnum(ws_client.Opcode.text));
    try std.testing.expectEqual(@as(u4, 2), @intFromEnum(ws_client.Opcode.binary));
    try std.testing.expectEqual(@as(u4, 8), @intFromEnum(ws_client.Opcode.close));
    try std.testing.expectEqual(@as(u4, 9), @intFromEnum(ws_client.Opcode.ping));
    try std.testing.expectEqual(@as(u4, 10), @intFromEnum(ws_client.Opcode.pong));
}

// ---- Frame encoding integration tests (client perspective) ----
// These verify the frame module functions that sendFrame relies on.

test "frame encode: text frame matches expected wire format" {
    const payload = "Hello";
    var buf: [256]u8 = undefined;
    const mask_key = [4]u8{ 0x37, 0xfa, 0x21, 0x3d };
    const encoded = try frame_mod.encodeFrameWithKey(&buf, .text, payload, true, mask_key);

    // First byte: FIN=1, opcode=text(1) => 0x81
    try std.testing.expectEqual(@as(u8, 0x81), encoded[0]);

    // Second byte: MASK=1, len=5 => 0x85
    try std.testing.expectEqual(@as(u8, 0x85), encoded[1]);

    // Bytes 2-5: mask key
    try std.testing.expectEqual(@as(u8, 0x37), encoded[2]);
    try std.testing.expectEqual(@as(u8, 0xfa), encoded[3]);
    try std.testing.expectEqual(@as(u8, 0x21), encoded[4]);
    try std.testing.expectEqual(@as(u8, 0x3d), encoded[5]);

    // Total: 2 (header) + 4 (mask) + 5 (payload) = 11
    try std.testing.expectEqual(@as(usize, 11), encoded.len);

    // Decode and unmask to verify round-trip
    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expect(frm.fin);
    try std.testing.expectEqual(frame_mod.Opcode.text, frm.opcode);
    try std.testing.expect(frm.mask_key != null);

    var payload_copy: [64]u8 = undefined;
    @memcpy(payload_copy[0..frm.payload.len], frm.payload);
    frame_mod.unmaskPayload(payload_copy[0..frm.payload.len], frm.mask_key.?);
    try std.testing.expectEqualStrings("Hello", payload_copy[0..frm.payload.len]);
}

test "frame encode: empty payload masked frame" {
    var buf: [64]u8 = undefined;
    const mask_key = [4]u8{ 0x37, 0xfa, 0x21, 0x3d };
    const encoded = try frame_mod.encodeFrameWithKey(&buf, .text, "", true, mask_key);

    // FIN=1, opcode=text => 0x81
    try std.testing.expectEqual(@as(u8, 0x81), encoded[0]);
    // MASK=1, len=0 => 0x80
    try std.testing.expectEqual(@as(u8, 0x80), encoded[1]);
    // 2 header + 4 mask + 0 payload = 6
    try std.testing.expectEqual(@as(usize, 6), encoded.len);
}

test "frame encode: binary frame with mask" {
    const payload = [_]u8{ 0xDE, 0xAD, 0xBE, 0xEF };
    var buf: [64]u8 = undefined;
    const mask_key = [4]u8{ 0x37, 0xfa, 0x21, 0x3d };
    const encoded = try frame_mod.encodeFrameWithKey(&buf, .binary, &payload, true, mask_key);

    // FIN=1, opcode=binary(2) => 0x82
    try std.testing.expectEqual(@as(u8, 0x82), encoded[0]);
    // MASK=1, len=4 => 0x84
    try std.testing.expectEqual(@as(u8, 0x84), encoded[1]);

    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expectEqual(frame_mod.Opcode.binary, frm.opcode);
}

test "frame encode: close frame with mask" {
    var buf: [16]u8 = undefined;
    const mask_key = [4]u8{ 0x37, 0xfa, 0x21, 0x3d };
    const encoded = try frame_mod.encodeFrameWithKey(&buf, .close, &.{}, true, mask_key);

    // FIN=1, opcode=close(8) => 0x88
    try std.testing.expectEqual(@as(u8, 0x88), encoded[0]);
    // MASK=1, len=0 => 0x80
    try std.testing.expectEqual(@as(u8, 0x80), encoded[1]);
    // 2 header + 4 mask + 0 payload = 6
    try std.testing.expectEqual(@as(usize, 6), encoded.len);
}

test "frame encode: buffer too small returns error" {
    var buf: [4]u8 = undefined;
    const result = frame_mod.encodeFrame(&buf, .text, "This is too long for the buffer", false);
    try std.testing.expectError(error.BufferTooSmall, result);
}

// ---- sendFrame needed buffer size calculation ----
// Verify the formula: 2 + 8 + 4 + data.len covers the worst case

test "frame: max header overhead for large payload" {
    // For payloads > 65535: header = 2 + 8 (extended len) + 4 (mask) = 14 bytes
    const allocator = std.testing.allocator;
    const large_payload = try allocator.alloc(u8, 70000);
    defer allocator.free(large_payload);
    @memset(large_payload, 'X');

    const buf = try allocator.alloc(u8, 14 + 70000);
    defer allocator.free(buf);

    const mask_key = [4]u8{ 0x37, 0xfa, 0x21, 0x3d };
    const encoded = try frame_mod.encodeFrameWithKey(buf, .text, large_payload, true, mask_key);

    // Verify 64-bit length indicator
    try std.testing.expectEqual(@as(u8, 127), encoded[1] & 0x7f);

    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expectEqual(@as(usize, 70000), frm.payload.len);
}

test "frame: medium payload uses 16-bit length" {
    // For payloads 126..65535: header = 2 + 2 (extended len) + 4 (mask) = 8 bytes
    var payload: [200]u8 = undefined;
    @memset(&payload, 'Y');

    var buf: [214]u8 = undefined; // 8 + 200 + some margin
    const mask_key = [4]u8{ 0x37, 0xfa, 0x21, 0x3d };
    const encoded = try frame_mod.encodeFrameWithKey(&buf, .binary, &payload, true, mask_key);

    // Verify 16-bit length indicator
    try std.testing.expectEqual(@as(u8, 126), encoded[1] & 0x7f);
    try std.testing.expectEqual(@as(usize, 200 + 8), encoded.len); // 8 header + 200 payload
}

test "frame: small payload uses 7-bit length" {
    const payload = "short";
    var buf: [64]u8 = undefined;
    const mask_key = [4]u8{ 0x37, 0xfa, 0x21, 0x3d };
    const encoded = try frame_mod.encodeFrameWithKey(&buf, .text, payload, true, mask_key);

    // len <= 125 => 7-bit length, total header = 2 + 4 = 6
    try std.testing.expectEqual(@as(u8, 5), encoded[1] & 0x7f);
    try std.testing.expectEqual(@as(usize, 5 + 6), encoded.len); // 6 header + 5 payload
}

// ---- Fragment state tests ----

test "WebSocketClient: initial fragment state" {
    const allocator = std.testing.allocator;
    var client = try ws_client.WebSocketClient.init(allocator, "ws://localhost/ws");
    defer {
        allocator.free(client.recv_buf);
        allocator.free(client.send_buf);
        allocator.free(client.url);
        client.frag_payload.deinit(allocator);
    }

    try std.testing.expect(!client.in_fragment);
    try std.testing.expectEqual(ws_client.Opcode.text, client.frag_opcode);
    try std.testing.expectEqual(@as(usize, 0), client.frag_payload.items.len);
}

// ---- URL parsing boundary tests ----

test "parseWsUrl: ws scheme only (no host)" {
    // "ws://" has no host, which is valid parse but yields empty host
    const u = try ws_client.parseWsUrl("ws://");
    try std.testing.expectEqualStrings("", u.host);
    try std.testing.expectEqualStrings("/", u.path);
}

test "parseWsUrl: host with trailing slash only" {
    const u = try ws_client.parseWsUrl("wss://example.com/");
    try std.testing.expectEqualStrings("example.com", u.host);
    try std.testing.expectEqualStrings("/", u.path);
    try std.testing.expectEqual(@as(u16, 443), u.port);
}

test "parseWsUrl: port at boundary 1" {
    const u = try ws_client.parseWsUrl("ws://host:1/path");
    try std.testing.expectEqual(@as(u16, 1), u.port);
}

test "parseWsUrl: port 443 explicit with ws scheme" {
    // ws:// with port 443 (unusual but valid)
    const u = try ws_client.parseWsUrl("ws://host:443/path");
    try std.testing.expectEqual(@as(u16, 443), u.port);
    try std.testing.expectEqualStrings("ws", u.scheme);
}

test "parseWsUrl: error on empty port" {
    const result = ws_client.parseWsUrl("ws://host:/path");
    try std.testing.expectError(error.InvalidPort, result);
}

// ---- Multiple init/cleanup cycles ----

test "WebSocketClient: multiple init cycles do not leak" {
    const allocator = std.testing.allocator;

    // The testing allocator will detect leaks if we forget to free
    var i: usize = 0;
    while (i < 5) : (i += 1) {
        var client = try ws_client.WebSocketClient.init(allocator, "ws://localhost:9090/test");
        allocator.free(client.recv_buf);
        allocator.free(client.send_buf);
        allocator.free(client.url);
        client.frag_payload.deinit(allocator);
    }
}

// ---- Frame decode for receive path ----
// Verify the decode path that the receive loop relies on.

test "frame decode: server text frame (unmasked) simulates receive" {
    // Server sends unmasked frames to client
    var buf: [256]u8 = undefined;
    const payload = "{\"event\":\"heartbeat\"}";
    const encoded = try frame_mod.encodeFrame(&buf, .text, payload, false);

    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expect(frm.fin);
    try std.testing.expectEqual(frame_mod.Opcode.text, frm.opcode);
    try std.testing.expect(frm.mask_key == null);
    try std.testing.expectEqualStrings(payload, frm.payload);
}

test "frame decode: ping frame simulates server ping" {
    var buf: [64]u8 = undefined;
    const encoded = try frame_mod.encodeFrame(&buf, .ping, "keepalive", false);

    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expectEqual(frame_mod.Opcode.ping, frm.opcode);
    try std.testing.expectEqualStrings("keepalive", frm.payload);
}

test "frame decode: close frame simulates server close" {
    var buf: [16]u8 = undefined;
    const encoded = try frame_mod.encodeFrame(&buf, .close, &.{}, false);

    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expectEqual(frame_mod.Opcode.close, frm.opcode);
    try std.testing.expectEqual(@as(usize, 0), frm.payload.len);
}

test "frame decode: pong frame" {
    var buf: [64]u8 = undefined;
    const encoded = try frame_mod.encodeFrame(&buf, .pong, "pong-data", false);

    const frm = try frame_mod.decodeFrame(encoded);
    try std.testing.expectEqual(frame_mod.Opcode.pong, frm.opcode);
    try std.testing.expectEqualStrings("pong-data", frm.payload);
}

test "frameSize: matches encoded length for masked text" {
    var buf: [64]u8 = undefined;
    const mask_key = [4]u8{ 0x37, 0xfa, 0x21, 0x3d };
    const encoded = try frame_mod.encodeFrameWithKey(&buf, .text, "test", true, mask_key);

    const sz = try frame_mod.frameSize(encoded);
    try std.testing.expectEqual(encoded.len, sz);
}

test "frameSize: matches encoded length for unmasked binary" {
    var buf: [256]u8 = undefined;
    const payload = [_]u8{0xFF} ** 130;
    const encoded = try frame_mod.encodeFrame(&buf, .binary, &payload, false);

    const sz = try frame_mod.frameSize(encoded);
    try std.testing.expectEqual(encoded.len, sz);
}

// ---- Recv buffer boundary ----

test "WebSocketClient: recv_buf starts empty" {
    const allocator = std.testing.allocator;
    var client = try ws_client.WebSocketClient.init(allocator, "ws://localhost/ws");
    defer {
        allocator.free(client.recv_buf);
        allocator.free(client.send_buf);
        allocator.free(client.url);
        client.frag_payload.deinit(allocator);
    }

    try std.testing.expectEqual(@as(usize, 0), client.recv_len);

    // recv_buf is allocated but recv_len indicates nothing has been read
    try std.testing.expect(client.recv_buf.len > 0);
}
