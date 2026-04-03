// Tests for SymbolMapper — spot/futures pair mapping

const std = @import("std");
const market_data = @import("market_data");

const SymbolMapper = market_data.SymbolMapper;

test "SymbolMapper: spot XBT/USD maps to BTC-USD" {
    var mapper = try SymbolMapper.init(std.testing.allocator);
    defer mapper.deinit();

    const result = mapper.spotToInternal("XBT/USD");
    try std.testing.expect(result != null);
    try std.testing.expectEqualStrings("BTC-USD", result.?);
}

test "SymbolMapper: spot ETH/USD maps to ETH-USD" {
    var mapper = try SymbolMapper.init(std.testing.allocator);
    defer mapper.deinit();

    const result = mapper.spotToInternal("ETH/USD");
    try std.testing.expect(result != null);
    try std.testing.expectEqualStrings("ETH-USD", result.?);
}

test "SymbolMapper: spot ETH/BTC maps to ETH-BTC" {
    var mapper = try SymbolMapper.init(std.testing.allocator);
    defer mapper.deinit();

    const result = mapper.spotToInternal("ETH/BTC");
    try std.testing.expect(result != null);
    try std.testing.expectEqualStrings("ETH-BTC", result.?);
}

test "SymbolMapper: unknown spot pair returns null" {
    var mapper = try SymbolMapper.init(std.testing.allocator);
    defer mapper.deinit();

    const result = mapper.spotToInternal("UNKNOWN/PAIR");
    try std.testing.expect(result == null);
}

test "SymbolMapper: futures PI_XBTUSD maps to BTC-USD-PERP" {
    var mapper = try SymbolMapper.init(std.testing.allocator);
    defer mapper.deinit();

    const result = mapper.futurestoInternal("PI_XBTUSD");
    try std.testing.expect(result != null);
    try std.testing.expectEqualStrings("BTC-USD-PERP", result.?);
}

test "SymbolMapper: futures PI_ETHUSD maps to ETH-USD-PERP" {
    var mapper = try SymbolMapper.init(std.testing.allocator);
    defer mapper.deinit();

    const result = mapper.futurestoInternal("PI_ETHUSD");
    try std.testing.expect(result != null);
    try std.testing.expectEqualStrings("ETH-USD-PERP", result.?);
}

test "SymbolMapper: unknown futures symbol returns null" {
    var mapper = try SymbolMapper.init(std.testing.allocator);
    defer mapper.deinit();

    const result = mapper.futurestoInternal("UNKNOWN_PERP");
    try std.testing.expect(result == null);
}

test "SymbolMapper: round-trip spot BTC-USD → XBT/USD" {
    var mapper = try SymbolMapper.init(std.testing.allocator);
    defer mapper.deinit();

    const kraken = mapper.internalToSpot("BTC-USD") orelse unreachable;
    try std.testing.expectEqualStrings("XBT/USD", kraken);

    // Verify round-trip
    const internal = mapper.spotToInternal(kraken) orelse unreachable;
    try std.testing.expectEqualStrings("BTC-USD", internal);
}

test "SymbolMapper: round-trip futures BTC-USD-PERP → PI_XBTUSD" {
    var mapper = try SymbolMapper.init(std.testing.allocator);
    defer mapper.deinit();

    const kraken = mapper.internalToFutures("BTC-USD-PERP") orelse unreachable;
    try std.testing.expectEqualStrings("PI_XBTUSD", kraken);

    // Verify round-trip
    const internal = mapper.futurestoInternal(kraken) orelse unreachable;
    try std.testing.expectEqualStrings("BTC-USD-PERP", internal);
}

test "SymbolMapper: internalToSpot unknown returns null" {
    var mapper = try SymbolMapper.init(std.testing.allocator);
    defer mapper.deinit();

    const result = mapper.internalToSpot("UNKNOWN");
    try std.testing.expect(result == null);
}

test "SymbolMapper: internalToFutures unknown returns null" {
    var mapper = try SymbolMapper.init(std.testing.allocator);
    defer mapper.deinit();

    const result = mapper.internalToFutures("UNKNOWN-PERP");
    try std.testing.expect(result == null);
}

test "SymbolMapper: multiple spot pairs map correctly" {
    var mapper = try SymbolMapper.init(std.testing.allocator);
    defer mapper.deinit();

    const pairs = [_]struct { kraken: []const u8, internal: []const u8 }{
        .{ .kraken = "XBT/USD", .internal = "BTC-USD" },
        .{ .kraken = "ETH/USD", .internal = "ETH-USD" },
        .{ .kraken = "SOL/USD", .internal = "SOL-USD" },
        .{ .kraken = "LTC/USD", .internal = "LTC-USD" },
        .{ .kraken = "XRP/USD", .internal = "XRP-USD" },
    };

    for (pairs) |p| {
        const result = mapper.spotToInternal(p.kraken) orelse {
            std.debug.print("Missing mapping for {s}\n", .{p.kraken});
            return error.MissingMapping;
        };
        try std.testing.expectEqualStrings(p.internal, result);
    }
}

test "SymbolMapper: multiple futures symbols map correctly" {
    var mapper = try SymbolMapper.init(std.testing.allocator);
    defer mapper.deinit();

    const syms = [_]struct { kraken: []const u8, internal: []const u8 }{
        .{ .kraken = "PI_XBTUSD", .internal = "BTC-USD-PERP" },
        .{ .kraken = "PI_ETHUSD", .internal = "ETH-USD-PERP" },
        .{ .kraken = "PI_SOLUSD", .internal = "SOL-USD-PERP" },
    };

    for (syms) |s| {
        const result = mapper.futurestoInternal(s.kraken) orelse {
            std.debug.print("Missing mapping for {s}\n", .{s.kraken});
            return error.MissingMapping;
        };
        try std.testing.expectEqualStrings(s.internal, result);
    }
}
