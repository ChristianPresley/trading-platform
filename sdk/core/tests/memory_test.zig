const std = @import("std");
const memory = @import("memory");

test "PoolAllocator: allocate all slots then verify full" {
    var pool = try memory.PoolAllocator.init(std.testing.allocator, 128, 4);
    defer pool.deinit();

    const alloc = pool.allocator();
    const a = try alloc.alloc(u8, 64);
    const b = try alloc.alloc(u8, 64);
    const c = try alloc.alloc(u8, 64);
    const d = try alloc.alloc(u8, 64);

    // All slots used — next allocation should fail
    try std.testing.expectError(error.OutOfMemory, alloc.alloc(u8, 64));

    // Free one slot, then re-allocate
    alloc.free(a);
    const e = try alloc.alloc(u8, 64);
    alloc.free(e);

    alloc.free(b);
    alloc.free(c);
    alloc.free(d);
}

test "PoolAllocator: alignment is 64 bytes" {
    var pool = try memory.PoolAllocator.init(std.testing.allocator, 64, 8);
    defer pool.deinit();

    const alloc = pool.allocator();
    const ptr = try alloc.alloc(u8, 64);
    try std.testing.expect(@intFromPtr(ptr.ptr) % memory.cache_line_size == 0);
    alloc.free(ptr);
}

test "ArenaAllocator: allocate, reset, re-allocate" {
    var arena = memory.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const alloc = arena.allocator();
    const buf1 = try alloc.alloc(u8, 1024);
    buf1[0] = 42;

    arena.reset();

    // After reset, can allocate again (may reuse memory)
    const buf2 = try alloc.alloc(u8, 1024);
    buf2[0] = 99;
}

test "ArenaAllocator: deinit frees all" {
    // Use std.testing.allocator to detect leaks
    var arena = memory.ArenaAllocator.init(std.testing.allocator);
    const alloc = arena.allocator();
    _ = try alloc.alloc(u8, 512);
    _ = try alloc.alloc(u8, 512);
    arena.deinit();
    // No leak expected (test allocator checks on deinit)
}
