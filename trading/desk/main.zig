const std = @import("std");
const terminal_mod = @import("terminal.zig");
const Terminal = terminal_mod.Terminal;
const layout_mod = @import("layout.zig");
const Renderer = @import("renderer.zig").Renderer;
const SpscRingBuffer = @import("ring_buffer").SpscRingBuffer;
const msg = @import("messages.zig");
const EngineEvent = msg.EngineEvent;
const UserCommand = msg.UserCommand;
const Engine = @import("engine.zig").Engine;

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

    // Allocate ring buffers
    var to_tui = try SpscRingBuffer(EngineEvent).init(allocator, 256);
    defer to_tui.deinit();
    var from_tui = try SpscRingBuffer(UserCommand).init(allocator, 256);
    defer from_tui.deinit();

    // Init engine
    var engine = try Engine.init(allocator, &to_tui, &from_tui);
    defer engine.deinit();

    // Spawn engine thread
    const engine_thread = try std.Thread.spawn(.{}, Engine.run, .{&engine});

    var size = Terminal.getSize() catch terminal_mod.Size{ .rows = 24, .cols = 80 };
    var renderer = try Renderer.init(allocator, &term, size.rows, size.cols);
    defer renderer.deinit();

    var latest_tick: u64 = 0;
    var engine_stopped = false;
    var ticks_since_last_update: u32 = 0;

    while (!terminal_mod.signal_received) {
        // Check for resize
        const new_size = Terminal.getSize() catch size;
        if (new_size.rows != size.rows or new_size.cols != size.cols) {
            size = new_size;
            try renderer.resize(size.rows, size.cols);
        }

        // Drain engine events
        var got_event = false;
        while (to_tui.pop()) |event| {
            got_event = true;
            switch (event) {
                .tick => |t| {
                    latest_tick = t;
                    ticks_since_last_update = 0;
                },
                .status => |s| {
                    latest_tick = s.tick;
                    ticks_since_last_update = 0;
                },
                .shutdown_ack => {
                    engine_stopped = true;
                },
                else => {},
            }
        }
        if (!got_event) {
            ticks_since_last_update += 1;
        }

        // Detect engine stopped (no ticks for ~150 frames at 15fps = 10 seconds)
        if (ticks_since_last_update > 150) {
            engine_stopped = true;
        }

        const panels = layout_mod.compute(size);

        // Render frame
        renderer.beginFrame();
        renderer.drawBox(panels.orderbook, "Orderbook");
        renderer.drawBox(panels.positions, "Positions");
        renderer.drawBox(panels.order_entry, "Order Entry");
        renderer.drawBox(panels.recent_orders, "Recent Orders");

        // Status bar
        if (engine_stopped) {
            renderer.drawText(panels.status_bar.x, panels.status_bar.y, "Engine stopped | q=quit");
        } else {
            renderer.drawTextFmt(panels.status_bar.x, panels.status_bar.y, "Tick: {d} | q=quit", .{latest_tick});
        }
        try renderer.endFrame();

        // Check input
        if (term.readByte()) |byte| {
            if (byte == 'q') {
                // Send quit command to engine
                _ = from_tui.push(UserCommand{ .quit = {} });
                break;
            }
        }

        std.Thread.sleep(66_000_000); // ~15 FPS
    }

    // Wait for engine thread
    engine_thread.join();
}

test "desk_smoke" {}
