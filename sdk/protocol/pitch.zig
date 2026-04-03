// Cboe PITCH 2.x Protocol Parser
// Binary fixed-layout message parsing with type dispatch.
// Used for multicast UDP market data feeds.

const std = @import("std");

pub const PitchError = error{
    BufferTooShort,
    UnknownMessageType,
    LengthMismatch,
};

// PITCH message types
// Add Order (Long): 0x21
// Add Order (Short): 0x22
// Order Execute: 0x23
// Order Execute at Price: 0x24
// Reduce Size (Long): 0x25
// Reduce Size (Short): 0x26
// Order Cancel: 0x27 (alias for full cancel)
// Trade (Long): 0x2A
// Trade (Short): 0x2B
// Trade Break: 0x2C
// End of Session: 0x2D

// Prices: long format in 1/10000 per share (u64), short in 1/100 per share (u16 × 100)
// Shares: long = u32, short = u16

pub const AddOrderLong = struct {
    timestamp: u32,         // Nanoseconds since midnight
    order_id: u64,
    side: u8,               // 'B' or 'S'
    shares: u32,
    symbol: [6]u8,
    price: u64,             // 1/10000 per share
    display: u8,            // 'Y' displayed, 'N' hidden
};

pub const AddOrderShort = struct {
    timestamp: u32,
    order_id: u64,
    side: u8,
    shares: u16,
    symbol: [6]u8,
    price: u16,             // 1/100 per share
    display: u8,
};

pub const Execute = struct {
    timestamp: u32,
    order_id: u64,
    executed_shares: u32,
    execution_id: u64,
};

pub const ExecuteAtPrice = struct {
    timestamp: u32,
    order_id: u64,
    executed_shares: u32,
    remaining_shares: u32,
    execution_id: u64,
    price: u64,
};

pub const Cancel = struct {
    timestamp: u32,
    order_id: u64,
    canceled_shares: u32,
};

pub const TradeLong = struct {
    timestamp: u32,
    order_id: u64,
    side: u8,
    shares: u32,
    symbol: [6]u8,
    price: u64,
    execution_id: u64,
};

pub const TradeShort = struct {
    timestamp: u32,
    order_id: u64,
    side: u8,
    shares: u16,
    symbol: [6]u8,
    price: u16,
    execution_id: u64,
};

pub const PitchMessage = union(enum) {
    add_order_long: AddOrderLong,
    add_order_short: AddOrderShort,
    execute: Execute,
    execute_at_price: ExecuteAtPrice,
    cancel: Cancel,
    trade_long: TradeLong,
    trade_short: TradeShort,
};

fn readU16Be(data: []const u8, offset: usize) u16 {
    return std.mem.readInt(u16, data[offset..][0..2], .big);
}

fn readU32Be(data: []const u8, offset: usize) u32 {
    return std.mem.readInt(u32, data[offset..][0..4], .big);
}

fn readU64Be(data: []const u8, offset: usize) u64 {
    return std.mem.readInt(u64, data[offset..][0..8], .big);
}

fn readBytes6(data: []const u8, offset: usize) [6]u8 {
    var result: [6]u8 = undefined;
    @memcpy(&result, data[offset..][0..6]);
    return result;
}

