const std = @import("std");
const messages = @import("messages");

// ---------------------------------------------------------------------------
// InstrumentId
// ---------------------------------------------------------------------------

test "InstrumentId: fromSlice stores bytes and length" {
    const id = messages.InstrumentId.fromSlice("BTC-USD");
    try std.testing.expectEqual(@as(u8, 7), id.len);
    try std.testing.expectEqualSlices(u8, "BTC-USD", id.slice());
}

test "InstrumentId: fromSlice with empty string" {
    const id = messages.InstrumentId.fromSlice("");
    try std.testing.expectEqual(@as(u8, 0), id.len);
    try std.testing.expectEqualSlices(u8, "", id.slice());
}

test "InstrumentId: fromSlice truncates at 32 bytes" {
    const long = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    const id = messages.InstrumentId.fromSlice(long);
    try std.testing.expectEqual(@as(u8, 32), id.len);
    try std.testing.expectEqualSlices(u8, long[0..32], id.slice());
}

test "InstrumentId: fromSlice with exactly 32 bytes" {
    const exact = "12345678901234567890123456789012";
    const id = messages.InstrumentId.fromSlice(exact);
    try std.testing.expectEqual(@as(u8, 32), id.len);
    try std.testing.expectEqualSlices(u8, exact, id.slice());
}

test "InstrumentId: slice returns correct sub-range" {
    const id = messages.InstrumentId.fromSlice("ETH");
    const s = id.slice();
    try std.testing.expectEqual(@as(usize, 3), s.len);
    try std.testing.expectEqual(@as(u8, 'E'), s[0]);
    try std.testing.expectEqual(@as(u8, 'T'), s[1]);
    try std.testing.expectEqual(@as(u8, 'H'), s[2]);
}

// ---------------------------------------------------------------------------
// PriceLevel
// ---------------------------------------------------------------------------

test "PriceLevel: struct creation with values" {
    const pl = messages.PriceLevel{ .price = 50000_00, .quantity = 1_500 };
    try std.testing.expectEqual(@as(i64, 50000_00), pl.price);
    try std.testing.expectEqual(@as(i64, 1_500), pl.quantity);
}

test "PriceLevel: zero values" {
    const pl = messages.PriceLevel{ .price = 0, .quantity = 0 };
    try std.testing.expectEqual(@as(i64, 0), pl.price);
    try std.testing.expectEqual(@as(i64, 0), pl.quantity);
}

test "PriceLevel: negative values" {
    const pl = messages.PriceLevel{ .price = -100, .quantity = -50 };
    try std.testing.expectEqual(@as(i64, -100), pl.price);
    try std.testing.expectEqual(@as(i64, -50), pl.quantity);
}

// ---------------------------------------------------------------------------
// OrderbookSnapshot
// ---------------------------------------------------------------------------

test "OrderbookSnapshot: default counts are settable" {
    var snap: messages.OrderbookSnapshot = undefined;
    snap.instrument = messages.InstrumentId.fromSlice("BTC-USD");
    snap.bid_count = 5;
    snap.ask_count = 3;
    try std.testing.expectEqual(@as(u8, 5), snap.bid_count);
    try std.testing.expectEqual(@as(u8, 3), snap.ask_count);
    try std.testing.expectEqualSlices(u8, "BTC-USD", snap.instrument.slice());
}

test "OrderbookSnapshot: bids and asks array capacity is 20" {
    try std.testing.expectEqual(@as(usize, 20), @typeInfo(@TypeOf(@as(messages.OrderbookSnapshot, undefined).bids)).array.len);
    try std.testing.expectEqual(@as(usize, 20), @typeInfo(@TypeOf(@as(messages.OrderbookSnapshot, undefined).asks)).array.len);
}

// ---------------------------------------------------------------------------
// PositionUpdate
// ---------------------------------------------------------------------------

