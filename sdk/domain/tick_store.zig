const std = @import("std");

pub const Side = enum(u8) { buy = 0, sell = 1 };

pub const Tick = struct {
    timestamp: u128,
    price: i64,
    quantity: i64,
    side: Side,
};

/// Write a u64 as a variable-length integer (LEB128-style unsigned).
/// Returns number of bytes written.
fn writeVarint(buf: []u8, value: u64) usize {
    var v = value;
    var i: usize = 0;
    while (true) {
        if (v < 0x80) {
            buf[i] = @as(u8, @intCast(v));
            i += 1;
            break;
        }
        buf[i] = @as(u8, @intCast((v & 0x7F) | 0x80));
        i += 1;
        v >>= 7;
    }
    return i;
}

/// Read a u64 from LEB128-style varint. Returns (value, bytes_consumed).
fn readVarint(buf: []const u8) struct { value: u64, consumed: usize } {
    var result: u64 = 0;
    var shift: u6 = 0;
    var i: usize = 0;
    while (i < buf.len) {
        const byte = buf[i];
        i += 1;
        result |= @as(u64, @intCast(byte & 0x7F)) << shift;
        if ((byte & 0x80) == 0) break;
        shift += 7;
        if (shift >= 64) break;
    }
    return .{ .value = result, .consumed = i };
}

/// Encode a signed i64 as a zigzag u64 (maps negatives to positive space).
fn zigzagEncode(value: i64) u64 {
    const v = @as(i64, value);
    return @as(u64, @bitCast((v << 1) ^ (v >> 63)));
}

/// Decode a zigzag-encoded u64 back to i64.
fn zigzagDecode(value: u64) i64 {
    return @as(i64, @bitCast((value >> 1) ^ (0 -% (value & 1))));
}

/// A date partition: one file per (instrument, YYYYMMDD).
const Partition = struct {
    date_tag: u32, // YYYYMMDD
    file: std.fs.File,
    last_timestamp: u128,
    last_price: i64,
    tick_count: u64,

    fn deinit(self: *Partition) void {
        self.file.close();
    }
};

pub const TickIterator = struct {
    allocator: std.mem.Allocator,
    data: []u8,
    offset: usize,
    last_timestamp: u128,
    last_price: i64,
    from: u128,
    to: u128,

    pub fn deinit(self: *TickIterator) void {
        self.allocator.free(self.data);
    }

    pub fn next(self: *TickIterator) ?Tick {
        while (self.offset < self.data.len) {
            const remaining = self.data[self.offset..];
            if (remaining.len == 0) return null;

            // Read delta_timestamp (varint)
            const ts_result = readVarint(remaining);
            if (ts_result.consumed == 0) return null;
            var pos = ts_result.consumed;

            // Read delta_price (varint zigzag)
            const price_result = readVarint(remaining[pos..]);
            if (price_result.consumed == 0) return null;
            pos += price_result.consumed;

            // Read quantity (varint zigzag)
            const qty_result = readVarint(remaining[pos..]);
            if (qty_result.consumed == 0) return null;
            pos += qty_result.consumed;

            // Read side (1 byte)
            if (pos >= remaining.len) return null;
            const side_byte = remaining[pos];
            pos += 1;

            self.offset += pos;

            const abs_ts = self.last_timestamp + ts_result.value;
            const abs_price = self.last_price + zigzagDecode(price_result.value);
            const qty = zigzagDecode(qty_result.value);
            const side: Side = if (side_byte == 0) .buy else .sell;

            self.last_timestamp = abs_ts;
            self.last_price = abs_price;

            if (abs_ts < self.from) continue;
            if (abs_ts > self.to) return null;

            return Tick{
                .timestamp = abs_ts,
                .price = abs_price,
                .quantity = qty,
                .side = side,
            };
        }
        return null;
    }
};

