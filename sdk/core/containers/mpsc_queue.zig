const std = @import("std");

/// Multi-producer single-consumer intrusive queue.
/// Lock-free push via atomic swap on tail; single-consumer pop.
pub fn MpscQueue(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            next: std.atomic.Value(?*Node),
            data: T,

            pub fn init(data: T) Node {
                return .{
                    .next = std.atomic.Value(?*Node).init(null),
                    .data = data,
                };
            }
        };

        // The sentinel dummy node is always allocated and never exposed to callers.
        // head points to the node whose .next is the front of the queue.
        // After a pop, head advances to the popped node (which becomes the new dummy).
        // We track the original sentinel pointer to free it in deinit.
        sentinel: *Node,
        head: *Node,
        tail: std.atomic.Value(*Node),
        alloc: std.mem.Allocator,

        pub fn initAlloc(allocator: std.mem.Allocator) !Self {
            const sentinel = try allocator.create(Node);
            sentinel.* = .{
                .next = std.atomic.Value(?*Node).init(null),
                .data = undefined,
            };
            return Self{
                .sentinel = sentinel,
                .head = sentinel,
                .tail = std.atomic.Value(*Node).init(sentinel),
                .alloc = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            // Free the original sentinel (it may no longer be head)
            self.alloc.destroy(self.sentinel);
        }

        /// Lock-free push. Can be called from multiple threads.
        pub fn push(self: *Self, node: *Node) void {
            node.next.store(null, .seq_cst);
            const prev = self.tail.swap(node, .seq_cst);
            prev.next.store(node, .release);
        }

        /// Single-consumer pop. Returns null if empty.
        /// The returned node's .next field is undefined after pop.
        pub fn pop(self: *Self) ?*Node {
            const head = self.head;
            const next = head.next.load(.acquire);
            if (next == null) return null;
            // Advance head: 'next' becomes the new dummy, and we return it as the result.
            // The data is in next.data (it was written by push before .next was published).
            self.head = next.?;
            return next.?;
        }
    };
}
