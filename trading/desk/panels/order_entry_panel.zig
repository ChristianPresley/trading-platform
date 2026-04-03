const std = @import("std");
const Renderer = @import("../renderer.zig").Renderer;
const Rect = @import("../layout.zig").Rect;
const messages = @import("../messages.zig");
const Action = @import("../input.zig").Action;

pub const TextField = struct {
    buf: [32]u8 = [_]u8{0} ** 32,
    len: u8 = 0,
    cursor: u8 = 0,

    pub fn insertChar(self: *TextField, c: u8) void {
        if (self.len >= 31) return;
        // Shift right from cursor
        var i: u8 = self.len;
        while (i > self.cursor) : (i -= 1) {
            self.buf[i] = self.buf[i - 1];
        }
        self.buf[self.cursor] = c;
        self.len += 1;
        self.cursor += 1;
    }

    pub fn deleteBack(self: *TextField) void {
        if (self.cursor == 0) return;
        var i: u8 = self.cursor - 1;
        while (i < self.len - 1) : (i += 1) {
            self.buf[i] = self.buf[i + 1];
        }
        self.len -= 1;
        self.cursor -= 1;
    }

    pub fn clear(self: *TextField) void {
        self.len = 0;
        self.cursor = 0;
    }

    pub fn asSlice(self: *const TextField) []const u8 {
        return self.buf[0..self.len];
    }
};

pub const OrderEntryPanel = struct {
    fields: [3]TextField, // quantity, price, (side is a toggle)
    active_field: u8,
    side: u8, // 0=buy, 1=sell
    instrument: messages.InstrumentId,
    flash_message: [64]u8,
    flash_len: u8,
    flash_frames: u8,

    const field_labels = [_][]const u8{ "Qty:", "Price:", "Side:" };

    pub fn init(default_instrument: []const u8) OrderEntryPanel {
        return OrderEntryPanel{
            .fields = .{ .{}, .{}, .{} },
            .active_field = 0,
            .side = 0,
            .instrument = messages.InstrumentId.fromSlice(default_instrument),
            .flash_message = [_]u8{0} ** 64,
            .flash_len = 0,
            .flash_frames = 0,
        };
    }

    /// Handle an action. Returns a UserCommand if the user submitted an order.
    pub fn handleAction(self: *OrderEntryPanel, action: Action) ?messages.UserCommand {
        switch (action) {
            .arrow_up => {
                if (self.active_field > 0) self.active_field -= 1;
            },
            .arrow_down => {
                if (self.active_field < 2) self.active_field += 1;
            },
            .char => |c| {
                if (self.active_field == 2) {
                    // Side toggle: 'b' for buy, 's' for sell
                    if (c == 'b' or c == 'B') self.side = 0;
                    if (c == 's' or c == 'S') self.side = 1;
                } else {
                    // Number fields: only accept digits and '.'
                    if ((c >= '0' and c <= '9') or c == '.') {
                        self.fields[self.active_field].insertChar(c);
                    }
                }
            },
            .backspace => {
                if (self.active_field < 2) {
                    self.fields[self.active_field].deleteBack();
                }
            },
            .delete_line => {
                if (self.active_field < 2) {
                    self.fields[self.active_field].clear();
                }
            },
            .enter => {
                return self.trySubmit();
            },
            else => {},
        }
        return null;
    }

    fn trySubmit(self: *OrderEntryPanel) ?messages.UserCommand {
        // Parse quantity
        const qty_str = self.fields[0].asSlice();
        const price_str = self.fields[1].asSlice();

        if (qty_str.len == 0 or price_str.len == 0) {
            self.setFlash("Fill qty and price");
            return null;
        }

        const qty = parseFixedPoint(qty_str) orelse {
            self.setFlash("Invalid quantity");
            return null;
        };
        const price = parseFixedPoint(price_str) orelse {
            self.setFlash("Invalid price");
            return null;
        };

        // Clear fields after submit
        self.fields[0].clear();
        self.fields[1].clear();
        self.active_field = 0;

        return .{ .submit_order = .{
            .instrument = self.instrument,
            .side = self.side,
            .quantity = qty,
            .price = price,
        } };
    }

    fn setFlash(self: *OrderEntryPanel, msg: []const u8) void {
        const copy_len = @min(msg.len, 64);
        @memcpy(self.flash_message[0..copy_len], msg[0..copy_len]);
        self.flash_len = @intCast(copy_len);
        self.flash_frames = 30; // ~2 seconds at 15 FPS
    }

    pub fn draw(self: *OrderEntryPanel, renderer: *Renderer, rect: Rect, active: bool) void {
        if (rect.h < 4 or rect.w < 20) return;

        const inner_x = rect.x + 2;
        const inner_y = rect.y + 1;
        const highlight = if (active) "\x1b[1m" else "";
        const reset = "\x1b[0m";
        _ = highlight;
        _ = reset;

        // Instrument
        renderer.drawTextFmt(inner_x, inner_y, "Instrument: {s}", .{self.instrument.asSlice()});

        // Fields
        for (0..3) |fi| {
            const row = inner_y + 1 + @as(u16, @intCast(fi));
            const is_active = active and (self.active_field == @as(u8, @intCast(fi)));
            const prefix: []const u8 = if (is_active) "\x1b[7m" else "";
            const suffix: []const u8 = if (is_active) "\x1b[0m" else "";

            if (fi == 2) {
                // Side toggle
                const side_str: []const u8 = if (self.side == 0) "BUY (b/s to toggle)" else "SELL (b/s to toggle)";
                renderer.drawTextFmt(inner_x, row, "{s}{s} {s}{s}", .{ prefix, field_labels[fi], side_str, suffix });
            } else {
                renderer.drawTextFmt(inner_x, row, "{s}{s} {s}{s}", .{ prefix, field_labels[fi], self.fields[fi].asSlice(), suffix });
            }
        }

        // Flash message
        if (self.flash_frames > 0) {
            self.flash_frames -= 1;
            renderer.drawTextFmt(inner_x, inner_y + 5, "\x1b[33m{s}\x1b[0m", .{self.flash_message[0..self.flash_len]});
        }

        // Submit hint
        if (active) {
            renderer.drawText(inner_x, inner_y + 6, "Enter=submit  Esc=back");
        }
    }
};

