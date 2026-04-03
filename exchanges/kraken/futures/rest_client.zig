// Kraken futures REST client

const std = @import("std");
const http_mod = @import("http_client");
const json_mod = @import("json");
const auth_mod = @import("futures_auth");
const types = @import("futures_types");

const KRAKEN_FUTURES_BASE_URL = "https://futures.kraken.com";

pub const FuturesRestClient = struct {
    allocator: std.mem.Allocator,
    http: http_mod.HttpClient,
    auth: ?auth_mod.FuturesAuth,

    pub fn init(allocator: std.mem.Allocator, auth: ?auth_mod.FuturesAuth) !FuturesRestClient {
        return FuturesRestClient{
            .allocator = allocator,
            .http = try http_mod.HttpClient.init(allocator),
            .auth = auth,
        };
    }

    pub fn deinit(self: *FuturesRestClient) void {
        self.http.deinit();
    }

    // ---- Internal helpers ----

    fn publicGet(self: *FuturesRestClient, path: []const u8) !json_mod.Value {
        var url_buf: [256]u8 = undefined;
        const url = try std.fmt.bufPrint(&url_buf, "{s}{s}", .{ KRAKEN_FUTURES_BASE_URL, path });
        var resp = try self.http.get(url);
        defer resp.deinit();
        return self.parseResponse(resp.body);
    }

    fn publicGetWithQuery(self: *FuturesRestClient, path: []const u8, query: []const u8) !json_mod.Value {
        var url_buf: [512]u8 = undefined;
        const url = try std.fmt.bufPrint(&url_buf, "{s}{s}?{s}", .{ KRAKEN_FUTURES_BASE_URL, path, query });
        var resp = try self.http.get(url);
        defer resp.deinit();
        return self.parseResponse(resp.body);
    }

    fn privatePost(self: *FuturesRestClient, path: []const u8, post_data: []const u8) !json_mod.Value {
        var a = self.auth orelse return error.AuthRequired;
        const nonce = a.nextNonce();
        self.auth = a;

        var nonce_str: [20]u8 = undefined;
        const nonce_s = try std.fmt.bufPrint(&nonce_str, "{d}", .{nonce});

        var sig_out: [88]u8 = undefined;
        var auth_copy = self.auth.?;
        const sig = auth_copy.sign(path, nonce, post_data, &sig_out);
        self.auth = auth_copy;

        var url_buf: [256]u8 = undefined;
        const url = try std.fmt.bufPrint(&url_buf, "{s}{s}", .{ KRAKEN_FUTURES_BASE_URL, path });

        const headers = [_]http_mod.Header{
            .{ .name = "APIKey", .value = auth_copy.api_key },
            .{ .name = "Nonce", .value = nonce_s },
            .{ .name = "Authent", .value = sig },
            .{ .name = "Content-Type", .value = "application/x-www-form-urlencoded" },
        };

        var resp = try self.http.post(url, post_data, &headers);
        defer resp.deinit();
        return self.parseResponse(resp.body);
    }

    fn parseResponse(self: *FuturesRestClient, body: []const u8) !json_mod.Value {
        var parser = json_mod.JsonParser.init(self.allocator);
        defer parser.deinit();
        const root = try parser.parse(body);

        // Futures API uses "result": "success"/"error" and "error" string field
        if (root.object.get("result")) |res| {
            if (res == .string and !std.mem.eql(u8, res.string, "success")) {
                return error.FuturesApiError;
            }
        }

        return root;
    }

    // ---- Public endpoints ----

    pub fn instruments(self: *FuturesRestClient) !types.InstrumentsResult {
        const root = try self.publicGet("/derivatives/api/v3/instruments");
        const instruments_val = root.object.get("instruments") orelse return error.MissingField;
        const arr = instruments_val.array;

        var inst_list = try self.allocator.alloc(types.InstrumentInfo, arr.len);
        var i: usize = 0;
        errdefer {
            for (inst_list[0..i]) |inst| {
                self.allocator.free(inst.symbol);
                self.allocator.free(inst.underlying);
                self.allocator.free(inst.last_price);
                self.allocator.free(inst.mark_price);
            }
            self.allocator.free(inst_list);
        }

        for (arr) |item| {
            const sym = if (item.object.get("symbol")) |v| v.string else "";
            const und = if (item.object.get("underlying")) |v| v.string else "";
            const last = if (item.object.get("last")) |v| switch (v) {
                .string => v.string,
                else => "0",
            } else "0";
            const mark = if (item.object.get("markPrice")) |v| switch (v) {
                .string => v.string,
                else => "0",
            } else "0";
            const cs: f64 = if (item.object.get("contractSize")) |v| switch (v) {
                .number => |f| f,
                .integer => |n| @floatFromInt(n),
                else => 1.0,
            } else 1.0;
            const tradeable: bool = if (item.object.get("tradeable")) |v| v.boolean else false;

            inst_list[i] = types.InstrumentInfo{
                .symbol = try self.allocator.dupe(u8, sym),
                .underlying = try self.allocator.dupe(u8, und),
                .last_price = try self.allocator.dupe(u8, last),
                .mark_price = try self.allocator.dupe(u8, mark),
                .contract_size = cs,
                .tradeable = tradeable,
            };
            i += 1;
        }

        return types.InstrumentsResult{
            .allocator = self.allocator,
            .instruments = inst_list[0..i],
        };
    }

    pub fn tickers(self: *FuturesRestClient) !types.TickersResult {
        const root = try self.publicGet("/derivatives/api/v3/tickers");
        const tickers_val = root.object.get("tickers") orelse return error.MissingField;
        const arr = tickers_val.array;

        var ticker_list = try self.allocator.alloc(types.FuturesTicker, arr.len);
        var i: usize = 0;
        errdefer {
            for (ticker_list[0..i]) |t| {
                self.allocator.free(t.symbol);
                self.allocator.free(t.bid);
                self.allocator.free(t.ask);
                self.allocator.free(t.last);
                self.allocator.free(t.vol24h);
                self.allocator.free(t.open_interest);
            }
            self.allocator.free(ticker_list);
        }

        for (arr) |item| {
            fn numStr(v: json_mod.Value, alloc: std.mem.Allocator) ![]const u8 {
                return switch (v) {
                    .string => alloc.dupe(u8, v.string),
                    .number => |f| {
                        var buf: [32]u8 = undefined;
                        return alloc.dupe(u8, try std.fmt.bufPrint(&buf, "{d}", .{f}));
                    },
                    .integer => |n| {
                        var buf: [32]u8 = undefined;
                        return alloc.dupe(u8, try std.fmt.bufPrint(&buf, "{d}", .{n}));
                    },
                    else => alloc.dupe(u8, "0"),
                };
            }
            const sym = if (item.object.get("symbol")) |v| v.string else "";
            const bid = if (item.object.get("bid")) |v| try numStr(v, self.allocator) else try self.allocator.dupe(u8, "0");
            const ask = if (item.object.get("ask")) |v| try numStr(v, self.allocator) else try self.allocator.dupe(u8, "0");
            const last = if (item.object.get("last")) |v| try numStr(v, self.allocator) else try self.allocator.dupe(u8, "0");
            const vol = if (item.object.get("vol24h")) |v| try numStr(v, self.allocator) else try self.allocator.dupe(u8, "0");
            const oi = if (item.object.get("openInterest")) |v| try numStr(v, self.allocator) else try self.allocator.dupe(u8, "0");

            ticker_list[i] = types.FuturesTicker{
                .symbol = try self.allocator.dupe(u8, sym),
                .bid = bid,
                .ask = ask,
                .last = last,
                .vol24h = vol,
                .open_interest = oi,
            };
            i += 1;
        }

        return types.TickersResult{
            .allocator = self.allocator,
            .tickers = ticker_list[0..i],
        };
    }

    pub fn orderbook(self: *FuturesRestClient, symbol: []const u8) !types.FuturesOrderBookResult {
        var query_buf: [128]u8 = undefined;
        const query = try std.fmt.bufPrint(&query_buf, "symbol={s}", .{symbol});
        const root = try self.publicGetWithQuery("/derivatives/api/v3/orderbook", query);
        const ob = root.object.get("orderBook") orelse return error.MissingField;
        const bids_val = ob.object.get("bids") orelse return error.MissingField;
        const asks_val = ob.object.get("asks") orelse return error.MissingField;

        const bids = try self.parseBookSide(bids_val.array);
        errdefer self.allocator.free(bids);
        const asks = try self.parseBookSide(asks_val.array);

        return types.FuturesOrderBookResult{
            .allocator = self.allocator,
            .symbol = try self.allocator.dupe(u8, symbol),
            .bids = bids,
            .asks = asks,
        };
    }

    fn parseBookSide(self: *FuturesRestClient, arr: []json_mod.Value) ![]types.FuturesOrderBookEntry {
        var entries = try self.allocator.alloc(types.FuturesOrderBookEntry, arr.len);
        for (arr, 0..) |item, i| {
            const row = item.array;
            const price: f64 = if (row.len > 0) switch (row[0]) {
                .number => |f| f,
                .integer => |n| @floatFromInt(n),
                else => 0,
            } else 0;
            const size: f64 = if (row.len > 1) switch (row[1]) {
                .number => |f| f,
                .integer => |n| @floatFromInt(n),
                else => 0,
            } else 0;
            entries[i] = types.FuturesOrderBookEntry{ .price = price, .size = size };
        }
        return entries;
    }

    // ---- Private endpoints ----

    pub fn accounts(self: *FuturesRestClient) !types.AccountsResult {
        const root = try self.privatePost("/derivatives/api/v3/accounts", "");
        const accts = root.object.get("accounts") orelse return error.MissingField;
        const k = accts.object.keys();

        var balances = try self.allocator.alloc(types.AccountBalance, k.len);
        var i: usize = 0;
        errdefer {
            for (balances[0..i]) |b| self.allocator.free(b.currency);
            self.allocator.free(balances);
        }

        for (k) |currency| {
            const acct = accts.object.get(currency) orelse continue;
            const bal: f64 = if (acct.object.get("balance")) |bv| switch (bv) {
                .number => |f| f,
                .integer => |n| @floatFromInt(n),
                else => 0,
            } else 0;
            balances[i] = types.AccountBalance{
                .currency = try self.allocator.dupe(u8, currency),
                .balance = bal,
            };
            i += 1;
        }

        return types.AccountsResult{
            .allocator = self.allocator,
            .balances = balances[0..i],
        };
    }

    pub fn sendOrder(self: *FuturesRestClient, order: types.FuturesOrderRequest) !types.SendOrderResult {
        var body_buf: [512]u8 = undefined;
        var stream = std.io.fixedBufferStream(&body_buf);
        const w = stream.writer();
        try w.print("orderType={s}&symbol={s}&side={s}&size={d}", .{
            order.order_type, order.symbol, order.side, order.size,
        });
        if (order.limit_price) |lp| try w.print("&limitPrice={d}", .{lp});
        if (order.stop_price) |sp| try w.print("&stopPrice={d}", .{sp});
        if (order.client_order_id) |cid| try w.print("&cliOrdId={s}", .{cid});
        if (order.reduce_only) try w.writeAll("&reduceOnly=true");

        const root = try self.privatePost("/derivatives/api/v3/sendorder", stream.getWritten());
        const send_status = root.object.get("sendStatus") orelse return error.MissingField;
        const order_id = if (send_status.object.get("order_id")) |v| v.string else "";
        const status = if (send_status.object.get("status")) |v| v.string else "unknown";

        return types.SendOrderResult{
            .allocator = self.allocator,
            .order_id = try self.allocator.dupe(u8, order_id),
            .status = try self.allocator.dupe(u8, status),
        };
    }

    pub fn cancelOrder(self: *FuturesRestClient, order_id: []const u8) !types.FuturesCancelResult {
        var body_buf: [128]u8 = undefined;
        const body = try std.fmt.bufPrint(&body_buf, "order_id={s}", .{order_id});
        const root = try self.privatePost("/derivatives/api/v3/cancelorder", body);
        const cancel_status = root.object.get("cancelStatus") orelse return error.MissingField;
        const status = if (cancel_status.object.get("status")) |v| v.string else "unknown";
        return types.FuturesCancelResult{
            .allocator = self.allocator,
            .status = try self.allocator.dupe(u8, status),
        };
    }

    pub fn cancelAllOrders(self: *FuturesRestClient, symbol: ?[]const u8) !types.FuturesCancelAllResult {
        var body_buf: [128]u8 = undefined;
        const body = if (symbol) |s|
            try std.fmt.bufPrint(&body_buf, "symbol={s}", .{s})
        else
            "";
        const root = try self.privatePost("/derivatives/api/v3/cancelallorders", body);
        const cancelled = if (root.object.get("cancelledOrders")) |v| v.array.len else 0;
        return types.FuturesCancelAllResult{ .cancelled_count = @intCast(cancelled) };
    }

    pub fn cancelAllOrdersAfter(self: *FuturesRestClient, timeout_seconds: u32) !types.DeadManResult {
        var body_buf: [64]u8 = undefined;
        const body = try std.fmt.bufPrint(&body_buf, "timeout={d}", .{timeout_seconds});
        const root = try self.privatePost("/derivatives/api/v3/cancelallordersafter", body);
        const status_val = root.object.get("status") orelse return error.MissingField;
        const trigger_val = root.object.get("triggerTime");
        const trigger_time: i64 = if (trigger_val) |tv| switch (tv) {
            .integer => |i| i,
            .number => |f| @intFromFloat(f),
            else => 0,
        } else 0;
        return types.DeadManResult{
            .allocator = self.allocator,
            .status = try self.allocator.dupe(u8, status_val.string),
            .trigger_time = trigger_time,
        };
    }
};
