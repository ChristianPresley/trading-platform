## Market Data Protocols

While FIX can carry market data, high-throughput exchanges use specialized binary protocols optimized for bandwidth and parsing speed.

### FAST Protocol (FIX Adapted for Streaming)

- **Purpose**: Binary encoding of FIX market data for multicast distribution
- **Encoding**: Uses Presence Map (PMAP) bitmap and stop-bit encoding to compress field data. Optional fields omitted entirely; delta encoding for incremental updates.
- **Throughput**: Can reduce FIX message sizes by 50-70%
- **Usage**: CME Group (MDP 3.0 uses SBE now, but legacy systems still use FAST), MOEX, various Asian exchanges
- **Decoding complexity**: Requires template-driven decoder; templates describe field layout per message type

### SBE (Simple Binary Encoding)

- **Purpose**: Successor to FAST; fixed-layout binary encoding for deterministic, zero-copy parsing
- **Design principles**: Fixed-size fields in fixed positions; no field-level compression; schema-driven
- **Advantages over FAST**: Constant-time field access (no sequential decoding); simpler implementation; better cache behavior
- **Usage**: CME MDP 3.0, Eurex T7, MEMX, various next-generation exchange feeds
- **Specification**: FIX Trading Community standard; XML schema describes message layouts

### ITCH Protocol

- **Origin**: Nasdaq
- **Design**: Simple binary protocol; each message type has a fixed-length header with a message-type byte followed by type-specific fixed-layout fields
- **Variants**:
  - **Nasdaq ITCH 5.0**: Full depth-of-book feed for Nasdaq equities
  - **Nasdaq Nordic ITCH**: Nordic exchange variant
  - **LSE Millennium ITCH**: London Stock Exchange variant (part of Millennium Exchange)
- **Transport**: Typically UDP multicast with TCP retransmission (MoldUDP64 or SoupBinTCP for recovery)
- **Message types**: AddOrder, OrderExecuted, OrderCanceled, OrderReplaced, Trade (Non-Cross), SystemEvent, StockDirectory
- **Characteristics**: Extremely compact; designed for full order book reconstruction; no request/response--purely one-directional

### OUCH Protocol

- **Origin**: Nasdaq
- **Purpose**: Order entry protocol (complementary to ITCH for market data)
- **Design**: Simple binary, low-overhead order entry with minimal message types
- **Transport**: TCP (via SoupBinTCP framing)
- **Usage**: Nasdaq, Chi-X (now Cboe), various dark pools
- **Message types**: EnterOrder, ReplaceOrder, CancelOrder, Accepted, Replaced, Canceled, Executed

### PITCH Protocol

- **Origin**: BATS Global Markets (now Cboe)
- **Purpose**: Market data and order entry
- **Design**: Fixed-length binary messages; extremely efficient
- **Usage**: Cboe US Equities, Cboe Europe, Cboe FX
- **Variant**: BOE (Cboe Binary Order Entry) for order routing

### Proprietary Exchange Protocols

| Exchange | Protocol | Notes |
|----------|----------|-------|
| CME Group | **iLink 3** (order entry), **MDP 3.0** (market data) | iLink uses FIXP session layer with SBE encoding; MDP uses SBE over multicast |
| NYSE/ICE | **Pillar** gateway, **XDP** (market data) | Pillar uses binary gateway; XDP is multicast depth-of-book feed |
| Eurex/Xetra | **T7 ETI** (order entry), **T7 EMDI/MDI** (market data) | ETI is binary; EMDI is enhanced market data interface |
| LSE | **MIT** (Millennium Exchange) | Native binary order entry; ITCH for market data |
| SGX | **OAPI/Titan** | OMnet-based API; migrating to newer platforms |
| HKEX | **OCG-C** (Orion Central Gateway) | Binary protocol for securities and derivatives |
| JPX (Tokyo) | **arrowhead** | J-Gate for derivatives; proprietary binary |
| ASX | **OUCH/ITCH** variant | Nasdaq-technology based |
| Cboe Europe | **BOE** + **PITCH** | Binary order entry and market data |

### Multicast Market Data Architecture

High-throughput exchanges distribute market data via **UDP multicast**:

```
Exchange Matching Engine
        |
   [Multicast Publisher]
        |
   ─────┼───── Multicast Group (e.g., 224.0.50.1:12345)
   |    |    |
 Firm A Firm B Firm C
```

**Recovery mechanisms**:

- **MoldUDP64** (Nasdaq): Sequence-numbered UDP packets; gaps detected by sequence; TCP retransmission channel for recovery
- **Packet Replay** (CME): Dedicated UDP channel replaying recent packets on a loop
- **Snapshot** channels: Periodic full state snapshots to allow late joiners to reconstruct the book without replaying the full day
- **Line arbitration**: Exchanges publish identical data on two or more redundant multicast lines (A/B feeds); receivers compare and take the first-arriving packet

### Consolidated and Proprietary Feeds

| Feed Type | Examples | Characteristics |
|-----------|----------|-----------------|
| **SIP** (Securities Information Processor) | CTA/CQS (NYSE-listed), UTP (Nasdaq-listed) | Consolidated US NBBO; regulatory mandate; higher latency |
| **Direct feeds** | Nasdaq TotalView, NYSE ArcaBook, Cboe PITCH | Per-exchange depth-of-book; lower latency; higher cost |
| **Aggregated** | Bloomberg B-PIPE, Refinitiv Elektron | Normalized multi-exchange data; managed infrastructure |
