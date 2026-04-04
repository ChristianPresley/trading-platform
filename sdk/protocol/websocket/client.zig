// WebSocket RFC 6455 client
// Handles HTTP upgrade handshake, frame masking, ping/pong, control frames.

const std = @import("std");
const frame_mod = @import("frame");

pub const Opcode = frame_mod.Opcode;

pub const Message = struct {
    opcode: Opcode,
    payload: []const u8,
};

const WsUrl = struct {
    scheme: []const u8, // "ws" or "wss"
    host: []const u8,
    port: u16,
    path: []const u8,
};

fn parseWsUrl(url: []const u8) !WsUrl {
    var scheme: []const u8 = undefined;
    var rest: []const u8 = undefined;
    var default_port: u16 = undefined;

    if (std.mem.startsWith(u8, url, "wss://")) {
        scheme = "wss";
        rest = url[6..];
        default_port = 443;
    } else if (std.mem.startsWith(u8, url, "ws://")) {
        scheme = "ws";
        rest = url[5..];
        default_port = 80;
    } else {
        return error.InvalidScheme;
    }

    const path_start = std.mem.indexOf(u8, rest, "/") orelse rest.len;
    const host_port = rest[0..path_start];
    const path: []const u8 = if (path_start < rest.len) rest[path_start..] else "/";

    var host: []const u8 = undefined;
    var port: u16 = default_port;

    if (std.mem.indexOf(u8, host_port, ":")) |colon| {
        host = host_port[0..colon];
        port = std.fmt.parseInt(u16, host_port[colon + 1 ..], 10) catch return error.InvalidPort;
    } else {
        host = host_port;
    }

    return WsUrl{
        .scheme = scheme,
        .host = host,
        .port = port,
        .path = path,
    };
}

