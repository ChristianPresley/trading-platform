// URL parsing: scheme, host, port, path, query

const std = @import("std");

pub const Url = struct {
    scheme: []const u8,
    host: []const u8,
    port: u16,
    path: []const u8,
    query: ?[]const u8,
};

pub const ParseError = error{
    MissingScheme,
    InvalidScheme,
    MissingHost,
    InvalidPort,
};

/// Parse a URL string into its components.
/// The returned Url references slices into the input string (no allocation).
pub fn parse(url: []const u8) ParseError!Url {
    // Find scheme separator "://"
    const scheme_end = std.mem.indexOf(u8, url, "://") orelse return error.MissingScheme;
    const scheme = url[0..scheme_end];

    // Validate scheme
    if (!std.mem.eql(u8, scheme, "http") and !std.mem.eql(u8, scheme, "https") and
        !std.mem.eql(u8, scheme, "ws") and !std.mem.eql(u8, scheme, "wss"))
    {
        return error.InvalidScheme;
    }

    const default_port: u16 = if (std.mem.eql(u8, scheme, "https") or std.mem.eql(u8, scheme, "wss")) 443 else 80;

    const after_scheme = url[scheme_end + 3 ..];
    if (after_scheme.len == 0) return error.MissingHost;

    // Find path start
    const path_start = std.mem.indexOfAny(u8, after_scheme, "/?#") orelse after_scheme.len;
    const host_port_str = after_scheme[0..path_start];

    // Separate host and port
    var host: []const u8 = host_port_str;
    var port: u16 = default_port;

    if (std.mem.lastIndexOf(u8, host_port_str, ":")) |colon_idx| {
        // Check it's not an IPv6 address bracket
        const potential_port = host_port_str[colon_idx + 1 ..];
        const parsed_port = std.fmt.parseInt(u16, potential_port, 10) catch return error.InvalidPort;
        host = host_port_str[0..colon_idx];
        port = parsed_port;
    }

    if (host.len == 0) return error.MissingHost;

    // Find path
    var path: []const u8 = "/";
    var query: ?[]const u8 = null;

    if (path_start < after_scheme.len) {
        const remaining = after_scheme[path_start..];
        // Split on '?'
        if (std.mem.indexOf(u8, remaining, "?")) |q_idx| {
            path = remaining[0..q_idx];
            const q_part = remaining[q_idx + 1 ..];
            // Split off fragment '#'
            if (std.mem.indexOf(u8, q_part, "#")) |frag_idx| {
                query = q_part[0..frag_idx];
            } else {
                query = q_part;
            }
        } else if (std.mem.indexOf(u8, remaining, "#")) |frag_idx| {
            path = remaining[0..frag_idx];
        } else {
            path = remaining;
        }
        if (path.len == 0) path = "/";
    }

    return Url{
        .scheme = scheme,
        .host = host,
        .port = port,
        .path = path,
        .query = query,
    };
}
