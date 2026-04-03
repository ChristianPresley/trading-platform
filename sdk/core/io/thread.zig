// Thread pinning utilities using sched_setaffinity

const std = @import("std");

/// Pin the current thread to a specific CPU core via sched_setaffinity.
pub fn pinToCore(core_id: usize) !void {
    // cpu_set_t is 128 bytes on Linux
    var cpu_set = std.mem.zeroes([128]u8);
    // Set the bit for core_id
    const byte_index = core_id / 8;
    const bit_index: u3 = @intCast(core_id % 8);
    if (byte_index >= cpu_set.len) return error.CoreIdTooLarge;
    cpu_set[byte_index] |= @as(u8, 1) << bit_index;

    const rc = std.os.linux.syscall3(
        .sched_setaffinity,
        0, // pid=0 means current thread
        cpu_set.len,
        @intFromPtr(&cpu_set),
    );
    switch (std.posix.errno(rc)) {
        .SUCCESS => {},
        .INVAL => return error.InvalidCore,
        .PERM => return error.PermissionDenied,
        .SRCH => return error.ThreadNotFound,
        else => |e| return std.posix.unexpectedErrno(e),
    }
}

const SpawnContext = struct {
    core_id: usize,
    func_ptr: *const anyopaque,
    args_ptr: *const anyopaque,
};

/// Spawn a thread and pin it to the specified core.
pub fn spawnPinned(core_id: usize, comptime func: anytype, args: anytype) !std.Thread {
    const ArgsType = @TypeOf(args);
    const Wrapper = struct {
        fn run(cid: usize, a: ArgsType) void {
            pinToCore(cid) catch {};
            @call(.auto, func, a);
        }
    };
    return std.Thread.spawn(.{}, Wrapper.run, .{ core_id, args });
}
