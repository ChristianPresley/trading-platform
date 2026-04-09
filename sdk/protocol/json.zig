// JSON streaming parser + DOM builder + serializer
// Supports: objects, arrays, strings (with escape sequences), numbers (int/float/negative/scientific),
// booleans, null. Returns error.NestingTooDeep for >100 levels of nesting.

const std = @import("std");

pub const MAX_NESTING = 100;

pub const ObjectMap = struct {
    keys_: [][]const u8,
    values_: []Value,
    len: usize,

    pub fn init() ObjectMap {
        return .{
            .keys_ = &.{},
            .values_ = &.{},
            .len = 0,
        };
    }

    pub fn get(self: ObjectMap, key: []const u8) ?Value {
        for (0..self.len) |i| {
            if (std.mem.eql(u8, self.keys_[i], key)) {
                return self.values_[i];
            }
        }
        return null;
    }

    pub fn keys(self: ObjectMap) [][]const u8 {
        return self.keys_[0..self.len];
    }

    pub fn deinit(self: *ObjectMap, allocator: std.mem.Allocator) void {
        for (0..self.len) |i| {
            allocator.free(self.keys_[i]);
            deinitValue(self.values_[i], allocator);
        }
        // Only free if heap-allocated (len > 0 means it came from toOwnedSlice)
        if (self.keys_.len > 0) allocator.free(self.keys_);
        if (self.values_.len > 0) allocator.free(self.values_);
        self.* = ObjectMap.init();
    }
};

pub const Value = union(enum) {
    object: ObjectMap,
    array: []Value,
    string: []const u8,
    number: f64,
    integer: i64,
    boolean: bool,
    null_value,
};

pub fn deinitValue(value: Value, allocator: std.mem.Allocator) void {
    switch (value) {
        .object => |obj| {
            var o = obj;
            o.deinit(allocator);
        },
        .array => |arr| {
            for (arr) |item| deinitValue(item, allocator);
            // Only free if it's a heap-allocated slice (len > 0 ensures it's from toOwnedSlice)
            if (arr.len > 0) allocator.free(arr);
        },
        .string => |s| allocator.free(s),
        else => {},
    }
}

