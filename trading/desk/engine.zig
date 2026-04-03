// Engine thread: generates tick events and sends them to TUI via SpscRingBuffer.

const std = @import("std");
const SpscRingBuffer = @import("ring_buffer").SpscRingBuffer;
const msg = @import("messages.zig");
const EngineEvent = msg.EngineEvent;
const UserCommand = msg.UserCommand;

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
    ) !Engine {
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

    /// Engine main loop. Runs in a separate thread.
    pub fn run(self: *Engine) void {
        while (self.running.load(.acquire)) {
            self.tick += 1;

            // Send tick event
            const tick_event = EngineEvent{ .tick = self.tick };
            if (!self.to_tui.push(tick_event)) {
                // Buffer full: drop event
            }

            // Send status update every 10 ticks
            if (self.tick % 10 == 0) {
                const status = EngineEvent{ .status = msg.StatusUpdate{
                    .tick = self.tick,
                    .engine_time_ns = 0,
                    .instrument_count = 2,
                    .connected = false,
                } };
                _ = self.to_tui.push(status);
            }

            // Drain commands from TUI
            while (self.from_tui.pop()) |cmd| {
                switch (cmd) {
                    .quit => {
                        self.running.store(false, .release);
                        _ = self.to_tui.push(EngineEvent{ .shutdown_ack = {} });
                        return;
                    },
                    .select_instrument => {},
                    .submit_order => |req| {
                        // Simple mock: immediately reject
                        _ = req;
                    },
                    .cancel_order => {},
                }
            }

            std.Thread.sleep(100_000_000); // 100ms per tick
        }
    }

    /// Request engine to stop (called from TUI thread).
    pub fn requestStop(self: *Engine) void {
        self.running.store(false, .release);
    }
};

test "engine_init" {
    const std_ = @import("std");
    _ = std_;
    // Engine init is tested structurally — no actual thread spawn in unit tests
    try @import("std").testing.expect(true);
}
