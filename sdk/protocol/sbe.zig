// Simple Binary Encoding (SBE) Decoder — CME MDP 3.0
// Uses compile-time message layout definitions (no XML parser needed).
// Zero-copy: fields reference slices into input buffer at computed offsets.

const std = @import("std");

pub const SbeError = error{
    BufferTooShort,
    UnknownTemplateId,
    InvalidMessageHeader,
    FieldOutOfBounds,
    AllocatorRequired,
};

pub const FieldType = enum {
    uint8,
    uint16,
    uint32,
    uint64,
    int8,
    int16,
    int32,
    int64,
    decimal,
    string,
};

pub const Decimal = struct {
    mantissa: i64,
    exponent: i8,
};

pub const FieldValue = union(FieldType) {
    uint8: u8,
    uint16: u16,
    uint32: u32,
    uint64: u64,
    int8: i8,
    int16: i16,
    int32: i32,
    int64: i64,
    decimal: Decimal,
    string: []const u8,
};

pub const Field = struct {
    name: []const u8,
    value: FieldValue,
};

pub const SbeMessage = struct {
    template_id: u16,
    fields: []Field,
};

// Compile-time field layout descriptor
pub const FieldLayout = struct {
    name: []const u8,
    offset: usize, // byte offset from start of message body (after SBE header)
    field_type: FieldType,
    size: usize,   // for strings: byte length
};

// SBE message header: block_length(u16) + template_id(u16) + schema_id(u16) + version(u16) = 8 bytes
pub const SBE_HEADER_SIZE: usize = 8;

// Null sentinel values for optional fields (SBE convention)
pub const NULL_U8: u8 = 0xFF;
pub const NULL_U16: u16 = 0xFFFF;
pub const NULL_U32: u32 = 0xFFFF_FFFF;
pub const NULL_U64: u64 = 0xFFFF_FFFF_FFFF_FFFF;
pub const NULL_I8: i8 = @bitCast(@as(u8, 0x80));  // i8 min
pub const NULL_I16: i16 = @bitCast(@as(u16, 0x8000));
pub const NULL_I32: i32 = @bitCast(@as(u32, 0x8000_0000));
pub const NULL_I64: i64 = @bitCast(@as(u64, 0x8000_0000_0000_0000));

// Example CME MDP 3.0 message layouts (hardcoded comptime)
// Template 1: MDIncrementalRefreshTrade (simplified)
pub const MDIncrementalRefreshTradeLayout = [_]FieldLayout{
    .{ .name = "TransactTime", .offset = 0,  .field_type = .uint64, .size = 8 },
    .{ .name = "MatchEventIndicator", .offset = 8, .field_type = .uint8, .size = 1 },
    .{ .name = "SecurityID", .offset = 9, .field_type = .int32, .size = 4 },
    .{ .name = "RptSeq", .offset = 13, .field_type = .uint32, .size = 4 },
    .{ .name = "MDEntryPx", .offset = 17, .field_type = .decimal, .size = 9 },
    .{ .name = "MDEntrySize", .offset = 26, .field_type = .int32, .size = 4 },
    .{ .name = "NumberOfOrders", .offset = 30, .field_type = .int32, .size = 4 },
    .{ .name = "TradingReferenceDate", .offset = 34, .field_type = .uint16, .size = 2 },
    .{ .name = "AggressorSide", .offset = 36, .field_type = .uint8, .size = 1 },
    .{ .name = "MDUpdateAction", .offset = 37, .field_type = .uint8, .size = 1 },
};

