// X.509 certificate parsing and chain validation
// Implements DER/ASN.1 parsing for certificate fields

const std = @import("std");

// ASN.1 tag constants
const TAG_SEQUENCE: u8 = 0x30;
const TAG_SET: u8 = 0x31;
const TAG_INTEGER: u8 = 0x02;
const TAG_BIT_STRING: u8 = 0x03;
const TAG_OCTET_STRING: u8 = 0x04;
const TAG_OID: u8 = 0x06;
const TAG_UTF8_STRING: u8 = 0x0C;
const TAG_PRINTABLE_STRING: u8 = 0x13;
const TAG_IA5_STRING: u8 = 0x16;
const TAG_UTC_TIME: u8 = 0x17;
const TAG_GENERALIZED_TIME: u8 = 0x18;
const TAG_CONTEXT_0: u8 = 0xA0;
const TAG_CONTEXT_3: u8 = 0xA3;
const TAG_BOOLEAN: u8 = 0x01;

pub const PublicKeyAlgorithm = enum {
    rsa,
    ecdsa_p256,
    ecdsa_p384,
    ed25519,
    unknown,
};

pub const PublicKey = struct {
    algorithm: PublicKeyAlgorithm,
    key_data: []const u8,
};

pub const Name = struct {
    common_name: ?[]const u8,
    organization: ?[]const u8,
    country: ?[]const u8,
    raw: []const u8,
};

pub const Validity = struct {
    not_before: i64,
    not_after: i64,
};

pub const SubjectAltName = struct {
    dns_names: [][]const u8,
};

pub const Certificate = struct {
    allocator: std.mem.Allocator,
    subject: Name,
    issuer: Name,
    public_key: PublicKey,
    validity: Validity,
    serial: []const u8,
    signature_algorithm: []const u8,
    signature: []const u8,
    subject_alt_names: ?SubjectAltName,
    is_ca: bool,
    der: []const u8,

    pub fn deinit(self: *Certificate) void {
        if (self.subject_alt_names) |san| {
            self.allocator.free(san.dns_names);
        }
        self.allocator.free(self.der);
    }
};

pub const DerParser = struct {
    data: []const u8,
    pos: usize,

    pub fn init(data: []const u8) DerParser {
        return .{ .data = data, .pos = 0 };
    }

    pub fn remaining(self: *const DerParser) usize {
        return self.data.len - self.pos;
    }

    pub fn readByte(self: *DerParser) !u8 {
        if (self.pos >= self.data.len) return error.Truncated;
        const b = self.data[self.pos];
        self.pos += 1;
        return b;
    }

    pub fn readLength(self: *DerParser) !usize {
        const first = try self.readByte();
        if (first & 0x80 == 0) return first;
        const num_bytes = first & 0x7F;
        if (num_bytes == 0 or num_bytes > 4) return error.InvalidLength;
        var len: usize = 0;
        for (0..num_bytes) |_| {
            len = (len << 8) | try self.readByte();
        }
        return len;
    }

    pub fn readTlv(self: *DerParser, expected_tag: u8) ![]const u8 {
        const tag = try self.readByte();
        if (tag != expected_tag) return error.UnexpectedTag;
        const len = try self.readLength();
        if (len > self.remaining()) return error.Truncated;
        const slice = self.data[self.pos .. self.pos + len];
        self.pos += len;
        return slice;
    }

    pub fn readTlvAnyTag(self: *DerParser) !struct { tag: u8, value: []const u8 } {
        const tag = try self.readByte();
        const len = try self.readLength();
        if (len > self.remaining()) return error.Truncated;
        const slice = self.data[self.pos .. self.pos + len];
        self.pos += len;
        return .{ .tag = tag, .value = slice };
    }

    pub fn enterSequence(self: *DerParser) !DerParser {
        const contents = try self.readTlv(TAG_SEQUENCE);
        return DerParser.init(contents);
    }

    pub fn skipTlv(self: *DerParser) !void {
        _ = try self.readByte(); // tag
        const len = try self.readLength();
        if (len > self.remaining()) return error.Truncated;
        self.pos += len;
    }

    pub fn peekTag(self: *const DerParser) ?u8 {
        if (self.pos >= self.data.len) return null;
        return self.data[self.pos];
    }
};

