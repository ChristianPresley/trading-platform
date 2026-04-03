const std = @import("std");
const posix = std.posix;

pub const Size = struct {
    rows: u16,
    cols: u16,
};

pub const Terminal = struct {
    original_termios: posix.termios,
    stdin_fd: posix.fd_t,
    stdout: std.fs.File,
    buf_writer: std.io.BufferedWriter(4096, std.fs.File.Writer),

    /// Global signal flag for SIGINT/SIGTERM
    var signal_received: std.atomic.Value(bool) = std.atomic.Value(bool).init(false);

    pub fn init() !Terminal {
        const stdin_fd = std.io.getStdIn().handle;
        const stdout = std.io.getStdOut();

        // Save original terminal attributes
        const original = try posix.tcgetattr(stdin_fd);

        // Set raw mode
        var raw = original;

        // Input flags: disable software flow control, CR translation
        raw.iflag.IXON = false;
        raw.iflag.ICRNL = false;
        raw.iflag.BRKINT = false;
        raw.iflag.INPCK = false;
        raw.iflag.ISTRIP = false;

        // Output flags: disable post-processing
        raw.oflag.OPOST = false;

        // Control flags: set 8-bit chars
        raw.cflag.CSIZE = .CS8;

        // Local flags: disable canonical mode, echo, signals, extended processing
        raw.lflag.ICANON = false;
        raw.lflag.ECHO = false;
        raw.lflag.ISIG = false;
        raw.lflag.IEXTEN = false;

        // Non-blocking read: VMIN=0, VTIME=0
        raw.cc[@intFromEnum(posix.V.MIN)] = 0;
        raw.cc[@intFromEnum(posix.V.TIME)] = 0;

        try posix.tcsetattr(stdin_fd, .FLUSH, raw);

        // Install signal handlers
        installSignalHandlers();

        var term = Terminal{
            .original_termios = original,
            .stdin_fd = stdin_fd,
            .stdout = stdout,
            .buf_writer = std.io.bufferedWriter(stdout.writer()),
        };

        // Enter alternate screen and hide cursor
        const w = term.buf_writer.writer();
        try w.writeAll("\x1b[?1049h"); // Enter alternate screen
        try w.writeAll("\x1b[?25l"); // Hide cursor
        try w.writeAll("\x1b[2J"); // Clear screen
        try term.buf_writer.flush();

        return term;
    }

    pub fn deinit(self: *Terminal) void {
        const w = self.buf_writer.writer();
        w.writeAll("\x1b[?25h") catch {}; // Show cursor
        w.writeAll("\x1b[?1049l") catch {}; // Exit alternate screen
        self.buf_writer.flush() catch {};

        // Restore original terminal attributes
        posix.tcsetattr(self.stdin_fd, .FLUSH, self.original_termios) catch {};
    }

    pub fn getSize() !Size {
        var wsz: std.os.linux.winsize = undefined;
        const rc = std.os.linux.ioctl(std.io.getStdOut().handle, std.os.linux.T.IOCGWINSZ, @intFromPtr(&wsz));
        if (@as(isize, @bitCast(rc)) < 0) {
            return Size{ .rows = 24, .cols = 80 }; // fallback
        }
        return Size{
            .rows = if (wsz.ws_row < 10) 10 else wsz.ws_row,
            .cols = if (wsz.ws_col < 40) 40 else wsz.ws_col,
        };
    }

    pub fn readByte(self: *Terminal) ?u8 {
        var buf: [1]u8 = undefined;
        const n = posix.read(self.stdin_fd, &buf) catch return null;
        if (n == 0) return null;
        return buf[0];
    }

    pub fn writer(self: *Terminal) std.io.BufferedWriter(4096, std.fs.File.Writer).Writer {
        return self.buf_writer.writer();
    }

    pub fn flush(self: *Terminal) !void {
        try self.buf_writer.flush();
    }

    pub fn shouldQuit() bool {
        return signal_received.load(.acquire);
    }

    fn installSignalHandlers() void {
        var act = std.mem.zeroes(posix.Sigaction);
        act.handler = .{ .handler = signalHandler };
        act.mask = posix.empty_sigset;
        posix.sigaction(posix.SIG.INT, &act, null) catch {};
        posix.sigaction(posix.SIG.TERM, &act, null) catch {};
    }

    fn signalHandler(_: c_int) callconv(.C) void {
        signal_received.store(true, .release);
    }
};

test "terminal_size_fallback" {
    // getSize should return reasonable values even outside a real terminal
    const size = Terminal.getSize() catch Size{ .rows = 24, .cols = 80 };
    try std.testing.expect(size.rows >= 10);
    try std.testing.expect(size.cols >= 40);
}
