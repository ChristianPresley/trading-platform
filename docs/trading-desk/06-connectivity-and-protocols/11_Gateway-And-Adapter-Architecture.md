## Gateway and Adapter Architecture

### Architectural Pattern

A professional trading platform uses a **gateway/adapter layer** to abstract exchange-specific protocols behind a uniform internal API:

```
                 ┌─────────────────────────────────────┐
                 │         Internal Trading Core        │
                 │   (Uniform order model, events,      │
                 │    normalized market data)            │
                 └──────────────┬───────────────────────┘
                                │
              Internal Protocol (Aeron/ZeroMQ/gRPC)
                                │
         ┌──────────┬───────────┼───────────┬──────────┐
         │          │           │           │          │
    ┌────v────┐ ┌───v───┐ ┌────v────┐ ┌────v────┐ ┌──v──┐
    │ NYSE    │ │Nasdaq │ │  CME    │ │ Broker  │ │ FIX │
    │ Gateway │ │Gateway│ │ Gateway │ │Adapter A│ │ GW  │
    └────┬────┘ └───┬───┘ └────┬────┘ └────┬────┘ └──┬──┘
         │          │           │           │          │
    NYSE Pillar  OUCH/ITCH  iLink3/MDP  Broker FIX  Generic
    Binary        Binary      SBE         4.2/4.4    FIX
```

### Gateway Responsibilities

1. **Protocol translation**: Convert internal order model to exchange-specific wire format and vice versa
2. **Session management**: Maintain FIX sessions, binary connections, heartbeats, sequence numbers
3. **Symbol mapping**: Translate internal instrument identifiers to exchange-specific symbology
4. **Order ID mapping**: Maintain correlation between internal ClOrdID and exchange OrderID
5. **Rate limiting**: Enforce exchange-mandated message rate limits (e.g., CME iLink: 500 msgs/sec per session)
6. **Throttling and queuing**: Buffer orders during transient connectivity issues
7. **Failover**: Detect gateway failure and route to backup session/gateway
8. **Normalization**: Convert exchange-specific execution reports, rejects, and market data into a uniform internal format
9. **Logging**: Capture every inbound and outbound message with nanosecond timestamps for audit and replay
10. **Enrichment**: Add routing metadata, regulatory tags (LEI, short-sell flags, etc.)

### Exchange Gateway Patterns

#### Direct Market Access (DMA) Gateways

- Connect directly to exchange matching engine
- Minimal latency overhead
- Must comply with exchange certification and testing requirements
- Each exchange has a certification program (e.g., CME iLink Certification, NYSE Pillar Certification)
- Typically deployed in co-location

#### Sponsored/Facilitated Access

- Broker provides access credentials; firm connects through broker's exchange membership
- Pre-trade risk checks may be applied by the broker (per SEC Rule 15c3-5 / Market Access Rule)
- Naked (unfiltered) sponsored access is prohibited in most jurisdictions

### Broker Adapters

Broker adapters handle connectivity to execution brokers for:

- **Algo routing**: Send orders to broker algorithms (VWAP, TWAP, Implementation Shortfall, etc.) via FIX with strategy-specific tags (TargetStrategy 847, StrategyParametersGrp)
- **SOR (Smart Order Routing)**: Leverage broker SOR for best execution across venues
- **Care orders**: Send orders for manual handling by broker sales traders
- **Indications of Interest (IOIs)**: Receive and parse IOI messages (MsgType=6)

### Protocol Translation Considerations

| Aspect | Challenge | Solution |
|--------|-----------|----------|
| **Field mapping** | Different exchanges use different tags/fields for the same concept | Mapping tables per exchange; automated regression testing |
| **Order types** | Exchange-specific order types (e.g., Cboe Midpoint Peg, NYSE ALO) | Internal model supports superset; gateway maps to exchange-specific representation |
| **State machines** | Different exchanges have subtly different order state transitions | Per-exchange state machine configuration; comprehensive unit tests |
| **Timestamps** | UTC vs. exchange local time; different precision (ms, us, ns) | Normalize to UTC nanoseconds internally |
| **Decimal handling** | Different precision and formats across exchanges | Use fixed-point decimal internally; convert at gateway boundary |
| **Reject reasons** | Each exchange has proprietary reject codes | Mapping tables; normalized internal reject taxonomy |
| **Market data schemas** | Different book representations (price-level vs. order-level) | Normalize to internal book model at feed handler |

### Feed Handler Architecture

Market data feed handlers are specialized gateways for inbound data:

```
Exchange Multicast (Line A + Line B)
         |              |
    ┌────v────┐    ┌────v────┐
    │  NIC A  │    │  NIC B  │
    │(kernel  │    │(kernel  │
    │ bypass) │    │ bypass) │
    └────┬────┘    └────┬────┘
         │              │
    ┌────v──────────────v────┐
    │    Line Arbitrator     │
    │ (deduplicate A/B feed, │
    │  take first-arriving)  │
    └───────────┬────────────┘
                │
    ┌───────────v────────────┐
    │     Protocol Decoder   │
    │  (ITCH/SBE/FAST/PITCH) │
    └───────────┬────────────┘
                │
    ┌───────────v────────────┐
    │  Book Builder / Cache  │
    │ (reconstructs full     │
    │  order book from       │
    │  incremental updates)  │
    └───────────┬────────────┘
                │
    ┌───────────v────────────┐
    │  Internal Distribution │
    │  (Aeron/Solace/shared  │
    │   memory / mmap)       │
    └────────────────────────┘
```

**Performance targets for feed handlers**:

- Wire-to-internal latency: < 5 microseconds (co-located)
- Message processing rate: > 10 million messages per second per feed
- Book update and publish: < 1 microsecond (in-memory)
- Zero garbage collection pauses (Java systems use off-heap or C/C++)

### Multi-Venue Connectivity Management

Large trading desks maintain connectivity to dozens of venues simultaneously:

- **Connectivity matrix**: Track session status for every venue, every session
- **Health dashboards**: Real-time status of all gateways, sessions, and feeds
- **Automated failover**: If primary gateway fails, route to backup within milliseconds
- **Circuit breakers**: Automatically disable a gateway if error rates exceed threshold
- **Configuration management**: Centralized configuration for all gateway parameters; version-controlled; environment-specific overrides
- **Certification environments**: Each exchange provides a UAT/certification environment for testing; firms must re-certify after protocol upgrades
