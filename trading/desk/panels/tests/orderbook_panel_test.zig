// Tests for orderbook_panel.zig — orderbook panel rendering logic.
// Covers: price/quantity formatting, sparkline generation, depth bar scaling.

const std = @import("std");
const orderbook_panel = @import("orderbook_panel");

const msg = orderbook_panel.msg;
const OrderbookSnapshot = msg.OrderbookSnapshot;
const PriceLevel = msg.PriceLevel;
const InstrumentId = msg.InstrumentId;

// Re-export draw to confirm module links — we don't call it (needs Renderer).
comptime {
    _ = orderbook_panel.draw;
}

// -- Helpers --

fn makeSnapshot(bid_prices: []const i64, bid_qtys: []const i64, ask_prices: []const i64, ask_qtys: []const i64) OrderbookSnapshot {
    var snap = std.mem.zeroes(OrderbookSnapshot);
    snap.instrument = InstrumentId.fromSlice("BTC-USD");
    const nb = @min(bid_prices.len, 20);
    for (0..nb) |i| {
        snap.bids[i] = PriceLevel{ .price = bid_prices[i], .quantity = bid_qtys[i] };
    }
    snap.bid_count = @intCast(nb);
    const na = @min(ask_prices.len, 20);
    for (0..na) |i| {
        snap.asks[i] = PriceLevel{ .price = ask_prices[i], .quantity = ask_qtys[i] };
    }
    snap.ask_count = @intCast(na);
    return snap;
}

// ---- fmtPrice tests ----

test "fmtPrice: standard price" {
    var buf: [32]u8 = undefined;
    // 50000.00 in fixed-point = 50000 * 100_000_000 = 5_000_000_000_000
    const result = orderbook_panel.fmtPrice(&buf, 5_000_000_000_000);
    try std.testing.expectEqualStrings("50000.00", result);
}

test "fmtPrice: price with decimals" {
    var buf: [32]u8 = undefined;
    // 50123.45 in fixed-point = 50123 * 100_000_000 + 45_000_000
    const price: i64 = 50123 * 100_000_000 + 45_000_000;
    const result = orderbook_panel.fmtPrice(&buf, price);
    try std.testing.expectEqualStrings("50123.45", result);
}

test "fmtPrice: zero price" {
    var buf: [32]u8 = undefined;
    const result = orderbook_panel.fmtPrice(&buf, 0);
    try std.testing.expectEqualStrings("0.00", result);
}

test "fmtPrice: single-digit fractional" {
    var buf: [32]u8 = undefined;
    // 100.05 in fixed-point = 100 * 100_000_000 + 5_000_000
    const price: i64 = 100 * 100_000_000 + 5_000_000;
    const result = orderbook_panel.fmtPrice(&buf, price);
    try std.testing.expectEqualStrings("100.05", result);
}

test "fmtPrice: large price" {
    var buf: [32]u8 = undefined;
    // 99999.99 in fixed-point
    const price: i64 = 99999 * 100_000_000 + 99_000_000;
    const result = orderbook_panel.fmtPrice(&buf, price);
    try std.testing.expectEqualStrings("99999.99", result);
}

test "fmtPrice: sub-penny precision truncated to 2 decimals" {
    var buf: [32]u8 = undefined;
    // 100.123456 in fixed-point = 100 * 100_000_000 + 12_345_600
    // frac2 = 12_345_600 / 1_000_000 = 12
    const price: i64 = 100 * 100_000_000 + 12_345_600;
    const result = orderbook_panel.fmtPrice(&buf, price);
    try std.testing.expectEqualStrings("100.12", result);
}

test "fmtPrice: small price (1 cent)" {
    var buf: [32]u8 = undefined;
    // 0.01 in fixed-point = 1_000_000
    const result = orderbook_panel.fmtPrice(&buf, 1_000_000);
    try std.testing.expectEqualStrings("0.01", result);
}

// ---- fmtQty tests ----

test "fmtQty: standard quantity" {
    var buf: [24]u8 = undefined;
    // 100 units in fixed-point = 100 * 100_000_000
    const result = orderbook_panel.fmtQty(&buf, 100 * 100_000_000);
    try std.testing.expectEqualStrings("100", result);
}

