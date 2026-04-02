## Data Normalization and Symbology

### The Symbology Problem

Every exchange, vendor, and data provider has its own way of identifying financial instruments. A single security may be known by dozens of different identifiers across the ecosystem. A robust symbology layer is critical for any market data system.

### Identifier Types

#### Exchange-Native Symbols

Each exchange defines its own symbol namespace:

- **NYSE/NASDAQ**: Ticker symbols (e.g., `AAPL`, `BRK.B`, `BF/B`). Special suffixes denote share classes, warrants, units, rights.
- **CME**: Globex symbol + contract month code (e.g., `ESM5` for E-mini S&P 500 June 2025). Root symbol + month letter (F=Jan, G=Feb, H=Mar, J=Apr, K=May, M=Jun, N=Jul, Q=Aug, U=Sep, V=Oct, X=Nov, Z=Dec) + year digit.
- **ICE**: Exchange-specific product codes and contract identifiers.
- **Eurex**: Product ID + expiry (e.g., `ODAX JUN25` for DAX options June 2025).

#### Industry Standard Identifiers

| Identifier | Issuer | Format | Coverage |
|-----------|--------|--------|----------|
| **ISIN** (International Securities Identification Number) | National Numbering Agencies coordinated by ANNA | 2-letter country code + 9 alphanumeric + 1 check digit (e.g., `US0378331005` for Apple) | Global securities; does not distinguish between listings on different exchanges |
| **CUSIP** (Committee on Uniform Securities Identification Procedures) | CUSIP Global Services (S&P/FactSet JV) | 9 characters: 6 issuer + 2 issue + 1 check (e.g., `037833100` for Apple) | North American securities |
| **SEDOL** (Stock Exchange Daily Official List) | London Stock Exchange | 7 characters alphanumeric (e.g., `2046251` for Apple on NASDAQ) | UK and international securities |
| **FIGI** (Financial Instrument Global Identifier) | Bloomberg (open standard via OMG/Object Management Group) | 12 characters (e.g., `BBG000B9XRY4` for Apple). Composite FIGI vs share-class FIGI vs exchange-level FIGI | Global; freely available via OpenFIGI API. Three tiers: composite (market-wide), share class, and exchange-level |
| **Ticker** | Exchanges | Variable format | Exchange-specific, not globally unique |
| **CIK** (Central Index Key) | SEC | Numeric | US SEC filings |
| **LEI** (Legal Entity Identifier) | GLEIF | 20 characters | Legal entities (issuers, counterparties), not individual securities |
| **MIC** (Market Identifier Code) | ISO 10383 | 4 characters (e.g., `XNYS` for NYSE, `XNAS` for NASDAQ) | Identifies trading venues |

#### Vendor-Specific Identifiers

| Vendor | Identifier Format | Example |
|--------|------------------|---------|
| **Bloomberg** | Ticker + market + asset class yellow key (e.g., `AAPL US Equity`, `ESA Index`, `EUR Curncy`) | `AAPL US Equity` |
| **Refinitiv** | RIC (Reuters Instrument Code) with exchange suffix (e.g., `AAPL.O` for NASDAQ, `AAPL.N` for hypothetical NYSE, `ESc1` for front-month E-mini) | `AAPL.O` |
| **FactSet** | FactSet permanent ID (e.g., `000C7F-E` for Apple) | `000C7F-E` |
| **S&P Capital IQ** | GVKEY + IID | `001690-01` |

### Symbology Services and Mapping

A professional trading desk requires a symbology master that can cross-reference between all identifier types. Key components:

- **Symbology mapping tables**: Maintained either in-house or via a vendor service. Must handle corporate actions (ticker changes, mergers, spin-offs, share class conversions) that alter identifier relationships.
- **OpenFIGI API**: Bloomberg's free API for mapping between FIGI and other identifiers. Useful as a starting point but not comprehensive for all asset classes.
- **ANNA DSB (Derivatives Service Bureau)**: Issues ISINs for OTC derivatives under MiFID II/MiFIR reporting obligations.
- **Refinitiv PermID**: LSEG's open, permanent identifier system.
- **SmartStream RDU (Reference Data Utility)**: Cross-referencing service across identifier types.

