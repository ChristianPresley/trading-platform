## Capacity Planning and Performance

### Throughput Requirements

| Component | Typical Requirement | Peak Multiplier |
|-----------|--------------------|-----------------| 
| Order entry throughput | 1,000 - 100,000 orders/second | 5-10x during volatility events |
| Market data ingest | 1-10 million messages/second (per exchange) | 3-5x during market opens/closes |
| Risk calculations | Evaluate every order in < 50 microseconds | Must scale linearly with order rate |
| Position updates | Real-time for every fill | Burst during auction matches |
| Historical data queries | Millions of rows per query | Concurrent users add load |

### Latency Budgets

A typical tick-to-trade latency budget for a co-located trading system:

| Stage | Budget | Cumulative |
|-------|--------|------------|
| NIC to application (kernel bypass) | 1-3 us | 3 us |
| Market data decode | 0.5-2 us | 5 us |
| Book update | 0.1-0.5 us | 5.5 us |
| Signal/strategy logic | 1-10 us | 15.5 us |
| Pre-trade risk check | 1-5 us | 20.5 us |
| Order encode | 0.5-2 us | 22.5 us |
| Application to NIC (kernel bypass) | 1-3 us | 25.5 us |
| Wire latency (cross-connect) | 0.1-0.5 us | 26 us |

**Total tick-to-trade: ~20-30 microseconds** for an aggressive co-located system. Less latency-sensitive systems may budget 100-500 microseconds.

### Exchange Rate Limits

| Exchange | Rate Limit | Notes |
|----------|-----------|-------|
| CME (iLink 3) | 500 messages/second per session | Can request multiple sessions |
| Nasdaq | Varies by port type; typically 10,000+ msgs/sec | Higher for market makers |
| NYSE (Pillar) | 1,000 orders/second per MPID | Can request increases |
| Cboe | Varies by market; typically 10,000+ msgs/sec | Port-based limits |
| Eurex (T7) | Throttle per session; typically 50-200 transactions/sec | Higher for market makers |

Exceeding rate limits results in rejected orders or temporary session disconnection. Trading systems must implement client-side throttling with token bucket or leaky bucket algorithms.

### Market Data Message Rates

| Feed | Normal Rate | Peak Rate |
|------|-------------|-----------|
| Nasdaq TotalView (full book) | 1-5M msgs/sec | 10-20M msgs/sec |
| NYSE ArcaBook | 500K-2M msgs/sec | 5-10M msgs/sec |
| CME MDP 3.0 | 200K-1M msgs/sec | 2-5M msgs/sec |
| Options (OPRA) | 10-50M msgs/sec | 100M+ msgs/sec |
| SIP (consolidated) | 1-5M msgs/sec | 10M+ msgs/sec |

**OPRA** (Options Price Reporting Authority) is the highest-throughput market data feed in the world, driven by the combinatorial explosion of option chains across strikes and expirations.

### Capacity Planning Process

1. **Baseline**: Measure current production throughput, latency percentiles, and resource utilization
2. **Growth modeling**: Project volume growth based on new instruments, strategies, venues, and market trends
3. **Stress testing**: Simulate 3-10x normal volume to identify bottlenecks
4. **Headroom**: Maintain 30-50% CPU headroom on critical-path servers; 50% memory headroom
5. **Hardware refresh cycle**: Plan upgrades every 18-24 months; coordinate with exchange protocol upgrades

---

## Database Considerations

### Time-Series Databases

Time-series data (tick data, OHLCV bars, performance metrics) is the dominant data type in trading. Specialized databases provide orders-of-magnitude better performance than relational databases for time-series workloads.

#### kdb+/q (Kx Systems, FD Technologies)

