// Renderer module tests
// Tests frame buffer operations, ANSI escape generation, color sequences,
// and box drawing without requiring a real terminal.

const std = @import("std");
const renderer_mod = @import("renderer");
const Renderer = renderer_mod.Renderer;
const Rect = renderer_mod.Rect;
const Rgb = renderer_mod.Rgb;
const theme_mod = renderer_mod.theme_mod;

// ---- Helper: create a renderer backed by a test buffer ----

// We cannot call Renderer.init() without a real Terminal pointer, so we test
// the buffer-level logic by verifying the format strings and sequences that
// the renderer would produce. For Renderer methods that only write to
// self.buf, we construct a minimal Renderer with a fake terminal pointer.
// Since endFrame() is the only method that dereferences terminal, and we
// never call it in these tests, the fake pointer is safe.

fn makeTestRenderer(allocator: std.mem.Allocator, rows: u16, cols: u16) !Renderer {
    const buf_size = @as(usize, rows) * @as(usize, cols) * 12 + 64;
    const buf = try allocator.alloc(u8, buf_size);
    return Renderer{
        .allocator = allocator,
        .buf = buf,
        .cursor = 0,
        .terminal = undefined, // never dereferenced in these tests
    };
}

// ---- Buffer size calculation ----

test "init: buffer size formula" {
    // Buffer = rows * cols * 12 + 64
    const rows: u16 = 24;
    const cols: u16 = 80;
    const expected = @as(usize, rows) * @as(usize, cols) * 12 + 64;
    try std.testing.expectEqual(@as(usize, 23104), expected);
}

test "init: buffer size for large terminal" {
    const rows: u16 = 200;
    const cols: u16 = 400;
    const expected = @as(usize, rows) * @as(usize, cols) * 12 + 64;
    try std.testing.expectEqual(@as(usize, 960064), expected);
}

// ---- beginFrame ----

test "beginFrame: resets cursor and writes home + clear" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 500; // simulate previous frame data
    r.beginFrame();
    // beginFrame writes ESC[H and ESC[2J
    const expected = "\x1b[H\x1b[2J";
    try std.testing.expectEqualStrings(expected, r.buf[0..r.cursor]);
}

test "beginFrame: cursor starts after escape sequences" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.beginFrame();
    // ESC[H = 3 bytes, ESC[2J = 4 bytes => 7 total
    try std.testing.expectEqual(@as(usize, 7), r.cursor);
}

// ---- writeRawPub ----

test "writeRawPub: writes data to buffer" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    r.writeRawPub("hello");
    try std.testing.expectEqual(@as(usize, 5), r.cursor);
    try std.testing.expectEqualStrings("hello", r.buf[0..5]);
}

test "writeRawPub: multiple writes append" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    r.writeRawPub("ab");
    r.writeRawPub("cd");
    try std.testing.expectEqual(@as(usize, 4), r.cursor);
    try std.testing.expectEqualStrings("abcd", r.buf[0..4]);
}

test "writeRawPub: overflow is silently ignored" {
    // Allocate a tiny buffer to test overflow handling.
    const buf = try std.testing.allocator.alloc(u8, 4);
    var r = Renderer{
        .allocator = std.testing.allocator,
        .buf = buf,
        .cursor = 0,
        .terminal = undefined,
    };
    defer r.deinit();

    r.writeRawPub("ab"); // fits
    try std.testing.expectEqual(@as(usize, 2), r.cursor);
    r.writeRawPub("cdefgh"); // does not fit — silently ignored
    try std.testing.expectEqual(@as(usize, 2), r.cursor); // unchanged
}

// ---- writeFmt ----

test "writeFmt: formats integer correctly" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    r.writeFmt("val={d}", .{@as(u32, 42)});
    try std.testing.expectEqualStrings("val=42", r.buf[0..r.cursor]);
}

test "writeFmt: formats string correctly" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    r.writeFmt("hello {s}", .{"world"});
    try std.testing.expectEqualStrings("hello world", r.buf[0..r.cursor]);
}

