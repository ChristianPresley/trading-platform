const std = @import("std");
const terminal_mod = @import("terminal.zig");
const Terminal = terminal_mod.Terminal;
const layout_mod = @import("layout.zig");
const Renderer = @import("renderer.zig").Renderer;
const SpscRingBuffer = @import("ring_buffer").SpscRingBuffer;
const msg = @import("messages.zig");
const EngineEvent = msg.EngineEvent;
const UserCommand = msg.UserCommand;
const OrderbookSnapshot = msg.OrderbookSnapshot;
const PositionUpdate = msg.PositionUpdate;
const OrderUpdate = msg.OrderUpdate;
const StatusUpdate = msg.StatusUpdate;
const Engine = @import("engine.zig").Engine;

const orderbook_panel = @import("panels/orderbook_panel.zig");
const positions_panel = @import("panels/positions_panel.zig");
const orders_panel = @import("panels/orders_panel.zig");
const status_panel = @import("panels/status_panel.zig");

const MAX_POSITIONS = 16;
const MAX_ORDERS = 64;

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

    // TUI state
    var orderbook_snap = [_]OrderbookSnapshot{std.mem.zeroes(OrderbookSnapshot)} ** 2;
    var active_instrument: usize = 0;
    var positions_buf: [MAX_POSITIONS]PositionUpdate = undefined;
    var positions_count: usize = 0;
    var orders_buf: [MAX_ORDERS]OrderUpdate = undefined;
    var orders_count: usize = 0;
    var latest_status = std.mem.zeroes(StatusUpdate);
    var engine_stopped = false;
    var ticks_since_event: u32 = 0;

    while (!terminal_mod.signal_received) {
        // Check for resize
        const new_size = Terminal.getSize() catch size;
        if (new_size.rows != size.rows or new_size.cols != size.cols) {
            size = new_size;
            try renderer.resize(size.rows, size.cols);
        }

        // Drain engine events (keep last per type)
        var got_event = false;
        while (to_tui.pop()) |event| {
            got_event = true;
            ticks_since_event = 0;
            switch (event) {
                .tick => {},
                .orderbook_snapshot => |snap| {
                    // Match by instrument name to slot
                    for (0..2) |i| {
                        if (std.mem.eql(u8, snap.instrument.slice(), orderbook_snap[i].instrument.slice()) or
                            orderbook_snap[i].bid_count == 0)
                        {
                            orderbook_snap[i] = snap;
                            break;
                        }
                    }
                },
                .position_update => |pu| {
                    // Upsert by instrument
                    var found = false;
                    for (0..positions_count) |i| {
                        if (std.mem.eql(u8, positions_buf[i].instrument.slice(), pu.instrument.slice())) {
                            positions_buf[i] = pu;
                            found = true;
                            break;
                        }
                    }
                    if (!found and positions_count < MAX_POSITIONS) {
                        positions_buf[positions_count] = pu;
                        positions_count += 1;
                    }
                },
                .order_update => |ou| {
                    // Append or update
                    var found = false;
                    for (0..orders_count) |i| {
                        if (orders_buf[i].id == ou.id) {
                            orders_buf[i] = ou;
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        if (orders_count < MAX_ORDERS) {
                            orders_buf[orders_count] = ou;
                            orders_count += 1;
                        } else {
                            // Ring: shift left, append at end
                            for (0..MAX_ORDERS - 1) |i| orders_buf[i] = orders_buf[i + 1];
                            orders_buf[MAX_ORDERS - 1] = ou;
                        }
                    }
                },
                .status => |s| {
                    latest_status = s;
                },
                .shutdown_ack => {
                    engine_stopped = true;
                },
            }
        }
        if (!got_event) {
            ticks_since_event += 1;
        }
        if (ticks_since_event > 150) {
            engine_stopped = true;
        }

        const panels = layout_mod.compute(size);

        // Render frame
        renderer.beginFrame();

        // Orderbook panel
        orderbook_panel.draw(&renderer, panels.orderbook, &orderbook_snap[active_instrument]);

        // Positions panel
        positions_panel.draw(&renderer, panels.positions, positions_buf[0..positions_count]);

        // Order entry panel (placeholder for now — Phase 6 will add full entry)
        renderer.drawBox(panels.order_entry, "Order Entry");
        renderer.drawText(panels.order_entry.x + 1, panels.order_entry.y + 1, "Tab to focus | Enter to submit");

        // Recent orders panel
        orders_panel.draw(&renderer, panels.recent_orders, orders_buf[0..orders_count]);

        // Status bar
        if (engine_stopped) {
            renderer.drawText(panels.status_bar.x, panels.status_bar.y, "Engine stopped | q=quit");
        } else {
            status_panel.draw(&renderer, panels.status_bar, &latest_status);
        }

        try renderer.endFrame();

        // Check input
        if (term.readByte()) |byte| {
            switch (byte) {
                'q' => {
                    _ = from_tui.push(UserCommand{ .quit = {} });
                    break;
                },
                'i' => {
                    // Toggle active instrument
                    active_instrument = (active_instrument + 1) % 2;
                },
                else => {},
            }
        }

        std.Thread.sleep(66_000_000); // ~15 FPS
    }

    // Wait for engine thread
    engine_thread.join();
}

test "desk_smoke" {}
