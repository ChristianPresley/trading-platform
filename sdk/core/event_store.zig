/// Append-only event store with file-based persistence.
/// On-disk format per event: [8 bytes seq][16 bytes timestamp][4 bytes data_len][data_len bytes data]
///
/// NOTE: Single-writer constraint — concurrent appends are NOT supported.
/// Multiple readers (via replay iterators) are safe as long as no concurrent writer exists.
const std = @import("std");

const HEADER_SIZE: usize = 8 + 16 + 4; // seq(8) + timestamp(16) + data_len(4)

// --- File-scope byte order helpers ---

fn writeU64Le(buf: *[8]u8, v: u64) void {
    buf[0] = @intCast(v & 0xff);
    buf[1] = @intCast((v >> 8) & 0xff);
    buf[2] = @intCast((v >> 16) & 0xff);
    buf[3] = @intCast((v >> 24) & 0xff);
    buf[4] = @intCast((v >> 32) & 0xff);
    buf[5] = @intCast((v >> 40) & 0xff);
    buf[6] = @intCast((v >> 48) & 0xff);
    buf[7] = @intCast((v >> 56) & 0xff);
}

fn writeU32Le(buf: *[4]u8, v: u32) void {
    buf[0] = @intCast(v & 0xff);
    buf[1] = @intCast((v >> 8) & 0xff);
    buf[2] = @intCast((v >> 16) & 0xff);
    buf[3] = @intCast((v >> 24) & 0xff);
}

fn writeU128Le(buf: *[16]u8, v: u128) void {
    var i: usize = 0;
    while (i < 16) : (i += 1) {
        buf[i] = @intCast((v >> @intCast(i * 8)) & 0xff);
    }
}

fn readU64Le(buf: []const u8) u64 {
    return @as(u64, buf[0]) |
        (@as(u64, buf[1]) << 8) |
        (@as(u64, buf[2]) << 16) |
        (@as(u64, buf[3]) << 24) |
        (@as(u64, buf[4]) << 32) |
        (@as(u64, buf[5]) << 40) |
        (@as(u64, buf[6]) << 48) |
        (@as(u64, buf[7]) << 56);
}

fn readU32Le(buf: []const u8) u32 {
    return @as(u32, buf[0]) |
        (@as(u32, buf[1]) << 8) |
        (@as(u32, buf[2]) << 16) |
        (@as(u32, buf[3]) << 24);
}

fn readU128Le(buf: []const u8) u128 {
    var v: u128 = 0;
    var i: usize = 0;
    while (i < 16) : (i += 1) {
        v |= @as(u128, buf[i]) << @intCast(i * 8);
    }
    return v;
}

fn nowNanos() u128 {
    var ts: std.posix.timespec = undefined;
    std.posix.clock_gettime(std.posix.CLOCK.REALTIME, &ts) catch return 0;
    return @as(u128, @intCast(ts.tv_sec)) * 1_000_000_000 + @as(u128, @intCast(ts.tv_nsec));
}

// ---

pub const Event = struct {
    sequence: u64,
    timestamp: u128,
    data: []const u8,
};

pub const Iterator = struct {
    store: *const EventStore,
    current_offset: usize,

    pub fn next(self: *Iterator) ?Event {
        if (self.current_offset + HEADER_SIZE > @as(usize, @intCast(self.store.write_offset))) return null;

        // Read header to determine record size
        var header: [HEADER_SIZE]u8 = undefined;
        const n = self.store.file.pread(&header, self.current_offset) catch return null;
        if (n < HEADER_SIZE) return null;

        const data_len = readU32Le(header[24..28]);
        const record_size = HEADER_SIZE + data_len;

        const evt = self.store.readAtOffset(self.current_offset) catch return null;
        self.current_offset += record_size;
        return evt;
    }
};

