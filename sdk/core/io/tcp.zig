// TCP connection management
// Non-blocking TCP sockets with hostname resolution

const std = @import("std");

pub const TcpConnection = struct {
    socket: std.posix.socket_t,
    allocator: std.mem.Allocator,

    pub fn connect(allocator: std.mem.Allocator, host: []const u8, port: u16) !TcpConnection {
        // Resolve hostname
        const address_list = try std.net.getAddressList(allocator, host, port);
        defer address_list.deinit();

        if (address_list.addrs.len == 0) return error.HostNotFound;

        var last_err: anyerror = error.HostNotFound;
        for (address_list.addrs) |addr| {
            const sock = std.posix.socket(addr.any.family, std.posix.SOCK.STREAM, std.posix.IPPROTO.TCP) catch |err| {
                last_err = err;
                continue;
            };

            std.posix.connect(sock, &addr.any, addr.getOsSockLen()) catch |err| {
                std.posix.close(sock);
                last_err = err;
                continue;
            };

            return TcpConnection{
                .socket = sock,
                .allocator = allocator,
            };
        }
        return last_err;
    }

    pub fn read(self: *TcpConnection, buf: []u8) !usize {
        return std.posix.read(self.socket, buf);
    }

    pub fn write(self: *TcpConnection, data: []const u8) !usize {
        return std.posix.write(self.socket, data);
    }

    pub fn close(self: *TcpConnection) void {
        std.posix.close(self.socket);
    }

    pub fn setNoDelay(self: *TcpConnection, enabled: bool) !void {
        const val: i32 = if (enabled) 1 else 0;
        try std.posix.setsockopt(
            self.socket,
            std.posix.IPPROTO.TCP,
            std.posix.TCP.NODELAY,
            std.mem.asBytes(&val),
        );
    }

    pub fn fd(self: *const TcpConnection) std.posix.fd_t {
        return self.socket;
    }
};