fn parseTime(time_str: []const u8, generalized: bool) !i64 {
    if (generalized) {
        if (time_str.len < 14) return error.InvalidTime;
        const year = std.fmt.parseInt(u32, time_str[0..4], 10) catch return error.InvalidTime;
        const month = std.fmt.parseInt(u32, time_str[4..6], 10) catch return error.InvalidTime;
        const day = std.fmt.parseInt(u32, time_str[6..8], 10) catch return error.InvalidTime;
        const hour = std.fmt.parseInt(u32, time_str[8..10], 10) catch return error.InvalidTime;
        const minute = std.fmt.parseInt(u32, time_str[10..12], 10) catch return error.InvalidTime;
        const second = std.fmt.parseInt(u32, time_str[12..14], 10) catch return error.InvalidTime;
        return dateToUnix(year, month, day, hour, minute, second);
    } else {
        if (time_str.len < 12) return error.InvalidTime;
        var year = std.fmt.parseInt(u32, time_str[0..2], 10) catch return error.InvalidTime;
        year = if (year >= 50) 1900 + year else 2000 + year;
        const month = std.fmt.parseInt(u32, time_str[2..4], 10) catch return error.InvalidTime;
        const day = std.fmt.parseInt(u32, time_str[4..6], 10) catch return error.InvalidTime;
        const hour = std.fmt.parseInt(u32, time_str[6..8], 10) catch return error.InvalidTime;
        const minute = std.fmt.parseInt(u32, time_str[8..10], 10) catch return error.InvalidTime;
        const second = std.fmt.parseInt(u32, time_str[10..12], 10) catch return error.InvalidTime;
        return dateToUnix(year, month, day, hour, minute, second);
    }
}

fn dateToUnix(year: u32, month: u32, day: u32, hour: u32, minute: u32, second: u32) i64 {
    const y: i64 = @intCast(year);
    const m: i64 = @intCast(month);
    const d: i64 = @intCast(day);

    const a = @divFloor(14 - m, 12);
    const yy = y + 4800 - a;
    const mm = m + 12 * a - 3;
    const jdn = d + @divFloor(153 * mm + 2, 5) + 365 * yy + @divFloor(yy, 4) - @divFloor(yy, 100) + @divFloor(yy, 400) - 32045;
    const unix_epoch_jdn: i64 = 2440588;
    const days = jdn - unix_epoch_jdn;

    return days * 86400 +
        @as(i64, @intCast(hour)) * 3600 +
        @as(i64, @intCast(minute)) * 60 +
        @as(i64, @intCast(second));
}

fn parseName(raw: []const u8) Name {
    var common_name: ?[]const u8 = null;
    var organization: ?[]const u8 = null;
    var country: ?[]const u8 = null;

    var p = DerParser.init(raw);
    while (p.remaining() > 0) {
        const rdn_tag = p.peekTag() orelse break;
        if (rdn_tag != TAG_SET) break;
        const rdn_contents = p.readTlv(TAG_SET) catch break;
        var rdn = DerParser.init(rdn_contents);
        while (rdn.remaining() > 0) {
            const attr_contents = rdn.readTlv(TAG_SEQUENCE) catch break;
            var attr = DerParser.init(attr_contents);
            const oid = attr.readTlv(TAG_OID) catch break;
            const tv = attr.readTlvAnyTag() catch break;

            // commonName: 2.5.4.3
            if (oid.len == 3 and oid[0] == 0x55 and oid[1] == 0x04 and oid[2] == 0x03) {
                common_name = tv.value;
            }
            // organizationName: 2.5.4.10
            if (oid.len == 3 and oid[0] == 0x55 and oid[1] == 0x04 and oid[2] == 0x0A) {
                organization = tv.value;
            }
            // countryName: 2.5.4.6
            if (oid.len == 3 and oid[0] == 0x55 and oid[1] == 0x04 and oid[2] == 0x06) {
                country = tv.value;
            }
        }
    }

    return Name{
        .common_name = common_name,
        .organization = organization,
        .country = country,
        .raw = raw,
    };
}

