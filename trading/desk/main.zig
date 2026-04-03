const std = @import("std");
const terminal_mod = @import("terminal.zig");
const Terminal = terminal_mod.Terminal;
const layout_mod = @import("layout.zig");
const Renderer = @import("renderer.zig").Renderer;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var term = Terminal.init() catch |err| {
        if (err == error.NotATerminal) {
            const stdout = std.fs.File.stdout().deprecatedWriter();
            try stdout.print("Trading Desk v0.1.0\n", .{});
            return;
        }
        return err;
    };
    defer term.deinit();

    var size = Terminal.getSize() catch terminal_mod.Size{ .rows = 24, .cols = 80 };
    var renderer = try Renderer.init(allocator, &term, size.rows, size.cols);
    defer renderer.deinit();

    while (!terminal_mod.signal_received) {
        // Check for resize
        const new_size = Terminal.getSize() catch size;
        if (new_size.rows != size.rows or new_size.cols != size.cols) {
            size = new_size;
            try renderer.resize(size.rows, size.cols);
        }

        const panels = layout_mod.compute(size);

        // Render frame
        renderer.beginFrame();
        renderer.drawBox(panels.orderbook, "Orderbook");
        renderer.drawBox(panels.positions, "Positions");
        renderer.drawBox(panels.order_entry, "Order Entry");
        renderer.drawBox(panels.recent_orders, "Recent Orders");

        // Status bar
        renderer.drawText(panels.status_bar.x, panels.status_bar.y, "Trading Desk v0.1.0 | q=quit");
        try renderer.endFrame();

        // Check input
        if (term.readByte()) |byte| {
            if (byte == 'q') break;
        }

        std.Thread.sleep(66_000_000); // ~15 FPS
    }
}

test "desk_smoke" {}
