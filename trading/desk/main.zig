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
const SyntheticFeed = @import("synthetic.zig").SyntheticFeed;
const orderbook_panel = @import("panels/orderbook_panel.zig");
const positions_panel = @import("panels/positions_panel.zig");
const orders_panel = @import("panels/orders_panel.zig");
const status_panel = @import("panels/status_panel.zig");

const MAX_ORDERS = 64;
const MAX_POSITIONS = 16;

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
    var to_tui = try SpscRingBuffer(EngineEvent).init(allocator, 1024);
    defer to_tui.deinit();
    var from_tui = try SpscRingBuffer(UserCommand).init(allocator, 256);
    defer from_tui.deinit();

    // Start engine thread
    var engine = Engine.init(allocator, &to_tui, &from_tui);
    defer engine.deinit();

    const engine_thread = try std.Thread.spawn(.{}, Engine.run, .{&engine});

    const frame_ns: u64 = 66_000_000; // ~15 FPS

    // TUI state
    const active_instrument: usize = 0;
    var orderbook_snapshots: [2]messages.OrderbookSnapshot = .{ .{}, .{} };
    var order_list: [MAX_ORDERS]messages.OrderUpdate = undefined;
    var order_count: usize = 0;
    var position_list: [MAX_POSITIONS]messages.PositionUpdate = undefined;
    var position_count: usize = 0;
    var status = messages.StatusUpdate{};
    var engine_running = true;

    while (!Terminal.shouldQuit() and engine_running) {
        // Drain events from engine
        while (to_tui.pop()) |event| {
            switch (event) {
                .tick => {},
                .orderbook_snapshot => |snap| {
                    // Match by instrument
                    for (0..2) |i| {
                        if (std.mem.eql(u8, snap.instrument.asSlice(), SyntheticFeed.instruments[i])) {
                            orderbook_snapshots[i] = snap;
                            break;
                        }
                    }
                },
                .position_update => |pos| {
                    if (position_count < MAX_POSITIONS) {
                        position_list[position_count] = pos;
                        position_count += 1;
                    }
                },
                .order_update => |order| {
                    // Update existing or add new
                    var found = false;
                    for (0..order_count) |i| {
                        if (order_list[i].id == order.id) {
                            order_list[i] = order;
                            found = true;
                            break;
                        }
                    }
                    if (!found and order_count < MAX_ORDERS) {
                        order_list[order_count] = order;
                        order_count += 1;
                    }
                },
                .status => |s| status = s,
                .shutdown_ack => engine_running = false,
            }
        }

        const current_size = Terminal.getSize() catch terminal_mod.Size{ .rows = 24, .cols = 80 };
        const panels = layout.compute(current_size);

        renderer.beginFrame();

        // Draw panels with borders
        renderer.drawBox(panels.orderbook, " Orderbook ");
        renderer.drawBox(panels.positions, " Positions ");
        renderer.drawBox(panels.order_entry, " Order Entry ");
        renderer.drawBox(panels.recent_orders, " Recent Orders ");

        // Draw panel contents
        orderbook_panel.draw(&renderer, panels.orderbook, &orderbook_snapshots[active_instrument]);
        positions_panel.draw(&renderer, panels.positions, position_list[0..position_count]);
        orders_panel.draw(&renderer, panels.recent_orders, order_list[0..order_count]);

        // Status bar
        const instrument_name = if (active_instrument < SyntheticFeed.instruments.len)
            SyntheticFeed.instruments[active_instrument]
        else
            "???";
        status_panel.draw(&renderer, panels.status_bar, &status, instrument_name);

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
