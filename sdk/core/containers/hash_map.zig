const std = @import("std");

/// Compile-time-sized open-addressing hash map with linear probing.
pub fn FixedHashMap(comptime K: type, comptime V: type, comptime capacity: usize) type {
    return struct {
        const Self = @This();

        const Slot = struct {
            occupied: bool,
            key: K,
            value: V,
        };

        slots: [capacity]Slot,
        len: usize,

        pub fn init() Self {
            return .{
                .slots = [_]Slot{.{ .occupied = false, .key = undefined, .value = undefined }} ** capacity,
                .len = 0,
            };
        }

        pub fn put(self: *Self, key: K, value: V) !void {
            if (self.len >= capacity) return error.OutOfMemory;
            var idx = hash(key) % capacity;
            var i: usize = 0;
            while (i < capacity) : (i += 1) {
                const slot = &self.slots[idx];
                if (!slot.occupied) {
                    slot.* = .{ .occupied = true, .key = key, .value = value };
                    self.len += 1;
                    return;
                }
                if (eql(K, slot.key, key)) {
                    slot.value = value;
                    return;
                }
                idx = (idx + 1) % capacity;
            }
            return error.OutOfMemory;
        }

        pub fn get(self: *Self, key: K) ?V {
            var idx = hash(key) % capacity;
            var i: usize = 0;
            while (i < capacity) : (i += 1) {
                const slot = &self.slots[idx];
                if (!slot.occupied) return null;
                if (eql(K, slot.key, key)) return slot.value;
                idx = (idx + 1) % capacity;
            }
            return null;
        }

        pub fn remove(self: *Self, key: K) bool {
            var idx = hash(key) % capacity;
            var i: usize = 0;
            while (i < capacity) : (i += 1) {
                const slot = &self.slots[idx];
                if (!slot.occupied) return false;
                if (eql(K, slot.key, key)) {
                    slot.occupied = false;
                    self.len -= 1;
                    // Rehash subsequent entries to maintain linear probing invariant
                    var j = (idx + 1) % capacity;
                    while (self.slots[j].occupied) {
                        const k2 = self.slots[j].key;
                        const v2 = self.slots[j].value;
                        self.slots[j].occupied = false;
                        self.len -= 1;
                        self.put(k2, v2) catch {};
                        j = (j + 1) % capacity;
                    }
                    return true;
                }
                idx = (idx + 1) % capacity;
            }
            return false;
        }

        pub fn count(self: *Self) usize {
            return self.len;
        }

        fn hash(key: K) usize {
            return switch (@typeInfo(K)) {
                .int, .comptime_int => @intCast(key),
                .pointer => |ptr| blk: {
                    if (ptr.child == u8) {
                        // slice of u8 — hash as string
                        const s: []const u8 = key;
                        var h: usize = 14695981039346656037;
                        for (s) |b| {
                            h ^= b;
                            h = h *% 1099511628211;
                        }
                        break :blk h;
                    }
                    break :blk @intFromPtr(key);
                },
                else => std.hash.autoHash(std.hash.Wyhash.init(0), key),
            };
        }

        fn eql(comptime KT: type, a: KT, b: KT) bool {
            return switch (@typeInfo(KT)) {
                .int, .comptime_int => a == b,
                .pointer => |ptr| blk: {
                    if (ptr.child == u8) {
                        const sa: []const u8 = a;
                        const sb: []const u8 = b;
                        break :blk std.mem.eql(u8, sa, sb);
                    }
                    break :blk a == b;
                },
                else => std.meta.eql(a, b),
            };
        }
    };
}