test "fmtQty: zero quantity" {
    var buf: [24]u8 = undefined;
    const result = orderbook_panel.fmtQty(&buf, 0);
    try std.testing.expectEqualStrings("0", result);
}

test "fmtQty: fractional quantity truncated to whole" {
    var buf: [24]u8 = undefined;
    // 5.75 in fixed-point = 5 * 100_000_000 + 75_000_000 => displays "5"
    const qty: i64 = 5 * 100_000_000 + 75_000_000;
    const result = orderbook_panel.fmtQty(&buf, qty);
    try std.testing.expectEqualStrings("5", result);
}

test "fmtQty: large quantity" {
    var buf: [24]u8 = undefined;
    const result = orderbook_panel.fmtQty(&buf, 999999 * 100_000_000);
    try std.testing.expectEqualStrings("999999", result);
}

// ---- sparkline tests ----

test "sparkline: basic quantization levels" {
    // Feed [0, 25, 50, 75, 100] => levels [0, 1, 3, 5, 7]
    var buf: [64]u8 = undefined;
    const values = [_]i64{ 0, 25, 50, 75, 100 };
    const result = orderbook_panel.sparkline(&values, 5, &buf);
    // Should produce 5 * 3 = 15 bytes
    try std.testing.expectEqual(@as(usize, 15), result.len);
    // First char should be level 0: U+2581 => 0xe2, 0x96, 0x81
    try std.testing.expectEqual(@as(u8, 0xe2), result[0]);
    try std.testing.expectEqual(@as(u8, 0x96), result[1]);
    try std.testing.expectEqual(@as(u8, 0x81), result[2]);
    // Last char should be level 7: U+2588 => 0xe2, 0x96, 0x88
    try std.testing.expectEqual(@as(u8, 0xe2), result[12]);
    try std.testing.expectEqual(@as(u8, 0x96), result[13]);
    try std.testing.expectEqual(@as(u8, 0x88), result[14]);
}

test "sparkline: empty values returns empty" {
    var buf: [64]u8 = undefined;
    const values = [_]i64{};
    const result = orderbook_panel.sparkline(&values, 5, &buf);
    try std.testing.expectEqual(@as(usize, 0), result.len);
}

test "sparkline: zero width returns empty" {
    var buf: [64]u8 = undefined;
    const values = [_]i64{ 1, 2, 3 };
    const result = orderbook_panel.sparkline(&values, 0, &buf);
    try std.testing.expectEqual(@as(usize, 0), result.len);
}

test "sparkline: flat values (all same) produce middle level" {
    var buf: [64]u8 = undefined;
    const values = [_]i64{ 50, 50, 50 };
    const result = orderbook_panel.sparkline(&values, 3, &buf);
    try std.testing.expectEqual(@as(usize, 9), result.len);
    // When range=0, all values get level 3 (middle)
    // Level 3: U+2584 => 0xe2, 0x96, 0x84
    for (0..3) |i| {
        try std.testing.expectEqual(@as(u8, 0xe2), result[i * 3]);
        try std.testing.expectEqual(@as(u8, 0x96), result[i * 3 + 1]);
        try std.testing.expectEqual(@as(u8, 0x84), result[i * 3 + 2]);
    }
}

test "sparkline: width truncates to most recent values" {
    var buf: [64]u8 = undefined;
    // 10 values, width=3 => show last 3 values
    const values = [_]i64{ 0, 10, 20, 30, 40, 50, 60, 70, 80, 100 };
    const result = orderbook_panel.sparkline(&values, 3, &buf);
    try std.testing.expectEqual(@as(usize, 9), result.len);
    // Last value (100) should be level 7: U+2588 => third byte 0x88
    try std.testing.expectEqual(@as(u8, 0x88), result[8]);
}

test "sparkline: single value produces single character" {
    var buf: [64]u8 = undefined;
    const values = [_]i64{42};
    const result = orderbook_panel.sparkline(&values, 10, &buf);
    // Single value: range=0, so level=3
    try std.testing.expectEqual(@as(usize, 3), result.len);
}