pub const EventStore = struct {
    allocator: std.mem.Allocator,
    file: std.fs.File,
    path: []const u8,
    /// Current write offset (= file size)
    write_offset: u64,
    /// Total number of events appended
    event_count: u64,
    /// Last sequence number assigned
    last_seq: u64,

    /// Opens or creates the event store file at `path`.
    pub fn init(allocator: std.mem.Allocator, path: []const u8) !EventStore {
        const path_copy = try allocator.dupe(u8, path);
        errdefer allocator.free(path_copy);

        const file = try std.fs.cwd().createFile(path, .{
            .read = true,
            .truncate = false,
        });

        // Determine current file size to resume from existing data
        const stat = try file.stat();
        const write_offset = stat.size;

        // Scan existing events to determine last_seq and event_count
        var last_seq: u64 = 0;
        var event_count: u64 = 0;
        var offset: u64 = 0;
        while (offset + HEADER_SIZE <= write_offset) {
            var header: [HEADER_SIZE]u8 = undefined;
            const n = try file.pread(&header, offset);
            if (n < HEADER_SIZE) break;

            const seq = readU64Le(header[0..8]);
            const data_len = readU32Le(header[24..28]);
            const record_size: u64 = HEADER_SIZE + data_len;

            if (offset + record_size > write_offset) break;

            last_seq = seq;
            event_count += 1;
            offset += record_size;
        }

        return EventStore{
            .allocator = allocator,
            .file = file,
            .path = path_copy,
            .write_offset = write_offset,
            .event_count = event_count,
            .last_seq = last_seq,
        };
    }

    /// Append an event. Returns the assigned sequence number.
    pub fn append(self: *EventStore, event: []const u8) !u64 {
        const seq = self.last_seq + 1;
        const ts = nowNanos();
        const data_len: u32 = @intCast(event.len);

        var header: [HEADER_SIZE]u8 = undefined;
        writeU64Le(header[0..8], seq);
        writeU128Le(header[8..24], ts);
        writeU32Le(header[24..28], data_len);

        try self.file.seekTo(self.write_offset);
        try self.file.writeAll(&header);
        try self.file.writeAll(event);

        self.write_offset += HEADER_SIZE + data_len;
        self.last_seq = seq;
        self.event_count += 1;
        return seq;
    }

    /// Read a single event by sequence number.
    /// Scans from the beginning — O(n) but suitable for correctness.
    pub fn read(self: *EventStore, seq: u64) ![]const u8 {
        var offset: u64 = 0;
        while (offset + HEADER_SIZE <= self.write_offset) {
            var header: [HEADER_SIZE]u8 = undefined;
            const n = try self.file.pread(&header, offset);
            if (n < HEADER_SIZE) return error.EventNotFound;

            const event_seq = readU64Le(header[0..8]);
            const data_len = readU32Le(header[24..28]);
            const data_offset = offset + HEADER_SIZE;

            if (event_seq == seq) {
                const buf = try self.allocator.alloc(u8, data_len);
                const read_n = try self.file.pread(buf, data_offset);
                if (read_n < data_len) {
                    self.allocator.free(buf);
                    return error.TruncatedEvent;
                }
                return buf;
            }

            offset += HEADER_SIZE + data_len;
        }
        return error.EventNotFound;
    }

    /// Read event at a given byte offset.
    pub fn readAtOffset(self: *const EventStore, offset: usize) !Event {
        if (offset + HEADER_SIZE > @as(usize, @intCast(self.write_offset))) return error.EndOfStore;

        var header: [HEADER_SIZE]u8 = undefined;
        const n = try self.file.pread(&header, offset);
        if (n < HEADER_SIZE) return error.EndOfStore;

        const seq = readU64Le(header[0..8]);
        const ts = readU128Le(header[8..24]);
        const data_len = readU32Le(header[24..28]);
        const data_offset = offset + HEADER_SIZE;

        if (data_offset + data_len > @as(usize, @intCast(self.write_offset))) return error.TruncatedEvent;

        const buf = try self.allocator.alloc(u8, data_len);
        errdefer self.allocator.free(buf);
        const read_n = try self.file.pread(buf, data_offset);
        if (read_n < data_len) return error.TruncatedEvent;

        return Event{
            .sequence = seq,
            .timestamp = ts,
            .data = buf,
        };
    }

    /// Returns an iterator starting from the first event with sequence >= from_seq.
    pub fn replay(self: *const EventStore, from_seq: u64) Iterator {
        // Scan to find the starting offset
        var offset: u64 = 0;
        while (offset + HEADER_SIZE <= self.write_offset) {
            var header: [HEADER_SIZE]u8 = undefined;
            const n = self.file.pread(&header, offset) catch break;
            if (n < HEADER_SIZE) break;

            const event_seq = readU64Le(header[0..8]);
            const data_len = readU32Le(header[24..28]);

            if (event_seq >= from_seq) {
                return Iterator{
                    .store = self,
                    .current_offset = @intCast(offset),
                };
            }

            offset += HEADER_SIZE + data_len;
        }

        // No matching event found — return iterator pointing to end
        return Iterator{
            .store = self,
            .current_offset = @intCast(self.write_offset),
        };
    }

    pub fn lastSequence(self: *const EventStore) u64 {
        return self.last_seq;
    }

    pub fn deinit(self: *EventStore) void {
        self.file.close();
        self.allocator.free(self.path);
    }
};
