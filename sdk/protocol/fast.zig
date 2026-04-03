// FAST (FIX Adapted for Streaming) Decoder
// Implements: stop-bit integer encoding, presence maps, delta/copy/increment operators.
// No external dependencies — pure Zig implementation.

const std = @import("std");

pub const FastError = error{
    BufferTooShort,
    PmapTooLong,
    Overflow,
    InvalidStopBit,
    MissingTemplate,
    UnsupportedOperator,
};

// Maximum PMAP bytes (7 bits each, up to 8 continuation bytes)
pub const MAX_PMAP_BYTES: usize = 8;

// Presence map: tracks which fields are present in this message
pub const PresenceMap = struct {
    bits: u64,
    bit_count: u6,

    pub fn isSet(self: PresenceMap, index: u6) bool {
        if (index >= self.bit_count) return false;
        return (self.bits >> @intCast(self.bit_count - 1 - index)) & 1 == 1;
    }
};

// Stop-bit decoding: each byte uses 7 data bits; MSB=1 marks the last byte.
// Returns the decoded unsigned value and the number of bytes consumed.
pub fn decodeStopBit(data: []const u8) FastError!struct { value: u64, bytes_consumed: usize } {
    if (data.len == 0) return FastError.BufferTooShort;
    var value: u64 = 0;
    var i: usize = 0;
    while (i < data.len) {
        const byte = data[i];
        const bits: u64 = byte & 0x7F;
        // Check for overflow before shifting
        if (value > (std.math.maxInt(u64) >> 7)) return FastError.Overflow;
        value = (value << 7) | bits;
        i += 1;
        if (byte & 0x80 != 0) {
            // Stop bit set — this is the last byte
            return .{ .value = value, .bytes_consumed = i };
        }
    }
    return FastError.InvalidStopBit;
}

// Signed stop-bit decoding (for signed integers, sign-extension from 7-bit chunks)
pub fn decodeStopBitSigned(data: []const u8) FastError!struct { value: i64, bytes_consumed: usize } {
    if (data.len == 0) return FastError.BufferTooShort;
    var value: i64 = 0;
    var i: usize = 0;
    while (i < data.len) {
        const byte = data[i];
        const bits: i64 = @as(i64, byte & 0x7F);
        value = (value << 7) | bits;
        i += 1;
        if (byte & 0x80 != 0) {
            // Sign-extend: if MSB of 7-bit chunk is set in first byte, value is negative
            // Check if sign bit (bit 6 of first byte after masking) was set
            if (data[0] & 0x40 != 0) {
                // Sign extend: fill upper bits with 1s
                const shift: u6 = @intCast(@min(63, i * 7));
                const mask = ~((@as(i64, 1) << shift) - 1);
                value |= mask;
            }
            return .{ .value = value, .bytes_consumed = i };
        }
    }
    return FastError.InvalidStopBit;
}

// Decode presence map from stop-bit encoded bytes (each byte 7 pmap bits + stop bit)
pub fn decodePmap(data: []const u8) FastError!PresenceMap {
    if (data.len == 0) return FastError.BufferTooShort;
    var bits: u64 = 0;
    var bit_count: usize = 0;
    var i: usize = 0;
    while (i < data.len and i < MAX_PMAP_BYTES) {
        const byte = data[i];
        const chunk: u64 = byte & 0x7F;
        bits = (bits << 7) | chunk;
        bit_count += 7;
        i += 1;
        if (byte & 0x80 != 0) {
            // Stop bit — pmap ends here
            break;
        }
    } else {
        if (i >= MAX_PMAP_BYTES) return FastError.PmapTooLong;
    }
    return PresenceMap{
        .bits = bits,
        .bit_count = @intCast(@min(bit_count, 63)),
    };
}

// FAST field operator types
pub const Operator = enum {
    none,
    copy,
    delta,
    increment,
    constant,
    default,
};