// Template 2: MDIncrementalRefreshBook (simplified)
pub const MDIncrementalRefreshBookLayout = [_]FieldLayout{
    .{ .name = "TransactTime", .offset = 0,  .field_type = .uint64, .size = 8 },
    .{ .name = "MatchEventIndicator", .offset = 8, .field_type = .uint8, .size = 1 },
    .{ .name = "SecurityID", .offset = 9, .field_type = .int32, .size = 4 },
    .{ .name = "MDEntryPx", .offset = 13, .field_type = .decimal, .size = 9 },
    .{ .name = "MDEntrySize", .offset = 22, .field_type = .int32, .size = 4 },
    .{ .name = "MDEntryType", .offset = 26, .field_type = .uint8, .size = 1 },
    .{ .name = "MDUpdateAction", .offset = 27, .field_type = .uint8, .size = 1 },
};

pub const SbeDecoder = struct {
    allocator: std.mem.Allocator,

    // init with allocator (used to allocate field arrays in decode)
    pub fn init(allocator: std.mem.Allocator) SbeDecoder {
        return SbeDecoder{ .allocator = allocator };
    }

    // Decode reads the SBE header, determines template_id, then extracts fields
    // from the known compile-time layout. Returns an SbeMessage with allocated fields.
    // Caller must free message.fields with allocator.free().
    pub fn decode(self: *SbeDecoder, data: []const u8) SbeError!SbeMessage {
        if (data.len < SBE_HEADER_SIZE) return SbeError.InvalidMessageHeader;

        // SBE header layout (little-endian for CME MDP 3.0):
        // [0..1] block_length, [2..3] template_id, [4..5] schema_id, [6..7] version
        const block_length = std.mem.readInt(u16, data[0..2], .little);
        const template_id = std.mem.readInt(u16, data[2..4], .little);
        const body = data[SBE_HEADER_SIZE..];

        if (body.len < block_length) return SbeError.BufferTooShort;

        return switch (template_id) {
            1 => try self.decodeWithLayout(template_id, body, &MDIncrementalRefreshTradeLayout),
            2 => try self.decodeWithLayout(template_id, body, &MDIncrementalRefreshBookLayout),
            else => SbeError.UnknownTemplateId,
        };
    }

    fn decodeWithLayout(
        self: *SbeDecoder,
        template_id: u16,
        body: []const u8,
        layout: []const FieldLayout,
    ) SbeError!SbeMessage {
        const fields = self.allocator.alloc(Field, layout.len) catch return SbeError.AllocatorRequired;

        for (layout, 0..) |fl, i| {
            const end = fl.offset + fl.size;
            if (end > body.len) {
                self.allocator.free(fields);
                return SbeError.FieldOutOfBounds;
            }
            const slice = body[fl.offset..end];
            const value: FieldValue = switch (fl.field_type) {
                .uint8 => .{ .uint8 = slice[0] },
                .uint16 => .{ .uint16 = std.mem.readInt(u16, slice[0..2], .little) },
                .uint32 => .{ .uint32 = std.mem.readInt(u32, slice[0..4], .little) },
                .uint64 => .{ .uint64 = std.mem.readInt(u64, slice[0..8], .little) },
                .int8 => .{ .int8 = @bitCast(slice[0]) },
                .int16 => .{ .int16 = std.mem.readInt(i16, slice[0..2], .little) },
                .int32 => .{ .int32 = std.mem.readInt(i32, slice[0..4], .little) },
                .int64 => .{ .int64 = std.mem.readInt(i64, slice[0..8], .little) },
                .decimal => blk: {
                    // SBE Decimal5: 8-byte mantissa (i64) + 1-byte exponent (i8)
                    const mantissa = std.mem.readInt(i64, slice[0..8], .little);
                    const exponent: i8 = @bitCast(slice[8]);
                    break :blk .{ .decimal = .{ .mantissa = mantissa, .exponent = exponent } };
                },
                .string => .{ .string = slice },
            };
            fields[i] = Field{ .name = fl.name, .value = value };
        }

        return SbeMessage{
            .template_id = template_id,
            .fields = fields,
        };
    }

    pub fn freeMessage(self: *SbeDecoder, msg: SbeMessage) void {
        self.allocator.free(msg.fields);
    }
};
