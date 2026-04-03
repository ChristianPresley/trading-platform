// Bidirectional symbol translation between OMS internal format and Kraken exchange formats.
// Spot: "BTC-USD" <-> "XXBTZUSD"
// Futures: "BTC-USD-PERP" <-> "PI_XBTUSD"

const std = @import("std");

/// A single spot pair mapping entry
const SpotPairEntry = struct {
    internal: []const u8, // e.g. "BTC-USD"
    kraken: []const u8,   // e.g. "XXBTZUSD"
};

/// A single futures symbol mapping entry
const FuturesSymEntry = struct {
    internal: []const u8, // e.g. "BTC-USD-PERP"
    kraken: []const u8,   // e.g. "PI_XBTUSD"
};

/// Compile-time spot pair lookup table
const SPOT_PAIRS = [_]SpotPairEntry{
    .{ .internal = "BTC-USD",  .kraken = "XXBTZUSD"  },
    .{ .internal = "BTC-EUR",  .kraken = "XXBTZEUR"  },
    .{ .internal = "ETH-USD",  .kraken = "XETHZUSD"  },
    .{ .internal = "ETH-EUR",  .kraken = "XETHZEUR"  },
    .{ .internal = "ETH-BTC",  .kraken = "XETHXXBT"  },
    .{ .internal = "SOL-USD",  .kraken = "SOLUSD"    },
    .{ .internal = "SOL-EUR",  .kraken = "SOLEUR"    },
    .{ .internal = "ADA-USD",  .kraken = "ADAUSD"    },
    .{ .internal = "ADA-EUR",  .kraken = "ADAEUR"    },
    .{ .internal = "DOT-USD",  .kraken = "DOTUSD"    },
    .{ .internal = "DOT-EUR",  .kraken = "DOTEUR"    },
    .{ .internal = "LINK-USD", .kraken = "LINKUSD"   },
    .{ .internal = "LINK-EUR", .kraken = "LINKEUR"   },
    .{ .internal = "LTC-USD",  .kraken = "XLTCZUSD"  },
    .{ .internal = "LTC-EUR",  .kraken = "XLTCZEUR"  },
    .{ .internal = "XRP-USD",  .kraken = "XXRPZUSD"  },
    .{ .internal = "XRP-EUR",  .kraken = "XXRPZEUR"  },
    .{ .internal = "USDC-USD", .kraken = "USDCUSD"   },
    .{ .internal = "USDT-USD", .kraken = "USDTZUSD"  },
    .{ .internal = "ATOM-USD", .kraken = "ATOMUSD"   },
    .{ .internal = "MATIC-USD", .kraken = "MATICUSD" },
};

/// Compile-time futures symbol lookup table
const FUTURES_SYMS = [_]FuturesSymEntry{
    .{ .internal = "BTC-USD-PERP",  .kraken = "PI_XBTUSD"  },
    .{ .internal = "ETH-USD-PERP",  .kraken = "PI_ETHUSD"  },
    .{ .internal = "SOL-USD-PERP",  .kraken = "PI_SOLUSD"  },
    .{ .internal = "ADA-USD-PERP",  .kraken = "PI_ADAUSD"  },
    .{ .internal = "DOT-USD-PERP",  .kraken = "PI_DOTUSD"  },
    .{ .internal = "LINK-USD-PERP", .kraken = "PI_LINKUSD" },
    .{ .internal = "LTC-USD-PERP",  .kraken = "PI_LTCUSD"  },
    .{ .internal = "XRP-USD-PERP",  .kraken = "PI_XRPUSD"  },
    .{ .internal = "BCH-USD-PERP",  .kraken = "PI_BCHUSD"  },
    .{ .internal = "ATOM-USD-PERP", .kraken = "PI_ATOMUSD" },
};

pub const SymbolTranslator = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !SymbolTranslator {
        return SymbolTranslator{ .allocator = allocator };
    }

    /// Translate internal symbol to Kraken spot pair name.
    /// "BTC-USD" -> "XXBTZUSD"
    pub fn toSpotPair(self: *SymbolTranslator, internal: []const u8) ![]const u8 {
        _ = self;
        for (&SPOT_PAIRS) |*entry| {
            if (std.mem.eql(u8, entry.internal, internal)) {
                return entry.kraken;
            }
        }
        return error.UnknownSymbol;
    }

    /// Translate Kraken spot pair name to internal symbol.
    /// "XXBTZUSD" -> "BTC-USD"
    pub fn fromSpotPair(self: *SymbolTranslator, kraken: []const u8) ![]const u8 {
        _ = self;
        for (&SPOT_PAIRS) |*entry| {
            if (std.mem.eql(u8, entry.kraken, kraken)) {
                return entry.internal;
            }
        }
        return error.UnknownSymbol;
    }

    /// Translate internal symbol to Kraken futures symbol.
    /// "BTC-USD-PERP" -> "PI_XBTUSD"
    pub fn toFuturesSymbol(self: *SymbolTranslator, internal: []const u8) ![]const u8 {
        _ = self;
        for (&FUTURES_SYMS) |*entry| {
            if (std.mem.eql(u8, entry.internal, internal)) {
                return entry.kraken;
            }
        }
        return error.UnknownSymbol;
    }

    /// Translate Kraken futures symbol to internal symbol.
    /// "PI_XBTUSD" -> "BTC-USD-PERP"
    pub fn fromFuturesSymbol(self: *SymbolTranslator, kraken: []const u8) ![]const u8 {
        _ = self;
        for (&FUTURES_SYMS) |*entry| {
            if (std.mem.eql(u8, entry.kraken, kraken)) {
                return entry.internal;
            }
        }
        return error.UnknownSymbol;
    }

    pub fn deinit(self: *SymbolTranslator) void {
        _ = self;
    }
};
