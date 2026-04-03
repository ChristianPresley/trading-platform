// OUCH 4.2 Protocol — Order Entry Protocol
// Encoder for client→server messages and decoder for server→client responses.
// Fixed binary layouts, big-endian multi-byte fields.

const std = @import("std");

pub const OuchError = error{
    BufferTooShort,
    UnknownMessageType,
    InvalidTokenLength,
};

// ---- Client → Server message types ----
// Enter Order: type 'O' (0x4F)
// Replace Order: type 'U' (0x55)
// Cancel Order: type 'X' (0x58)

// ---- Server → Client message types ----
// System Event: type 'S' (0x53)
// Accepted: type 'A' (0x41)
// Replaced: type 'U' (0x55)
// Canceled: type 'C' (0x43)
// Executed: type 'E' (0x45)
// Rejected: type 'J' (0x4A)

pub const EnterOrder = struct {
    token: [14]u8,      // Order token (right-padded with spaces)
    side: u8,           // 'B' buy, 'S' sell, 'T' short sell, 'E' short sell exempt
    shares: u32,
    symbol: [8]u8,      // Right-padded with spaces
    price: u32,         // Price in 1/10000 per share
    tif: u32,           // Time in Force: 99998=IOC, 99999=GTD, others=seconds
    firm: [4]u8,        // Firm ID
};

// Enter Order binary layout (big-endian, 49 bytes total):
// [0]    type = 'O'
// [1..14] token (14 bytes)
// [15]   side (1 byte)
// [16..19] shares (u32 BE)
// [20..27] symbol (8 bytes)
// [28..31] price (u32 BE)
// [32..35] tif (u32 BE)
// [36..39] firm (4 bytes)
// Total = 40 bytes (after type byte: 39)
pub const ENTER_ORDER_SIZE: usize = 40;

pub const ReplaceOrder = struct {
    existing_token: [14]u8,
    replacement_token: [14]u8,
    shares: u32,
    price: u32,
    tif: u32,
};

// Replace Order layout (47 bytes):
// [0]    type = 'U'
// [1..14] existing_token (14 bytes)
// [15..28] replacement_token (14 bytes)
// [29..32] shares (u32 BE)
// [33..36] price (u32 BE)
// [37..40] tif (u32 BE)
// Total = 41 bytes
pub const REPLACE_ORDER_SIZE: usize = 41;

// Cancel Order layout:
// [0]    type = 'X'
// [1..14] token (14 bytes)
// Total = 15 bytes
pub const CANCEL_ORDER_SIZE: usize = 15;

// ---- Server response types ----

pub const Accepted = struct {
    token: [14]u8,
    side: u8,
    shares: u32,
    symbol: [8]u8,
    price: u32,
    tif: u32,
    firm: [4]u8,
    order_reference_number: u64,
};

pub const Replaced = struct {
    replacement_token: [14]u8,
    side: u8,
    shares: u32,
    symbol: [8]u8,
    price: u32,
    tif: u32,
    firm: [4]u8,
    order_reference_number: u64,
    previous_order_token: [14]u8,
};

pub const Canceled = struct {
    token: [14]u8,
    shares: u32,
    reason: u8,
};

pub const Executed = struct {
    token: [14]u8,
    executed_shares: u32,
    execution_price: u32,
    liquidity_flag: u8,
    match_number: u64,
};

pub const Rejected = struct {
    token: [14]u8,
    reason: u8,
};

pub const OuchMessage = union(enum) {
    accepted: Accepted,
    replaced: Replaced,
    canceled: Canceled,
    executed: Executed,
    rejected: Rejected,
};

fn writeU32Be(buf: []u8, offset: usize, value: u32) void {
    std.mem.writeInt(u32, buf[offset..][0..4], value, .big);
}

fn writeU64Be(buf: []u8, offset: usize, value: u64) void {
    std.mem.writeInt(u64, buf[offset..][0..8], value, .big);
}

fn readU32Be(data: []const u8, offset: usize) u32 {
    return std.mem.readInt(u32, data[offset..][0..4], .big);
}

fn readU64Be(data: []const u8, offset: usize) u64 {
    return std.mem.readInt(u64, data[offset..][0..8], .big);
}

