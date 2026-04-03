const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll("Trading Desk v0.1.0\n");
}

test "desk_smoke" {}
