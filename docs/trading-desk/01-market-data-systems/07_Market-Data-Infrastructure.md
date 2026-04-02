## Market Data Infrastructure

### Feed Handlers

Feed handlers are the first point of contact between exchange data and the firm's internal systems. They are specialized software (and sometimes hardware) components that:

1. **Connect** to exchange multicast feeds or TCP sessions.
2. **Receive** raw exchange messages.
3. **Decode** protocol-specific encoding (ITCH, SBE, FAST, etc.).
4. **Normalize** into a canonical internal format.
5. **Sequence** and detect gaps.
6. **Recover** missing messages (via TCP retransmission or snapshot).
7. **Publish** normalized data to the internal distribution layer.
8. **Timestamp** with high-precision receipt times (ideally hardware-timestamped at the NIC).

#### Feed Handler Architecture Patterns

- **Software feed handlers**: Run on commodity x86 servers with kernel-bypass networking. Examples: custom-built in C/C++, vendor solutions from Exegy, MayStreet, Vela (now part of Trading Technologies), SR Labs.
- **FPGA feed handlers**: Use FPGAs (Field-Programmable Gate Arrays) to decode market data in hardware, achieving sub-microsecond decode latency. Used by HFT firms and major banks for latency-sensitive feeds. Vendors: Exegy (nxFramework), Xilinx/AMD Alveo, Cisco Nexus, custom builds.
- **Tick-to-trade appliances**: Integrated hardware that combines feed handling, strategy logic, and order generation on a single FPGA or ASIC. Used by ultra-low-latency prop trading firms.

#### Feed Handler Operational Concerns

- **Redundancy**: Dual feed handlers per exchange feed (primary/secondary), processing both A and B lines.
- **Failover**: Automatic failover if the primary handler fails or falls behind.
- **Monitoring**: Real-time monitoring of message rates, gap counts, latency metrics (exchange timestamp to internal publish timestamp), and handler health.
- **Capacity planning**: Feed handlers must be sized for peak message rates, which can be 5-10x average during volatile markets. The "flash crash" of May 6, 2010, and various subsequent volatility events have demonstrated that peak rates can exceed all historical precedents.

### Ticker Plants

A ticker plant is the central hub of market data distribution within a firm. It receives normalized data from all feed handlers and distributes it to consuming applications.

#### Core Functions

- **Conflation engine**: Apply per-consumer conflation policies.
- **Entitlement enforcement**: Filter data based on user/application permissions.
- **Caching**: Maintain the latest image (snapshot) of every instrument for new subscribers and recovery.
- **Subscription management**: Track which consumers are subscribed to which instruments.
- **Derived data calculation**: Compute VWAP, spread midpoint, composite NBBO, and other derived fields.
- **Fan-out**: Efficiently distribute data to hundreds or thousands of consumers.

#### Ticker Plant Technologies

| Technology | Description |
|-----------|-------------|
| **Solace PubSub+** | Hardware-accelerated message broker with native market data features (topic-based routing, content filtering, conflation). Used by major banks and exchanges. |
| **TIBCO Rendezvous (RV)** | Legacy but still widely deployed reliable multicast middleware. TIBCO EMS for guaranteed messaging. |
| **Informatica Ultra Messaging (29West)** | Ultra-low-latency messaging with multicast, unicast, and persistence options. Known for minimal latency overhead. |
| **Aeron** | Open-source high-performance messaging library. IPC and UDP unicast/multicast. Used by several HFT firms and exchanges. Aeron Cluster for fault-tolerant replicated state machines. |
| **Chronicle Queue** | Java-based, memory-mapped file inter-process communication. Microsecond latencies. Popular in Java-based trading systems. |
| **ZeroMQ** | Open-source messaging library. Lightweight, good for internal distribution. Lacks built-in market data features (conflation, entitlements). |
| **Kafka** | Not suitable for real-time tick distribution (latency too high for trading), but commonly used for event sourcing, analytics pipelines, and non-latency-sensitive distribution. |
| **Custom shared memory** | Some firms build custom IPC using shared memory (mmap, huge pages) for lowest possible latency between co-located processes. |

