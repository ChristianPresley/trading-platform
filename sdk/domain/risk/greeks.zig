const std = @import("std");

/// Standard normal PDF: (1/sqrt(2π)) * e^(-x²/2)
pub fn normalPdf(x: f64) f64 {
    return @exp(-0.5 * x * x) / @sqrt(2.0 * std.math.pi);
}

/// Standard normal CDF using Abramowitz & Stegun rational approximation (7-term).
/// Maximum absolute error: 3×10⁻⁷.
pub fn normalCdf(x: f64) f64 {
    if (x >= 8.0) return 1.0;
    if (x <= -8.0) return 0.0;

    const neg = x < 0.0;
    const abs_x = if (neg) -x else x;

    // Abramowitz & Stegun 26.2.17
    const t = 1.0 / (1.0 + 0.2316419 * abs_x);
    const poly = t * (0.319381530 +
        t * (-0.356563782 +
        t * (1.781477937 +
        t * (-1.821255978 +
        t * 1.330274429))));
    const cdf = 1.0 - normalPdf(abs_x) * poly;

    return if (neg) 1.0 - cdf else cdf;
}

/// Black-Scholes option pricing model.
pub const BlackScholes = struct {
    /// Compute d1 and d2 for Black-Scholes formula.
    fn d1d2(spot: f64, strike: f64, r: f64, sigma: f64, t: f64) struct { d1: f64, d2: f64 } {
        const log_ratio = @log(spot / strike);
        const drift = (r + 0.5 * sigma * sigma) * t;
        const vol_sqrt_t = sigma * @sqrt(t);
        const d1 = (log_ratio + drift) / vol_sqrt_t;
        const d2 = d1 - vol_sqrt_t;
        return .{ .d1 = d1, .d2 = d2 };
    }

    /// Black-Scholes option price.
    /// At t=0 returns intrinsic value: max(S-K, 0) for calls, max(K-S, 0) for puts.
    pub fn price(spot: f64, strike: f64, r: f64, sigma: f64, t: f64, is_call: bool) f64 {
        if (t <= 0.0) {
            if (is_call) {
                const v = spot - strike;
                return if (v > 0.0) v else 0.0;
            } else {
                const v = strike - spot;
                return if (v > 0.0) v else 0.0;
            }
        }
        if (sigma <= 0.0) {
            // Zero vol: option worth discounted intrinsic
            const disc = @exp(-r * t);
            if (is_call) {
                const v = spot - strike * disc;
                return if (v > 0.0) v else 0.0;
            } else {
                const v = strike * disc - spot;
                return if (v > 0.0) v else 0.0;
            }
        }

        const ds = d1d2(spot, strike, r, sigma, t);
        const disc = @exp(-r * t);

        if (is_call) {
            return spot * normalCdf(ds.d1) - strike * disc * normalCdf(ds.d2);
        } else {
            return strike * disc * normalCdf(-ds.d2) - spot * normalCdf(-ds.d1);
        }
    }

    /// Delta: first derivative of option price w.r.t. spot price.
    /// At t=0: step function (1 for call ITM, 0 for call OTM).
    pub fn delta(spot: f64, strike: f64, r: f64, sigma: f64, t: f64, is_call: bool) f64 {
        if (t <= 0.0) {
            if (is_call) {
                return if (spot > strike) 1.0 else 0.0;
            } else {
                return if (spot < strike) -1.0 else 0.0;
            }
        }
        if (sigma <= 0.0) {
            if (is_call) {
                return if (spot > strike) 1.0 else 0.0;
            } else {
                return if (spot < strike) -1.0 else 0.0;
            }
        }

        const ds = d1d2(spot, strike, r, sigma, t);
        if (is_call) {
            return normalCdf(ds.d1);
        } else {
            return normalCdf(ds.d1) - 1.0;
        }
    }

    /// Gamma: second derivative of option price w.r.t. spot price.
    /// Same for calls and puts.  Zero at expiry (t=0).
    pub fn gamma(spot: f64, strike: f64, r: f64, sigma: f64, t: f64) f64 {
        if (t <= 0.0 or sigma <= 0.0) return 0.0;
        const ds = d1d2(spot, strike, r, sigma, t);
        return normalPdf(ds.d1) / (spot * sigma * @sqrt(t));
    }

    /// Vega: first derivative of option price w.r.t. sigma.
    /// Same for calls and puts.  Zero at expiry (t=0).
    pub fn vega(spot: f64, strike: f64, r: f64, sigma: f64, t: f64) f64 {
        if (t <= 0.0 or sigma <= 0.0) return 0.0;
        const ds = d1d2(spot, strike, r, sigma, t);
        return spot * normalPdf(ds.d1) * @sqrt(t);
    }

    /// Theta: first derivative of option price w.r.t. time (dV/dt, per-year).
    /// Zero at expiry (t=0).
    pub fn theta(spot: f64, strike: f64, r: f64, sigma: f64, t: f64, is_call: bool) f64 {
        if (t <= 0.0 or sigma <= 0.0) return 0.0;
        const ds = d1d2(spot, strike, r, sigma, t);
        const disc = @exp(-r * t);
        const term1 = -(spot * normalPdf(ds.d1) * sigma) / (2.0 * @sqrt(t));
        if (is_call) {
            return term1 - r * strike * disc * normalCdf(ds.d2);
        } else {
            return term1 + r * strike * disc * normalCdf(-ds.d2);
        }
    }

    /// Rho: first derivative of option price w.r.t. risk-free rate.
    /// Zero at expiry (t=0).
    pub fn rho(spot: f64, strike: f64, r: f64, sigma: f64, t: f64, is_call: bool) f64 {
        if (t <= 0.0 or sigma <= 0.0) return 0.0;
        const ds = d1d2(spot, strike, r, sigma, t);
        const disc = @exp(-r * t);
        if (is_call) {
            return strike * t * disc * normalCdf(ds.d2);
        } else {
            return -strike * t * disc * normalCdf(-ds.d2);
        }
    }

    /// Implied volatility via Newton-Raphson iteration.
    /// Uses vega as the derivative.  Returns error.DidNotConverge after 100 iterations.
    /// Returns error.InvalidInput for non-positive inputs or degenerate cases.
    pub fn impliedVolatility(market_price: f64, spot: f64, strike: f64, r: f64, t: f64, is_call: bool) !f64 {
        if (market_price <= 0.0 or spot <= 0.0 or strike <= 0.0 or t <= 0.0) {
            return error.InvalidInput;
        }

        // Initial guess: use Brenner-Subrahmanyam approximation
        var sigma: f64 = @sqrt(2.0 * std.math.pi / t) * market_price / spot;
        if (sigma <= 0.0 or std.math.isNan(sigma)) sigma = 0.2;
        if (sigma > 10.0) sigma = 10.0;

        var iter: u32 = 0;
        while (iter < 100) : (iter += 1) {
            const p = price(spot, strike, r, sigma, t, is_call);
            const v = vega(spot, strike, r, sigma, t);

            const diff = p - market_price;
            if (@abs(diff) < 1e-10) return sigma;
            if (@abs(v) < 1e-15) break; // vega too small — cannot converge

            sigma = sigma - diff / v;
            if (sigma <= 0.0) sigma = 1e-8;
        }

        // Final check
        const p = price(spot, strike, r, sigma, t, is_call);
        if (@abs(p - market_price) < 1e-6) return sigma;

        return error.DidNotConverge;
    }
};
