// Kraken spot REST client — public + private endpoints.
// All responses parse the Kraken {"error": [], "result": {...}} envelope.

const std = @import("std");
const http_mod = @import("http_client");
const json_mod = @import("json");
const auth_mod = @import("spot_auth");
const types = @import("spot_types");

const KRAKEN_BASE_URL = "https://api.kraken.com";

pub const SpotRestClient = struct {
    allocator: std.mem.Allocator,
    http: http_mod.HttpClient,
    auth: ?auth_mod.SpotAuth,

    pub fn init(allocator: std.mem.Allocator, auth: ?auth_mod.SpotAuth) !SpotRestClient {
        return SpotRestClient{
            .allocator = allocator,
            .http = try http_mod.HttpClient.init(allocator),
            .auth = auth,
        };
    }

    pub fn deinit(self: *SpotRestClient) void {
        self.http.deinit();
    }

    // ---- Internal helpers ----

    fn publicGet(self: *SpotRestClient, path: []const u8) !json_mod.Value {
        var url_buf: [256]u8 = undefined;
        const url = try std.fmt.bufPrint(&url_buf, "{s}{s}", .{ KRAKEN_BASE_URL, path });
        var resp = try self.http.get(url);
        defer resp.deinit();
        return self.parseKrakenResponse(resp.body);
    }

    fn publicGetWithQuery(self: *SpotRestClient, path: []const u8, query: []const u8) !json_mod.Value {
        var url_buf: [512]u8 = undefined;
        const url = try std.fmt.bufPrint(&url_buf, "{s}{s}?{s}", .{ KRAKEN_BASE_URL, path, query });
        var resp = try self.http.get(url);
        defer resp.deinit();
        return self.parseKrakenResponse(resp.body);
    }

    fn privatePost(self: *SpotRestClient, path: []const u8, post_data: []const u8) !json_mod.Value {
        var a = self.auth orelse return error.AuthRequired;
        const nonce = a.nextNonce();
        self.auth = a; // update nonce counter

        // Build post data with nonce
        var body_buf: [2048]u8 = undefined;
        const body = if (post_data.len > 0)
            try std.fmt.bufPrint(&body_buf, "nonce={d}&{s}", .{ nonce, post_data })
        else
            try std.fmt.bufPrint(&body_buf, "nonce={d}", .{nonce});

        // Compute signature
        var sig_out: [88]u8 = undefined;
        var auth_copy = self.auth.?;
        const sig = auth_copy.sign(path, nonce, body, &sig_out);
        self.auth = auth_copy;

        var url_buf: [256]u8 = undefined;
        const url = try std.fmt.bufPrint(&url_buf, "{s}{s}", .{ KRAKEN_BASE_URL, path });

        const headers = [_]http_mod.Header{
            .{ .name = "API-Key", .value = auth_copy.api_key },
            .{ .name = "API-Sign", .value = sig },
            .{ .name = "Content-Type", .value = "application/x-www-form-urlencoded" },
        };

        var resp = try self.http.post(url, body, &headers);
        defer resp.deinit();
        return self.parseKrakenResponse(resp.body);
    }

    fn parseKrakenResponse(self: *SpotRestClient, body: []const u8) !json_mod.Value {
        var parser = json_mod.JsonParser.init(self.allocator);
        defer parser.deinit();
        const root = try parser.parse(body);

        // Check error array
        if (root.object.get("error")) |err_val| {
            if (err_val == .array and err_val.array.len > 0) {
                // Non-empty error array
                return error.KrakenApiError;
            }
        }

        const result = root.object.get("result") orelse return error.MissingResult;
        return result;
    }

    // ---- Public endpoints ----

    pub fn systemStatus(self: *SpotRestClient) !types.SystemStatus {
        const result = try self.publicGet("/0/public/SystemStatus");
        const status_val = result.object.get("status") orelse return error.MissingField;
        const ts_val = result.object.get("timestamp") orelse return error.MissingField;
        return types.SystemStatus{
            .status = status_val.string,
            .timestamp = ts_val.string,
        };
    }

    pub fn serverTime(self: *SpotRestClient) !types.ServerTime {
        const result = try self.publicGet("/0/public/Time");
        const ut_val = result.object.get("unixtime") orelse return error.MissingField;
        const rfc_val = result.object.get("rfc1123") orelse return error.MissingField;
        const unixtime: i64 = switch (ut_val) {
            .integer => |i| i,
            .number => |f| @intFromFloat(f),
            else => return error.TypeMismatch,
        };
        return types.ServerTime{
            .unixtime = unixtime,
            .rfc1123 = rfc_val.string,
        };
    }

    pub fn assetPairs(self: *SpotRestClient, pairs: ?[]const []const u8) !types.AssetPairsResult {
        var result: json_mod.Value = undefined;
        if (pairs) |ps| {
            var query_buf: [1024]u8 = undefined;
            var qstream = std.io.fixedBufferStream(&query_buf);
            const qw = qstream.writer();
            try qw.writeAll("pair=");
            for (ps, 0..) |p, i| {
                if (i > 0) try qw.writeByte(',');
                try qw.writeAll(p);
            }
            result = try self.publicGetWithQuery("/0/public/AssetPairs", qstream.getWritten());
        } else {
            result = try self.publicGet("/0/public/AssetPairs");
        }

        // Collect pair names from the result object keys
        const k = result.object.keys();
        var pair_list = std.ArrayList([]const u8).init(self.allocator);
        errdefer {
            for (pair_list.items) |p| self.allocator.free(p);
            pair_list.deinit();
        }
        for (k) |key| {
            try pair_list.append(try self.allocator.dupe(u8, key));
        }
        return types.AssetPairsResult{
            .allocator = self.allocator,
            .pairs = try pair_list.toOwnedSlice(),
        };
    }

    pub fn ticker(self: *SpotRestClient, pairs_list: []const []const u8) !types.TickerResult {
        var query_buf: [512]u8 = undefined;
        var qstream = std.io.fixedBufferStream(&query_buf);
        const qw = qstream.writer();
        try qw.writeAll("pair=");
        for (pairs_list, 0..) |p, i| {
            if (i > 0) try qw.writeByte(',');
            try qw.writeAll(p);
        }
        const result = try self.publicGetWithQuery("/0/public/Ticker", qstream.getWritten());

        // Get first pair's data
        const k = result.object.keys();
        if (k.len == 0) return error.EmptyResult;
        const pair_name = k[0];
        const ticker_data = result.object.get(pair_name) orelse return error.MissingField;

        // Extract ask[0], bid[0], c[0] (last trade closed)
        const ask_arr = ticker_data.object.get("a") orelse return error.MissingField;
        const bid_arr = ticker_data.object.get("b") orelse return error.MissingField;
        const last_arr = ticker_data.object.get("c") orelse return error.MissingField;

        const ask_price = if (ask_arr.array.len > 0) ask_arr.array[0].string else "";
        const bid_price = if (bid_arr.array.len > 0) bid_arr.array[0].string else "";
        const last_price = if (last_arr.array.len > 0) last_arr.array[0].string else "";

        return types.TickerResult{
            .allocator = self.allocator,
            .pair = try self.allocator.dupe(u8, pair_name),
            .ask_price = try self.allocator.dupe(u8, ask_price),
            .bid_price = try self.allocator.dupe(u8, bid_price),
            .last_price = try self.allocator.dupe(u8, last_price),
        };
    }

    pub fn ohlc(self: *SpotRestClient, pair: []const u8, interval: u32) !types.OhlcResult {
        var query_buf: [128]u8 = undefined;
        const query = try std.fmt.bufPrint(&query_buf, "pair={s}&interval={d}", .{ pair, interval });
        const result = try self.publicGetWithQuery("/0/public/OHLC", query);

        // The result has "last" field and a pair key with OHLC data
        const last_val = result.object.get("last") orelse return error.MissingField;
        const last_ts: i64 = switch (last_val) {
            .integer => |i| i,
            .number => |f| @intFromFloat(f),
            else => return error.TypeMismatch,
        };

        // Find the pair data array (first key that isn't "last")
        const k = result.object.keys();
        var ohlc_arr: ?json_mod.Value = null;
        var found_pair: []const u8 = pair;
        for (k) |key| {
            if (!std.mem.eql(u8, key, "last")) {
                ohlc_arr = result.object.get(key);
                found_pair = key;
                break;
            }
        }

        const arr = (ohlc_arr orelse return error.MissingField).array;
        var entries = try self.allocator.alloc(types.OhlcEntry, arr.len);
        errdefer self.allocator.free(entries);

        var i: usize = 0;
        errdefer {
            for (entries[0..i]) |e| {
                self.allocator.free(e.open);
                self.allocator.free(e.high);
                self.allocator.free(e.low);
                self.allocator.free(e.close);
                self.allocator.free(e.vwap);
                self.allocator.free(e.volume);
            }
        }

        for (arr) |item| {
            const row = item.array;
            if (row.len < 8) return error.MalformedOhlc;
            const time: i64 = switch (row[0]) {
                .integer => |v| v,
                .number => |v| @intFromFloat(v),
                else => return error.TypeMismatch,
            };
            const count: u64 = switch (row[7]) {
                .integer => |v| @intCast(v),
                .number => |v| @intFromFloat(v),
                else => return error.TypeMismatch,
            };
            entries[i] = types.OhlcEntry{
                .time = time,
                .open = try self.allocator.dupe(u8, row[1].string),
                .high = try self.allocator.dupe(u8, row[2].string),
                .low = try self.allocator.dupe(u8, row[3].string),
                .close = try self.allocator.dupe(u8, row[4].string),
                .vwap = try self.allocator.dupe(u8, row[5].string),
                .volume = try self.allocator.dupe(u8, row[6].string),
                .count = count,
            };
            i += 1;
        }

        return types.OhlcResult{
            .allocator = self.allocator,
            .pair = try self.allocator.dupe(u8, found_pair),
            .entries = entries,
            .last = last_ts,
        };
    }

    pub fn orderBook(self: *SpotRestClient, pair: []const u8, count: ?u16) !types.OrderBookResult {
        var query_buf: [128]u8 = undefined;
        const query = if (count) |c|
            try std.fmt.bufPrint(&query_buf, "pair={s}&count={d}", .{ pair, c })
        else
            try std.fmt.bufPrint(&query_buf, "pair={s}", .{pair});
        const result = try self.publicGetWithQuery("/0/public/Depth", query);

        const k = result.object.keys();
        if (k.len == 0) return error.EmptyResult;
        const pair_data = result.object.get(k[0]) orelse return error.MissingField;

        const asks_val = pair_data.object.get("asks") orelse return error.MissingField;
        const bids_val = pair_data.object.get("bids") orelse return error.MissingField;

        const asks = try self.parseBookSide(asks_val.array);
        errdefer {
            for (asks) |e| {
                self.allocator.free(e.price);
                self.allocator.free(e.volume);
            }
            self.allocator.free(asks);
        }
        const bids = try self.parseBookSide(bids_val.array);

        return types.OrderBookResult{
            .allocator = self.allocator,
            .pair = try self.allocator.dupe(u8, k[0]),
            .asks = asks,
            .bids = bids,
        };
    }

    fn parseBookSide(self: *SpotRestClient, arr: []json_mod.Value) ![]types.OrderBookEntry {
        var entries = try self.allocator.alloc(types.OrderBookEntry, arr.len);
        var i: usize = 0;
        errdefer {
            for (entries[0..i]) |e| {
                self.allocator.free(e.price);
                self.allocator.free(e.volume);
            }
            self.allocator.free(entries);
        }
        for (arr) |item| {
            const row = item.array;
            if (row.len < 2) return error.MalformedOrderBook;
            const ts: i64 = if (row.len > 2) switch (row[2]) {
                .integer => |v| v,
                .number => |v| @intFromFloat(v),
                else => 0,
            } else 0;
            entries[i] = types.OrderBookEntry{
                .price = try self.allocator.dupe(u8, row[0].string),
                .volume = try self.allocator.dupe(u8, row[1].string),
                .timestamp = ts,
            };
            i += 1;
        }
        return entries;
    }

    // ---- Private endpoints ----

    pub fn getBalance(self: *SpotRestClient) !types.BalanceResult {
        const result = try self.privatePost("/0/private/Balance", "");
        const k = result.object.keys();
        var currencies = try self.allocator.alloc([]const u8, k.len);
        var balances = try self.allocator.alloc([]const u8, k.len);
        var i: usize = 0;
        errdefer {
            for (currencies[0..i]) |c| self.allocator.free(c);
            for (balances[0..i]) |b| self.allocator.free(b);
            self.allocator.free(currencies);
            self.allocator.free(balances);
        }
        for (k) |key| {
            const val = result.object.get(key) orelse continue;
            currencies[i] = try self.allocator.dupe(u8, key);
            balances[i] = try self.allocator.dupe(u8, val.string);
            i += 1;
        }
        return types.BalanceResult{
            .allocator = self.allocator,
            .currencies = currencies[0..i],
            .balances = balances[0..i],
        };
    }

    pub fn tradeBalance(self: *SpotRestClient, asset: ?[]const u8) !types.TradeBalanceResult {
        var body_buf: [64]u8 = undefined;
        const body = if (asset) |a|
            try std.fmt.bufPrint(&body_buf, "asset={s}", .{a})
        else
            "";
        const result = try self.privatePost("/0/private/TradeBalance", body);

        fn getStr(obj: json_mod.Value, key: []const u8, alloc: std.mem.Allocator) ![]const u8 {
            const v = obj.object.get(key) orelse return alloc.dupe(u8, "0");
            return alloc.dupe(u8, v.string);
        }

        return types.TradeBalanceResult{
            .allocator = self.allocator,
            .eb = try getStr(result, "eb", self.allocator),
            .tb = try getStr(result, "tb", self.allocator),
            .m  = try getStr(result, "m",  self.allocator),
            .n  = try getStr(result, "n",  self.allocator),
            .c  = try getStr(result, "c",  self.allocator),
            .v  = try getStr(result, "v",  self.allocator),
            .e  = try getStr(result, "e",  self.allocator),
            .mf = try getStr(result, "mf", self.allocator),
        };
    }

    pub fn openOrders(self: *SpotRestClient) !types.OpenOrdersResult {
        const result = try self.privatePost("/0/private/OpenOrders", "");
        const open = result.object.get("open") orelse return error.MissingField;
        return self.parseOrderList(open);
    }

    pub fn closedOrders(self: *SpotRestClient) !types.ClosedOrdersResult {
        const result = try self.privatePost("/0/private/ClosedOrders", "");
        const closed = result.object.get("closed") orelse return error.MissingField;
        const count_val = result.object.get("count");
        const count: u64 = if (count_val) |cv| switch (cv) {
            .integer => |i| @intCast(i),
            .number => |f| @intFromFloat(f),
            else => 0,
        } else 0;
        const list = try self.parseOrderList(closed);
        return types.ClosedOrdersResult{
            .allocator = list.allocator,
            .orders = list.orders,
            .count = count,
        };
    }

    fn parseOrderList(self: *SpotRestClient, orders_val: json_mod.Value) !types.OpenOrdersResult {
        const k = orders_val.object.keys();
        var orders = try self.allocator.alloc(types.OrderInfo, k.len);
        var i: usize = 0;
        errdefer {
            for (orders[0..i]) |o| {
                self.allocator.free(o.txid);
                self.allocator.free(o.status);
                self.allocator.free(o.pair);
                self.allocator.free(o.type_);
                self.allocator.free(o.ordertype);
                self.allocator.free(o.price);
                self.allocator.free(o.vol);
            }
            self.allocator.free(orders);
        }
        for (k) |txid| {
            const order = orders_val.object.get(txid) orelse continue;
            const descr = order.object.get("descr") orelse continue;
            const status_str = if (order.object.get("status")) |sv| sv.string else "unknown";
            const pair_str = if (descr.object.get("pair")) |pv| pv.string else "";
            const type_str = if (descr.object.get("type")) |tv| tv.string else "";
            const ot_str = if (descr.object.get("ordertype")) |ov| ov.string else "";
            const price_str = if (descr.object.get("price")) |pv| pv.string else "0";
            const vol_str = if (order.object.get("vol")) |vv| vv.string else "0";
            orders[i] = types.OrderInfo{
                .txid = try self.allocator.dupe(u8, txid),
                .status = try self.allocator.dupe(u8, status_str),
                .pair = try self.allocator.dupe(u8, pair_str),
                .type_ = try self.allocator.dupe(u8, type_str),
                .ordertype = try self.allocator.dupe(u8, ot_str),
                .price = try self.allocator.dupe(u8, price_str),
                .vol = try self.allocator.dupe(u8, vol_str),
            };
            i += 1;
        }
        return types.OpenOrdersResult{
            .allocator = self.allocator,
            .orders = orders[0..i],
        };
    }

    pub fn addOrder(self: *SpotRestClient, order: types.OrderRequest) !types.AddOrderResult {
        var body_buf: [1024]u8 = undefined;
        var stream = std.io.fixedBufferStream(&body_buf);
        const w = stream.writer();
        try w.print("pair={s}&type={s}&ordertype={s}&volume={s}", .{
            order.pair, order.type_, order.ordertype, order.volume,
        });
        if (order.price) |p| try w.print("&price={s}", .{p});
        if (order.leverage) |l| try w.print("&leverage={s}", .{l});
        if (order.oflags) |f| try w.print("&oflags={s}", .{f});
        if (order.validate) try w.writeAll("&validate=true");

        const result = try self.privatePost("/0/private/AddOrder", stream.getWritten());
        const descr_val = result.object.get("descr") orelse return error.MissingField;
        const order_descr = descr_val.object.get("order") orelse return error.MissingField;

        var txids_list = std.ArrayList([]const u8).init(self.allocator);
        errdefer {
            for (txids_list.items) |t| self.allocator.free(t);
            txids_list.deinit();
        }
        if (result.object.get("txid")) |txid_val| {
            for (txid_val.array) |t| {
                try txids_list.append(try self.allocator.dupe(u8, t.string));
            }
        }

        return types.AddOrderResult{
            .allocator = self.allocator,
            .descr = try self.allocator.dupe(u8, order_descr.string),
            .txids = try txids_list.toOwnedSlice(),
        };
    }

    pub fn cancelOrder(self: *SpotRestClient, txid: []const u8) !types.CancelResult {
        var body_buf: [128]u8 = undefined;
        const body = try std.fmt.bufPrint(&body_buf, "txid={s}", .{txid});
        const result = try self.privatePost("/0/private/CancelOrder", body);
        const count_val = result.object.get("count") orelse return error.MissingField;
        const pending_val = result.object.get("pending");
        const count: u32 = switch (count_val) {
            .integer => |i| @intCast(i),
            .number => |f| @intFromFloat(f),
            else => 0,
        };
        const pending = if (pending_val) |pv| pv.boolean else false;
        return types.CancelResult{ .count = count, .pending = pending };
    }

    pub fn cancelAll(self: *SpotRestClient) !types.CancelAllResult {
        const result = try self.privatePost("/0/private/CancelAll", "");
        const count_val = result.object.get("count") orelse return error.MissingField;
        const count: u32 = switch (count_val) {
            .integer => |i| @intCast(i),
            .number => |f| @intFromFloat(f),
            else => 0,
        };
        return types.CancelAllResult{ .count = count };
    }
};
