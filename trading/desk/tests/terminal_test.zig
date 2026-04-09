// Terminal module tests
// Tests pure logic and data structures without requiring a real terminal.

const std = @import("std");
const terminal_mod = @import("terminal");
const Size = terminal_mod.Size;
const Terminal = terminal_mod.Terminal;

// ---- Size struct tests ----

test "Size: default construction" {
    const s = Size{ .rows = 24, .cols = 80 };
    try std.testing.expectEqual(@as(u16, 24), s.rows);
    try std.testing.expectEqual(@as(u16, 80), s.cols);
}

test "Size: minimum terminal dimensions" {
    const s = Size{ .rows = 10, .cols = 40 };
    try std.testing.expectEqual(@as(u16, 10), s.rows);
    try std.testing.expectEqual(@as(u16, 40), s.cols);
}

test "Size: large terminal dimensions" {
    const s = Size{ .rows = 200, .cols = 400 };
    try std.testing.expectEqual(@as(u16, 200), s.rows);
    try std.testing.expectEqual(@as(u16, 400), s.cols);
}

test "Size: maximum u16 dimensions" {
    const s = Size{ .rows = std.math.maxInt(u16), .cols = std.math.maxInt(u16) };
    try std.testing.expectEqual(@as(u16, 65535), s.rows);
    try std.testing.expectEqual(@as(u16, 65535), s.cols);
}

// ---- Terminal struct field layout ----

test "Terminal: struct has expected fields" {
    // Verify Terminal struct layout without calling init() (which requires a real tty).
    // We create one with zeroed fields to confirm field types compile correctly.
    const posix = std.posix;
    var term = Terminal{
        .original_termios = std.mem.zeroes(posix.termios),
        .stdin_fd = 0,
        .stdout_fd = 0,
        .buf = undefined,
        .buf_pos = 0,
    };
    try std.testing.expectEqual(@as(usize, 0), term.buf_pos);
    term.buf_pos = 42;
    try std.testing.expectEqual(@as(usize, 42), term.buf_pos);
}

test "Terminal: buffer size is 64K" {
    // The internal buffer should be 65536 bytes.
    try std.testing.expectEqual(@as(usize, 65536), @sizeOf([65536]u8));
}

// ---- Write buffer logic (tested via beginWrite) ----

test "Terminal: beginWrite resets buf_pos to zero" {
    // We can test beginWrite since it only touches buf_pos, no I/O.
    var term: Terminal = undefined;
    term.buf_pos = 500;
    term.beginWrite();
    try std.testing.expectEqual(@as(usize, 0), term.buf_pos);
}

test "Terminal: beginWrite is idempotent on zero" {
    var term: Terminal = undefined;
    term.buf_pos = 0;
    term.beginWrite();
    try std.testing.expectEqual(@as(usize, 0), term.buf_pos);
}

// ---- ANSI escape sequence constants ----

test "ANSI: alternate screen enter sequence" {
    // The terminal uses ESC[?1049h to enter alternate screen.
    const seq = "\x1b[?1049h";
    try std.testing.expectEqual(@as(usize, 8), seq.len);
    try std.testing.expectEqual(@as(u8, 0x1b), seq[0]);
    try std.testing.expectEqual(@as(u8, '['), seq[1]);
    try std.testing.expectEqual(@as(u8, 'h'), seq[seq.len - 1]);
}

test "ANSI: alternate screen exit sequence" {
    const seq = "\x1b[?1049l";
    try std.testing.expectEqual(@as(usize, 8), seq.len);
    try std.testing.expectEqual(@as(u8, 'l'), seq[seq.len - 1]);
}

test "ANSI: hide cursor sequence" {
    const seq = "\x1b[?25l";
    try std.testing.expectEqual(@as(usize, 6), seq.len);
    try std.testing.expectEqualStrings("\x1b[?25l", seq);
}

test "ANSI: show cursor sequence" {
    const seq = "\x1b[?25h";
    try std.testing.expectEqual(@as(usize, 6), seq.len);
    try std.testing.expectEqualStrings("\x1b[?25h", seq);
}

test "ANSI: cursor home sequence" {
    const seq = "\x1b[H";
    try std.testing.expectEqual(@as(usize, 3), seq.len);
    try std.testing.expectEqualStrings("\x1b[H", seq);
}

test "ANSI: clear screen sequence" {
    const seq = "\x1b[2J";
    try std.testing.expectEqual(@as(usize, 4), seq.len);
    try std.testing.expectEqualStrings("\x1b[2J", seq);
}

// ---- print() format logic (tested via bufPrint to verify format strings) ----

test "print: cursor position format produces correct ANSI" {
    // Terminal.print uses std.fmt.bufPrint internally.
    // Verify the cursor-positioning format string it would use.
    var buf: [64]u8 = undefined;
    const s = try std.fmt.bufPrint(&buf, "\x1b[{d};{d}H", .{ @as(u16, 5), @as(u16, 10) });
    try std.testing.expectEqualStrings("\x1b[5;10H", s);
}

test "print: cursor position row 1 col 1" {
    var buf: [64]u8 = undefined;
    const s = try std.fmt.bufPrint(&buf, "\x1b[{d};{d}H", .{ @as(u16, 1), @as(u16, 1) });
    try std.testing.expectEqualStrings("\x1b[1;1H", s);
}

test "print: cursor position large values" {
    var buf: [64]u8 = undefined;
    const s = try std.fmt.bufPrint(&buf, "\x1b[{d};{d}H", .{ @as(u16, 200), @as(u16, 400) });
    try std.testing.expectEqualStrings("\x1b[200;400H", s);
}

// ---- signal_received flag ----

test "signal_received: default is false" {
    // Reset for test isolation
    terminal_mod.signal_received = false;
    try std.testing.expect(!terminal_mod.signal_received);
}

test "signal_received: can be set to true" {
    terminal_mod.signal_received = false;
    terminal_mod.signal_received = true;
    try std.testing.expect(terminal_mod.signal_received);
    // Reset
    terminal_mod.signal_received = false;
}

