// Sniper / Liquidity Seeking algorithm.
// Monitors the order book; fires an aggressive order when sufficient
// liquidity appears at an acceptable price level.

const std = @import("std");

pub const Side = enum { buy, sell };

pub const OrderType = enum { market, limit };

pub const Fill = struct {
    quantity: i64,
    price: i64,
};

pub const ChildOrder = struct {
    instrument: []const u8,
    side: Side,
    quantity: i64,
    order_type: OrderType,
    price: ?i64,
};

pub const SniperParams = struct {
    total_qty: i64,
    /// Maximum acceptable price for buys; minimum acceptable for sells.
    max_price: i64,
    /// Minimum cumulative size at acceptable price levels before firing.
    min_size_threshold: i64,
    instrument: []const u8,
    side: Side,
};

// Minimal book level for sniper (avoids import of full L2Book).
pub const BookLevel = struct {
    price: i64,
    quantity: i64,
};

// Minimal book view for sniper.
pub const L2BookView = struct {
    bids: []const BookLevel,
    asks: []const BookLevel,
};

pub const SniperAlgo = struct {
    params: SniperParams,
    filled_qty: i64,
    fired: bool,

    pub fn init(params: SniperParams) SniperAlgo {
        return SniperAlgo{
            .params = params,
            .filled_qty = 0,
            .fired = false,
        };
    }

    /// Called on each book update.
    /// Returns a child order when sufficient liquidity at acceptable price is found.
    pub fn onBookUpdate(self: *SniperAlgo, book: *const L2BookView) ?ChildOrder {
        const remaining = self.params.total_qty - self.filled_qty;
        if (remaining <= 0) return null;
        if (self.fired) return null;

        // For buy orders: look at asks at or below max_price.
        // For sell orders: look at bids at or above max_price (used as min acceptable).
        var available: i64 = 0;
        var best_price: ?i64 = null;

        switch (self.params.side) {
            .buy => {
                for (book.asks) |level| {
                    if (level.price > self.params.max_price) break;
                    available += level.quantity;
                    if (best_price == null) best_price = level.price;
                }
            },
            .sell => {
                for (book.bids) |level| {
                    // bids sorted descending; skip levels below min acceptable price.
                    if (level.price < self.params.max_price) break;
                    available += level.quantity;
                    if (best_price == null) best_price = level.price;
                }
            },
        }

        if (available < self.params.min_size_threshold) return null;

        // Fire: take up to remaining qty, limited by available liquidity.
        const qty = @min(remaining, available);
        self.fired = true;

        return ChildOrder{
            .instrument = self.params.instrument,
            .side = self.params.side,
            .quantity = qty,
            .order_type = .market,
            .price = best_price,
        };
    }

    pub fn onFill(self: *SniperAlgo, fill: Fill) void {
        self.filled_qty += fill.quantity;
        // Allow re-firing if there is still remaining qty.
        if (self.filled_qty < self.params.total_qty) {
            self.fired = false;
        }
    }
};
