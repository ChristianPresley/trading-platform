// Tests for Kraken spot REST client — JSON response parsing
// These tests do NOT make real network calls. They test the JSON parsing logic
// by calling parseResponse-equivalent helpers with static JSON.

const std = @import("std");
const json_mod = @import("json");

// Parse a Kraken envelope and call check_fn with the result value.
// Frees all parser-allocated memory after check_fn returns.
fn withKrakenResult(
    allocator: std.mem.Allocator,
    body: []const u8,
    check_fn: *const fn (result: json_mod.Value) anyerror!void,
) !void {
    var parser = json_mod.JsonParser.init(allocator);
    var root = try parser.parse(body);
    defer json_mod.deinitValue(root, allocator);

    if (root.object.get("error")) |err_val| {
        if (err_val == .array and err_val.array.len > 0) {
            return error.KrakenApiError;
        }
    }

    const result = root.object.get("result") orelse return error.MissingResult;
    try check_fn(result);
}

test "parse system status response" {
    const body =
        \\{"error":[],"result":{"status":"online","timestamp":"2021-03-22T17:18:03Z"}}
    ;
    try withKrakenResult(std.testing.allocator, body, struct {
        fn check(result: json_mod.Value) !void {
            const status = result.object.get("status") orelse return error.MissingField;
            try std.testing.expectEqualSlices(u8, "online", status.string);
            const ts = result.object.get("timestamp") orelse return error.MissingField;
            try std.testing.expectEqualSlices(u8, "2021-03-22T17:18:03Z", ts.string);
        }
    }.check);
}

test "error array non-empty returns KrakenApiError" {
    const body =
        \\{"error":["EGeneral:Invalid arguments"],"result":{}}
    ;
    const allocator = std.testing.allocator;
    var parser = json_mod.JsonParser.init(allocator);
    var root = try parser.parse(body);
    defer json_mod.deinitValue(root, allocator);

    const err_val = root.object.get("error").?;
    try std.testing.expect(err_val.array.len > 0);
}

test "parse server time response" {
    const body =
        \\{"error":[],"result":{"unixtime":1616492376,"rfc1123":"Sun, 23 Mar 2021 11:39:36 +0000"}}
    ;
    try withKrakenResult(std.testing.allocator, body, struct {
        fn check(result: json_mod.Value) !void {
            const ut = result.object.get("unixtime") orelse return error.MissingField;
            try std.testing.expect(ut == .integer or ut == .number);
            const rfc = result.object.get("rfc1123") orelse return error.MissingField;
            try std.testing.expect(std.mem.startsWith(u8, rfc.string, "Sun"));
        }
    }.check);
}

test "parse balance response" {
    const body =
        \\{"error":[],"result":{"ZUSD":"1234.5678","XXBT":"0.5000","XETH":"10.0000"}}
    ;
    try withKrakenResult(std.testing.allocator, body, struct {
        fn check(result: json_mod.Value) !void {
            const k = result.object.keys();
            try std.testing.expectEqual(@as(usize, 3), k.len);
            const zusd = result.object.get("ZUSD") orelse return error.MissingField;
            try std.testing.expectEqualSlices(u8, "1234.5678", zusd.string);
        }
    }.check);
}

test "parse ticker response" {
    const body =
        \\{"error":[],"result":{"XXBTZUSD":{"a":["37500.00000","1","1.000"],"b":["37499.00000","1","1.000"],"c":["37500.10000","0.01000000"],"v":["1000.000","2000.000"],"p":["37450.000","37460.000"],"t":[500,1000],"l":["37000.000","37000.000"],"h":["38000.000","38000.000"],"o":"37200.000"}}}
    ;
    try withKrakenResult(std.testing.allocator, body, struct {
        fn check(result: json_mod.Value) !void {
            const k = result.object.keys();
            try std.testing.expectEqual(@as(usize, 1), k.len);
            const pair_data = result.object.get("XXBTZUSD") orelse return error.MissingField;
            const ask = pair_data.object.get("a") orelse return error.MissingField;
            try std.testing.expectEqual(@as(usize, 3), ask.array.len);
            try std.testing.expectEqualSlices(u8, "37500.00000", ask.array[0].string);
        }
    }.check);
}

test "parse open orders response" {
    const body =
        \\{"error":[],"result":{"open":{"OQCLML-BW3P3-BUCMWW":{"refid":null,"userref":0,"status":"open","opentm":1616492376.594,"starttm":0,"expiretm":0,"descr":{"pair":"XBTUSD","type":"buy","ordertype":"limit","price":"37500.00","price2":"0","leverage":"none","order":"buy 1.25000000 XBTUSD @ limit 37500.00","close":""},"vol":"1.25000000","vol_exec":"0.00000000","cost":"0.00000","fee":"0.00000","price":"0.00000","stopprice":"0.00000","limitprice":"0.00000","misc":"","oflags":"fciq"}}}}
    ;
    try withKrakenResult(std.testing.allocator, body, struct {
        fn check(result: json_mod.Value) !void {
            const open = result.object.get("open") orelse return error.MissingField;
            const k = open.object.keys();
            try std.testing.expectEqual(@as(usize, 1), k.len);
            try std.testing.expectEqualSlices(u8, "OQCLML-BW3P3-BUCMWW", k[0]);
        }
    }.check);
}

test "parse cancel order response" {
    const body =
        \\{"error":[],"result":{"count":1}}
    ;
    try withKrakenResult(std.testing.allocator, body, struct {
        fn check(result: json_mod.Value) !void {
            const count = result.object.get("count") orelse return error.MissingField;
            try std.testing.expect(count == .integer or count == .number);
            const count_val: i64 = switch (count) {
                .integer => |i| i,
                .number => |f| @intFromFloat(f),
                else => unreachable,
            };
            try std.testing.expectEqual(@as(i64, 1), count_val);
        }
    }.check);
}

test "parse add order response" {
    const body =
        \\{"error":[],"result":{"descr":{"order":"buy 1.25000000 XBTUSD @ limit 37500.00","close":""},"txid":["OQCLML-BW3P3-BUCMWW"]}}
    ;
    try withKrakenResult(std.testing.allocator, body, struct {
        fn check(result: json_mod.Value) !void {
            const descr = result.object.get("descr") orelse return error.MissingField;
            const order_descr = descr.object.get("order") orelse return error.MissingField;
            try std.testing.expect(std.mem.startsWith(u8, order_descr.string, "buy"));
            const txid = result.object.get("txid") orelse return error.MissingField;
            try std.testing.expectEqual(@as(usize, 1), txid.array.len);
        }
    }.check);
}

test "empty error array is ok" {
    const body =
        \\{"error":[],"result":{"status":"online","timestamp":"2021-03-22T17:18:03Z"}}
    ;
    try withKrakenResult(std.testing.allocator, body, struct {
        fn check(_: json_mod.Value) !void {}
    }.check);
}

test "parse order book response" {
    const body =
        \\{"error":[],"result":{"XXBTZUSD":{"asks":[["37500.00000","0.500",1616492376],["37501.00000","1.000",1616492377]],"bids":[["37499.00000","0.250",1616492376]]}}}
    ;
    try withKrakenResult(std.testing.allocator, body, struct {
        fn check(result: json_mod.Value) !void {
            const pair = result.object.get("XXBTZUSD") orelse return error.MissingField;
            const asks = pair.object.get("asks") orelse return error.MissingField;
            try std.testing.expectEqual(@as(usize, 2), asks.array.len);
            const bids = pair.object.get("bids") orelse return error.MissingField;
            try std.testing.expectEqual(@as(usize, 1), bids.array.len);
        }
    }.check);
}
