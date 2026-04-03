const std = @import("std");

/// Fixed-capacity sorted array with binary search insert/find.
pub fn SortedArray(comptime T: type, comptime compareFn: fn (T, T) std.math.Order) type {
    return struct {
        const Self = @This();

        items: []T,
        len: usize,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, cap: usize) !Self {
            const buf = try allocator.alloc(T, cap);
            return Self{
                .items = buf,
                .len = 0,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }

        /// Binary search insert, maintaining sorted order. Returns error.OutOfMemory if full.
        pub fn insert(self: *Self, item: T) !void {
            if (self.len >= self.items.len) return error.OutOfMemory;
            const pos = self.lowerBound(item);
            // Shift elements right
            var i = self.len;
            while (i > pos) : (i -= 1) {
                self.items[i] = self.items[i - 1];
            }
            self.items[pos] = item;
            self.len += 1;
        }

        /// Binary search for item. Returns index or null.
        pub fn find(self: *Self, item: T) ?usize {
            const pos = self.lowerBound(item);
            if (pos < self.len and compareFn(self.items[pos], item) == .eq) {
                return pos;
            }
            return null;
        }

        /// Remove element at index. Returns removed element.
        pub fn removeAt(self: *Self, index: usize) T {
            const item = self.items[index];
            var i = index;
            while (i + 1 < self.len) : (i += 1) {
                self.items[i] = self.items[i + 1];
            }
            self.len -= 1;
            return item;
        }

        fn lowerBound(self: *Self, item: T) usize {
            var lo: usize = 0;
            var hi: usize = self.len;
            while (lo < hi) {
                const mid = lo + (hi - lo) / 2;
                switch (compareFn(self.items[mid], item)) {
                    .lt => lo = mid + 1,
                    else => hi = mid,
                }
            }
            return lo;
        }
    };
}
