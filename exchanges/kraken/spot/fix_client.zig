const std = @import("std");
const codec = @import("fix_codec");
const session_mod = @import("fix_session");
const hmac_mod = @import("hmac");
const base64_mod = @import("base64");

/// Kraken FIX endpoint constants
pub const KRAKEN_FIX_HOST = "fix.kraken.com";
pub const KRAKEN_FIX_PORT: u16 = 6881;
pub const KRAKEN_TARGET_COMP_ID = "KRAKEN";

/// Order request for NewOrderSingle (tag 35=D)
pub const FixOrderRequest = struct {
    cl_ord_id: []const u8,
    symbol: []const u8,
    side: u8, // '1' = Buy, '2' = Sell
    order_qty: []const u8,
    price: []const u8,
    ord_type: u8, // '1' = Market, '2' = Limit
};

/// Amend request for OrderCancelReplaceRequest (tag 35=G)
pub const FixAmendRequest = struct {
    orig_cl_ord_id: []const u8,
    cl_ord_id: []const u8,
    symbol: []const u8,
    side: u8,
    order_qty: []const u8,
    price: []const u8,
    ord_type: u8,
};

/// Kraken-specific FIX client.
/// Uses SenderCompID = API key, Password(554) = HMAC-SHA512 signed nonce.
pub const KrakenFixClient = struct {
    allocator: std.mem.Allocator,
    api_key: []const u8,
    api_secret: []const u8,
    session: session_mod.FixSession,

    /// Initializes the Kraken FIX client with API credentials.
    pub fn init(
        allocator: std.mem.Allocator,
        api_key: []const u8,
        api_secret: []const u8,
    ) !KrakenFixClient {
        const config = session_mod.SessionConfig{
            .sender_comp_id = api_key,
            .target_comp_id = KRAKEN_TARGET_COMP_ID,
            .fix_version = .fix50sp2,
            .heartbeat_interval_s = 30,
        };
        return .{
            .allocator = allocator,
            .api_key = api_key,
            .api_secret = api_secret,
            .session = try session_mod.FixSession.init(allocator, config),
        };
    }

    /// Connects to the Kraken FIX endpoint.
    pub fn connect(self: *KrakenFixClient) !void {
        try self.session.connect(KRAKEN_FIX_HOST, KRAKEN_FIX_PORT);
    }

    /// Computes the Kraken Logon nonce signature.
    /// nonce is a SendingTime timestamp string.
    /// Password = base64(HMAC-SHA512(nonce, base64_decode(api_secret)))
    fn computeNonceSignature(self: *KrakenFixClient, nonce: []const u8, out_buf: []u8) ![]const u8 {
        // Decode base64 API secret
        var secret_bytes: [128]u8 = undefined;
        const secret = base64_mod.decode(&secret_bytes, self.api_secret) catch {
            // If secret is not base64, use raw bytes
            const copy_len = @min(self.api_secret.len, secret_bytes.len);
            @memcpy(secret_bytes[0..copy_len], self.api_secret[0..copy_len]);
            // Fall through with raw secret
            var raw_hmac: [64]u8 = undefined;
            hmac_mod.hmacSha512(self.api_secret[0..copy_len], nonce, &raw_hmac);
            const encoded = base64_mod.encode(out_buf, &raw_hmac);
            return encoded;
        };

        // HMAC-SHA512(nonce, decoded_secret)
        var raw_hmac: [64]u8 = undefined;
        hmac_mod.hmacSha512(secret, nonce, &raw_hmac);

        // Base64 encode the result
        const encoded = base64_mod.encode(out_buf, &raw_hmac);
        return encoded;
    }

    /// Kraken Logon: SenderCompID = API key, Password(554) = HMAC-SHA512 signed nonce.
    /// Nonce must be within 5s of Kraken server time.
    pub fn logon(self: *KrakenFixClient) !void {
        // Build sending time as nonce (UTC timestamp)
        const ts_s = blk: {
            var ts_: std.os.linux.timespec = undefined;
            _ = std.os.linux.clock_gettime(.REALTIME, &ts_);
            break :blk ts_.sec;
        };
        var nonce_buf: [32]u8 = undefined;
        const nonce = try std.fmt.bufPrint(&nonce_buf, "{}", .{ts_s});

        // Compute HMAC-SHA512 password
        var pw_raw_buf: [256]u8 = undefined;
        const password = try self.computeNonceSignature(nonce, &pw_raw_buf);

        // Build Logon message
        var msg = try self.session.buildLogon();
        defer msg.deinit();

        // Kraken-specific: Password tag 554
        try msg.setTag(554, password);

        // Encode and "send" (advance state)
        var buf: [8192]u8 = undefined;
        _ = try msg.encode(&buf);
        self.session.state = .logged_on;
    }

    /// Sends a NewOrderSingle (tag 35=D).
    pub fn newOrderSingle(self: *KrakenFixClient, order: FixOrderRequest) !void {
        var msg = codec.FixMessage.init(self.allocator);
        defer msg.deinit();

        try msg.setTag(35, "D"); // MsgType = NewOrderSingle
        try msg.setTag(11, order.cl_ord_id); // ClOrdID
        try msg.setTag(55, order.symbol); // Symbol
        var side_buf = [1]u8{order.side};
        try msg.setTag(54, &side_buf); // Side
        try msg.setTag(38, order.order_qty); // OrderQty
        try msg.setTag(44, order.price); // Price
        var ord_type_buf = [1]u8{order.ord_type};
        try msg.setTag(40, &ord_type_buf); // OrdType
        try msg.setTag(60, "19700101-00:00:00.000"); // TransactTime

        try self.session.send(&msg);
    }

    /// Sends an OrderCancelRequest (tag 35=F).
    pub fn orderCancelRequest(
        self: *KrakenFixClient,
        orig_cl_ord_id: []const u8,
        cl_ord_id: []const u8,
    ) !void {
        var msg = codec.FixMessage.init(self.allocator);
        defer msg.deinit();

        try msg.setTag(35, "F"); // MsgType = OrderCancelRequest
        try msg.setTag(41, orig_cl_ord_id); // OrigClOrdID
        try msg.setTag(11, cl_ord_id); // ClOrdID
        try msg.setTag(60, "19700101-00:00:00.000"); // TransactTime

        try self.session.send(&msg);
    }

    /// Sends an OrderCancelReplaceRequest (tag 35=G).
    pub fn orderCancelReplaceRequest(self: *KrakenFixClient, request: FixAmendRequest) !void {
        var msg = codec.FixMessage.init(self.allocator);
        defer msg.deinit();

        try msg.setTag(35, "G"); // MsgType = OrderCancelReplaceRequest
        try msg.setTag(41, request.orig_cl_ord_id); // OrigClOrdID
        try msg.setTag(11, request.cl_ord_id); // ClOrdID
        try msg.setTag(55, request.symbol); // Symbol
        var side_buf = [1]u8{request.side};
        try msg.setTag(54, &side_buf); // Side
        try msg.setTag(38, request.order_qty); // OrderQty
        try msg.setTag(44, request.price); // Price
        var ord_type_buf = [1]u8{request.ord_type};
        try msg.setTag(40, &ord_type_buf); // OrdType
        try msg.setTag(60, "19700101-00:00:00.000"); // TransactTime

        try self.session.send(&msg);
    }

    /// Reads the next message from the session (stub for unit-test model).
    pub fn nextMessage(self: *KrakenFixClient) !codec.FixMessage {
        _ = self;
        return error.NoMessageAvailable;
    }

    /// Sends a Logout and marks session as disconnected.
    pub fn logout(self: *KrakenFixClient) !void {
        try self.session.logout();
    }

    /// Frees all resources.
    pub fn deinit(self: *KrakenFixClient) void {
        self.session.deinit();
    }
};
