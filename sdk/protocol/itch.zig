// NASDAQ TotalView ITCH 5.0 Protocol Parser
// Binary fixed-layout message parsing with type dispatch.

const std = @import("std");

pub const ItchError = error{
    BufferTooShort,
    UnknownMessageType,
};

// All timestamps in nanoseconds since midnight (48-bit)
pub const SystemEvent = struct {
    timestamp: u48,
    event_code: u8,
};

pub const AddOrder = struct {
    timestamp: u48,
    order_ref: u64,
    side: u8,
    shares: u32,
    stock: [8]u8,
    price: u32,
};

pub const AddOrderMpid = struct {
    timestamp: u48,
    order_ref: u64,
    side: u8,
    shares: u32,
    stock: [8]u8,
    price: u32,
    attribution: [4]u8,
};

pub const Execute = struct {
    timestamp: u48,
    order_ref: u64,
    executed_shares: u32,
    match_number: u64,
};

pub const ExecutePrice = struct {
    timestamp: u48,
    order_ref: u64,
    executed_shares: u32,
    match_number: u64,
    printable: u8,
    execution_price: u32,
};

pub const Cancel = struct {
    timestamp: u48,
    order_ref: u64,
    canceled_shares: u32,
};

pub const Delete = struct {
    timestamp: u48,
    order_ref: u64,
};

pub const Replace = struct {
    timestamp: u48,
    original_order_ref: u64,
    new_order_ref: u64,
    shares: u32,
    price: u32,
};

pub const Trade = struct {
    timestamp: u48,
    order_ref: u64,
    side: u8,
    shares: u32,
    stock: [8]u8,
    price: u32,
    match_number: u64,
};

pub const CrossTrade = struct {
    timestamp: u48,
    shares: u64,
    stock: [8]u8,
    cross_price: u32,
    match_number: u64,
    cross_type: u8,
};

pub const BrokenTrade = struct {
    timestamp: u48,
    match_number: u64,
};

pub const Noii = struct {
    timestamp: u48,
    paired_shares: u64,
    imbalance_shares: u64,
    imbalance_direction: u8,
    stock: [8]u8,
    far_price: u32,
    near_price: u32,
    current_ref_price: u32,
    cross_type: u8,
    price_variation_indicator: u8,
};

pub const ItchMessage = union(enum) {
    system_event: SystemEvent,
    add_order: AddOrder,
    add_order_mpid: AddOrderMpid,
    execute: Execute,
    execute_price: ExecutePrice,
    cancel: Cancel,
    delete: Delete,
    replace: Replace,
    trade: Trade,
    cross_trade: CrossTrade,
    broken_trade: BrokenTrade,
    noii: Noii,
};

// Read a big-endian u48 from 6 bytes
fn readU48Be(data: []const u8, offset: usize) u48 {
    const b0: u48 = data[offset];
    const b1: u48 = data[offset + 1];
    const b2: u48 = data[offset + 2];
    const b3: u48 = data[offset + 3];
    const b4: u48 = data[offset + 4];
    const b5: u48 = data[offset + 5];
    return (b0 << 40) | (b1 << 32) | (b2 << 24) | (b3 << 16) | (b4 << 8) | b5;
}

fn readU32Be(data: []const u8, offset: usize) u32 {
    return std.mem.readInt(u32, data[offset..][0..4], .big);
}

fn readU64Be(data: []const u8, offset: usize) u64 {
    return std.mem.readInt(u64, data[offset..][0..8], .big);
}

fn readBytes8(data: []const u8, offset: usize) [8]u8 {
    var result: [8]u8 = undefined;
    @memcpy(&result, data[offset..][0..8]);
    return result;
}

fn readBytes4(data: []const u8, offset: usize) [4]u8 {
    var result: [4]u8 = undefined;
    @memcpy(&result, data[offset..][0..4]);
    return result;
}

