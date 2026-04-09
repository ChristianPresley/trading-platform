const std = @import("std");

/// SOH delimiter byte used in FIX protocol
pub const SOH: u8 = 0x01;

/// A single FIX tag-value pair
const TagEntry = struct {
    tag: u32,
    value: []u8,
};

/// FIX tag-value message codec.
/// Supports encode/decode with SOH delimiter and checksum validation.
pub const FixMessage = struct {
    allocator: std.mem.Allocator,
    entries: std.ArrayList(TagEntry),

    /// Allocates tag storage.
    pub fn init(allocator: std.mem.Allocator) FixMessage {
        return .{
            .allocator = allocator,
            .entries = .empty,
        };
    }

    /// Frees all memory owned by this message.
    pub fn deinit(self: *FixMessage) void {
        for (self.entries.items) |entry| {
            self.allocator.free(entry.value);
        }
        self.entries.deinit(self.allocator);
    }

    /// Stores a tag=value pair. Duplicates tags are allowed (last write wins on get).
    pub fn setTag(self: *FixMessage, tag: u32, value: []const u8) !void {
        // If tag already exists, update in place
        for (self.entries.items) |*entry| {
            if (entry.tag == tag) {
                self.allocator.free(entry.value);
                entry.value = try self.allocator.dupe(u8, value);
                return;
            }
        }
        // New tag
        const duped = try self.allocator.dupe(u8, value);
        try self.entries.append(self.allocator, .{ .tag = tag, .value = duped });
    }

    /// Retrieves the value for a tag, or null if not present.
    pub fn getTag(self: *const FixMessage, tag: u32) ?[]const u8 {
        // Return the last occurrence per FIX spec
        var result: ?[]const u8 = null;
        for (self.entries.items) |entry| {
            if (entry.tag == tag) {
                result = entry.value;
            }
        }
        return result;
    }

    /// Shorthand for tag 35 (MsgType).
    pub fn getMsgType(self: *const FixMessage) ?[]const u8 {
        return self.getTag(35);
    }

    /// Parses tag value as integer (i64), returns null on missing or parse error.
    pub fn getInt(self: *const FixMessage, tag: u32) ?i64 {
        const val = self.getTag(tag) orelse return null;
        return std.fmt.parseInt(i64, val, 10) catch null;
    }

    /// Serializes the message: BeginString(8), BodyLength(9), MsgType(35),
    /// remaining tags in insertion order, CheckSum(10); SOH delimited.
    /// Returns the portion of buf actually used.
    pub fn encode(self: *const FixMessage, buf: []u8) ![]const u8 {
        const begin_string = self.getTag(8) orelse return error.MissingBeginString;
        const msg_type = self.getTag(35) orelse return error.MissingMsgType;

        // Build body: tag 35 first, then all other tags except 8, 9, 10
        var body_buf: [8192]u8 = undefined;
        var body_len: usize = 0;

        // MsgType (35) first
        const mt_field = try std.fmt.bufPrint(body_buf[body_len..], "35={s}\x01", .{msg_type});
        body_len += mt_field.len;

        // All other tags except 8, 9, 10, 35
        for (self.entries.items) |entry| {
            if (entry.tag == 8 or entry.tag == 9 or entry.tag == 10 or entry.tag == 35) continue;
            const field = try std.fmt.bufPrint(body_buf[body_len..], "{}={s}\x01", .{ entry.tag, entry.value });
            body_len += field.len;
        }

        const body = body_buf[0..body_len];
        const body_length = body.len;

        // Now assemble: BeginString SOH BodyLength SOH Body CheckSum SOH
        var pos: usize = 0;

        const bs = try std.fmt.bufPrint(buf[pos..], "8={s}\x01", .{begin_string});
        pos += bs.len;

        const bl = try std.fmt.bufPrint(buf[pos..], "9={}\x01", .{body_length});
        pos += bl.len;

        @memcpy(buf[pos..][0..body_len], body);
        pos += body_len;

        // Compute checksum over everything so far
        const checksum = computeChecksum(buf[0..pos]);
        const cs = try std.fmt.bufPrint(buf[pos..], "10={:0>3}\x01", .{checksum});
        pos += cs.len;

        return buf[0..pos];
    }

    /// Parses SOH-delimited tag=value pairs, validates checksum.
    pub fn decode(allocator: std.mem.Allocator, raw: []const u8) !FixMessage {
        var msg = FixMessage.init(allocator);
        errdefer msg.deinit();

        // Find the checksum field (tag 10) to validate
        // Checksum is over all bytes up to (but not including) the "10=" field
        var checksum_pos: ?usize = null;
        var pos: usize = 0;
        while (pos < raw.len) {
            // Find SOH
            var end = pos;
            while (end < raw.len and raw[end] != SOH) : (end += 1) {}

            const field = raw[pos..end];
            // Find '='
            var eq_pos: ?usize = null;
            for (field, 0..) |c, i| {
                if (c == '=') {
                    eq_pos = i;
                    break;
                }
            }
            const eq = eq_pos orelse return error.MalformedField;
            const tag_str = field[0..eq];
            const value = field[eq + 1 ..];

            const tag = std.fmt.parseInt(u32, tag_str, 10) catch return error.InvalidTag;

            // Record where "10=" starts for checksum validation
            if (tag == 10) {
                checksum_pos = pos;
            }

            try msg.setTag(tag, value);

            pos = end + 1; // skip SOH
        }

        // Require BeginString (tag 8) before checksum validation
        if (msg.getTag(8) == null) return error.MissingBeginString;

        // Validate checksum if tag 10 is present
        if (checksum_pos) |cs_pos| {
            const computed = computeChecksum(raw[0..cs_pos]);
            const stored_str = msg.getTag(10) orelse return error.MissingChecksum;
            const stored = std.fmt.parseInt(u8, stored_str, 10) catch return error.InvalidChecksum;
            if (computed != stored) return error.ChecksumMismatch;
        }

        return msg;
    }

    /// Computes the FIX checksum: sum of all bytes mod 256.
    pub fn computeChecksum(data: []const u8) u8 {
        var sum: u32 = 0;
        for (data) |b| {
            sum +%= b;
        }
        return @truncate(sum);
    }
};
