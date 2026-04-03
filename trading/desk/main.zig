const std = @import("std");
const Terminal = @import("terminal.zig").Terminal;
const terminal_mod = @import("terminal.zig");

pub fn main() !void {
    var term = Terminal.init() catch |err| {
        // Non-terminal stdin (e.g. piped input): fall back to simple output
        if (err == error.NotATerminal) {
            const stdout = std.fs.File.stdout().deprecatedWriter();
            try stdout.print("Trading Desk v0.1.0\n", .{});
            return;
        }
        return err;
    };
    defer term.deinit();

    // Display static message
    try term.print("\x1b[2;2HTrading Desk v0.1.0 -- press q to quit", .{});
    try term.flushBuf();

    // Main loop: read input, break on 'q' or signal
    while (!terminal_mod.signal_received) {
        if (term.readByte()) |byte| {
            if (byte == 'q') break;
        }
        std.Thread.sleep(16_000_000); // ~60 FPS polling
    }
}

test "desk_smoke" {}
