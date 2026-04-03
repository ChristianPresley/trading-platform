---
phase: 3
iteration: 01
generated: 2026-04-03
---

# Design: Trading Platform SDK (Pure Zig) with Kraken Exchange Integration

Research: .claude/specs/trading-desk-kraken-integration/02-research-01.md

## Current State

No source code exists. The repository contains comprehensive documentation:
- `docs/trading-desk/` — 17 sections covering all aspects of a professional trading desk (market data, OMS, execution, risk, positions, connectivity, infrastructure, post-trade, compliance, UI, analytics) (`02-research-01.md:558`)
- `docs/kraken-exchange-documentation/` — 8 sections with full API specs for spot REST/WS/FIX and futures REST/WS (`02-research-01.md:555-558`)
- CLAUDE.md references .NET/C# but actual direction is pure Zig with zero external dependencies (`02-research-01.md:557`)

## Desired End State

A complete, pure-Zig SDK providing every building block needed for a professional trading platform. All components built natively — no external libraries, no C interop, no `.zon` dependencies. The SDK is a layered library consumed by exchange adapters (Kraken first) and trading applications. The design document serves as an architectural blueprint documenting how to build each component.

## Patterns to Follow

- **Gateway/adapter architecture**: Internal trading core communicates with per-venue gateways that handle protocol translation, session management, symbol mapping, and rate limiting — found at `02-research-01.md:239-241`
- **Event sourcing + CQRS**: Immutable ordered event log as the system of record; separate write (command) and read (projection) models — found at `02-research-01.md:274-275`
- **Lock-free structures on hot path**: Ring buffers, SPSC/MPSC queues, object pooling, cache-line alignment (64 bytes) for zero-contention data flow — found at `02-research-01.md:264-265`
- **Pre-trade risk pipeline**: Sequential validation stages (order validation → price check → size limits → position limits → credit check → rate throttle → duplicate check) — found at `02-research-01.md:193`
- **HMAC-SHA512 auth pattern**: Both Kraken spot and futures use HMAC-SHA512 with base64-decoded secrets, differing only in input construction — found at `02-research-01.md:553`
- **FIX protocol as lingua franca**: FIX tag-value encoding used across OMS, execution reports, market data, and Kraken's FIX API — found at `02-research-01.md:554`

## Patterns to Avoid

- **GC-based runtimes**: Research documents GC mitigation techniques (.NET `GC.TryStartNoGCRegion`, Java ZGC) as workarounds — found at `02-research-01.md:266`. Zig eliminates this entire problem class through explicit allocation.
- **External dependency chains**: Research references QuickFIX/J, QuickFIX/N, Chronicle FIX, etc. — found at `02-research-01.md:234-235`. These introduce C/C++/Java interop. All protocol implementations will be native Zig.
- **Kernel networking for hot path**: Research documents kernel bypass (OpenOnload, DPDK) reducing NIC-to-app latency from ~10us to ~1-2us — found at `02-research-01.md:152`. The SDK will use io_uring as the primary I/O model, avoiding kernel TCP/IP stack overhead where possible.

## Resolved Design Decisions

| Decision | Choice | Reason |
| --- | --- | --- |
| SDK scope | Full platform | All components documented as native Zig building blocks; covers entire trading desk |
| Module layout | Layered by abstraction | sdk/core → sdk/protocol → sdk/domain; strict dependency direction; exchanges/ and trading/ as consumers |
| TLS | Custom TLS 1.2/1.3 | Built on Zig std.crypto primitives (AES-GCM, ChaCha20-Poly1305, X25519, RSA, ECDSA, X.509); full control |
| Memory model | Arena + pool allocators | Cache-line aligned (64 bytes), pre-allocated pools for hot-path objects, huge page support via mmap |
| Serialization formats | All: JSON, FIX, SBE, FAST, ITCH, OUCH, PITCH | Exchange-ready from day one; covers Kraken and all traditional/electronic venues |
| Concurrency model | io_uring + dedicated pinned threads | io_uring event loop for general I/O; pinned threads with SPSC ring buffers for high-throughput feeds |
| Order book | L2 + L3 with shared BookView | Market-by-Price for Kraken/simple feeds; Market-by-Order for MBO exchanges; common query interface |
| Event store | Built-in append-only log | Sequence numbers, nanosecond timestamps, replay capability; satisfies audit trail requirements |
| Tick storage | Custom columnar + Parquet export | Column-oriented binary for real-time ingest; Parquet writer for offline analysis ecosystem |

