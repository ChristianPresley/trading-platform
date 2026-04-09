// Tests for order_entry_panel.zig — order entry panel state machine and text fields.
// Covers: TextField init/append/backspace/clear, OrderEntryPanel navigation,
//         side toggling, order submission, and input validation.

const std = @import("std");
const order_entry = @import("order_entry_panel");

const TextField = order_entry.TextField;
const OrderEntryPanel = order_entry.OrderEntryPanel;
const Action = order_entry.input_mod.Action;
const UserCommand = order_entry.msg.UserCommand;

// ---- TextField tests ----

test "TextField: init with default value" {
    const tf = TextField.init("hello");
    try std.testing.expectEqualStrings("hello", tf.slice());
    try std.testing.expectEqual(@as(u8, 5), tf.len);
    try std.testing.expectEqual(@as(u8, 5), tf.cursor);
}

test "TextField: init with empty default" {
    const tf = TextField.init("");
    try std.testing.expectEqualStrings("", tf.slice());
    try std.testing.expectEqual(@as(u8, 0), tf.len);
    try std.testing.expectEqual(@as(u8, 0), tf.cursor);
}

test "TextField: init truncates at 31 chars" {
    const long = "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345678";
    const tf = TextField.init(long);
    try std.testing.expectEqual(@as(u8, 31), tf.len);
    try std.testing.expectEqualStrings(long[0..31], tf.slice());
}

test "TextField: appendChar adds character" {
    var tf = TextField.init("ab");
    tf.appendChar('c');
    try std.testing.expectEqualStrings("abc", tf.slice());
    try std.testing.expectEqual(@as(u8, 3), tf.len);
    try std.testing.expectEqual(@as(u8, 3), tf.cursor);
}

test "TextField: appendChar respects max length" {
    var tf = TextField.init("0123456789012345678901234567890"); // 31 chars
    try std.testing.expectEqual(@as(u8, 31), tf.len);
    tf.appendChar('X'); // should be ignored
    try std.testing.expectEqual(@as(u8, 31), tf.len);
}

test "TextField: backspace removes last character" {
    var tf = TextField.init("abc");
    tf.backspace();
    try std.testing.expectEqualStrings("ab", tf.slice());
    try std.testing.expectEqual(@as(u8, 2), tf.len);
    try std.testing.expectEqual(@as(u8, 2), tf.cursor);
}

test "TextField: backspace on empty is no-op" {
    var tf = TextField.init("");
    tf.backspace();
    try std.testing.expectEqualStrings("", tf.slice());
    try std.testing.expectEqual(@as(u8, 0), tf.len);
}

test "TextField: clear resets to empty" {
    var tf = TextField.init("something");
    tf.clear();
    try std.testing.expectEqualStrings("", tf.slice());
    try std.testing.expectEqual(@as(u8, 0), tf.len);
    try std.testing.expectEqual(@as(u8, 0), tf.cursor);
}

test "TextField: multiple appends build string" {
    var tf = TextField.init("");
    tf.appendChar('1');
    tf.appendChar('2');
    tf.appendChar('3');
    try std.testing.expectEqualStrings("123", tf.slice());
}

test "TextField: backspace then append" {
    var tf = TextField.init("abc");
    tf.backspace();
    tf.appendChar('d');
    try std.testing.expectEqualStrings("abd", tf.slice());
}

// ---- OrderEntryPanel init tests ----

test "OrderEntryPanel: init sets instrument" {
    const panel = OrderEntryPanel.init("BTC-USD");
    try std.testing.expectEqualStrings("BTC-USD", panel.fields[0].slice());
}

test "OrderEntryPanel: init defaults side to buy" {
    const panel = OrderEntryPanel.init("ETH-USD");
    try std.testing.expectEqualStrings("buy", panel.fields[1].slice());
    try std.testing.expectEqual(@as(u8, 0), panel.side);
}

test "OrderEntryPanel: init defaults quantity and price to empty" {
    const panel = OrderEntryPanel.init("BTC-USD");
    try std.testing.expectEqualStrings("", panel.fields[2].slice());
    try std.testing.expectEqualStrings("", panel.fields[3].slice());
}

