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
const CandleUpdate = msg.CandleUpdate;
const Engine = @import("engine.zig").Engine;
const input_mod = @import("input.zig");
const InputHandler = input_mod.InputHandler;
const Action = input_mod.Action;

const orderbook_panel = @import("panels/orderbook_panel.zig");
const positions_panel = @import("panels/positions_panel.zig");
const chart_panel = @import("panels/chart_panel.zig");
const orders_panel = @import("panels/orders_panel.zig");
const status_panel = @import("panels/status_panel.zig");
const order_entry_panel_mod = @import("panels/order_entry_panel.zig");
const OrderEntryPanel = order_entry_panel_mod.OrderEntryPanel;
const theme_mod = @import("theme.zig");

const MAX_POSITIONS = 16;
const MAX_ORDERS = 64;

// Panel indices (positions panel removed from tab cycle — accessed via 'p' overlay)
const PANEL_ORDERBOOK = 0;
const PANEL_ORDER_ENTRY = 1;
const PANEL_RECENT_ORDERS = 2;

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
    var candle_history: [2][512]CandleUpdate = undefined;
    var candle_counts: [2]usize = .{ 0, 0 };
    var engine_stopped = false;
    var ticks_since_event: u32 = 0;
    var show_positions_overlay: bool = false;
    var bbo_history: [2][128]i64 = undefined;
    var bbo_history_count: [2]usize = .{ 0, 0 };
    var frame_count: u64 = 0;
    var order_arrival_frame: [MAX_ORDERS]u64 = std.mem.zeroes([MAX_ORDERS]u64);
    var viewport_offset: [2]usize = .{ 0, 0 }; // per-instrument scroll offset
    var candle_width: u8 = 3; // shared zoom level

    // Input and focus state
    var input_handler = InputHandler.init();
    var active_panel: u8 = PANEL_ORDERBOOK;
    var order_entry = OrderEntryPanel.init("BTC-USD");
    var status_msg: [64]u8 = undefined;
    var status_msg_len: usize = 0;
    var status_msg_frames: u32 = 0; // frames remaining to show status message
    const theme = &theme_mod.dark;

    // Orderbook and orders panel scroll positions (reserved for future use)
    const orderbook_scroll: i32 = 0;
    const orders_scroll: i32 = 0;
    _ = orderbook_scroll;
    _ = orders_scroll;

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
                    for (0..2) |i| {
                        if (std.mem.eql(u8, snap.instrument.slice(), orderbook_snap[i].instrument.slice()) or
                            orderbook_snap[i].bid_count == 0)
                        {
                            orderbook_snap[i] = snap;
                            // Update BBO midpoint history if both sides exist
                            if (snap.bid_count > 0 and snap.ask_count > 0) {
                                const midpoint = @divTrunc(snap.bids[0].price + snap.asks[0].price, 2);
                                const slot = bbo_history_count[i] % 128;
                                bbo_history[i][slot] = midpoint;
                                bbo_history_count[i] += 1;
                            }
                            break;
                        }
                    }
                },
                .position_update => |pu| {
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
                    var found = false;
                    for (0..orders_count) |i| {
                        if (orders_buf[i].id == ou.id) {
                            orders_buf[i] = ou;
                            order_arrival_frame[i] = frame_count;
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        if (orders_count < MAX_ORDERS) {
                            orders_buf[orders_count] = ou;
                            order_arrival_frame[orders_count] = frame_count;
                            orders_count += 1;
                        } else {
                            for (0..MAX_ORDERS - 1) |i| {
                                orders_buf[i] = orders_buf[i + 1];
                                order_arrival_frame[i] = order_arrival_frame[i + 1];
                            }
                            orders_buf[MAX_ORDERS - 1] = ou;
                            order_arrival_frame[MAX_ORDERS - 1] = frame_count;
                        }
                    }
                },
                .status => |s| {
                    latest_status = s;
                },
                .candle_update => |cu| {
                    // Determine instrument index by matching instrument name
                    var idx: usize = 0;
                    for (0..2) |i| {
                        if (std.mem.eql(u8, orderbook_snap[i].instrument.slice(), cu.instrument.slice())) {
                            idx = i;
                            break;
                        }
                    }
                    // Append to ring buffer (overwrite oldest if at 512)
                    const slot = candle_counts[idx] % 512;
                    candle_history[idx][slot] = cu;
                    candle_counts[idx] += 1;
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

        // Countdown status message
        if (status_msg_frames > 0) status_msg_frames -= 1;

        const panels = layout_mod.compute(size);

        // Render frame
        renderer.beginFrame();

        // Orderbook panel (highlight if active)
        if (active_panel == PANEL_ORDERBOOK) {
            renderer.writeRawPub("\x1b[1m");
        }
        const bbo_len = @min(bbo_history_count[active_instrument], 128);
        orderbook_panel.draw(&renderer, panels.orderbook, &orderbook_snap[active_instrument], bbo_history[active_instrument][0..bbo_len], theme);
        if (active_panel == PANEL_ORDERBOOK) {
            renderer.writeRawPub("\x1b[0m");
        }

        // Chart panel (top-right, replaces positions panel in tab cycle)
        const candle_len = @min(candle_counts[active_instrument], 512);
        chart_panel.draw(&renderer, panels.chart, candle_history[active_instrument][0..candle_len], theme, viewport_offset[active_instrument], candle_width);

        // Order entry panel
        order_entry.draw(&renderer, panels.order_entry, active_panel == PANEL_ORDER_ENTRY, theme);

        // Recent orders panel
        if (active_panel == PANEL_RECENT_ORDERS) renderer.writeRawPub("\x1b[1m");
        orders_panel.draw(&renderer, panels.recent_orders, orders_buf[0..orders_count], frame_count, theme);
        if (active_panel == PANEL_RECENT_ORDERS) renderer.writeRawPub("\x1b[0m");

        // Status bar
        if (status_msg_frames > 0) {
            renderer.writeFmt("\x1b[{d};{d}H{s}", .{
                panels.status_bar.y + 1, panels.status_bar.x + 1,
                status_msg[0..status_msg_len],
            });
        } else if (engine_stopped) {
            renderer.drawText(panels.status_bar.x, panels.status_bar.y, "Engine stopped | q=quit | Tab=switch panel");
        } else {
            const status_age: u32 = if (status_msg_frames < 45) 45 - status_msg_frames else 0;
            status_panel.draw(&renderer, panels.status_bar, &latest_status, status_age, theme);
        }

        // Positions overlay (drawn on top of all panels when toggled with 'p')
        if (show_positions_overlay) {
            positions_panel.draw(&renderer, panels.positions_overlay, positions_buf[0..positions_count], theme);
        }

        try renderer.endFrame();

        // Process frame boundary escape reset
        if (input_handler.frameReset()) |act| {
            _ = processAction(&input_handler, act, &active_panel, &active_instrument, &order_entry,
                &from_tui, &status_msg, &status_msg_len, &status_msg_frames, &show_positions_overlay,
                &viewport_offset, &candle_width, &candle_counts);
        }

        // Process input bytes
        while (term.readByte()) |byte| {
            const text_mode = (active_panel == PANEL_ORDER_ENTRY);
            if (input_handler.feed(byte, text_mode)) |act| {
                const should_quit = processAction(&input_handler, act, &active_panel, &active_instrument,
                    &order_entry, &from_tui, &status_msg, &status_msg_len, &status_msg_frames, &show_positions_overlay,
                    &viewport_offset, &candle_width, &candle_counts);
                if (should_quit) {
                    _ = from_tui.push(UserCommand{ .quit = {} });
                    goto_done = true;
                    break;
                }
            }
        }

        if (goto_done) break;

        frame_count += 1;
        std.Thread.sleep(66_000_000); // ~15 FPS
    }

    // Wait for engine thread
    engine_thread.join();
}

