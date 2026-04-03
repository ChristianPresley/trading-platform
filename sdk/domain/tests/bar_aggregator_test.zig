// Tests for bar aggregators (time-based, volume-based, tick-based)

const std = @import("std");
const bar_aggregator = @import("bar_aggregator");

const BarAggregator = bar_aggregator.BarAggregator;
const VolumeBarAggregator = bar_aggregator.VolumeBarAggregator;
const TickBarAggregator = bar_aggregator.TickBarAggregator;
const Bar = bar_aggregator.Bar;

const NS_PER_MIN: u128 = 60_000_000_000;

// ---- Time-based BarAggregator ----

test "BarAggregator: single trade, no bar emitted" {
    var agg = BarAggregator.init(NS_PER_MIN);
    const result = agg.onTrade(50000, 10, 0);
    try std.testing.expect(result == null);
}

test "BarAggregator: OHLCV correctness within one bar" {
    var agg = BarAggregator.init(NS_PER_MIN);

    _ = agg.onTrade(100, 1, 0);                 // open = 100
    _ = agg.onTrade(150, 2, NS_PER_MIN / 4);    // high = 150
    _ = agg.onTrade(80, 3, NS_PER_MIN / 2);     // low = 80
    _ = agg.onTrade(120, 4, (3 * NS_PER_MIN) / 4); // close = 120

    const bar = agg.flush() orelse unreachable;
    try std.testing.expectEqual(@as(i64, 100), bar.open);
    try std.testing.expectEqual(@as(i64, 150), bar.high);
    try std.testing.expectEqual(@as(i64, 80), bar.low);
    try std.testing.expectEqual(@as(i64, 120), bar.close);
    try std.testing.expectEqual(@as(i64, 10), bar.volume); // 1+2+3+4
}

test "BarAggregator: bar boundary rollover emits completed bar" {
    var agg = BarAggregator.init(NS_PER_MIN);

    _ = agg.onTrade(100, 5, 0);
    _ = agg.onTrade(110, 3, NS_PER_MIN / 2);

    // This trade is past the interval — should emit the completed bar
    const bar = agg.onTrade(120, 2, NS_PER_MIN + 1);
    const completed = bar orelse unreachable;

    try std.testing.expectEqual(@as(i64, 100), completed.open);
    try std.testing.expectEqual(@as(i64, 110), completed.high);
    try std.testing.expectEqual(@as(i64, 100), completed.low);
    try std.testing.expectEqual(@as(i64, 110), completed.close);
    try std.testing.expectEqual(@as(i64, 8), completed.volume); // 5+3
    try std.testing.expectEqual(@as(u128, 0), completed.timestamp);
}

test "BarAggregator: single-trade bar — flush returns that trade as bar" {
    var agg = BarAggregator.init(NS_PER_MIN);
    _ = agg.onTrade(9999, 7, 0);
    const bar = agg.flush() orelse unreachable;
    try std.testing.expectEqual(@as(i64, 9999), bar.open);
    try std.testing.expectEqual(@as(i64, 9999), bar.high);
    try std.testing.expectEqual(@as(i64, 9999), bar.low);
    try std.testing.expectEqual(@as(i64, 9999), bar.close);
    try std.testing.expectEqual(@as(i64, 7), bar.volume);
}

test "BarAggregator: flush on empty returns null" {
    var agg = BarAggregator.init(NS_PER_MIN);
    try std.testing.expect(agg.flush() == null);
}

test "BarAggregator: out-of-order timestamp does not rewind" {
    var agg = BarAggregator.init(NS_PER_MIN);
    _ = agg.onTrade(100, 1, NS_PER_MIN / 2); // start at half-minute mark
    // out-of-order earlier timestamp — treat as same or later
    const result = agg.onTrade(200, 1, 0);
    // No bar emitted (timestamp 0 < bar_start + interval)
    try std.testing.expect(result == null);
    // Should still have accumulated data
    const bar = agg.flush() orelse unreachable;
    try std.testing.expectEqual(@as(i64, 100), bar.open);
}