const Tokenizer = struct {
    input: []const u8,
    pos: usize,

    fn init(input: []const u8) Tokenizer {
        return .{ .input = input, .pos = 0 };
    }

    fn skipWhitespace(self: *Tokenizer) void {
        while (self.pos < self.input.len) {
            switch (self.input[self.pos]) {
                ' ', '\t', '\r', '\n' => self.pos += 1,
                else => break,
            }
        }
    }

    fn peekReal(self: *Tokenizer) ?u8 {
        self.skipWhitespace();
        if (self.pos >= self.input.len) return null;
        return self.input[self.pos];
    }

    fn consume(self: *Tokenizer) !u8 {
        if (self.pos >= self.input.len) return error.UnexpectedEnd;
        const c = self.input[self.pos];
        self.pos += 1;
        return c;
    }

    fn expect(self: *Tokenizer, c: u8) !void {
        const got = try self.consume();
        if (got != c) return error.UnexpectedCharacter;
    }

    fn parseString(self: *Tokenizer, allocator: std.mem.Allocator) ParseError![]const u8 {
        try self.expect('"');
        var result: std.ArrayList(u8) = .empty;
        errdefer result.deinit(allocator);

        while (true) {
            if (self.pos >= self.input.len) return error.UnterminatedString;
            const c = self.input[self.pos];
            self.pos += 1;

            if (c == '"') break;

            if (c == '\\') {
                if (self.pos >= self.input.len) return error.UnterminatedString;
                const esc = self.input[self.pos];
                self.pos += 1;
                switch (esc) {
                    '"' => try result.append(allocator, '"'),
                    '\\' => try result.append(allocator, '\\'),
                    '/' => try result.append(allocator, '/'),
                    'b' => try result.append(allocator, '\x08'),
                    'f' => try result.append(allocator, '\x0C'),
                    'n' => try result.append(allocator, '\n'),
                    'r' => try result.append(allocator, '\r'),
                    't' => try result.append(allocator, '\t'),
                    'u' => {
                        if (self.pos + 4 > self.input.len) return error.InvalidUnicodeEscape;
                        const hex_str = self.input[self.pos .. self.pos + 4];
                        self.pos += 4;
                        const code_point = std.fmt.parseInt(u21, hex_str, 16) catch return error.InvalidUnicodeEscape;

                        // High surrogate
                        if (code_point >= 0xD800 and code_point <= 0xDBFF) {
                            if (self.pos + 6 > self.input.len) return error.InvalidSurrogatePair;
                            if (self.input[self.pos] != '\\' or self.input[self.pos + 1] != 'u') return error.InvalidSurrogatePair;
                            self.pos += 2;
                            const low_hex = self.input[self.pos .. self.pos + 4];
                            self.pos += 4;
                            const low = std.fmt.parseInt(u21, low_hex, 16) catch return error.InvalidSurrogatePair;
                            if (low < 0xDC00 or low > 0xDFFF) return error.InvalidSurrogatePair;
                            const full_cp: u21 = @intCast(0x10000 + (@as(u32, code_point - 0xD800) << 10) + (low - 0xDC00));
                            var utf8_buf: [4]u8 = undefined;
                            const n = std.unicode.utf8Encode(full_cp, &utf8_buf) catch return error.InvalidUnicodeEscape;
                            try result.appendSlice(allocator, utf8_buf[0..n]);
                        } else {
                            var utf8_buf: [4]u8 = undefined;
                            const n = std.unicode.utf8Encode(code_point, &utf8_buf) catch return error.InvalidUnicodeEscape;
                            try result.appendSlice(allocator, utf8_buf[0..n]);
                        }
                    },
                    else => return error.InvalidEscapeSequence,
                }
            } else {
                try result.append(allocator, c);
            }
        }

        return result.toOwnedSlice(allocator);
    }

    fn parseNumber(self: *Tokenizer) ParseError!Value {
        const start = self.pos;
        var is_float = false;

        if (self.pos < self.input.len and self.input[self.pos] == '-') {
            self.pos += 1;
        }

        if (self.pos >= self.input.len) return error.InvalidNumber;
        if (self.input[self.pos] == '0') {
            self.pos += 1;
        } else if (self.input[self.pos] >= '1' and self.input[self.pos] <= '9') {
            while (self.pos < self.input.len and self.input[self.pos] >= '0' and self.input[self.pos] <= '9') {
                self.pos += 1;
            }
        } else {
            return error.InvalidNumber;
        }

        if (self.pos < self.input.len and self.input[self.pos] == '.') {
            is_float = true;
            self.pos += 1;
            if (self.pos >= self.input.len or self.input[self.pos] < '0' or self.input[self.pos] > '9') {
                return error.InvalidNumber;
            }
            while (self.pos < self.input.len and self.input[self.pos] >= '0' and self.input[self.pos] <= '9') {
                self.pos += 1;
            }
        }

        if (self.pos < self.input.len and (self.input[self.pos] == 'e' or self.input[self.pos] == 'E')) {
            is_float = true;
            self.pos += 1;
            if (self.pos < self.input.len and (self.input[self.pos] == '+' or self.input[self.pos] == '-')) {
                self.pos += 1;
            }
            if (self.pos >= self.input.len or self.input[self.pos] < '0' or self.input[self.pos] > '9') {
                return error.InvalidNumber;
            }
            while (self.pos < self.input.len and self.input[self.pos] >= '0' and self.input[self.pos] <= '9') {
                self.pos += 1;
            }
        }

        const num_str = self.input[start..self.pos];

        if (is_float) {
            const f = std.fmt.parseFloat(f64, num_str) catch return error.InvalidNumber;
            return Value{ .number = f };
        } else {
            const i = std.fmt.parseInt(i64, num_str, 10) catch {
                const f = std.fmt.parseFloat(f64, num_str) catch return error.InvalidNumber;
                return Value{ .number = f };
            };
            return Value{ .integer = i };
        }
    }
};

pub const ParseError = error{
    NestingTooDeep,
    UnexpectedEnd,
    UnexpectedCharacter,
    InvalidLiteral,
    UnterminatedString,
    InvalidUnicodeEscape,
    InvalidSurrogatePair,
    InvalidEscapeSequence,
    InvalidNumber,
    ExpectedString,
    TrailingComma,
    ExpectedCommaOrBrace,
    ExpectedCommaOrBracket,
    TrailingData,
    OutOfMemory,
};

