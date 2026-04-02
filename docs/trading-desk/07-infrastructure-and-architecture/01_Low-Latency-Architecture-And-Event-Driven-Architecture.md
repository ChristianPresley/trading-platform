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
