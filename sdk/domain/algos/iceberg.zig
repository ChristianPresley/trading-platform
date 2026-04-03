// Iceberg order algorithm.
// Displays a small visible slice; refills when the current slice is fully filled.
// Optional variance adds randomized size variation to the display quantity.

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

pub const IcebergParams = struct {
    total_qty: i64,
    display_qty: i64,
    price: i64,
    instrument: []const u8,
    side: Side,
    /// Fractional variance applied to display_qty (e.g. 0.1 = ±10%).
    variance_pct: f64,
};

pub const IcebergAlgo = struct {
    params: IcebergParams,
    filled_qty: i64,
    /// Quantity in current visible slice (already placed).
    slice_remaining: i64,
    slice_count: u32,

    pub fn init(params: IcebergParams) IcebergAlgo {
        return IcebergAlgo{
            .params = params,
            .filled_qty = 0,
            .slice_remaining = 0,
            .slice_count = 0,
        };
    }

    /// Returns the initial visible slice (call once at start).
    pub fn currentSlice(self: *IcebergAlgo) ?ChildOrder {
        const remaining_total = self.params.total_qty - self.filled_qty;
        if (remaining_total <= 0) return null;

        const slice_qty = self.computeSliceQty(remaining_total);
        self.slice_remaining = slice_qty;
        self.slice_count += 1;

        return ChildOrder{
            .instrument = self.params.instrument,
            .side = self.params.side,
            .quantity = slice_qty,
            .order_type = .limit,
            .price = self.params.price,
        };
    }

    /// Called when a fill arrives.
    /// If the current visible slice is exhausted, returns the next slice.
    pub fn onFill(self: *IcebergAlgo, fill: Fill) ?ChildOrder {
        const actually_filled = @min(fill.quantity, self.slice_remaining);
        self.filled_qty += fill.quantity;
        self.slice_remaining -= actually_filled;

        const remaining_total = self.params.total_qty - self.filled_qty;
        if (remaining_total <= 0) return null;
        if (self.slice_remaining > 0) return null;

        // Current slice exhausted — emit next slice.
        const slice_qty = self.computeSliceQty(remaining_total);
        self.slice_remaining = slice_qty;
        self.slice_count += 1;

        return ChildOrder{
            .instrument = self.params.instrument,
            .side = self.params.side,
            .quantity = slice_qty,
            .order_type = .limit,
            .price = self.params.price,
        };
    }

    fn computeSliceQty(self: *const IcebergAlgo, remaining_total: i64) i64 {
        var qty = self.params.display_qty;

        // Apply deterministic variance based on slice_count parity.
        if (self.params.variance_pct > 0.0) {
            const delta: i64 = @intFromFloat(
                @as(f64, @floatFromInt(self.params.display_qty)) * self.params.variance_pct,
            );
            if (self.slice_count % 2 == 0) {
                qty += delta;
            } else {
                qty -= delta;
                if (qty <= 0) qty = 1;
            }
        }

        if (qty > remaining_total) qty = remaining_total;
        return qty;
    }
};