### Data Normalization

Beyond symbology, normalization encompasses:

- **Price scaling**: Some exchanges transmit prices as integers with an implicit decimal (e.g., price in hundredths of a cent). The feed handler must apply the correct scale factor per instrument.
- **Quantity normalization**: Lot sizes vary by venue and instrument. Some feeds report in round lots, others in shares.
- **Currency normalization**: Multi-listed securities may trade in different currencies across venues.
- **Timestamp normalization**: Converting exchange timestamps (which may be in local time, UTC, or nanoseconds since midnight) to a uniform format, typically UTC nanoseconds since epoch.
- **Trade condition mapping**: Each exchange has its own set of condition codes (e.g., regular sale, block trade, bunched, average price, intermarket sweep). These must be mapped to a canonical set for downstream consumers.
- **Venue identification**: Mapping exchange-specific venue codes to ISO 10383 MIC codes.

---

## Market Data Protocols

### FIX Protocol and FAST Encoding

#### FIX (Financial Information eXchange)

FIX is the most widely used application-layer protocol in financial markets. Originally designed for order routing, FIX has been extended with a market data domain (FIX messages 35=W MarketDataSnapshotFullRefresh, 35=X MarketDataIncrementalRefresh, 35=V MarketDataRequest).

- **FIX versions**: 4.2, 4.4, 5.0, 5.0SP2 are the most common. FIXT 1.1 separates transport from application layer.
- **Encoding**: Tag-value pairs in ASCII by default (e.g., `35=W|55=AAPL|268=2|...`). Human-readable but bandwidth-inefficient.
- **FIX/FAST**: FAST (FIX Adapted for STreaming) is a binary encoding that compresses FIX messages using techniques like stop-bit encoding, presence maps, and delta encoding. Reduces bandwidth by 50-90% compared to plain FIX. Widely used by exchanges for multicast market data dissemination.
- **SBE (Simple Binary Encoding)**: A newer FIX encoding scheme that is faster to parse than FAST (no complex state machines needed for decoding). CME Group's MDP 3.0 uses SBE. It is a fixed-layout binary format defined by XML message schemas.
- **FIX Orchestra**: Machine-readable specification of FIX message structures and workflows, enabling automated code generation.

#### FAST Encoding Details

FAST uses several compression techniques:

- **Presence map**: A bitmap indicating which fields are present in a message (absent fields use default or previous values).
- **Stop-bit encoding**: Variable-length integer encoding where the high bit of each byte indicates whether more bytes follow.
- **Delta encoding**: Fields are encoded as deltas from their previous value, exploiting temporal locality in market data.
- **Copy operator**: A field copies its value from the previous message if not explicitly present.
- **Increment operator**: A field is incremented from its previous value.
- **Template-based**: Messages conform to predefined templates, reducing the need to transmit field tags.

### Exchange-Specific Binary Protocols

#### ITCH

ITCH is a family of binary market data protocols used by Nasdaq and other exchanges worldwide. Key characteristics:

- **Unidirectional**: ITCH is output-only; there is no request/response. The full order book must be reconstructed from a stream of add/modify/delete/execute messages.
- **Message types** (NASDAQ TotalView-ITCH 5.0):
  - `A` - Add Order (no attribution)
  - `F` - Add Order with MPID (attributed)
  - `E` - Order Executed
  - `C` - Order Executed with Price
  - `X` - Order Cancel
  - `D` - Order Delete
  - `U` - Order Replace
  - `P` - Trade (non-cross)
  - `Q` - Cross Trade
  - `S` - System Event
  - `R` - Stock Directory
  - `H` - Stock Trading Action (halts/resumes)
  - `I` - Net Order Imbalance Indicator (NOII)
  - `L` - LULD Auction Collar
- **Encoding**: Fixed-length binary messages. Fields are big-endian integers and ASCII strings. Very fast to parse.
- **Throughput**: NASDAQ TotalView-ITCH can produce over 100,000 messages per second during peak activity, with bursts significantly higher.

Exchanges using ITCH or ITCH-derived protocols: NASDAQ (US, Nordic, Baltic), ASX, SGX, LSE (Millennium ITCH), Aquis, TMX.