var goto_done: bool = false;

/// Process a decoded action. Returns true if the app should quit.
fn processAction(
    _handler: *InputHandler,
    action: Action,
    active_panel: *u8,
    active_instrument: *usize,
    order_entry: *OrderEntryPanel,
    from_tui: *SpscRingBuffer(UserCommand),
    status_msg: *[64]u8,
    status_msg_len: *usize,
    status_msg_frames: *u32,
    show_positions_overlay: *bool,
    viewport_offset: *[2]usize,
    candle_width: *u8,
    candle_counts: *[2]usize,
) bool {
    _ = _handler;
    switch (action) {
        .quit => {
            if (active_panel.* != PANEL_ORDER_ENTRY) {
                return true;
            }
            // In order entry, Escape exits focus
            active_panel.* = PANEL_ORDERBOOK;
        },
        .escape => {
            if (active_panel.* == PANEL_ORDER_ENTRY) {
                active_panel.* = PANEL_ORDERBOOK;
            }
        },
        .tab => {
            active_panel.* = (active_panel.* + 1) % 3;
        },
        .shift_tab => {
            if (active_panel.* == 0) {
                active_panel.* = 2;
            } else {
                active_panel.* -= 1;
            }
        },
        .toggle_positions => {
            show_positions_overlay.* = !show_positions_overlay.*;
        },
        .char => |c| {
            if (active_panel.* == PANEL_ORDER_ENTRY) {
                _ = order_entry.handleAction(action);
            } else if (c == 'i') {
                // Toggle instrument in orderbook panel
                active_instrument.* = (active_instrument.* + 1) % 2;
            }
        },
        .arrow_up, .arrow_down => {
            if (active_panel.* == PANEL_ORDER_ENTRY) {
                _ = order_entry.handleAction(action);
            }
        },
        .arrow_left => {
            if (active_panel.* != PANEL_ORDER_ENTRY) {
                // Scroll left (further back in history)
                const idx = active_instrument.*;
                const total = candle_counts.*[idx];
                if (viewport_offset.*[idx] == 0) {
                    // Start scroll: offset > 0 means scrolled from right edge
                    // 0 = auto-follow; increment to 1 to start scrolling
                    if (total > 1) viewport_offset.*[idx] = 1;
                } else {
                    viewport_offset.*[idx] += 1;
                    // Clamp to max meaningful offset (total candles - 1)
                    if (viewport_offset.*[idx] >= total) {
                        viewport_offset.*[idx] = if (total > 0) total - 1 else 0;
                    }
                }
            }
        },
        .arrow_right => {
            if (active_panel.* != PANEL_ORDER_ENTRY) {
                // Scroll right (toward newest candles)
                const idx = active_instrument.*;
                if (viewport_offset.*[idx] > 1) {
                    viewport_offset.*[idx] -= 1;
                } else {
                    // Back to auto-follow
                    viewport_offset.*[idx] = 0;
                }
            }
        },
        .zoom_in => {
            // Cycle candle_width: 1 → 3 → 5 → 1
            candle_width.* = switch (candle_width.*) {
                1 => 3,
                3 => 5,
                else => 1,
            };
        },
        .zoom_out => {
            // Cycle candle_width: 5 → 3 → 1 → 5
            candle_width.* = switch (candle_width.*) {
                5 => 3,
                3 => 1,
                else => 5,
            };
        },
        .enter => {
            if (active_panel.* == PANEL_ORDER_ENTRY) {
                if (order_entry.handleAction(action)) |cmd| {
                    if (from_tui.push(cmd)) {
                        const s = "Order submitted";
                        @memcpy(status_msg[0..s.len], s);
                        status_msg_len.* = s.len;
                        status_msg_frames.* = 45; // ~3 seconds at 15fps
                    }
                }
            }
        },
        .backspace => {
            if (active_panel.* == PANEL_ORDER_ENTRY) {
                _ = order_entry.handleAction(action);
            }
        },
        .delete_line => {
            if (active_panel.* == PANEL_ORDER_ENTRY) {
                _ = order_entry.handleAction(action);
            }
        },
        else => {},
    }
    return false;
}

test "desk_smoke" {}