## Approach

### Layer 1: sdk/core — Foundational Primitives

The core layer has zero dependencies beyond Zig's compiler builtins and provides:

**Memory management** (`core/memory.zig`): Arena allocator for request-scoped work (bulk free on scope exit), fixed-size pool allocator with slab allocation for hot-path objects (orders, book levels, events), and a huge-page allocator wrapping `mmap` with `MAP_HUGETLB`. All allocators conform to Zig's `std.mem.Allocator` interface. Pool allocator aligns all allocations to 64-byte cache lines.

**Cryptography** (`core/crypto/`): HMAC-SHA512 and SHA256 for Kraken authentication (`02-research-01.md:14-15`), Base64 encode/decode for API secrets, AES-128-GCM and AES-256-GCM for TLS record protection, ChaCha20-Poly1305 as alternative cipher suite, X25519 for TLS key exchange, RSA-PKCS1v15 and ECDSA-P256/P384 for X.509 certificate signature verification. Zig's `std.crypto` provides the underlying primitives; the SDK wraps them into trading-specific interfaces (e.g., `KrakenAuth.sign()`).

**Containers** (`core/containers/`): SPSC ring buffer (single-producer/single-consumer, lock-free, cache-line padded head/tail pointers) for inter-thread communication. MPSC queue for multiple producers feeding a single consumer. Fixed-capacity hash map with open addressing for order-ID lookups. Sorted array with binary search for price levels.

**Time** (`core/time.zig`): Nanosecond-precision timestamps from `CLOCK_MONOTONIC_RAW` (for latency measurement) and `CLOCK_REALTIME` (for wall-clock). Conversion between Unix nanoseconds, RFC3339 (Kraken WS v2, `02-research-01.md:40`), ISO8601 (Kraken Futures, `02-research-01.md:89`), and FIX UTCTimestamp formats.

**I/O** (`core/io/`): io_uring-based event loop wrapping `std.os.linux.IoUring` — submission/completion ring management, socket read/write, timer scheduling, buffer registration for zero-copy receives. Thread pinning via `sched_setaffinity` with NUMA-aware core selection. TCP connection management with configurable timeouts.

**Event store** (`core/event_store.zig`): Append-only memory-mapped file with 64-bit sequence numbers and 128-bit nanosecond timestamps. Zero-copy reads via mmap. Sequence gap detection for integrity. Replay iterator for state reconstruction. Date-partitioned files for retention management.

### Layer 2: sdk/protocol — Wire Protocols

The protocol layer depends only on core and implements every wire format:

**TLS** (`protocol/tls/`): Custom TLS 1.2 and 1.3 client implementation. Handshake state machine (ClientHello → ServerHello → certificate validation → key exchange → Finished). Cipher suites: TLS_AES_128_GCM_SHA256, TLS_AES_256_GCM_SHA384, TLS_CHACHA20_POLY1305_SHA256 for TLS 1.3; TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 for TLS 1.2. X.509 certificate chain validation against a bundled CA store. Session resumption via tickets. Built on core crypto primitives.

**HTTP** (`protocol/http/`): HTTP/1.1 client built on TLS. Request/response parsing with zero-copy headers. Connection pooling and keep-alive. Chunked transfer encoding. URL parsing. Sufficient for all Kraken REST endpoints (`02-research-01.md:21-35`).

**WebSocket** (`protocol/websocket/`): RFC 6455 implementation over HTTP upgrade. Frame parsing (text, binary, ping, pong, close). Automatic ping/pong for keepalive (Kraken requires ~1 min, `02-research-01.md:42`). Reconnection logic with Cloudflare rate limit awareness (150 reconnects per 10 min, `02-research-01.md:42`). Message fragmentation and reassembly.

**JSON** (`protocol/json.zig`): Streaming pull parser (SAX-style) for zero-allocation parsing of large responses. DOM builder for smaller payloads. Serializer with compile-time struct reflection. Handles Kraken's `result`/`error` response format (`02-research-01.md:33`).

**FIX** (`protocol/fix/`): FIX 4.2, 4.4, and 5.0 SP2 tag-value codec (`02-research-01.md:225`). Session layer (FIXT 1.1): Logon/Logout, Heartbeat/TestRequest, ResendRequest/SequenceReset with PossDupFlag handling. Sequence number persistence across disconnections (`02-research-01.md:228`). SOH delimiter parsing, checksum (tag 10) validation. Message type dispatch. Covers Kraken FIX API (`02-research-01.md:45-51`) and traditional exchange connectivity.