// FAST field value (simplified to u64 for demonstration)
pub const FastFieldValue = union(enum) {
    unsigned: u64,
    signed: i64,
    string_val: []const u8,
    absent,
};

// FAST field descriptor (template-driven)
pub const FastFieldDef = struct {
    name: []const u8,
    operator: Operator,
    is_optional: bool,
    initial_value: u64,
};

// FAST decoder state (maintains previous values for delta/copy/increment)
pub const FastDecoder = struct {
    prev_values: [64]u64,
    field_count: usize,

    pub fn init() FastDecoder {
        return FastDecoder{
            .prev_values = [_]u64{0} ** 64,
            .field_count = 0,
        };
    }

    // Decode a FAST message body given a template definition and raw data.
    // Returns decoded field values (caller must provide buffer for results).
    // data: raw bytes starting AFTER the pmap bytes
    // pmap: presence map already decoded
    // template: field definitions
    // out: output buffer for field values
    // Returns number of fields decoded.
    pub fn decode(
        self: *FastDecoder,
        data: []const u8,
        pmap: PresenceMap,
        template: []const FastFieldDef,
        out: []FastFieldValue,
    ) FastError!usize {
        var cursor: usize = 0;
        var field_idx: usize = 0;

        for (template, 0..) |field_def, fi| {
            if (fi >= out.len) break;
            const present = pmap.isSet(@intCast(fi));

            switch (field_def.operator) {
                .none => {
                    // Always present, no state
                    if (cursor >= data.len) return FastError.BufferTooShort;
                    const result = try decodeStopBit(data[cursor..]);
                    cursor += result.bytes_consumed;
                    out[fi] = .{ .unsigned = result.value };
                    field_idx += 1;
                },
                .copy => {
                    if (present) {
                        if (cursor >= data.len) return FastError.BufferTooShort;
                        const result = try decodeStopBit(data[cursor..]);
                        cursor += result.bytes_consumed;
                        self.prev_values[fi] = result.value;
                        out[fi] = .{ .unsigned = result.value };
                    } else {
                        out[fi] = .{ .unsigned = self.prev_values[fi] };
                    }
                    field_idx += 1;
                },
                .delta => {
                    if (present) {
                        if (cursor >= data.len) return FastError.BufferTooShort;
                        const result = try decodeStopBitSigned(data[cursor..]);
                        cursor += result.bytes_consumed;
                        const new_val = @as(i64, @bitCast(self.prev_values[fi])) + result.value;
                        self.prev_values[fi] = @bitCast(new_val);
                        out[fi] = .{ .unsigned = self.prev_values[fi] };
                    } else {
                        out[fi] = .{ .unsigned = self.prev_values[fi] };
                    }
                    field_idx += 1;
                },
                .increment => {
                    if (present) {
                        if (cursor >= data.len) return FastError.BufferTooShort;
                        const result = try decodeStopBit(data[cursor..]);
                        cursor += result.bytes_consumed;
                        self.prev_values[fi] = result.value;
                        out[fi] = .{ .unsigned = result.value };
                    } else {
                        self.prev_values[fi] +%= 1;
                        out[fi] = .{ .unsigned = self.prev_values[fi] };
                    }
                    field_idx += 1;
                },
                .constant => {
                    out[fi] = .{ .unsigned = field_def.initial_value };
                    field_idx += 1;
                },
                .default => {
                    if (present) {
                        if (cursor >= data.len) return FastError.BufferTooShort;
                        const result = try decodeStopBit(data[cursor..]);
                        cursor += result.bytes_consumed;
                        out[fi] = .{ .unsigned = result.value };
                    } else {
                        out[fi] = .{ .unsigned = field_def.initial_value };
                    }
                    field_idx += 1;
                },
            }
        }

        return field_idx;
    }
};

// FastMessage: simple wrapper for decoded fields
pub const FastMessage = struct {
    field_count: usize,
    fields: []FastFieldValue,
};
