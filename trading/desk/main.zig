const std = @import("std");
const Terminal = @import("terminal.zig").Terminal;

pub fn main() !void {
    var term = Terminal.init() catch |err| {
        // If terminal init fails (e.g., piped stdin), fall back to simple output
        const stdout = std.io.getStdOut().writer();
        try stdout.print("Trading Desk v0.1.0 (terminal init failed: {})\n", .{err});
        return;
    };
    defer term.deinit();

    const w = term.writer();
    try w.writeAll("\x1b[2;2H");
    try w.writeAll("Trading Desk v0.1.0 -- press q to quit");
    try term.flush();

    while (!Terminal.shouldQuit()) {
        if (term.readByte()) |byte| {
            if (byte == 'q') break;
        }
        std.time.sleep(16_000_000); // ~60 checks/sec
    }
}

test "desk_smoke" {}
