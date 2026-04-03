---
phase: 4
iteration: 01
generated: 2026-04-03
---

# Outline: Trading Platform SDK (Pure Zig) with Kraken Exchange Integration

Design: .claude/specs/trading-desk-kraken-integration/03-design-01.md

## Overview

Build a complete pure-Zig trading platform SDK in 12 vertical phases, each delivering end-to-end testable functionality. Every phase follows strict TDD: first write contract tests against public API signatures (no implementation exists yet), then implement until all tests pass with zero leaks. No external dependencies, no C interop — only `std` and code in this repo.

## TDD Methodology (applies to ALL phases)

Each phase has two sub-steps executed in order:

### Step A: Contract Tests
Write test files that import the module and exercise its public API. The implementation does not exist yet. Tests must cover:
- **Happy path**: normal inputs produce correct outputs
- **Boundary**: empty inputs, maximum values, zero quantities, smallest increments
- **Malformed input**: truncated messages, invalid data, missing required fields, wrong types
- **State transitions**: sequences of calls exercising stateful behavior
- **Invariants**: properties that must ALWAYS hold (e.g., "best bid < best ask", "sequence numbers are monotonic")

Rules for test code:
1. Call the public API exactly as a consumer would — do not test internals
2. Use `std.testing.allocator` to catch memory leaks
3. Name tests as behavioral specifications: `"parser rejects message with missing channel field"` not `"test_parse_3"`
4. For wire format tests, construct payloads from Kraken API docs — include doc URL as comment above each fixture
5. No trivial tests — every test asserts something a user would care about

### Step B: Implementation
Write the module to make every test pass.

Rules for implementation code:
1. Run `zig build test` after each meaningful change — not done until all tests pass with zero leaks
2. Do not modify test files. If a test seems wrong, flag it — do not silently change it
3. No external dependencies. No `@cImport`. Only `std` and code in this repo
4. Allocations must be explicit — use the allocator passed by the caller. No global state
5. Hot-path functions must not allocate. Document any function that allocates with a comment

---

## Phase 1: Project Skeleton + Core Primitives
**Delivers**: Build system (`build.zig`), module structure, memory allocators (arena/pool with 64-byte cache-line alignment), time utilities (nanosecond timestamps, format conversions), containers (SPSC ring buffer, MPSC queue, fixed-capacity hash map, sorted array), cryptography (HMAC-SHA512, SHA256, Base64, AES-128/256-GCM, ChaCha20-Poly1305, X25519, RSA-PKCS1v15, ECDSA-P256/P384)
**Layers touched**: sdk/core (memory, time, containers, crypto), build system

### Key types / signatures introduced
```zig
// core/memory.zig
pub const PoolAllocator = struct {
    pub fn init(backing: std.mem.Allocator, slot_size: usize, slot_count: usize) PoolAllocator;
    pub fn allocator(self: *PoolAllocator) std.mem.Allocator;
    pub fn deinit(self: *PoolAllocator) void;
};
pub const ArenaAllocator = struct {
    pub fn init(backing: std.mem.Allocator) ArenaAllocator;
    pub fn allocator(self: *ArenaAllocator) std.mem.Allocator;
    pub fn reset(self: *ArenaAllocator) void;
    pub fn deinit(self: *ArenaAllocator) void;
};

// core/time.zig
pub const Timestamp = struct {
    nanos: u128,
    pub fn now() Timestamp;                          // CLOCK_MONOTONIC_RAW
    pub fn wallClock() Timestamp;                    // CLOCK_REALTIME
    pub fn toRfc3339(self: Timestamp, buf: []u8) []const u8;
    pub fn toIso8601(self: Timestamp, buf: []u8) []const u8;
    pub fn toFixUtc(self: Timestamp, buf: []u8) []const u8;
    pub fn fromRfc3339(s: []const u8) !Timestamp;
    pub fn fromUnixNanos(n: u128) Timestamp;
};

// core/containers/ring_buffer.zig
pub fn SpscRingBuffer(comptime T: type) type {
    return struct {
        pub fn init(allocator: std.mem.Allocator, capacity: usize) !@This();
        pub fn push(self: *@This(), item: T) bool;
        pub fn pop(self: *@This()) ?T;
        pub fn deinit(self: *@This()) void;
    };
}

// core/containers/hash_map.zig
pub fn FixedHashMap(comptime K: type, comptime V: type, comptime capacity: usize) type {
    return struct {
        pub fn init() @This();
        pub fn put(self: *@This(), key: K, value: V) !void;
        pub fn get(self: *@This(), key: K) ?V;
        pub fn remove(self: *@This(), key: K) bool;
        pub fn count(self: *@This()) usize;
    };
}

// core/crypto/hmac.zig
pub fn hmacSha512(key: []const u8, data: []const u8, out: *[64]u8) void;
pub fn sha256(data: []const u8, out: *[32]u8) void;

// core/crypto/base64.zig
pub fn encode(dest: []u8, source: []const u8) []const u8;
pub fn decode(dest: []u8, source: []const u8) ![]const u8;
```