pub const PitchParser = struct {
    pub fn init() PitchParser {
        return PitchParser{};
    }

    // PITCH 2.x message format (each message in data starts from index 0):
    // [0]     message_type (u8)
    // [1..N]  payload (varies by type)
    //
    // Add Order Long (0x21): total 34 bytes
    //   [0] type, [1..4] timestamp, [5..12] order_id, [13] side, [14..17] shares,
    //   [18..23] symbol(6), [24..31] price(u64), [32] display, [33] reserved
    //
    // Add Order Short (0x22): total 27 bytes
    //   [0] type, [1..4] timestamp, [5..12] order_id, [13] side, [14..15] shares(u16),
    //   [16..21] symbol(6), [22..23] price(u16), [24] display, [25..26] reserved
    //
    // Order Execute (0x23): total 25 bytes
    //   [0] type, [1..4] timestamp, [5..12] order_id, [13..16] executed_shares,
    //   [17..24] execution_id
    //
    // Order Execute at Price (0x24): total 37 bytes
    //   [0] type, [1..4] ts, [5..12] order_id, [13..16] executed_shares,
    //   [17..20] remaining_shares, [21..28] execution_id, [29..36] price
    //
    // Order Cancel (0x27): total 17 bytes
    //   [0] type, [1..4] ts, [5..12] order_id, [13..16] canceled_shares
    //
    // Trade (Long) (0x2A): total 41 bytes
    //   [0] type, [1..4] ts, [5..12] order_id, [13] side, [14..17] shares,
    //   [18..23] symbol(6), [24..31] price(u64), [32..39] execution_id, [40] reserved
    //
    // Trade (Short) (0x2B): total 34 bytes
    //   [0] type, [1..4] ts, [5..12] order_id, [13] side, [14..15] shares(u16),
    //   [16..21] symbol(6), [22..23] price(u16), [24..31] execution_id, [32..33] reserved

    pub fn parse(self: *PitchParser, data: []const u8) PitchError!PitchMessage {
        _ = self;
        if (data.len < 1) return PitchError.BufferTooShort;

        const msg_type = data[0];
        return switch (msg_type) {
            0x21 => blk: {
                if (data.len < 34) return PitchError.BufferTooShort;
                break :blk PitchMessage{ .add_order_long = .{
                    .timestamp = readU32Be(data, 1),
                    .order_id = readU64Be(data, 5),
                    .side = data[13],
                    .shares = readU32Be(data, 14),
                    .symbol = readBytes6(data, 18),
                    .price = readU64Be(data, 24),
                    .display = data[32],
                } };
            },
            0x22 => blk: {
                if (data.len < 26) return PitchError.BufferTooShort;
                break :blk PitchMessage{ .add_order_short = .{
                    .timestamp = readU32Be(data, 1),
                    .order_id = readU64Be(data, 5),
                    .side = data[13],
                    .shares = readU16Be(data, 14),
                    .symbol = readBytes6(data, 16),
                    .price = readU16Be(data, 22),
                    .display = data[24],
                } };
            },
            0x23 => blk: {
                if (data.len < 25) return PitchError.BufferTooShort;
                break :blk PitchMessage{ .execute = .{
                    .timestamp = readU32Be(data, 1),
                    .order_id = readU64Be(data, 5),
                    .executed_shares = readU32Be(data, 13),
                    .execution_id = readU64Be(data, 17),
                } };
            },
            0x24 => blk: {
                if (data.len < 37) return PitchError.BufferTooShort;
                break :blk PitchMessage{ .execute_at_price = .{
                    .timestamp = readU32Be(data, 1),
                    .order_id = readU64Be(data, 5),
                    .executed_shares = readU32Be(data, 13),
                    .remaining_shares = readU32Be(data, 17),
                    .execution_id = readU64Be(data, 21),
                    .price = readU64Be(data, 29),
                } };
            },
            0x27 => blk: {
                if (data.len < 17) return PitchError.BufferTooShort;
                break :blk PitchMessage{ .cancel = .{
                    .timestamp = readU32Be(data, 1),
                    .order_id = readU64Be(data, 5),
                    .canceled_shares = readU32Be(data, 13),
                } };
            },
            0x2A => blk: {
                if (data.len < 40) return PitchError.BufferTooShort;
                break :blk PitchMessage{ .trade_long = .{
                    .timestamp = readU32Be(data, 1),
                    .order_id = readU64Be(data, 5),
                    .side = data[13],
                    .shares = readU32Be(data, 14),
                    .symbol = readBytes6(data, 18),
                    .price = readU64Be(data, 24),
                    .execution_id = readU64Be(data, 32),
                } };
            },
            0x2B => blk: {
                if (data.len < 32) return PitchError.BufferTooShort;
                break :blk PitchMessage{ .trade_short = .{
                    .timestamp = readU32Be(data, 1),
                    .order_id = readU64Be(data, 5),
                    .side = data[13],
                    .shares = readU16Be(data, 14),
                    .symbol = readBytes6(data, 16),
                    .price = readU16Be(data, 22),
                    .execution_id = readU64Be(data, 24),
                } };
            },
            else => PitchError.UnknownMessageType,
        };
    }
};
