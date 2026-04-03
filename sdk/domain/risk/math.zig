const std = @import("std");

/// Cholesky decomposition: returns lower triangular matrix L such that A = L * L^T.
/// Returns error.NotPositiveDefinite if the matrix is not positive definite.
/// The caller owns the returned slice.
pub fn choleskyDecomposition(allocator: std.mem.Allocator, matrix: []const []const f64) ![][]f64 {
    const n = matrix.len;
    if (n == 0) return error.InvalidInput;
    for (matrix) |row| {
        if (row.len != n) return error.InvalidInput;
    }

    // Allocate n rows
    const L = try allocator.alloc([]f64, n);
    errdefer {
        for (L) |row| allocator.free(row);
        allocator.free(L);
    }
    for (L) |*row| {
        row.* = try allocator.alloc(f64, n);
        @memset(row.*, 0.0);
    }

    for (0..n) |i| {
        for (0..i + 1) |j| {
            var sum: f64 = 0.0;
            for (0..j) |k| {
                sum += L[i][k] * L[j][k];
            }
            if (i == j) {
                const diag = matrix[i][i] - sum;
                if (diag <= 0.0) return error.NotPositiveDefinite;
                L[i][j] = @sqrt(diag);
            } else {
                L[i][j] = (matrix[i][j] - sum) / L[j][j];
            }
        }
    }
    return L;
}

/// Standard normal random variable using Box-Muller transform.
/// Updates the seed (LCG). Returns a standard normal sample.
pub fn normalRandom(seed: *u64) f64 {
    // Use Box-Muller: need two uniform samples ua, ub.
    // We use a simple LCG for both.
    const ua = lcgUniform(seed);
    const ub = lcgUniform(seed);

    // Avoid log(0)
    const safe_ua = if (ua < 1e-300) 1e-300 else ua;
    const radius = @sqrt(-2.0 * @log(safe_ua));
    const theta = 2.0 * std.math.pi * ub;
    return radius * @cos(theta);
}

/// In-place ascending sort (insertion sort — sufficient for percentile computation on simulation output).
pub fn sortAscending(data: []f64) void {
    const n = data.len;
    if (n <= 1) return;
    var i: usize = 1;
    while (i < n) : (i += 1) {
        const key = data[i];
        var j: usize = i;
        while (j > 0 and data[j - 1] > key) : (j -= 1) {
            data[j] = data[j - 1];
        }
        data[j] = key;
    }
}

/// Linear congruential generator producing a uniform sample in (0, 1).
/// Uses the Park-Miller minimal standard multiplier.
fn lcgUniform(seed: *u64) f64 {
    // Xorshift64 for better randomness quality
    seed.* ^= seed.* << 13;
    seed.* ^= seed.* >> 7;
    seed.* ^= seed.* << 17;
    // Map high 53 bits to (0, 1)
    const mantissa = seed.* >> 11; // 53 bits
    const f = @as(f64, @floatFromInt(mantissa)) * (1.0 / @as(f64, @floatFromInt(1 << 53)));
    // Clamp to avoid exact 0 (log domain)
    return if (f < 1e-300) 1e-300 else f;
}
