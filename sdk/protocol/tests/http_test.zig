// HTTP tests: request formatting, response parsing, chunked decoding, URL parsing

const std = @import("std");
const url_mod = @import("url");
const chunked_mod = @import("chunked");
const http_client = @import("http_client");

// ---- URL parsing tests ----

test "url: parse http with default port" {
    const u = try url_mod.parse("http://example.com/path");
    try std.testing.expectEqualStrings("http", u.scheme);
    try std.testing.expectEqualStrings("example.com", u.host);
    try std.testing.expectEqual(@as(u16, 80), u.port);
    try std.testing.expectEqualStrings("/path", u.path);
    try std.testing.expect(u.query == null);
}

test "url: parse https with default port" {
    const u = try url_mod.parse("https://api.kraken.com/0/public/Time");
    try std.testing.expectEqualStrings("https", u.scheme);
    try std.testing.expectEqualStrings("api.kraken.com", u.host);
    try std.testing.expectEqual(@as(u16, 443), u.port);
    try std.testing.expectEqualStrings("/0/public/Time", u.path);
    try std.testing.expect(u.query == null);
}

test "url: parse with explicit port" {
    const u = try url_mod.parse("http://localhost:8080/api");
    try std.testing.expectEqualStrings("http", u.scheme);
    try std.testing.expectEqualStrings("localhost", u.host);
    try std.testing.expectEqual(@as(u16, 8080), u.port);
    try std.testing.expectEqualStrings("/api", u.path);
}

test "url: parse with query string" {
    const u = try url_mod.parse("https://example.com/search?q=zig&page=1");
    try std.testing.expectEqualStrings("https", u.scheme);
    try std.testing.expectEqualStrings("example.com", u.host);
    try std.testing.expectEqualStrings("/search", u.path);
    try std.testing.expect(u.query != null);
    try std.testing.expectEqualStrings("q=zig&page=1", u.query.?);
}

test "url: parse root path" {
    const u = try url_mod.parse("https://example.com");
    try std.testing.expectEqualStrings("example.com", u.host);
    try std.testing.expectEqualStrings("/", u.path);
}

test "url: parse path with no query" {
    const u = try url_mod.parse("https://example.com/a/b/c");
    try std.testing.expectEqualStrings("/a/b/c", u.path);
    try std.testing.expect(u.query == null);
}

test "url: error on missing scheme" {
    const result = url_mod.parse("example.com/path");
    try std.testing.expectError(error.MissingScheme, result);
}

test "url: error on invalid scheme" {
    const result = url_mod.parse("ftp://example.com");
    try std.testing.expectError(error.InvalidScheme, result);
}

test "url: websocket scheme" {
    const u = try url_mod.parse("wss://ws.kraken.com/v2");
    try std.testing.expectEqualStrings("wss", u.scheme);
    try std.testing.expectEqual(@as(u16, 443), u.port);
}

// ---- Chunked decoding tests ----

test "chunked: single chunk" {
    const encoded = "5\r\nHello\r\n0\r\n\r\n";
    const decoded = try chunked_mod.decode(std.testing.allocator, encoded);
    defer std.testing.allocator.free(decoded);
    try std.testing.expectEqualStrings("Hello", decoded);
}

test "chunked: multiple chunks" {
    const encoded = "5\r\nHello\r\n6\r\n World\r\n0\r\n\r\n";
    const decoded = try chunked_mod.decode(std.testing.allocator, encoded);
    defer std.testing.allocator.free(decoded);
    try std.testing.expectEqualStrings("Hello World", decoded);
}

test "chunked: zero-length terminator only" {
    const encoded = "0\r\n\r\n";
    const decoded = try chunked_mod.decode(std.testing.allocator, encoded);
    defer std.testing.allocator.free(decoded);
    try std.testing.expectEqual(@as(usize, 0), decoded.len);
}

test "chunked: hex chunk size" {
    const encoded = "a\r\n0123456789\r\n0\r\n\r\n";
    const decoded = try chunked_mod.decode(std.testing.allocator, encoded);
    defer std.testing.allocator.free(decoded);
    try std.testing.expectEqualStrings("0123456789", decoded);
}

test "chunked: uppercase hex chunk size" {
    const encoded = "A\r\n0123456789\r\n0\r\n\r\n";
    const decoded = try chunked_mod.decode(std.testing.allocator, encoded);
    defer std.testing.allocator.free(decoded);
    try std.testing.expectEqualStrings("0123456789", decoded);
}

test "chunked: large chunk" {
    const allocator = std.testing.allocator;
    var encoded = std.ArrayList(u8).init(allocator);
    defer encoded.deinit();

    const chunk_data = "A" ** 256;
    try encoded.writer().print("100\r\n{s}\r\n0\r\n\r\n", .{chunk_data});

    const decoded = try chunked_mod.decode(allocator, encoded.items);
    defer allocator.free(decoded);
    try std.testing.expectEqual(@as(usize, 256), decoded.len);
    for (decoded) |b| try std.testing.expectEqual(@as(u8, 'A'), b);
}

// ---- HTTP request formatting tests ----