// ---- Color sequences ----

test "writeColor: produces 24-bit true color foreground escape" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    r.writeColor(Rgb{ .r = 255, .g = 23, .b = 68 });
    try std.testing.expectEqualStrings("\x1b[38;2;255;23;68m", r.buf[0..r.cursor]);
}

test "writeColor: zero color (black)" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    r.writeColor(Rgb{ .r = 0, .g = 0, .b = 0 });
    try std.testing.expectEqualStrings("\x1b[38;2;0;0;0m", r.buf[0..r.cursor]);
}

test "writeColor: max color (white)" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    r.writeColor(Rgb{ .r = 255, .g = 255, .b = 255 });
    try std.testing.expectEqualStrings("\x1b[38;2;255;255;255m", r.buf[0..r.cursor]);
}

test "writeBgColor: produces 24-bit true color background escape" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    r.writeBgColor(Rgb{ .r = 18, .g = 18, .b = 18 });
    try std.testing.expectEqualStrings("\x1b[48;2;18;18;18m", r.buf[0..r.cursor]);
}

test "writeBgColor: dark theme background color" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    r.writeBgColor(theme_mod.dark.background);
    try std.testing.expectEqualStrings("\x1b[48;2;18;18;18m", r.buf[0..r.cursor]);
}

test "resetColor: produces SGR reset escape" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    r.resetColor();
    try std.testing.expectEqualStrings("\x1b[0m", r.buf[0..r.cursor]);
}

// ---- drawText ----

test "drawText: produces cursor position followed by text" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    r.drawText(0, 0, "hello");
    // x=0, y=0 => ANSI row=1, col=1
    try std.testing.expectEqualStrings("\x1b[1;1Hhello", r.buf[0..r.cursor]);
}

test "drawText: non-zero coordinates" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    r.drawText(9, 4, "test");
    // x=9, y=4 => ANSI row=5, col=10
    try std.testing.expectEqualStrings("\x1b[5;10Htest", r.buf[0..r.cursor]);
}

test "drawText: empty string" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    r.drawText(0, 0, "");
    // Should still write the cursor positioning escape
    try std.testing.expectEqualStrings("\x1b[1;1H", r.buf[0..r.cursor]);
}

// ---- drawTextFmt ----

test "drawTextFmt: formats and positions correctly" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    r.drawTextFmt(0, 0, "price={d}", .{@as(u32, 12345)});
    try std.testing.expectEqualStrings("\x1b[1;1Hprice=12345", r.buf[0..r.cursor]);
}

// ---- drawBox ----

test "drawBox: minimum size box (2x2)" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    const rect = Rect{ .x = 0, .y = 0, .w = 2, .h = 2 };
    r.drawBox(rect, "");
    // Should produce output (not skip due to too-small check)
    try std.testing.expect(r.cursor > 0);
}

test "drawBox: too small width skips drawing" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    const rect = Rect{ .x = 0, .y = 0, .w = 1, .h = 5 };
    r.drawBox(rect, "");
    try std.testing.expectEqual(@as(usize, 0), r.cursor);
}

test "drawBox: too small height skips drawing" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    const rect = Rect{ .x = 0, .y = 0, .w = 20, .h = 1 };
    r.drawBox(rect, "");
    try std.testing.expectEqual(@as(usize, 0), r.cursor);
}

test "drawBox: output contains box drawing characters" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    const rect = Rect{ .x = 0, .y = 0, .w = 10, .h = 4 };
    r.drawBox(rect, "Title");
    const output = r.buf[0..r.cursor];
    // Should contain corner characters (UTF-8 encoded)
    try std.testing.expect(std.mem.indexOf(u8, output, "\xe2\x94\x8c") != null); // ┌
    try std.testing.expect(std.mem.indexOf(u8, output, "\xe2\x94\x90") != null); // ┐
    try std.testing.expect(std.mem.indexOf(u8, output, "\xe2\x94\x94") != null); // └
    try std.testing.expect(std.mem.indexOf(u8, output, "\xe2\x94\x98") != null); // ┘
    try std.testing.expect(std.mem.indexOf(u8, output, "\xe2\x94\x80") != null); // ─
    try std.testing.expect(std.mem.indexOf(u8, output, "\xe2\x94\x82") != null); // │
}

