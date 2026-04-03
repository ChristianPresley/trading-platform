const std = @import("std");
const translator_mod = @import("symbol_translator");

const SymbolTranslator = translator_mod.SymbolTranslator;

test "spot pair round-trip: BTC-USD <-> XXBTZUSD" {
    var t = try SymbolTranslator.init(std.testing.allocator);
    defer t.deinit();

    const kraken = try t.toSpotPair("BTC-USD");
    try std.testing.expectEqualStrings("XXBTZUSD", kraken);

    const internal = try t.fromSpotPair("XXBTZUSD");
    try std.testing.expectEqualStrings("BTC-USD", internal);
}

test "spot pair round-trip: ETH-USD <-> XETHZUSD" {
    var t = try SymbolTranslator.init(std.testing.allocator);
    defer t.deinit();

    const kraken = try t.toSpotPair("ETH-USD");
    try std.testing.expectEqualStrings("XETHZUSD", kraken);

    const internal = try t.fromSpotPair("XETHZUSD");
    try std.testing.expectEqualStrings("ETH-USD", internal);
}

test "spot pair round-trip: XRP-USD <-> XXRPZUSD" {
    var t = try SymbolTranslator.init(std.testing.allocator);
    defer t.deinit();

    const kraken = try t.toSpotPair("XRP-USD");
    try std.testing.expectEqualStrings("XXRPZUSD", kraken);

    const internal = try t.fromSpotPair("XXRPZUSD");
    try std.testing.expectEqualStrings("XRP-USD", internal);
}

test "futures symbol round-trip: BTC-USD-PERP <-> PI_XBTUSD" {
    var t = try SymbolTranslator.init(std.testing.allocator);
    defer t.deinit();

    const kraken = try t.toFuturesSymbol("BTC-USD-PERP");
    try std.testing.expectEqualStrings("PI_XBTUSD", kraken);

    const internal = try t.fromFuturesSymbol("PI_XBTUSD");
    try std.testing.expectEqualStrings("BTC-USD-PERP", internal);
}

test "futures symbol round-trip: ETH-USD-PERP <-> PI_ETHUSD" {
    var t = try SymbolTranslator.init(std.testing.allocator);
    defer t.deinit();

    const kraken = try t.toFuturesSymbol("ETH-USD-PERP");
    try std.testing.expectEqualStrings("PI_ETHUSD", kraken);

    const internal = try t.fromFuturesSymbol("PI_ETHUSD");
    try std.testing.expectEqualStrings("ETH-USD-PERP", internal);
}

test "unknown spot symbol returns error" {
    var t = try SymbolTranslator.init(std.testing.allocator);
    defer t.deinit();

    const result = t.toSpotPair("UNKNOWN-XYZ");
    try std.testing.expectError(error.UnknownSymbol, result);
}

test "unknown kraken spot pair returns error" {
    var t = try SymbolTranslator.init(std.testing.allocator);
    defer t.deinit();

    const result = t.fromSpotPair("NOTAPAIR");
    try std.testing.expectError(error.UnknownSymbol, result);
}

test "unknown futures symbol returns error" {
    var t = try SymbolTranslator.init(std.testing.allocator);
    defer t.deinit();

    const result = t.toFuturesSymbol("UNKNOWN-USD-PERP");
    try std.testing.expectError(error.UnknownSymbol, result);
}

test "unknown kraken futures symbol returns error" {
    var t = try SymbolTranslator.init(std.testing.allocator);
    defer t.deinit();

    const result = t.fromFuturesSymbol("FI_UNKNOWN");
    try std.testing.expectError(error.UnknownSymbol, result);
}

test "multiple spot pairs translate correctly" {
    var t = try SymbolTranslator.init(std.testing.allocator);
    defer t.deinit();

    try std.testing.expectEqualStrings("XXBTZEUR", try t.toSpotPair("BTC-EUR"));
    try std.testing.expectEqualStrings("XETHZEUR", try t.toSpotPair("ETH-EUR"));
    try std.testing.expectEqualStrings("XETHXXBT", try t.toSpotPair("ETH-BTC"));
    try std.testing.expectEqualStrings("SOLUSD",   try t.toSpotPair("SOL-USD"));
    try std.testing.expectEqualStrings("XLTCZUSD", try t.toSpotPair("LTC-USD"));
}

test "multiple futures symbols translate correctly" {
    var t = try SymbolTranslator.init(std.testing.allocator);
    defer t.deinit();

    try std.testing.expectEqualStrings("PI_ETHUSD",  try t.toFuturesSymbol("ETH-USD-PERP"));
    try std.testing.expectEqualStrings("PI_SOLUSD",  try t.toFuturesSymbol("SOL-USD-PERP"));
    try std.testing.expectEqualStrings("PI_XRPUSD",  try t.toFuturesSymbol("XRP-USD-PERP"));
    try std.testing.expectEqualStrings("PI_LINKUSD", try t.toFuturesSymbol("LINK-USD-PERP"));
}
