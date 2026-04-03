const std = @import("std");
const order_types = @import("order_types.zig");

pub const OrderId = order_types.OrderId;
pub const OrderType = order_types.OrderType;
pub const TimeInForce = order_types.TimeInForce;
pub const Side = order_types.Side;

/// All possible order statuses (FIX OrdStatus + internal states)
pub const OrdStatus = enum {
    pending_new,
    new,
    partially_filled,
    filled,
    cancelled,
    replaced,
    pending_cancel,
    rejected,
    suspended,
    pending_replace,
    expired,
    staged,
    validating,
    route_pending,
};

/// Execution type events that drive state transitions
pub const ExecType = enum {
    new,
    partial_fill,
    fill,
    cancelled,
    replaced,
    rejected,
    pending_cancel,
    pending_replace,
    expired,
    suspended,
    restated,
};

/// Order parameters for replace requests
pub const OrderParams = struct {
    quantity: ?i64,
    price: ?i64,
    tif: ?TimeInForce,
};

/// Fill information for execution reports
pub const FillInfo = struct {
    fill_qty: i64,
    fill_price: i64,
};

/// Full order record
pub const Order = struct {
    id: OrderId,
    instrument: []const u8,
    side: Side,
    order_type: OrderType,
    quantity: i64,
    price: ?i64,
    tif: TimeInForce,
    status: OrdStatus,
    created_at: u128,
    parent_id: ?OrderId,
    filled_qty: i64,
};

/// State machine for order lifecycle transitions
pub const OrderStateMachine = struct {
    pub fn init() OrderStateMachine {
        return .{};
    }

    /// Validate and apply a state transition.
    /// Returns the new OrdStatus or an error if the transition is illegal.
    pub fn transition(self: *OrderStateMachine, current: OrdStatus, event: ExecType) !OrdStatus {
        _ = self;
        // Terminal states cannot transition
        if (isTerminal(current)) return error.IllegalTransition;

        return switch (current) {
            .validating => switch (event) {
                .new => .pending_new,
                .rejected => .rejected,
                else => error.IllegalTransition,
            },
            .staged => switch (event) {
                .new => .pending_new,
                .rejected => .rejected,
                else => error.IllegalTransition,
            },
            .pending_new => switch (event) {
                .new => .new,
                .rejected => .rejected,
                .cancelled => .cancelled,
                else => error.IllegalTransition,
            },
            .route_pending => switch (event) {
                .new => .new,
                .rejected => .rejected,
                .cancelled => .cancelled,
                else => error.IllegalTransition,
            },
            .new => switch (event) {
                .partial_fill => .partially_filled,
                .fill => .filled,
                .cancelled => .cancelled,
                .replaced => .replaced,
                .pending_cancel => .pending_cancel,
                .pending_replace => .pending_replace,
                .expired => .expired,
                .suspended => .suspended,
                .restated => .new,
                else => error.IllegalTransition,
            },
            .partially_filled => switch (event) {
                .partial_fill => .partially_filled,
                .fill => .filled,
                .cancelled => .cancelled,
                .replaced => .replaced,
                .pending_cancel => .pending_cancel,
                .pending_replace => .pending_replace,
                .expired => .expired,
                .suspended => .suspended,
                .restated => .partially_filled,
                else => error.IllegalTransition,
            },
            .pending_cancel => switch (event) {
                .cancelled => .cancelled,
                .partial_fill => .partially_filled,
                .fill => .filled,
                .rejected => .new, // cancel rejected → back to new
                .restated => .pending_cancel,
                else => error.IllegalTransition,
            },
            .pending_replace => switch (event) {
                .replaced => .replaced,
                .partial_fill => .partially_filled,
                .fill => .filled,
                .rejected => .new, // replace rejected → back to new
                .restated => .pending_replace,
                else => error.IllegalTransition,
            },
            .suspended => switch (event) {
                .new => .new,
                .cancelled => .cancelled,
                .restated => .suspended,
                else => error.IllegalTransition,
            },
            // Terminal states handled above
            .filled, .cancelled, .replaced, .rejected, .expired => error.IllegalTransition,
        };
    }

    /// Returns true for terminal states where no further transitions are possible
    pub fn isTerminal(status: OrdStatus) bool {
        return switch (status) {
            .filled, .cancelled, .rejected, .expired => true,
            else => false,
        };
    }
};

// Forward declaration — implemented in separate files but referenced here by pointer
pub const PreTradeRisk = opaque {};
pub const EventStore = opaque {};

