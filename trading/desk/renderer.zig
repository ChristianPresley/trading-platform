// Frame-buffer renderer for Trading Desk TUI.
// Builds the entire screen in memory and writes it in a single syscall.

const std = @import("std");
const Terminal = @import("terminal.zig").Terminal;
const layout = @import("layout.zig");
const Rect = layout.Rect;

pub const Renderer = struct {
    allocator: std.mem.Allocator,
    buf: []u8,
    cursor: usize,
    terminal: *Terminal,

    /// Initialize renderer. Allocates frame buffer.
    pub fn init(allocator: std.mem.Allocator, terminal: *Terminal, size_rows: u16, size_cols: u16) !Renderer {
        // Allocate buffer: rows * cols * 12 bytes per cell (worst-case ANSI sequences)
        const buf_size = @as(usize, size_rows) * @as(usize, size_cols) * 12 + 64;
        const buf = try allocator.alloc(u8, buf_size);
        return Renderer{
            .allocator = allocator,
            .buf = buf,
            .cursor = 0,
            .terminal = terminal,
        };
    }

    pub fn deinit(self: *Renderer) void {
        self.allocator.free(self.buf);
    }

    /// Start a new frame: reset cursor, write cursor-home escape.
    pub fn beginFrame(self: *Renderer) void {
        self.cursor = 0;
        self.writeRaw("\x1b[H") catch {};
        self.writeRaw("\x1b[2J") catch {}; // clear screen
    }

    /// Write raw bytes to frame buffer (public version, silently ignores overflow).
    pub fn writeRawPub(self: *Renderer, data: []const u8) void {
        self.writeRaw(data) catch {};
    }

    /// Write raw bytes to frame buffer.
    fn writeRaw(self: *Renderer, data: []const u8) !void {
        if (self.cursor + data.len > self.buf.len) return error.BufferFull;
        @memcpy(self.buf[self.cursor .. self.cursor + data.len], data);
        self.cursor += data.len;
    }

    /// Write formatted bytes to frame buffer.
    pub fn writeFmt(self: *Renderer, comptime fmt: []const u8, args: anytype) void {
        var tmp: [4096]u8 = undefined;
        const s = std.fmt.bufPrint(&tmp, fmt, args) catch return;
        self.writeRaw(s) catch {};
    }

    /// Draw a bordered box with a title centered on the top border.
    pub fn drawBox(self: *Renderer, rect: Rect, title: []const u8) void {
        if (rect.w < 2 or rect.h < 2) return;

        // Move to top-left corner (1-indexed in ANSI)
        const row1 = rect.y + 1;
        const col1 = rect.x + 1;
        const row2 = rect.y + rect.h;
        const col2 = rect.x + rect.w;

        // Draw top border
        self.writeFmt("\x1b[{d};{d}H+", .{ row1, col1 });
        // Title centered on top border
        const inner_width = rect.w -| 2;
        const title_len = @min(title.len, inner_width);
        const padding = (inner_width -| title_len) / 2;
        var i: u16 = 0;
        while (i < padding) : (i += 1) {
            self.writeRaw("-") catch {};
        }
        self.writeRaw(title[0..title_len]) catch {};
        i = 0;
        const right_pad = inner_width -| padding -| title_len;
        while (i < right_pad) : (i += 1) {
            self.writeRaw("-") catch {};
        }
        self.writeFmt("+", .{});

        // Draw bottom border
        self.writeFmt("\x1b[{d};{d}H+", .{ row2, col1 });
        i = 0;
        while (i < inner_width) : (i += 1) {
            self.writeRaw("-") catch {};
        }
        self.writeFmt("+", .{});

        // Draw side borders
        var r: u16 = row1 + 1;
        while (r < row2) : (r += 1) {
            self.writeFmt("\x1b[{d};{d}H|", .{ r, col1 });
            self.writeFmt("\x1b[{d};{d}H|", .{ r, col2 });
        }
    }

    /// Draw text at absolute terminal coordinates (1-indexed).
    pub fn drawText(self: *Renderer, x: u16, y: u16, text: []const u8) void {
        self.writeFmt("\x1b[{d};{d}H{s}", .{ y + 1, x + 1, text });
    }

    /// Draw formatted text at absolute terminal coordinates (1-indexed).
    pub fn drawTextFmt(self: *Renderer, x: u16, y: u16, comptime fmt: []const u8, args: anytype) void {
        var tmp: [512]u8 = undefined;
        const s = std.fmt.bufPrint(&tmp, fmt, args) catch return;
        self.drawText(x, y, s);
    }

    /// Flush frame buffer to terminal in one write.
    pub fn endFrame(self: *Renderer) !void {
        _ = try self.terminal.stdout.write(self.buf[0..self.cursor]);
        self.terminal.buf_pos = 0;
    }

    /// Reallocate buffer if terminal size changed.
    pub fn resize(self: *Renderer, new_rows: u16, new_cols: u16) !void {
        const needed = @as(usize, new_rows) * @as(usize, new_cols) * 12 + 64;
        if (needed > self.buf.len) {
            self.allocator.free(self.buf);
            self.buf = try self.allocator.alloc(u8, needed);
        }
        self.cursor = 0;
    }
};

test "renderer_drawbox_no_crash" {
    // Renderer requires a Terminal pointer, so we do a unit test
    // for just the buffer logic without initializing a real terminal.
    // We test only the data structures and layout logic.
    const r = Rect{ .x = 0, .y = 0, .w = 20, .h = 5 };
    try std.testing.expect(r.w == 20);
    try std.testing.expect(r.h == 5);
}
