// TCA engine tests
const std = @import("std");
const tca = @import("tca");
const TcaEngine = tca.TcaEngine;
const Execution = tca.Execution;
const Benchmark = tca.Benchmark;
const Side = tca.Side;

test "IS decomposition: timing + market_impact + opportunity = total IS cost (multi-fill)" {
    var engine = try TcaEngine.init(std.testing.allocator);
    defer engine.deinit();

    // Three buy fills at different prices
    const executions = [_]Execution{
        .{ .price = 10010, .quantity = 100, .timestamp = 1000, .side = .buy, .venue = "kraken" },
        .{ .price = 10020, .quantity = 100, .timestamp = 2000, .side = .buy, .venue = "kraken" },
        .{ .price = 10030, .quantity = 100, .timestamp = 3000, .side = .buy, .venue = "kraken" },
    };
    const benchmark = Benchmark{
        .arrival_price = 10000,
        .market_vwap = 10015,
        .close_price = 10050,
        .attempted_qty = 300,
    };

    const report = try engine.analyze(&executions, benchmark);

    // timing + market_impact + opportunity_cost should sum to is_cost
    // (since all qty filled, opportunity_cost = 0)
    const sum = report.timing_cost_bps + report.market_impact_bps + report.opportunity_cost_bps;
    try std.testing.expectApproxEqAbs(report.is_cost_bps, sum, 0.001);
}

test "zero slippage when all fills at arrival price" {
    var engine = try TcaEngine.init(std.testing.allocator);
    defer engine.deinit();

    // Single buy fill exactly at arrival price
    const executions = [_]Execution{
        .{ .price = 10000, .quantity = 200, .timestamp = 1000, .side = .buy, .venue = "kraken" },
    };
    const benchmark = Benchmark{
        .arrival_price = 10000,
        .market_vwap = 10000,
        .close_price = 10000,
        .attempted_qty = 200,
    };

    const report = try engine.analyze(&executions, benchmark);

    try std.testing.expectApproxEqAbs(0.0, report.is_cost_bps, 0.001);
    try std.testing.expectApproxEqAbs(0.0, report.vwap_slippage_bps, 0.001);
}

test "VWAP slippage sign: buy fills above market VWAP -> positive slippage" {
    var engine = try TcaEngine.init(std.testing.allocator);
    defer engine.deinit();

    // Buy fills at 10100, market VWAP at 10000
    const executions = [_]Execution{
        .{ .price = 10100, .quantity = 100, .timestamp = 1000, .side = .buy, .venue = "kraken" },
    };
    const benchmark = Benchmark{
        .arrival_price = 10050,
        .market_vwap = 10000,
        .close_price = 10100,
        .attempted_qty = 100,
    };

    const report = try engine.analyze(&executions, benchmark);

    // Buying above market VWAP is a cost (positive slippage for buy)
    try std.testing.expect(report.vwap_slippage_bps > 0.0);
}

test "fill rate = 1.0 when all quantity filled" {
    var engine = try TcaEngine.init(std.testing.allocator);
    defer engine.deinit();

    const executions = [_]Execution{
        .{ .price = 10000, .quantity = 500, .timestamp = 1000, .side = .buy, .venue = "kraken" },
    };
    const benchmark = Benchmark{
        .arrival_price = 10000,
        .market_vwap = 10000,
        .close_price = 10000,
        .attempted_qty = 500,
    };

    const report = try engine.analyze(&executions, benchmark);

    try std.testing.expectApproxEqAbs(1.0, report.fill_rate, 0.001);
}

test "partial fill rate" {
    var engine = try TcaEngine.init(std.testing.allocator);
    defer engine.deinit();

    const executions = [_]Execution{
        .{ .price = 10000, .quantity = 250, .timestamp = 1000, .side = .buy, .venue = "kraken" },
    };
    const benchmark = Benchmark{
        .arrival_price = 10000,
        .market_vwap = 10000,
        .close_price = 10050,
        .attempted_qty = 500,
    };

    const report = try engine.analyze(&executions, benchmark);

    try std.testing.expectApproxEqAbs(0.5, report.fill_rate, 0.001);
}

test "single execution: timing_cost = 0 per spec edge case" {
    var engine = try TcaEngine.init(std.testing.allocator);
    defer engine.deinit();

    const executions = [_]Execution{
        .{ .price = 10020, .quantity = 100, .timestamp = 1000, .side = .buy, .venue = "kraken" },
    };
    const benchmark = Benchmark{
        .arrival_price = 10000,
        .market_vwap = 10010,
        .close_price = 10030,
        .attempted_qty = 100,
    };

    const report = try engine.analyze(&executions, benchmark);

    try std.testing.expectApproxEqAbs(0.0, report.timing_cost_bps, 0.001);
}
