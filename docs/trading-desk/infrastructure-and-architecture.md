# Infrastructure and Architecture

Comprehensive reference for infrastructure patterns, system architecture, deployment, and operational considerations in professional trading desk applications.

---

## Table of Contents

1. [Low-Latency Architecture Patterns](#low-latency-architecture-patterns)
2. [Event-Driven Architecture](#event-driven-architecture)
3. [High Availability and Disaster Recovery](#high-availability-and-disaster-recovery)
4. [System Monitoring and Alerting](#system-monitoring-and-alerting)
5. [Capacity Planning and Performance](#capacity-planning-and-performance)
6. [Database Considerations](#database-considerations)
7. [Security Architecture](#security-architecture)
8. [Configuration Management](#configuration-management)
9. [Deployment and Release Management](#deployment-and-release-management)
10. [Scalability Patterns](#scalability-patterns)
11. [Cloud vs On-Premise Considerations](#cloud-vs-on-premise-considerations)

---

## Low-Latency Architecture Patterns

In electronic trading, latency directly impacts profitability. Market-making, statistical arbitrage, and other latency-sensitive strategies require tick-to-trade times measured in microseconds. Even for less aggressive strategies, lower latency improves fill rates and execution quality.

### Kernel Bypass Networking

Standard Linux networking traverses the kernel network stack (syscalls, interrupt handling, socket buffers, context switches), adding 10-50 microseconds of overhead. Kernel bypass eliminates this entirely.

#### Solarflare/Xilinx OpenOnload

- **What**: User-space network stack that intercepts standard socket calls and processes them in the application process, bypassing the kernel entirely
- **How**: Uses Solarflare (now AMD/Xilinx) NICs with dedicated hardware support; the NIC DMAs packets directly to user-space memory
- **Latency reduction**: Kernel stack ~20-50us down to ~2-5us for network I/O
- **API compatibility**: Drop-in replacement; standard BSD sockets work unmodified via LD_PRELOAD
- **ef_vi API**: For maximum performance, applications can use the proprietary ef_vi API to interact with the NIC at the lowest level (zero-copy, poll-mode)
- **Deployment**: Dominant in HFT and electronic market-making; virtually every serious co-located trading system uses OpenOnload or equivalent

#### DPDK (Data Plane Development Kit)

- **What**: Intel-originated framework for high-performance packet processing entirely in user space
- **How**: NIC is unbound from the kernel driver; DPDK poll-mode driver (PMD) reads packets directly from NIC ring buffers in a busy-poll loop
- **Strengths**: Hardware-agnostic (supports Intel, Mellanox/NVIDIA, Broadcom NICs); extremely high throughput (100M+ packets/second); extensive ecosystem
- **Weaknesses**: Requires dedicating CPU cores to polling; more complex than OpenOnload; not a drop-in socket replacement
- **Usage in trading**: Custom market data feed handlers; FPGA coprocessor interfaces; ultra-low-latency gateways

#### Other Kernel Bypass Approaches

| Technology | Description |
|------------|-------------|
| **Mellanox/NVIDIA VMA** | Verbs-based user-space stack for Mellanox NICs; similar concept to OpenOnload |
| **io_uring** | Linux async I/O interface; not full kernel bypass but significantly reduces syscall overhead |
| **XDP (eXpress Data Path)** | eBPF-based packet processing at the driver level; lower latency than standard stack but not full user-space |
| **RDMA (Remote DMA)** | InfiniBand or RoCE; zero-copy, kernel-bypass network transfers; used for inter-server communication in HFT clusters |

### Busy Polling and CPU Affinity

- **Busy polling**: Instead of blocking on I/O (epoll_wait), the application continuously polls for new data in a tight loop. Eliminates interrupt latency and context switch overhead at the cost of 100% CPU utilization on the polling core.
- **CPU pinning (affinity)**: Bind critical threads to specific CPU cores using `sched_setaffinity()` or `taskset`. Prevents the OS scheduler from migrating threads, avoiding cache pollution.
- **CPU isolation**: Use `isolcpus` kernel parameter or `cset` to remove cores from the general scheduler entirely, dedicating them to trading processes.
- **NUMA awareness**: Pin threads and allocate memory on the same NUMA node as the NIC to avoid cross-socket memory access penalties (50-100ns additional latency).
- **IRQ affinity**: Direct NIC interrupts (when used) to specific cores, away from trading-critical cores.

### Lock-Free Data Structures

Traditional mutexes and locks cause thread contention, priority inversion, and unpredictable latency spikes. Lock-free alternatives use atomic CPU instructions (CAS, fetch-and-add) to achieve thread safety without blocking.

| Data Structure | Pattern | Usage |
|----------------|---------|-------|
| **LMAX Disruptor** (ring buffer) | Single-producer/multi-consumer or multi-producer/multi-consumer; sequence-based coordination | Core pattern in many Java trading systems; inter-thread event passing |
| **SPSC queue** (single-producer, single-consumer) | Lock-free via memory ordering (acquire/release semantics) | Passing orders/events between dedicated threads |
| **MPSC queue** | Multiple producers, single consumer; CAS-based | Aggregating events from multiple sources |
| **Lock-free hash maps** | CAS-based insertion and lookup | Order book lookups, instrument caches |
| **Atomic counters** | `std::atomic` / `Interlocked` operations | Sequence numbers, statistics counters |

**Key libraries**:

- **LMAX Disruptor** (Java): The foundational ring buffer; used by LMAX Exchange
- **Agrona** (Java, Real Logic): Concurrent data structures used in Aeron
- **liblfds** (C): Portable lock-free data structures
- **.NET `System.Threading.Channels`**: High-performance bounded/unbounded channels
- **.NET `ConcurrentQueue<T>`**: Lock-free MPMC queue in the standard library

### Memory-Mapped Files

Memory-mapped files (`mmap` on Linux, `MemoryMappedFile` in .NET) map file contents directly into process virtual memory, enabling:

- **Persistent shared memory**: Multiple processes can share data through a memory-mapped file with zero-copy
- **Message passing**: Chronicle Queue (Java) uses memory-mapped files for inter-process messaging with microsecond latency and automatic persistence
- **State persistence**: Order state, position data, and sequence numbers persisted via mmap with minimal overhead
- **Recovery**: On restart, the process simply re-maps the file and has immediate access to prior state

**Chronicle Queue** (Chronicle Software) is the most prominent trading-specific implementation:

- Append-only log structure
- Sub-microsecond write latency
- Automatic roll by time or size
- Built-in replay capability
- Zero garbage collection overhead

### Additional Low-Latency Techniques

| Technique | Description |
|-----------|-------------|
| **Huge pages** | 2MB or 1GB pages reduce TLB misses; critical for large working sets (order books, market data caches) |
| **Pre-allocation** | Allocate all memory at startup; avoid runtime allocation on the critical path |
| **Object pooling** | Reuse objects instead of allocating/freeing; eliminates GC pressure in managed languages |
| **Cache-line optimization** | Align data structures to 64-byte cache lines; avoid false sharing between cores |
| **Branch prediction hints** | Use `likely()`/`unlikely()` macros; arrange code so the hot path is the predicted path |
| **Short-string optimization** | Avoid heap allocation for short strings (symbols, IDs) |
| **JIT warmup** (Java/.NET) | Force JIT compilation of critical paths before market open; use AOT (Ahead-of-Time) compilation where possible |
| **GC tuning** | For .NET: use `GC.TryStartNoGCRegion()`, server GC mode, pinned arrays. For Java: Azul Zing C4, ZGC, or Shenandoah GC; or go off-heap entirely |
| **FPGA acceleration** | Offload protocol parsing, risk checks, or order generation to FPGA hardware for sub-microsecond processing |

### Latency Measurement

Accurate latency measurement is essential:

- **Hardware timestamping**: NIC hardware timestamps on packet arrival; nanosecond precision
- **Kernel timestamps** (`SO_TIMESTAMPING`): Software timestamps at various points in the kernel stack
- **Corvil/Pico** (now part of Cisco/Corvil): Network monitoring appliances that capture and timestamp every packet with nanosecond precision
- **Internal instrumentation**: Measure critical path segments (wire-to-app, app processing, app-to-wire) separately
- **Percentile reporting**: p50, p99, p99.9, p99.99 latencies; the tail matters more than the median in trading

---

## Event-Driven Architecture

### Event Sourcing

Instead of storing current state, the system stores an immutable, ordered log of all state-changing events. Current state is derived by replaying events.

**Benefits for trading**:

- **Complete audit trail**: Every order, fill, cancel, and modification is an event in the log
- **Replay and debugging**: Reproduce any historical state by replaying events up to a point in time
- **Regulatory compliance**: Immutable event log satisfies record-keeping requirements
- **Disaster recovery**: Rebuild state from the event log after a failure
- **Testing**: Replay production event streams against new code to verify behavior

**Implementation considerations**:

- **Event store**: Kafka, EventStoreDB, Chronicle Queue, custom append-only log
- **Snapshotting**: Periodically snapshot derived state to avoid replaying the entire history on startup
- **Schema evolution**: Events are immutable; schema changes require versioned event types and upcasting
- **Event ordering**: Global ordering (single partition) vs. per-entity ordering (partitioned by order ID or instrument)

### CQRS (Command Query Responsibility Segregation)

Separates the write model (commands that change state) from the read model (queries that return state):

```
Commands (NewOrder, CancelOrder, ModifyOrder)
         |
    ┌────v────────────────┐
    │   Command Handler   │
    │  (validates, emits  │
    │   domain events)    │
    └────────┬────────────┘
             │
        Domain Events
             │
    ┌────────v────────────┐      ┌──────────────────┐
    │    Event Store      │─────>│  Read Model       │
    │  (source of truth)  │      │  Projections      │
    └─────────────────────┘      │  (positions, P&L, │
                                 │   blotters, books) │
                                 └──────────────────┘
```

**Benefits**: Write model optimized for validation and consistency; read models optimized for specific query patterns (trader blotter, risk dashboard, compliance view). Multiple independent read models can be maintained.

### Event Bus

An event bus distributes events to interested consumers:

- **Internal**: LMAX Disruptor, Aeron, shared memory, .NET Channels
- **Cross-process**: Kafka, Solace, TIBCO, Aeron
- **Patterns**: Fan-out (one event, many consumers), event routing (content-based), event filtering

### Complex Event Processing (CEP)

CEP engines detect patterns across streams of events in real time:

| Product | Vendor | Description |
|---------|--------|-------------|
| **Esper** | EsperTech | Open-source Java CEP; SQL-like EPL (Event Processing Language) |
| **Apama** (now part of Software AG/IBM) | Software AG | Enterprise CEP; widely used in algo trading and surveillance |
| **Kx/kdb+** (q language) | Kx Systems (FD Technologies) | Time-series database with built-in streaming analytics; de facto standard in quant finance |
| **Flink** | Apache | Distributed stream processing; used for real-time analytics pipelines |
| **Kafka Streams / ksqlDB** | Confluent | Stream processing on Kafka; useful for derived data and materialized views |
| **Coral8/Sybase CEP** | Legacy | Historical CEP; many trading systems built on these |

**Trading CEP use cases**:

- **Algo logic**: Detect price patterns, volume spikes, spread changes
- **Risk monitoring**: Alert when position limits approach thresholds; detect unusual order rates
- **Surveillance**: Detect spoofing (large orders canceled shortly after submission), layering, wash trading
- **Market quality**: Monitor spread widths, trade-through rates, fill ratios

---

## High Availability and Disaster Recovery

Trading systems have stringent availability requirements. Unplanned downtime during market hours has direct financial impact and regulatory consequences.

### Deployment Topologies

#### Active-Active

Both sites process traffic simultaneously; load is distributed across sites:

```
            ┌─────────┐     ┌─────────┐
            │  Site A  │<--->│  Site B  │
            │(Primary) │sync │(Primary)│
            └─────────┘     └─────────┘
                 │               │
            Exchange A      Exchange B
```

- **Strengths**: No wasted capacity; lower latency for geographically distributed venues; no failover delay
- **Challenges**: State synchronization between sites; split-brain prevention; more complex operationally
- **Usage**: Multi-region trading (e.g., US and European operations); market data distribution

#### Active-Passive (Hot Standby)

Primary site handles all traffic; standby site maintains synchronized state but does not process orders:

- **State replication**: Synchronous or asynchronous replication of order state, positions, and configuration
- **Failover trigger**: Manual (operator decision) or automated (health check failure)
- **Failover time**: Target < 30 seconds for warm standby; < 5 minutes for cold standby
- **Usage**: Most common DR pattern for trading systems; simpler to reason about

#### Active-Passive (Warm Standby)

Standby site is running and receiving replicated state but requires manual activation:

- Applications are running but not connected to exchanges
- FIX sessions are pre-configured but not initiated
- On failover: establish exchange sessions, verify state, begin processing

### RTO and RPO Requirements

| Component | RTO (Recovery Time Objective) | RPO (Recovery Point Objective) |
|-----------|------------------------------|-------------------------------|
| Order management | < 2 minutes | Zero (no order loss) |
| Market data | < 30 seconds | N/A (stateless stream) |
| Risk engine | < 1 minute | Zero (positions must be accurate) |
| Post-trade / STP | < 15 minutes | < 1 minute |
| Analytics / Reporting | < 1 hour | < 5 minutes |

### Failover Mechanisms

- **FIX session failover**: Secondary FIX sessions pre-configured at the exchange; activate on primary failure. Exchange supports session migration or firm initiates new session with sequence reset.
- **Database failover**: SQL Server Always On AG, Oracle Data Guard, PostgreSQL streaming replication with Patroni
- **Application failover**: Kubernetes pod rescheduling, VM live migration, or dedicated failover scripts
- **Network failover**: Dual-homed connectivity; BGP-based failover; redundant cross-connects
- **DNS-based failover**: Weighted or health-check-based DNS routing (less common for latency-sensitive paths)

### Geo-Redundant Sites

Typical trading firm site strategy:

| Site | Location | Role |
|------|----------|------|
| Primary | Co-located at exchange (e.g., Equinix NY5) | Production trading |
| DR | Nearby but separate facility (e.g., Equinix NY4/NY9) | Hot/warm standby |
| Tertiary | Different region (e.g., Chicago, London) | Cold standby; covers regional catastrophe |
| Office | Corporate headquarters | Development, monitoring, non-latency-sensitive operations |

### Testing DR

- **DR drills**: Mandatory periodic failover tests (at minimum quarterly)
- **Chaos engineering**: Inject failures to test resilience (Netflix-style)
- **Weekend DR tests**: Full site failover during non-market hours
- **Regulatory expectation**: SEC, FCA, MAS, and other regulators expect documented DR procedures and test results

---

## System Monitoring and Alerting

### Application Monitoring

| Category | What to Monitor | Tools |
|----------|-----------------|-------|
| **Order flow** | Order rates, fill rates, reject rates, cancel rates, order-to-trade ratio | Custom dashboards; Grafana |
| **Latency** | Tick-to-trade, order-to-ack, internal processing time per component | Histogram metrics; Prometheus; custom instrumentation |
| **FIX sessions** | Connection status, sequence numbers, heartbeat status, message rates | FIX engine admin interface; custom monitors |
| **Market data** | Feed status, gap count, stale tick detection, message rates per feed | Feed handler metrics; comparison across redundant feeds |
| **Risk** | Position vs. limits, P&L vs. thresholds, margin utilization | Risk engine dashboards; real-time alerts |
| **Business logic** | Strategy performance, algo completion rates, SOR routing statistics | Custom analytics |

### Infrastructure Monitoring

| Category | What to Monitor | Tools |
|----------|-----------------|-------|
| **Servers** | CPU, memory, disk I/O, network I/O, GC pauses | Prometheus + node_exporter, Datadog, Zabbix |
| **Network** | Packet loss, jitter, latency (one-way and round-trip), NIC statistics | Corvil, ExtraHop, DPDK stats, ethtool counters |
| **Storage** | Disk utilization, I/O latency, replication lag | Storage vendor tools; OS metrics |
| **Middleware** | Queue depths, message rates, consumer lag, broker health | Solace admin, Kafka consumer lag (Burrow), TIBCO admin |
| **Database** | Query latency, connection pool, replication lag, lock contention | Database-specific tools; Prometheus exporters |

### Monitoring Stack

Common monitoring architecture for trading:

```
Application Metrics ──> Prometheus/InfluxDB ──> Grafana (dashboards)
                                                      │
Application Logs ────> ELK Stack (Elasticsearch,      v
                       Logstash, Kibana) or Splunk   Alertmanager/
                                                     PagerDuty/
Network Packets ─────> Corvil/Pico Analytics         OpsGenie
                                                      │
Infrastructure ──────> Datadog/Zabbix/Nagios    ──>  On-call
```

**Trading-specific monitoring products**:

| Product | Vendor | Capability |
|---------|--------|------------|
| **Corvil** | Cisco (Corvil) | Wire-level network analytics; nanosecond timestamping; protocol-aware (FIX, ITCH, etc.) |
| **Pico** (now Corvil) | Acquired by Cisco | Similar to Corvil; network monitoring for financial markets |
| **ExtraHop** | ExtraHop Networks | Wire data analytics; real-time protocol analysis |
| **Geneos** | ITRS Group | Trading infrastructure monitoring; widely used in banks |
| **AppDynamics / Dynatrace** | Cisco / Dynatrace | Application performance monitoring; less common in ultra-low-latency |
| **Splunk** | Cisco (Splunk) | Log analytics; very common in trading firms for operational intelligence |
| **Elastic Stack (ELK)** | Elastic | Open-source log and event analytics |

### SLA Tracking

Key SLAs for a trading platform:

| SLA | Target | Measurement |
|-----|--------|-------------|
| System availability (market hours) | 99.99% (< 52 min downtime/year) | Uptime monitors |
| Order acknowledgment latency | < 500 microseconds (p99) | Internal instrumentation |
| Market data freshness | < 100 microseconds from exchange (co-located) | Hardware timestamping |
| Risk check latency | < 50 microseconds (pre-trade) | Internal instrumentation |
| Failover time | < 2 minutes | DR drill measurement |
| Trade report delivery | < 15 minutes from execution | Post-trade pipeline monitoring |

### Alerting Best Practices

- **Severity tiers**: P1 (immediate page: system down, data loss), P2 (urgent: degraded performance, single component failure), P3 (warning: approaching thresholds), P4 (informational)
- **Runbooks**: Every alert has an associated runbook with diagnosis and remediation steps
- **Escalation**: Automated escalation if acknowledgment is not received within defined windows
- **Suppression**: During known maintenance windows or exchange outages, suppress related alerts
- **Market-hours awareness**: Higher sensitivity during market hours; different on-call rotation

---

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

---

## Security Architecture

### Network Segmentation

Trading infrastructure requires strict network segmentation:

```
┌──────────────────────────────────────────────────┐
│                    Internet                        │
└───────────────────┬──────────────────────────────┘
                    │ (DMZ / WAF / Reverse Proxy)
┌───────────────────v──────────────────────────────┐
│              Corporate Zone                       │
│  (Email, Web, Office applications)                │
└───────────────────┬──────────────────────────────┘
                    │ (Firewall: strict rules)
┌───────────────────v──────────────────────────────┐
│            Trading DMZ                            │
│  (API gateways, FIX gateways, web UIs)           │
└───────────────────┬──────────────────────────────┘
                    │ (Firewall: application-aware)
┌───────────────────v──────────────────────────────┐
│           Trading Core Zone                       │
│  (OMS, EMS, Risk Engine, Matching)                │
│  (No direct internet access)                      │
└───────────────────┬──────────────────────────────┘
                    │ (Dedicated cross-connects)
┌───────────────────v──────────────────────────────┐
│          Exchange Connectivity Zone               │
│  (Exchange gateways, market data feed handlers)   │
│  (Most restricted; only exchange traffic)         │
└──────────────────────────────────────────────────┘
```

### Encryption

| Layer | Requirement | Implementation |
|-------|-------------|----------------|
| **FIX sessions** | TLS 1.2+ for all external FIX connections | Stunnel, native TLS in FIX engine, or exchange-mandated encryption |
| **Internal messaging** | TLS or mTLS for cross-zone communication | Certificate-based mutual authentication |
| **Database connections** | TLS for all database connections | Database-native TLS configuration |
| **Data at rest** | Encrypt sensitive data (PII, credentials, trade data) | Transparent Data Encryption (TDE) for SQL Server/Oracle; LUKS for disk encryption |
| **Key management** | Centralized key management | HashiCorp Vault, AWS KMS, Azure Key Vault, Thales HSM |

### Access Controls

- **Role-Based Access Control (RBAC)**: Traders, risk managers, compliance officers, operations staff, and developers have different permissions
- **Entitlement management**: Which users can trade which instruments on which venues with which order types
- **Four-eyes principle**: Critical changes (risk limits, algo parameters, user permissions) require approval from a second authorized person
- **Privileged Access Management (PAM)**: CyberArk, Delinea (Thycotic), BeyondTrust for administrative access to production systems
- **Service accounts**: Trading applications use service accounts with minimum necessary permissions; credentials rotated regularly

### Multi-Factor Authentication

- **Production access**: MFA required for all production system access (SSH, RDP, admin consoles)
- **Trading operations**: Traders authenticate to the trading platform with MFA
- **VPN**: MFA for all remote access
- **Methods**: Hardware tokens (YubiKey, RSA SecurID), TOTP authenticator apps, push-based (Duo, Okta Verify)

### Audit Logging

Regulatory requirements (SEC Rule 17a-4, MiFID II, MAR) mandate comprehensive audit logging:

- **All order events**: Every order submission, modification, cancellation, fill, and rejection
- **All user actions**: Login, logout, configuration changes, permission changes
- **All system events**: Application startup/shutdown, failover events, connectivity changes
- **Market data**: Timestamped record of received market data (for best execution and surveillance)
- **Retention**: Typically 5-7 years depending on jurisdiction; WORM (Write Once Read Many) storage required in some jurisdictions
- **Immutability**: Audit logs must be tamper-evident; append-only storage; cryptographic hashing chains
- **Time synchronization**: NTP or PTP (Precision Time Protocol, IEEE 1588) synchronization to UTC; sub-microsecond accuracy required for MiFID II clock synchronization

---

## Configuration Management

### Instrument Configuration

Every tradeable instrument requires configuration:

| Parameter | Description |
|-----------|-------------|
| **Symbol / Ticker** | Exchange-specific and internal identifiers |
| **Instrument type** | Equity, future, option, FX, bond, etc. |
| **Exchange / Venue** | Where the instrument trades |
| **Tick size** | Minimum price increment (may vary by price level) |
| **Lot size** | Minimum order quantity; round lot size |
| **Trading hours** | Open, close, auction periods, halts |
| **Currency** | Trading and settlement currencies |
| **Margin requirements** | Initial and maintenance margin (for derivatives) |
| **Short-sell restrictions** | Locate requirements, uptick rules |
| **Price bands** | Exchange-imposed price limits |
| **Contract specifications** | Expiry, delivery, multiplier (for derivatives) |

**Reference data sources**: Exchange reference data files (downloaded daily), Bloomberg per-security data, Refinitiv instrument data, SIX Financial Information, manual overrides.

### Algo Parameters

Algorithm configuration requires versioned, auditable management:

| Parameter Type | Examples |
|----------------|----------|
| **Strategy parameters** | Participation rate, aggression level, start/end time, limit price |
| **Execution parameters** | Minimum order size, maximum order size, dark pool inclusion, venue preferences |
| **Model parameters** | Alpha signals, volatility estimates, mean-reversion thresholds |
| **Risk parameters** | Maximum position, maximum order value, maximum loss before pause |

### Risk Limits

Layered risk limit framework:

| Level | Limit Types | Enforcement |
|-------|-------------|-------------|
| **Firm level** | Maximum gross/net exposure, maximum daily loss, maximum order rate | Hard limits; system shutdown if breached |
| **Desk level** | Desk-specific exposure limits, P&L limits | Hard limits; desk disabled |
| **Trader level** | Per-trader position limits, order size limits, instrument restrictions | Pre-trade checks |
| **Strategy level** | Per-algo limits, per-instrument limits within strategy | Pre-trade checks |
| **Instrument level** | Maximum position per instrument, maximum order size | Pre-trade checks |

### User Permissions

| Dimension | Granularity |
|-----------|-------------|
| **Instruments** | Which instruments a user can trade |
| **Venues** | Which exchanges/brokers a user can route to |
| **Order types** | Market, limit, stop, algo, etc. |
| **Actions** | View, submit, modify, cancel, force-cancel |
| **Accounts** | Which accounts a user can trade in |
| **Monetary limits** | Maximum notional per order, per day |

### Environment Management

| Environment | Purpose | Data |
|-------------|---------|------|
| **Production** | Live trading | Real market data, real exchange connections |
| **UAT / Staging** | Pre-release validation | Real or replayed market data; exchange simulators or certification environments |
| **QA** | Automated testing | Synthetic data; mock exchange simulators |
| **Development** | Developer workstations | Local simulators; synthetic data |
| **DR** | Disaster recovery | Replicated production data |

**Configuration storage**: Centralized configuration service (Consul, etcd, Spring Cloud Config, custom database-backed service); version-controlled in Git; environment-specific overrides via hierarchical configuration.

---

## Deployment and Release Management

### Deployment Strategies

#### Blue-Green Deployment

Maintain two identical production environments (Blue and Green):

1. Current production runs on Blue
2. Deploy new version to Green
3. Smoke test Green with synthetic orders against exchange simulator
4. Switch traffic from Blue to Green (at a natural boundary: end of day, weekend)
5. Blue becomes the rollback target

**Trading-specific considerations**: FIX sessions must be migrated (sequence numbers, session state); positions and orders must be consistent; exchange connections must be re-established.

#### Canary Releases

Route a small percentage of traffic through the new version:

- **By instrument**: Route orders for a subset of instruments through the new version
- **By account**: Route specific test accounts through the new version
- **By strategy**: Deploy new algo version alongside old; compare execution quality

#### Feature Flags

Enable/disable features at runtime without deployment:

- **Usage**: Gradually roll out new order types, new venues, new risk checks
- **Tools**: LaunchDarkly, ConfigCat, custom feature flag service (database-backed)
- **Trading-specific**: Feature flags for new exchange connections, new algo strategies, new risk rules

### Deployment Windows

| Window | Constraints |
|--------|-------------|
| **Weekend** | Preferred for major releases; full regression testing possible; Saturday deployments common |
| **Pre-market (before open)** | Minor patches; limited testing window; must complete before pre-market sessions open |
| **Post-market (after close)** | Minor patches; more testing time than pre-market |
| **Intraday** | Emergency hotfixes ONLY; require management approval; highest risk |
| **Holiday** | Extended testing window; reduced market activity; good for major changes |

### Market-Hours Restrictions

- **Code freeze during market hours**: No deployments to production trading systems while markets are open (except emergency hotfixes with approval)
- **Configuration changes**: Limited configuration changes during market hours; pre-approved changes only
- **Infrastructure changes**: No network changes, server reboots, or middleware upgrades during market hours
- **Change Advisory Board (CAB)**: Formal approval process for all production changes; includes trading desk representation

### Release Process

1. **Development**: Feature branch; code review; unit tests; integration tests
2. **QA**: Automated regression suite; performance benchmarks; exchange simulator testing
3. **UAT**: User acceptance testing with traders and operations; replay production market data against new version
4. **Staging**: Deploy to staging environment that mirrors production; end-to-end testing with exchange certification environments
5. **Production**: Deploy during approved window; smoke test; monitor closely for 24-48 hours
6. **Rollback plan**: Every deployment has a documented rollback procedure; tested before deployment

### Versioning and Artifacts

- **Semantic versioning**: Major.Minor.Patch for platform components
- **Artifact repository**: JFrog Artifactory, Sonatype Nexus, Azure Artifacts, or NuGet feed for .NET
- **Container registry**: Docker images for containerized components; Harbor, ACR, ECR
- **Immutable artifacts**: Build once, deploy to all environments; never modify an artifact after build

---

## Scalability Patterns

### Horizontal Scaling

#### Partitioning by Instrument

The most natural partitioning strategy for trading systems:

```
                    ┌──────────────┐
                    │  Order Router │
                    └──────┬───────┘
              ┌────────────┼────────────┐
              v            v            v
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │ OMS Node │ │ OMS Node │ │ OMS Node │
        │ AAPL-GOOG│ │ MSFT-TSLA│ │ AMZN-META│
        └──────────┘ └──────────┘ └──────────┘
```

- Each node handles a subset of instruments
- Order state is local to the node (no cross-node coordination for single-instrument orders)
- Cross-instrument orders (pairs, baskets) require coordination

#### Partitioning by Exchange

Each exchange gateway and its associated order management run independently:

- Natural isolation since exchange sessions are independent
- Cross-exchange orders (SOR) require a coordination layer
- Simplifies capacity planning per venue

#### Partitioning by Desk / Strategy

Each trading desk or strategy has its own processing pipeline:

- Risk isolation between desks
- Independent deployment cycles
- Different latency requirements per desk

### Multi-Tenancy

For platform providers serving multiple clients (e.g., broker platforms, SaaS trading systems):

| Approach | Isolation | Complexity | Use Case |
|----------|-----------|------------|----------|
| **Separate instances** | Complete | High ops overhead | Largest clients; regulatory requirement |
| **Shared infrastructure, separate databases** | Strong data isolation | Moderate | Mid-tier clients |
| **Shared everything with tenant ID** | Logical isolation only | Lower ops overhead | Smaller clients; must enforce at every layer |

### Scaling Market Data

Market data is the highest-throughput component. Scaling approaches:

- **Fan-out architecture**: One feed handler per exchange feed; internal distribution via multicast or shared memory
- **Filtering/conflation**: Not all consumers need every tick; conflate (throttle) updates for slower consumers (GUIs, analytics)
- **Hierarchical distribution**: Feed handler -> regional distributors -> local caches
- **Hardware acceleration**: FPGA-based feed handlers for the highest-throughput feeds (OPRA)

---

## Cloud vs On-Premise Considerations

### The Latency Question

The fundamental tension: cloud provides operational efficiency, but introduces network latency that is unacceptable for latency-sensitive trading.

| Workload | Cloud Suitability | Reason |
|----------|-------------------|--------|
| **HFT / Market Making** | Not suitable | Requires co-location; every microsecond matters |
| **Algo execution (DMA)** | Marginal | Sub-millisecond latency requirements; proximity matters |
| **Agency algo / SOR** | Possible | Millisecond latency acceptable for some strategies |
| **Portfolio trading** | Suitable | Seconds-to-minutes timeframe; latency less critical |
| **Post-trade processing** | Well-suited | No real-time latency requirement |
| **Risk analytics** | Well-suited | Batch and near-real-time; benefits from elastic compute |
| **Back-testing / Research** | Ideal | Elastic compute; burst capacity; cost-effective |
| **Compliance / Surveillance** | Well-suited | Event-driven processing; storage-intensive |
| **Disaster recovery** | Well-suited | Cost-effective warm/cold standby |

### Cloud Adoption in Trading

Major cloud providers have financial services offerings:

#### AWS

- **AWS Outposts**: On-premise AWS infrastructure; co-located at exchange data centers
- **AWS Direct Connect**: Dedicated network connection to AWS; low-latency access
- **Amazon FinSpace**: Managed analytics for financial data
- **AWS Graviton**: ARM-based instances; cost-effective for non-latency-critical workloads
- **Exchange connectivity**: AWS has presence in Equinix NY5, LD4 (London), TY3 (Tokyo)

#### Microsoft Azure

- **Azure ExpressRoute**: Dedicated circuits to Azure; financial services peering
- **Azure Confidential Computing**: Hardware-based TEE for sensitive workloads
- **Azure for Financial Services**: Compliance frameworks, reference architectures
- **.NET optimization**: Natural fit for .NET trading platforms; Azure Functions, Azure Kubernetes Service

#### Google Cloud

- **Google Cloud Dedicated Interconnect**: Low-latency dedicated connections
- **BigQuery**: Petabyte-scale analytics for historical data
- **Anthos**: Hybrid cloud management across on-premise and cloud

### Regulatory Considerations

| Jurisdiction | Key Requirements |
|-------------|------------------|
| **US (SEC/FINRA)** | Books and records requirements; cloud outsourcing guidance; vendor risk management |
| **EU (ESMA/EBA)** | DORA (Digital Operational Resilience Act): strict ICT third-party risk management; data residency requirements |
| **UK (FCA)** | Operational resilience requirements; material outsourcing notification |
| **Singapore (MAS)** | Technology Risk Management guidelines; cloud outsourcing guidelines |
| **Australia (ASIC/APRA)** | CPS 234 (Information Security); outsourcing requirements |

**Common regulatory requirements for cloud adoption**:

- **Data residency**: Some jurisdictions require data to remain within national borders
- **Audit access**: Regulators must be able to inspect cloud infrastructure and data
- **Exit strategy**: Documented plan for migrating away from cloud provider
- **Concentration risk**: Regulators concerned about systemic risk if too many firms use the same cloud provider
- **Encryption**: Data must be encrypted in transit and at rest; key management under firm control

### Hybrid Architecture

The most common pattern for trading firms is a hybrid architecture:

```
┌──────────────────────────────────────────────────────┐
│                Co-Location (On-Premise)                │
│                                                        │
│  ┌──────────┐  ┌──────────┐  ┌───────────────────┐   │
│  │ Exchange  │  │ Market   │  │ Low-Latency       │   │
│  │ Gateways  │  │ Data Feed│  │ Order Management  │   │
│  │           │  │ Handlers │  │ & Risk            │   │
│  └──────────┘  └──────────┘  └───────────────────┘   │
│                       │                                │
│              Dedicated Link / VPN                      │
└───────────────────────┼──────────────────────────────┘
                        │
┌───────────────────────v──────────────────────────────┐
│                   Cloud                               │
│                                                        │
│  ┌──────────┐  ┌──────────┐  ┌───────────────────┐   │
│  │ Back-    │  │ Analytics │  │ Disaster          │   │
│  │ Testing  │  │ & Research│  │ Recovery          │   │
│  │ Cluster  │  │           │  │                   │   │
│  └──────────┘  └──────────┘  └───────────────────┘   │
│                                                        │
│  ┌──────────┐  ┌──────────┐  ┌───────────────────┐   │
│  │ Post-    │  │ Compliance│  │ Client            │   │
│  │ Trade    │  │ & Surveil.│  │ Portals           │   │
│  └──────────┘  └──────────┘  └───────────────────┘   │
└──────────────────────────────────────────────────────┘
```

**Key hybrid architecture decisions**:

- **Network connectivity**: Dedicated circuits (AWS Direct Connect, Azure ExpressRoute) between co-location and cloud; redundant paths
- **Data replication**: Real-time replication of order/position data from co-lo to cloud for analytics and DR
- **Security boundary**: Treat the cloud-to-colo link as an untrusted network; encrypt everything; mutual TLS
- **Latency budget**: Understand and accept the added latency for non-critical-path workloads
- **Cost model**: Co-location is CapEx-heavy (hardware, space, power); cloud is OpEx (pay-as-you-go); hybrid optimizes total cost

### Emerging Trends

- **Exchange co-located cloud**: AWS Outposts and Azure Stack deployed in exchange data centers; firms get cloud APIs with co-located latency
- **FPGA-as-a-Service**: Cloud providers offering FPGA instances (AWS F1) for trading workloads; latency not competitive with dedicated co-lo FPGA but useful for development
- **Confidential computing**: Hardware-based trusted execution environments (Intel SGX, AMD SEV) for running trading logic in cloud without trusting the provider
- **Multi-cloud**: Avoiding single-provider lock-in; distributing across AWS, Azure, and GCP; adds complexity but reduces concentration risk
- **Kubernetes for trading**: Increasingly used for non-latency-sensitive components; not yet suitable for the critical order path due to networking overhead

---

## Summary

Infrastructure and architecture for a professional trading platform must balance competing demands:

1. **Performance**: Sub-millisecond latency on the critical path; millions of messages per second throughput
2. **Reliability**: 99.99%+ availability during market hours; zero data loss; proven failover
3. **Security**: Defense in depth; comprehensive audit logging; regulatory compliance
4. **Operability**: Comprehensive monitoring; automated alerting; documented runbooks; tested DR procedures
5. **Agility**: Ability to deploy new features safely; configuration-driven behavior; feature flags
6. **Cost efficiency**: Right-size infrastructure; cloud for non-latency-sensitive workloads; avoid over-provisioning
7. **Regulatory compliance**: Meet jurisdiction-specific requirements for data residency, audit, resilience, and reporting