- **Status**: The de facto standard for tick data storage and analytics in capital markets
- **Design**: Column-oriented, in-memory database with the **q** programming language (a descendant of APL/K)
- **Performance**: Can ingest millions of rows per second; query billions of rows in milliseconds
- **Strengths**: Vector processing; built-in temporal joins; tightly integrated query language; HDB (Historical Database) on disk, RDB (Real-time Database) in memory
- **Usage**: Virtually every major bank and hedge fund uses kdb+ for tick data, back-testing, and real-time analytics
- **Cost**: One of the most expensive database licenses in the industry; historically priced per CPU core
- **Ecosystem**: First Derivatives provides consulting; large community of q developers in finance

#### InfluxDB

- **Design**: Purpose-built time-series database; open-source core
- **Query language**: InfluxQL (SQL-like) and Flux (functional)
- **Strengths**: Easy to deploy; good for operational metrics and moderate-volume time series
- **Weaknesses**: Not suitable for the volume and query complexity of institutional tick data
- **Usage**: Infrastructure monitoring, strategy performance metrics, moderate-volume analytics

#### TimescaleDB

- **Design**: PostgreSQL extension for time-series data; hypertables with automatic time-based partitioning
- **Strengths**: Full SQL compatibility; leverages PostgreSQL ecosystem (extensions, tools, expertise); continuous aggregates
- **Usage**: Good middle ground when teams want time-series performance with PostgreSQL familiarity
- **Consideration**: Performance gap vs. kdb+ for pure tick analytics, but much more accessible

#### QuestDB

- **Design**: Column-oriented time-series database; SQL interface; designed for high-throughput ingest
- **Strengths**: Very high ingest rates; SQL compatibility; lower cost than kdb+
- **Usage**: Emerging alternative to kdb+ for tick data; growing adoption in fintech

### Relational Databases

Still essential for reference data, configuration, order state, and position management.

| Database | Trading Usage | Notes |
|----------|---------------|-------|
| **SQL Server** | Order management, position management, configuration, compliance | Dominant in .NET shops; strong in Windows-based trading environments |
| **Oracle** | Enterprise trading systems, especially in large banks | Historical dominance; RAC for HA; Exadata for performance |
| **PostgreSQL** | Increasingly replacing Oracle/SQL Server; strong in newer platforms | Cost-effective; extensible (TimescaleDB, PostGIS); strong community |
| **Sybase ASE** (now SAP) | Legacy trading systems, especially in equities | Declining but still present in some firms |

**Key relational DB requirements for trading**:

- **Low-latency queries**: Sub-millisecond for order lookups by ClOrdID or OrderID
- **High write throughput**: Thousands of order state updates per second
- **Partitioning**: By date for historical queries; by instrument for concurrent access
- **Replication**: Synchronous replication for DR; read replicas for reporting

### In-Memory Data Grids and Caches

For data that must be accessed with sub-millisecond latency but needs to be shared across processes or servers.

| Product | Vendor | Description |
|---------|--------|-------------|
| **Redis** | Redis Ltd | In-memory key-value store; widely used for caching, pub/sub, and session state. Redis Streams for event streaming. |
| **Hazelcast** | Hazelcast | Distributed in-memory data grid; Java-native; used for position caches, instrument caches |
| **Oracle Coherence** | Oracle | Enterprise distributed cache; used in large bank trading platforms |
| **Apache Ignite** | Apache | Distributed in-memory platform; SQL support; compute grid |
| **GemFire / Apache Geode** | VMware | Distributed cache; event-driven; used in financial services |
| **Memcached** | Open source | Simple distributed cache; less feature-rich than Redis |
| **Microsoft Garnet** | Microsoft | High-performance cache-store; compatible with Redis protocol; .NET-optimized |

**Common caching patterns in trading**:

- **Instrument cache**: All tradeable instruments with their attributes (tick size, lot size, trading hours, margin requirements)
- **Position cache**: Real-time positions by account, instrument, and strategy
- **Price cache**: Last-traded price, NBBO, VWAP for every instrument
- **Order state cache**: Active orders indexed by ClOrdID, OrderID, and instrument
- **Risk limit cache**: Current utilization vs. configured limits