test "OrderEntryPanel: init focuses on quantity field (field 2)" {
    const panel = OrderEntryPanel.init("BTC-USD");
    try std.testing.expectEqual(@as(u8, 2), panel.active_field);
}

// ---- Navigation tests ----

test "OrderEntryPanel: arrow_down advances field" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 0;
    _ = panel.handleAction(Action{ .arrow_down = {} });
    try std.testing.expectEqual(@as(u8, 1), panel.active_field);
}

test "OrderEntryPanel: arrow_up goes back" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 2;
    _ = panel.handleAction(Action{ .arrow_up = {} });
    try std.testing.expectEqual(@as(u8, 1), panel.active_field);
}

test "OrderEntryPanel: arrow_up at top stays at 0" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 0;
    _ = panel.handleAction(Action{ .arrow_up = {} });
    try std.testing.expectEqual(@as(u8, 0), panel.active_field);
}

test "OrderEntryPanel: arrow_down at bottom stays at 3" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 3;
    _ = panel.handleAction(Action{ .arrow_down = {} });
    try std.testing.expectEqual(@as(u8, 3), panel.active_field);
}

test "OrderEntryPanel: tab advances field" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 1;
    _ = panel.handleAction(Action{ .tab = {} });
    try std.testing.expectEqual(@as(u8, 2), panel.active_field);
}

test "OrderEntryPanel: tab at bottom stays at 3" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 3;
    _ = panel.handleAction(Action{ .tab = {} });
    try std.testing.expectEqual(@as(u8, 3), panel.active_field);
}

test "OrderEntryPanel: enter advances field (not on price)" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 0;
    const cmd = panel.handleAction(Action{ .enter = {} });
    try std.testing.expect(cmd == null); // no order submitted
    try std.testing.expectEqual(@as(u8, 1), panel.active_field);
}

// ---- Side toggle tests ----

test "OrderEntryPanel: 'b' on side field sets buy" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 1;
    panel.side = 1; // currently sell
    _ = panel.handleAction(Action{ .char = 'b' });
    try std.testing.expectEqual(@as(u8, 0), panel.side);
    try std.testing.expectEqualStrings("buy", panel.fields[1].slice());
}

test "OrderEntryPanel: 's' on side field sets sell" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 1;
    _ = panel.handleAction(Action{ .char = 's' });
    try std.testing.expectEqual(@as(u8, 1), panel.side);
    try std.testing.expectEqualStrings("sell", panel.fields[1].slice());
}

test "OrderEntryPanel: 'B' (uppercase) on side field sets buy" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 1;
    panel.side = 1;
    _ = panel.handleAction(Action{ .char = 'B' });
    try std.testing.expectEqual(@as(u8, 0), panel.side);
    try std.testing.expectEqualStrings("buy", panel.fields[1].slice());
}

test "OrderEntryPanel: 'S' (uppercase) on side field sets sell" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 1;
    _ = panel.handleAction(Action{ .char = 'S' });
    try std.testing.expectEqual(@as(u8, 1), panel.side);
    try std.testing.expectEqualStrings("sell", panel.fields[1].slice());
}

test "OrderEntryPanel: non-b/s char on side field is ignored" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 1;
    _ = panel.handleAction(Action{ .char = 'x' });
    // Side unchanged
    try std.testing.expectEqual(@as(u8, 0), panel.side);
    try std.testing.expectEqualStrings("buy", panel.fields[1].slice());
}

test "OrderEntryPanel: backspace on side field is no-op" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 1;
    _ = panel.handleAction(Action{ .backspace = {} });
    try std.testing.expectEqualStrings("buy", panel.fields[1].slice());
}

test "OrderEntryPanel: delete_line on side field is no-op" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 1;
    _ = panel.handleAction(Action{ .delete_line = {} });
    try std.testing.expectEqualStrings("buy", panel.fields[1].slice());
}

// ---- Text input on non-side fields ----

test "OrderEntryPanel: char input on quantity field" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 2;
    _ = panel.handleAction(Action{ .char = '5' });
    _ = panel.handleAction(Action{ .char = '0' });
    try std.testing.expectEqualStrings("50", panel.fields[2].slice());
}

