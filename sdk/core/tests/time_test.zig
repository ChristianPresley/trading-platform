const std = @import("std");
const time = @import("time");

test "Timestamp.now() is monotonically increasing" {
    const t1 = time.Timestamp.now();
    // Spin briefly
    var i: usize = 0;
    while (i < 10000) : (i += 1) {}
    const t2 = time.Timestamp.now();
    try std.testing.expect(t2.nanos >= t1.nanos);
}

test "Timestamp.fromUnixNanos(0) produces epoch" {
    const ts = time.Timestamp.fromUnixNanos(0);
    try std.testing.expectEqual(@as(u128, 0), ts.nanos);

    var buf: [40]u8 = undefined;
    const s = ts.toRfc3339(&buf);
    // Should be 1970-01-01T00:00:00.000000000Z
    try std.testing.expectEqualStrings("1970-01-01T00:00:00.000000000Z", s);
}

test "Timestamp.toRfc3339 / fromRfc3339 round-trip" {
    // 2024-01-15T10:30:00.123456789Z
    const nanos: u128 = 1705313400 * 1_000_000_000 + 123456789;
    const ts = time.Timestamp.fromUnixNanos(nanos);

    var buf: [40]u8 = undefined;
    const s = ts.toRfc3339(&buf);

    const ts2 = try time.Timestamp.fromRfc3339(s);
    // Allow small tolerance due to fractional parsing
    const diff = if (ts2.nanos > ts.nanos) ts2.nanos - ts.nanos else ts.nanos - ts2.nanos;
    try std.testing.expect(diff < 1000); // within 1 microsecond
}

test "Timestamp.toIso8601 format" {
    // Unix epoch
    const ts = time.Timestamp.fromUnixNanos(0);
    var buf: [32]u8 = undefined;
    const s = ts.toIso8601(&buf);
    try std.testing.expectEqualStrings("19700101-00:00:00.000", s);
}

test "Timestamp.toFixUtc matches FIX UTCTimestamp spec" {
    const ts = time.Timestamp.fromUnixNanos(0);
    var buf: [32]u8 = undefined;
    const s = ts.toFixUtc(&buf);
    try std.testing.expectEqualStrings("19700101-00:00:00.000", s);
}

test "Timestamp.wallClock returns non-zero" {
    const ts = time.Timestamp.wallClock();
    // Wall clock should be past epoch
    try std.testing.expect(ts.nanos > 0);
}
