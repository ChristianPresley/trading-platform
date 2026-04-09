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
const TradeUpdate = msg.TradeUpdate;
const StatusUpdate = msg.StatusUpdate;
const CandleUpdate = msg.CandleUpdate;
const FootprintUpdate = msg.FootprintUpdate;
const Engine = @import("engine.zig").Engine;
const input_mod = @import("input.zig");
const InputHandler = input_mod.InputHandler;
const Action = input_mod.Action;

const orderbook_panel = @import("panels/orderbook_panel.zig");
const positions_panel = @import("panels/positions_panel.zig");
const chart_panel = @import("panels/chart_panel.zig");
const orders_panel = @import("panels/orders_panel.zig");
const trade_tape_panel = @import("panels/trade_tape_panel.zig");
const status_panel = @import("panels/status_panel.zig");
const order_entry_panel_mod = @import("panels/order_entry_panel.zig");
const OrderEntryPanel = order_entry_panel_mod.OrderEntryPanel;
const theme_mod = @import("theme.zig");

const MAX_POSITIONS = 16;
const MAX_ORDERS = 64;
const NUM_INSTRUMENTS = 8;

// Panel indices (positions panel removed from tab cycle — accessed via 'p' overlay)
const PANEL_ORDERBOOK = 0;
const PANEL_ORDER_ENTRY = 1;
const PANEL_RECENT_ORDERS = 2;

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var term = Terminal.init() catch |err| {
        if (err == error.NotATerminal) {
            const banner = "Trading Desk v0.1.0\n";
            _ = std.os.linux.write(std.posix.STDOUT_FILENO, banner, banner.len);
            return;
        }
        return err;
    };
    defer term.deinit();

    // Allocate ring buffers
    var to_tui = try SpscRingBuffer(EngineEvent).init(allocator, 4096);
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
    var orderbook_snap = [_]OrderbookSnapshot{std.mem.zeroes(OrderbookSnapshot)} ** NUM_INSTRUMENTS;
    var active_instrument: usize = 0;
    var positions_buf: [MAX_POSITIONS]PositionUpdate = undefined;
    var positions_count: usize = 0;
    var orders_buf: [MAX_ORDERS]OrderUpdate = undefined;
    var orders_count: usize = 0;
    const MAX_TAPE = trade_tape_panel.MAX_TAPE_ENTRIES;
    var tape_buf: [MAX_TAPE]TradeUpdate = undefined;
    var tape_count: usize = 0;
    var latest_status = std.mem.zeroes(StatusUpdate);
    var candle_history: [NUM_INSTRUMENTS][512]CandleUpdate = undefined;
    var candle_counts: [NUM_INSTRUMENTS]usize = .{0} ** NUM_INSTRUMENTS;
    var footprint_history: [NUM_INSTRUMENTS][512]FootprintUpdate = undefined;
    var footprint_counts: [NUM_INSTRUMENTS]usize = .{0} ** NUM_INSTRUMENTS;
    var engine_stopped = false;
    var ticks_since_event: u32 = 0;
    var show_positions_overlay: bool = false;
    var bbo_history: [NUM_INSTRUMENTS][128]i64 = undefined;
    var bbo_history_count: [NUM_INSTRUMENTS]usize = .{0} ** NUM_INSTRUMENTS;
    var frame_count: u64 = 0;
    var order_arrival_frame: [MAX_ORDERS]u64 = std.mem.zeroes([MAX_ORDERS]u64);
    var viewport_offset: [NUM_INSTRUMENTS]usize = .{0} ** NUM_INSTRUMENTS; // per-instrument scroll offset
    var candle_width: u8 = 3; // shared zoom level
    var crosshair_active: bool = false;
    var crosshair_idx: [NUM_INSTRUMENTS]usize = .{0} ** NUM_INSTRUMENTS; // per-instrument cursor position

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
                    for (0..NUM_INSTRUMENTS) |i| {
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
                .trade_update => |tu| {
                    if (tape_count < MAX_TAPE) {
                        tape_buf[tape_count] = tu;
                        tape_count += 1;
                    } else {
                        // Ring buffer: shift left and append
                        for (0..MAX_TAPE - 1) |ti| {
                            tape_buf[ti] = tape_buf[ti + 1];
                        }
                        tape_buf[MAX_TAPE - 1] = tu;
                    }
                },
                .status => |s| {
                    latest_status = s;
                },
                .candle_update => |cu| {
                    // Determine instrument index by matching instrument name
                    var idx: usize = 0;
                    for (0..NUM_INSTRUMENTS) |i| {
                        if (std.mem.eql(u8, orderbook_snap[i].instrument.slice(), cu.instrument.slice())) {
                            idx = i;
                            break;
                        }
                    }
                    // Update in-place if timestamp matches current bar, else append
                    const count = candle_counts[idx];
                    if (count > 0) {
                        const last_slot = (count - 1) % 512;
                        if (candle_history[idx][last_slot].timestamp == cu.timestamp) {
                            candle_history[idx][last_slot] = cu;
                        } else {
                            const slot = count % 512;
                            candle_history[idx][slot] = cu;
                            candle_counts[idx] += 1;
                        }
                    } else {
                        candle_history[idx][0] = cu;
                        candle_counts[idx] = 1;
                    }
                },
                .footprint_update => |fu| {
                    var idx: usize = 0;
                    for (0..NUM_INSTRUMENTS) |i| {
                        if (std.mem.eql(u8, orderbook_snap[i].instrument.slice(), fu.instrument.slice())) {
                            idx = i;
                            break;
                        }
                    }
                    const slot = footprint_counts[idx] % 512;
                    footprint_history[idx][slot] = fu;
                    footprint_counts[idx] += 1;
                },
                .shutdown_ack => {
                    engine_stopped = true;
                },
                .tca_report => {},   // no-op: TCA report acknowledged but not displayed
                .eod_report => {},   // no-op: EOD report acknowledged but not displayed
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
        // Linearize candle ring buffer into chronological order for rendering.
        const candle_total = candle_counts[active_instrument];
        const candle_len = @min(candle_total, 512);
        var candle_linear: [512]CandleUpdate = undefined;
        if (candle_total > 512) {
            // Ring has wrapped: head is at (candle_total % 512), which is the oldest entry.
            const head = candle_total % 512;
            const tail_len = 512 - head;
            @memcpy(candle_linear[0..tail_len], candle_history[active_instrument][head..512]);
            @memcpy(candle_linear[tail_len..512], candle_history[active_instrument][0..head]);
        } else {
            @memcpy(candle_linear[0..candle_len], candle_history[active_instrument][0..candle_len]);
        }
        // Linearize footprint ring buffer similarly.
        const fp_total = footprint_counts[active_instrument];
        const fp_len = @min(fp_total, 512);
        var fp_linear: [512]FootprintUpdate = undefined;
        if (fp_total > 512) {
            const fp_head = fp_total % 512;
            const fp_tail_len = 512 - fp_head;
            @memcpy(fp_linear[0..fp_tail_len], footprint_history[active_instrument][fp_head..512]);
            @memcpy(fp_linear[fp_tail_len..512], footprint_history[active_instrument][0..fp_head]);
        } else {
            @memcpy(fp_linear[0..fp_len], footprint_history[active_instrument][0..fp_len]);
        }
        const inst_name = orderbook_snap[active_instrument].instrument.slice();
        chart_panel.draw(&renderer, panels.chart, candle_linear[0..candle_len], fp_linear[0..fp_len], theme, viewport_offset[active_instrument], candle_width, crosshair_active, crosshair_idx[active_instrument], inst_name);

        // Order entry panel
        order_entry.draw(&renderer, panels.order_entry, active_panel == PANEL_ORDER_ENTRY, theme);

        // Recent orders panel
        if (active_panel == PANEL_RECENT_ORDERS) renderer.writeRawPub("\x1b[1m");
        orders_panel.draw(&renderer, panels.recent_orders, orders_buf[0..orders_count], frame_count, theme);
        if (active_panel == PANEL_RECENT_ORDERS) renderer.writeRawPub("\x1b[0m");

        // Trade tape panel (time & sales from fake traders)
        trade_tape_panel.draw(&renderer, panels.trade_tape, &tape_buf, tape_count, theme);

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
            status_panel.draw(&renderer, panels.status_bar, &latest_status, status_age, theme, inst_name);
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
                &viewport_offset, &candle_width, &candle_counts, &crosshair_active, &crosshair_idx);
        }

        // Process input bytes
        while (term.readByte()) |byte| {
            const text_mode = (active_panel == PANEL_ORDER_ENTRY);
            if (input_handler.feed(byte, text_mode)) |act| {
                const should_quit = processAction(&input_handler, act, &active_panel, &active_instrument,
                    &order_entry, &from_tui, &status_msg, &status_msg_len, &status_msg_frames, &show_positions_overlay,
                    &viewport_offset, &candle_width, &candle_counts, &crosshair_active, &crosshair_idx);
                if (should_quit) {
                    _ = from_tui.push(UserCommand{ .quit = {} });
                    goto_done = true;
                    break;
                }
            }
        }

        if (goto_done) break;

        // Keep order entry instrument in sync with active instrument
        const active_sym = orderbook_snap[active_instrument].instrument.slice();
        if (active_sym.len > 0 and !std.mem.eql(u8, order_entry.fields[0].slice(), active_sym)) {
            order_entry.fields[0] = order_entry_panel_mod.TextField.init(active_sym);
        }

        frame_count += 1;
        {
            const req = std.os.linux.timespec{ .sec = 0, .nsec = 66_000_000 };
            _ = std.os.linux.nanosleep(&req, null); // ~15 FPS
        }
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
    viewport_offset: *[NUM_INSTRUMENTS]usize,
    candle_width: *u8,
    candle_counts: *[NUM_INSTRUMENTS]usize,
    crosshair_active: *bool,
    crosshair_idx: *[NUM_INSTRUMENTS]usize,
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
                // Cycle through all instruments
                active_instrument.* = (active_instrument.* + 1) % NUM_INSTRUMENTS;
            }
        },
        .arrow_up, .arrow_down => {
            if (active_panel.* == PANEL_ORDER_ENTRY) {
                _ = order_entry.handleAction(action);
            }
        },
        .arrow_left => {
            if (active_panel.* != PANEL_ORDER_ENTRY) {
                const idx = active_instrument.*;
                if (crosshair_active.*) {
                    // Move crosshair left (clamp to 0)
                    if (crosshair_idx.*[idx] > 0) {
                        crosshair_idx.*[idx] -= 1;
                    }
                } else {
                    // Scroll left (further back in history)
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
            }
        },
        .arrow_right => {
            if (active_panel.* != PANEL_ORDER_ENTRY) {
                const idx = active_instrument.*;
                if (crosshair_active.*) {
                    // Move crosshair right (clamped to visible_candles - 1)
                    // We don't know visible count here without panel size, so use a generous max
                    const total = candle_counts.*[idx];
                    if (total > 0 and crosshair_idx.*[idx] + 1 < total) {
                        crosshair_idx.*[idx] += 1;
                    }
                } else {
                    // Scroll right (toward newest candles)
                    if (viewport_offset.*[idx] > 1) {
                        viewport_offset.*[idx] -= 1;
                    } else {
                        // Back to auto-follow
                        viewport_offset.*[idx] = 0;
                    }
                }
            }
        },
        .toggle_crosshair => {
            const idx = active_instrument.*;
            crosshair_active.* = !crosshair_active.*;
            if (crosshair_active.*) {
                // When activating, set to last visible candle index
                const total = candle_counts.*[idx];
                crosshair_idx.*[idx] = if (total > 0) total - 1 else 0;
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
    }
    return false;
}

test "desk_smoke" {}

test "synthetic_8_instruments_init" {
    const SyntheticFeed = @import("synthetic.zig").SyntheticFeed;
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();
    // All 8 books should be initialized with depth levels
    for (0..8) |i| {
        try std.testing.expect(feed.books[i].bids_len >= 1);
        try std.testing.expect(feed.books[i].asks_len >= 1);
    }
    // Tick should advance
    feed.tick();
    try std.testing.expect(feed.tick_count == 1);
}

test "synthetic_8_instruments_correlation" {
    const SyntheticFeed = @import("synthetic.zig").SyntheticFeed;
    var feed = try SyntheticFeed.init(std.testing.allocator, 42);
    defer feed.deinit();
    for (0..100) |_| feed.tick();
    // BTC spot (idx 0) and BTC-USD-PERP (idx 1) should stay within 2% of each other
    const spot_mid = feed.books[0].midPrice() orelse return error.NoMidPrice;
    const perp_mid = feed.books[1].midPrice() orelse return error.NoMidPrice;
    try std.testing.expect(spot_mid > 0);
    try std.testing.expect(perp_mid > 0);
    const diff = @abs(perp_mid - spot_mid);
    const threshold = @divTrunc(spot_mid * 2, 100);
    try std.testing.expect(diff < threshold);
}

test "engine_8_instrument_init" {
    const SpscRB = SpscRingBuffer(EngineEvent);
    const SpscRBCmd = SpscRingBuffer(UserCommand);
    var to_tui = try SpscRB.init(std.testing.allocator, 64);
    defer to_tui.deinit();
    var from_tui = try SpscRBCmd.init(std.testing.allocator, 16);
    defer from_tui.deinit();
    var engine = try Engine.init(std.testing.allocator, &to_tui, &from_tui);
    defer engine.deinit();
    // Engine should start at tick 0 with 8 instruments loaded
    try std.testing.expect(engine.tick == 0);
    try std.testing.expect(engine.feed.books[0].bids_len >= 1);
    try std.testing.expect(engine.feed.books[7].bids_len >= 1);
}