test "BarAggregator: multiple bar boundaries emit multiple bars" {
    var agg = BarAggregator.init(NS_PER_MIN);

    _ = agg.onTrade(100, 1, 0);
    const bar1 = agg.onTrade(200, 1, NS_PER_MIN + 1);
    const bar2 = agg.onTrade(300, 1, 2 * NS_PER_MIN + 1);

    try std.testing.expect(bar1 != null);
    try std.testing.expect(bar2 != null);
    try std.testing.expectEqual(@as(i64, 100), bar1.?.open);
    try std.testing.expectEqual(@as(i64, 200), bar2.?.open);
}

// ---- VolumeBarAggregator ----

test "VolumeBarAggregator: emits bar when volume threshold reached" {
    var agg = VolumeBarAggregator.init(100);
    _ = agg.onTrade(50000, 40, 0);
    _ = agg.onTrade(50100, 30, 1);
    const bar = agg.onTrade(49900, 30, 2); // total = 100, should emit
    const completed = bar orelse unreachable;
    try std.testing.expectEqual(@as(i64, 50000), completed.open);
    try std.testing.expectEqual(@as(i64, 100), completed.volume);
}

test "VolumeBarAggregator: no bar before threshold" {
    var agg = VolumeBarAggregator.init(100);
    const r1 = agg.onTrade(50000, 40, 0);
    const r2 = agg.onTrade(50100, 30, 1);
    try std.testing.expect(r1 == null);
    try std.testing.expect(r2 == null);
}

test "VolumeBarAggregator: OHLCV correct across volume bar" {
    var agg = VolumeBarAggregator.init(50);
    _ = agg.onTrade(100, 10, 0);   // open = 100
    _ = agg.onTrade(200, 10, 1);   // high = 200
    _ = agg.onTrade(50, 10, 2);    // low = 50
    const bar = agg.onTrade(150, 20, 3); // close = 150, vol = 50
    const completed = bar orelse unreachable;
    try std.testing.expectEqual(@as(i64, 100), completed.open);
    try std.testing.expectEqual(@as(i64, 200), completed.high);
    try std.testing.expectEqual(@as(i64, 50), completed.low);
    try std.testing.expectEqual(@as(i64, 150), completed.close);
    try std.testing.expectEqual(@as(i64, 50), completed.volume);
}

// ---- TickBarAggregator ----

test "TickBarAggregator: emits bar every N ticks" {
    var agg = TickBarAggregator.init(3);
    _ = agg.onTrade(100, 1, 0);
    _ = agg.onTrade(200, 1, 1);
    const bar = agg.onTrade(150, 1, 2); // 3rd tick
    const completed = bar orelse unreachable;
    try std.testing.expectEqual(@as(i64, 100), completed.open);
    try std.testing.expectEqual(@as(i64, 200), completed.high);
    try std.testing.expectEqual(@as(i64, 100), completed.low);
    try std.testing.expectEqual(@as(i64, 150), completed.close);
    try std.testing.expectEqual(@as(i64, 3), completed.volume);
}

test "TickBarAggregator: no bar before N ticks" {
    var agg = TickBarAggregator.init(5);
    _ = agg.onTrade(100, 1, 0);
    const r = agg.onTrade(200, 1, 1);
    try std.testing.expect(r == null);
}

test "TickBarAggregator: resets after bar" {
    var agg = TickBarAggregator.init(2);
    _ = agg.onTrade(100, 1, 0);
    const bar1 = agg.onTrade(200, 1, 1);
    try std.testing.expect(bar1 != null);

    // Should start fresh bar
    _ = agg.onTrade(300, 1, 2);
    const bar2 = agg.onTrade(400, 1, 3);
    try std.testing.expect(bar2 != null);
    try std.testing.expectEqual(@as(i64, 300), bar2.?.open);
}
