const std = @import("std");
const event_store = @import("event_store");

/// Helper: get an absolute path inside a tmpDir for a given filename.
/// Creates the file first so realpath works, then returns the absolute path.
fn tmpPath(tmp: *std.testing.TmpDir, filename: []const u8, buf: []u8) ![]const u8 {
    // Create an empty file so realpath can resolve it
    const f = try tmp.dir.createFile(filename, .{});
    f.close();
    return try tmp.dir.realpath(filename, buf);
}

test "EventStore: append/read round-trip" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const path = try tmpPath(&tmp, "events.bin", &path_buf);

    var store = try event_store.EventStore.init(std.testing.allocator, path);
    defer store.deinit();

    const seq = try store.append("hello world");
    try std.testing.expectEqual(@as(u64, 1), seq);

    const data = try store.read(1);
    defer std.testing.allocator.free(data);
    try std.testing.expectEqualStrings("hello world", data);
}

test "EventStore: sequence numbers are monotonically increasing" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const path = try tmpPath(&tmp, "events.bin", &path_buf);

    var store = try event_store.EventStore.init(std.testing.allocator, path);
    defer store.deinit();

    const s1 = try store.append("event1");
    const s2 = try store.append("event2");
    const s3 = try store.append("event3");

    try std.testing.expect(s1 < s2);
    try std.testing.expect(s2 < s3);
    try std.testing.expectEqual(@as(u64, 1), s1);
    try std.testing.expectEqual(@as(u64, 2), s2);
    try std.testing.expectEqual(@as(u64, 3), s3);
}

test "EventStore: lastSequence returns correct value" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const path = try tmpPath(&tmp, "events.bin", &path_buf);

    var store = try event_store.EventStore.init(std.testing.allocator, path);
    defer store.deinit();

    try std.testing.expectEqual(@as(u64, 0), store.lastSequence());
    _ = try store.append("a");
    try std.testing.expectEqual(@as(u64, 1), store.lastSequence());
    _ = try store.append("b");
    try std.testing.expectEqual(@as(u64, 2), store.lastSequence());
}

test "EventStore: read non-existent sequence returns error" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const path = try tmpPath(&tmp, "events.bin", &path_buf);

    var store = try event_store.EventStore.init(std.testing.allocator, path);
    defer store.deinit();

    try std.testing.expectError(error.EventNotFound, store.read(99));
}

test "EventStore: replay from seq 1 returns all events" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const path = try tmpPath(&tmp, "events.bin", &path_buf);

    var store = try event_store.EventStore.init(std.testing.allocator, path);
    defer store.deinit();

    _ = try store.append("first");
    _ = try store.append("second");
    _ = try store.append("third");

    var iter = store.replay(1);
    var count: usize = 0;
    while (iter.next()) |evt| {
        defer std.testing.allocator.free(evt.data);
        count += 1;
        try std.testing.expect(evt.sequence >= 1);
    }
    try std.testing.expectEqual(@as(usize, 3), count);
}

test "EventStore: replay from arbitrary sequence" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const path = try tmpPath(&tmp, "events.bin", &path_buf);

    var store = try event_store.EventStore.init(std.testing.allocator, path);
    defer store.deinit();

    _ = try store.append("event-1");
    _ = try store.append("event-2");
    _ = try store.append("event-3");
    _ = try store.append("event-4");
    _ = try store.append("event-5");

    // Replay from seq 3 — should get events 3, 4, 5
    var iter = store.replay(3);
    var seqs = std.ArrayList(u64).init(std.testing.allocator);
    defer seqs.deinit();

    while (iter.next()) |evt| {
        defer std.testing.allocator.free(evt.data);
        try seqs.append(evt.sequence);
    }

    try std.testing.expectEqual(@as(usize, 3), seqs.items.len);
    try std.testing.expectEqual(@as(u64, 3), seqs.items[0]);
    try std.testing.expectEqual(@as(u64, 4), seqs.items[1]);
    try std.testing.expectEqual(@as(u64, 5), seqs.items[2]);
}

test "EventStore: empty store replay returns no events" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const path = try tmpPath(&tmp, "events.bin", &path_buf);

    var store = try event_store.EventStore.init(std.testing.allocator, path);
    defer store.deinit();

    var iter = store.replay(0);
    var count: usize = 0;
    while (iter.next()) |evt| {
        defer std.testing.allocator.free(evt.data);
        count += 1;
    }
    try std.testing.expectEqual(@as(usize, 0), count);
}

test "EventStore: multiple events read individually" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const path = try tmpPath(&tmp, "events.bin", &path_buf);

    var store = try event_store.EventStore.init(std.testing.allocator, path);
    defer store.deinit();

    _ = try store.append("alpha");
    _ = try store.append("beta");
    _ = try store.append("gamma");

    const d1 = try store.read(1);
    defer std.testing.allocator.free(d1);
    try std.testing.expectEqualStrings("alpha", d1);

    const d2 = try store.read(2);
    defer std.testing.allocator.free(d2);
    try std.testing.expectEqualStrings("beta", d2);

    const d3 = try store.read(3);
    defer std.testing.allocator.free(d3);
    try std.testing.expectEqualStrings("gamma", d3);
}

test "EventStore: timestamps are non-zero" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const path = try tmpPath(&tmp, "events.bin", &path_buf);

    var store = try event_store.EventStore.init(std.testing.allocator, path);
    defer store.deinit();

    _ = try store.append("ts-test");

    // Read via replay to get the event with timestamp
    var iter = store.replay(1);
    if (iter.next()) |evt| {
        defer std.testing.allocator.free(evt.data);
        try std.testing.expect(evt.timestamp > 0);
    } else {
        return error.NoEvent;
    }
}