### Test checkpoint
- Type: Automated
- Step A: Write contract tests for all core modules — allocator behavior, timestamp conversions against known values, ring buffer push/pop/full/empty, crypto against RFC test vectors (HMAC-SHA512 RFC 4231, AES-GCM NIST vectors)
- Step B: Implement until `zig build test` passes with zero leaks
- Verify: `zig build test --summary all` shows all core test suites green

---

## Phase 2: I/O + TLS + HTTP + JSON (Networking Stack)
**Delivers**: io_uring-based event loop, TCP connection management with timeouts, thread pinning via `sched_setaffinity`, TLS 1.2/1.3 client (handshake state machine, cipher suites, X.509 validation, session resumption), HTTP/1.1 client (request/response, connection pooling, chunked encoding), JSON streaming parser + DOM builder + serializer
**Layers touched**: sdk/core/io, sdk/protocol (tls, http, json)
**Depends on**: Phase 1

### Key types / signatures introduced
```zig
// core/io/event_loop.zig
pub const EventLoop = struct {
    pub fn init(allocator: std.mem.Allocator) !EventLoop;
    pub fn addSocket(self: *EventLoop, fd: std.posix.fd_t, handler: *const Handler) !void;
    pub fn addTimer(self: *EventLoop, timeout_ms: u64, callback: *const fn() void) !void;
    pub fn run(self: *EventLoop) !void;
    pub fn deinit(self: *EventLoop) void;
};

// protocol/tls/client.zig
pub const TlsClient = struct {
    pub fn init(allocator: std.mem.Allocator, hostname: []const u8) !TlsClient;
    pub fn handshake(self: *TlsClient, tcp_fd: std.posix.fd_t) !void;
    pub fn read(self: *TlsClient, buf: []u8) !usize;
    pub fn write(self: *TlsClient, data: []const u8) !usize;
    pub fn close(self: *TlsClient) void;
    pub fn deinit(self: *TlsClient) void;
};

// protocol/http/client.zig
pub const HttpClient = struct {
    pub fn init(allocator: std.mem.Allocator) !HttpClient;
    pub fn get(self: *HttpClient, url: []const u8) !Response;
    pub fn post(self: *HttpClient, url: []const u8, body: []const u8, headers: []const Header) !Response;
    pub fn deinit(self: *HttpClient) void;
};
pub const Response = struct { status: u16, headers: []Header, body: []const u8 };

// protocol/json.zig
pub const JsonParser = struct {
    pub fn init(allocator: std.mem.Allocator) JsonParser;
    pub fn parse(self: *JsonParser, input: []const u8) !Value;
    pub fn deinit(self: *JsonParser) void;
};
pub const Value = union(enum) { object: Map, array: []Value, string: []const u8, number: f64, integer: i64, boolean: bool, null_value };
pub fn stringify(value: Value, buf: []u8) ![]const u8;
```

### Test checkpoint
- Type: Automated + Integration
- Step A: Contract tests for JSON (parse/stringify round-trip, malformed input, nested structures, Kraken response format), TLS (handshake state transitions, cipher negotiation), HTTP (request formatting, response parsing, chunked decoding)
- Step B: Implement until unit tests pass; then integration test: `GET https://api.kraken.com/0/public/SystemStatus` — parse JSON response, assert `status` field exists
- Verify: `zig build test --summary all` green + integration test fetches live Kraken data

---

## Phase 3: WebSocket + Kraken REST (Public + Auth + Private)
**Delivers**: WebSocket RFC 6455 client (frame parsing, ping/pong, reconnection with Cloudflare rate limit awareness), Kraken spot REST client (all public + private endpoints), Kraken spot auth (HMAC-SHA512 signing, nonce management), Kraken futures REST client + auth (different header/signature scheme), rate limit tracking (call counter with tier-based decay for spot, cost units for futures)
**Layers touched**: sdk/protocol/websocket, exchanges/kraken/spot, exchanges/kraken/futures
**Depends on**: Phase 2

