const std = @import("std");
const ring_buffer = @import("ring_buffer");
const mpsc_queue = @import("mpsc_queue");
const hash_map = @import("hash_map");
const sorted_array = @import("sorted_array");

// Ring buffer tests
test "SpscRingBuffer: push until full returns false" {
    const Rb = ring_buffer.SpscRingBuffer(u32);
    var rb = try Rb.init(std.testing.allocator, 4);
    defer rb.deinit();

    // Capacity rounds to 4 (next power of 2 >= 4)
    try std.testing.expect(rb.push(1));
    try std.testing.expect(rb.push(2));
    try std.testing.expect(rb.push(3));
    try std.testing.expect(rb.push(4));
    try std.testing.expect(!rb.push(5)); // full
}

test "SpscRingBuffer: pop until empty returns null" {
    const Rb = ring_buffer.SpscRingBuffer(u32);
    var rb = try Rb.init(std.testing.allocator, 2);
    defer rb.deinit();

    _ = rb.push(10);
    _ = rb.push(20);

    try std.testing.expectEqual(@as(?u32, 10), rb.pop());
    try std.testing.expectEqual(@as(?u32, 20), rb.pop());
    try std.testing.expectEqual(@as(?u32, null), rb.pop());
}

test "SpscRingBuffer: push/pop interleaved" {
    const Rb = ring_buffer.SpscRingBuffer(u32);
    var rb = try Rb.init(std.testing.allocator, 4);
    defer rb.deinit();

    _ = rb.push(1);
    _ = rb.push(2);
    try std.testing.expectEqual(@as(?u32, 1), rb.pop());
    _ = rb.push(3);
    try std.testing.expectEqual(@as(?u32, 2), rb.pop());
    try std.testing.expectEqual(@as(?u32, 3), rb.pop());
    try std.testing.expectEqual(@as(?u32, null), rb.pop());
}

test "SpscRingBuffer: capacity rounds to power of 2" {
    const Rb = ring_buffer.SpscRingBuffer(u32);
    var rb = try Rb.init(std.testing.allocator, 3);
    defer rb.deinit();
    // Capacity should be 4 (next power of 2 >= 3)
    try std.testing.expectEqual(@as(usize, 4), rb.capacity);
}

test "SpscRingBuffer: capacity 1 works" {
    const Rb = ring_buffer.SpscRingBuffer(u32);
    var rb = try Rb.init(std.testing.allocator, 1);
    defer rb.deinit();

    try std.testing.expect(rb.push(42));
    try std.testing.expect(!rb.push(99)); // full
    try std.testing.expectEqual(@as(?u32, 42), rb.pop());
    try std.testing.expect(rb.push(99));
}

// MPSC queue tests
test "MpscQueue: push and pop FIFO" {
    const Q = mpsc_queue.MpscQueue(u32);
    var q = try Q.initAlloc(std.testing.allocator);
    defer q.deinit();

    var n1 = Q.Node.init(1);
    var n2 = Q.Node.init(2);
    var n3 = Q.Node.init(3);

    q.push(&n1);
    q.push(&n2);
    q.push(&n3);

    const p1 = q.pop();
    const p2 = q.pop();
    const p3 = q.pop();

    try std.testing.expect(p1 != null);
    try std.testing.expect(p2 != null);
    try std.testing.expect(p3 != null);
    try std.testing.expectEqual(@as(u32, 1), p1.?.data);
    try std.testing.expectEqual(@as(u32, 2), p2.?.data);
    try std.testing.expectEqual(@as(u32, 3), p3.?.data);
}

test "MpscQueue: pop from empty returns null" {
    const Q = mpsc_queue.MpscQueue(u32);
    var q = try Q.initAlloc(std.testing.allocator);
    defer q.deinit();
    try std.testing.expectEqual(@as(?*Q.Node, null), q.pop());
}

// Hash map tests
test "FixedHashMap: put/get round-trip" {
    var map = hash_map.FixedHashMap(u32, u32, 16).init();
    try map.put(1, 100);
    try map.put(2, 200);
    try std.testing.expectEqual(@as(?u32, 100), map.get(1));
    try std.testing.expectEqual(@as(?u32, 200), map.get(2));
    try std.testing.expectEqual(@as(?u32, null), map.get(3));
}

test "FixedHashMap: remove returns true for existing key" {
    var map = hash_map.FixedHashMap(u32, u32, 16).init();
    try map.put(5, 50);
    try std.testing.expect(map.remove(5));
    try std.testing.expect(!map.remove(5));
    try std.testing.expectEqual(@as(?u32, null), map.get(5));
}

test "FixedHashMap: put when full returns error" {
    var map = hash_map.FixedHashMap(u32, u32, 2).init();
    try map.put(1, 1);
    try map.put(2, 2);
    try std.testing.expectError(error.OutOfMemory, map.put(3, 3));
}

test "FixedHashMap: update existing key" {
    var map = hash_map.FixedHashMap(u32, u32, 8).init();
    try map.put(7, 70);
    try map.put(7, 77);
    try std.testing.expectEqual(@as(?u32, 77), map.get(7));
    try std.testing.expectEqual(@as(usize, 1), map.count());
}

// Sorted array tests
fn compareU32(a: u32, b: u32) std.math.Order {
    return std.math.order(a, b);
}

test "SortedArray: insert maintains sort order" {
    var sa = try sorted_array.SortedArray(u32, compareU32).init(std.testing.allocator, 8);
    defer sa.deinit();

    try sa.insert(5);
    try sa.insert(1);
    try sa.insert(3);
    try sa.insert(2);

    try std.testing.expectEqual(@as(u32, 1), sa.items[0]);
    try std.testing.expectEqual(@as(u32, 2), sa.items[1]);
    try std.testing.expectEqual(@as(u32, 3), sa.items[2]);
    try std.testing.expectEqual(@as(u32, 5), sa.items[3]);
}

test "SortedArray: find returns correct index" {
    var sa = try sorted_array.SortedArray(u32, compareU32).init(std.testing.allocator, 8);
    defer sa.deinit();

    try sa.insert(10);
    try sa.insert(20);
    try sa.insert(30);

    try std.testing.expectEqual(@as(?usize, 0), sa.find(10));
    try std.testing.expectEqual(@as(?usize, 1), sa.find(20));
    try std.testing.expectEqual(@as(?usize, 2), sa.find(30));
    try std.testing.expectEqual(@as(?usize, null), sa.find(15));
}

test "SortedArray: removeAt shifts elements" {
    var sa = try sorted_array.SortedArray(u32, compareU32).init(std.testing.allocator, 8);
    defer sa.deinit();

    try sa.insert(1);
    try sa.insert(2);
    try sa.insert(3);

    const removed = sa.removeAt(1); // remove middle element (2)
    try std.testing.expectEqual(@as(u32, 2), removed);
    try std.testing.expectEqual(@as(usize, 2), sa.len);
    try std.testing.expectEqual(@as(u32, 1), sa.items[0]);
    try std.testing.expectEqual(@as(u32, 3), sa.items[1]);
}

test "SortedArray: OutOfMemory when full" {
    var sa = try sorted_array.SortedArray(u32, compareU32).init(std.testing.allocator, 2);
    defer sa.deinit();

    try sa.insert(1);
    try sa.insert(2);
    try std.testing.expectError(error.OutOfMemory, sa.insert(3));
}