test "OrderEntryPanel: char input on price field" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 3;
    _ = panel.handleAction(Action{ .char = '1' });
    _ = panel.handleAction(Action{ .char = '0' });
    _ = panel.handleAction(Action{ .char = '0' });
    try std.testing.expectEqualStrings("100", panel.fields[3].slice());
}

test "OrderEntryPanel: backspace on quantity field removes char" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 2;
    _ = panel.handleAction(Action{ .char = '1' });
    _ = panel.handleAction(Action{ .char = '2' });
    _ = panel.handleAction(Action{ .backspace = {} });
    try std.testing.expectEqualStrings("1", panel.fields[2].slice());
}

test "OrderEntryPanel: delete_line clears quantity field" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 2;
    _ = panel.handleAction(Action{ .char = '9' });
    _ = panel.handleAction(Action{ .char = '9' });
    _ = panel.handleAction(Action{ .delete_line = {} });
    try std.testing.expectEqualStrings("", panel.fields[2].slice());
}

test "OrderEntryPanel: char input on instrument field" {
    var panel = OrderEntryPanel.init("");
    panel.active_field = 0;
    _ = panel.handleAction(Action{ .char = 'E' });
    _ = panel.handleAction(Action{ .char = 'T' });
    _ = panel.handleAction(Action{ .char = 'H' });
    try std.testing.expectEqualStrings("ETH", panel.fields[0].slice());
}

// ---- Order submission tests ----

test "OrderEntryPanel: submit valid order" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 2;
    _ = panel.handleAction(Action{ .char = '1' });
    _ = panel.handleAction(Action{ .char = '0' });
    panel.active_field = 3;
    _ = panel.handleAction(Action{ .char = '5' });
    _ = panel.handleAction(Action{ .char = '0' });
    _ = panel.handleAction(Action{ .char = '0' });
    _ = panel.handleAction(Action{ .char = '0' });
    _ = panel.handleAction(Action{ .char = '0' });
    // Submit
    const cmd = panel.handleAction(Action{ .enter = {} });
    try std.testing.expect(cmd != null);
    try std.testing.expect(cmd.? == .submit_order);

    const order = cmd.?.submit_order;
    try std.testing.expectEqualStrings("BTC-USD", order.instrument.slice());
    try std.testing.expectEqual(@as(u8, 0), order.side); // buy
    try std.testing.expectEqual(@as(i64, 10 * 100_000_000), order.quantity);
    try std.testing.expectEqual(@as(i64, 50000 * 100_000_000), order.price);
}

test "OrderEntryPanel: submit sell order" {
    var panel = OrderEntryPanel.init("ETH-USD");
    // Set side to sell
    panel.active_field = 1;
    _ = panel.handleAction(Action{ .char = 's' });
    // Enter qty
    panel.active_field = 2;
    _ = panel.handleAction(Action{ .char = '5' });
    // Enter price
    panel.active_field = 3;
    _ = panel.handleAction(Action{ .char = '3' });
    _ = panel.handleAction(Action{ .char = '0' });
    _ = panel.handleAction(Action{ .char = '0' });
    _ = panel.handleAction(Action{ .char = '0' });

    const cmd = panel.handleAction(Action{ .enter = {} });
    try std.testing.expect(cmd != null);
    const order = cmd.?.submit_order;
    try std.testing.expectEqual(@as(u8, 1), order.side); // sell
    try std.testing.expectEqual(@as(i64, 5 * 100_000_000), order.quantity);
    try std.testing.expectEqual(@as(i64, 3000 * 100_000_000), order.price);
}

test "OrderEntryPanel: submit with empty quantity returns null" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 3;
    _ = panel.handleAction(Action{ .char = '1' });
    // Submit without entering quantity
    const cmd = panel.handleAction(Action{ .enter = {} });
    try std.testing.expect(cmd == null);
}

test "OrderEntryPanel: submit with empty price returns null" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 2;
    _ = panel.handleAction(Action{ .char = '1' });
    panel.active_field = 3;
    // Submit with empty price
    const cmd = panel.handleAction(Action{ .enter = {} });
    try std.testing.expect(cmd == null);
}