pub const WebSocketClient = struct {
    allocator: std.mem.Allocator,
    url: []const u8,
    parsed_url: WsUrl,
    socket: std.posix.socket_t,
    connected: bool,
    recv_buf: []u8,
    recv_len: usize,
    send_buf: []u8,
    // Assembled message for fragmented frames
    frag_payload: std.ArrayList(u8),
    frag_opcode: Opcode,
    in_fragment: bool,

    const RECV_BUF_SIZE = 1 << 20; // 1 MiB
    const SEND_BUF_SIZE = 65536;

    pub fn init(allocator: std.mem.Allocator, url: []const u8) !WebSocketClient {
        const parsed = try parseWsUrl(url);
        const url_dup = try allocator.dupe(u8, url);
        const recv_buf = try allocator.alloc(u8, RECV_BUF_SIZE);
        const send_buf = try allocator.alloc(u8, SEND_BUF_SIZE);
        return WebSocketClient{
            .allocator = allocator,
            .url = url_dup,
            .parsed_url = parsed,
            .socket = undefined,
            .connected = false,
            .recv_buf = recv_buf,
            .recv_len = 0,
            .send_buf = send_buf,
            .frag_payload = .{},
            .frag_opcode = .text,
            .in_fragment = false,
        };
    }

    pub fn connect(self: *WebSocketClient) !void {
        // Resolve host
        const address_list = try std.net.getAddressList(self.allocator, self.parsed_url.host, self.parsed_url.port);
        defer address_list.deinit();
        if (address_list.addrs.len == 0) return error.HostNotFound;

        const addr = address_list.addrs[0];
        const sock = try std.posix.socket(addr.any.family, std.posix.SOCK.STREAM, std.posix.IPPROTO.TCP);
        errdefer std.posix.close(sock);
        try std.posix.connect(sock, &addr.any, addr.getOsSockLen());
        self.socket = sock;

        // WebSocket upgrade handshake
        // Generate a random 16-byte key (simplified: use fixed pattern for non-security-critical use)
        const ws_key = "dGhlIHNhbXBsZSBub25jZQ=="; // "the sample nonce" base64

        var req_buf: [2048]u8 = undefined;
        const req = try std.fmt.bufPrint(&req_buf,
            "GET {s} HTTP/1.1\r\n" ++
                "Host: {s}\r\n" ++
                "Upgrade: websocket\r\n" ++
                "Connection: Upgrade\r\n" ++
                "Sec-WebSocket-Key: {s}\r\n" ++
                "Sec-WebSocket-Version: 13\r\n" ++
                "\r\n",
            .{ self.parsed_url.path, self.parsed_url.host, ws_key });

        var written: usize = 0;
        while (written < req.len) {
            const n = try std.posix.write(self.socket, req[written..]);
            written += n;
        }

        // Read upgrade response
        var resp_buf: [4096]u8 = undefined;
        var resp_len: usize = 0;
        while (resp_len < resp_buf.len) {
            const n = try std.posix.read(self.socket, resp_buf[resp_len..]);
            if (n == 0) return error.ConnectionClosed;
            resp_len += n;
            if (std.mem.indexOf(u8, resp_buf[0..resp_len], "\r\n\r\n") != null) break;
        }

        const resp = resp_buf[0..resp_len];
        if (!std.mem.startsWith(u8, resp, "HTTP/1.1 101")) {
            return error.UpgradeFailed;
        }

        self.connected = true;
    }

    pub fn send(self: *WebSocketClient, data: []const u8) !void {
        try self.sendFrame(.text, data);
    }

    pub fn sendBinary(self: *WebSocketClient, data: []const u8) !void {
        try self.sendFrame(.binary, data);
    }

    fn sendFrame(self: *WebSocketClient, opcode: Opcode, data: []const u8) !void {
        if (!self.connected) return error.NotConnected;

        // For large payloads, allocate a temporary buffer
        const mask_key = [4]u8{ 0x37, 0xfa, 0x21, 0x3d };
        const needed = 2 + 8 + 4 + data.len; // max header + mask + payload
        if (needed <= self.send_buf.len) {
            const frame_data = try frame_mod.encodeFrameWithKey(self.send_buf, opcode, data, true, mask_key);
            var written: usize = 0;
            while (written < frame_data.len) {
                const n = std.posix.write(self.socket, frame_data[written..]) catch return error.BrokenPipe;
                written += n;
            }
        } else {
            const tmp = try self.allocator.alloc(u8, needed);
            defer self.allocator.free(tmp);
            const frame_data = try frame_mod.encodeFrameWithKey(tmp, opcode, data, true, mask_key);
            var written: usize = 0;
            while (written < frame_data.len) {
                const n = std.posix.write(self.socket, frame_data[written..]) catch return error.BrokenPipe;
                written += n;
            }
        }
    }

    /// Receive the next data message. Handles ping/pong/close internally.
    /// Returned payload is valid until next call to receive or deinit.
    pub fn receive(self: *WebSocketClient) !Message {
        while (true) {
            // Try to parse a frame from recv_buf
            if (self.recv_len >= 2) {
                const frame_sz = frame_mod.frameSize(self.recv_buf[0..self.recv_len]) catch 0;
                if (frame_sz > 0 and self.recv_len >= frame_sz) {
                    var frm = try frame_mod.decodeFrame(self.recv_buf[0..frame_sz]);

                    // Unmask if needed
                    if (frm.mask_key) |mk| {
                        const payload_mut = self.recv_buf[self.recv_len - frm.payload.len .. self.recv_len];
                        frame_mod.unmaskPayload(payload_mut, mk);
                        frm.payload = payload_mut;
                    }

                    // Shift buffer
                    const remaining = self.recv_len - frame_sz;
                    if (remaining > 0) {
                        std.mem.copyForwards(u8, self.recv_buf[0..remaining], self.recv_buf[frame_sz..self.recv_len]);
                    }
                    self.recv_len = remaining;

                    // Handle control frames
                    switch (frm.opcode) {
                        .ping => {
                            // Send pong
                            var pong_buf: [128 + 14]u8 = undefined;
                            const pong_frame = try frame_mod.encodeFrame(&pong_buf, .pong, frm.payload, true);
                            _ = std.posix.write(self.socket, pong_frame) catch {};
                            continue;
                        },
                        .pong => {
                            // Ignore unsolicited pongs
                            continue;
                        },
                        .close => {
                            self.connected = false;
                            return error.ConnectionClosed;
                        },
                        .continuation => {
                            // Fragmented message continuation
                            try self.frag_payload.appendSlice(self.allocator, frm.payload);
                            if (frm.fin) {
                                const op = self.frag_opcode;
                                self.in_fragment = false;
                                return Message{
                                    .opcode = op,
                                    .payload = self.frag_payload.items,
                                };
                            }
                            continue;
                        },
                        .text, .binary => {
                            if (!frm.fin) {
                                // Start of fragmented message
                                self.frag_payload.clearRetainingCapacity();
                                try self.frag_payload.appendSlice(self.allocator, frm.payload);
                                self.frag_opcode = frm.opcode;
                                self.in_fragment = true;
                                continue;
                            }
                            return Message{
                                .opcode = frm.opcode,
                                .payload = frm.payload,
                            };
                        },
                        else => {
                            return error.UnknownOpcode;
                        },
                    }
                }
            }

            // Need more data
            if (self.recv_len >= self.recv_buf.len) return error.BufferFull;
            const n = try std.posix.read(self.socket, self.recv_buf[self.recv_len..]);
            if (n == 0) {
                self.connected = false;
                return error.ConnectionClosed;
            }
            self.recv_len += n;
        }
    }

    pub fn close(self: *WebSocketClient) !void {
        if (!self.connected) return;
        // Send close frame
        var buf: [8]u8 = undefined;
        const close_frame = try frame_mod.encodeFrame(&buf, .close, &.{}, true);
        _ = std.posix.write(self.socket, close_frame) catch {};
        self.connected = false;
    }

    pub fn deinit(self: *WebSocketClient) void {
        if (self.connected) {
            _ = self.close() catch {};
        }
        std.posix.close(self.socket);
        self.allocator.free(self.recv_buf);
        self.allocator.free(self.send_buf);
        self.allocator.free(self.url);
        self.frag_payload.deinit(self.allocator);
    }
};
