## Message Queuing and Middleware

Trading platforms use messaging middleware to decouple components, distribute market data, and ensure reliable message delivery.

### Messaging Platforms

#### Solace PubSub+ (formerly Solace Systems)

- **Type**: Hardware-accelerated or software message broker
- **Protocol support**: AMQP, MQTT, JMS, REST, native Solace API
- **Strengths**: Sub-100-microsecond latency in appliance mode; guaranteed delivery; content-based routing; native WAN optimization
- **Usage**: Extremely prevalent on sell-side trading desks; many tier-1 banks use Solace as their primary messaging backbone
- **Deployment**: Hardware appliance, software broker, or SaaS (Solace Cloud)
- **Capacity**: Millions of messages per second; thousands of concurrent clients

#### TIBCO Rendezvous (RV) and EMS

- **TIBCO RV**: Multicast-based publish/subscribe; historically the dominant middleware in trading for market data distribution. Certified Message Delivery (RVCM) adds reliability. Still widely deployed but declining in new installations.
- **TIBCO EMS**: JMS-compliant message broker; used for order flow and guaranteed delivery
- **TIBCO FTL**: Next-generation low-latency messaging; designed as RV successor
- **Strengths**: Subject-based addressing; multicast efficiency; vast installed base
- **Weaknesses**: Legacy licensing model; RV lacks persistence by default

#### Apache Kafka

- **Type**: Distributed event streaming platform
- **Strengths**: Extremely high throughput; durable log-based storage; replay capability; event sourcing natural fit; massive ecosystem
- **Usage in trading**: Trade capture, audit logging, event sourcing, analytics pipelines, post-trade processing. Generally NOT used for low-latency order routing due to latency characteristics (milliseconds, not microseconds).
- **Deployment**: Self-managed or Confluent Cloud
- **Typical trading use cases**:
  - Trade event bus (execution reports, fills)
  - Market data normalization pipeline
  - Risk calculation input stream
  - Compliance and surveillance data
  - Audit trail and regulatory reporting

#### ZeroMQ (0MQ)

- **Type**: Embeddable messaging library (not a broker)
- **Patterns**: PUB/SUB, REQ/REP, PUSH/PULL, DEALER/ROUTER
- **Strengths**: Brokerless; microsecond latency; simple API; polyglot (C, C++, Java, .NET, Python)
- **Usage**: Intra-process and inter-process communication in trading systems; market data fan-out within a single server
- **Weaknesses**: No built-in persistence; no centralized management

#### Aeron

- **Type**: Ultra-low-latency, reliable UDP-based messaging library
- **Design**: Developed by Real Logic (Martin Thompson); designed for financial systems
- **Strengths**: Single-digit microsecond latency; reliable multicast; back-pressure support; archive for replay; cluster for fault tolerance
- **Transport**: UDP unicast, UDP multicast, IPC (shared memory), or Aeron Cluster for replication
- **Usage**: Internal messaging for HFT systems; cluster consensus; market data transport
- **Aeron Cluster**: Raft-based consensus for replicated state machines (used for matching engines, risk engines)
- **Language**: Java and C; .NET wrapper available

#### Other Middleware

| Product | Vendor | Notes |
|---------|--------|-------|
| **IBM MQ** | IBM | Enterprise JMS broker; used in back-office and settlement |
| **RabbitMQ** | VMware | AMQP broker; used for less latency-sensitive workflows |
| **Chronicle Queue** | Chronicle Software | Off-heap, memory-mapped Java queue; microsecond latency; used in HFT |
| **LMAX Disruptor** | LMAX Exchange | Lock-free ring buffer; inter-thread messaging; foundational pattern in low-latency Java systems |
| **Oracle Coherence** | Oracle | In-memory data grid with messaging capabilities |

### Messaging Patterns in Trading

#### Publish/Subscribe (Pub/Sub)

The dominant pattern for market data distribution:

```
Market Data Feed Handler
        |
   [Message Bus / Topic]
        |
   ┌────┼────┬────────┐
   v    v    v        v
 Algo  Risk  GUI   Compliance
Engine Engine      Surveillance
```

- **Topic hierarchies**: `MD.EQUITY.US.NASDAQ.AAPL` allows wildcard subscriptions (`MD.EQUITY.US.>`)
- **Content-based routing**: Subscribe to messages matching a predicate (e.g., price > threshold)
- **Fan-out**: One publisher, many subscribers; each gets an independent copy

#### Guaranteed Delivery

For order flow, allocation, and settlement messages where message loss is unacceptable:

- **Persistent messaging**: Messages stored to disk before acknowledgment
- **Transacted sessions**: Multiple messages committed atomically
- **Dead letter queues**: Failed messages routed for investigation
- **Exactly-once delivery**: Kafka transactions or idempotent consumers

#### Request/Reply

For synchronous operations (instrument lookups, risk checks):

- Correlation ID links response to request
- Timeout handling is critical in trading (fail-fast)
