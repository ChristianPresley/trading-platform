const std = @import("std");
const math = @import("math.zig");

/// Historical VaR: sorts return distribution, picks (1-confidence) percentile loss.
/// Returns error.InsufficientData if there are fewer than 1/(1-confidence) observations.
/// `returns` should be signed P&L returns (negative = loss).
pub fn historicalVar(returns: []const f64, confidence: f64) !f64 {
    if (returns.len == 0) return error.InsufficientData;

    // Check minimum data requirement: need at least ceil(1 / (1 - confidence)) observations
    const min_obs: usize = @intFromFloat(@ceil(1.0 / (1.0 - confidence)));
    if (returns.len < min_obs) return error.InsufficientData;

    // Copy and sort ascending (most negative first)
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sorted = try allocator.dupe(f64, returns);
    defer allocator.free(sorted);
    math.sortAscending(sorted);

    // VaR at confidence level: take the (1-confidence) * n index (loss = negative returns)
    const idx_f: f64 = (1.0 - confidence) * @as(f64, @floatFromInt(sorted.len));
    var idx: usize = @intFromFloat(idx_f);
    if (idx >= sorted.len) idx = sorted.len - 1;

    // VaR is expressed as a positive loss amount
    return -sorted[idx];
}

/// Parametric (variance-covariance) VaR: assumes normally distributed returns.
/// formula: VaR = sigma * z_alpha * sqrt(horizon_days) * position_value
pub fn parametricVar(sigma: f64, z_alpha: f64, horizon_days: f64, position_value: f64) f64 {
    return sigma * z_alpha * @sqrt(horizon_days) * position_value;
}

/// Monte Carlo VaR using Cholesky-correlated normal returns.
/// `covariance` is an n×n positive definite matrix of daily return covariances.
/// `weights` is the portfolio weight vector (must sum to 1 or be scaled).
/// `simulations` is the number of random portfolio loss scenarios.
/// Returns error.InsufficientData if simulations < 1/(1-confidence).
pub fn monteCarloVar(
    allocator: std.mem.Allocator,
    covariance: []const []const f64,
    weights: []const f64,
    simulations: u32,
    confidence: f64,
) !f64 {
    const n = covariance.len;
    if (n == 0 or weights.len != n) return error.InvalidInput;
    if (simulations == 0) return error.InsufficientData;

    const min_obs: usize = @intFromFloat(@ceil(1.0 / (1.0 - confidence)));
    if (simulations < min_obs) return error.InsufficientData;

    // Cholesky decompose covariance matrix
    const L = try math.choleskyDecomposition(allocator, covariance);
    defer {
        for (L) |row| allocator.free(row);
        allocator.free(L);
    }

    // Allocate portfolio loss array
    const losses = try allocator.alloc(f64, simulations);
    defer allocator.free(losses);

    // Generate correlated normal returns via Box-Muller + Cholesky
    var seed: u64 = 0xDEADBEEF_CAFEBABE;
    const z = try allocator.alloc(f64, n);
    defer allocator.free(z);
    const corr = try allocator.alloc(f64, n);
    defer allocator.free(corr);

    for (0..simulations) |s| {
        // Draw n independent standard normal samples
        for (0..n) |i| {
            z[i] = math.normalRandom(&seed);
        }

        // Correlate: corr = L * z
        for (0..n) |i| {
            corr[i] = 0.0;
            for (0..i + 1) |j| {
                corr[i] += L[i][j] * z[j];
            }
        }

        // Portfolio return = weights · corr
        var portfolio_return: f64 = 0.0;
        for (0..n) |i| {
            portfolio_return += weights[i] * corr[i];
        }

        // Loss = -return (positive means portfolio lost money)
        losses[s] = -portfolio_return;
    }

    // Sort losses ascending
    math.sortAscending(losses);

    // VaR at confidence: percentile index
    const idx_f: f64 = confidence * @as(f64, @floatFromInt(simulations));
    var idx: usize = @intFromFloat(idx_f);
    if (idx >= simulations) idx = simulations - 1;

    return losses[idx];
}

/// Expected Shortfall (CVaR): average of losses beyond the VaR threshold.
/// Returns error.InsufficientData if not enough data points.
pub fn expectedShortfall(returns: []const f64, confidence: f64) !f64 {
    if (returns.len == 0) return error.InsufficientData;

    const min_obs: usize = @intFromFloat(@ceil(1.0 / (1.0 - confidence)));
    if (returns.len < min_obs) return error.InsufficientData;

    // Copy and sort ascending
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sorted = try allocator.dupe(f64, returns);
    defer allocator.free(sorted);
    math.sortAscending(sorted);

    // Cutoff index: tail beyond VaR threshold
    // Use round to avoid floating point precision issues (e.g. 0.1 * 20 = 1.9999...)
    const idx_f: f64 = (1.0 - confidence) * @as(f64, @floatFromInt(sorted.len));
    const cutoff_rounded: usize = @intFromFloat(@round(idx_f));
    const cutoff: usize = if (cutoff_rounded == 0) 1 else cutoff_rounded;

    // Average over losses in tail (returns that are more negative than VaR)
    // We average the worst `cutoff` losses (indices 0..cutoff-1 in sorted ascending)
    const tail_count = cutoff;
    var sum: f64 = 0.0;
    for (0..tail_count) |i| {
        sum += sorted[i];
    }
    const es = -(sum / @as(f64, @floatFromInt(tail_count)));
    return es;
}