/// Parse a DER-encoded X.509 certificate.
pub fn parse(allocator: std.mem.Allocator, der: []const u8) !Certificate {
    const der_copy = try allocator.dupe(u8, der);
    errdefer allocator.free(der_copy);

    var p = DerParser.init(der_copy);
    var cert_seq = try p.enterSequence();
    var tbs_seq = try cert_seq.enterSequence();

    var serial: []const u8 = &.{};
    var subject: Name = .{ .common_name = null, .organization = null, .country = null, .raw = &.{} };
    var issuer: Name = .{ .common_name = null, .organization = null, .country = null, .raw = &.{} };
    var validity: Validity = .{ .not_before = 0, .not_after = 0 };
    var public_key = PublicKey{ .algorithm = .unknown, .key_data = &.{} };
    var is_ca = false;
    var subject_alt_names: ?SubjectAltName = null;

    // Optional version [0]
    if (tbs_seq.peekTag() == TAG_CONTEXT_0) {
        tbs_seq.skipTlv() catch {};
    }

    // serialNumber INTEGER
    serial = tbs_seq.readTlv(TAG_INTEGER) catch &.{};

    // signatureAlgorithm SEQUENCE
    tbs_seq.skipTlv() catch {};

    // issuer Name (SEQUENCE of SETs)
    const issuer_raw = tbs_seq.readTlv(TAG_SEQUENCE) catch &.{};
    issuer = parseName(issuer_raw);

    // validity Validity
    parse_validity: {
        var val_seq = tbs_seq.enterSequence() catch break :parse_validity;
        if (val_seq.peekTag() == TAG_UTC_TIME) {
            const ts = val_seq.readTlv(TAG_UTC_TIME) catch break :parse_validity;
            validity.not_before = parseTime(ts, false) catch 0;
        } else if (val_seq.peekTag() == TAG_GENERALIZED_TIME) {
            const ts = val_seq.readTlv(TAG_GENERALIZED_TIME) catch break :parse_validity;
            validity.not_before = parseTime(ts, true) catch 0;
        }
        if (val_seq.peekTag() == TAG_UTC_TIME) {
            const ts = val_seq.readTlv(TAG_UTC_TIME) catch break :parse_validity;
            validity.not_after = parseTime(ts, false) catch 0;
        } else if (val_seq.peekTag() == TAG_GENERALIZED_TIME) {
            const ts = val_seq.readTlv(TAG_GENERALIZED_TIME) catch break :parse_validity;
            validity.not_after = parseTime(ts, true) catch 0;
        }
    }

    // subject Name
    const subject_raw = tbs_seq.readTlv(TAG_SEQUENCE) catch &.{};
    subject = parseName(subject_raw);

    // subjectPublicKeyInfo
    parse_spki: {
        var spki_seq = tbs_seq.enterSequence() catch break :parse_spki;
        var algo_seq = spki_seq.enterSequence() catch break :parse_spki;
        const algo_oid = algo_seq.readTlv(TAG_OID) catch &.{};
        // RSA: 1.2.840.113549.1.1.1
        if (algo_oid.len == 9 and algo_oid[0] == 0x2a and algo_oid[1] == 0x86 and
            algo_oid[2] == 0x48 and algo_oid[3] == 0x86 and algo_oid[4] == 0xf7 and
            algo_oid[5] == 0x0d and algo_oid[6] == 0x01 and algo_oid[7] == 0x01)
        {
            public_key.algorithm = .rsa;
        } else if (algo_oid.len == 7 and algo_oid[0] == 0x2a and algo_oid[1] == 0x86 and
            algo_oid[2] == 0x48 and algo_oid[3] == 0xce and algo_oid[4] == 0x3d)
        {
            public_key.algorithm = .ecdsa_p256;
        }
        public_key.key_data = spki_seq.readTlv(TAG_BIT_STRING) catch &.{};
    }

    // Skip issuerUniqueID [1], subjectUniqueID [2], then look for extensions [3]
    while (tbs_seq.remaining() > 0) {
        const tag = tbs_seq.peekTag() orelse break;
        if (tag == TAG_CONTEXT_3) {
            parse_extensions: {
                const ext_wrapper = tbs_seq.readTlv(TAG_CONTEXT_3) catch break :parse_extensions;
                var ext_seq_p = DerParser.init(ext_wrapper);
                const ext_seq_contents = ext_seq_p.readTlv(TAG_SEQUENCE) catch break :parse_extensions;
                var exts = DerParser.init(ext_seq_contents);
                while (exts.remaining() > 0) {
                    const ext_contents = exts.readTlv(TAG_SEQUENCE) catch break;
                    var ext = DerParser.init(ext_contents);
                    const ext_oid = ext.readTlv(TAG_OID) catch break;

                    // Skip optional critical BOOLEAN
                    if (ext.peekTag() == TAG_BOOLEAN) {
                        ext.skipTlv() catch {};
                    }

                    // Basic Constraints OID: 2.5.29.19
                    if (ext_oid.len == 3 and ext_oid[0] == 0x55 and ext_oid[1] == 0x1d and ext_oid[2] == 0x13) {
                        const bc_bytes = ext.readTlv(TAG_OCTET_STRING) catch continue;
                        var bc_p = DerParser.init(bc_bytes);
                        var bc_seq = bc_p.enterSequence() catch continue;
                        if (bc_seq.peekTag() == TAG_BOOLEAN) {
                            const ca_val = bc_seq.readTlv(TAG_BOOLEAN) catch continue;
                            is_ca = ca_val.len > 0 and ca_val[0] != 0;
                        }
                    }

                    // Subject Alternative Name OID: 2.5.29.17
                    if (ext_oid.len == 3 and ext_oid[0] == 0x55 and ext_oid[1] == 0x1d and ext_oid[2] == 0x11) {
                        const san_bytes = ext.readTlv(TAG_OCTET_STRING) catch continue;
                        var san_p = DerParser.init(san_bytes);
                        const san_seq_content = san_p.readTlv(TAG_SEQUENCE) catch continue;
                        var san_seq = DerParser.init(san_seq_content);

                        var dns_list: std.ArrayList([]const u8) = .empty;
                        while (san_seq.remaining() > 0) {
                            const gn = san_seq.readTlvAnyTag() catch break;
                            // dNSName [2] IMPLICIT IA5String
                            if (gn.tag == 0x82) {
                                try dns_list.append(allocator, gn.value);
                            }
                        }
                        subject_alt_names = SubjectAltName{
                            .dns_names = try dns_list.toOwnedSlice(allocator),
                        };
                    }
                }
            }
        } else {
            tbs_seq.skipTlv() catch break;
        }
    }

    // signatureAlgorithm
    const sig_algo = cert_seq.readTlv(TAG_SEQUENCE) catch &.{};
    // signature BIT STRING
    const signature = cert_seq.readTlv(TAG_BIT_STRING) catch &.{};

    return Certificate{
        .allocator = allocator,
        .subject = subject,
        .issuer = issuer,
        .public_key = public_key,
        .validity = validity,
        .serial = serial,
        .signature_algorithm = sig_algo,
        .signature = signature,
        .subject_alt_names = subject_alt_names,
        .is_ca = is_ca,
        .der = der_copy,
    };
}