#### OUCH

OUCH is the corresponding order-entry protocol paired with ITCH. It is a simple binary protocol for submitting, modifying, and canceling orders. While ITCH is for market data output, OUCH is for order input. Both share a similar design philosophy of simplicity and low-latency parsing.

#### PITCH (Cboe)

Cboe uses the PITCH protocol for its market data feeds:

- Binary encoding, similar philosophy to ITCH.
- Message types for add order, order executed, order canceled, trade, trading status.
- Used across Cboe US equities (BZX, BYX, EDGX, EDGA), Cboe Options, and Cboe Europe.
- Multicast UDP delivery with TCP gap-fill recovery.

#### CME MDP 3.0 (Market Data Platform)

CME Group's current market data protocol:

- **Encoding**: SBE (Simple Binary Encoding) over multicast UDP.
- **Message types**: Market data incremental refresh, market data snapshot, security definition, security status.
- **Book management**: Supports both Market-by-Price (10 levels of explicit and implied depth) and Market-by-Order (full order-level detail, introduced progressively across products).
- **Channels**: Data is organized into channels (multicast groups), each carrying a subset of instruments. Subscribers choose channels based on their product interest.
- **Recovery**: TCP-based snapshot recovery and historical replay services for gap-filling.
- **Throughput**: Peak message rates exceed 25 million messages per second across all channels during volatile sessions.

#### OPRA (Options Price Reporting Authority)

OPRA is the consolidated tape for US-listed equity options:

- Aggregates quotes and trades from all 16+ US options exchanges.
- One of the highest-throughput feeds in the world: peak rates exceed 150 billion messages per day (as of 2025), with sustained rates above 50 million messages per second.
- Binary encoding, delivered via multicast UDP across 48 multicast channels (as of the 2023 capacity expansion).
- OPRA is a regulatory requirement for any firm displaying US equity options market data.
- Managed by the Options Clearing Corporation (OCC) and the OPRA Plan.

#### ICE iMpact

ICE Futures uses the iMpact protocol:

- Multicast UDP delivery.
- Binary messages for market snapshots, trade messages, market statistics, options analytics (implied volatility, greeks).
- Covers ICE Futures US, ICE Futures Europe, ICE Futures Canada, ICE Futures Singapore.

### Transport Layer Considerations

#### Multicast UDP

The dominant transport for exchange market data feeds:

- **IP multicast**: A single stream is sent once and received by all subscribers on the multicast group. Dramatically reduces exchange bandwidth requirements compared to unicast TCP.
- **Multicast groups**: Feeds are partitioned into groups (channels) by product type, asset class, or hash function. Subscribers join only the groups they need.
- **Line arbitration**: For redundant delivery, exchanges typically publish the same data on two independent multicast lines (A and B feeds). The recipient performs line arbitration, selecting the message that arrives first and deduplicating using sequence numbers.
- **Packet loss**: UDP provides no delivery guarantee. Subscribers must detect gaps via sequence numbers and initiate recovery.
- **Kernel bypass**: For lowest latency, firms use kernel-bypass networking (DPDK, Solarflare OpenOnload, Mellanox VMA/DPDK, Xilinx/AMD Alveo FPGA NICs) to receive multicast packets directly in user space, bypassing the OS network stack. This can reduce NIC-to-application latency from ~10us (kernel path) to ~1-2us (kernel bypass) or sub-microsecond (FPGA).
- **Co-location**: To minimize network propagation delay, firms co-locate their feed handlers in the exchange's data center. Major co-location facilities: Equinix NY5/NY4/NY11 (US equities, NYSE), Carteret (NASDAQ), Aurora (CME), Basildon (LSE), Bergamo (Borsa Italiana).

#### TCP Recovery

When a multicast gap is detected, recovery is typically performed via:

- **TCP retransmission**: A dedicated TCP recovery service at the exchange resends the missed messages upon request.
- **Snapshot service**: A periodic full snapshot of the book state is published on a separate multicast channel or available via TCP. The subscriber can use the snapshot to rebuild state and then resume incremental processing.
- **Re-spin**: Some exchanges offer a complete replay of the day's messages from the beginning (used for late joiners or catastrophic gap situations).
