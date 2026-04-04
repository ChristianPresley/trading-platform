const std = @import("std");

pub const cache_line_size: usize = 64;

/// Fixed-slot pool allocator backed by a contiguous slab, 64-byte aligned slots.
pub const PoolAllocator = struct {
    backing: std.mem.Allocator,
    slab: []align(cache_line_size) u8,
    slot_size: usize,
    slot_count: usize,
    free_list: ?*FreeNode,
    allocated: usize,

    const FreeNode = struct {
        next: ?*FreeNode,
    };

    pub fn init(backing: std.mem.Allocator, slot_size: usize, slot_count: usize) !PoolAllocator {
        // Ensure slot_size is at least large enough for a FreeNode pointer and aligned
        const effective_slot_size = @max(slot_size, @sizeOf(FreeNode));
        const aligned_slot_size = std.mem.alignForward(usize, effective_slot_size, cache_line_size);
        const slab = try backing.alignedAlloc(u8, std.mem.Alignment.fromByteUnits(cache_line_size), aligned_slot_size * slot_count);

        var pool = PoolAllocator{
            .backing = backing,
            .slab = slab,
            .slot_size = aligned_slot_size,
            .slot_count = slot_count,
            .free_list = null,
            .allocated = 0,
        };

        // Build free list in reverse order so first allocation returns slot 0
        var i: usize = slot_count;
        while (i > 0) {
            i -= 1;
            const slot_ptr: *FreeNode = @ptrCast(@alignCast(&slab[i * aligned_slot_size]));
            slot_ptr.next = pool.free_list;
            pool.free_list = slot_ptr;
        }

        return pool;
    }

    pub fn deinit(self: *PoolAllocator) void {
        self.backing.free(self.slab);
    }

    pub fn allocator(self: *PoolAllocator) std.mem.Allocator {
        return .{
            .ptr = self,
            .vtable = &vtable,
        };
    }

    fn alloc(ctx: *anyopaque, n: usize, alignment: std.mem.Alignment, ret_addr: usize) ?[*]u8 {
        _ = ret_addr;
        const self: *PoolAllocator = @ptrCast(@alignCast(ctx));
        const align_bytes = alignment.toByteUnits();
        if (n > self.slot_size or align_bytes > cache_line_size) return null;
        const node = self.free_list orelse return null;
        self.free_list = node.next;
        self.allocated += 1;
        return @ptrCast(node);
    }

    fn resize(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) bool {
        _ = alignment;
        _ = ret_addr;
        _ = buf;
        const self: *PoolAllocator = @ptrCast(@alignCast(ctx));
        return new_len <= self.slot_size;
    }

    fn free(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, ret_addr: usize) void {
        _ = alignment;
        _ = ret_addr;
        const self: *PoolAllocator = @ptrCast(@alignCast(ctx));
        const node: *FreeNode = @ptrCast(@alignCast(buf.ptr));
        node.next = self.free_list;
        self.free_list = node;
        self.allocated -= 1;
    }

    fn remap(_: *anyopaque, _: []u8, _: std.mem.Alignment, _: usize, _: usize) ?[*]u8 {
        return null;
    }

    const vtable = std.mem.Allocator.VTable{
        .alloc = alloc,
        .resize = resize,
        .remap = remap,
        .free = free,
    };
};

/// Bump allocator with reset capability.
pub const ArenaAllocator = struct {
    inner: std.heap.ArenaAllocator,

    pub fn init(backing: std.mem.Allocator) ArenaAllocator {
        return .{ .inner = std.heap.ArenaAllocator.init(backing) };
    }

    pub fn deinit(self: *ArenaAllocator) void {
        self.inner.deinit();
    }

    pub fn allocator(self: *ArenaAllocator) std.mem.Allocator {
        return self.inner.allocator();
    }

    pub fn reset(self: *ArenaAllocator) void {
        _ = self.inner.reset(.retain_capacity);
    }
};
