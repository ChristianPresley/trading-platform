// Terminal management for Trading Desk TUI
// Handles raw mode, alternate screen, size detection, non-blocking stdin.
// Designed for Zig 0.16 on Linux.

const std = @import("std");
const posix = std.posix;
const linux = std.os.linux;

pub const Size = struct {
    rows: u16,
    cols: u16,
};

/// Global signal flag: set to true by SIGINT/SIGTERM handler.
pub var signal_received: bool = false;

fn signalHandler(sig: i32) callconv(.c) void {
    _ = sig;
    signal_received = true;
}

pub const Terminal = struct {
    original_termios: posix.termios,
    stdin_fd: posix.fd_t,
    stdout_fd: posix.fd_t,
    buf: [65536]u8,
    buf_pos: usize,

    pub fn init() !Terminal {
        const stdin_fd = posix.STDIN_FILENO;
        const stdout_fd = posix.STDOUT_FILENO;

        // Save original termios (fails with NotATerminal if stdin is not a tty)
        const original = posix.tcgetattr(stdin_fd) catch return error.NotATerminal;

        // Set raw mode
        var raw = original;
        raw.iflag.ICRNL = false;
        raw.iflag.IXON = false;
        raw.lflag.ECHO = false;
        raw.lflag.ICANON = false;
        raw.lflag.ISIG = false;
        raw.lflag.IEXTEN = false;
        raw.cflag.CSIZE = .CS8;
        // VMIN=0, VTIME=0 => non-blocking
        raw.cc[@intFromEnum(posix.V.MIN)] = 0;
        raw.cc[@intFromEnum(posix.V.TIME)] = 0;
        try posix.tcsetattr(stdin_fd, .FLUSH, raw);

        var term = Terminal{
            .original_termios = original,
            .stdin_fd = stdin_fd,
            .stdout_fd = stdout_fd,
            .buf = undefined,
            .buf_pos = 0,
        };

        // Register signal handlers
        const sa = posix.Sigaction{
            .handler = .{ .handler = signalHandler },
            .mask = posix.sigemptyset(),
            .flags = 0,
        };
        posix.sigaction(posix.SIG.INT, &sa, null);
        posix.sigaction(posix.SIG.TERM, &sa, null);

        // Enter alternate screen and hide cursor
        try term.writeStr("\x1b[?1049h\x1b[?25l");
        try term.flushBuf();

        return term;
    }

    pub fn deinit(self: *Terminal) void {
        // Show cursor and exit alternate screen
        self.writeStr("\x1b[?25h\x1b[?1049l") catch {};
        self.flushBuf() catch {};

        // Restore original termios
        posix.tcsetattr(self.stdin_fd, .FLUSH, self.original_termios) catch {};
    }

    /// Get terminal size using TIOCGWINSZ ioctl.
    pub fn getSize() !Size {
        var ws = posix.winsize{
            .row = 0,
            .col = 0,
            .xpixel = 0,
            .ypixel = 0,
        };
        const err = posix.system.ioctl(posix.STDOUT_FILENO, posix.T.IOCGWINSZ, @intFromPtr(&ws));
        if (posix.errno(err) != .SUCCESS) {
            return error.IoctlFailed;
        }
        const rows = if (ws.row < 10) 10 else ws.row;
        const cols = if (ws.col < 40) 40 else ws.col;
        return Size{ .rows = rows, .cols = cols };
    }

    /// Non-blocking read of one byte from stdin.
    /// Returns null if no byte is available.
    pub fn readByte(self: *Terminal) ?u8 {
        var fds = [1]posix.pollfd{.{
            .fd = self.stdin_fd,
            .events = posix.POLL.IN,
            .revents = 0,
        }};
        const ready = posix.poll(&fds, 0) catch return null;
        if (ready == 0) return null;
        var byte: [1]u8 = undefined;
        const n = posix.read(self.stdin_fd, &byte) catch return null;
        if (n == 0) return null;
        return byte[0];
    }

    /// Write all bytes to stdout fd via raw syscall.
    fn writeAll(self: *Terminal, data: []const u8) !void {
        var written: usize = 0;
        while (written < data.len) {
            const rc = linux.write(self.stdout_fd, data[written..].ptr, data[written..].len);
            const signed: isize = @bitCast(rc);
            if (signed < 0) return error.WriteFailed;
            written += @intCast(rc);
        }
    }

    /// Write raw bytes to the internal buffer.
    fn writeStr(self: *Terminal, data: []const u8) !void {
        if (self.buf_pos + data.len > self.buf.len) {
            try self.flushBuf();
        }
        if (data.len > self.buf.len) {
            // Too large for buffer, write directly
            try self.writeAll(data);
            return;
        }
        @memcpy(self.buf[self.buf_pos .. self.buf_pos + data.len], data);
        self.buf_pos += data.len;
    }

    /// Write formatted bytes to the internal buffer.
    pub fn print(self: *Terminal, comptime fmt: []const u8, args: anytype) !void {
        var tmp: [4096]u8 = undefined;
        const s = try std.fmt.bufPrint(&tmp, fmt, args);
        try self.writeStr(s);
    }

    /// Flush internal buffer to stdout.
    pub fn flushBuf(self: *Terminal) !void {
        if (self.buf_pos == 0) return;
        try self.writeAll(self.buf[0..self.buf_pos]);
        self.buf_pos = 0;
    }

    /// Reset write position (start of new frame).
    pub fn beginWrite(self: *Terminal) void {
        self.buf_pos = 0;
    }
};

test "terminal_size_type" {
    const s = Size{ .rows = 24, .cols = 80 };
    try std.testing.expect(s.rows == 24);
    try std.testing.expect(s.cols == 80);
}
