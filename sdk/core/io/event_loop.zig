// io_uring-based event loop
// Uses Linux io_uring for high-performance async I/O

const std = @import("std");

pub const Handler = struct {
    onRead: *const fn (fd: std.posix.fd_t, data: []const u8) void,
    onError: *const fn (fd: std.posix.fd_t, err: anyerror) void,
};

const SocketEntry = struct {
    fd: std.posix.fd_t,
    handler: *const Handler,
};

const TimerEntry = struct {
    timeout_ms: u64,
    callback: *const fn () void,
};

pub const EventLoop = struct {
    allocator: std.mem.Allocator,
    ring: std.os.linux.IoUring,
    sockets: std.ArrayList(SocketEntry),
    timers: std.ArrayList(TimerEntry),
    running: bool,
    read_buf: [65536]u8,

    pub fn init(allocator: std.mem.Allocator) !EventLoop {
        const ring = try std.os.linux.IoUring.init(256, 0);
        return EventLoop{
            .allocator = allocator,
            .ring = ring,
            .sockets = .{},
            .timers = .{},
            .running = false,
            .read_buf = undefined,
        };
    }

    pub fn addSocket(self: *EventLoop, fd: std.posix.fd_t, handler: *const Handler) !void {
        try self.sockets.append(self.allocator, .{ .fd = fd, .handler = handler });
    }

    pub fn addTimer(self: *EventLoop, timeout_ms: u64, callback: *const fn () void) !void {
        try self.timers.append(self.allocator, .{ .timeout_ms = timeout_ms, .callback = callback });
    }

    pub fn removeSocket(self: *EventLoop, fd: std.posix.fd_t) void {
        var i: usize = 0;
        while (i < self.sockets.items.len) {
            if (self.sockets.items[i].fd == fd) {
                _ = self.sockets.swapRemove(i);
            } else {
                i += 1;
            }
        }
    }

    pub fn run(self: *EventLoop) !void {
        self.running = true;
        while (self.running) {
            // Submit read requests for registered sockets
            for (self.sockets.items) |entry| {
                const sqe = try self.ring.read(
                    @intCast(entry.fd),
                    entry.fd,
                    .{ .buffer = &self.read_buf },
                    0,
                );
                _ = sqe;
            }

            // Submit timer timeouts
            for (self.timers.items) |entry| {
                const ts = std.os.linux.kernel_timespec{
                    .sec = @intCast(entry.timeout_ms / 1000),
                    .nsec = @intCast((entry.timeout_ms % 1000) * 1_000_000),
                };
                _ = try self.ring.timeout(0, &ts, 0, 0);
                _ = entry.callback;
            }

            const submitted = try self.ring.submit();
            if (submitted == 0 and self.sockets.items.len == 0 and self.timers.items.len == 0) {
                break;
            }

            // Wait for completions
            var cqe = self.ring.copy_cqe() catch |err| {
                if (err == error.WouldBlock) continue;
                return err;
            };
            _ = cqe;
        }
    }

    pub fn stop(self: *EventLoop) void {
        self.running = false;
    }

    pub fn deinit(self: *EventLoop) void {
        self.sockets.deinit(self.allocator);
        self.timers.deinit(self.allocator);
        self.ring.deinit();
    }
};
