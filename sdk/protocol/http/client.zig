// HTTP/1.1 client with connection pooling

const std = @import("std");
const url_mod = @import("url");
const chunked_mod = @import("chunked");

pub const Header = struct {
    name: []const u8,
    value: []const u8,
};

pub const Response = struct {
    allocator: std.mem.Allocator,
    status: u16,
    headers: []Header,
    body: []const u8,

    pub fn deinit(self: *Response) void {
        for (self.headers) |h| {
            self.allocator.free(h.name);
            self.allocator.free(h.value);
        }
        self.allocator.free(self.headers);
        self.allocator.free(self.body);
    }
};

/// Parse an HTTP/1.1 response from raw bytes.
pub fn parseResponse(allocator: std.mem.Allocator, data: []const u8) !Response {
    // Find end of headers (\r\n\r\n or \n\n)
    const header_end = std.mem.indexOf(u8, data, "\r\n\r\n") orelse
        std.mem.indexOf(u8, data, "\n\n") orelse
        return error.InvalidResponse;

    const sep_len: usize = if (std.mem.indexOf(u8, data, "\r\n\r\n") != null) 4 else 2;
    const header_section = data[0..header_end];
    const body_data = data[header_end + sep_len ..];

    // Parse status line
    const first_line_end = std.mem.indexOf(u8, header_section, "\r\n") orelse
        std.mem.indexOf(u8, header_section, "\n") orelse
        header_section.len;
    const status_line = header_section[0..first_line_end];

    // "HTTP/1.1 200 OK"
    if (status_line.len < 12) return error.InvalidStatusLine;
    if (!std.mem.startsWith(u8, status_line, "HTTP/")) return error.InvalidStatusLine;

    const space1 = std.mem.indexOf(u8, status_line, " ") orelse return error.InvalidStatusLine;
    const code_str = status_line[space1 + 1 .. space1 + 4];
    const status_code = std.fmt.parseInt(u16, code_str, 10) catch return error.InvalidStatusCode;

    // Parse headers
    var headers_list: std.ArrayList(Header) = .empty;
    errdefer {
        for (headers_list.items) |h| {
            allocator.free(h.name);
            allocator.free(h.value);
        }
        headers_list.deinit(allocator);
    }

    const header_nl = if (std.mem.indexOf(u8, header_section, "\r\n") != null) "\r\n" else "\n";
    var line_iter = std.mem.splitSequence(u8, header_section[first_line_end + header_nl.len ..], header_nl);
    var content_length: ?usize = null;
    var is_chunked = false;

    while (line_iter.next()) |line| {
        if (line.len == 0) continue;
        const colon = std.mem.indexOf(u8, line, ":") orelse continue;
        const name = std.mem.trim(u8, line[0..colon], " \t");
        const value = std.mem.trim(u8, line[colon + 1 ..], " \t");

        const name_dup = try allocator.dupe(u8, name);
        errdefer allocator.free(name_dup);
        const value_dup = try allocator.dupe(u8, value);
        errdefer allocator.free(value_dup);

        // Check for Content-Length
        if (std.ascii.eqlIgnoreCase(name, "content-length")) {
            content_length = std.fmt.parseInt(usize, value, 10) catch null;
        }
        // Check for Transfer-Encoding: chunked
        if (std.ascii.eqlIgnoreCase(name, "transfer-encoding") and
            std.mem.indexOf(u8, value, "chunked") != null)
        {
            is_chunked = true;
        }

        try headers_list.append(allocator, .{ .name = name_dup, .value = value_dup });
    }

    // Extract body
    var body: []const u8 = undefined;
    if (is_chunked) {
        body = try chunked_mod.decode(allocator, body_data);
    } else if (content_length) |cl| {
        if (cl > body_data.len) return error.BodyTruncated;
        body = try allocator.dupe(u8, body_data[0..cl]);
    } else {
        // Read until connection close
        body = try allocator.dupe(u8, body_data);
    }

    return Response{
        .allocator = allocator,
        .status = status_code,
        .headers = try headers_list.toOwnedSlice(allocator),
        .body = body,
    };
}

/// Format an HTTP request into buf.
/// Returns the number of bytes written.
pub fn formatRequest(
    method: []const u8,
    url: url_mod.Url,
    extra_headers: []const Header,
    body: ?[]const u8,
    buf: []u8,
) !usize {
    var pos: usize = 0;

    // Helper to append a slice to buf
    const append = struct {
        fn f(b: []u8, p: *usize, data: []const u8) !void {
            if (p.* + data.len > b.len) return error.NoSpaceLeft;
            @memcpy(b[p.* .. p.* + data.len], data);
            p.* += data.len;
        }
    }.f;

    // Request line
    try append(buf, &pos, method);
    try append(buf, &pos, " ");
    try append(buf, &pos, url.path);
    if (url.query) |q| {
        try append(buf, &pos, "?");
        try append(buf, &pos, q);
    }
    try append(buf, &pos, " HTTP/1.1\r\n");

    // Host header
    try append(buf, &pos, "Host: ");
    try append(buf, &pos, url.host);
    if ((std.mem.eql(u8, url.scheme, "http") and url.port != 80) or
        (std.mem.eql(u8, url.scheme, "https") and url.port != 443))
    {
        const port_str = std.fmt.bufPrint(buf[pos..], ":{d}", .{url.port}) catch return error.NoSpaceLeft;
        pos += port_str.len;
    }
    try append(buf, &pos, "\r\n");

    // Standard headers
    try append(buf, &pos, "Connection: keep-alive\r\n");
    try append(buf, &pos, "User-Agent: trading-platform/1.0\r\n");
    try append(buf, &pos, "Accept: application/json\r\n");

    // Body length
    if (body) |b| {
        const cl_str = std.fmt.bufPrint(buf[pos..], "Content-Length: {d}\r\n", .{b.len}) catch return error.NoSpaceLeft;
        pos += cl_str.len;
    }

    // Extra headers
    for (extra_headers) |h| {
        try append(buf, &pos, h.name);
        try append(buf, &pos, ": ");
        try append(buf, &pos, h.value);
        try append(buf, &pos, "\r\n");
    }

    try append(buf, &pos, "\r\n");

    // Body
    if (body) |b| {
        try append(buf, &pos, b);
    }

    return pos;
}

