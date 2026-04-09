const std = @import("std");
const recon = @import("reconciliation");

/// A mark price for computing unrealized P&L.
pub const Mark = struct {
    instrument: []const u8,
    price: i64,
};

/// Snapshot of a position at a point in time.
pub const PositionSnapshot = struct {
    instrument: []const u8,
    quantity: i64,
    avg_cost: i64,
    realized_pnl: i64,
    timestamp_ms: u64,
};

/// Daily P&L report.
pub const DailyPnlReport = struct {
    realized_pnl: i64,
    unrealized_pnl: i64,
    total_pnl: i64,
    snapshots: []const PositionSnapshot,
};

/// End-of-day full report.
pub const EodReport = struct {
    date_ms: u64,
    pnl: DailyPnlReport,
    recon_result: recon.ReconResult,
    snapshots: []const PositionSnapshot,
};

/// Minimal position manager interface for EOD (decoupled from full PositionManager).
pub const EodPositionView = struct {
    instrument: []const u8,
    quantity: i64,
    avg_cost: i64,
    realized_pnl: i64,
};

pub const EodProcessor = struct {
    allocator: std.mem.Allocator,
    snapshots: std.ArrayList(PositionSnapshot),

    pub fn init(allocator: std.mem.Allocator) !EodProcessor {
        return EodProcessor{
            .allocator = allocator,
            .snapshots = .empty,
        };
    }

    pub fn deinit(self: *EodProcessor) void {
        self.snapshots.deinit(self.allocator);
    }

    /// Snapshot all positions from a list of position views.
    pub fn snapshotPositions(self: *EodProcessor, positions: []const EodPositionView) ![]const PositionSnapshot {
        self.snapshots.clearRetainingCapacity();

        const now_ms = blk: {
            var ts: std.os.linux.timespec = undefined;
            _ = std.os.linux.clock_gettime(.REALTIME, &ts);
            break :blk @as(u64, @intCast(ts.sec)) * 1000 + @as(u64, @intCast(@divTrunc(ts.nsec, 1_000_000)));
        };

        for (positions) |pos| {
            try self.snapshots.append(self.allocator, .{
                .instrument = pos.instrument,
                .quantity = pos.quantity,
                .avg_cost = pos.avg_cost,
                .realized_pnl = pos.realized_pnl,
                .timestamp_ms = now_ms,
            });
        }

        return self.snapshots.items;
    }

    /// Compute daily P&L from position views and mark prices.
    pub fn computeDailyPnl(self: *EodProcessor, positions: []const EodPositionView, marks: []const Mark) !DailyPnlReport {
        const snapshots = try self.snapshotPositions(positions);

        var realized_pnl: i64 = 0;
        var unrealized_pnl: i64 = 0;

        for (positions) |pos| {
            realized_pnl += pos.realized_pnl;

            // Find mark price for this instrument
            for (marks) |mark| {
                if (std.mem.eql(u8, pos.instrument, mark.instrument)) {
                    const upnl = if (pos.quantity > 0)
                        (mark.price - pos.avg_cost) * pos.quantity
                    else if (pos.quantity < 0)
                        (pos.avg_cost - mark.price) * (-pos.quantity)
                    else
                        @as(i64, 0);
                    unrealized_pnl += upnl;
                    break;
                }
            }
        }

        return DailyPnlReport{
            .realized_pnl = realized_pnl,
            .unrealized_pnl = unrealized_pnl,
            .total_pnl = realized_pnl + unrealized_pnl,
            .snapshots = snapshots,
        };
    }

    /// Run end-of-day procedure: snapshot positions, compute P&L, run reconciliation.
    pub fn runEndOfDay(
        self: *EodProcessor,
        positions: []const EodPositionView,
        recon_engine: *recon.ReconEngine,
        marks: []const Mark,
        internal_trades: []const recon.Trade,
        external_trades: []const recon.Trade,
    ) !EodReport {
        const pnl = try self.computeDailyPnl(positions, marks);
        const recon_result = try recon_engine.reconcileTrades(internal_trades, external_trades);
        const now_ms = blk: {
            var ts: std.os.linux.timespec = undefined;
            _ = std.os.linux.clock_gettime(.REALTIME, &ts);
            break :blk @as(u64, @intCast(ts.sec)) * 1000 + @as(u64, @intCast(@divTrunc(ts.nsec, 1_000_000)));
        };

        return EodReport{
            .date_ms = now_ms,
            .pnl = pnl,
            .recon_result = recon_result,
            .snapshots = pnl.snapshots,
        };
    }
};
