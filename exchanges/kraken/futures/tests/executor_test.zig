const std = @import("std");
const executor_mod = @import("futures_executor");
const oms_mod = @import("oms");

const FuturesExecutor = executor_mod.FuturesExecutor;
const ExchangeOrderId = executor_mod.ExchangeOrderId;
const MockExchangeResponse = executor_mod.MockExchangeResponse;

const OrderManager = oms_mod.OrderManager;
const Order = oms_mod.Order;
const OrdStatus = oms_mod.OrdStatus;
const ExecType = oms_mod.ExecType;
const FillInfo = oms_mod.FillInfo;

// order_types types re-exported by oms.zig
const OrderType = oms_mod.OrderType;
const TimeInForce = oms_mod.TimeInForce;
const Side = oms_mod.Side;

// --- Test helpers ---

fn alwaysPassRisk(_: *anyopaque, _: *const Order) bool {
    return true;
}

fn noopStore(_: *anyopaque, _: []const u8) anyerror!u64 {
    return 0;
}

var dummy_risk_obj: u8 = 0;
var dummy_store_obj: u8 = 0;

fn makeOms(allocator: std.mem.Allocator) !OrderManager {
    return OrderManager.init(
        allocator,
        @ptrCast(&dummy_risk_obj),
        @ptrCast(&dummy_store_obj),
        alwaysPassRisk,
        noopStore,
    );
}

fn makeFuturesOrder(id: oms_mod.OrderId) Order {
    return Order{
        .id = id,
        .instrument = "BTC-USD-PERP",
        .side = .buy,
        .order_type = .limit,
        .quantity = 10_000_000_000, // 100 contracts in fixed-point 1e8
        .price = 5_000_000_000_000, // 50000.0 USD
        .tif = .gtc,
        .status = .pending_new,
        .created_at = 0,
        .parent_id = null,
        .filled_qty = 0,
    };
}

// --- Tests ---

test "placeOrder: futures order submission drives OMS to new on acceptance" {
    var oms = try makeOms(std.testing.allocator);
    defer oms.deinit();

    var exec = try FuturesExecutor.init(std.testing.allocator, null, null, &oms);
    defer exec.deinit();

    const order_template = makeFuturesOrder(0);
    const oms_id = try oms.submitOrder(order_template);

    const before = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    try std.testing.expect(before.status == .pending_new);

    exec.injectResponse(.{
        .accepted = true,
        .order_id = "FUT_ORDER_001",
        .exec_type = .new,
        .fill_qty = null,
        .fill_price = null,
    });

    const order = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    const eid = try exec.placeOrder(order);

    const after = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    try std.testing.expect(after.status == .new);
    try std.testing.expectEqualStrings("FUT_ORDER_001", eid.asSlice());
}

test "placeOrder: exchange rejection drives OMS to rejected" {
    var oms = try makeOms(std.testing.allocator);
    defer oms.deinit();

    var exec = try FuturesExecutor.init(std.testing.allocator, null, null, &oms);
    defer exec.deinit();

    const order_template = makeFuturesOrder(0);
    const oms_id = try oms.submitOrder(order_template);

    exec.injectResponse(.{
        .accepted = false,
        .order_id = "",
        .exec_type = .rejected,
        .fill_qty = null,
        .fill_price = null,
    });

    const order = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    const result = exec.placeOrder(order);
    try std.testing.expectError(error.OrderRejected, result);

    const after = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    try std.testing.expect(after.status == .rejected);
}

test "cancelOrder: drives OMS to cancelled state" {
    var oms = try makeOms(std.testing.allocator);
    defer oms.deinit();

    var exec = try FuturesExecutor.init(std.testing.allocator, null, null, &oms);
    defer exec.deinit();

    const order_template = makeFuturesOrder(0);
    const oms_id = try oms.submitOrder(order_template);

    // Move to new
    try oms.onExecution(oms_id, .new, null);
    // Request cancel
    try oms.cancelOrder(oms_id);

    exec.injectResponse(.{
        .accepted = true,
        .order_id = "",
        .exec_type = .cancelled,
        .fill_qty = null,
        .fill_price = null,
    });

    const exchange_id = ExchangeOrderId.fromSlice("FUT_ORDER_001");
    try exec.cancelOrder(oms_id, exchange_id);

    const after = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    try std.testing.expect(after.status == .cancelled);
}

