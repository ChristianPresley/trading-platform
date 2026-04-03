const std = @import("std");
const oms = @import("oms");

const OrdStatus = oms.OrdStatus;
const ExecType = oms.ExecType;
const OrderStateMachine = oms.OrderStateMachine;

test "OrderStateMachine: pending_new → new on new exec" {
    var sm = OrderStateMachine.init();
    const result = try sm.transition(.pending_new, .new);
    try std.testing.expectEqual(OrdStatus.new, result);
}

test "OrderStateMachine: pending_new → rejected on rejected exec" {
    var sm = OrderStateMachine.init();
    const result = try sm.transition(.pending_new, .rejected);
    try std.testing.expectEqual(OrdStatus.rejected, result);
}

test "OrderStateMachine: new → partially_filled on partial_fill" {
    var sm = OrderStateMachine.init();
    const result = try sm.transition(.new, .partial_fill);
    try std.testing.expectEqual(OrdStatus.partially_filled, result);
}

test "OrderStateMachine: new → filled on fill" {
    var sm = OrderStateMachine.init();
    const result = try sm.transition(.new, .fill);
    try std.testing.expectEqual(OrdStatus.filled, result);
}

test "OrderStateMachine: new → cancelled on cancelled" {
    var sm = OrderStateMachine.init();
    const result = try sm.transition(.new, .cancelled);
    try std.testing.expectEqual(OrdStatus.cancelled, result);
}

test "OrderStateMachine: new → pending_cancel on pending_cancel" {
    var sm = OrderStateMachine.init();
    const result = try sm.transition(.new, .pending_cancel);
    try std.testing.expectEqual(OrdStatus.pending_cancel, result);
}

test "OrderStateMachine: new → pending_replace on pending_replace" {
    var sm = OrderStateMachine.init();
    const result = try sm.transition(.new, .pending_replace);
    try std.testing.expectEqual(OrdStatus.pending_replace, result);
}

test "OrderStateMachine: new → expired on expired" {
    var sm = OrderStateMachine.init();
    const result = try sm.transition(.new, .expired);
    try std.testing.expectEqual(OrdStatus.expired, result);
}

test "OrderStateMachine: partially_filled → filled on fill" {
    var sm = OrderStateMachine.init();
    const result = try sm.transition(.partially_filled, .fill);
    try std.testing.expectEqual(OrdStatus.filled, result);
}

test "OrderStateMachine: partially_filled → cancelled on cancelled" {
    var sm = OrderStateMachine.init();
    const result = try sm.transition(.partially_filled, .cancelled);
    try std.testing.expectEqual(OrdStatus.cancelled, result);
}

test "OrderStateMachine: pending_cancel → cancelled on cancelled" {
    var sm = OrderStateMachine.init();
    const result = try sm.transition(.pending_cancel, .cancelled);
    try std.testing.expectEqual(OrdStatus.cancelled, result);
}

test "OrderStateMachine: pending_replace → replaced on replaced" {
    var sm = OrderStateMachine.init();
    const result = try sm.transition(.pending_replace, .replaced);
    try std.testing.expectEqual(OrdStatus.replaced, result);
}

test "OrderStateMachine: invalid transition returns error" {
    var sm = OrderStateMachine.init();
    // pending_new cannot receive fill
    try std.testing.expectError(error.IllegalTransition, sm.transition(.pending_new, .fill));
}

test "OrderStateMachine: filled is terminal — all events fail" {
    var sm = OrderStateMachine.init();
    try std.testing.expectError(error.IllegalTransition, sm.transition(.filled, .new));
    try std.testing.expectError(error.IllegalTransition, sm.transition(.filled, .cancelled));
    try std.testing.expectError(error.IllegalTransition, sm.transition(.filled, .partial_fill));
}

test "OrderStateMachine: cancelled is terminal" {
    var sm = OrderStateMachine.init();
    try std.testing.expectError(error.IllegalTransition, sm.transition(.cancelled, .new));
}

test "OrderStateMachine: rejected is terminal" {
    var sm = OrderStateMachine.init();
    try std.testing.expectError(error.IllegalTransition, sm.transition(.rejected, .new));
}

test "OrderStateMachine: expired is terminal" {
    var sm = OrderStateMachine.init();
    try std.testing.expectError(error.IllegalTransition, sm.transition(.expired, .new));
}

test "OrderStateMachine: isTerminal returns correct values" {
    try std.testing.expect(OrderStateMachine.isTerminal(.filled));
    try std.testing.expect(OrderStateMachine.isTerminal(.cancelled));
    try std.testing.expect(OrderStateMachine.isTerminal(.rejected));
    try std.testing.expect(OrderStateMachine.isTerminal(.expired));
    try std.testing.expect(!OrderStateMachine.isTerminal(.new));
    try std.testing.expect(!OrderStateMachine.isTerminal(.partially_filled));
    try std.testing.expect(!OrderStateMachine.isTerminal(.pending_new));
    try std.testing.expect(!OrderStateMachine.isTerminal(.pending_cancel));
    try std.testing.expect(!OrderStateMachine.isTerminal(.pending_replace));
    try std.testing.expect(!OrderStateMachine.isTerminal(.suspended));
}

test "OrderStateMachine: fill-before-cancel race — partial fill then cancel" {
    var sm = OrderStateMachine.init();
    // new → partially_filled (partial fill arrives)
    var s = try sm.transition(.new, .partial_fill);
    try std.testing.expectEqual(OrdStatus.partially_filled, s);
    // partially_filled → cancelled (cancel arrives after partial fill)
    s = try sm.transition(.partially_filled, .cancelled);
    try std.testing.expectEqual(OrdStatus.cancelled, s);
}

test "OrderStateMachine: fill-before-replace race — partial fill then replace" {
    var sm = OrderStateMachine.init();
    // new → partially_filled
    var s = try sm.transition(.new, .partial_fill);
    try std.testing.expectEqual(OrdStatus.partially_filled, s);
    // partially_filled → pending_replace (replace request)
    s = try sm.transition(.partially_filled, .pending_replace);
    try std.testing.expectEqual(OrdStatus.pending_replace, s);
    // pending_replace → replaced
    s = try sm.transition(.pending_replace, .replaced);
    try std.testing.expectEqual(OrdStatus.replaced, s);
}

test "OrderStateMachine: validating → pending_new → new full path" {
    var sm = OrderStateMachine.init();
    var s = try sm.transition(.validating, .new);
    try std.testing.expectEqual(OrdStatus.pending_new, s);
    s = try sm.transition(.pending_new, .new);
    try std.testing.expectEqual(OrdStatus.new, s);
}