/// Order manager: integrates risk validation, state machine, and event store
pub const OrderManager = struct {
    allocator: std.mem.Allocator,
    risk: *anyopaque,
    store: *anyopaque,
    orders: std.AutoHashMap(OrderId, Order),
    next_id: OrderId,
    sm: OrderStateMachine,

    // Function pointers for risk validate and event store append, injected at init
    risk_validate_fn: *const fn (risk: *anyopaque, order: *const Order) bool,
    store_append_fn: *const fn (store: *anyopaque, data: []const u8) anyerror!u64,

    pub fn init(
        allocator: std.mem.Allocator,
        risk: *anyopaque,
        store: *anyopaque,
        risk_validate_fn: *const fn (risk: *anyopaque, order: *const Order) bool,
        store_append_fn: *const fn (store: *anyopaque, data: []const u8) anyerror!u64,
    ) !OrderManager {
        return OrderManager{
            .allocator = allocator,
            .risk = risk,
            .store = store,
            .orders = std.AutoHashMap(OrderId, Order).init(allocator),
            .next_id = 1,
            .sm = OrderStateMachine.init(),
            .risk_validate_fn = risk_validate_fn,
            .store_append_fn = store_append_fn,
        };
    }

    /// Submit a new order through the risk pipeline.
    /// Returns the assigned OrderId on success.
    pub fn submitOrder(self: *OrderManager, order_in: Order) !OrderId {
        // Validate via risk pipeline
        const passed = self.risk_validate_fn(self.risk, &order_in);
        if (!passed) return error.RiskRejected;

        const id = self.next_id;
        self.next_id += 1;

        var order = order_in;
        order.id = id;
        order.status = .pending_new;

        // Emit event
        var buf: [256]u8 = undefined;
        const event_data = try std.fmt.bufPrint(&buf, "submit:{d}", .{id});
        _ = try self.store_append_fn(self.store, event_data);

        try self.orders.put(id, order);
        return id;
    }

    /// Request cancellation of an order.
    pub fn cancelOrder(self: *OrderManager, id: OrderId) !void {
        const order_ptr = self.orders.getPtr(id) orelse return error.OrderNotFound;
        const new_status = try self.sm.transition(order_ptr.status, .pending_cancel);
        order_ptr.status = new_status;

        var buf: [64]u8 = undefined;
        const event_data = try std.fmt.bufPrint(&buf, "cancel:{d}", .{id});
        _ = try self.store_append_fn(self.store, event_data);
    }

    /// Request replacement of an order with new parameters.
    /// The original order must be in `new` or `partially_filled` state.
    pub fn replaceOrder(self: *OrderManager, id: OrderId, new_params: OrderParams) !OrderId {
        const order_ptr = self.orders.getPtr(id) orelse return error.OrderNotFound;

        // Only new or partially_filled can be replaced
        if (order_ptr.status != .new and order_ptr.status != .partially_filled) {
            return error.IllegalTransition;
        }

        const new_status = try self.sm.transition(order_ptr.status, .pending_replace);
        order_ptr.status = new_status;

        // Apply new parameters to create replacement order
        var replacement = order_ptr.*;
        const rep_id = self.next_id;
        self.next_id += 1;
        replacement.id = rep_id;
        replacement.parent_id = id;
        replacement.status = .pending_replace;

        if (new_params.quantity) |q| replacement.quantity = q;
        if (new_params.price) |p| replacement.price = p;
        if (new_params.tif) |t| replacement.tif = t;

        var buf: [128]u8 = undefined;
        const event_data = try std.fmt.bufPrint(&buf, "replace:{d}→{d}", .{ id, rep_id });
        _ = try self.store_append_fn(self.store, event_data);

        try self.orders.put(rep_id, replacement);
        return rep_id;
    }

    /// Process an execution report from the exchange.
    pub fn onExecution(self: *OrderManager, id: OrderId, exec: ExecType, fill: ?FillInfo) !void {
        const order_ptr = self.orders.getPtr(id) orelse return error.OrderNotFound;
        const new_status = try self.sm.transition(order_ptr.status, exec);
        order_ptr.status = new_status;

        if (fill) |f| {
            order_ptr.filled_qty += f.fill_qty;
        }

        var buf: [128]u8 = undefined;
        const event_data = try std.fmt.bufPrint(&buf, "exec:{d}:{s}", .{ id, @tagName(exec) });
        _ = try self.store_append_fn(self.store, event_data);
    }

    /// Retrieve a reference to an order by ID.
    pub fn getOrder(self: *OrderManager, id: OrderId) ?*const Order {
        return self.orders.getPtr(id);
    }

    pub fn deinit(self: *OrderManager) void {
        self.orders.deinit();
    }
};