### Pub/Sub Architecture

The publish-subscribe pattern is the dominant architecture for market data distribution:

```
 [Exchange Feeds]
       |
       v
 [Feed Handlers] -- normalize, decode, timestamp
       |
       v
 [Ticker Plant / Message Bus] -- conflate, entitle, cache, fan-out
       |
       +---> [Trading UI]          (conflated L1, L2 depth)
       +---> [Algo Engine]         (full-tick, zero conflation)
       +---> [Risk Engine]         (snapshot every N seconds)
       +---> [Tick Database]       (full-tick, persistent storage)
       +---> [Compliance Monitor]  (full-tick, surveillance)
       +---> [Market Making Engine](full-tick + full depth)
       +---> [Analytics Platform]  (conflated or batch)
```

#### Topic Hierarchies

Market data is typically organized into topic hierarchies that enable efficient subscription:

```
/md/{asset_class}/{region}/{exchange}/{symbol}/{data_level}

Examples:
/md/equity/us/xnys/AAPL/l1
/md/equity/us/xnys/AAPL/l2
/md/equity/us/xnas/AAPL/trades
/md/futures/us/xcme/ES/l1
/md/futures/us/xcme/ES/depth
/md/options/us/opra/AAPL/chains
/md/fx/global/spot/EURUSD/l1
```

Wildcard subscriptions (e.g., `/md/equity/us/xnys/*/l1` for all NYSE L1) are supported by most middleware but must be used carefully to avoid subscribing to excessive data.

### Network Architecture

A typical market data network topology:

- **Exchange co-location segment**: Feed handlers in the exchange data center, connected via cross-connects to exchange matching engines. 1-10 microsecond latency.
- **Metro area network**: Fiber or microwave links between co-location sites and the firm's primary data center. E.g., Carteret (NASDAQ) to Secaucus (firm DC): ~0.2ms fiber; Aurora (CME) to Chicago (firm DC): <0.1ms.
- **Primary data center**: Ticker plant, trading engines, risk systems. Connected to co-lo via dedicated circuits.
- **Secondary data center**: DR (disaster recovery) site with replicated feed handlers and ticker plant. Active-active or active-passive.
- **WAN distribution**: For regional offices, data is typically compressed and distributed over WAN links. Latency less critical for display users.
- **Cloud**: Increasingly, non-latency-sensitive workloads (analytics, backtesting, alternative data) run in cloud environments. Some exchanges (CME, Cboe, NYSE) offer data feeds directly in public clouds (AWS, GCP, Azure) via co-location adjacency or cloud gateway services.

### Latency Measurement

Market data latency is measured at multiple points:

| Measurement Point | Description |
|------------------|-------------|
| **Exchange match to feed publish** | Time from order match at the exchange to the exchange publishing the resulting message. Exchange-internal; not controllable by subscribers. |
| **Wire latency** | Propagation delay from exchange NIC to subscriber NIC. Depends on distance and medium (fiber ~4.9 us/km, microwave ~3.3 us/km). |
| **NIC to application** | Time from packet arrival at the NIC to delivery to the application. Kernel path: ~5-15us. Kernel bypass: ~1-3us. FPGA: <1us. |
| **Decode latency** | Time to decode the exchange-specific protocol into the internal format. Software: 1-10us. FPGA: <1us. |
| **Distribution latency** | Time from internal publish to delivery at the consuming application. Depends on middleware. Low-latency pub/sub: 1-10us. |
| **End-to-end (tick-to-trade)** | Total time from exchange publishing a market data event to the firm generating and transmitting a resulting order. Competitive HFT targets: <10us total. Typical professional desk: 100us-10ms. |

Hardware timestamping (PTP/IEEE 1588, NIC hardware timestamps) is essential for accurate latency measurement. Software timestamps introduce jitter and are unreliable for microsecond-level measurements.