pub const TickStore = struct {
    allocator: std.mem.Allocator,
    base_path: []const u8,
    /// Currently open partition per instrument (instrument -> Partition)
    open_partitions: std.StringHashMap(Partition),

    pub fn init(allocator: std.mem.Allocator, base_path: []const u8) !TickStore {
        // Create base directory if not exists
        std.fs.makeDirAbsolute(base_path) catch |err| switch (err) {
            error.PathAlreadyExists => {},
            else => return err,
        };

        return TickStore{
            .allocator = allocator,
            .base_path = base_path,
            .open_partitions = std.StringHashMap(Partition).init(allocator),
        };
    }

    pub fn deinit(self: *TickStore) void {
        var it = self.open_partitions.iterator();
        while (it.next()) |entry| {
            entry.value_ptr.deinit();
        }
        self.open_partitions.deinit();
    }

    /// Compute YYYYMMDD from nanosecond timestamp.
    fn dateTagFromNs(ts_ns: u128) u32 {
        const ts_secs = @as(u64, @intCast(ts_ns / 1_000_000_000));
        // Days since Unix epoch
        const days = ts_secs / 86400;
        // Gregorian calendar computation
        const z = @as(i64, @intCast(days)) + 719468;
        const era = @divFloor(z, 146097);
        const doe = @as(u32, @intCast(z - era * 146097));
        const yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
        const y = @as(i64, @intCast(yoe)) + era * 400;
        const doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
        const mp = (5 * doy + 2) / 153;
        const d = doy - (153 * mp + 2) / 5 + 1;
        const m = if (mp < 10) mp + 3 else mp - 9;
        const year = if (m <= 2) y + 1 else y;

        return @as(u32, @intCast(year)) * 10000 + m * 100 + d;
    }

    fn partitionPath(self: *TickStore, buf: []u8, instrument: []const u8, date_tag: u32) ![]const u8 {
        return std.fmt.bufPrint(buf, "{s}/{s}/{d:0>8}.ticks", .{ self.base_path, instrument, date_tag });
    }

    fn ensureInstrumentDir(self: *TickStore, instrument: []const u8) !void {
        var buf: [1024]u8 = undefined;
        const dir_path = try std.fmt.bufPrint(&buf, "{s}/{s}", .{ self.base_path, instrument });
        std.fs.makeDirAbsolute(dir_path) catch |err| switch (err) {
            error.PathAlreadyExists => {},
            else => return err,
        };
    }

    fn openPartition(self: *TickStore, instrument: []const u8, date_tag: u32) !*Partition {
        try self.ensureInstrumentDir(instrument);

        var path_buf: [1024]u8 = undefined;
        const path = try self.partitionPath(&path_buf, instrument, date_tag);

        const file = try std.fs.createFileAbsolute(path, .{
            .read = true,
            .truncate = false,
        });

        // Seek to end for appending
        try file.seekFromEnd(0);

        const part = Partition{
            .date_tag = date_tag,
            .file = file,
            .last_timestamp = 0,
            .last_price = 0,
            .tick_count = 0,
        };

        try self.open_partitions.put(instrument, part);
        return self.open_partitions.getPtr(instrument).?;
    }

    /// Append a tick to the date-partitioned file for the instrument.
    pub fn write(self: *TickStore, instrument: []const u8, tick: Tick) !void {
        const date_tag = dateTagFromNs(tick.timestamp);

        // Check if we have an open partition for this instrument
        var part_ptr = self.open_partitions.getPtr(instrument);
        if (part_ptr == null or part_ptr.?.date_tag != date_tag) {
            // Close old partition if date changed
            if (part_ptr) |old| {
                old.deinit();
                _ = self.open_partitions.remove(instrument);
            }
            part_ptr = try self.openPartition(instrument, date_tag);
        }

        const part = part_ptr.?;

        // Delta-encode timestamp (as nanoseconds delta)
        const delta_ts = tick.timestamp - part.last_timestamp;
        const delta_price = tick.price - part.last_price;

        var buf: [64]u8 = undefined;
        var offset: usize = 0;

        offset += writeVarint(buf[offset..], @as(u64, @intCast(delta_ts)));
        offset += writeVarint(buf[offset..], zigzagEncode(delta_price));
        offset += writeVarint(buf[offset..], zigzagEncode(tick.quantity));
        buf[offset] = @intFromEnum(tick.side);
        offset += 1;

        _ = try part.file.write(buf[0..offset]);

        part.last_timestamp = tick.timestamp;
        part.last_price = tick.price;
        part.tick_count += 1;
    }

    /// Flush all buffered writes to disk.
    pub fn flush(self: *TickStore) !void {
        var it = self.open_partitions.iterator();
        while (it.next()) |entry| {
            try entry.value_ptr.file.sync();
        }
    }

    /// Query ticks for an instrument in the range [from, to] (nanosecond timestamps).
    /// Reads all relevant partition files.
    pub fn query(self: *TickStore, instrument: []const u8, from: u128, to: u128) !TickIterator {
        // Flush first to ensure data is on disk
        try self.flush();

        const from_date = dateTagFromNs(from);
        const to_date = dateTagFromNs(to);

        // Collect all data from relevant partitions
        var all_data = std.ArrayList(u8).init(self.allocator);
        errdefer all_data.deinit();

        var current_date = from_date;
        while (current_date <= to_date) {
            var path_buf: [1024]u8 = undefined;
            const path = try self.partitionPath(&path_buf, instrument, current_date);

            const file = std.fs.openFileAbsolute(path, .{}) catch |err| switch (err) {
                error.FileNotFound => {
                    current_date = nextDate(current_date);
                    continue;
                },
                else => return err,
            };
            defer file.close();

            const file_size = (try file.stat()).size;
            if (file_size > 0) {
                const start = all_data.items.len;
                try all_data.resize(start + file_size);
                _ = try file.readAll(all_data.items[start..]);
            }

            current_date = nextDate(current_date);
        }

        const data = try all_data.toOwnedSlice();

        return TickIterator{
            .allocator = self.allocator,
            .data = data,
            .offset = 0,
            .last_timestamp = 0,
            .last_price = 0,
            .from = from,
            .to = to,
        };
    }

    fn nextDate(date_tag: u32) u32 {
        // Extract Y/M/D
        const y = date_tag / 10000;
        const m = (date_tag % 10000) / 100;
        const d = date_tag % 100;

        // Days in month (simplified, no leap year for brevity)
        const days_in_month = [_]u32{ 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
        const is_leap = (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0);
        const dim = if (m == 2 and is_leap) @as(u32, 29) else days_in_month[m];

        if (d < dim) {
            return y * 10000 + m * 100 + (d + 1);
        } else if (m < 12) {
            return y * 10000 + (m + 1) * 100 + 1;
        } else {
            return (y + 1) * 10000 + 100 + 1;
        }
    }
};