**SBE** (`protocol/sbe.zig`): Simple Binary Encoding for CME MDP 3.0 and Eurex T7 (`02-research-01.md:144`). Schema-driven zero-copy decoder — fixed-layout binary with compile-time field offset calculation. Message header parsing, group and vardata handling.

**FAST** (`protocol/fast.zig`): FIX Adapted for Streaming — presence maps, stop-bit encoding, delta/increment operators (`02-research-01.md:143`). Template-driven decoder for compressed market data feeds.

**ITCH** (`protocol/itch.zig`): NASDAQ TotalView-ITCH unidirectional binary protocol. Message types: Add Order (A/F), Execute (E/C), Cancel (X), Delete (D), Replace (U), Trade (P) (`02-research-01.md:145`). Fixed-width messages, no framing — length-prefixed on TCP.

**OUCH** (`protocol/ouch.zig`): Order entry companion to ITCH (`02-research-01.md:146`). Enter Order, Replace Order, Cancel Order, and execution/cancel confirmations.

**PITCH** (`protocol/pitch.zig`): Cboe binary protocol, similar to ITCH (`02-research-01.md:147`). Add Order, Execute, Cancel, Trade messages with multicast UDP transport support.

### Layer 3: sdk/domain — Trading Domain Models

The domain layer depends on core and protocol, implementing business logic:

**Order book** (`domain/orderbook.zig`): L2 (Market-by-Price) using sorted price-level arrays with O(1) top-of-book and O(log n) insert. L3 (Market-by-Order) using price-level map with per-level doubly-linked order queues and order-ID hash map for O(1) lookup. Shared `BookView` interface for best bid/ask, depth, spread, mid-price. Book builder from ITCH/SBE incremental messages with sequence gap detection (`02-research-01.md:163-164`).

**Order state machine** (`domain/oms.zig`): FIX-standard OrdStatus states — PendingNew, New, PartiallyFilled, Filled, Cancelled, Replaced, PendingCancel, Rejected, Suspended, PendingReplace, Expired (`02-research-01.md:102`). Validated state transitions with race condition handling: fill-before-cancel, fill-before-replace, unsolicited cancel (`02-research-01.md:107`). Order versioning with ClOrdID/OrigClOrdID linkage (`02-research-01.md:111`). Internal states: Staged, Validating, RoutePending (`02-research-01.md:110`).

**Order types** (`domain/order_types.zig`): Market, Limit, Stop, Stop-Limit, Trailing Stop with FIX tag mappings (`02-research-01.md:94-99`). Time-in-force: Day, GTC, IOC, FOK, GTD (`02-research-01.md:95`). Bracket orders (primary + take-profit + stop-loss), OCO pairs, contingent orders (`02-research-01.md:122-125`). Parent-child relationships with quantity invariants (`02-research-01.md:121`).

**Position tracking** (`domain/positions.zig`): Position keyed by (Account, Instrument, SettlementDate, Currency, LegalEntity) (`02-research-01.md:310`). Real-time realized and unrealized P&L (`02-research-01.md:312-313`). Cost basis methods: FIFO, LIFO, specific identification, average cost (`02-research-01.md:338`). Multi-currency with base currency conversion (`02-research-01.md:327`). P&L attribution decomposition: TradePnL + PositionPnL + CarryPnL + FxPnL + Fees (`02-research-01.md:317`).

**Pre-trade risk** (`domain/risk/pre_trade.zig`): Sequential validation pipeline (`02-research-01.md:193`). Size limits (max shares, max notional, max % ADV), price reasonability checks (% from NBBO mid, % from last trade), message rate throttling, duplicate detection (`02-research-01.md:194-196`). Configurable limit hierarchy: board → division → desk → trader → strategy (`02-research-01.md:199`). Utilization zones with breach escalation (`02-research-01.md:200-201`).