test "OrderEntryPanel: submit with non-numeric quantity returns null" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 2;
    _ = panel.handleAction(Action{ .char = 'a' });
    _ = panel.handleAction(Action{ .char = 'b' });
    panel.active_field = 3;
    _ = panel.handleAction(Action{ .char = '1' });
    const cmd = panel.handleAction(Action{ .enter = {} });
    try std.testing.expect(cmd == null);
}

test "OrderEntryPanel: submit with non-numeric price returns null" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 2;
    _ = panel.handleAction(Action{ .char = '1' });
    panel.active_field = 3;
    _ = panel.handleAction(Action{ .char = 'x' });
    const cmd = panel.handleAction(Action{ .enter = {} });
    try std.testing.expect(cmd == null);
}

test "OrderEntryPanel: submit with zero quantity returns null" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 2;
    _ = panel.handleAction(Action{ .char = '0' });
    panel.active_field = 3;
    _ = panel.handleAction(Action{ .char = '1' });
    const cmd = panel.handleAction(Action{ .enter = {} });
    try std.testing.expect(cmd == null);
}

test "OrderEntryPanel: submit with zero price returns null" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 2;
    _ = panel.handleAction(Action{ .char = '1' });
    panel.active_field = 3;
    _ = panel.handleAction(Action{ .char = '0' });
    const cmd = panel.handleAction(Action{ .enter = {} });
    try std.testing.expect(cmd == null);
}

test "OrderEntryPanel: enter on non-price field does not submit" {
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 2;
    _ = panel.handleAction(Action{ .char = '5' });
    const cmd = panel.handleAction(Action{ .enter = {} });
    try std.testing.expect(cmd == null);
    // Should advance to price field
    try std.testing.expectEqual(@as(u8, 3), panel.active_field);
}

// ---- Full workflow tests ----

test "OrderEntryPanel: full entry workflow top to bottom" {
    var panel = OrderEntryPanel.init("");
    panel.active_field = 0;

    // Type instrument
    for ("BTC") |c| {
        _ = panel.handleAction(Action{ .char = c });
    }
    try std.testing.expectEqualStrings("BTC", panel.fields[0].slice());

    // Enter -> advance to side
    _ = panel.handleAction(Action{ .enter = {} });
    try std.testing.expectEqual(@as(u8, 1), panel.active_field);

    // Set sell
    _ = panel.handleAction(Action{ .char = 's' });
    try std.testing.expectEqual(@as(u8, 1), panel.side);

    // Enter -> advance to qty
    _ = panel.handleAction(Action{ .enter = {} });
    try std.testing.expectEqual(@as(u8, 2), panel.active_field);

    // Type qty
    _ = panel.handleAction(Action{ .char = '2' });
    _ = panel.handleAction(Action{ .char = '5' });

    // Enter -> advance to price
    _ = panel.handleAction(Action{ .enter = {} });
    try std.testing.expectEqual(@as(u8, 3), panel.active_field);

    // Type price
    _ = panel.handleAction(Action{ .char = '1' });
    _ = panel.handleAction(Action{ .char = '0' });
    _ = panel.handleAction(Action{ .char = '0' });

    // Enter on price -> submit order
    const cmd = panel.handleAction(Action{ .enter = {} });
    try std.testing.expect(cmd != null);
    const order = cmd.?.submit_order;
    try std.testing.expectEqualStrings("BTC", order.instrument.slice());
    try std.testing.expectEqual(@as(u8, 1), order.side);
    try std.testing.expectEqual(@as(i64, 25 * 100_000_000), order.quantity);
    try std.testing.expectEqual(@as(i64, 100 * 100_000_000), order.price);
}

test "OrderEntryPanel: escape action returns null" {
    var panel = OrderEntryPanel.init("BTC-USD");
    const cmd = panel.handleAction(Action{ .escape = {} });
    try std.testing.expect(cmd == null);
}

test "OrderEntryPanel: unhandled action returns null" {
    var panel = OrderEntryPanel.init("BTC-USD");
    const cmd = panel.handleAction(Action{ .arrow_left = {} });
    try std.testing.expect(cmd == null);
}