pub const ItchParser = struct {
    pub fn init() ItchParser {
        return ItchParser{};
    }

    // ITCH 5.0 messages begin with 1 byte message type, then payload bytes.
    // Byte offsets described below are from the start of data (index 0 = type byte).
    //
    // System Event (S): total 12 bytes
    //   [0] type='S', [1..2] stock_locate, [3..4] tracking_number, [5..10] timestamp(u48), [11] event_code
    //
    // Add Order (A): total 36 bytes
    //   [0]='A', [1..2] stock_locate, [3..4] tracking, [5..10] ts, [11..18] order_ref(u64),
    //   [19] side, [20..23] shares(u32), [24..31] stock([8]u8), [32..35] price(u32)
    //
    // Add Order with MPID (F): total 40 bytes  (same as A + 4 bytes attribution)
    //
    // Order Executed (E): total 31 bytes
    //   [0]='E', [1..2] sl, [3..4] tn, [5..10] ts, [11..18] order_ref, [19..22] executed_shares, [23..30] match_number
    //
    // Order Executed with Price (C): total 36 bytes
    //   extends E with [31] printable, [32..35] execution_price
    //
    // Order Cancel (X): total 23 bytes
    //   [0]='X', [1..2] sl, [3..4] tn, [5..10] ts, [11..18] order_ref, [19..22] canceled_shares
    //
    // Order Delete (D): total 19 bytes
    //   [0]='D', [1..2] sl, [3..4] tn, [5..10] ts, [11..18] order_ref
    //
    // Order Replace (U): total 35 bytes
    //   [0]='U', [1..2] sl, [3..4] tn, [5..10] ts, [11..18] orig_order_ref, [19..26] new_order_ref,
    //   [27..30] shares, [31..34] price
    //
    // Trade Message (P): total 44 bytes
    //   [0]='P', [1..2] sl, [3..4] tn, [5..10] ts, [11..18] order_ref, [19] side,
    //   [20..23] shares, [24..31] stock, [32..35] price, [36..43] match_number
    //
    // Cross Trade (Q): total 40 bytes
    //   [0]='Q', [1..2] sl, [3..4] tn, [5..10] ts, [11..18] shares(u64), [19..26] stock,
    //   [27..30] cross_price, [31..38] match_number, [39] cross_type
    //
    // Broken Trade (B): total 19 bytes
    //   [0]='B', [1..2] sl, [3..4] tn, [5..10] ts, [11..18] match_number
    //
    // NOII (I): total 50 bytes
    //   [0]='I', [1..2] sl, [3..4] tn, [5..10] ts, [11..18] paired_shares(u64),
    //   [19..26] imbalance_shares(u64), [27] imbalance_direction, [28..35] stock,
    //   [36..39] far_price, [40..43] near_price, [44..47] current_ref_price,
    //   [48] cross_type, [49] price_variation_indicator

    pub fn parse(self: *ItchParser, data: []const u8) ItchError!ItchMessage {
        _ = self;
        if (data.len < 1) return ItchError.BufferTooShort;

        const msg_type = data[0];
        return switch (msg_type) {
            'S' => blk: {
                if (data.len < 12) return ItchError.BufferTooShort;
                break :blk ItchMessage{ .system_event = .{
                    .timestamp = readU48Be(data, 5),
                    .event_code = data[11],
                } };
            },
            'A' => blk: {
                if (data.len < 36) return ItchError.BufferTooShort;
                break :blk ItchMessage{ .add_order = .{
                    .timestamp = readU48Be(data, 5),
                    .order_ref = readU64Be(data, 11),
                    .side = data[19],
                    .shares = readU32Be(data, 20),
                    .stock = readBytes8(data, 24),
                    .price = readU32Be(data, 32),
                } };
            },
            'F' => blk: {
                if (data.len < 40) return ItchError.BufferTooShort;
                break :blk ItchMessage{ .add_order_mpid = .{
                    .timestamp = readU48Be(data, 5),
                    .order_ref = readU64Be(data, 11),
                    .side = data[19],
                    .shares = readU32Be(data, 20),
                    .stock = readBytes8(data, 24),
                    .price = readU32Be(data, 32),
                    .attribution = readBytes4(data, 36),
                } };
            },
            'E' => blk: {
                if (data.len < 31) return ItchError.BufferTooShort;
                break :blk ItchMessage{ .execute = .{
                    .timestamp = readU48Be(data, 5),
                    .order_ref = readU64Be(data, 11),
                    .executed_shares = readU32Be(data, 19),
                    .match_number = readU64Be(data, 23),
                } };
            },
            'C' => blk: {
                if (data.len < 36) return ItchError.BufferTooShort;
                break :blk ItchMessage{ .execute_price = .{
                    .timestamp = readU48Be(data, 5),
                    .order_ref = readU64Be(data, 11),
                    .executed_shares = readU32Be(data, 19),
                    .match_number = readU64Be(data, 23),
                    .printable = data[31],
                    .execution_price = readU32Be(data, 32),
                } };
            },
            'X' => blk: {
                if (data.len < 23) return ItchError.BufferTooShort;
                break :blk ItchMessage{ .cancel = .{
                    .timestamp = readU48Be(data, 5),
                    .order_ref = readU64Be(data, 11),
                    .canceled_shares = readU32Be(data, 19),
                } };
            },
            'D' => blk: {
                if (data.len < 19) return ItchError.BufferTooShort;
                break :blk ItchMessage{ .delete = .{
                    .timestamp = readU48Be(data, 5),
                    .order_ref = readU64Be(data, 11),
                } };
            },
            'U' => blk: {
                if (data.len < 35) return ItchError.BufferTooShort;
                break :blk ItchMessage{ .replace = .{
                    .timestamp = readU48Be(data, 5),
                    .original_order_ref = readU64Be(data, 11),
                    .new_order_ref = readU64Be(data, 19),
                    .shares = readU32Be(data, 27),
                    .price = readU32Be(data, 31),
                } };
            },
            'P' => blk: {
                if (data.len < 44) return ItchError.BufferTooShort;
                break :blk ItchMessage{ .trade = .{
                    .timestamp = readU48Be(data, 5),
                    .order_ref = readU64Be(data, 11),
                    .side = data[19],
                    .shares = readU32Be(data, 20),
                    .stock = readBytes8(data, 24),
                    .price = readU32Be(data, 32),
                    .match_number = readU64Be(data, 36),
                } };
            },
            'Q' => blk: {
                if (data.len < 40) return ItchError.BufferTooShort;
                break :blk ItchMessage{ .cross_trade = .{
                    .timestamp = readU48Be(data, 5),
                    .shares = readU64Be(data, 11),
                    .stock = readBytes8(data, 19),
                    .cross_price = readU32Be(data, 27),
                    .match_number = readU64Be(data, 31),
                    .cross_type = data[39],
                } };
            },
            'B' => blk: {
                if (data.len < 19) return ItchError.BufferTooShort;
                break :blk ItchMessage{ .broken_trade = .{
                    .timestamp = readU48Be(data, 5),
                    .match_number = readU64Be(data, 11),
                } };
            },
            'I' => blk: {
                if (data.len < 50) return ItchError.BufferTooShort;
                break :blk ItchMessage{ .noii = .{
                    .timestamp = readU48Be(data, 5),
                    .paired_shares = readU64Be(data, 11),
                    .imbalance_shares = readU64Be(data, 19),
                    .imbalance_direction = data[27],
                    .stock = readBytes8(data, 28),
                    .far_price = readU32Be(data, 36),
                    .near_price = readU32Be(data, 40),
                    .current_ref_price = readU32Be(data, 44),
                    .cross_type = data[48],
                    .price_variation_indicator = data[49],
                } };
            },
            else => ItchError.UnknownMessageType,
        };
    }
};