test "sparkline: buffer too small truncates safely" {
    // Buffer for only 2 chars (6 bytes) but 5 values
    var buf: [6]u8 = undefined;
    const values = [_]i64{ 0, 25, 50, 75, 100 };
    const result = orderbook_panel.sparkline(&values, 5, &buf);
    try std.testing.expectEqual(@as(usize, 6), result.len);
}

test "sparkline: two values min/max" {
    var buf: [64]u8 = undefined;
    const values = [_]i64{ 0, 100 };
    const result = orderbook_panel.sparkline(&values, 2, &buf);
    try std.testing.expectEqual(@as(usize, 6), result.len);
    // First should be level 0 (0x81), last level 7 (0x88)
    try std.testing.expectEqual(@as(u8, 0x81), result[2]);
    try std.testing.expectEqual(@as(u8, 0x88), result[5]);
}

// ---- depthBar tests ----

test "depthBar: max quantity fills full width" {
    var buf: [64]u8 = undefined;
    const result = orderbook_panel.depthBar(100, 100, 4, &buf);
    try std.testing.expectEqual(@as(usize, 12), result.len); // 4 chars * 3 bytes
}

test "depthBar: half quantity fills half width" {
    var buf: [64]u8 = undefined;
    const result = orderbook_panel.depthBar(50, 100, 4, &buf);
    try std.testing.expectEqual(@as(usize, 6), result.len); // 2 chars * 3 bytes
}

test "depthBar: zero quantity returns empty" {
    var buf: [64]u8 = undefined;
    const result = orderbook_panel.depthBar(0, 100, 4, &buf);
    try std.testing.expectEqual(@as(usize, 0), result.len);
}

test "depthBar: zero max_quantity returns empty" {
    var buf: [64]u8 = undefined;
    const result = orderbook_panel.depthBar(50, 0, 4, &buf);
    try std.testing.expectEqual(@as(usize, 0), result.len);
}

test "depthBar: negative max_quantity returns empty" {
    var buf: [64]u8 = undefined;
    const result = orderbook_panel.depthBar(50, -10, 4, &buf);
    try std.testing.expectEqual(@as(usize, 0), result.len);
}

test "depthBar: zero width returns empty" {
    var buf: [64]u8 = undefined;
    const result = orderbook_panel.depthBar(100, 100, 0, &buf);
    try std.testing.expectEqual(@as(usize, 0), result.len);
}

test "depthBar: small fraction rounds down" {
    var buf: [64]u8 = undefined;
    // 1/100 * 4 = 0.04, rounds to 0
    const result = orderbook_panel.depthBar(1, 100, 4, &buf);
    try std.testing.expectEqual(@as(usize, 0), result.len);
}

test "depthBar: uses full block character" {
    var buf: [64]u8 = undefined;
    const result = orderbook_panel.depthBar(100, 100, 1, &buf);
    try std.testing.expectEqual(@as(usize, 3), result.len);
    // Full block: U+2588 => 0xe2, 0x96, 0x88
    try std.testing.expectEqual(@as(u8, 0xe2), result[0]);
    try std.testing.expectEqual(@as(u8, 0x96), result[1]);
    try std.testing.expectEqual(@as(u8, 0x88), result[2]);
}

test "depthBar: proportional scaling large values" {
    var buf: [256]u8 = undefined;
    const result = orderbook_panel.depthBar(75, 100, 8, &buf);
    // 75/100 * 8 = 6 filled columns => 6 * 3 = 18 bytes
    try std.testing.expectEqual(@as(usize, 18), result.len);
}

test "depthBar: quantity exceeding max clamps to width" {
    var buf: [64]u8 = undefined;
    const result = orderbook_panel.depthBar(200, 100, 4, &buf);
    // ratio = 200*4/100 = 8, clamped to width=4 => 4 * 3 = 12
    try std.testing.expectEqual(@as(usize, 12), result.len);
}

// ---- OrderbookSnapshot construction ----

