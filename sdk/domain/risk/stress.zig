const std = @import("std");

pub const Position = struct {
    instrument: []const u8,
    quantity: i64,
};

pub const Shock = struct {
    instrument: []const u8,
    price_change_pct: f64,
};

pub const StressResult = struct {
    scenario: []const u8,
    pnl_impact: f64,
};

const Scenario = struct {
    name: []const u8,
    shocks: []Shock,
};

pub const StressTest = struct {
    allocator: std.mem.Allocator,
    scenarios: std.ArrayList(Scenario),

    pub fn init(allocator: std.mem.Allocator) !StressTest {
        return StressTest{
            .allocator = allocator,
            .scenarios = std.ArrayList(Scenario).init(allocator),
        };
    }

    pub fn deinit(self: *StressTest) void {
        for (self.scenarios.items) |s| {
            self.allocator.free(s.shocks);
        }
        self.scenarios.deinit();
    }

    /// Add a named stress scenario with a set of price shocks.
    pub fn addScenario(self: *StressTest, name: []const u8, shocks: []const Shock) !void {
        const owned_shocks = try self.allocator.dupe(Shock, shocks);
        try self.scenarios.append(.{
            .name = name,
            .shocks = owned_shocks,
        });
    }

    /// Run all scenarios against the given positions and mark prices.
    /// `mark_prices` must correspond 1:1 with `positions` (same index).
    /// Returns a slice of results (caller owns via allocator).
    pub fn run(self: *StressTest, positions: []const Position, mark_prices: []const i64) ![]StressResult {
        const results = try self.allocator.alloc(StressResult, self.scenarios.items.len);

        for (self.scenarios.items, 0..) |scenario, si| {
            var total_pnl: f64 = 0.0;

            for (positions, 0..) |pos, pi| {
                const mark: f64 = @floatFromInt(mark_prices[pi]);

                // Find shock for this instrument (linear scan)
                var shock_pct: f64 = 0.0;
                for (scenario.shocks) |shock| {
                    if (std.mem.eql(u8, shock.instrument, pos.instrument)) {
                        shock_pct = shock.price_change_pct;
                        break;
                    }
                }

                // P&L impact = quantity * mark_price * shock_pct
                const qty: f64 = @floatFromInt(pos.quantity);
                total_pnl += qty * mark * shock_pct;
            }

            results[si] = .{
                .scenario = scenario.name,
                .pnl_impact = total_pnl,
            };
        }

        return results;
    }
};
