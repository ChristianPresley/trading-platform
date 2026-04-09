const std = @import("std");
const oms = @import("oms");

pub const Order = oms.Order;
pub const OrderType = oms.OrderType;

pub const RejectReason = enum {
    invalid_order,
    size_exceeded,
    price_unreasonable,
    position_limit,
    rate_exceeded,
    duplicate_detected,
};

pub const ValidationResult = union(enum) {
    passed,
    rejected: RejectReason,
};

pub const RiskConfig = struct {
    max_order_size: i64,
    max_notional: i64,
    max_position: i64,
    max_order_rate: u32, // orders per second
    price_band_pct: f64, // allowed deviation from reference price (0.0–1.0)
    dedup_window_ms: u64, // duplicate detection window in milliseconds
};

/// Key used for duplicate detection
const DedupKey = struct {
    instrument_hash: u64,
    side: oms.Side,
    quantity: i64,
    price: i64,
};

pub const PreTradeRisk = struct {
    allocator: std.mem.Allocator,
    config: RiskConfig,

    // Position tracking per instrument (simple hash map simulation with fixed capacity)
    positions: std.StringHashMap(i64),

    // Rate throttle: sliding window of timestamps (nanoseconds)
    rate_window: std.ArrayList(u64),

    // Duplicate detection: recent (key, timestamp_ms) pairs
    dedup_entries: std.ArrayList(DedupEntry),

    // Reference prices per instrument for price reasonability check
    ref_prices: std.StringHashMap(i64),

    const DedupEntry = struct {
        key: DedupKey,
        timestamp_ms: u64,
    };

    pub fn init(allocator: std.mem.Allocator, config: RiskConfig) !PreTradeRisk {
        return PreTradeRisk{
            .allocator = allocator,
            .config = config,
            .positions = std.StringHashMap(i64).init(allocator),
            .rate_window = .empty,
            .dedup_entries = .empty,
            .ref_prices = std.StringHashMap(i64).init(allocator),
        };
    }

    pub fn deinit(self: *PreTradeRisk) void {
        self.positions.deinit();
        self.rate_window.deinit(self.allocator);
        self.dedup_entries.deinit(self.allocator);
        self.ref_prices.deinit();
    }

    /// Set reference price for an instrument (used for price reasonability checks)
    pub fn setReferencePrice(self: *PreTradeRisk, instrument: []const u8, price: i64) !void {
        try self.ref_prices.put(instrument, price);
    }

    /// Update tracked position for an instrument
    pub fn updatePosition(self: *PreTradeRisk, instrument: []const u8, delta: i64) !void {
        const entry = try self.positions.getOrPutValue(instrument, 0);
        entry.value_ptr.* += delta;
    }

    /// Run the full validation pipeline. Returns passed or rejected with reason.
    pub fn validate(self: *PreTradeRisk, order: *const Order) ValidationResult {
        // 1. Basic order validation
        if (order.quantity <= 0) return .{ .rejected = .invalid_order };
        if (order.order_type != .market and order.order_type != .trailing_stop) {
            if (order.price == null) return .{ .rejected = .invalid_order };
            if (order.price.? <= 0) return .{ .rejected = .invalid_order };
        }
        if (order.instrument.len == 0) return .{ .rejected = .invalid_order };

        // 2. Size limits
        if (order.quantity > self.config.max_order_size) return .{ .rejected = .size_exceeded };
        const notional = if (order.price) |p| order.quantity * p else 0;
        if (notional > self.config.max_notional) return .{ .rejected = .size_exceeded };

        // 3. Price reasonability (skip for market orders and trailing stops)
        if (order.order_type == .limit or order.order_type == .stop or order.order_type == .stop_limit) {
            if (order.price) |price| {
                if (self.ref_prices.get(order.instrument)) |ref_price| {
                    const diff: f64 = @abs(@as(f64, @floatFromInt(price - ref_price)));
                    const band: f64 = @as(f64, @floatFromInt(ref_price)) * self.config.price_band_pct;
                    if (diff > band) return .{ .rejected = .price_unreasonable };
                }
            }
        }

        // 4. Position limits
        const current_pos = self.positions.get(order.instrument) orelse 0;
        const delta: i64 = if (order.side == .buy) order.quantity else -order.quantity;
        const new_pos = @abs(current_pos + delta);
        if (new_pos > self.config.max_position) return .{ .rejected = .position_limit };

        // 5. Rate throttle: check orders per second
        const now_ns = nowNanos();
        const one_second_ns: u64 = 1_000_000_000;
        const window_start = if (now_ns >= one_second_ns) now_ns - one_second_ns else 0;

        // Prune expired timestamps to prevent unbounded growth
        var wi: usize = 0;
        for (self.rate_window.items) |ts| {
            if (ts >= window_start) {
                self.rate_window.items[wi] = ts;
                wi += 1;
            }
        }
        self.rate_window.items.len = wi;

        if (wi >= self.config.max_order_rate) return .{ .rejected = .rate_exceeded };

        // Record this order in the rate window
        self.rate_window.append(self.allocator, now_ns) catch {};

        // 6. Duplicate detection (skipped when dedup_window_ms == 0)
        if (self.config.dedup_window_ms > 0) {
            const price_for_dedup: i64 = order.price orelse 0;
            const instrument_hash = hashStr(order.instrument);
            const dedup_key = DedupKey{
                .instrument_hash = instrument_hash,
                .side = order.side,
                .quantity = order.quantity,
                .price = price_for_dedup,
            };
            const now_ms = now_ns / 1_000_000;
            const window_start_ms = if (now_ms >= self.config.dedup_window_ms)
                now_ms - self.config.dedup_window_ms
            else
                0;

            // Prune expired dedup entries to prevent unbounded growth
            var di: usize = 0;
            for (self.dedup_entries.items) |entry| {
                if (entry.timestamp_ms >= window_start_ms) {
                    self.dedup_entries.items[di] = entry;
                    di += 1;
                }
            }
            self.dedup_entries.items.len = di;

            for (self.dedup_entries.items) |entry| {
                if (dedupKeyEql(entry.key, dedup_key)) {
                    return .{ .rejected = .duplicate_detected };
                }
            }

            // Record this order for future duplicate checks
            self.dedup_entries.append(self.allocator, .{
                .key = dedup_key,
                .timestamp_ms = now_ms,
            }) catch {};
        }

        return .passed;
    }

    fn nowNanos() u64 {
        var ts: std.os.linux.timespec = undefined;
        const rc = std.os.linux.clock_gettime(.MONOTONIC, &ts);
        if (@as(isize, @bitCast(rc)) < 0) return 0;
        return @as(u64, @intCast(ts.sec)) * 1_000_000_000 + @as(u64, @intCast(ts.nsec));
    }

    fn hashStr(s: []const u8) u64 {
        var h: u64 = 14695981039346656037;
        for (s) |b| {
            h ^= b;
            h = h *% 1099511628211;
        }
        return h;
    }

    fn dedupKeyEql(a: DedupKey, b: DedupKey) bool {
        return a.instrument_hash == b.instrument_hash and
            a.side == b.side and
            a.quantity == b.quantity and
            a.price == b.price;
    }
};
