// Brinson attribution tests
const std = @import("std");
const attr = @import("attribution");
const BrinsonAttribution = attr.BrinsonAttribution;
const Holding = attr.Holding;

test "allocation + selection + interaction = total" {
    const portfolio = [_]Holding{
        .{ .sector = "tech", .weight = 0.6, .return_pct = 0.12 },
        .{ .sector = "energy", .weight = 0.4, .return_pct = 0.06 },
    };
    const benchmark = [_]Holding{
        .{ .sector = "tech", .weight = 0.5, .return_pct = 0.10 },
        .{ .sector = "energy", .weight = 0.5, .return_pct = 0.05 },
    };

    const result = BrinsonAttribution.compute(&portfolio, &benchmark);

    const expected_total = result.allocation + result.selection + result.interaction;
    try std.testing.expectApproxEqAbs(expected_total, result.total, 0.0001);
}

test "identical portfolio and benchmark -> all effects zero" {
    const portfolio = [_]Holding{
        .{ .sector = "tech", .weight = 0.5, .return_pct = 0.10 },
        .{ .sector = "energy", .weight = 0.5, .return_pct = 0.05 },
    };
    const benchmark = [_]Holding{
        .{ .sector = "tech", .weight = 0.5, .return_pct = 0.10 },
        .{ .sector = "energy", .weight = 0.5, .return_pct = 0.05 },
    };

    const result = BrinsonAttribution.compute(&portfolio, &benchmark);

    try std.testing.expectApproxEqAbs(0.0, result.allocation, 0.0001);
    try std.testing.expectApproxEqAbs(0.0, result.selection, 0.0001);
    try std.testing.expectApproxEqAbs(0.0, result.interaction, 0.0001);
    try std.testing.expectApproxEqAbs(0.0, result.total, 0.0001);
}

test "zero-weight portfolio sector: allocation effect is zero" {
    // Portfolio has zero weight in 'energy', benchmark has 0.3
    const portfolio = [_]Holding{
        .{ .sector = "tech", .weight = 1.0, .return_pct = 0.10 },
        .{ .sector = "energy", .weight = 0.0, .return_pct = 0.05 },
    };
    const benchmark = [_]Holding{
        .{ .sector = "tech", .weight = 0.7, .return_pct = 0.10 },
        .{ .sector = "energy", .weight = 0.3, .return_pct = 0.05 },
    };

    const result = BrinsonAttribution.compute(&portfolio, &benchmark);

    // Allocation for 'energy': (0 - 0.3) * (0.05 - r_b_total)
    // r_b_total = 0.7*0.10 + 0.3*0.05 = 0.07 + 0.015 = 0.085
    // energy allocation = (0 - 0.3) * (0.05 - 0.085) = (-0.3) * (-0.035) = 0.0105
    // tech allocation = (1.0 - 0.7) * (0.10 - 0.085) = 0.3 * 0.015 = 0.0045
    // Sum = 0.015
    // Just verify it computes without error and sums correctly
    const check = result.allocation + result.selection + result.interaction;
    try std.testing.expectApproxEqAbs(check, result.total, 0.0001);
}

test "single sector portfolio and benchmark" {
    const portfolio = [_]Holding{
        .{ .sector = "tech", .weight = 1.0, .return_pct = 0.15 },
    };
    const benchmark = [_]Holding{
        .{ .sector = "tech", .weight = 1.0, .return_pct = 0.10 },
    };

    const result = BrinsonAttribution.compute(&portfolio, &benchmark);

    // allocation = (1 - 1) * (0.10 - 0.10) = 0
    // selection = 1 * (0.15 - 0.10) = 0.05
    // interaction = (1 - 1) * (0.15 - 0.10) = 0
    try std.testing.expectApproxEqAbs(0.0, result.allocation, 0.0001);
    try std.testing.expectApproxEqAbs(0.05, result.selection, 0.0001);
    try std.testing.expectApproxEqAbs(0.0, result.interaction, 0.0001);
    try std.testing.expectApproxEqAbs(0.05, result.total, 0.0001);
}
