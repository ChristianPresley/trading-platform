const std = @import("std");

pub fn main() !void {
    const stdout = std.fs.File.stdout().deprecatedWriter();
    try stdout.print("Trading Desk v0.1.0\n", .{});
}

test "desk_smoke" {}
