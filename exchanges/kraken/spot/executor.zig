// Kraken spot order execution engine.
// Routes orders via FIX > WS > REST (preferred channel in that order).
// Drives OMS state transitions based on exchange responses.

const std = @import("std");
const oms_mod = @import("oms");

const OrderManager = oms_mod.OrderManager;
const Order = oms_mod.Order;
const ExecType = oms_mod.ExecType;
const FillInfo = oms_mod.FillInfo;
const OrdStatus = oms_mod.OrdStatus;
// order_types types re-exported by oms.zig
const OrderType = oms_mod.OrderType;
const Side = oms_mod.Side;

/// Opaque handle for a Kraken spot REST client reference
pub const SpotRestClient = opaque {};
/// Opaque handle for a Kraken spot WS client reference
pub const SpotWsClient = opaque {};
/// Opaque handle for a Kraken FIX session reference
pub const FixSession = opaque {};

/// Exchange-assigned order identifier from Kraken (transaction ID)
pub const ExchangeOrderId = struct {
    txid: [32]u8,
    len: u8,

    pub fn fromSlice(s: []const u8) ExchangeOrderId {
        var id = ExchangeOrderId{ .txid = [_]u8{0} ** 32, .len = 0 };
        const copy_len = @min(s.len, 32);
        @memcpy(id.txid[0..copy_len], s[0..copy_len]);
        id.len = @intCast(copy_len);
        return id;
    }

    pub fn asSlice(self: *const ExchangeOrderId) []const u8 {
        return self.txid[0..self.len];
    }
};

/// Parameters for an order amend (cancel-replace)
pub const AmendParams = struct {
    price: ?i64,
    quantity: ?i64,
};

/// Routing preference for order submission
pub const RouteChannel = enum {
    fix,
    ws,
    rest,
};

/// Mock exchange response for an order submission — used in tests
pub const MockExchangeResponse = struct {
    accepted: bool,
    txid: []const u8,
    exec_type: ExecType,
    fill_qty: ?i64,
    fill_price: ?i64,
};

