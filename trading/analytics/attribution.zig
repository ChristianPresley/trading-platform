// Brinson-Fachler performance attribution model
// Decomposes active return into allocation, selection, and interaction effects.

const std = @import("std");

pub const Holding = struct {
    sector: []const u8,
    weight: f64,
    return_pct: f64,
};

pub const AttributionResult = struct {
    allocation: f64,
    selection: f64,
    interaction: f64,
    total: f64,
};

pub const BrinsonAttribution = struct {
    /// Compute Brinson-Fachler attribution.
    ///
    /// portfolio: holdings in the active portfolio (weights sum to ~1.0)
    /// benchmark: holdings in the benchmark (weights sum to ~1.0)
    ///
    /// Allocation effect  = sum_i [ (w_p_i - w_b_i) * (r_b_i - r_b_total) ]
    /// Selection effect   = sum_i [ w_b_i * (r_p_i - r_b_i) ]
    /// Interaction effect = sum_i [ (w_p_i - w_b_i) * (r_p_i - r_b_i) ]
    pub fn compute(portfolio: []const Holding, benchmark: []const Holding) AttributionResult {
        // Compute benchmark total return (weighted average)
        var r_b_total: f64 = 0.0;
        for (benchmark) |bh| {
            r_b_total += bh.weight * bh.return_pct;
        }

        var allocation: f64 = 0.0;
        var selection: f64 = 0.0;
        var interaction: f64 = 0.0;

        // Iterate over benchmark sectors to compute selection and interaction.
        // For each benchmark sector, find the portfolio sector by name.
        for (benchmark) |bh| {
            const w_b = bh.weight;
            const r_b = bh.return_pct;

            // Find matching portfolio sector
            var w_p: f64 = 0.0;
            var r_p: f64 = 0.0;
            for (portfolio) |ph| {
                if (std.mem.eql(u8, ph.sector, bh.sector)) {
                    w_p = ph.weight;
                    r_p = ph.return_pct;
                    break;
                }
            }

            allocation += (w_p - w_b) * (r_b - r_b_total);
            selection += w_b * (r_p - r_b);
            interaction += (w_p - w_b) * (r_p - r_b);
        }

        // Handle portfolio sectors not in benchmark (allocation only, no selection/interaction from b-side)
        for (portfolio) |ph| {
            var found = false;
            for (benchmark) |bh| {
                if (std.mem.eql(u8, ph.sector, bh.sector)) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                // Sector in portfolio but not in benchmark
                // w_b = 0, r_b = r_b_total (assumed)
                // allocation effect = (w_p - 0) * (r_b_total - r_b_total) = 0
                // Actually per Brinson: use r_b = 0 for missing sector, entire return is allocation
                const w_p = ph.weight;
                const r_p = ph.return_pct;
                allocation += w_p * (0.0 - r_b_total);
                selection += 0.0; // w_b = 0
                interaction += w_p * (r_p - 0.0);
            }
        }

        const total = allocation + selection + interaction;

        return AttributionResult{
            .allocation = allocation,
            .selection = selection,
            .interaction = interaction,
            .total = total,
        };
    }
};