### Key types / signatures introduced
```zig
// protocol/websocket/client.zig
pub const WebSocketClient = struct {
    pub fn init(allocator: std.mem.Allocator, url: []const u8) !WebSocketClient;
    pub fn connect(self: *WebSocketClient) !void;
    pub fn send(self: *WebSocketClient, data: []const u8) !void;
    pub fn receive(self: *WebSocketClient) !Message;
    pub fn close(self: *WebSocketClient) !void;
    pub fn deinit(self: *WebSocketClient) void;
};
pub const Message = struct { opcode: Opcode, payload: []const u8 };

// exchanges/kraken/spot/auth.zig
pub const SpotAuth = struct {
    pub fn init(api_key: []const u8, api_secret: []const u8) SpotAuth;
    pub fn sign(self: *SpotAuth, uri_path: []const u8, nonce: u64, post_data: []const u8, out: *[88]u8) []const u8;
};

// exchanges/kraken/spot/rest_client.zig
pub const SpotRestClient = struct {
    pub fn init(allocator: std.mem.Allocator, auth: ?SpotAuth) !SpotRestClient;
    pub fn systemStatus(self: *SpotRestClient) !SystemStatus;
    pub fn assetPairs(self: *SpotRestClient, pairs: ?[]const []const u8) !AssetPairsResult;
    pub fn addOrder(self: *SpotRestClient, order: OrderRequest) !AddOrderResult;
    pub fn cancelOrder(self: *SpotRestClient, txid: []const u8) !CancelResult;
    pub fn getBalance(self: *SpotRestClient) !BalanceResult;
    pub fn deinit(self: *SpotRestClient) void;
};

// exchanges/kraken/futures/auth.zig
pub const FuturesAuth = struct {
    pub fn init(api_key: []const u8, api_secret: []const u8) FuturesAuth;
    pub fn sign(self: *FuturesAuth, endpoint_path: []const u8, nonce: u64, post_data: []const u8, out: *[88]u8) []const u8;
};

// exchanges/kraken/spot/rate_limiter.zig
pub const SpotRateLimiter = struct {
    pub fn init(tier: Tier) SpotRateLimiter;
    pub fn canCall(self: *SpotRateLimiter, cost: u8) bool;
    pub fn recordCall(self: *SpotRateLimiter, cost: u8) void;
};
```

### Test checkpoint
- Type: Automated + Integration
- Step A: Contract tests for WebSocket (frame encode/decode, masking, ping/pong, fragmentation), Kraken spot auth (sign against known nonce/secret/path → expected HMAC output from docs), futures auth (same with different construction), rate limiter (counter decay, tier limits, boundary at max)
- Step B: Implement until unit tests pass; integration test: authenticated `GetBalance` on spot + `accounts` on futures
- Verify: `zig build test --summary all` green + live API calls return valid responses

---

## Phase 4: Kraken WebSocket Streaming + Market Data + Order Book
**Delivers**: Kraken spot WS v2 client (token refresh every 15 min, reconnection logic), Kraken futures WS client (challenge-based auth, 60s ping), market data normalization (symbology mapping, price scaling, timestamp normalization), L2 order book (sorted price levels, O(1) top-of-book), L3 order book (per-level order queues, O(1) order lookup), `BookView` interface, bar aggregation (OHLCV, volume bars, tick bars)
**Layers touched**: exchanges/kraken/spot (ws_client), exchanges/kraken/futures (ws_client), sdk/domain (market_data, orderbook)
**Depends on**: Phase 3

### Key types / signatures introduced
```zig
// domain/orderbook.zig
pub const L2Book = struct {
    pub fn init(allocator: std.mem.Allocator, depth: usize) !L2Book;
    pub fn applySnapshot(self: *L2Book, bids: []const Level, asks: []const Level) void;
    pub fn applyUpdate(self: *L2Book, side: Side, price: i64, qty: i64) void;
    pub fn bestBid(self: *const L2Book) ?Level;
    pub fn bestAsk(self: *const L2Book) ?Level;
    pub fn spread(self: *const L2Book) ?i64;
    pub fn midPrice(self: *const L2Book) ?i64;
    pub fn deinit(self: *L2Book) void;
};
pub const Level = struct { price: i64, quantity: i64 };

// domain/market_data.zig
pub const SymbolMapper = struct {
    pub fn init(allocator: std.mem.Allocator) !SymbolMapper;
    pub fn spotToInternal(self: *SymbolMapper, kraken_pair: []const u8) ?[]const u8;
    pub fn futurestoInternal(self: *SymbolMapper, kraken_symbol: []const u8) ?[]const u8;
    pub fn deinit(self: *SymbolMapper) void;
};

pub const BarAggregator = struct {
    pub fn init(interval_ns: u128) BarAggregator;
    pub fn onTrade(self: *BarAggregator, price: i64, qty: i64, timestamp: u128) ?Bar;
};
pub const Bar = struct { open: i64, high: i64, low: i64, close: i64, volume: i64, timestamp: u128 };

// exchanges/kraken/spot/ws_client.zig
pub const SpotWsClient = struct {
    pub fn init(allocator: std.mem.Allocator, auth: ?SpotAuth) !SpotWsClient;
    pub fn connect(self: *SpotWsClient) !void;
    pub fn subscribe(self: *SpotWsClient, channel: Channel, pairs: []const []const u8) !void;
    pub fn nextMessage(self: *SpotWsClient) !WsMessage;
    pub fn deinit(self: *SpotWsClient) void;
};
```

