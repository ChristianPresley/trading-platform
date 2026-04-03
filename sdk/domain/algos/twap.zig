// TWAP — Time-Weighted Average Price execution algorithm.
// Divides total_qty evenly across num_slices intervals.
// Each slice fires at its scheduled time ± jitter_pct.

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

pub const TwapParams = struct {
    total_qty: i64,
    start_time: u128,
    end_time: u128,
    num_slices: u32,
    instrument: []const u8,
    side: Side,
    jitter_pct: f64,
};

pub const TwapAlgo = struct {
    params: TwapParams,
    filled_qty: i64,
    current_slice: u32,
    /// Pre-computed scheduled fire times for each slice (with jitter applied at init).
    slice_times: [64]u128,
    slice_qtys: [64]i64,
    num_slices_clamped: u32,

    pub fn init(params: TwapParams) TwapAlgo {
        var algo = TwapAlgo{
            .params = params,
            .filled_qty = 0,
            .current_slice = 0,
            .slice_times = [_]u128{0} ** 64,
            .slice_qtys = [_]i64{0} ** 64,
            .num_slices_clamped = 0,
        };

        const n = @min(params.num_slices, 64);
        algo.num_slices_clamped = n;

        if (n == 0) return algo;

        const duration = params.end_time -% params.start_time;
        const slice_interval = duration / n;
        const base_qty = @divTrunc(params.total_qty, @as(i64, @intCast(n)));

        var remainder = params.total_qty - base_qty * @as(i64, @intCast(n));

        // Use a simple deterministic jitter based on slice index.
        // jitter_pct: e.g. 0.1 = ±10% of slice_interval.
        for (0..n) |i| {
            // Deterministic jitter: alternate +/- based on index parity.
            const jitter_sign: i64 = if (i % 2 == 0) 1 else -1;
            const jitter_fraction: f64 = params.jitter_pct * 0.5;
            const jitter_ns: i64 = @intFromFloat(@as(f64, @floatFromInt(slice_interval)) * jitter_fraction * @as(f64, @floatFromInt(jitter_sign)));
            const base_time = params.start_time + slice_interval * i + slice_interval / 2;
            const fire_time: u128 = if (jitter_ns >= 0)
                base_time + @as(u128, @intCast(jitter_ns))
            else
                base_time -% @as(u128, @intCast(-jitter_ns));
            algo.slice_times[i] = fire_time;

            // Last slice gets the remainder.
            if (i == n - 1) {
                algo.slice_qtys[i] = base_qty + remainder;
                remainder = 0;
            } else {
                algo.slice_qtys[i] = base_qty;
            }
        }

        return algo;
    }

    /// Returns next child order if the current slice's scheduled time has arrived.
    pub fn nextSlice(self: *TwapAlgo, now: u128) ?ChildOrder {
        if (self.isComplete()) return null;
        if (self.current_slice >= self.num_slices_clamped) return null;

        const fire_time = self.slice_times[self.current_slice];
        if (now < fire_time) return null;

        const qty = self.slice_qtys[self.current_slice];
        self.current_slice += 1;

        if (qty <= 0) return null;

        return ChildOrder{
            .instrument = self.params.instrument,
            .side = self.params.side,
            .quantity = qty,
            .order_type = .market,
            .price = null,
        };
    }

    pub fn onFill(self: *TwapAlgo, fill: Fill) void {
        self.filled_qty += fill.quantity;
    }

    pub fn isComplete(self: *TwapAlgo) bool {
        if (self.filled_qty >= self.params.total_qty) return true;
        if (self.current_slice >= self.num_slices_clamped) return true;
        return false;
    }

    pub fn remainingQty(self: *TwapAlgo) i64 {
        return self.params.total_qty - self.filled_qty;
    }
};