test "OrderbookSnapshot: zeroes produces valid empty book" {
    const snap = std.mem.zeroes(OrderbookSnapshot);
    try std.testing.expectEqual(@as(u8, 0), snap.bid_count);
    try std.testing.expectEqual(@as(u8, 0), snap.ask_count);
}

test "OrderbookSnapshot: makeSnapshot helper" {
    const bid_p = [_]i64{ 5000_000_000_00, 4999_000_000_00 };
    const bid_q = [_]i64{ 100_000_000_00, 200_000_000_00 };
    const ask_p = [_]i64{ 5001_000_000_00, 5002_000_000_00 };
    const ask_q = [_]i64{ 50_000_000_00, 75_000_000_00 };
    const snap = makeSnapshot(&bid_p, &bid_q, &ask_p, &ask_q);

    try std.testing.expectEqual(@as(u8, 2), snap.bid_count);
    try std.testing.expectEqual(@as(u8, 2), snap.ask_count);
    try std.testing.expectEqualStrings("BTC-USD", snap.instrument.slice());
}

// ---- Spread calculation logic ----

test "spread: computed from best ask - best bid" {
    var buf: [32]u8 = undefined;
    const bid_p = [_]i64{5000 * 100_000_000};
    const bid_q = [_]i64{100 * 100_000_000};
    const ask_p = [_]i64{5001 * 100_000_000};
    const ask_q = [_]i64{50 * 100_000_000};
    const snap = makeSnapshot(&bid_p, &bid_q, &ask_p, &ask_q);

    const spread = snap.asks[0].price - snap.bids[0].price;
    try std.testing.expectEqual(@as(i64, 1 * 100_000_000), spread);

    // Format the spread
    const formatted = orderbook_panel.fmtPrice(&buf, spread);
    try std.testing.expectEqualStrings("1.00", formatted);
}

// ---- Max quantity scanning ----

test "max quantity scan: finds largest across bids and asks" {
    const bid_p = [_]i64{ 5000, 4999 };
    const bid_q = [_]i64{ 100, 300 };
    const ask_p = [_]i64{ 5001, 5002 };
    const ask_q = [_]i64{ 200, 50 };
    const snap = makeSnapshot(&bid_p, &bid_q, &ask_p, &ask_q);

    var max_qty: i64 = 1;
    for (0..snap.ask_count) |i| {
        if (snap.asks[i].quantity > max_qty) max_qty = snap.asks[i].quantity;
    }
    for (0..snap.bid_count) |i| {
        if (snap.bids[i].quantity > max_qty) max_qty = snap.bids[i].quantity;
    }

    try std.testing.expectEqual(@as(i64, 300), max_qty);
}

// ---- Depth bar column width calculation ----

test "depth bar width: inner_w > 28 yields positive bar_w" {
    const inner_w: u16 = 50;
    const price_qty_w: u16 = 26;
    const bar_w: u16 = if (inner_w > price_qty_w + 2) inner_w - price_qty_w - 2 else 0;
    try std.testing.expectEqual(@as(u16, 22), bar_w);
}

test "depth bar width: narrow panel yields 0" {
    const inner_w: u16 = 25;
    const price_qty_w: u16 = 26;
    const bar_w: u16 = if (inner_w > price_qty_w + 2) inner_w - price_qty_w - 2 else 0;
    try std.testing.expectEqual(@as(u16, 0), bar_w);
}

// ---- InstrumentId ----

test "InstrumentId: fromSlice and slice round-trip" {
    const id = InstrumentId.fromSlice("ETH-USD");
    try std.testing.expectEqualStrings("ETH-USD", id.slice());
}

test "InstrumentId: truncates at 32 chars" {
    const long = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    const id = InstrumentId.fromSlice(long);
    try std.testing.expectEqual(@as(u8, 32), id.len);
    try std.testing.expectEqualStrings(long[0..32], id.slice());
}

test "InstrumentId: empty slice" {
    const id = InstrumentId.fromSlice("");
    try std.testing.expectEqual(@as(u8, 0), id.len);
    try std.testing.expectEqualStrings("", id.slice());
}
