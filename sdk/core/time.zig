const std = @import("std");

pub const Timestamp = struct {
    nanos: u128,

    /// Reads CLOCK_MONOTONIC_RAW
    pub fn now() Timestamp {
        var ts: std.os.linux.timespec = undefined;
        const rc = std.os.linux.clock_gettime(.MONOTONIC, &ts);
        if (rc != 0) unreachable;
        return fromTimespec(ts);
    }

    /// Reads CLOCK_REALTIME
    pub fn wallClock() Timestamp {
        var ts: std.os.linux.timespec = undefined;
        const rc = std.os.linux.clock_gettime(.REALTIME, &ts);
        if (rc != 0) unreachable;
        return fromTimespec(ts);
    }

    fn fromTimespec(ts: std.os.linux.timespec) Timestamp {
        const secs: u128 = @intCast(ts.sec);
        const nanos: u128 = @intCast(ts.nsec);
        return .{ .nanos = secs * 1_000_000_000 + nanos };
    }

    pub fn fromUnixNanos(n: u128) Timestamp {
        return .{ .nanos = n };
    }

    /// Formats as YYYY-MM-DDTHH:MM:SS.nnnnnnnnnZ (RFC 3339 with nanoseconds)
    pub fn toRfc3339(self: Timestamp, buf: []u8) []const u8 {
        const parts = decompose(self.nanos);
        const result = std.fmt.bufPrint(buf, "{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}.{d:0>9}Z", .{
            parts.year, parts.month, parts.day,
            parts.hour, parts.min,   parts.sec,
            parts.nanosecond,
        }) catch buf[0..0];
        return result;
    }

    /// Formats as YYYYMMDD-HH:MM:SS.nnn (ISO 8601 / FIX UTCTimestamp style)
    pub fn toIso8601(self: Timestamp, buf: []u8) []const u8 {
        const parts = decompose(self.nanos);
        const ms = parts.nanosecond / 1_000_000;
        const result = std.fmt.bufPrint(buf, "{d:0>4}{d:0>2}{d:0>2}-{d:0>2}:{d:0>2}:{d:0>2}.{d:0>3}", .{
            parts.year, parts.month, parts.day,
            parts.hour, parts.min,   parts.sec,
            ms,
        }) catch buf[0..0];
        return result;
    }

    /// Formats as FIX UTCTimestamp YYYYMMDD-HH:MM:SS.nnn
    pub fn toFixUtc(self: Timestamp, buf: []u8) []const u8 {
        return self.toIso8601(buf);
    }

    /// Parses RFC 3339 string (e.g. "2024-01-15T10:30:00.000000000Z")
    pub fn fromRfc3339(s: []const u8) !Timestamp {
        if (s.len < 20) return error.InvalidFormat;
        // Expect: YYYY-MM-DDTHH:MM:SS[.nnnnnnnnn]Z
        const year = try parseIntN(s[0..4]);
        if (s[4] != '-') return error.InvalidFormat;
        const month = try parseIntN(s[5..7]);
        if (s[7] != '-') return error.InvalidFormat;
        const day = try parseIntN(s[8..10]);
        if (s[10] != 'T') return error.InvalidFormat;
        const hour = try parseIntN(s[11..13]);
        if (s[13] != ':') return error.InvalidFormat;
        const min = try parseIntN(s[14..16]);
        if (s[16] != ':') return error.InvalidFormat;
        const sec = try parseIntN(s[17..19]);

        var nanosecond: u128 = 0;
        var idx: usize = 19;
        if (idx < s.len and s[idx] == '.') {
            idx += 1;
            const frac_start = idx;
            while (idx < s.len and s[idx] >= '0' and s[idx] <= '9') : (idx += 1) {}
            const frac_digits = idx - frac_start;
            const frac = try parseIntN(s[frac_start..idx]);
            // Normalize to nanoseconds
            var multiplier: u128 = 1;
            var pad = frac_digits;
            while (pad < 9) : (pad += 1) multiplier *= 10;
            var divisor: u128 = 1;
            while (pad > 9) : (pad -= 1) divisor *= 10;
            nanosecond = (frac * multiplier) / divisor;
        }
        if (idx < s.len and (s[idx] == 'Z' or s[idx] == 'z')) idx += 1;

        const epoch_seconds = dateToUnixSeconds(year, month, day, hour, min, sec);
        return .{ .nanos = epoch_seconds * 1_000_000_000 + nanosecond };
    }

    const DateParts = struct {
        year: u32,
        month: u32,
        day: u32,
        hour: u32,
        min: u32,
        sec: u32,
        nanosecond: u32,
    };

    fn decompose(nanos: u128) DateParts {
        const total_secs: u64 = @intCast(nanos / 1_000_000_000);
        const ns: u32 = @intCast(nanos % 1_000_000_000);

        // Convert Unix seconds to date/time components
        const days: u64 = total_secs / 86400;
        const time_of_day: u64 = total_secs % 86400;
        const hour: u32 = @intCast(time_of_day / 3600);
        const min: u32 = @intCast((time_of_day % 3600) / 60);
        const sec: u32 = @intCast(time_of_day % 60);

        // Civil calendar from days since Unix epoch (Jan 1, 1970)
        // Algorithm from Howard Hinnant's civil_from_days
        const z: i64 = @intCast(days);
        const shifted_z = z + 719468;
        const era: i64 = @divFloor(shifted_z, 146097);
        const doe: u64 = @intCast(shifted_z - era * 146097);
        const yoe: u64 = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
        const y: i64 = @intCast(yoe);
        const year_civil: i64 = y + era * 400;
        const doy: u64 = doe - (365 * yoe + yoe / 4 - yoe / 100);
        const mp: u64 = (5 * doy + 2) / 153;
        const day: u32 = @intCast(doy - (153 * mp + 2) / 5 + 1);
        const month: u32 = @intCast(if (mp < 10) mp + 3 else mp - 9);
        const year: u32 = @intCast(year_civil + @as(i64, if (month <= 2) 1 else 0));

        return .{
            .year = year,
            .month = month,
            .day = day,
            .hour = hour,
            .min = min,
            .sec = sec,
            .nanosecond = ns,
        };
    }

    fn parseIntN(s: []const u8) !u128 {
        var result: u128 = 0;
        for (s) |c| {
            if (c < '0' or c > '9') return error.InvalidChar;
            result = result * 10 + (c - '0');
        }
        return result;
    }

    fn dateToUnixSeconds(year: u128, month: u128, day: u128, hour: u128, min: u128, sec: u128) u128 {
        // Days since epoch using civil calendar
        const y: i64 = @intCast(if (month <= 2) year - 1 else year);
        const m: i64 = @intCast(month);
        const d: i64 = @intCast(day);
        const era: i64 = @divFloor(y, 400);
        const yoe: i64 = y - era * 400;
        const doy: i64 = @divFloor(153 * (m + (if (m > 2) @as(i64, -3) else @as(i64, 9))) + 2, 5) + d - 1;
        const doe: i64 = yoe * 365 + @divFloor(yoe, 4) - @divFloor(yoe, 100) + doy;
        const days: i64 = era * 146097 + doe - 719468;
        const total_secs: u128 = @intCast(days);
        return total_secs * 86400 + hour * 3600 + min * 60 + sec;
    }
};
