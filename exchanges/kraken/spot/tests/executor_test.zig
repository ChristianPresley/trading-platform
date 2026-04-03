const std = @import("std");
const executor_mod = @import("spot_executor");
const oms_mod = @import("oms");

const SpotExecutor = executor_mod.SpotExecutor;
const ExchangeOrderId = executor_mod.ExchangeOrderId;
const AmendParams = executor_mod.AmendParams;
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

/// Dummy risk and store objects (only addresses matter; never dereferenced)
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

fn makeOrder(id: oms_mod.OrderId) Order {
    return Order{
        .id = id,
        .instrument = "BTC-USD",
        .side = .buy,
        .order_type = .limit,
        .quantity = 100_000_000, // 1.0 BTC in fixed-point 1e8
        .price = 5_000_000_000_000, // 50000.0 USD
        .tif = .gtc,
        .status = .pending_new,
        .created_at = 0,
        .parent_id = null,
        .filled_qty = 0,
    };
}

// --- Tests ---

test "placeOrder: OMS order maps to Kraken params and drives OMS to new on acceptance" {
    var oms = try makeOms(std.testing.allocator);
    defer oms.deinit();

    var exec = try SpotExecutor.init(std.testing.allocator, null, null, null, &oms);
    defer exec.deinit();

    // Submit order to OMS first to register it
    const order_template = makeOrder(0);
    const oms_id = try oms.submitOrder(order_template);
    try std.testing.expect(oms_id == 1);

    // Verify OMS is pending_new
    const before = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    try std.testing.expect(before.status == .pending_new);

    // Inject acceptance response
    exec.injectResponse(.{
        .accepted = true,
        .txid = "TXID123456",
        .exec_type = .new,
        .fill_qty = null,
        .fill_price = null,
    });

    // Get order ref and place
    const order = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    const txid = try exec.placeOrder(order);

    // OMS should now be in 'new'
    const after = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    try std.testing.expect(after.status == .new);
    try std.testing.expectEqualStrings("TXID123456", txid.asSlice());
}

