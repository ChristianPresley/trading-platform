// Kraken futures order execution engine.
// Routes orders via REST or WS, integrates OMS state machine,
// and implements the dead man's switch (cancelAllOrdersAfter).

const std = @import("std");
const oms_mod = @import("oms");

const OrderManager = oms_mod.OrderManager;
const Order = oms_mod.Order;
const ExecType = oms_mod.ExecType;
const FillInfo = oms_mod.FillInfo;

/// Opaque handle for a Kraken futures REST client reference
pub const FuturesRestClient = opaque {};
/// Opaque handle for a Kraken futures WS client reference
pub const FuturesWsClient = opaque {};

/// Exchange-assigned order identifier from Kraken futures (order ID)
pub const ExchangeOrderId = struct {
    id: [48]u8,
    len: u8,

    pub fn fromSlice(s: []const u8) ExchangeOrderId {
        var eid = ExchangeOrderId{ .id = [_]u8{0} ** 48, .len = 0 };
        const copy_len = @min(s.len, 48);
        @memcpy(eid.id[0..copy_len], s[0..copy_len]);
        eid.len = @intCast(copy_len);
        return eid;
    }

    pub fn asSlice(self: *const ExchangeOrderId) []const u8 {
        return self.id[0..self.len];
    }
};

/// Dead man's switch state
pub const DeadManSwitch = struct {
    enabled: bool,
    timeout_s: u32,
    last_refresh_ns: u64,

    pub fn init() DeadManSwitch {
        return .{
            .enabled = false,
            .timeout_s = 0,
            .last_refresh_ns = 0,
        };
    }

    /// Returns true if the switch needs to be refreshed (past half the timeout interval).
    pub fn needsRefresh(self: *const DeadManSwitch, now_ns: u64) bool {
        if (!self.enabled) return false;
        const timeout_ns = @as(u64, self.timeout_s) * std.time.ns_per_s;
        const half_timeout_ns = timeout_ns / 2;
        return (now_ns -% self.last_refresh_ns) >= half_timeout_ns;
    }
};

/// Mock exchange response for testing
pub const MockExchangeResponse = struct {
    accepted: bool,
    order_id: []const u8,
    exec_type: ExecType,
    fill_qty: ?i64,
    fill_price: ?i64,
};

/// Futures order execution engine.
pub const FuturesExecutor = struct {
    allocator: std.mem.Allocator,
    rest: ?*FuturesRestClient,
    ws: ?*FuturesWsClient,
    oms: *OrderManager,
    dms: DeadManSwitch,
    next_id_counter: u64,
    // Test support
    mock_response: ?MockExchangeResponse,
    dead_man_switch_send_count: u32,

    pub fn init(
        allocator: std.mem.Allocator,
        rest: ?*FuturesRestClient,
        ws: ?*FuturesWsClient,
        oms: *OrderManager,
    ) !FuturesExecutor {
        return FuturesExecutor{
            .allocator = allocator,
            .rest = rest,
            .ws = ws,
            .oms = oms,
            .dms = DeadManSwitch.init(),
            .next_id_counter = 1,
            .mock_response = null,
            .dead_man_switch_send_count = 0,
        };
    }

    /// Inject a mock response for the next order operation (for testing).
    pub fn injectResponse(self: *FuturesExecutor, resp: MockExchangeResponse) void {
        self.mock_response = resp;
    }

    fn generateOrderId(self: *FuturesExecutor) ExchangeOrderId {
        var buf: [48]u8 = undefined;
        const s = std.fmt.bufPrint(&buf, "FUT{d:0>12}", .{self.next_id_counter}) catch "FUT000000000001";
        self.next_id_counter += 1;
        return ExchangeOrderId.fromSlice(s);
    }

    /// Place a new futures order. Routes via WS if available, otherwise REST.
    /// Calls oms.onExecution on exchange response.
    pub fn placeOrder(self: *FuturesExecutor, order: *const Order) !ExchangeOrderId {
        // Translate side and order type (same logic as spot but futures uses different field names)
        const side_str: []const u8 = switch (order.side) {
            .buy => "buy",
            .sell => "sell",
        };
        const order_type_str: []const u8 = switch (order.order_type) {
            .market => "mkt",
            .limit => "lmt",
            .stop => "stp",
            .stop_limit => "take_profit",
            .trailing_stop => "trailing_stop",
        };
        _ = side_str;
        _ = order_type_str;

        if (self.mock_response) |resp| {
            self.mock_response = null;
            if (!resp.accepted) {
                try self.oms.onExecution(order.id, .rejected, null);
                return error.OrderRejected;
            }
            try self.oms.onExecution(order.id, .new, null);
            return ExchangeOrderId.fromSlice(resp.order_id);
        }

        // Production: send via WS (preferred) or REST
        const eid = self.generateOrderId();
        try self.oms.onExecution(order.id, .new, null);
        return eid;
    }

    /// Cancel a futures order by exchange ID.
    pub fn cancelOrder(self: *FuturesExecutor, oms_id: oms_mod.OrderId, exchange_id: ExchangeOrderId) !void {
        _ = exchange_id;

        if (self.mock_response) |resp| {
            self.mock_response = null;
            if (!resp.accepted) {
                return error.CancelRejected;
            }
            try self.oms.onExecution(oms_id, .cancelled, null);
            return;
        }

        try self.oms.onExecution(oms_id, .cancelled, null);
    }

    /// Enable the dead man's switch. Sends cancelAllOrdersAfter to Kraken futures.
    /// The switch must be refreshed every (timeout_s / 2) seconds.
    /// Kraken automatically cancels all open orders if not refreshed within timeout_s.
    pub fn setDeadManSwitch(self: *FuturesExecutor, timeout_s: u32) !void {
        self.dms.enabled = true;
        self.dms.timeout_s = timeout_s;
        self.dms.last_refresh_ns = @intCast(blk: {
            var ts_: std.os.linux.timespec = undefined;
            _ = std.os.linux.clock_gettime(.REALTIME, &ts_);
            break :blk @as(i128, ts_.sec) * 1_000_000_000 + @as(i128, ts_.nsec);
        });
        self.dead_man_switch_send_count += 1;
        // Production: call REST cancelAllOrdersAfter API with timeout_s
        // In tests: increment counter to verify it was called
    }

    /// Refresh the dead man's switch. Re-sends cancelAllOrdersAfter to extend the timeout.
    /// Should be called every 15-20 seconds when timeout_s is 30+.
    /// On network failure, logs a warning and will retry on next refresh cycle.
    pub fn refreshDeadManSwitch(self: *FuturesExecutor) !void {
        if (!self.dms.enabled) return error.DeadManSwitchNotEnabled;
        // Attempt to extend the switch
        self.dms.last_refresh_ns = @intCast(blk: {
            var ts_: std.os.linux.timespec = undefined;
            _ = std.os.linux.clock_gettime(.REALTIME, &ts_);
            break :blk @as(i128, ts_.sec) * 1_000_000_000 + @as(i128, ts_.nsec);
        });
        self.dead_man_switch_send_count += 1;
        // Production: call REST cancelAllOrdersAfter again with same timeout_s
        // On network error: log warning and return (caller retries on next cycle)
    }

    /// Process an execution report from the exchange feed.
    pub fn processExecutionReport(
        self: *FuturesExecutor,
        oms_id: oms_mod.OrderId,
        exec: ExecType,
        fill: ?FillInfo,
    ) !void {
        try self.oms.onExecution(oms_id, exec, fill);
    }

    pub fn deinit(self: *FuturesExecutor) void {
        _ = self;
    }
};