test "PositionUpdate: struct fields" {
    const pu = messages.PositionUpdate{
        .instrument = messages.InstrumentId.fromSlice("ETH-USD"),
        .quantity = 10,
        .avg_cost = 3200_00,
        .unrealized_pnl = 500_00,
        .realized_pnl = 100_00,
    };
    try std.testing.expectEqual(@as(i64, 10), pu.quantity);
    try std.testing.expectEqual(@as(i64, 3200_00), pu.avg_cost);
    try std.testing.expectEqual(@as(i64, 500_00), pu.unrealized_pnl);
    try std.testing.expectEqual(@as(i64, 100_00), pu.realized_pnl);
    try std.testing.expectEqualSlices(u8, "ETH-USD", pu.instrument.slice());
}

// ---------------------------------------------------------------------------
// OrderUpdate
// ---------------------------------------------------------------------------

test "OrderUpdate: buy side and pending status" {
    const ou = messages.OrderUpdate{
        .id = 42,
        .instrument = messages.InstrumentId.fromSlice("SOL-USD"),
        .side = 0, // buy
        .quantity = 100,
        .price = 150_00,
        .status = 0, // pending
        .filled_qty = 0,
    };
    try std.testing.expectEqual(@as(u64, 42), ou.id);
    try std.testing.expectEqual(@as(u8, 0), ou.side);
    try std.testing.expectEqual(@as(u8, 0), ou.status);
    try std.testing.expectEqual(@as(i64, 0), ou.filled_qty);
}

test "OrderUpdate: sell side and filled status" {
    const ou = messages.OrderUpdate{
        .id = 99,
        .instrument = messages.InstrumentId.fromSlice("BTC-USD"),
        .side = 1, // sell
        .quantity = 50,
        .price = 60000_00,
        .status = 2, // filled
        .filled_qty = 50,
    };
    try std.testing.expectEqual(@as(u8, 1), ou.side);
    try std.testing.expectEqual(@as(u8, 2), ou.status);
    try std.testing.expectEqual(@as(i64, 50), ou.filled_qty);
    try std.testing.expectEqual(ou.quantity, ou.filled_qty);
}

test "OrderUpdate: cancelled and rejected status values" {
    var ou: messages.OrderUpdate = undefined;
    ou.status = 3; // cancelled
    try std.testing.expectEqual(@as(u8, 3), ou.status);
    ou.status = 4; // rejected
    try std.testing.expectEqual(@as(u8, 4), ou.status);
}

// ---------------------------------------------------------------------------
// OrderRequest
// ---------------------------------------------------------------------------

test "OrderRequest: buy order" {
    const req = messages.OrderRequest{
        .instrument = messages.InstrumentId.fromSlice("BTC-USD"),
        .side = 0, // buy
        .quantity = 1,
        .price = 50000_00,
    };
    try std.testing.expectEqual(@as(u8, 0), req.side);
    try std.testing.expectEqual(@as(i64, 1), req.quantity);
    try std.testing.expectEqual(@as(i64, 50000_00), req.price);
}

test "OrderRequest: sell order" {
    const req = messages.OrderRequest{
        .instrument = messages.InstrumentId.fromSlice("ETH-USD"),
        .side = 1, // sell
        .quantity = 25,
        .price = 3200_00,
    };
    try std.testing.expectEqual(@as(u8, 1), req.side);
    try std.testing.expectEqual(@as(i64, 25), req.quantity);
}

// ---------------------------------------------------------------------------
// StatusUpdate
// ---------------------------------------------------------------------------

test "StatusUpdate: connected state" {
    var su: messages.StatusUpdate = undefined;
    su.tick = 1000;
    su.engine_time_ns = 123456789;
    su.instrument_count = 5;
    su.connected = true;
    su.strategy_state_len = 0;
    try std.testing.expectEqual(@as(u64, 1000), su.tick);
    try std.testing.expectEqual(@as(u128, 123456789), su.engine_time_ns);
    try std.testing.expectEqual(@as(u8, 5), su.instrument_count);
    try std.testing.expect(su.connected);
}

test "StatusUpdate: disconnected state" {
    var su: messages.StatusUpdate = undefined;
    su.connected = false;
    try std.testing.expect(!su.connected);
}