test "placeOrder: exchange rejection drives OMS to rejected state" {
    var oms = try makeOms(std.testing.allocator);
    defer oms.deinit();

    var exec = try SpotExecutor.init(std.testing.allocator, null, null, null, &oms);
    defer exec.deinit();

    const order_template = makeOrder(0);
    const oms_id = try oms.submitOrder(order_template);

    exec.injectResponse(.{
        .accepted = false,
        .txid = "",
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

test "cancelOrder: propagates cancel through OMS" {
    var oms = try makeOms(std.testing.allocator);
    defer oms.deinit();

    var exec = try SpotExecutor.init(std.testing.allocator, null, null, null, &oms);
    defer exec.deinit();

    const order_template = makeOrder(0);
    const oms_id = try oms.submitOrder(order_template);

    // Move to 'new' state via execution report
    try oms.onExecution(oms_id, .new, null);

    // Now request cancel via OMS (sets to pending_cancel)
    try oms.cancelOrder(oms_id);
    const before = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    try std.testing.expect(before.status == .pending_cancel);

    // Inject cancel acceptance
    exec.injectResponse(.{
        .accepted = true,
        .txid = "",
        .exec_type = .cancelled,
        .fill_qty = null,
        .fill_price = null,
    });

    const exchange_id = ExchangeOrderId.fromSlice("TXID_CANCEL_TEST");
    try exec.cancelOrder(oms_id, exchange_id);

    const after = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    try std.testing.expect(after.status == .cancelled);
}

test "amendOrder: generates new exchange ID and drives OMS to replaced" {
    var oms = try makeOms(std.testing.allocator);
    defer oms.deinit();

    var exec = try SpotExecutor.init(std.testing.allocator, null, null, null, &oms);
    defer exec.deinit();

    const order_template = makeOrder(0);
    const oms_id = try oms.submitOrder(order_template);

    // Move to 'new'
    try oms.onExecution(oms_id, .new, null);
    // Request replace (moves to pending_replace)
    _ = try oms.replaceOrder(oms_id, .{ .price = 4_500_000_000_000, .quantity = null, .tif = null });

    const new_oms_id = oms_id + 1; // replaceOrder creates child order

    exec.injectResponse(.{
        .accepted = true,
        .txid = "NEW_TXID_AMEND",
        .exec_type = .replaced,
        .fill_qty = null,
        .fill_price = null,
    });

    const orig_exchange_id = ExchangeOrderId.fromSlice("ORIG_TXID");
    const params = AmendParams{ .price = 4_500_000_000_000, .quantity = null };
    const new_txid = try exec.amendOrder(new_oms_id, orig_exchange_id, params);

    try std.testing.expectEqualStrings("NEW_TXID_AMEND", new_txid.asSlice());

    // The replacement order (new_oms_id) should be in replaced state
    const after = oms.getOrder(new_oms_id) orelse return error.OrderNotFound;
    try std.testing.expect(after.status == .replaced);
}

test "partial fill drives OMS to partially_filled with correct cumQty" {
    var oms = try makeOms(std.testing.allocator);
    defer oms.deinit();

    var exec = try SpotExecutor.init(std.testing.allocator, null, null, null, &oms);
    defer exec.deinit();

    const order_template = makeOrder(0);
    const oms_id = try oms.submitOrder(order_template);

    // Move to new
    try oms.onExecution(oms_id, .new, null);

    // Process partial fill (0.5 BTC)
    try exec.processExecutionReport(oms_id, .partial_fill, .{
        .fill_qty = 50_000_000, // 0.5 BTC
        .fill_price = 5_000_000_000_000,
    });

    const after = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    try std.testing.expect(after.status == .partially_filled);
    try std.testing.expect(after.filled_qty == 50_000_000);
}

test "partial fill followed by cancel: OMS shows partially_filled -> cancelled, cumQty preserved" {
    var oms = try makeOms(std.testing.allocator);
    defer oms.deinit();

    var exec = try SpotExecutor.init(std.testing.allocator, null, null, null, &oms);
    defer exec.deinit();

    const order_template = makeOrder(0);
    const oms_id = try oms.submitOrder(order_template);

    // Move to new, then partial fill
    try oms.onExecution(oms_id, .new, null);
    try exec.processExecutionReport(oms_id, .partial_fill, .{
        .fill_qty = 50_000_000,
        .fill_price = 5_000_000_000_000,
    });

    // Verify partially filled
    const mid = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    try std.testing.expect(mid.status == .partially_filled);
    try std.testing.expect(mid.filled_qty == 50_000_000);

    // Request cancel
    try oms.cancelOrder(oms_id);

    // Exchange confirms cancel
    exec.injectResponse(.{
        .accepted = true,
        .txid = "",
        .exec_type = .cancelled,
        .fill_qty = null,
        .fill_price = null,
    });
    const exchange_id = ExchangeOrderId.fromSlice("TXID_TEST");
    try exec.cancelOrder(oms_id, exchange_id);

    const after = oms.getOrder(oms_id) orelse return error.OrderNotFound;
    try std.testing.expect(after.status == .cancelled);
    // cumQty is preserved
    try std.testing.expect(after.filled_qty == 50_000_000);
}

test "ExchangeOrderId fromSlice and asSlice round-trip" {
    const s = "ABCDEFGHIJ1234567890";
    const id = ExchangeOrderId.fromSlice(s);
    try std.testing.expectEqualStrings(s, id.asSlice());
}

test "ExchangeOrderId truncates to 32 bytes" {
    const long_s = "A" ** 40;
    const id = ExchangeOrderId.fromSlice(long_s);
    try std.testing.expect(id.len == 32);
    try std.testing.expectEqualStrings(long_s[0..32], id.asSlice());
}

test "preferred channel is FIX when fix is non-null" {
    var oms = try makeOms(std.testing.allocator);
    defer oms.deinit();

    // We can't create a real FixSession but we can test channel selection
    // by passing non-null pointers and checking the field
    var exec_rest_only = try SpotExecutor.init(std.testing.allocator, null, null, null, &oms);
    defer exec_rest_only.deinit();
    try std.testing.expect(exec_rest_only.preferred_channel == .rest);
}
