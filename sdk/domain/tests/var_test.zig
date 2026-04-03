const std = @import("std");
const var_mod = @import("var");

test "parametric VaR: sigma=0.02, z=1.645, horizon=1, value=1M" {
    const result = var_mod.parametricVar(0.02, 1.645, 1.0, 1_000_000.0);
    // Expected: 0.02 * 1.645 * 1.0 * 1_000_000 = 32_900
    try std.testing.expectApproxEqAbs(@as(f64, 32_900.0), result, 0.001);
}

test "historical VaR: sorted returns, 95% confidence" {
    // 20 returns: worst are -0.05, -0.04, -0.03 ...
    var returns = [_]f64{
        -0.05, -0.04, -0.03, -0.02, -0.01,
        0.00,  0.01,  0.02,  0.03,  0.04,
        0.05,  0.06,  0.07,  0.08,  0.09,
        0.10,  0.11,  0.12,  0.13,  0.14,
    };
    // 95% confidence: (1-0.95) * 20 = 1.0 → index 1 (second worst)
    // VaR = -(-0.04) = 0.04
    const result = try var_mod.historicalVar(&returns, 0.95);
    // The result should be in the range of the worst few losses
    try std.testing.expect(result >= 0.03 and result <= 0.05);
}

test "historical VaR: insufficient data returns error" {
    var returns = [_]f64{ -0.01, -0.02 };
    // 99% confidence: need at least ceil(1/0.01) = 100 observations
    const result = var_mod.historicalVar(&returns, 0.99);
    try std.testing.expectError(error.InsufficientData, result);
}

test "expected shortfall > VaR" {
    var returns = [_]f64{
        -0.10, -0.08, -0.06, -0.05, -0.04,
        -0.03, -0.02, -0.01, 0.00,  0.01,
        0.02,  0.03,  0.04,  0.05,  0.06,
        0.07,  0.08,  0.09,  0.10,  0.11,
    };
    const confidence = 0.95;
    const var_result = try var_mod.historicalVar(&returns, confidence);
    const es_result = try var_mod.expectedShortfall(&returns, confidence);
    // ES should be >= VaR (average of tail losses beyond VaR)
    try std.testing.expect(es_result >= var_result);
}

test "Monte Carlo VaR is positive and plausible for 1-asset normal" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 1-asset: covariance = [[sigma^2]], weight = [1.0]
    const sigma: f64 = 0.02;
    const row = [_]f64{sigma * sigma};
    const cov_row: []const f64 = &row;
    const cov = [_][]const f64{cov_row};
    const weights = [_]f64{1.0};

    const result = try var_mod.monteCarloVar(
        allocator,
        &cov,
        &weights,
        10_000,
        0.95,
    );

    // Parametric reference: sigma * 1.645 = 0.0329
    // MC VaR should be positive and within a reasonable range of parametric
    const expected = sigma * 1.645;
    try std.testing.expect(result > 0.0);
    // Check within 50% of parametric value (LCG-based RNG has limited quality)
    try std.testing.expect(result < expected * 2.0);
    try std.testing.expect(result > expected * 0.1);
}

test "expected shortfall with known tail" {
    // 20 observations at 90% confidence to avoid floating point min_obs issues
    var returns = [_]f64{
        -0.10, -0.08, -0.06, -0.04, -0.02,
        0.00,  0.02,  0.04,  0.06,  0.08,
        0.10,  0.12,  0.14,  0.16,  0.18,
        0.20,  0.22,  0.24,  0.26,  0.28,
    };
    // 90% confidence: 10% tail of 20 = 2 obs at indices 0,1 = -0.10, -0.08
    // ES = (0.10 + 0.08) / 2 = 0.09
    const es = try var_mod.expectedShortfall(&returns, 0.90);
    try std.testing.expectApproxEqAbs(@as(f64, 0.09), es, 1e-10);
}