### Test checkpoint
- Type: Automated + Integration
- Step A: Contract tests for L2Book (snapshot apply, incremental updates, BBO invariant `best_bid < best_ask`, empty book edge cases, price level removal when qty=0), BarAggregator (OHLCV correctness, bar boundary rollover, single-trade bar), SymbolMapper (spot pair mapping, futures prefix mapping, unknown symbol returns null), WS message parsing (Kraken v2 book snapshot format, incremental update format — payloads from docs with URL comments)
- Step B: Implement until unit tests pass; integration test: connect to `wss://ws.kraken.com/v2`, subscribe to `book` for BTC/USD, build L2 book, assert spread > 0
- Verify: `zig build test --summary all` green + live order book updates streaming

---

## Phase 5: FIX Protocol + Kraken FIX Connectivity
**Delivers**: FIX 4.2/4.4/5.0 SP2 tag-value codec (SOH delimiter, checksum validation, message type dispatch), FIXT 1.1 session layer (Logon/Logout, Heartbeat/TestRequest, ResendRequest/SequenceReset, PossDupFlag handling, sequence number persistence), Kraken FIX client (SenderCompID auth, nonce within 5s of server time)
**Layers touched**: sdk/protocol/fix, exchanges/kraken/spot (fix_client)
**Depends on**: Phase 2 (needs TCP/TLS)

### Key types / signatures introduced
```zig
// protocol/fix/codec.zig
pub const FixMessage = struct {
    pub fn init(allocator: std.mem.Allocator) FixMessage;
    pub fn setTag(self: *FixMessage, tag: u32, value: []const u8) !void;
    pub fn getTag(self: *const FixMessage, tag: u32) ?[]const u8;
    pub fn getMsgType(self: *const FixMessage) ?[]const u8;
    pub fn encode(self: *const FixMessage, buf: []u8) ![]const u8;
    pub fn deinit(self: *FixMessage) void;
};
pub fn decode(allocator: std.mem.Allocator, raw: []const u8) !FixMessage;
pub fn computeChecksum(data: []const u8) u8;

// protocol/fix/session.zig
pub const FixSession = struct {
    pub fn init(allocator: std.mem.Allocator, config: SessionConfig) !FixSession;
    pub fn connect(self: *FixSession, host: []const u8, port: u16) !void;
    pub fn logon(self: *FixSession) !void;
    pub fn send(self: *FixSession, msg: *FixMessage) !void;
    pub fn receive(self: *FixSession) !FixMessage;
    pub fn logout(self: *FixSession) !void;
    pub fn deinit(self: *FixSession) void;
};
pub const SessionConfig = struct {
    sender_comp_id: []const u8,
    target_comp_id: []const u8,
    fix_version: FixVersion,
    heartbeat_interval_s: u32,
};
```

### Test checkpoint
- Type: Automated + Integration
- Step A: Contract tests for FIX codec (encode/decode round-trip, checksum computation against known messages, SOH delimiter handling, missing BeginString/BodyLength/MsgType rejection, tag extraction), FIX session (Logon message construction per Kraken docs with SenderCompID auth fields, Heartbeat/TestRequest state machine, sequence number increment, PossDupFlag on resend)
- Step B: Implement until unit tests pass; integration test: FIX Logon/Logout with Kraken FIX endpoint
- Verify: `zig build test --summary all` green + successful FIX session establishment

---

## Phase 6: OMS + Order Types + Pre-Trade Risk + Event Store
**Delivers**: Order state machine (PendingNew→New→PartiallyFilled→Filled→Cancelled etc., plus internal states Staged/Validating/RoutePending), order types with FIX tag mappings (Market/Limit/Stop/StopLimit/TrailingStop, TIF Day/GTC/IOC/FOK/GTD, bracket/OCO/contingent), pre-trade risk pipeline (size limits, price reasonability, rate throttle, duplicate detection, configurable limit hierarchy), append-only event store (sequence numbers, nanosecond timestamps, mmap, replay)
**Layers touched**: sdk/domain (oms, order_types, risk/pre_trade), sdk/core (event_store)
**Depends on**: Phase 1

