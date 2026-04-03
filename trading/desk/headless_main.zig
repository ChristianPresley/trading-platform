// Headless desk executable — runs the engine without terminal dependency.
// Exposes HeadlessDesk with push/pop/shutdown API for programmatic control.

const std = @import("std");
const SpscRingBuffer = @import("ring_buffer").SpscRingBuffer;
const msg = @import("messages.zig");
const EngineEvent = msg.EngineEvent;
const UserCommand = msg.UserCommand;
const Engine = @import("engine.zig").Engine;

pub const HeadlessDesk = struct {
    to_engine: *SpscRingBuffer(UserCommand),
    from_engine: *SpscRingBuffer(EngineEvent),
    engine: Engine,
    engine_thread: std.Thread,
    allocator: std.mem.Allocator,
    stopped: bool,

    pub fn init(allocator: std.mem.Allocator) !HeadlessDesk {
        const to_engine = try allocator.create(SpscRingBuffer(UserCommand));
        errdefer allocator.destroy(to_engine);
        to_engine.* = try SpscRingBuffer(UserCommand).init(allocator, 256);
        errdefer to_engine.deinit();

        const from_engine = try allocator.create(SpscRingBuffer(EngineEvent));
        errdefer allocator.destroy(from_engine);
        from_engine.* = try SpscRingBuffer(EngineEvent).init(allocator, 256);
        errdefer from_engine.deinit();

        // Engine.init takes: to_tui = from_engine, from_tui = to_engine
        var engine = try Engine.init(allocator, from_engine, to_engine);
        errdefer engine.deinit();

        const thread = try std.Thread.spawn(.{}, Engine.run, .{&engine});

        return HeadlessDesk{
            .to_engine = to_engine,
            .from_engine = from_engine,
            .engine = engine,
            .engine_thread = thread,
            .allocator = allocator,
            .stopped = false,
        };
    }

    /// Push a UserCommand into the engine. Returns true if the ring buffer accepted it.
    pub fn push(self: *HeadlessDesk, cmd: UserCommand) bool {
        return self.to_engine.push(cmd);
    }

    /// Pop the next EngineEvent, or null if none is available.
    pub fn pop(self: *HeadlessDesk) ?EngineEvent {
        return self.from_engine.pop();
    }

    /// Shutdown the engine cleanly and join the engine thread.
    pub fn shutdown(self: *HeadlessDesk) void {
        if (self.stopped) return;
        self.stopped = true;

        _ = self.to_engine.push(UserCommand{ .quit = {} });

        // Spin-drain from_engine until shutdown_ack received (with timeout)
        var iterations: usize = 0;
        const max_iterations: usize = 1000;
        outer: while (iterations < max_iterations) : (iterations += 1) {
            while (self.from_engine.pop()) |event| {
                switch (event) {
                    .shutdown_ack => break :outer,
                    else => {},
                }
            }
            std.Thread.sleep(1_000_000); // 1ms
        }

        // If timeout reached without ack, force stop
        if (iterations >= max_iterations) {
            self.engine.requestStop();
        }

        self.engine_thread.join();

        self.from_engine.deinit();
        self.allocator.destroy(self.from_engine);
        self.to_engine.deinit();
        self.allocator.destroy(self.to_engine);
        self.engine.deinit();
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var desk = try HeadlessDesk.init(allocator);

    // Run briefly and collect events
    std.Thread.sleep(300_000_000); // 300ms — a few engine ticks

    var event_count: usize = 0;
    while (desk.pop()) |_| {
        event_count += 1;
    }

    std.debug.print("HeadlessDesk: received {} events\n", .{event_count});

    desk.shutdown();
}

test "headless_init_shutdown" {
    var desk = try HeadlessDesk.init(std.testing.allocator);
    desk.shutdown();
    // If we get here without deadlock or crash, the test passes.
}

test "headless_push_pop" {
    var desk = try HeadlessDesk.init(std.testing.allocator);
    defer desk.shutdown();

    // Sleep long enough for the engine to produce at least one event (100ms per tick)
    std.Thread.sleep(200_000_000); // 200ms

    var count: usize = 0;
    while (desk.pop()) |_| {
        count += 1;
    }

    try std.testing.expect(count > 0);
}

test "headless_quit_ack" {
    var desk = try HeadlessDesk.init(std.testing.allocator);
    defer desk.shutdown();

    // Push quit directly and spin until shutdown_ack arrives
    _ = desk.push(UserCommand{ .quit = {} });

    var received_ack = false;
    var iters: usize = 0;
    while (iters < 1000) : (iters += 1) {
        while (desk.pop()) |event| {
            switch (event) {
                .shutdown_ack => {
                    received_ack = true;
                },
                else => {},
            }
        }
        if (received_ack) break;
        std.Thread.sleep(1_000_000); // 1ms
    }

    try std.testing.expect(received_ack);
}
