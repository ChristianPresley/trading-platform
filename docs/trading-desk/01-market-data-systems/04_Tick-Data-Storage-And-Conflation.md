## Tick Data Storage and Time-Series Databases

### Tick Data Characteristics

Tick data consists of every individual market event (quote change, trade execution, order book update) with nanosecond-precision timestamps. Key characteristics that drive storage architecture:

- **Volume**: A single US equity exchange can produce 5-10 billion messages per day. Across all US equity venues, daily message counts exceed 100 billion. Options (OPRA) adds another 100+ billion. Futures and international exchanges add more.
- **Append-only**: Tick data is strictly append-only; events are never modified in place.
- **Time-ordered**: Data arrives and is queried in time order, making time the primary index.
- **Wide columns**: Each tick may have 20-50+ fields, but queries often access only a subset.
- **Compression**: Tick data compresses well due to high temporal locality (prices and sizes change incrementally).

### Storage Technologies

#### Specialized Tick Databases

| Database | Description |
|----------|-------------|
| **KDB+/q** (KX Systems) | The industry standard for tick data. Column-oriented, in-memory with memory-mapped disk storage. The q language enables extremely concise and fast analytics. Used by the majority of top-tier investment banks and hedge funds. Supports billions of rows with sub-millisecond query times on properly partitioned data. |
| **OneTick** (OneMarketData) | Purpose-built tick database with built-in analytics, event processing, and CEP (complex event processing). Strong in regulatory surveillance and compliance analytics. |
| **Codd (formerly Codd & Date)** | Specialist financial time-series databases. |

#### General-Purpose Time-Series Databases

| Database | Notes for Tick Data |
|----------|-------------------|
| **TimescaleDB** | PostgreSQL extension. Good for moderate-volume tick data. Automatic partitioning by time (hypertables). SQL interface lowers the learning curve. |
| **InfluxDB** | Purpose-built time-series DB. Good for operational metrics; less common for high-frequency tick data due to cardinality constraints in earlier versions. InfluxDB 3.0 (Apache Arrow-based) improves this. |
| **QuestDB** | Column-oriented, designed for high-throughput time-series ingestion. SQL interface. Good performance on tick data workloads. Open-source with commercial enterprise edition. |
| **ClickHouse** | Column-oriented OLAP database. Exceptional compression and query performance on time-series data. Increasingly used for tick data analytics. MergeTree engine with time-based partitioning. |
| **Apache Druid** | Real-time OLAP, good for aggregated analytics but less common for raw tick storage. |
| **DuckDB** | In-process OLAP database. Excellent for ad hoc analysis of Parquet-formatted tick data files. |

#### File-Based Storage

Many firms store historical tick data in columnar file formats:

- **Apache Parquet**: The de facto standard for analytical data storage. Column-oriented, excellent compression (Snappy, Zstd, Gzip), schema evolution support. Partitioned by date/symbol for efficient pruning.
- **Apache Arrow (Feather/IPC)**: In-memory columnar format. Zero-copy reads. Used for inter-process communication and as a compute layer over Parquet.
- **HDF5**: Hierarchical Data Format. Used in quantitative research environments. Good compression, supports chunking.
- **Flat binary files**: Some ultra-low-latency systems use custom binary formats for minimum overhead.

### Partitioning Strategies

Tick data is typically partitioned by:

- **Date**: One partition per trading day. Most common primary partition.
- **Symbol/instrument**: Within each date, data may be further partitioned or sorted by symbol.
- **Venue**: For multi-venue data, partitioning by venue can improve query locality.

In KDB+, the standard approach is a **partitioned database** with date-partitioned tables stored on disk and recent data (today) held in an **RDB (Real-time Database)** in memory. A **tickerplant** process receives data from feed handlers and writes it to the RDB and to a transaction log.

### Bar Aggregation

Tick data is aggregated into bars (candles) for charting and analysis:

#### OHLCV Bars

