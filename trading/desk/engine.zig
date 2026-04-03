const std = @import("std");
const ring_buffer = @import("ring_buffer");
const SpscRingBuffer = ring_buffer.SpscRingBuffer;
const messages = @import("messages.zig");
const EngineEvent = messages.EngineEvent;
const UserCommand = messages.UserCommand;

pub const Engine = struct {
    allocator: std.mem.Allocator,
    to_tui: *SpscRingBuffer(EngineEvent),
    from_tui: *SpscRingBuffer(UserCommand),
    running: std.atomic.Value(bool),
    tick: u64,

    pub fn init(
        allocator: std.mem.Allocator,
        to_tui: *SpscRingBuffer(EngineEvent),
        from_tui: *SpscRingBuffer(UserCommand),
    ) Engine {
        return Engine{
            .allocator = allocator,
            .to_tui = to_tui,
            .from_tui = from_tui,
            .running = std.atomic.Value(bool).init(true),
            .tick = 0,
        };
    }

    pub fn deinit(self: *Engine) void {
        _ = self;
    }

    /// Main engine loop — runs on the engine thread.
    pub fn run(self: *Engine) void {
        while (self.running.load(.acquire)) {
            self.tick += 1;

            // Process commands from TUI
            while (self.from_tui.pop()) |cmd| {
                switch (cmd) {
                    .quit => {
                        self.running.store(false, .release);
                        _ = self.to_tui.push(.{ .shutdown_ack = {} });
                        return;
                    },
                    else => {},
                }
            }

            // Push tick event
            _ = self.to_tui.push(.{ .tick = self.tick });

            // Push status update
            _ = self.to_tui.push(.{ .status = .{
                .tick = self.tick,
                .engine_time_ns = @intCast(std.time.nanoTimestamp()),
                .instrument_count = 0,
                .connected = false,
            } });

            std.time.sleep(100_000_000); // 100ms per tick
        }
    }

    pub fn requestStop(self: *Engine) void {
        self.running.store(false, .release);
    }
};

test "engine_init_deinit" {
    const allocator = std.testing.allocator;
    var to_tui = try SpscRingBuffer(EngineEvent).init(allocator, 256);
    defer to_tui.deinit();
    var from_tui = try SpscRingBuffer(UserCommand).init(allocator, 256);
    defer from_tui.deinit();

    var engine = Engine.init(allocator, &to_tui, &from_tui);
    defer engine.deinit();
    try std.testing.expect(engine.tick == 0);
}
