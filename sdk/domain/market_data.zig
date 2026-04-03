// Market data normalization — symbol mapping between Kraken and internal formats.
// Spot: "XBT/USD" ↔ "BTC-USD"
// Futures: "PI_XBTUSD" ↔ "BTC-USD-PERP"

const std = @import("std");

const SpotEntry = struct {
    kraken: []const u8,
    internal: []const u8,
};

const FuturesEntry = struct {
    kraken: []const u8,
    internal: []const u8,
};

/// Compile-time spot symbol mapping table.
const SPOT_MAP = [_]SpotEntry{
    .{ .kraken = "XBT/USD", .internal = "BTC-USD" },
    .{ .kraken = "XBT/EUR", .internal = "BTC-EUR" },
    .{ .kraken = "XBT/GBP", .internal = "BTC-GBP" },
    .{ .kraken = "XBT/JPY", .internal = "BTC-JPY" },
    .{ .kraken = "ETH/USD", .internal = "ETH-USD" },
    .{ .kraken = "ETH/EUR", .internal = "ETH-EUR" },
    .{ .kraken = "ETH/BTC", .internal = "ETH-BTC" },
    .{ .kraken = "SOL/USD", .internal = "SOL-USD" },
    .{ .kraken = "SOL/EUR", .internal = "SOL-EUR" },
    .{ .kraken = "SOL/BTC", .internal = "SOL-BTC" },
    .{ .kraken = "ADA/USD", .internal = "ADA-USD" },
    .{ .kraken = "DOT/USD", .internal = "DOT-USD" },
    .{ .kraken = "USDC/USD", .internal = "USDC-USD" },
    .{ .kraken = "USDT/USD", .internal = "USDT-USD" },
    .{ .kraken = "LINK/USD", .internal = "LINK-USD" },
    .{ .kraken = "MATIC/USD", .internal = "MATIC-USD" },
    .{ .kraken = "AVAX/USD", .internal = "AVAX-USD" },
    .{ .kraken = "ATOM/USD", .internal = "ATOM-USD" },
    .{ .kraken = "LTC/USD", .internal = "LTC-USD" },
    .{ .kraken = "XRP/USD", .internal = "XRP-USD" },
};

/// Compile-time futures symbol mapping table.
const FUTURES_MAP = [_]FuturesEntry{
    .{ .kraken = "PI_XBTUSD", .internal = "BTC-USD-PERP" },
    .{ .kraken = "PI_ETHUSD", .internal = "ETH-USD-PERP" },
    .{ .kraken = "PI_SOLUSD", .internal = "SOL-USD-PERP" },
    .{ .kraken = "PI_ADAUSD", .internal = "ADA-USD-PERP" },
    .{ .kraken = "PI_DOTUSD", .internal = "DOT-USD-PERP" },
    .{ .kraken = "PI_LINKUSD", .internal = "LINK-USD-PERP" },
    .{ .kraken = "PI_LTCUSD", .internal = "LTC-USD-PERP" },
    .{ .kraken = "PI_XRPUSD", .internal = "XRP-USD-PERP" },
    .{ .kraken = "PI_AVAXUSD", .internal = "AVAX-USD-PERP" },
    .{ .kraken = "PI_ATOMUSD", .internal = "ATOM-USD-PERP" },
    .{ .kraken = "FI_XBTUSD_231229", .internal = "BTC-USD-20231229" },
    .{ .kraken = "FI_ETHUSD_231229", .internal = "ETH-USD-20231229" },
};

/// Symbol mapper between Kraken exchange symbols and internal canonical symbols.
/// Uses static tables — no heap allocation for lookups.
pub const SymbolMapper = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !SymbolMapper {
        return SymbolMapper{ .allocator = allocator };
    }

    /// Maps Kraken spot pair (e.g. "XBT/USD") to internal symbol (e.g. "BTC-USD").
    /// Returns null if the pair is not in the mapping table.
    pub fn spotToInternal(_: *SymbolMapper, kraken_pair: []const u8) ?[]const u8 {
        for (&SPOT_MAP) |*entry| {
            if (std.mem.eql(u8, entry.kraken, kraken_pair)) {
                return entry.internal;
            }
        }
        return null;
    }

    /// Maps Kraken futures symbol (e.g. "PI_XBTUSD") to internal symbol (e.g. "BTC-USD-PERP").
    /// Returns null if the symbol is not in the mapping table.
    pub fn futurestoInternal(_: *SymbolMapper, kraken_symbol: []const u8) ?[]const u8 {
        for (&FUTURES_MAP) |*entry| {
            if (std.mem.eql(u8, entry.kraken, kraken_symbol)) {
                return entry.internal;
            }
        }
        return null;
    }

    /// Maps internal symbol (e.g. "BTC-USD") to Kraken spot pair (e.g. "XBT/USD").
    /// Returns null if not found.
    pub fn internalToSpot(_: *SymbolMapper, internal: []const u8) ?[]const u8 {
        for (&SPOT_MAP) |*entry| {
            if (std.mem.eql(u8, entry.internal, internal)) {
                return entry.kraken;
            }
        }
        return null;
    }

    /// Maps internal symbol (e.g. "BTC-USD-PERP") to Kraken futures symbol (e.g. "PI_XBTUSD").
    /// Returns null if not found.
    pub fn internalToFutures(_: *SymbolMapper, internal: []const u8) ?[]const u8 {
        for (&FUTURES_MAP) |*entry| {
            if (std.mem.eql(u8, entry.internal, internal)) {
                return entry.kraken;
            }
        }
        return null;
    }

    pub fn deinit(_: *SymbolMapper) void {
        // No heap allocation to release
    }
};