pub const JsonParser = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) JsonParser {
        return .{ .allocator = allocator };
    }

    pub fn parse(self: *JsonParser, input: []const u8) ParseError!Value {
        var tok = Tokenizer.init(input);
        const value = try self.parseValue(&tok, 0);
        tok.skipWhitespace();
        if (tok.pos != tok.input.len) return error.TrailingData;
        return value;
    }

    fn parseValue(self: *JsonParser, tok: *Tokenizer, depth: usize) ParseError!Value {
        if (depth > MAX_NESTING) return error.NestingTooDeep;

        tok.skipWhitespace();
        const c = tok.peekReal() orelse return error.UnexpectedEnd;

        return switch (c) {
            '{' => self.parseObject(tok, depth + 1),
            '[' => self.parseArray(tok, depth + 1),
            '"' => Value{ .string = try tok.parseString(self.allocator) },
            '-', '0'...'9' => tok.parseNumber(),
            't' => blk: {
                if (tok.pos + 4 > tok.input.len or !std.mem.eql(u8, tok.input[tok.pos .. tok.pos + 4], "true")) {
                    return error.InvalidLiteral;
                }
                tok.pos += 4;
                break :blk Value{ .boolean = true };
            },
            'f' => blk: {
                if (tok.pos + 5 > tok.input.len or !std.mem.eql(u8, tok.input[tok.pos .. tok.pos + 5], "false")) {
                    return error.InvalidLiteral;
                }
                tok.pos += 5;
                break :blk Value{ .boolean = false };
            },
            'n' => blk: {
                if (tok.pos + 4 > tok.input.len or !std.mem.eql(u8, tok.input[tok.pos .. tok.pos + 4], "null")) {
                    return error.InvalidLiteral;
                }
                tok.pos += 4;
                break :blk Value{ .null_value = {} };
            },
            else => error.UnexpectedCharacter,
        };
    }

    fn parseObject(self: *JsonParser, tok: *Tokenizer, depth: usize) ParseError!Value {
        tok.skipWhitespace();
        try tok.expect('{');

        var keys_list: std.ArrayList([]const u8) = .empty;
        var vals_list: std.ArrayList(Value) = .empty;
        errdefer {
            for (keys_list.items) |k| self.allocator.free(k);
            for (vals_list.items) |v| deinitValue(v, self.allocator);
            keys_list.deinit(self.allocator);
            vals_list.deinit(self.allocator);
        }

        tok.skipWhitespace();
        if (tok.peekReal() == '}') {
            _ = try tok.consume();
            keys_list.deinit(self.allocator);
            vals_list.deinit(self.allocator);
            return Value{ .object = ObjectMap.init() };
        }

        while (true) {
            tok.skipWhitespace();
            const first = tok.peekReal() orelse return error.UnexpectedEnd;
            if (first != '"') return error.ExpectedString;

            const key = try tok.parseString(self.allocator);
            // Append key first; outer errdefer frees keys_list.items on error.
            // Use a separate errdefer for the key itself in case append fails.
            keys_list.append(self.allocator, key) catch |e| {
                self.allocator.free(key);
                return e;
            };

            tok.skipWhitespace();
            try tok.expect(':');

            const value = try self.parseValue(tok, depth);
            try vals_list.append(self.allocator, value);

            tok.skipWhitespace();
            const next = tok.peekReal() orelse return error.UnexpectedEnd;
            if (next == '}') {
                _ = try tok.consume();
                break;
            }
            if (next == ',') {
                _ = try tok.consume();
                tok.skipWhitespace();
                if (tok.peekReal() == '}') return error.TrailingComma;
                continue;
            }
            return error.ExpectedCommaOrBrace;
        }

        const count = keys_list.items.len;
        const k_slice = try keys_list.toOwnedSlice(self.allocator);
        const v_slice = try vals_list.toOwnedSlice(self.allocator);
        return Value{ .object = ObjectMap{ .keys_ = k_slice, .values_ = v_slice, .len = count } };
    }

    fn parseArray(self: *JsonParser, tok: *Tokenizer, depth: usize) ParseError!Value {
        tok.skipWhitespace();
        try tok.expect('[');

        var items: std.ArrayList(Value) = .empty;
        errdefer {
            for (items.items) |item| deinitValue(item, self.allocator);
            items.deinit(self.allocator);
        }

        tok.skipWhitespace();
        if (tok.peekReal() == ']') {
            _ = try tok.consume();
            items.deinit(self.allocator);
            return Value{ .array = &.{} };
        }

        while (true) {
            const value = try self.parseValue(tok, depth);
            try items.append(self.allocator, value);

            tok.skipWhitespace();
            const next = tok.peekReal() orelse return error.UnexpectedEnd;
            if (next == ']') {
                _ = try tok.consume();
                break;
            }
            if (next == ',') {
                _ = try tok.consume();
                tok.skipWhitespace();
                if (tok.peekReal() == ']') return error.TrailingComma;
                continue;
            }
            return error.ExpectedCommaOrBracket;
        }

        return Value{ .array = try items.toOwnedSlice(self.allocator) };
    }

    pub fn deinit(self: *JsonParser) void {
        _ = self;
    }
};