**Risk calculations** (`domain/risk/`): VaR — historical, parametric (`z_alpha * sigma * sqrt(T)`), Monte Carlo with Cholesky decomposition (`02-research-01.md:174-176`). Expected Shortfall / CVaR (`02-research-01.md:177`). Options Greeks — Delta, Gamma, Vega, Theta, Rho with Black-Scholes formulas (`02-research-01.md:180-184`). Fixed income — DV01, Key Rate DV01s, CS01, Convexity (`02-research-01.md:187-190`). Stress testing with historical and hypothetical scenarios (`02-research-01.md:205-208`). Risk attribution with factor models and marginal/component VaR (`02-research-01.md:215-216`).

**Market data normalization** (`domain/market_data.zig`): Symbology mapping (exchange-native, ISIN, CUSIP, FIGI) (`02-research-01.md:137`). Price scaling (integer prices with implicit decimal), timestamp normalization to UTC nanoseconds, venue identification to ISO 10383 MIC (`02-research-01.md:138`). Bar aggregation: OHLCV at configurable intervals, plus volume bars, dollar bars, tick bars (`02-research-01.md:167-168`). VWAP calculation with trade condition filtering (`02-research-01.md:169`).

**Tick store** (`domain/tick_store.zig`): Custom column-oriented binary format — date-partitioned directories with per-column files (timestamp, price, quantity, side). Delta encoding on timestamps, varint encoding on integer-scaled prices. Memory-mapped reads for zero-copy queries. Time-range query support via binary search on timestamp column. **Parquet writer** (`domain/parquet_writer.zig`): Batch export to Apache Parquet format for offline analysis in Python/DuckDB/Pandas.

**Execution algorithms** (`domain/algos/`): VWAP (historical volume profile, participation limits), TWAP (equal slices with randomization), POV/Participation (real-time volume tracking), Implementation Shortfall (arrival price benchmark, impact models) (`02-research-01.md:363-366`). Iceberg, Sniper/Liquidity Seeking, Dark Pool, Pairs Trading, Adaptive/Multi-Strategy (`02-research-01.md:368-372`). Algorithm parameter framework with urgency levels (`02-research-01.md:375`).

**Smart order routing** (`domain/sor.zig`): Venue scoring and routing decision flow (`02-research-01.md:382`). Fee optimization (maker-taker vs inverted) (`02-research-01.md:381`). Dark pool pinging logic (`02-research-01.md:369`).

**Post-trade** (`domain/post_trade/`): Trade confirmation matching (`02-research-01.md:401`). Reconciliation engine: trade, position, and cash recon with configurable tolerances and break management (`02-research-01.md:354-358`). SOD/EOD procedures: position snapshots, corporate action processing, P&L sign-off workflow (`02-research-01.md:347-351`). Allocation and average pricing (`02-research-01.md:413-414`).

### Layer 4: exchanges/kraken — First Exchange Adapter

Consumes all SDK layers to implement Kraken connectivity:

**Spot adapter** (`exchanges/kraken/spot/`): REST client for all public and private endpoints (`02-research-01.md:21-22`). Authentication with HMAC-SHA512 signing and nonce management (`02-research-01.md:14-18`). WebSocket v2 client with token refresh (15-min validity, `02-research-01.md:39`). FIX client with SenderCompID auth and sequence number management (`02-research-01.md:45-48`). Rate limit tracking: call counter with tier-based decay (`02-research-01.md:27-29`).

**Futures adapter** (`exchanges/kraken/futures/`): REST client with distinct authentication (different header names, different signature input construction, `02-research-01.md:62-64`). WebSocket with challenge-based auth (`02-research-01.md:75`). Rate limit: 500 cost units per 10 seconds (`02-research-01.md:68`). Dead man's switch support (`02-research-01.md:58`). Multi-collateral margin tracking (`02-research-01.md:78-82`).

**Symbol mapping**: Spot pairs like "BTC/USD" vs futures prefixed symbols like "fi_xbtusd" (`02-research-01.md:88`).

### Layer 5: trading/ — Application Layer

**Strategies** (`trading/strategies/`): Algo execution orchestration consuming domain/algos. Basis trading: spot on Kraken + CME futures (`02-research-01.md:546-548`). Perpetual funding rate arbitrage (`02-research-01.md:529-530`).

**Analytics** (`trading/analytics/`): TCA — IS decomposition, VWAP slippage, spread capture, fill rate (`02-research-01.md:385-388`). Performance attribution: Brinson (allocation + selection + interaction) and factor-based (`02-research-01.md:495-496`). Venue toxicity analysis via VPIN (`02-research-01.md:396`).

## Open Questions

(none — all design decisions resolved)
