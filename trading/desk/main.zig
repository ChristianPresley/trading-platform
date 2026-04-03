const std = @import("std");
const terminal_mod = @import("terminal.zig");
const Terminal = terminal_mod.Terminal;
const layout = @import("layout.zig");
const Renderer = @import("renderer.zig").Renderer;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var term = Terminal.init() catch |err| {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("Trading Desk v0.1.0 (terminal init failed: {})\n", .{err});
        return;
    };
    defer term.deinit();

    var renderer = try Renderer.init(allocator, &term);
    defer renderer.deinit();

    const frame_ns: u64 = 66_000_000; // ~15 FPS

    while (!Terminal.shouldQuit()) {
        const current_size = Terminal.getSize() catch terminal_mod.Size{ .rows = 24, .cols = 80 };
        const panels = layout.compute(current_size);

        renderer.beginFrame();

        // Draw panels
        renderer.drawBox(panels.orderbook, " Orderbook ");
        renderer.drawBox(panels.positions, " Positions ");
        renderer.drawBox(panels.order_entry, " Order Entry ");
        renderer.drawBox(panels.recent_orders, " Recent Orders ");

        // Status bar
        renderer.drawText(panels.status_bar.x + 1, panels.status_bar.y, "Trading Desk v0.1.0 | q=quit");

        try renderer.endFrame();

        // Input handling
        if (term.readByte()) |byte| {
            if (byte == 'q') break;
        }

        std.time.sleep(frame_ns);
    }
}

test "desk_smoke" {}