test "StatusUpdate: strategy_state buffer capacity is 64" {
    try std.testing.expectEqual(@as(usize, 64), @typeInfo(@TypeOf(@as(messages.StatusUpdate, undefined).strategy_state)).array.len);
}

test "StatusUpdate: vpin_scores and vpin_valid arrays have 8 slots" {
    try std.testing.expectEqual(@as(usize, 8), @typeInfo(@TypeOf(@as(messages.StatusUpdate, undefined).vpin_scores)).array.len);
    try std.testing.expectEqual(@as(usize, 8), @typeInfo(@TypeOf(@as(messages.StatusUpdate, undefined).vpin_valid)).array.len);
}

// ---------------------------------------------------------------------------
// TcaReportEvent
// ---------------------------------------------------------------------------

test "TcaReportEvent: struct fields" {
    const tca = messages.TcaReportEvent{
        .instrument = messages.InstrumentId.fromSlice("BTC-USD"),
        .is_cost_bps = 25,
        .fill_rate_pct = 95,
        .market_impact_bps = 10,
    };
    try std.testing.expectEqual(@as(i64, 25), tca.is_cost_bps);
    try std.testing.expectEqual(@as(u8, 95), tca.fill_rate_pct);
    try std.testing.expectEqual(@as(i64, 10), tca.market_impact_bps);
}

// ---------------------------------------------------------------------------
// EodReportEvent
// ---------------------------------------------------------------------------

test "EodReportEvent: pnl fields and tick" {
    const eod = messages.EodReportEvent{
        .realized_pnl = 1000,
        .unrealized_pnl = -200,
        .total_pnl = 800,
        .tick = 86400,
    };
    try std.testing.expectEqual(@as(i64, 1000), eod.realized_pnl);
    try std.testing.expectEqual(@as(i64, -200), eod.unrealized_pnl);
    try std.testing.expectEqual(@as(i64, 800), eod.total_pnl);
    try std.testing.expectEqual(@as(u64, 86400), eod.tick);
}

test "EodReportEvent: total equals realized + unrealized" {
    const eod = messages.EodReportEvent{
        .realized_pnl = 500,
        .unrealized_pnl = 300,
        .total_pnl = 800,
        .tick = 1,
    };
    try std.testing.expectEqual(eod.realized_pnl + eod.unrealized_pnl, eod.total_pnl);
}

// ---------------------------------------------------------------------------
// CandleUpdate
// ---------------------------------------------------------------------------

test "CandleUpdate: OHLCV fields" {
    const candle = messages.CandleUpdate{
        .instrument = messages.InstrumentId.fromSlice("BTC-USD"),
        .open = 50000,
        .high = 51000,
        .low = 49500,
        .close = 50800,
        .volume = 1234,
        .timestamp = 1700000000,
    };
    try std.testing.expectEqual(@as(i64, 50000), candle.open);
    try std.testing.expectEqual(@as(i64, 51000), candle.high);
    try std.testing.expectEqual(@as(i64, 49500), candle.low);
    try std.testing.expectEqual(@as(i64, 50800), candle.close);
    try std.testing.expectEqual(@as(i64, 1234), candle.volume);
    try std.testing.expectEqual(@as(u64, 1700000000), candle.timestamp);
}

test "CandleUpdate: high >= low invariant" {
    const candle = messages.CandleUpdate{
        .instrument = messages.InstrumentId.fromSlice("X"),
        .open = 100,
        .high = 200,
        .low = 50,
        .close = 150,
        .volume = 10,
        .timestamp = 0,
    };
    try std.testing.expect(candle.high >= candle.low);
}

// ---------------------------------------------------------------------------
// TradeUpdate
// ---------------------------------------------------------------------------