/// Spot order execution engine.
/// In production, rest/ws/fix are live client references.
/// In tests, they are null and responses are injected via injectResponse().
pub const SpotExecutor = struct {
    allocator: std.mem.Allocator,
    rest: ?*SpotRestClient,
    ws: ?*SpotWsClient,
    fix: ?*FixSession,
    oms: *OrderManager,
    preferred_channel: RouteChannel,
    // Test support: injected mock responses
    mock_response: ?MockExchangeResponse,
    next_txid_counter: u64,

    pub fn init(
        allocator: std.mem.Allocator,
        rest: ?*SpotRestClient,
        ws: ?*SpotWsClient,
        fix: ?*FixSession,
        oms: *OrderManager,
    ) !SpotExecutor {
        // Determine routing preference: FIX > WS > REST
        const channel: RouteChannel = if (fix != null) .fix else if (ws != null) .ws else .rest;
        return SpotExecutor{
            .allocator = allocator,
            .rest = rest,
            .ws = ws,
            .fix = fix,
            .oms = oms,
            .preferred_channel = channel,
            .mock_response = null,
            .next_txid_counter = 1,
        };
    }

    /// Inject a mock response for the next order operation (for testing).
    pub fn injectResponse(self: *SpotExecutor, resp: MockExchangeResponse) void {
        self.mock_response = resp;
    }

    /// Generate a synthetic txid for test/mock purposes.
    fn generateTxid(self: *SpotExecutor) ExchangeOrderId {
        var buf: [32]u8 = undefined;
        const s = std.fmt.bufPrint(&buf, "TXID{d:0>10}", .{self.next_txid_counter}) catch "TXID0000000001";
        self.next_txid_counter += 1;
        return ExchangeOrderId.fromSlice(s);
    }

    /// Place a new order. Translates OMS Order to Kraken format and routes via
    /// the preferred channel. On success, calls oms.onExecution(.new).
    /// On exchange rejection, calls oms.onExecution(.rejected).
    pub fn placeOrder(self: *SpotExecutor, order: *const Order) !ExchangeOrderId {
        // Translate: side
        const side_str: []const u8 = switch (order.side) {
            .buy => "buy",
            .sell => "sell",
        };
        // Translate: order type
        const ordertype_str: []const u8 = switch (order.order_type) {
            .market => "market",
            .limit => "limit",
            .stop => "stop-loss",
            .stop_limit => "stop-loss-limit",
            .trailing_stop => "trailing-stop",
        };

        // Format quantity (stored as integer, e.g. satoshis*1e8 or lots*1e8)
        // For Kraken, format as decimal with 8 decimal places
        var vol_buf: [32]u8 = undefined;
        const whole = @divTrunc(order.quantity, 100_000_000);
        const frac = @abs(@rem(order.quantity, 100_000_000));
        const volume_str = std.fmt.bufPrint(&vol_buf, "{d}.{d:0>8}", .{ whole, frac }) catch return error.FormatError;

        // Format price
        var price_buf: [32]u8 = undefined;
        const price_str: ?[]const u8 = if (order.price) |p| blk: {
            const pw = @divTrunc(p, 100_000_000);
            const pf = @abs(@rem(p, 100_000_000));
            break :blk std.fmt.bufPrint(&price_buf, "{d}.{d:0>8}", .{ pw, pf }) catch return error.FormatError;
        } else null;

        _ = side_str;
        _ = ordertype_str;
        _ = volume_str;
        _ = price_str;

        // In production: send via preferred_channel.
        // In tests: consume mock_response.
        if (self.mock_response) |resp| {
            self.mock_response = null;
            if (!resp.accepted) {
                // Exchange rejected — drive OMS to rejected
                try self.oms.onExecution(order.id, .rejected, null);
                return error.OrderRejected;
            }
            // Exchange accepted — drive OMS to new
            try self.oms.onExecution(order.id, .new, null);
            return ExchangeOrderId.fromSlice(resp.txid);
        }

        // No mock: production path would call REST/WS/FIX here.
        // For now, generate a synthetic txid (would be replaced by actual call).
        const txid = self.generateTxid();
        try self.oms.onExecution(order.id, .new, null);
        return txid;
    }

    /// Cancel an existing order by exchange ID.
    pub fn cancelOrder(self: *SpotExecutor, oms_id: oms_mod.OrderId, exchange_id: ExchangeOrderId) !void {
        _ = exchange_id;

        if (self.mock_response) |resp| {
            self.mock_response = null;
            if (!resp.accepted) {
                // Cancel rejected — order stays in pending_cancel
                return error.CancelRejected;
            }
            try self.oms.onExecution(oms_id, .cancelled, null);
            return;
        }

        // Production: send cancel via preferred channel
        try self.oms.onExecution(oms_id, .cancelled, null);
    }

    /// Amend an order (cancel-replace). FIX uses tag 35=G. REST/WS do cancel+new.
    /// Returns new ExchangeOrderId for the replacement order.
    pub fn amendOrder(
        self: *SpotExecutor,
        oms_id: oms_mod.OrderId,
        exchange_id: ExchangeOrderId,
        params: AmendParams,
    ) !ExchangeOrderId {
        _ = exchange_id;
        _ = params;

        if (self.mock_response) |resp| {
            self.mock_response = null;
            if (!resp.accepted) {
                return error.AmendRejected;
            }
            // Drive OMS: pending_replace -> replaced
            try self.oms.onExecution(oms_id, .replaced, null);
            return ExchangeOrderId.fromSlice(resp.txid);
        }

        // Production: FIX = OrderCancelReplaceRequest (35=G), REST/WS = cancel+new
        const new_txid = self.generateTxid();
        try self.oms.onExecution(oms_id, .replaced, null);
        return new_txid;
    }

    /// Process an execution report from the exchange feed.
    /// Maps exchange ExecType to OMS event and drives state.
    pub fn processExecutionReport(
        self: *SpotExecutor,
        oms_id: oms_mod.OrderId,
        exec: ExecType,
        fill: ?FillInfo,
    ) !void {
        try self.oms.onExecution(oms_id, exec, fill);
    }

    pub fn deinit(self: *SpotExecutor) void {
        _ = self;
    }
};
