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
const order_entry_panel = @import("panels/order_entry_panel.zig");
const InputHandler = @import("input.zig").InputHandler;

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
    var active_instrument: usize = 0;
    var orderbook_snapshots: [2]messages.OrderbookSnapshot = .{ .{}, .{} };
    var order_list: [MAX_ORDERS]messages.OrderUpdate = undefined;
    var order_count: usize = 0;
    var position_list: [MAX_POSITIONS]messages.PositionUpdate = undefined;
    var position_count: usize = 0;
    var status = messages.StatusUpdate{};
    var engine_running = true;

    // Input state
    var input_handler = InputHandler.init();
    var active_panel: u8 = 0; // 0=orderbook, 1=positions, 2=order_entry, 3=recent_orders
    var entry_panel = order_entry_panel.OrderEntryPanel.init("BTC-USD");

    while (!Terminal.shouldQuit() and engine_running) {
        // Drain events from engine
        while (to_tui.pop()) |event| {
            switch (event) {
                .tick => {},
                .orderbook_snapshot => |snap| {
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

        // Process input
        var got_byte = false;
        while (term.readByte()) |byte| {
            got_byte = true;
            if (input_handler.feed(byte)) |action| {
                switch (action) {
                    .quit => {
                        if (active_panel != 2) { // 'q' quits unless in order entry
                            _ = from_tui.push(.{ .quit = {} });
                            engine_running = false;
                            break;
                        }
                    },
                    .tab => {
                        active_panel = (active_panel + 1) % 4;
                    },
                    .shift_tab => {
                        active_panel = if (active_panel == 0) 3 else active_panel - 1;
                    },
                    .escape => {
                        if (active_panel == 2) active_panel = 0; // exit order entry
                    },
                    .char => |c| {
                        if (active_panel == 2) {
                            if (entry_panel.handleAction(action)) |cmd| {
                                _ = from_tui.push(cmd);
                            }
                        } else if (c == 'q') {
                            _ = from_tui.push(.{ .quit = {} });
                            engine_running = false;
                            break;
                        } else if (c == '1') {
                            active_instrument = 0;
                            entry_panel.instrument = messages.InstrumentId.fromSlice("BTC-USD");
                        } else if (c == '2') {
                            active_instrument = 1;
                            entry_panel.instrument = messages.InstrumentId.fromSlice("ETH-USD");
                        }
                    },
                    else => {
                        if (active_panel == 2) {
                            if (entry_panel.handleAction(action)) |cmd| {
                                _ = from_tui.push(cmd);
                            }
                        }
                    },
                }
            }
        }
        if (!got_byte) {
            if (input_handler.tickTimeout()) |action| {
                switch (action) {
                    .escape => {
                        if (active_panel == 2) active_panel = 0;
                    },
                    else => {},
                }
            }
        }

        if (!engine_running) break;

        const current_size = Terminal.getSize() catch terminal_mod.Size{ .rows = 24, .cols = 80 };
        const panels = layout.compute(current_size);

        renderer.beginFrame();

        // Draw panels with borders (highlight active)
        const panel_titles = [_][]const u8{ " Orderbook ", " Positions ", " Order Entry ", " Recent Orders " };
        const panel_rects = [_]layout.Rect{ panels.orderbook, panels.positions, panels.order_entry, panels.recent_orders };

        for (0..4) |pi| {
            if (pi == active_panel) {
                renderer.drawText(panel_rects[pi].x, panel_rects[pi].y, "\x1b[36m"); // cyan
            }
            renderer.drawBox(panel_rects[pi], panel_titles[pi]);
            if (pi == active_panel) {
                renderer.drawText(panel_rects[pi].x + panel_rects[pi].w, panel_rects[pi].y, "\x1b[0m");
            }
        }

        // Draw panel contents
        orderbook_panel.draw(&renderer, panels.orderbook, &orderbook_snapshots[active_instrument]);
        positions_panel.draw(&renderer, panels.positions, position_list[0..position_count]);
        orders_panel.draw(&renderer, panels.recent_orders, order_list[0..order_count]);
        entry_panel.draw(&renderer, panels.order_entry, active_panel == 2);

        // Status bar
        const instrument_name = if (active_instrument < SyntheticFeed.instruments.len)
            SyntheticFeed.instruments[active_instrument]
        else
            "???";
        status_panel.draw(&renderer, panels.status_bar, &status, instrument_name);

        try renderer.endFrame();

        std.time.sleep(frame_ns);
    }

    engine.requestStop();
    engine_thread.join();
}

test "desk_smoke" {}