test "http: format GET request" {
    const allocator = std.testing.allocator;
    const u = try url_mod.parse("https://api.kraken.com/0/public/Time");

    var buf: [4096]u8 = undefined;
    const len = try http_client.formatRequest("GET", u, &.{}, null, &buf);
    const req = buf[0..len];

    try std.testing.expect(std.mem.startsWith(u8, req, "GET /0/public/Time HTTP/1.1\r\n"));
    try std.testing.expect(std.mem.indexOf(u8, req, "Host: api.kraken.com\r\n") != null);
    try std.testing.expect(std.mem.indexOf(u8, req, "\r\n\r\n") != null);
    _ = allocator;
}

test "http: format POST request with body" {
    const u = try url_mod.parse("https://api.kraken.com/0/private/Balance");
    const body = "nonce=12345&otp=";
    const headers = [_]http_client.Header{
        .{ .name = "Content-Type", .value = "application/x-www-form-urlencoded" },
        .{ .name = "API-Key", .value = "test-key" },
    };

    var buf: [4096]u8 = undefined;
    const len = try http_client.formatRequest("POST", u, &headers, body, &buf);
    const req = buf[0..len];

    try std.testing.expect(std.mem.startsWith(u8, req, "POST /0/private/Balance HTTP/1.1\r\n"));
    try std.testing.expect(std.mem.indexOf(u8, req, "Content-Type: application/x-www-form-urlencoded\r\n") != null);
    try std.testing.expect(std.mem.indexOf(u8, req, "API-Key: test-key\r\n") != null);
    try std.testing.expect(std.mem.endsWith(u8, req, body));
}

test "http: request includes Content-Length for POST" {
    const u = try url_mod.parse("http://example.com/api");
    const body = "hello=world";

    var buf: [4096]u8 = undefined;
    const len = try http_client.formatRequest("POST", u, &.{}, body, &buf);
    const req = buf[0..len];

    try std.testing.expect(std.mem.indexOf(u8, req, "Content-Length: 11\r\n") != null);
}

// ---- HTTP response parsing tests ----

test "http: parse 200 OK response" {
    const raw =
        "HTTP/1.1 200 OK\r\n" ++
        "Content-Type: application/json\r\n" ++
        "Content-Length: 15\r\n" ++
        "\r\n" ++
        "{\"status\":\"ok\"}";

    var resp = try http_client.parseResponse(std.testing.allocator, raw);
    defer resp.deinit();

    try std.testing.expectEqual(@as(u16, 200), resp.status);
    try std.testing.expectEqualStrings("{\"status\":\"ok\"}", resp.body);
}

test "http: parse 404 response" {
    const raw =
        "HTTP/1.1 404 Not Found\r\n" ++
        "Content-Length: 9\r\n" ++
        "\r\n" ++
        "Not Found";

    var resp = try http_client.parseResponse(std.testing.allocator, raw);
    defer resp.deinit();

    try std.testing.expectEqual(@as(u16, 404), resp.status);
    try std.testing.expectEqualStrings("Not Found", resp.body);
}

test "http: parse response headers" {
    const raw =
        "HTTP/1.1 200 OK\r\n" ++
        "Content-Type: application/json\r\n" ++
        "X-Custom: value\r\n" ++
        "Content-Length: 2\r\n" ++
        "\r\n" ++
        "{}";

    var resp = try http_client.parseResponse(std.testing.allocator, raw);
    defer resp.deinit();

    try std.testing.expectEqual(@as(u16, 200), resp.status);
    // Check that headers were parsed
    var found_ct = false;
    var found_custom = false;
    for (resp.headers) |h| {
        if (std.ascii.eqlIgnoreCase(h.name, "content-type")) found_ct = true;
        if (std.ascii.eqlIgnoreCase(h.name, "x-custom")) found_custom = true;
    }
    try std.testing.expect(found_ct);
    try std.testing.expect(found_custom);
}

test "http: parse chunked response" {
    const raw =
        "HTTP/1.1 200 OK\r\n" ++
        "Transfer-Encoding: chunked\r\n" ++
        "\r\n" ++
        "5\r\nHello\r\n" ++
        "6\r\n World\r\n" ++
        "0\r\n\r\n";

    var resp = try http_client.parseResponse(std.testing.allocator, raw);
    defer resp.deinit();

    try std.testing.expectEqual(@as(u16, 200), resp.status);
    try std.testing.expectEqualStrings("Hello World", resp.body);
}

test "http: GET request format has connection keep-alive" {
    const u = try url_mod.parse("https://example.com/test");
    var buf: [4096]u8 = undefined;
    const len = try http_client.formatRequest("GET", u, &.{}, null, &buf);
    const req = buf[0..len];
    try std.testing.expect(std.mem.indexOf(u8, req, "Connection: keep-alive\r\n") != null);
}

test "http: non-default port included in Host header" {
    const u = try url_mod.parse("http://example.com:8080/path");
    var buf: [4096]u8 = undefined;
    const len = try http_client.formatRequest("GET", u, &.{}, null, &buf);
    const req = buf[0..len];
    try std.testing.expect(std.mem.indexOf(u8, req, "Host: example.com:8080\r\n") != null);
}

test "http: URL with query string in request line" {
    const u = try url_mod.parse("https://example.com/search?q=zig");
    var buf: [4096]u8 = undefined;
    const len = try http_client.formatRequest("GET", u, &.{}, null, &buf);
    const req = buf[0..len];
    try std.testing.expect(std.mem.indexOf(u8, req, "GET /search?q=zig HTTP/1.1\r\n") != null);
}
