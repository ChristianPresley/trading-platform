const std = @import("std");
const greeks = @import("greeks");

const BS = greeks.BlackScholes;

// Standard test parameters
const S: f64 = 100.0;
const K: f64 = 100.0;
const r: f64 = 0.05;
const sigma: f64 = 0.2;
const T: f64 = 1.0;

test "put-call parity: C - P = S - K*e^(-rT) within 1e-10" {
    const call = BS.price(S, K, r, sigma, T, true);
    const put = BS.price(S, K, r, sigma, T, false);
    const lhs = call - put;
    const rhs = S - K * @exp(-r * T);
    try std.testing.expectApproxEqAbs(rhs, lhs, 1e-10);
}

test "put-call parity: various strikes" {
    const strikes = [_]f64{ 80.0, 90.0, 100.0, 110.0, 120.0 };
    for (strikes) |k| {
        const call = BS.price(S, k, r, sigma, T, true);
        const put = BS.price(S, k, r, sigma, T, false);
        const lhs = call - put;
        const rhs = S - k * @exp(-r * T);
        try std.testing.expectApproxEqAbs(rhs, lhs, 1e-10);
    }
}

test "deep ITM call delta ≈ 1.0" {
    // S=100, K=50 → deep in the money
    const d = BS.delta(100.0, 50.0, r, sigma, T, true);
    try std.testing.expect(d > 0.99);
}

test "deep OTM call delta ≈ 0.0" {
    // S=100, K=200 → deep out of the money
    const d = BS.delta(100.0, 200.0, r, sigma, T, true);
    try std.testing.expect(d < 0.01);
}

test "deep ITM put delta ≈ -1.0" {
    // S=50, K=100 → deep ITM put
    const d = BS.delta(50.0, 100.0, r, sigma, T, false);
    try std.testing.expect(d < -0.99);
}

test "at-expiry call value = max(S-K, 0)" {
    // ITM
    const itm = BS.price(110.0, 100.0, r, sigma, 0.0, true);
    try std.testing.expectApproxEqAbs(@as(f64, 10.0), itm, 1e-10);
    // OTM
    const otm = BS.price(90.0, 100.0, r, sigma, 0.0, true);
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), otm, 1e-10);
}

test "at-expiry put value = max(K-S, 0)" {
    // ITM
    const itm = BS.price(90.0, 100.0, r, sigma, 0.0, false);
    try std.testing.expectApproxEqAbs(@as(f64, 10.0), itm, 1e-10);
    // OTM
    const otm = BS.price(110.0, 100.0, r, sigma, 0.0, false);
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), otm, 1e-10);
}

test "gamma is zero at expiry" {
    const g = BS.gamma(S, K, r, sigma, 0.0);
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), g, 1e-10);
}

test "vega > 0 for non-expired options" {
    const v = BS.vega(S, K, r, sigma, T);
    try std.testing.expect(v > 0.0);
}

test "vega is zero at expiry" {
    const v = BS.vega(S, K, r, sigma, 0.0);
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), v, 1e-10);
}

test "vega > 0 for various strikes" {
    const strikes = [_]f64{ 80.0, 90.0, 100.0, 110.0, 120.0 };
    for (strikes) |k| {
        const v = BS.vega(S, k, r, sigma, T);
        try std.testing.expect(v > 0.0);
    }
}

test "implied volatility round-trip: price → impliedVol → price" {
    const target_sigma: f64 = 0.25;
    const mkt_price = BS.price(S, K, r, target_sigma, T, true);
    const recovered_sigma = try BS.impliedVolatility(mkt_price, S, K, r, T, true);
    try std.testing.expectApproxEqAbs(target_sigma, recovered_sigma, 1e-6);
}

test "implied volatility round-trip for put" {
    const target_sigma: f64 = 0.30;
    const mkt_price = BS.price(S, K, r, target_sigma, T, false);
    const recovered_sigma = try BS.impliedVolatility(mkt_price, S, K, r, T, false);
    try std.testing.expectApproxEqAbs(target_sigma, recovered_sigma, 1e-6);
}

test "implied volatility invalid input returns error" {
    // Zero time to expiry
    const result = BS.impliedVolatility(5.0, S, K, r, 0.0, true);
    try std.testing.expectError(error.InvalidInput, result);
}

test "ATM call delta is approximately 0.5" {
    // ATM option: delta ≈ N(d1) ≈ 0.5 + adjustment for drift
    const d = BS.delta(S, K, r, sigma, T, true);
    try std.testing.expect(d > 0.5 and d < 0.65);
}

test "rho > 0 for call, < 0 for put" {
    const rho_call = BS.rho(S, K, r, sigma, T, true);
    const rho_put = BS.rho(S, K, r, sigma, T, false);
    try std.testing.expect(rho_call > 0.0);
    try std.testing.expect(rho_put < 0.0);
}

test "normalCdf symmetry: N(x) + N(-x) = 1" {
    const xs = [_]f64{ 0.0, 1.0, -1.0, 2.0, -2.0, 0.5, -0.5 };
    for (xs) |x| {
        const sum = greeks.normalCdf(x) + greeks.normalCdf(-x);
        try std.testing.expectApproxEqAbs(@as(f64, 1.0), sum, 1e-6);
    }
}