/// Parse a decimal string like "50000.50" into fixed-point i64 with 8 decimal places.
fn parseFixedPoint(s: []const u8) ?i64 {
    if (s.len == 0) return null;
    var whole: i64 = 0;
    var frac: i64 = 0;
    var frac_digits: u8 = 0;
    var in_frac = false;

    for (s) |c| {
        if (c == '.') {
            if (in_frac) return null; // double dot
            in_frac = true;
            continue;
        }
        if (c < '0' or c > '9') return null;
        if (in_frac) {
            if (frac_digits < 8) {
                frac = frac * 10 + @as(i64, c - '0');
                frac_digits += 1;
            }
        } else {
            whole = whole * 10 + @as(i64, c - '0');
        }
    }

    // Scale frac to 8 decimal places
    var i: u8 = frac_digits;
    while (i < 8) : (i += 1) {
        frac *= 10;
    }

    return whole * 100_000_000 + frac;
}

test "parse_fixed_point" {
    try std.testing.expectEqual(@as(?i64, 5_000_050_000_000), parseFixedPoint("50000.50"));
    try std.testing.expectEqual(@as(?i64, 100_000_000), parseFixedPoint("1"));
    try std.testing.expectEqual(@as(?i64, 50_000_000), parseFixedPoint("0.5"));
    try std.testing.expectEqual(@as(?i64, null), parseFixedPoint(""));
    try std.testing.expectEqual(@as(?i64, null), parseFixedPoint("abc"));
}

test "text_field_operations" {
    var field = TextField{};
    field.insertChar('1');
    field.insertChar('2');
    field.insertChar('3');
    try std.testing.expectEqualStrings("123", field.asSlice());
    field.deleteBack();
    try std.testing.expectEqualStrings("12", field.asSlice());
    field.clear();
    try std.testing.expectEqualStrings("", field.asSlice());
}