test "dead man's switch: setDeadManSwitch sends initial request" {
    var oms = try makeOms(std.testing.allocator);
    defer oms.deinit();

    var exec = try FuturesExecutor.init(std.testing.allocator, null, null, &oms);
    defer exec.deinit();

    try std.testing.expect(!exec.dms.enabled);
    try std.testing.expect(exec.dead_man_switch_send_count == 0);

    try exec.setDeadManSwitch(30);

    try std.testing.expect(exec.dms.enabled);
    try std.testing.expect(exec.dms.timeout_s == 30);
    try std.testing.expect(exec.dead_man_switch_send_count == 1);
}

test "dead man's switch: refreshDeadManSwitch increments send count" {
    var oms = try makeOms(std.testing.allocator);
    defer oms.deinit();

    var exec = try FuturesExecutor.init(std.testing.allocator, null, null, &oms);
    defer exec.deinit();

    try exec.setDeadManSwitch(30);
    try std.testing.expect(exec.dead_man_switch_send_count == 1);

    try exec.refreshDeadManSwitch();
    try std.testing.expect(exec.dead_man_switch_send_count == 2);

    try exec.refreshDeadManSwitch();
    try std.testing.expect(exec.dead_man_switch_send_count == 3);
}

test "dead man's switch: refresh when not enabled returns error" {
    var oms = try makeOms(std.testing.allocator);
    defer oms.deinit();

    var exec = try FuturesExecutor.init(std.testing.allocator, null, null, &oms);
    defer exec.deinit();

    const result = exec.refreshDeadManSwitch();
    try std.testing.expectError(error.DeadManSwitchNotEnabled, result);
}

test "dead man's switch: periodic refresh pattern" {
    var oms = try makeOms(std.testing.allocator);
    defer oms.deinit();

    var exec = try FuturesExecutor.init(std.testing.allocator, null, null, &oms);
    defer exec.deinit();

    // Simulate the pattern: set once, refresh multiple times
    try exec.setDeadManSwitch(60);
    var i: u32 = 0;
    while (i < 5) : (i += 1) {
        try exec.refreshDeadManSwitch();
    }
    // 1 initial + 5 refreshes = 6 total sends
    try std.testing.expect(exec.dead_man_switch_send_count == 6);
}

test "exchange ack drives OMS state correctly for futures" {
    var oms = try makeOms(std.testing.allocator);
    defer oms.deinit();

    var exec = try FuturesExecutor.init(std.testing.allocator, null, null, &oms);
    defer exec.deinit();

    const order_template = makeFuturesOrder(0);
    const oms_id = try oms.submitOrder(order_template);

    // Simulate: new -> partial_fill -> fill
    try exec.processExecutionReport(oms_id, .new, null);
    const s1 = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    try std.testing.expect(s1.status == .new);

    try exec.processExecutionReport(oms_id, .partial_fill, .{ .fill_qty = 5_000_000_000, .fill_price = 5_000_000_000_000 });
    const s2 = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    try std.testing.expect(s2.status == .partially_filled);
    try std.testing.expect(s2.filled_qty == 5_000_000_000);

    try exec.processExecutionReport(oms_id, .fill, .{ .fill_qty = 5_000_000_000, .fill_price = 5_000_000_000_000 });
    const s3 = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    try std.testing.expect(s3.status == .filled);
    try std.testing.expect(s3.filled_qty == 10_000_000_000);
}

test "ExchangeOrderId fromSlice and asSlice round-trip" {
    const s = "futures-order-id-12345";
    const eid = ExchangeOrderId.fromSlice(s);
    try std.testing.expectEqualStrings(s, eid.asSlice());
}

test "needsRefresh returns false when disabled" {
    const dms = executor_mod.DeadManSwitch.init();
    try std.testing.expect(!dms.needsRefresh(0));
    try std.testing.expect(!dms.needsRefresh(std.math.maxInt(u64)));
}

test "needsRefresh returns true when past half timeout" {
    var dms = executor_mod.DeadManSwitch.init();
    dms.enabled = true;
    dms.timeout_s = 30;
    dms.last_refresh_ns = 0;

    // Half of 30s = 15s = 15_000_000_000 ns
    // At exactly 15s, should need refresh
    try std.testing.expect(dms.needsRefresh(15_000_000_000));
    try std.testing.expect(dms.needsRefresh(20_000_000_000));
    // Before 15s, should not need refresh
    try std.testing.expect(!dms.needsRefresh(14_999_999_999));
}