test "TradeUpdate: fields and trader tag" {
    var tu: messages.TradeUpdate = undefined;
    tu.instrument = messages.InstrumentId.fromSlice("ETH-USD");
    tu.side = 0; // buy
    tu.quantity = 5;
    tu.price = 3200_00;
    tu.tick = 42;
    @memcpy(tu.trader_tag[0..2], "MM");
    tu.trader_tag_len = 2;
    try std.testing.expectEqual(@as(u8, 0), tu.side);
    try std.testing.expectEqual(@as(i64, 5), tu.quantity);
    try std.testing.expectEqualSlices(u8, "MM", tu.trader_tag[0..tu.trader_tag_len]);
}

test "TradeUpdate: trader_tag buffer capacity is 8" {
    try std.testing.expectEqual(@as(usize, 8), @typeInfo(@TypeOf(@as(messages.TradeUpdate, undefined).trader_tag)).array.len);
}

// ---------------------------------------------------------------------------
// EngineEvent (tagged union)
// ---------------------------------------------------------------------------

test "EngineEvent: tick variant" {
    const ev = messages.EngineEvent{ .tick = 100 };
    switch (ev) {
        .tick => |t| try std.testing.expectEqual(@as(u64, 100), t),
        else => return error.UnexpectedVariant,
    }
}

test "EngineEvent: shutdown_ack variant" {
    const ev = messages.EngineEvent{ .shutdown_ack = {} };
    switch (ev) {
        .shutdown_ack => {},
        else => return error.UnexpectedVariant,
    }
}

test "EngineEvent: orderbook_snapshot variant" {
    var snap: messages.OrderbookSnapshot = undefined;
    snap.instrument = messages.InstrumentId.fromSlice("BTC-USD");
    snap.bid_count = 1;
    snap.ask_count = 1;
    const ev = messages.EngineEvent{ .orderbook_snapshot = snap };
    switch (ev) {
        .orderbook_snapshot => |s| {
            try std.testing.expectEqualSlices(u8, "BTC-USD", s.instrument.slice());
            try std.testing.expectEqual(@as(u8, 1), s.bid_count);
        },
        else => return error.UnexpectedVariant,
    }
}

test "EngineEvent: position_update variant" {
    const pu = messages.PositionUpdate{
        .instrument = messages.InstrumentId.fromSlice("ETH"),
        .quantity = 10,
        .avg_cost = 100,
        .unrealized_pnl = 0,
        .realized_pnl = 0,
    };
    const ev = messages.EngineEvent{ .position_update = pu };
    switch (ev) {
        .position_update => |p| try std.testing.expectEqual(@as(i64, 10), p.quantity),
        else => return error.UnexpectedVariant,
    }
}

test "EngineEvent: candle_update variant" {
    const candle = messages.CandleUpdate{
        .instrument = messages.InstrumentId.fromSlice("SOL"),
        .open = 1,
        .high = 2,
        .low = 0,
        .close = 1,
        .volume = 100,
        .timestamp = 999,
    };
    const ev = messages.EngineEvent{ .candle_update = candle };
    switch (ev) {
        .candle_update => |c| try std.testing.expectEqual(@as(u64, 999), c.timestamp),
        else => return error.UnexpectedVariant,
    }
}

test "EngineEvent: trade_update variant" {
    var tu: messages.TradeUpdate = undefined;
    tu.instrument = messages.InstrumentId.fromSlice("X");
    tu.side = 1;
    tu.quantity = 7;
    tu.price = 42;
    tu.tick = 1;
    tu.trader_tag_len = 0;
    const ev = messages.EngineEvent{ .trade_update = tu };
    switch (ev) {
        .trade_update => |t| try std.testing.expectEqual(@as(i64, 7), t.quantity),
        else => return error.UnexpectedVariant,
    }
}

test "EngineEvent: tca_report variant" {
    const tca = messages.TcaReportEvent{
        .instrument = messages.InstrumentId.fromSlice("BTC"),
        .is_cost_bps = 5,
        .fill_rate_pct = 80,
        .market_impact_bps = 3,
    };
    const ev = messages.EngineEvent{ .tca_report = tca };
    switch (ev) {
        .tca_report => |r| try std.testing.expectEqual(@as(u8, 80), r.fill_rate_pct),
        else => return error.UnexpectedVariant,
    }
}

