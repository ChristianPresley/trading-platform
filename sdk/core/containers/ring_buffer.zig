const std = @import("std");

/// Single-producer single-consumer lock-free ring buffer.
pub fn SpscRingBuffer(comptime T: type) type {
    return struct {
        const Self = @This();

        buffer: []T,
        capacity: usize,
        write_idx: std.atomic.Value(usize),
        read_idx: std.atomic.Value(usize),
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, capacity: usize) !Self {
            const cap = nextPowerOfTwo(capacity);
            const buf = try allocator.alloc(T, cap);
            return Self{
                .buffer = buf,
                .capacity = cap,
                .write_idx = std.atomic.Value(usize).init(0),
                .read_idx = std.atomic.Value(usize).init(0),
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
        }

        /// Push an item. Returns false if the buffer is full (non-blocking).
        pub fn push(self: *Self, item: T) bool {
            const write = self.write_idx.load(.acquire);
            const read = self.read_idx.load(.acquire);
            if (write - read >= self.capacity) return false;
            self.buffer[write & (self.capacity - 1)] = item;
            self.write_idx.store(write + 1, .release);
            return true;
        }

        /// Pop an item. Returns null if empty (non-blocking).
        pub fn pop(self: *Self) ?T {
            const read = self.read_idx.load(.acquire);
            const write = self.write_idx.load(.acquire);
            if (read >= write) return null;
            const item = self.buffer[read & (self.capacity - 1)];
            self.read_idx.store(read + 1, .release);
            return item;
        }

        fn nextPowerOfTwo(n: usize) usize {
            if (n == 0) return 1;
            var v = n - 1;
            v |= v >> 1;
            v |= v >> 2;
            v |= v >> 4;
            v |= v >> 8;
            v |= v >> 16;
            v |= v >> 32;
            return v + 1;
        }
    };
}
