// Smart Order Router (SOR).
// Scores venues by price, fees, latency, and fill probability.
// Routes orders to best venue or splits across venues for large orders.

const std = @import("std");

// Inline minimal types to avoid cross-directory import issues.
pub const Side = enum { buy, sell };

pub const OrderType = enum { market, limit };

pub const ChildOrder = struct {
    instrument: []const u8,
    side: Side,
    quantity: i64,
    order_type: OrderType,
    price: ?i64,
    venue: []const u8,
};

pub const FeeModel = enum {
    /// Maker pays fee, taker pays fee (standard).
    maker_taker,
    /// Inverted: maker receives rebate.
    inverted,
    /// Flat fee regardless of role.
    flat,
};

pub const VenueConfig = struct {
    name: []const u8,
    fee_model: FeeModel,
    /// Higher priority = preferred when scores are otherwise equal.
    priority: u8,
    /// Taker fee in basis points (positive = cost, negative = rebate).
    taker_fee_bps: i32,
    /// Maker fee / rebate in basis points.
    maker_fee_bps: i32,
};

pub const VenueStats = struct {
    avg_latency_ns: u64,
    fill_rate: f64,
    reject_rate: f64,
};

// Minimal book level.
pub const Level = struct {
    price: i64,
    quantity: i64,
};

pub const L2Book = struct {
    bids: []const Level,
    asks: []const Level,
};

pub const VenueBook = struct {
    venue: []const u8,
    book: *const L2Book,
};

pub const MarketState = struct {
    books: []const VenueBook,
};

// Order struct for routing.
pub const Order = struct {
    instrument: []const u8,
    side: Side,
    order_type: OrderType,
    quantity: i64,
    price: ?i64,
};

pub const RoutingDecision = struct {
    venue: []const u8,
    child_orders: []ChildOrder,
};

const MAX_VENUES = 16;

const VenueEntry = struct {
    config: VenueConfig,
    stats: VenueStats,
};