test "EngineEvent: eod_report variant" {
    const eod = messages.EodReportEvent{
        .realized_pnl = 100,
        .unrealized_pnl = 50,
        .total_pnl = 150,
        .tick = 10,
    };
    const ev = messages.EngineEvent{ .eod_report = eod };
    switch (ev) {
        .eod_report => |r| try std.testing.expectEqual(@as(i64, 150), r.total_pnl),
        else => return error.UnexpectedVariant,
    }
}

test "EngineEvent: all variant tags exist" {
    // Compile-time check: ensure all union fields are accessible
    const fields = @typeInfo(messages.EngineEvent).@"union".fields;
    try std.testing.expectEqual(@as(usize, 11), fields.len);
}

// ---------------------------------------------------------------------------
// UserCommand (tagged union)
// ---------------------------------------------------------------------------

test "UserCommand: quit variant" {
    const cmd = messages.UserCommand{ .quit = {} };
    switch (cmd) {
        .quit => {},
        else => return error.UnexpectedVariant,
    }
}

test "UserCommand: select_instrument variant" {
    const id = messages.InstrumentId.fromSlice("BTC-USD");
    const cmd = messages.UserCommand{ .select_instrument = id };
    switch (cmd) {
        .select_instrument => |inst| try std.testing.expectEqualSlices(u8, "BTC-USD", inst.slice()),
        else => return error.UnexpectedVariant,
    }
}

test "UserCommand: submit_order variant" {
    const req = messages.OrderRequest{
        .instrument = messages.InstrumentId.fromSlice("ETH-USD"),
        .side = 0,
        .quantity = 10,
        .price = 3000,
    };
    const cmd = messages.UserCommand{ .submit_order = req };
    switch (cmd) {
        .submit_order => |o| {
            try std.testing.expectEqual(@as(i64, 10), o.quantity);
            try std.testing.expectEqual(@as(i64, 3000), o.price);
        },
        else => return error.UnexpectedVariant,
    }
}

test "UserCommand: cancel_order variant" {
    const cmd = messages.UserCommand{ .cancel_order = 42 };
    switch (cmd) {
        .cancel_order => |id| try std.testing.expectEqual(@as(u64, 42), id),
        else => return error.UnexpectedVariant,
    }
}

test "UserCommand: all variant tags exist" {
    const fields = @typeInfo(messages.UserCommand).@"union".fields;
    try std.testing.expectEqual(@as(usize, 4), fields.len);
}

// ---------------------------------------------------------------------------
// Size invariants — types must be fixed-size and non-zero
// ---------------------------------------------------------------------------

test "all message types are non-zero size" {
    try std.testing.expect(@sizeOf(messages.InstrumentId) > 0);
    try std.testing.expect(@sizeOf(messages.PriceLevel) > 0);
    try std.testing.expect(@sizeOf(messages.OrderbookSnapshot) > 0);
    try std.testing.expect(@sizeOf(messages.PositionUpdate) > 0);
    try std.testing.expect(@sizeOf(messages.OrderUpdate) > 0);
    try std.testing.expect(@sizeOf(messages.OrderRequest) > 0);
    try std.testing.expect(@sizeOf(messages.StatusUpdate) > 0);
    try std.testing.expect(@sizeOf(messages.TcaReportEvent) > 0);
    try std.testing.expect(@sizeOf(messages.EodReportEvent) > 0);
    try std.testing.expect(@sizeOf(messages.CandleUpdate) > 0);
    try std.testing.expect(@sizeOf(messages.TradeUpdate) > 0);
    try std.testing.expect(@sizeOf(messages.EngineEvent) > 0);
    try std.testing.expect(@sizeOf(messages.UserCommand) > 0);
}

test "InstrumentId size matches buf + len" {
    // 32-byte buffer + 1-byte length = 33 bytes (may have padding)
    try std.testing.expect(@sizeOf(messages.InstrumentId) >= 33);
}

test "PriceLevel size is two i64 fields" {
    try std.testing.expectEqual(@as(usize, 16), @sizeOf(messages.PriceLevel));
}