fn hostnameMatches(cert_name: []const u8, hostname: []const u8) bool {
    if (std.mem.eql(u8, cert_name, hostname)) return true;
    // Wildcard: *.example.com
    if (cert_name.len > 2 and cert_name[0] == '*' and cert_name[1] == '.') {
        const suffix = cert_name[1..]; // ".example.com"
        if (hostname.len > suffix.len) {
            const host_suffix = hostname[hostname.len - suffix.len ..];
            // Ensure no dot in the host part (wildcard only matches one label)
            const host_label = hostname[0 .. hostname.len - suffix.len];
            if (std.mem.indexOf(u8, host_label, ".") == null) {
                return std.mem.eql(u8, host_suffix, suffix);
            }
        }
    }
    return false;
}

pub const RootStore = struct {
    trusted_subjects: []const []const u8,

    pub fn init() RootStore {
        return .{ .trusted_subjects = &.{} };
    }
};

pub const VerifyError = error{
    ChainTooShort,
    ExpiredCertificate,
    HostnameMismatch,
    SelfSignedCertificate,
    NotACertificateAuthority,
    UntrustedRoot,
};

pub fn verifyChain(
    chain: []const Certificate,
    root_store: *const RootStore,
    hostname: []const u8,
) VerifyError!void {
    if (chain.len == 0) return error.ChainTooShort;

    const now = blk: {
        var ts_: std.os.linux.timespec = undefined;
        _ = std.os.linux.clock_gettime(.REALTIME, &ts_);
        break :blk ts_.sec;
    };
    const leaf = &chain[0];

    // Hostname check
    var hostname_ok = false;
    if (leaf.subject_alt_names) |san| {
        for (san.dns_names) |dns| {
            if (hostnameMatches(dns, hostname)) {
                hostname_ok = true;
                break;
            }
        }
    }
    if (!hostname_ok) {
        if (leaf.subject.common_name) |cn| {
            hostname_ok = hostnameMatches(cn, hostname);
        }
    }
    if (!hostname_ok) return error.HostnameMismatch;

    // Expiry check
    for (chain) |cert| {
        if (now < cert.validity.not_before or now > cert.validity.not_after) {
            return error.ExpiredCertificate;
        }
    }

    // CA flag on intermediates
    if (chain.len > 1) {
        for (chain[1..]) |cert| {
            if (!cert.is_ca) return error.NotACertificateAuthority;
        }
    }

    // Self-signed rejection (single cert, issuer == subject)
    if (chain.len == 1) {
        const c = &chain[0];
        if (std.mem.eql(u8, c.subject.raw, c.issuer.raw)) {
            return error.SelfSignedCertificate;
        }
    }

    // Root trust
    if (root_store.trusted_subjects.len > 0) {
        const root = &chain[chain.len - 1];
        var trusted = false;
        for (root_store.trusted_subjects) |subj| {
            if (std.mem.eql(u8, subj, root.subject.raw)) {
                trusted = true;
                break;
            }
        }
        if (!trusted) return error.UntrustedRoot;
    }
}