test "drawBox: title is embedded in output" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    const rect = Rect{ .x = 0, .y = 0, .w = 20, .h = 5 };
    r.drawBox(rect, "Orders");
    const output = r.buf[0..r.cursor];
    try std.testing.expect(std.mem.indexOf(u8, output, "Orders") != null);
}

test "drawBox: empty title produces only border chars" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    const rect = Rect{ .x = 0, .y = 0, .w = 10, .h = 4 };
    r.drawBox(rect, "");
    const output = r.buf[0..r.cursor];
    // Should still have all four corners
    try std.testing.expect(std.mem.indexOf(u8, output, "\xe2\x94\x8c") != null); // ┌
    try std.testing.expect(std.mem.indexOf(u8, output, "\xe2\x94\x98") != null); // ┘
}

test "drawBox: side borders count matches height minus 2" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    const rect = Rect{ .x = 0, .y = 0, .w = 10, .h = 6 };
    r.drawBox(rect, "");
    const output = r.buf[0..r.cursor];
    // Count occurrences of │ (side border). Each row between top and bottom
    // has 2 side borders (left + right). Height 6 => 4 inner rows => 8 │ chars.
    var count: usize = 0;
    var pos: usize = 0;
    while (pos + 3 <= output.len) {
        if (std.mem.eql(u8, output[pos .. pos + 3], "\xe2\x94\x82")) {
            count += 1;
            pos += 3;
        } else {
            pos += 1;
        }
    }
    try std.testing.expectEqual(@as(usize, 8), count);
}

// ---- drawBoxThemed ----

test "drawBoxThemed: includes color and reset sequences" {
    var r = try makeTestRenderer(std.testing.allocator, 24, 80);
    defer r.deinit();

    r.cursor = 0;
    const rect = Rect{ .x = 0, .y = 0, .w = 10, .h = 4 };
    r.drawBoxThemed(rect, "Test", &theme_mod.dark);
    const output = r.buf[0..r.cursor];
    // Should start with the border color escape
    const border_color = "\x1b[38;2;66;66;66m"; // dark.border = {0x42, 0x42, 0x42}
    try std.testing.expect(std.mem.indexOf(u8, output, border_color) != null);
    // Should end with SGR reset
    try std.testing.expect(std.mem.indexOf(u8, output, "\x1b[0m") != null);
}

// ---- resize ----

test "resize: grows buffer when needed" {
    var r = try makeTestRenderer(std.testing.allocator, 10, 10);
    defer r.deinit();

    const old_len = r.buf.len;
    try r.resize(200, 400);
    // New size = 200 * 400 * 12 + 64 = 960064
    try std.testing.expect(r.buf.len >= 960064);
    try std.testing.expect(r.buf.len > old_len);
    try std.testing.expectEqual(@as(usize, 0), r.cursor);
}

test "resize: no realloc when buffer is already large enough" {
    var r = try makeTestRenderer(std.testing.allocator, 200, 400);
    defer r.deinit();

    const original_len = r.buf.len;
    r.cursor = 100;
    try r.resize(10, 10); // smaller — no realloc needed
    try std.testing.expectEqual(original_len, r.buf.len);
    try std.testing.expectEqual(@as(usize, 0), r.cursor);
}

// ---- Rect struct tests ----

test "Rect: basic construction" {
    const r = Rect{ .x = 5, .y = 10, .w = 40, .h = 12 };
    try std.testing.expectEqual(@as(u16, 5), r.x);
    try std.testing.expectEqual(@as(u16, 10), r.y);
    try std.testing.expectEqual(@as(u16, 40), r.w);
    try std.testing.expectEqual(@as(u16, 12), r.h);
}