const PooledConnection = struct {
    host: []const u8,
    port: u16,
    socket: std.posix.socket_t,
    in_use: bool,
};

pub const HttpClient = struct {
    allocator: std.mem.Allocator,
    connections: std.ArrayList(PooledConnection),
    max_pool_size: usize,
    request_buf: [65536]u8,
    response_buf: [1 << 20]u8, // 1 MiB

    pub fn init(allocator: std.mem.Allocator) !HttpClient {
        return HttpClient{
            .allocator = allocator,
            .connections = .{},
            .max_pool_size = 16,
            .request_buf = undefined,
            .response_buf = undefined,
        };
    }

    fn getOrCreateConnection(self: *HttpClient, host: []const u8, port: u16) !std.posix.socket_t {
        // Look for existing idle connection
        for (self.connections.items) |*conn| {
            if (!conn.in_use and std.mem.eql(u8, conn.host, host) and conn.port == port) {
                conn.in_use = true;
                return conn.socket;
            }
        }

        // Evict an idle connection if pool is at capacity
        if (self.connections.items.len >= self.max_pool_size) {
            for (self.connections.items, 0..) |*conn, i| {
                if (!conn.in_use) {
                    std.posix.close(conn.socket);
                    self.allocator.free(conn.host);
                    _ = self.connections.swapRemove(self.allocator, i);
                    break;
                }
            }
        }

        // Create new connection
        const address_list = try std.net.getAddressList(self.allocator, host, port);
        defer address_list.deinit();
        if (address_list.addrs.len == 0) return error.HostNotFound;

        const addr = address_list.addrs[0];
        const sock = try std.posix.socket(addr.any.family, std.posix.SOCK.STREAM, std.posix.IPPROTO.TCP);
        errdefer std.posix.close(sock);
        try std.posix.connect(sock, &addr.any, addr.getOsSockLen());

        const host_dup = try self.allocator.dupe(u8, host);
        try self.connections.append(self.allocator, .{
            .host = host_dup,
            .port = port,
            .socket = sock,
            .in_use = true,
        });
        return sock;
    }

    fn releaseConnection(self: *HttpClient, sock: std.posix.socket_t) void {
        for (self.connections.items) |*conn| {
            if (conn.socket == sock) {
                conn.in_use = false;
                return;
            }
        }
    }

    fn sendRequest(self: *HttpClient, url_str: []const u8, method: []const u8, body: ?[]const u8, extra_headers: []const Header) !Response {
        const url = try url_mod.parse(url_str);
        const sock = try self.getOrCreateConnection(url.host, url.port);
        errdefer self.releaseConnection(sock);

        const req_len = try formatRequest(method, url, extra_headers, body, &self.request_buf);
        var written: usize = 0;
        while (written < req_len) {
            const n = try std.posix.write(sock, self.request_buf[written..req_len]);
            written += n;
        }

        // Read response
        var total_read: usize = 0;
        while (total_read < self.response_buf.len) {
            const n = std.posix.read(sock, self.response_buf[total_read..]) catch break;
            if (n == 0) break;
            total_read += n;
            // Heuristic: if we've found \r\n\r\n and have content-length bytes, stop
            if (total_read > 4 and
                std.mem.indexOf(u8, self.response_buf[0..total_read], "\r\n\r\n") != null)
            {
                // Check if we have full body
                const header_end = std.mem.indexOf(u8, self.response_buf[0..total_read], "\r\n\r\n").?;
                const headers_section = self.response_buf[0..header_end];
                if (std.mem.indexOf(u8, headers_section, "Transfer-Encoding: chunked") != null) {
                    // For chunked, check for terminal 0\r\n\r\n
                    if (std.mem.indexOf(u8, self.response_buf[header_end..total_read], "0\r\n\r\n") != null) break;
                } else if (std.mem.indexOf(u8, headers_section, "Content-Length:")) |_| {
                    break; // Simplified: assume we got it all
                } else {
                    break;
                }
            }
        }

        const resp = try parseResponse(self.allocator, self.response_buf[0..total_read]);
        self.releaseConnection(sock);
        return resp;
    }

    pub fn get(self: *HttpClient, url: []const u8) !Response {
        return self.sendRequest(url, "GET", null, &.{});
    }

    pub fn post(self: *HttpClient, url: []const u8, body: []const u8, headers: []const Header) !Response {
        return self.sendRequest(url, "POST", body, headers);
    }

    pub fn deinit(self: *HttpClient) void {
        for (self.connections.items) |conn| {
            std.posix.close(conn.socket);
            self.allocator.free(conn.host);
        }
        self.connections.deinit(self.allocator);
    }
};
