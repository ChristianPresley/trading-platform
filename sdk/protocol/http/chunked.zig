// HTTP chunked transfer encoding decoder

const std = @import("std");

/// Decode chunked transfer encoding from a byte slice.
/// Returns a newly allocated slice containing the decoded body.
/// Caller must free the returned slice.
pub fn decode(allocator: std.mem.Allocator, data: []const u8) ![]const u8 {
    var result: std.ArrayList(u8) = .{};
    errdefer result.deinit(allocator);

    var pos: usize = 0;
    while (pos < data.len) {
        // Read chunk size line (hex number followed by \r\n or \n)
        const line_end = findLineEnd(data, pos) orelse return error.InvalidChunkedEncoding;
        const size_line = data[pos..line_end.end_of_digits];

        // Parse hex chunk size
        const chunk_size = std.fmt.parseInt(usize, size_line, 16) catch return error.InvalidChunkSize;
        pos = line_end.next;

        if (chunk_size == 0) {
            // Terminal chunk — skip optional trailers
            break;
        }

        // Read chunk data
        if (pos + chunk_size > data.len) return error.TruncatedChunk;
        try result.appendSlice(allocator, data[pos .. pos + chunk_size]);
        pos += chunk_size;

        // Skip trailing \r\n after chunk data
        if (pos < data.len and data[pos] == '\r') pos += 1;
        if (pos < data.len and data[pos] == '\n') pos += 1;
    }

    return result.toOwnedSlice(allocator);
}

const LineEnd = struct {
    end_of_digits: usize, // index of first char after hex digits (excludes extensions)
    next: usize, // index of first char of next line
};

fn findLineEnd(data: []const u8, start: usize) ?LineEnd {
    var i = start;
    // Find end of hex digits (stop at ';' for extensions or '\r'/'\n')
    const digits_end = blk: {
        while (i < data.len) {
            const c = data[i];
            if (c == '\r' or c == '\n' or c == ';') break :blk i;
            i += 1;
        }
        break :blk i;
    };
    // Skip to end of line
    while (i < data.len and data[i] != '\n') {
        i += 1;
    }
    if (i >= data.len) return null;
    i += 1; // skip '\n'
    return LineEnd{ .end_of_digits = digits_end, .next = i };
}

/// Decode chunked data from a generic reader (reads until 0-length chunk).
/// Returns allocated slice with decoded body.
pub fn decodeFromReader(allocator: std.mem.Allocator, reader: anytype) ![]const u8 {
    var result: std.ArrayList(u8) = .{};
    errdefer result.deinit(allocator);

    var line_buf: [128]u8 = undefined;

    while (true) {
        // Read chunk size line
        var line_len: usize = 0;
        while (line_len < line_buf.len) {
            const byte = reader.readByte() catch return error.ConnectionClosed;
            if (byte == '\n') break;
            if (byte != '\r') {
                line_buf[line_len] = byte;
                line_len += 1;
            }
        }
        const size_line = line_buf[0..line_len];

        // Strip chunk extensions (after ';')
        const semi = std.mem.indexOf(u8, size_line, ";") orelse size_line.len;
        const chunk_size = std.fmt.parseInt(usize, size_line[0..semi], 16) catch return error.InvalidChunkSize;

        if (chunk_size == 0) break;

        // Read chunk data
        const old_len = result.items.len;
        try result.resize(allocator, old_len + chunk_size);
        var read_so_far: usize = 0;
        while (read_so_far < chunk_size) {
            const n = reader.read(result.items[old_len + read_so_far ..]) catch return error.ConnectionClosed;
            if (n == 0) return error.ConnectionClosed;
            read_so_far += n;
        }

        // Skip trailing \r\n
        _ = reader.readByte() catch {}; // \r
        _ = reader.readByte() catch {}; // \n
    }

    return result.toOwnedSlice(allocator);
}