### Key types / signatures introduced
```zig
// domain/oms.zig
pub const OrderStateMachine = struct {
    pub fn init() OrderStateMachine;
    pub fn transition(self: *OrderStateMachine, current: OrdStatus, event: ExecType) !OrdStatus;
    pub fn isTerminal(status: OrdStatus) bool;
};
pub const OrdStatus = enum { pending_new, new, partially_filled, filled, cancelled, replaced, pending_cancel, rejected, suspended, pending_replace, expired, staged, validating, route_pending };

pub const OrderManager = struct {
    pub fn init(allocator: std.mem.Allocator, risk: *PreTradeRisk, store: *EventStore) !OrderManager;
    pub fn submitOrder(self: *OrderManager, order: Order) !OrderId;
    pub fn cancelOrder(self: *OrderManager, id: OrderId) !void;
    pub fn replaceOrder(self: *OrderManager, id: OrderId, new_params: OrderParams) !OrderId;
    pub fn getOrder(self: *OrderManager, id: OrderId) ?*const Order;
    pub fn deinit(self: *OrderManager) void;
};

// domain/risk/pre_trade.zig
pub const PreTradeRisk = struct {
    pub fn init(allocator: std.mem.Allocator, config: RiskConfig) !PreTradeRisk;
    pub fn validate(self: *PreTradeRisk, order: *const Order) ValidationResult;
    pub fn deinit(self: *PreTradeRisk) void;
};
pub const ValidationResult = union(enum) { passed, rejected: RejectReason };

// core/event_store.zig
pub const EventStore = struct {
    pub fn init(allocator: std.mem.Allocator, path: []const u8) !EventStore;
    pub fn append(self: *EventStore, event: []const u8) !u64; // returns sequence number
    pub fn read(self: *EventStore, seq: u64) ![]const u8;
    pub fn replay(self: *EventStore, from_seq: u64) Iterator;
    pub fn deinit(self: *EventStore) void;
};
```

### Test checkpoint
- Type: Automated
- Step A: Contract tests for state machine (all valid transitions, all invalid transitions rejected, terminal state detection, race conditions: fill-before-cancel, fill-before-replace), order types (FIX tag mapping correctness, bracket order parent-child invariants, OCO cancellation logic), pre-trade risk (order within limits passes, over-size rejected, price too far from reference rejected, rate throttle triggers after burst, duplicate detection), event store (append/read round-trip, sequence monotonicity invariant, replay from arbitrary sequence, gap detection)
- Step B: Implement until `zig build test` passes with zero leaks
- Verify: Full order lifecycle through validation pipeline, events persisted and replayable

---

## Phase 7: Kraken Order Execution End-to-End
**Delivers**: Order placement/cancel/amend via Kraken spot REST + WS v2 + FIX, Kraken futures REST + WS, integration with OMS state machine (exchange acks drive state transitions), dead man's switch (futures `cancelallordersafter` every 15-20s), symbol translation between OMS and exchange-native formats
**Layers touched**: exchanges/kraken/spot (execution), exchanges/kraken/futures (execution), sdk/domain (oms integration)
**Depends on**: Phases 3, 4, 5, 6

### Key types / signatures introduced
```zig
// exchanges/kraken/spot/executor.zig
pub const SpotExecutor = struct {
    pub fn init(allocator: std.mem.Allocator, rest: *SpotRestClient, ws: ?*SpotWsClient, fix: ?*FixSession, oms: *OrderManager) !SpotExecutor;
    pub fn placeOrder(self: *SpotExecutor, order: *const Order) !ExchangeOrderId;
    pub fn cancelOrder(self: *SpotExecutor, exchange_id: ExchangeOrderId) !void;
    pub fn amendOrder(self: *SpotExecutor, exchange_id: ExchangeOrderId, params: AmendParams) !ExchangeOrderId;
    pub fn deinit(self: *SpotExecutor) void;
};

// exchanges/kraken/futures/executor.zig
pub const FuturesExecutor = struct {
    pub fn init(allocator: std.mem.Allocator, rest: *FuturesRestClient, ws: ?*FuturesWsClient, oms: *OrderManager) !FuturesExecutor;
    pub fn placeOrder(self: *FuturesExecutor, order: *const Order) !ExchangeOrderId;
    pub fn cancelOrder(self: *FuturesExecutor, exchange_id: ExchangeOrderId) !void;
    pub fn setDeadManSwitch(self: *FuturesExecutor, timeout_s: u32) !void;
    pub fn deinit(self: *FuturesExecutor) void;
};
```