pub const SmartOrderRouter = struct {
    allocator: std.mem.Allocator,
    venues: [MAX_VENUES]VenueEntry,
    venue_count: usize,
    /// Heap-allocated child orders returned by route().
    child_orders_buf: []ChildOrder,

    pub fn init(allocator: std.mem.Allocator, venues: []const VenueConfig) !SmartOrderRouter {
        if (venues.len > MAX_VENUES) return error.TooManyVenues;

        var sor = SmartOrderRouter{
            .allocator = allocator,
            .venues = undefined,
            .venue_count = venues.len,
            .child_orders_buf = &[_]ChildOrder{},
        };

        for (venues, 0..) |v, i| {
            sor.venues[i] = VenueEntry{
                .config = v,
                .stats = VenueStats{
                    .avg_latency_ns = 1_000_000, // default 1ms
                    .fill_rate = 0.9,
                    .reject_rate = 0.01,
                },
            };
        }

        return sor;
    }

    pub fn deinit(self: *SmartOrderRouter) void {
        if (self.child_orders_buf.len > 0) {
            self.allocator.free(self.child_orders_buf);
        }
    }

    pub fn updateVenueStats(self: *SmartOrderRouter, venue: []const u8, stats: VenueStats) void {
        for (0..self.venue_count) |i| {
            if (std.mem.eql(u8, self.venues[i].config.name, venue)) {
                self.venues[i].stats = stats;
                return;
            }
        }
    }

    /// Score a venue. Higher is better.
    fn scoreVenue(self: *const SmartOrderRouter, idx: usize, order: *const Order, market_state: *const MarketState) f64 {
        const entry = self.venues[idx];

        // Price score: for buys, lower ask price is better; for sells, higher bid is better.
        // We normalize relative to other venues using the BBO.
        var price_score: f64 = 0.0;
        for (market_state.books) |b| {
            if (std.mem.eql(u8, b.venue, entry.config.name)) {
                switch (order.side) {
                    .buy => {
                        if (b.book.asks.len > 0) {
                            // Invert: lower price → higher score.
                            // We'll normalize later; just store the price for ranking.
                            price_score = -@as(f64, @floatFromInt(b.book.asks[0].price));
                        }
                    },
                    .sell => {
                        if (b.book.bids.len > 0) {
                            price_score = @as(f64, @floatFromInt(b.book.bids[0].price));
                        }
                    },
                }
                break;
            }
        }

        // Fee score: lower cost (or higher rebate) is better.
        // Convert taker_fee_bps to a score (negative fee = rebate = good).
        const fee_score: f64 = -@as(f64, @floatFromInt(entry.config.taker_fee_bps));

        // Latency score: lower latency is better.
        // Normalize: assume 1ms base; score = -log(latency_ns / 1_000_000).
        const latency_ms = @as(f64, @floatFromInt(entry.stats.avg_latency_ns)) / 1_000_000.0;
        const latency_score: f64 = -latency_ms;

        // Fill probability score.
        const fill_score: f64 = entry.stats.fill_rate - entry.stats.reject_rate;

        // Priority tiebreaker.
        const priority_score: f64 = @as(f64, @floatFromInt(entry.config.priority)) * 0.001;

        // Weighted composite (price dominates, then fees, then fill rate, then latency).
        return price_score * 1000.0 +
            fee_score * 10.0 +
            fill_score * 5.0 +
            latency_score * 0.1 +
            priority_score;
    }

    pub fn route(
        self: *SmartOrderRouter,
        order: *const Order,
        market_state: *const MarketState,
    ) !RoutingDecision {
        if (self.venue_count == 0) return error.NoVenues;

        // Free previous allocation.
        if (self.child_orders_buf.len > 0) {
            self.allocator.free(self.child_orders_buf);
            self.child_orders_buf = &[_]ChildOrder{};
        }

        // Score all venues and find the best.
        var best_idx: usize = 0;
        var best_score: f64 = -std.math.inf(f64);

        for (0..self.venue_count) |i| {
            const s = self.scoreVenue(i, order, market_state);
            if (s > best_score) {
                best_score = s;
                best_idx = i;
            }
        }

        const best_venue = self.venues[best_idx].config.name;

        // Check if we should split: if order qty > available liquidity at best venue.
        var available_at_best: i64 = order.quantity;
        for (market_state.books) |b| {
            if (std.mem.eql(u8, b.venue, best_venue)) {
                switch (order.side) {
                    .buy => {
                        var total: i64 = 0;
                        for (b.book.asks) |level| {
                            if (order.price) |p| {
                                if (level.price > p) break;
                            }
                            total += level.quantity;
                        }
                        available_at_best = total;
                    },
                    .sell => {
                        var total: i64 = 0;
                        for (b.book.bids) |level| {
                            if (order.price) |p| {
                                if (level.price < p) break;
                            }
                            total += level.quantity;
                        }
                        available_at_best = total;
                    },
                }
                break;
            }
        }

        if (available_at_best >= order.quantity or self.venue_count == 1) {
            // Route all to best venue.
            const buf = try self.allocator.alloc(ChildOrder, 1);
            buf[0] = ChildOrder{
                .instrument = order.instrument,
                .side = order.side,
                .quantity = order.quantity,
                .order_type = order.order_type,
                .price = order.price,
                .venue = best_venue,
            };
            self.child_orders_buf = buf;
            return RoutingDecision{
                .venue = best_venue,
                .child_orders = buf,
            };
        }

        // Split: send available_at_best to best venue, remainder to second-best.
        var second_idx: usize = 0;
        var second_score: f64 = -std.math.inf(f64);
        for (0..self.venue_count) |i| {
            if (i == best_idx) continue;
            const s = self.scoreVenue(i, order, market_state);
            if (s > second_score) {
                second_score = s;
                second_idx = i;
            }
        }

        const remainder = order.quantity - available_at_best;
        const buf = try self.allocator.alloc(ChildOrder, 2);
        buf[0] = ChildOrder{
            .instrument = order.instrument,
            .side = order.side,
            .quantity = available_at_best,
            .order_type = order.order_type,
            .price = order.price,
            .venue = best_venue,
        };
        buf[1] = ChildOrder{
            .instrument = order.instrument,
            .side = order.side,
            .quantity = remainder,
            .order_type = order.order_type,
            .price = order.price,
            .venue = self.venues[second_idx].config.name,
        };
        self.child_orders_buf = buf;

        return RoutingDecision{
            .venue = best_venue,
            .child_orders = buf,
        };
    }
};