| Field | Description |
|-------|-------------|
| **Open** | First trade price in the bar interval |
| **High** | Highest trade price in the bar interval |
| **Low** | Lowest trade price in the bar interval |
| **Close** | Last trade price in the bar interval |
| **Volume** | Total shares/contracts traded in the bar interval |

Common bar intervals: 1-second, 5-second, 1-minute, 5-minute, 15-minute, 30-minute, 1-hour, daily.

#### Alternative Bar Types

- **Volume bars**: A new bar is formed after a fixed number of shares/contracts trade.
- **Dollar bars**: A new bar is formed after a fixed notional amount trades.
- **Tick bars**: A new bar is formed after a fixed number of trades.
- **Renko bars**: Fixed price movement bars, ignoring time.
- **Range bars**: A new bar forms when price moves a fixed range.

These alternative bar types are popular in quantitative research because they normalize for variations in trading activity across time.

### VWAP Calculations

Volume-Weighted Average Price is one of the most important derived metrics:

```
VWAP = Sum(Price_i * Volume_i) / Sum(Volume_i)
```

Implementations must handle:

- **Trade condition filtering**: Exclude off-exchange prints, odd lots (historically), and other non-regular trades depending on the use case.
- **Continuous vs interval**: Running VWAP (cumulative from session open) vs interval VWAP (e.g., 5-minute windows).
- **Anchored VWAP**: VWAP calculated from an arbitrary user-specified start point.
- **Regulatory VWAP**: SEC Rule 10b-18 safe harbor calculations for share repurchase programs use specific VWAP definitions.

---

## Market Data Conflation and Throttling

### The Conflation Problem

Market data producers generate far more updates than most consumers can process or need. A single actively traded instrument may generate thousands of quote updates per second, but a trading UI refreshing at 30fps only needs ~30 updates per second per instrument. Algo engines may need every tick, but risk systems may only need snapshots every second.

### Conflation Strategies

#### Last-Value Conflation

The most common approach: within each conflation interval, only the most recent value for each field is retained. When the interval expires, a snapshot of current values is published. This ensures consumers always see the latest state, even if intermediate updates were dropped.

- **Interval-based**: Conflate over fixed time windows (e.g., 100ms, 250ms, 500ms, 1s).
- **Rate-based**: Limit to N updates per second per instrument.
- **Change-based**: Only publish when a field has actually changed.

#### Image/Snapshot vs Streaming

- **Snapshot (image)**: A complete representation of the current state of an instrument. Used for initial synchronization, recovery after gaps, and low-update-frequency consumers.
- **Streaming (incremental)**: Only changed fields are sent. More bandwidth-efficient for active instruments, but requires the consumer to maintain state and handle recovery.
- **Stale detection**: Consumers must detect when data is stale (no updates received within an expected interval). Stale data is a significant operational risk.

#### Conflation at Different Layers

| Layer | Conflation Approach |
|-------|-------------------|
| **Feed handler** | Typically no conflation; all ticks are captured for the tick database. May conflate for specific downstream consumers. |
| **Ticker plant / distribution** | Configurable conflation per consumer class. Low-latency consumers get every tick; display consumers get conflated data. |
| **Middleware (pub/sub)** | Middleware systems like Solace, TIBCO Rendezvous, Informatica Ultra Messaging, and 29West can perform conflation natively. |
| **Client library** | The client-side API may conflate updates before invoking application callbacks. |
| **UI framework** | The UI rendering loop naturally conflates because it only displays the current state at each frame refresh. |

### Bandwidth Management

- **Subscription management**: Only subscribe to instruments the application needs. Unsubscribe when no longer needed. This is the most effective bandwidth control.
- **Field filtering**: Request only the fields needed (e.g., a display only needs bid/ask/last, not full depth).
- **Topic-based filtering**: Market data middleware allows subscription by topic hierarchy (e.g., `/marketdata/equity/US/AAPL/L1`), and the infrastructure filters at the source.
- **Multicast group selection**: Only join the multicast groups containing instruments of interest.
- **Compression**: For WAN distribution, apply compression (LZ4, Zstd) to market data streams. Some middleware systems support this natively.
