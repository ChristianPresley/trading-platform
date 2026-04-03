const std = @import("std");

/// Entry in the sequence store
const SeqEntry = struct {
    seq_num: u32,
    msg: []u8,
};

/// Sequence number persistence for gap fill / resend.
/// Stores sent messages indexed by sequence number for replay on ResendRequest.
pub const SeqStore = struct {
    allocator: std.mem.Allocator,
    entries: std.ArrayList(SeqEntry),

    /// Allocates the sequence store.
    pub fn init(allocator: std.mem.Allocator) !SeqStore {
        return .{
            .allocator = allocator,
            .entries = std.ArrayList(SeqEntry).init(allocator),
        };
    }

    /// Stores a message at the given sequence number.
    /// If the sequence number already exists, overwrites the existing message.
    pub fn store(self: *SeqStore, seq_num: u32, msg: []const u8) !void {
        // Check if already exists
        for (self.entries.items) |*entry| {
            if (entry.seq_num == seq_num) {
                self.allocator.free(entry.msg);
                entry.msg = try self.allocator.dupe(u8, msg);
                return;
            }
        }
        const duped = try self.allocator.dupe(u8, msg);
        try self.entries.append(.{ .seq_num = seq_num, .msg = duped });
    }

    /// Retrieves the message for a sequence number, or null if not found.
    pub fn retrieve(self: *const SeqStore, seq_num: u32) ?[]const u8 {
        for (self.entries.items) |entry| {
            if (entry.seq_num == seq_num) return entry.msg;
        }
        return null;
    }

    /// Returns the highest stored sequence number, or 0 if empty.
    pub fn lastSeqNum(self: *const SeqStore) u32 {
        var max: u32 = 0;
        for (self.entries.items) |entry| {
            if (entry.seq_num > max) max = entry.seq_num;
        }
        return max;
    }

    /// Frees all stored messages.
    pub fn deinit(self: *SeqStore) void {
        for (self.entries.items) |entry| {
            self.allocator.free(entry.msg);
        }
        self.entries.deinit();
    }
};
