const std = @import("std");
const terminal_mod = @import("terminal.zig");
const Terminal = terminal_mod.Terminal;
const layout = @import("layout.zig");
const Renderer = @import("renderer.zig").Renderer;
const messages = @import("messages.zig");
const EngineEvent = messages.EngineEvent;
const UserCommand = messages.UserCommand;
const Engine = @import("engine.zig").Engine;
const ring_buffer = @import("ring_buffer");
const SpscRingBuffer = ring_buffer.SpscRingBuffer;

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

    // Ring buffers for engine <-> TUI communication
    var to_tui = try SpscRingBuffer(EngineEvent).init(allocator, 256);
    defer to_tui.deinit();
    var from_tui = try SpscRingBuffer(UserCommand).init(allocator, 256);
    defer from_tui.deinit();

    // Start engine thread
    var engine = Engine.init(allocator, &to_tui, &from_tui);
    defer engine.deinit();

    const engine_thread = try std.Thread.spawn(.{}, Engine.run, .{&engine});

    const frame_ns: u64 = 66_000_000; // ~15 FPS

    // TUI state
    var current_tick: u64 = 0;
    var engine_running = true;

    while (!Terminal.shouldQuit() and engine_running) {
        // Drain events from engine
        while (to_tui.pop()) |event| {
            switch (event) {
                .tick => |t| current_tick = t,
                .status => {},
                .shutdown_ack => engine_running = false,
                else => {},
            }
        }

        const current_size = Terminal.getSize() catch terminal_mod.Size{ .rows = 24, .cols = 80 };
        const panels = layout.compute(current_size);

        renderer.beginFrame();

        // Draw panels
        renderer.drawBox(panels.orderbook, " Orderbook ");
        renderer.drawBox(panels.positions, " Positions ");
        renderer.drawBox(panels.order_entry, " Order Entry ");
        renderer.drawBox(panels.recent_orders, " Recent Orders ");

        // Status bar with tick counter
        renderer.drawTextFmt(panels.status_bar.x + 1, panels.status_bar.y,
            "Trading Desk v0.1.0 | Tick: {d} | q=quit", .{current_tick});

        try renderer.endFrame();

        // Input handling
        if (term.readByte()) |byte| {
            if (byte == 'q') {
                _ = from_tui.push(.{ .quit = {} });
                break;
            }
        }

        std.time.sleep(frame_ns);
    }

    // Signal engine to stop if not already
    engine.requestStop();
    engine_thread.join();
}

test "desk_smoke" {}
