// Order entry panel: text fields for instrument, side, quantity, price.

const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const layout = @import("../layout.zig");
const Rect = layout.Rect;
const msg = @import("../messages.zig");
const UserCommand = msg.UserCommand;
const OrderRequest = msg.OrderRequest;
const InstrumentId = msg.InstrumentId;
const Action = @import("../input.zig").Action;

pub const TextField = struct {
    buf: [32]u8,
    len: u8,
    cursor: u8,

    pub fn init(default: []const u8) TextField {
        var tf = TextField{ .buf = undefined, .len = 0, .cursor = 0 };
        const n = @min(default.len, 31);
        @memcpy(tf.buf[0..n], default[0..n]);
        tf.len = @intCast(n);
        tf.cursor = tf.len;
        return tf;
    }

    pub fn slice(self: *const TextField) []const u8 {
        return self.buf[0..self.len];
    }

    pub fn appendChar(self: *TextField, c: u8) void {
        if (self.len >= 31) return;
        self.buf[self.len] = c;
        self.len += 1;
        self.cursor = self.len;
    }

    pub fn backspace(self: *TextField) void {
        if (self.len == 0) return;
        self.len -= 1;
        self.cursor = self.len;
    }

    pub fn clear(self: *TextField) void {
        self.len = 0;
        self.cursor = 0;
    }
};

pub const OrderEntryPanel = struct {
    fields: [4]TextField,
    active_field: u8,
    side: u8, // 0=buy, 1=sell

    const FIELD_LABELS = [_][]const u8{ "Instrument:", "Side:", "Quantity:", "Price:" };

    pub fn init(default_instrument: []const u8) OrderEntryPanel {
        return OrderEntryPanel{
            .fields = .{
                TextField.init(default_instrument),
                TextField.init("buy"),
                TextField.init(""),
                TextField.init(""),
            },
            .active_field = 2, // default focus on quantity
            .side = 0,
        };
    }

    /// Handle an action. Returns a UserCommand if order should be submitted.
    pub fn handleAction(self: *OrderEntryPanel, action: Action) ?UserCommand {
        switch (action) {
            .arrow_up => {
                if (self.active_field > 0) self.active_field -= 1;
            },
            .arrow_down => {
                if (self.active_field < 3) self.active_field += 1;
            },
            .char => |c| {
                if (self.active_field == 1) {
                    // Side field: toggle with 'b'/'s'
                    if (c == 'b' or c == 'B') {
                        self.side = 0;
                        self.fields[1] = TextField.init("buy");
                    } else if (c == 's' or c == 'S') {
                        self.side = 1;
                        self.fields[1] = TextField.init("sell");
                    }
                } else {
                    self.fields[self.active_field].appendChar(c);
                }
            },
            .backspace => {
                if (self.active_field != 1) {
                    self.fields[self.active_field].backspace();
                }
            },
            .delete_line => {
                if (self.active_field != 1) {
                    self.fields[self.active_field].clear();
                }
            },
            .enter => {
                // Submit order when Enter pressed on price field (field 3)
                if (self.active_field == 3) {
                    return self.buildOrder();
                }
                // Advance to next field
                if (self.active_field < 3) self.active_field += 1;
            },
            .tab => {
                if (self.active_field < 3) {
                    self.active_field += 1;
                }
            },
            .escape => {
                // Blur order entry — handled by main
            },
            else => {},
        }
        return null;
    }

    fn buildOrder(self: *const OrderEntryPanel) ?UserCommand {
        // Parse quantity
        const qty_str = self.fields[2].slice();
        if (qty_str.len == 0) return null;
        const qty_int = std.fmt.parseInt(i64, qty_str, 10) catch return null;
        if (qty_int <= 0) return null;

        // Parse price
        const price_str = self.fields[3].slice();
        if (price_str.len == 0) return null;
        const price_int = std.fmt.parseInt(i64, price_str, 10) catch return null;
        if (price_int <= 0) return null;

        return UserCommand{ .submit_order = OrderRequest{
            .instrument = InstrumentId.fromSlice(self.fields[0].slice()),
            .side = self.side,
            .quantity = qty_int * 100_000_000, // convert to 8 decimal places
            .price = price_int * 100_000_000,
        } };
    }

    pub fn draw(self: *const OrderEntryPanel, renderer: *Renderer, rect: Rect, active: bool) void {
        const title = if (active) "Order Entry [ACTIVE]" else "Order Entry";
        renderer.drawBox(rect, title);

        if (rect.h < 4 or rect.w < 25) return;

        const inner_x = rect.x + 1;
        const inner_y = rect.y + 1;

        for (0..4) |i| {
            const row = inner_y + @as(u16, @intCast(i));
            if (row >= rect.y + rect.h - 1) break;

            const label = FIELD_LABELS[i];
            const value = self.fields[i].slice();

            if (active and self.active_field == i) {
                // Highlight active field with inverse video
                renderer.writeFmt("\x1b[{d};{d}H\x1b[7m{s:<12}\x1b[0m {s}", .{
                    row + 1, inner_x + 1, label, value,
                });
            } else {
                renderer.writeFmt("\x1b[{d};{d}H{s:<12} {s}", .{
                    row + 1, inner_x + 1, label, value,
                });
            }
        }

        // Help text
        const help_row = inner_y + 4;
        if (help_row < rect.y + rect.h - 1) {
            renderer.writeFmt("\x1b[{d};{d}HEnter=submit b/s=side Esc=exit", .{
                help_row + 1, inner_x + 1,
            });
        }
    }
};

test "order_entry_init" {
    var panel = OrderEntryPanel.init("BTC-USD");
    try @import("std").testing.expectEqualStrings("BTC-USD", panel.fields[0].slice());
}

test "order_entry_submit" {
    const std_ = @import("std");
    var panel = OrderEntryPanel.init("BTC-USD");
    panel.active_field = 2;
    // Type quantity
    _ = panel.handleAction(Action{ .char = '1' });
    _ = panel.handleAction(Action{ .char = '0' });
    panel.active_field = 3;
    // Type price
    _ = panel.handleAction(Action{ .char = '5' });
    _ = panel.handleAction(Action{ .char = '0' });
    _ = panel.handleAction(Action{ .char = '0' });
    _ = panel.handleAction(Action{ .char = '0' });
    _ = panel.handleAction(Action{ .char = '0' });
    // Submit
    const cmd = panel.handleAction(Action{ .enter = {} });
    try std_.testing.expect(cmd != null);
    try std_.testing.expect(cmd.? == .submit_order);
}