/// Internal stringify to allocating writer (avoids anytype recursion issue).
fn stringifyToWriter(value: Value, aw: *std.Io.Writer.Allocating) (std.Io.Writer.Error || std.mem.Allocator.Error)!void {
    const writer = &aw.writer;
    switch (value) {
        .null_value => try writer.writeAll("null"),
        .boolean => |b| try writer.writeAll(if (b) "true" else "false"),
        .integer => |i| try writer.print("{d}", .{i}),
        .number => |f| {
            if (std.math.isNan(f) or std.math.isInf(f)) {
                try writer.writeAll("null");
            } else {
                try writer.print("{d}", .{f});
            }
        },
        .string => |s| {
            try writer.writeByte('"');
            for (s) |byte| {
                switch (byte) {
                    '"' => try writer.writeAll("\\\""),
                    '\\' => try writer.writeAll("\\\\"),
                    '\n' => try writer.writeAll("\\n"),
                    '\r' => try writer.writeAll("\\r"),
                    '\t' => try writer.writeAll("\\t"),
                    '\x08' => try writer.writeAll("\\b"),
                    '\x0C' => try writer.writeAll("\\f"),
                    0x00...0x07, 0x0B, 0x0E...0x1F => {
                        try writer.print("\\u{x:0>4}", .{byte});
                    },
                    else => try writer.writeByte(byte),
                }
            }
            try writer.writeByte('"');
        },
        .array => |arr| {
            try writer.writeByte('[');
            for (arr, 0..) |item, i| {
                if (i > 0) try writer.writeByte(',');
                try stringifyToWriter(item, aw);
            }
            try writer.writeByte(']');
        },
        .object => |obj| {
            try writer.writeByte('{');
            for (0..obj.len) |i| {
                if (i > 0) try writer.writeByte(',');
                // Write key as string
                try writer.writeByte('"');
                for (obj.keys_[i]) |byte| {
                    switch (byte) {
                        '"' => try writer.writeAll("\\\""),
                        '\\' => try writer.writeAll("\\\\"),
                        '\n' => try writer.writeAll("\\n"),
                        '\r' => try writer.writeAll("\\r"),
                        '\t' => try writer.writeAll("\\t"),
                        else => try writer.writeByte(byte),
                    }
                }
                try writer.writeByte('"');
                try writer.writeByte(':');
                try stringifyToWriter(obj.values_[i], aw);
            }
            try writer.writeByte('}');
        },
    }
}

/// Serialize a Value into a newly allocated string. Caller must free.
pub fn stringifyAlloc(allocator: std.mem.Allocator, value: Value) ![]const u8 {
    var aw: std.Io.Writer.Allocating = .init(allocator);
    errdefer {
        var list = aw.toArrayList();
        list.deinit(allocator);
    }
    try stringifyToWriter(value, &aw);
    return try aw.toOwnedSlice();
}

/// Serialize a Value into a fixed-size buffer. Returns the serialized slice.
/// Uses the buffer directly as backing storage via a fixed-buffer stream.
pub fn stringify(value: Value, buf: []u8) ![]const u8 {
    // Use a FixedBufferAllocator backed by a stack buffer to avoid any heap allocation.
    var stack_buf: [65536]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&stack_buf);
    const fba_alloc = fba.allocator();
    var aw: std.Io.Writer.Allocating = .init(fba_alloc);
    try stringifyToWriter(value, &aw);
    const result = aw.written();
    if (result.len > buf.len) return error.NoSpaceLeft;
    @memcpy(buf[0..result.len], result);
    return buf[0..result.len];
}