fn readBytes14(data: []const u8, offset: usize) [14]u8 {
    var result: [14]u8 = undefined;
    @memcpy(&result, data[offset..][0..14]);
    return result;
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

pub const OuchEncoder = struct {
    pub fn encodeEnterOrder(order: EnterOrder, buf: []u8) OuchError![]const u8 {
        if (buf.len < ENTER_ORDER_SIZE) return OuchError.BufferTooShort;
        buf[0] = 'O';
        @memcpy(buf[1..15], &order.token);
        buf[15] = order.side;
        writeU32Be(buf, 16, order.shares);
        @memcpy(buf[20..28], &order.symbol);
        writeU32Be(buf, 28, order.price);
        writeU32Be(buf, 32, order.tif);
        @memcpy(buf[36..40], &order.firm);
        return buf[0..ENTER_ORDER_SIZE];
    }

    pub fn encodeReplaceOrder(replace: ReplaceOrder, buf: []u8) OuchError![]const u8 {
        if (buf.len < REPLACE_ORDER_SIZE) return OuchError.BufferTooShort;
        buf[0] = 'U';
        @memcpy(buf[1..15], &replace.existing_token);
        @memcpy(buf[15..29], &replace.replacement_token);
        writeU32Be(buf, 29, replace.shares);
        writeU32Be(buf, 33, replace.price);
        writeU32Be(buf, 37, replace.tif);
        return buf[0..REPLACE_ORDER_SIZE];
    }

    pub fn encodeCancelOrder(token: [14]u8, buf: []u8) OuchError![]const u8 {
        if (buf.len < CANCEL_ORDER_SIZE) return OuchError.BufferTooShort;
        buf[0] = 'X';
        @memcpy(buf[1..15], &token);
        return buf[0..CANCEL_ORDER_SIZE];
    }
};

pub const OuchDecoder = struct {
    // Decode a server→client OUCH response message.
    // Message layouts:
    // Accepted (A): [0]='A', [1..14] token, [15] side, [16..19] shares, [20..27] symbol,
    //               [28..31] price, [32..35] tif, [36..39] firm, [40..47] order_ref
    //               Total = 48 bytes
    //
    // Replaced (U): [0]='U', [1..14] replacement_token, [15] side, [16..19] shares,
    //               [20..27] symbol, [28..31] price, [32..35] tif, [36..39] firm,
    //               [40..47] order_ref, [48..61] previous_token
    //               Total = 62 bytes
    //
    // Canceled (C): [0]='C', [1..14] token, [15..18] shares, [19] reason
    //               Total = 20 bytes
    //
    // Executed (E): [0]='E', [1..14] token, [15..18] executed_shares, [19..22] execution_price,
    //               [23] liquidity_flag, [24..31] match_number
    //               Total = 32 bytes
    //
    // Rejected (J): [0]='J', [1..14] token, [15] reason
    //               Total = 16 bytes

    pub fn decode(data: []const u8) OuchError!OuchMessage {
        if (data.len < 1) return OuchError.BufferTooShort;

        return switch (data[0]) {
            'A' => blk: {
                if (data.len < 48) return OuchError.BufferTooShort;
                break :blk OuchMessage{ .accepted = .{
                    .token = readBytes14(data, 1),
                    .side = data[15],
                    .shares = readU32Be(data, 16),
                    .symbol = readBytes8(data, 20),
                    .price = readU32Be(data, 28),
                    .tif = readU32Be(data, 32),
                    .firm = readBytes4(data, 36),
                    .order_reference_number = readU64Be(data, 40),
                } };
            },
            'U' => blk: {
                if (data.len < 62) return OuchError.BufferTooShort;
                break :blk OuchMessage{ .replaced = .{
                    .replacement_token = readBytes14(data, 1),
                    .side = data[15],
                    .shares = readU32Be(data, 16),
                    .symbol = readBytes8(data, 20),
                    .price = readU32Be(data, 28),
                    .tif = readU32Be(data, 32),
                    .firm = readBytes4(data, 36),
                    .order_reference_number = readU64Be(data, 40),
                    .previous_order_token = readBytes14(data, 48),
                } };
            },
            'C' => blk: {
                if (data.len < 20) return OuchError.BufferTooShort;
                break :blk OuchMessage{ .canceled = .{
                    .token = readBytes14(data, 1),
                    .shares = readU32Be(data, 15),
                    .reason = data[19],
                } };
            },
            'E' => blk: {
                if (data.len < 32) return OuchError.BufferTooShort;
                break :blk OuchMessage{ .executed = .{
                    .token = readBytes14(data, 1),
                    .executed_shares = readU32Be(data, 15),
                    .execution_price = readU32Be(data, 19),
                    .liquidity_flag = data[23],
                    .match_number = readU64Be(data, 24),
                } };
            },
            'J' => blk: {
                if (data.len < 16) return OuchError.BufferTooShort;
                break :blk OuchMessage{ .rejected = .{
                    .token = readBytes14(data, 1),
                    .reason = data[15],
                } };
            },
            else => OuchError.UnknownMessageType,
        };
    }
};