### Test checkpoint
- Type: Automated + Integration
- Step A: Contract tests for executor (order submission maps OMS order → Kraken API params correctly, cancel propagates through OMS state machine, amend generates new ClOrdID, dead man's switch sends periodic heartbeat, exchange rejection drives OMS to `rejected` state, partial fill drives OMS to `partially_filled`)
- Step B: Implement until unit tests pass; integration test: place a limit order far from market on Kraken, verify OMS state transitions to `new`, cancel it, verify transition to `cancelled`
- Verify: `zig build test --summary all` green + full order lifecycle confirmed on live exchange

---

## Phase 8: Position Tracking + P&L + Risk Calculations
**Delivers**: Position tracking keyed by (Account, Instrument, SettlementDate, Currency, LegalEntity), realized/unrealized P&L, cost basis methods (FIFO, LIFO, average cost), multi-currency with base currency conversion, VaR (historical, parametric, Monte Carlo with Cholesky), Expected Shortfall, Greeks (Delta/Gamma/Vega/Theta/Rho via Black-Scholes), stress testing (historical + hypothetical scenarios), risk attribution
**Layers touched**: sdk/domain (positions, risk/)
**Depends on**: Phases 6, 7

### Key types / signatures introduced
```zig
// domain/positions.zig
pub const PositionManager = struct {
    pub fn init(allocator: std.mem.Allocator, config: PositionConfig) !PositionManager;
    pub fn onFill(self: *PositionManager, fill: Fill) !void;
    pub fn getPosition(self: *PositionManager, key: PositionKey) ?*const Position;
    pub fn realizedPnl(self: *PositionManager, key: PositionKey) ?i64;
    pub fn unrealizedPnl(self: *PositionManager, key: PositionKey, mark_price: i64) ?i64;
    pub fn deinit(self: *PositionManager) void;
};
pub const PositionKey = struct { account: []const u8, instrument: []const u8, settlement_date: u32, currency: []const u8 };

// domain/risk/var.zig
pub fn historicalVar(returns: []const f64, confidence: f64) f64;
pub fn parametricVar(sigma: f64, z_alpha: f64, horizon_days: f64, position_value: f64) f64;
pub fn monteCarloVar(allocator: std.mem.Allocator, covariance: []const []const f64, weights: []const f64, simulations: u32, confidence: f64) !f64;

// domain/risk/greeks.zig
pub const BlackScholes = struct {
    pub fn delta(spot: f64, strike: f64, r: f64, sigma: f64, t: f64, is_call: bool) f64;
    pub fn gamma(spot: f64, strike: f64, r: f64, sigma: f64, t: f64) f64;
    pub fn vega(spot: f64, strike: f64, r: f64, sigma: f64, t: f64) f64;
    pub fn theta(spot: f64, strike: f64, r: f64, sigma: f64, t: f64, is_call: bool) f64;
    pub fn price(spot: f64, strike: f64, r: f64, sigma: f64, t: f64, is_call: bool) f64;
};
```

### Test checkpoint
- Type: Automated
- Step A: Contract tests for positions (FIFO cost basis: buy 100@10, buy 100@12, sell 150 → realized P&L is known value; flat position after equal buy/sell; multi-currency conversion), VaR (parametric VaR against textbook example, historical VaR with known sorted returns, Monte Carlo VaR within statistical tolerance of parametric for normal distribution), Greeks (Black-Scholes put-call parity invariant: `C - P = S - K*e^(-rT)`, delta of deep ITM call ≈ 1.0, at-expiry option value = intrinsic)
- Step B: Implement until `zig build test` passes with zero leaks
- Verify: All risk calculations match textbook/reference values

---

## Phase 9: Additional Market Data Protocols (SBE, FAST, ITCH, OUCH, PITCH)
**Delivers**: SBE decoder (CME MDP 3.0 schema-driven, zero-copy, compile-time field offsets), FAST decoder (presence maps, stop-bit encoding, delta operators), ITCH parser (NASDAQ TotalView — Add/Execute/Cancel/Delete/Replace/Trade), OUCH encoder/decoder (Enter/Replace/Cancel Order + confirmations), PITCH parser (Cboe binary — Add/Execute/Cancel/Trade with multicast UDP)
**Layers touched**: sdk/protocol (sbe, fast, itch, ouch, pitch)
**Depends on**: Phase 1

### Key types / signatures introduced
```zig
// protocol/itch.zig
pub const ItchParser = struct {
    pub fn init() ItchParser;
    pub fn parse(self: *ItchParser, data: []const u8) !ItchMessage;
};
pub const ItchMessage = union(enum) {
    add_order: AddOrder,
    execute: Execute,
    cancel: Cancel,
    delete: Delete,
    replace: Replace,
    trade: Trade,
    system_event: SystemEvent,
};

// protocol/sbe.zig
pub const SbeDecoder = struct {
    pub fn init(schema: []const u8) !SbeDecoder;
    pub fn decode(self: *SbeDecoder, data: []const u8) !SbeMessage;
};

// protocol/ouch.zig
pub const OuchEncoder = struct {
    pub fn encodeEnterOrder(order: EnterOrder, buf: []u8) ![]const u8;
    pub fn encodeCancelOrder(token: [14]u8, buf: []u8) ![]const u8;
};
pub const OuchDecoder = struct {
    pub fn decode(data: []const u8) !OuchMessage;
};
```

### Test checkpoint
- Type: Automated
- Step A: Contract tests for each protocol using hand-constructed binary payloads matching spec formats — ITCH Add Order (message type 'A', verify all field extraction including stock locate, timestamp, order ref, side, shares, stock, price), SBE (fixed-layout message with known field offsets), FAST (stop-bit encoded integers, presence map toggling), OUCH (encode/decode round-trip for Enter Order), PITCH (Add Order Long/Short variants)
- Step B: Implement until `zig build test` passes with zero leaks
- Verify: All protocol decoders correctly parse reference messages

---

## Phase 10: Execution Algorithms + Smart Order Routing
**Delivers**: VWAP (historical volume profile, participation limits), TWAP (equal slices with randomization), POV (real-time volume tracking), Implementation Shortfall (arrival price benchmark), Iceberg, Sniper/Liquidity Seeking, SOR with venue scoring, fee optimization (maker-taker vs inverted), dark pool pinging
**Layers touched**: sdk/domain (algos/, sor)
**Depends on**: Phases 4, 6

### Key types / signatures introduced
```zig
// domain/algos/twap.zig
pub const TwapAlgo = struct {
    pub fn init(params: TwapParams) TwapAlgo;
    pub fn nextSlice(self: *TwapAlgo, now: u128) ?ChildOrder;
    pub fn onFill(self: *TwapAlgo, fill: Fill) void;
    pub fn isComplete(self: *TwapAlgo) bool;
    pub fn remainingQty(self: *TwapAlgo) i64;
};
pub const TwapParams = struct { total_qty: i64, start_time: u128, end_time: u128, num_slices: u32, instrument: []const u8, side: Side };

// domain/algos/vwap.zig
pub const VwapAlgo = struct {
    pub fn init(params: VwapParams, volume_profile: []const f64) VwapAlgo;
    pub fn onMarketData(self: *VwapAlgo, volume: i64, now: u128) ?ChildOrder;
    pub fn onFill(self: *VwapAlgo, fill: Fill) void;
    pub fn participationRate(self: *const VwapAlgo) f64;
};

// domain/sor.zig
pub const SmartOrderRouter = struct {
    pub fn init(allocator: std.mem.Allocator, venues: []const VenueConfig) !SmartOrderRouter;
    pub fn route(self: *SmartOrderRouter, order: *const Order, market_state: *const MarketState) !RoutingDecision;
    pub fn deinit(self: *SmartOrderRouter) void;
};
pub const RoutingDecision = struct { venue: []const u8, child_orders: []ChildOrder };
```

### Test checkpoint
- Type: Automated
- Step A: Contract tests for TWAP (total quantity divided evenly across slices, randomization stays within bounds, fill tracking reduces remaining, completion detection), VWAP (participation rate never exceeds limit, volume-profile weighting correctness), SOR (routes to lowest-fee venue when prices equal, routes to best-price venue when fees equal, splits across venues for large orders)
- Step B: Implement until `zig build test` passes with zero leaks
- Verify: All algo invariants hold under varied input sequences

---

## Phase 11: Post-Trade + Reconciliation + Tick Store
**Delivers**: Trade confirmation matching, reconciliation engine (trade/position/cash recon with configurable tolerances, break management), SOD/EOD procedures (position snapshots, P&L sign-off), allocation and average pricing, tick store (columnar binary — date-partitioned, delta-encoded timestamps, varint prices, mmap reads), Parquet writer (batch export)
**Layers touched**: sdk/domain (post_trade/, tick_store, parquet_writer)
**Depends on**: Phases 7, 8

### Key types / signatures introduced
```zig
// domain/post_trade/reconciliation.zig
pub const ReconEngine = struct {
    pub fn init(allocator: std.mem.Allocator, tolerance: ReconTolerance) !ReconEngine;
    pub fn reconcileTrades(self: *ReconEngine, internal: []const Trade, external: []const Trade) !ReconResult;
    pub fn reconcilePositions(self: *ReconEngine, internal: []const Position, external: []const Position) !ReconResult;
    pub fn deinit(self: *ReconEngine) void;
};
pub const ReconResult = struct { matched: u32, breaks: []Break };

// domain/tick_store.zig
pub const TickStore = struct {
    pub fn init(allocator: std.mem.Allocator, base_path: []const u8) !TickStore;
    pub fn write(self: *TickStore, instrument: []const u8, tick: Tick) !void;
    pub fn query(self: *TickStore, instrument: []const u8, from: u128, to: u128) !TickIterator;
    pub fn deinit(self: *TickStore) void;
};

// domain/parquet_writer.zig
pub const ParquetWriter = struct {
    pub fn init(allocator: std.mem.Allocator, path: []const u8, schema: Schema) !ParquetWriter;
    pub fn writeRowGroup(self: *ParquetWriter, columns: []const Column) !void;
    pub fn close(self: *ParquetWriter) !void;
};
```

### Test checkpoint
- Type: Automated
- Step A: Contract tests for recon (perfect match returns zero breaks, quantity mismatch flagged, missing trade flagged, tolerance allows small price differences), tick store (write/read round-trip, time-range query returns correct subset, date partition boundary handling, empty range returns no results), Parquet (write row group and verify file header magic bytes `PAR1`, column data retrievable)
- Step B: Implement until `zig build test` passes with zero leaks
- Verify: Full EOD workflow — snapshot positions, reconcile, export ticks to Parquet

---

## Phase 12: Trading Strategies + Analytics
**Delivers**: TCA (Implementation Shortfall decomposition, VWAP slippage, spread capture, fill rate), performance attribution (Brinson allocation/selection/interaction, factor-based), venue toxicity via VPIN, basis trading strategy (spot vs futures), perpetual funding rate arbitrage strategy
**Layers touched**: trading/ (strategies, analytics)
**Depends on**: Phases 10, 11

### Key types / signatures introduced
```zig
// trading/analytics/tca.zig
pub const TcaEngine = struct {
    pub fn init(allocator: std.mem.Allocator) !TcaEngine;
    pub fn analyze(self: *TcaEngine, executions: []const Execution, benchmark: Benchmark) !TcaReport;
    pub fn deinit(self: *TcaEngine) void;
};
pub const TcaReport = struct { is_cost_bps: f64, vwap_slippage_bps: f64, spread_capture: f64, fill_rate: f64 };

// trading/analytics/attribution.zig
pub const BrinsonAttribution = struct {
    pub fn compute(portfolio: []const Holding, benchmark: []const Holding) AttributionResult;
};
pub const AttributionResult = struct { allocation: f64, selection: f64, interaction: f64, total: f64 };

// trading/strategies/basis.zig
pub const BasisStrategy = struct {
    pub fn init(allocator: std.mem.Allocator, config: BasisConfig) !BasisStrategy;
    pub fn onMarketData(self: *BasisStrategy, spot: *const L2Book, futures: *const L2Book) ?Signal;
    pub fn deinit(self: *BasisStrategy) void;
};
pub const Signal = struct { direction: Direction, spot_qty: i64, futures_qty: i64, expected_basis_bps: f64 };
```

### Test checkpoint
- Type: Automated
- Step A: Contract tests for TCA (IS decomposition components sum to total cost, zero-slippage when all fills at arrival price, VWAP slippage sign correctness), Brinson attribution (allocation + selection + interaction = total excess return, zero-weight sectors contribute zero allocation effect), basis strategy (generates buy-spot/sell-futures signal when basis exceeds threshold, no signal when basis within band, signal quantities maintain hedge ratio)
- Step B: Implement until `zig build test` passes with zero leaks
- Verify: End-to-end simulation — strategy signals → algo execution → position/P&L tracking → TCA report

---

## Dependencies

```
Phase 1 ─┬─→ Phase 2 ──→ Phase 3 ──→ Phase 4 ──┐
          │                                       │
          ├─→ Phase 2 ──→ Phase 5 ───────────────┤
          │                                       │
          ├─→ Phase 6 ───────────────────────────┤
          │                                       │
          ├─→ Phase 9 (independent)               │
          │                                       │
          │              Phase 7 ←────────────────┘
          │                ↓
          │              Phase 8
          │                ↓
          ├─→ Phase 4 + Phase 6 → Phase 10
          │                          ↓
          │              Phase 11 ←─ Phase 7 + Phase 8
          │                ↓           ↓
          └──────────── Phase 12 ←── Phase 10 + Phase 11
```

- Phase 5 (FIX) and Phase 6 (OMS) can run **in parallel** with Phases 3-4 after their respective prerequisites
- Phase 9 (additional protocols) can run **anytime after Phase 1** — fully independent
- Phase 7 is the convergence point requiring Phases 3, 4, 5, and 6
- Phases 8-12 are sequential with limited parallelism
