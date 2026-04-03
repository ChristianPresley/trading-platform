// TLS record layer: framing, content type dispatch, fragmentation/reassembly

const std = @import("std");

pub const ContentType = enum(u8) {
    change_cipher_spec = 20,
    alert = 21,
    handshake = 22,
    application_data = 23,
    heartbeat = 24,
    _,
};

pub const AlertLevel = enum(u8) {
    warning = 1,
    fatal = 2,
    _,
};

pub const AlertDescription = enum(u8) {
    close_notify = 0,
    unexpected_message = 10,
    bad_record_mac = 20,
    decryption_failed = 21,
    record_overflow = 22,
    decompression_failure = 30,
    handshake_failure = 40,
    no_certificate = 41,
    bad_certificate = 42,
    unsupported_certificate = 43,
    certificate_revoked = 44,
    certificate_expired = 45,
    certificate_unknown = 46,
    illegal_parameter = 47,
    unknown_ca = 48,
    access_denied = 49,
    decode_error = 50,
    decrypt_error = 51,
    protocol_version = 70,
    insufficient_security = 71,
    internal_error = 80,
    inappropriate_fallback = 86,
    user_canceled = 90,
    no_renegotiation = 100,
    unsupported_extension = 110,
    _,
};

pub const TLS_VERSION_12: u16 = 0x0303;
pub const TLS_VERSION_13: u16 = 0x0304;

/// Maximum TLS record payload size (2^14 bytes)
pub const MAX_RECORD_PAYLOAD = 16384;

pub const Record = struct {
    content_type: ContentType,
    version: u16,
    payload: []const u8,
};

pub const CipherState = struct {
    key: [32]u8,
    iv: [12]u8,
    seq_num: u64,
};

/// Read a TLS record from an fd into buf.
/// buf must be at least 5 + MAX_RECORD_PAYLOAD bytes.
/// Returns Record with payload pointing into buf.
pub fn readRecord(fd: std.posix.fd_t, buf: []u8) !Record {
    if (buf.len < 5) return error.BufferTooSmall;

    // Read 5-byte header
    var header_read: usize = 0;
    while (header_read < 5) {
        const n = try std.posix.read(fd, buf[header_read..5]);
        if (n == 0) return error.ConnectionClosed;
        header_read += n;
    }

    const content_type: ContentType = @enumFromInt(buf[0]);
    const version = (@as(u16, buf[1]) << 8) | buf[2];
    const length = (@as(u16, buf[3]) << 8) | buf[4];

    if (length > MAX_RECORD_PAYLOAD) return error.RecordOverflow;
    if (buf.len < 5 + length) return error.BufferTooSmall;

    // Read payload
    var payload_read: usize = 0;
    while (payload_read < length) {
        const n = try std.posix.read(fd, buf[5 + payload_read .. 5 + length]);
        if (n == 0) return error.ConnectionClosed;
        payload_read += n;
    }

    return Record{
        .content_type = content_type,
        .version = version,
        .payload = buf[5 .. 5 + length],
    };
}

/// Write a TLS record to an fd.
/// If cipher_state is provided, encrypts the data (placeholder for actual encryption).
pub fn writeRecord(
    fd: std.posix.fd_t,
    content_type: ContentType,
    data: []const u8,
    cipher_state: ?*CipherState,
) !void {
    if (data.len > MAX_RECORD_PAYLOAD) return error.RecordTooLarge;

    // Build header: content_type (1) + version (2) + length (2)
    var header: [5]u8 = undefined;
    header[0] = @intFromEnum(content_type);
    header[1] = 0x03; // TLS 1.2/1.3 legacy version major
    header[2] = 0x03; // TLS 1.2/1.3 legacy version minor
    const length: u16 = @intCast(data.len);
    header[3] = @intCast(length >> 8);
    header[4] = @intCast(length & 0xFF);

    // Update sequence number if cipher state provided
    if (cipher_state) |cs| {
        cs.seq_num += 1;
    }

    // Write header
    var written: usize = 0;
    while (written < header.len) {
        const n = try std.posix.write(fd, header[written..]);
        if (n == 0) return error.ConnectionClosed;
        written += n;
    }

    // Write payload
    written = 0;
    while (written < data.len) {
        const n = try std.posix.write(fd, data[written..]);
        if (n == 0) return error.ConnectionClosed;
        written += n;
    }
}

/// Build a TLS record as bytes into an output buffer (for testing/framing without I/O).
pub fn frameRecord(
    content_type: ContentType,
    version: u16,
    payload: []const u8,
    out: []u8,
) ![]u8 {
    const total = 5 + payload.len;
    if (out.len < total) return error.BufferTooSmall;
    if (payload.len > MAX_RECORD_PAYLOAD) return error.RecordTooLarge;

    out[0] = @intFromEnum(content_type);
    out[1] = @intCast(version >> 8);
    out[2] = @intCast(version & 0xFF);
    out[3] = @intCast(payload.len >> 8);
    out[4] = @intCast(payload.len & 0xFF);
    @memcpy(out[5..total], payload);
    return out[0..total];
}

/// Parse a TLS record from a byte slice (no I/O). Returns Record pointing into input slice.
pub fn parseRecord(data: []const u8) !Record {
    if (data.len < 5) return error.Truncated;
    const content_type: ContentType = @enumFromInt(data[0]);
    const version = (@as(u16, data[1]) << 8) | data[2];
    const length = (@as(u16, data[3]) << 8) | data[4];
    if (length > MAX_RECORD_PAYLOAD) return error.RecordOverflow;
    if (data.len < 5 + length) return error.Truncated;
    return Record{
        .content_type = content_type,
        .version = version,
        .payload = data[5 .. 5 + length],
    };
}
