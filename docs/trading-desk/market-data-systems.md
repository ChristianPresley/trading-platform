# Market Data Systems

## Table of Contents

1. [Overview](#overview)
2. [Real-Time Market Data Feeds](#real-time-market-data-feeds)
3. [Market Data Sources and Exchanges](#market-data-sources-and-exchanges)
4. [Data Normalization and Symbology](#data-normalization-and-symbology)
5. [Market Data Protocols](#market-data-protocols)
6. [Tick Data Storage and Time-Series Databases](#tick-data-storage-and-time-series-databases)
7. [Market Data Conflation and Throttling](#market-data-conflation-and-throttling)
8. [Reference Data and Static Data](#reference-data-and-static-data)
9. [Historical Market Data](#historical-market-data)
10. [Market Data Entitlements and Licensing](#market-data-entitlements-and-licensing)
11. [Market Data Infrastructure](#market-data-infrastructure)
12. [Alternative Data Integration](#alternative-data-integration)

---

## Overview

Market data systems form the nervous system of any professional trading desk. They are responsible for the ingestion, normalization, distribution, storage, and entitlement management of financial instrument pricing information across all asset classes. A well-architected market data platform must handle millions of messages per second with microsecond-level latency while maintaining data integrity, auditability, and regulatory compliance.

The core responsibilities of a market data system include:

- **Ingestion**: Connecting to exchanges, consolidated feeds, and third-party vendors to receive raw pricing events.
- **Normalization**: Translating venue-specific message formats and symbology into a uniform internal representation.
- **Distribution**: Delivering normalized data to consuming applications (trading UIs, algorithmic engines, risk systems, compliance monitors) with appropriate entitlements.
- **Persistence**: Storing tick-level and aggregated data for historical analysis, backtesting, and regulatory record-keeping.
- **Entitlement enforcement**: Ensuring that data usage complies with exchange licensing agreements, user-level permissions, and display/non-display classification.

---

## Real-Time Market Data Feeds

### Level 1 Data (Top of Book)

Level 1 data provides the most basic real-time pricing information for a financial instrument. It represents the current best available prices and the most recent trade activity.

#### Core Fields

| Field | Description |
|-------|-------------|
| **Best Bid Price** | Highest price at which a buyer is willing to purchase |
| **Best Bid Size** | Number of shares/contracts available at the best bid |
| **Best Ask Price** (Offer) | Lowest price at which a seller is willing to sell |
| **Best Ask Size** | Number of shares/contracts available at the best ask |
| **Last Trade Price** | Price of the most recent executed trade |
| **Last Trade Size** | Volume of the most recent executed trade |
| **Last Trade Time** | Timestamp of the most recent execution (typically exchange timestamp) |
| **Cumulative Volume** | Total shares/contracts traded in the current session |
| **VWAP** | Volume-weighted average price for the session |
| **Open Price** | First trade price of the session (or indicative open from auction) |
| **High Price** | Highest trade price during the session |
| **Low Price** | Lowest trade price during the session |
| **Previous Close** | Official closing price from the prior session |
| **Net Change** | Difference between last trade price and previous close |
| **Turnover** | Cumulative notional value traded (price x volume) |

#### NBBO vs BBO

- **BBO (Best Bid and Offer)**: The best bid and ask prices available on a single venue. Each exchange publishes its own BBO.
- **NBBO (National Best Bid and Offer)**: The best bid and ask prices across all protected exchanges in the United States. The NBBO is the regulatory benchmark under Regulation NMS (National Market System). It is calculated by the Securities Information Processors (SIPs) by comparing BBOs from all NMS exchanges. Brokers have a duty of best execution against the NBBO. In practice, many firms calculate their own "direct NBBO" from direct exchange feeds to achieve lower latency than the SIP-disseminated NBBO.

#### Quote Condition Codes

Quotes carry condition codes that indicate their nature: regular trading, pre-market, after-hours, auction indicative, halted, short-sale restricted, odd-lot, and so on. Proper interpretation of these codes is essential for accurate pricing displays and algorithmic decision-making.

### Level 2 Data (Depth of Book)

Level 2 data reveals the full order book beyond the top-of-book, showing the supply and demand landscape at multiple price levels.

#### Market-by-Price (MBP)

Market-by-Price aggregates all orders at each price level into a single entry showing the total quantity available. This is the most common Level 2 representation for display purposes.

```
Price Level | Bid Qty | Bid Price | Ask Price | Ask Qty
     1      |  5,000  |  150.25   |  150.26   |  3,200
     2      |  8,300  |  150.24   |  150.27   |  7,100
     3      | 12,400  |  150.23   |  150.28   |  4,500
     4      |  2,100  |  150.22   |  150.29   |  9,800
     5      |  6,700  |  150.21   |  150.30   | 15,200
```

Typical depth: 5, 10, or 20 price levels, depending on the exchange and subscription tier. CME provides 10 levels of implied and explicit depth in its Market-by-Price feed. NYSE Arca publishes full depth. NASDAQ TotalView provides full depth-of-book with attributed orders.

#### Market-by-Order (MBO)

Market-by-Order provides individual order-level detail: each resting order in the book is represented as a separate entry with its unique order ID, price, size, timestamp, and (on some venues) the identity of the market participant (attributed feeds).

MBO data is significantly higher bandwidth than MBP. It enables:

- Precise order book reconstruction.
- Queue position estimation (knowing how many orders are ahead at a price level).
- Detection of order patterns (iceberg detection, spoofing analysis).
- More accurate simulation for backtesting fill models.

Exchanges offering MBO feeds include:

| Exchange | MBO Feed Name |
|----------|---------------|
| NASDAQ | TotalView-ITCH |
| NYSE | NYSE Integrated Feed (pillar) |
| CME | CME Market-by-Order (MBO, via MDP 3.0) |
| LSE | Level 2 - Full Order Book (via MIT/native) |
| Eurex | EOBI (Enhanced Order Book Interface) |
| ASX | ASX ITCH |
| TMX | TMX Quantum Feed |

#### Implied and Composite Books

In derivatives markets, exchanges like CME calculate implied prices from combinations of outright and spread orders. The implied book is published alongside the explicit book. Trading systems must merge these to present a complete depth view. Similarly, for securities trading across multiple venues, a composite or consolidated book aggregates depth from all lit venues.

### Level 3 Data

Level 3 is not a standardized industry term but sometimes refers to the ability to submit and manage orders directly within the exchange's order book, essentially market-maker functionality. Some practitioners use it to refer to the full MBO feed with add/modify/delete messages.

---

## Market Data Sources and Exchanges

### Major Equity Exchanges

#### United States

| Exchange | Operator | Primary Feed | Protocol |
|----------|----------|-------------|----------|
| **NYSE** | Intercontinental Exchange (ICE) | NYSE Pillar | NYSE Pillar Gateway (binary) |
| **NYSE Arca** | ICE | NYSE Arca Integrated Feed | Pillar binary |
| **NYSE American** | ICE | NYSE American Integrated Feed | Pillar binary |
| **NASDAQ** | Nasdaq Inc. | TotalView-ITCH 5.0 | ITCH (binary, multicast UDP) |
| **NASDAQ BX** | Nasdaq Inc. | BX TotalView-ITCH | ITCH |
| **NASDAQ PSX** | Nasdaq Inc. | PSX TotalView-ITCH | ITCH |
| **Cboe BZX** | Cboe Global Markets | Cboe PITCH | PITCH (binary) |
| **Cboe BYX** | Cboe | Cboe PITCH | PITCH |
| **Cboe EDGX** | Cboe | Cboe PITCH | PITCH |
| **Cboe EDGA** | Cboe | Cboe PITCH | PITCH |
| **IEX** | IEX Group | IEX TOPS / DEEP | IEX-TP (binary, free) |
| **MEMX** | Members Exchange | MEMX Memoir | Memoir (binary) |
| **LTSE** | Long-Term Stock Exchange | LTSE data feed | LTSE proprietary |
| **MIAX Pearl Equities** | Miami International Holdings | MIAX Pearl MACH | MEI protocol |

There are currently 16 registered national securities exchanges in the US for equities, plus numerous ATSs (Alternative Trading Systems) / dark pools.

#### Europe

| Exchange | Operator | Primary Feed |
|----------|----------|-------------|
| **LSE** | London Stock Exchange Group (LSEG) | MIT (Millennium Exchange) via UDP multicast |
| **Euronext** (Paris, Amsterdam, Brussels, Lisbon, Dublin, Oslo, Milan) | Euronext N.V. | Optiq MDG (Market Data Gateway) |
| **Eurex** | Deutsche Boerse | EOBI (Enhanced Order Book Interface), EMDI |
| **Xetra** | Deutsche Boerse | T7 EMDI/EOBI |
| **SIX Swiss Exchange** | SIX Group | FIX/FAST, proprietary binary |
| **Nasdaq Nordic/Baltic** | Nasdaq | ITCH |
| **Cboe Europe** | Cboe | Cboe Europe PITCH |
| **Aquis Exchange** | Aquis Exchange PLC | ITCH |
| **Turquoise** | LSEG | MIT-based |

#### Asia-Pacific

| Exchange | Operator | Primary Feed |
|----------|----------|-------------|
| **TSE** (Tokyo) | Japan Exchange Group | arrowhead (FLEX Full/Standard) |
| **HKEX** | Hong Kong Exchanges | OMD (Orion Market Data) |
| **SGX** | Singapore Exchange | ITCH (Titan OMS) |
| **ASX** | ASX Ltd | ASX ITCH |
| **SSE** (Shanghai) | SSE | FAST/Binary |
| **SZSE** (Shenzhen) | SZSE | Binary |
| **BSE/NSE** (India) | BSE Ltd / NSE | Proprietary binary, multicast |
| **KRX** (Korea) | Korea Exchange | KOSCOM feed |

### Derivatives Exchanges

| Exchange | Asset Classes | Primary Feed |
|----------|--------------|-------------|
| **CME Group** (CME, CBOT, NYMEX, COMEX) | Futures, options on futures (rates, equity index, FX, energy, metals, agriculture) | MDP 3.0 (Market Data Platform), SBE encoding, multicast UDP |
| **ICE** (ICE Futures US, ICE Futures Europe, ICE Futures Canada) | Energy, soft commodities, rates, equity index | iMpact multicast |
| **Cboe Options** (C1, C2, BZX Options, EDGX Options) | Equity options | Cboe PITCH |
| **NASDAQ Options** (PHLX, ISE, GEMX, MRX, BX Options, NASDAQ Options) | Equity options | ITCH |
| **NYSE Options** (NYSE Arca Options, NYSE American Options) | Equity options | Pillar |
| **MIAX Options** (MIAX, PEARL, EMERALD) | Equity options | MEI / MACH |
| **Eurex** | European derivatives (EURO STOXX, DAX, rates) | EOBI, EMDI |
| **LME** | Base metals | LMEselect (proprietary) |

### Consolidated Feeds vs Direct Feeds

#### Consolidated Feeds (US Equities)

In the US, the consolidated tape is mandated by Regulation NMS and operated by the Securities Information Processors (SIPs):

- **CTA (Consolidated Tape Association)**: Covers NYSE-listed (Tape A) and NYSE Arca / regional-listed (Tape B) securities. Operated by the NYSE on behalf of the CTA Plan participants.
  - **CTS (Consolidated Tape System)**: Trade reports (last sale).
  - **CQS (Consolidated Quotation System)**: Best bid/offer quotes from each exchange.

- **UTP (Unlisted Trading Privileges Plan)**: Covers NASDAQ-listed (Tape C) securities. Operated by Nasdaq on behalf of UTP Plan participants.
  - **UTDF (UTP Trade Data Feed)**: Trade reports.
  - **UQDF (UTP Quotation Data Feed)**: Best bid/offer quotes.

The SIP aggregates quotes from all NMS exchanges and calculates the NBBO. SIP latency is typically in the range of hundreds of microseconds to low single-digit milliseconds. Under the SEC's 2023 market data infrastructure rule updates, the consolidated tape is evolving toward a competing consolidator model in the US.

In Europe, following MiFID II/MiFIR, there was no mandatory consolidated tape until the EU adopted rules for a European consolidated tape provider (CTP) in 2024, with Cboe subsidiary being selected as the first CTP for equities.

#### Direct Exchange Feeds

Professional trading desks subscribe to direct feeds from individual exchanges for several reasons:

- **Lower latency**: Direct feeds arrive faster than the consolidated tape because there is no aggregation step. The latency advantage can be 10-500 microseconds depending on infrastructure.
- **Greater depth**: Direct feeds typically provide full depth-of-book or more price levels than the consolidated tape.
- **Order-level detail**: MBO feeds are only available via direct feeds.
- **Imbalance and auction data**: Opening/closing auction indicative prices, paired/unpaired shares.
- **Additional message types**: Order imbalance indicators, LULD (Limit Up-Limit Down) bands, short sale restriction indicators, regulatory halt messages.

The trade-off is cost: each direct feed requires a separate exchange data license, co-location or network connectivity, and a dedicated feed handler. A US equities desk subscribing to all 16 exchanges' direct feeds will spend significantly more than one using only the SIP, but gains a material latency and information advantage.

### Market Data Vendors

Major third-party market data vendors provide aggregated, normalized feeds:

| Vendor | Key Products |
|--------|-------------|
| **Bloomberg** | Bloomberg B-PIPE (real-time), Bloomberg Terminal, BVAL (valuations) |
| **Refinitiv (LSEG)** | Refinitiv Real-Time (Elektron/TREP), Eikon, Datascope |
| **ICE Data Services** | ICE Consolidated Feed, ICE Global Network, ICE Pricing & Analytics |
| **Nasdaq Global Data Services** | Nasdaq Global Data Service, Nasdaq Basic |
| **FactSet** | Real-time feed via Open:FactSet |
| **S&P Global Market Intelligence** | Capital IQ real-time |
| **MayStreet** | Ultra-low-latency normalized feeds, full packet capture |
| **Exegy** | Hardware-accelerated feed handling, nxFramework |

Vendor feeds offer convenience (single API, normalized symbology, broad coverage) at the cost of additional latency (typically 1-10ms over direct) and higher per-instrument licensing fees.

---

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

---

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

---

## Reference Data and Static Data

### Instrument Master (Security Master)

The instrument master is the authoritative database of all tradeable instruments and their static attributes. It is the foundation on which all other market data systems build.

#### Core Attributes

| Category | Fields |
|----------|--------|
| **Identifiers** | Ticker, ISIN, CUSIP, SEDOL, FIGI, exchange symbol, RIC, Bloomberg ticker, internal ID |
| **Classification** | Asset class, instrument type (common stock, preferred, ETF, ADR, warrant, right, unit), sector (GICS, ICB), industry |
| **Listing** | Primary exchange (MIC), listing date, trading currency, country of risk, country of incorporation |
| **Trading parameters** | Tick size (minimum price increment), lot size (round lot, odd lot, board lot), minimum order size, maximum order size |
| **Pricing** | Price display format (decimal, fractional for US treasuries), price magnifier, settlement price type |
| **Corporate** | Issuer name, issuer LEI, shares outstanding, market cap, free float |
| **Options-specific** | Underlying, strike price, expiration date, option type (call/put), exercise style (American/European/Bermudan), contract multiplier, deliverable |
| **Futures-specific** | Underlying, expiration date, first notice date, last trading date, contract size, tick value, settlement method (cash/physical), delivery months |
| **FX-specific** | Currency pair, base currency, quote currency, spot date convention, pip value |
| **Fixed income** | Coupon rate, coupon frequency, maturity date, day count convention, accrued interest, call/put schedule |

### Corporate Actions

Corporate actions alter the characteristics of securities and require adjustments to market data, positions, and analytics:

| Action | Impact on Market Data |
|--------|---------------------|
| **Stock split / reverse split** | Adjust historical prices by split ratio. Update shares outstanding, lot sizes. |
| **Dividend** (cash, stock, special) | Ex-date price adjustment. Stock dividends affect share count. |
| **Merger / acquisition** | Ticker change, ISIN change, delisting of acquired entity, new listing for combined entity. |
| **Spin-off** | New instrument created, price adjustment for parent. |
| **Rights issue** | New temporary instrument (rights), dilution adjustment. |
| **Ticker change** | Symbol mapping update across all systems. |
| **Name change** | Descriptive update, no price impact. |
| **Delisting** | Instrument becomes non-tradeable; must be marked inactive. |
| **Conversion** (convertible bonds, preferred to common) | New instrument relationship, potential delisting of old. |

Handling corporate actions correctly is one of the hardest problems in financial data management. A single missed or misapplied corporate action can corrupt analytics, break backtests, and cause trading errors.

### Holiday Calendars

Trading systems must know when markets are open or closed:

- **Exchange-specific holidays**: Each exchange publishes its own holiday calendar. NYSE has ~9 holidays/year; LSE has ~8; TSE (Tokyo) has ~16+ including Golden Week.
- **Early close days**: Some exchanges close early on certain days (e.g., NYSE closes at 13:00 ET on the day before certain US holidays).
- **Settlement calendars**: Settlement dates depend on the business day calendar of the settlement currency and location.
- **Cross-market coordination**: Trading a cross-listed security or a multi-leg strategy requires knowledge of all relevant market calendars.

Calendar data providers: Bloomberg CALS function, Refinitiv calendar data, QuantLib holiday implementations, custom internal maintenance.

### Trading Hours

| Venue | Pre-Market | Core Session | Post-Market |
|-------|-----------|-------------|-------------|
| **NYSE** | 04:00-09:30 ET (via Arca) | 09:30-16:00 ET | 16:00-20:00 ET |
| **NASDAQ** | 04:00-09:30 ET | 09:30-16:00 ET | 16:00-20:00 ET |
| **CME ES** (E-mini S&P) | Sunday 18:00-Friday 17:00 ET (nearly 24h with 1h break) | Same | Same |
| **LSE** | 05:05-08:00 GMT (auction) | 08:00-16:30 GMT | 16:30-17:00 GMT (closing auction) |
| **Eurex** | 07:30-08:00 CET (pre-trading) | 08:00-22:00 CET (varies by product) | N/A |
| **TSE** | N/A | 09:00-11:30, 12:30-15:30 JST (morning/afternoon sessions, extended to 15:30 from Nov 2024) | N/A |
| **HKEX** | 09:00-09:30 HKT (pre-open) | 09:30-12:00, 13:00-16:00 HKT (morning/afternoon) | 16:00-16:10 HKT (closing auction) |

Trading hours are critical for: data feed activation/deactivation, stale data detection, auction phase identification, risk limit resets, and P&L calculations.

### Tick Size Tables

Tick sizes (minimum price increments) vary by instrument, price level, and venue:

#### US Equities (Reg NMS)

- Stocks priced >= $1.00: $0.01 minimum tick
- Stocks priced < $1.00: $0.0001 minimum tick

#### European Equities (MiFID II Tick Size Regime)

Tick sizes depend on the instrument's average daily number of transactions (ADNT) and price level, as defined in RTS 11 tables. For example, a liquid stock with ADNT > 10,000 trading at EUR 50 might have a tick size of EUR 0.01, while a less liquid stock at the same price might have a tick of EUR 0.05.

#### Futures

Tick sizes are contract-specific. For example:
- CME ES (E-mini S&P 500): 0.25 index points = $12.50/tick
- CME NQ (E-mini NASDAQ-100): 0.25 index points = $5.00/tick
- CME CL (WTI Crude Oil): $0.01/barrel = $10.00/tick
- Eurex FGBL (Euro-Bund): 0.01% = EUR 10.00/tick

### Lot Sizes

- **US equities**: Round lot = 100 shares (though odd-lot handling has evolved under SEC reforms).
- **LSE equities**: Varies by instrument, often 1 share for electronic order book.
- **HKEX**: Board lot varies by stock (commonly 100, 200, 400, 500, 1000, 2000 shares).
- **Futures**: Always 1 contract minimum. Block trade minimums are larger.

---

## Historical Market Data

### End-of-Day (EOD) Data

EOD data provides daily summary statistics for each instrument:

- **Official closing price**: The exchange-determined closing price (often from a closing auction).
- **Adjusted close**: Closing price adjusted for corporate actions (splits, dividends). Critical for long-term return analysis.
- **OHLCV**: Open, high, low, close, volume for the session.
- **Settlement price**: For futures and options, the daily settlement price used for margin calculations (may differ from the last trade price; often calculated by the exchange using a methodology involving trades in the final minutes).

EOD data providers: Bloomberg, Refinitiv, FactSet, S&P Capital IQ, Quandl (Nasdaq), Yahoo Finance (limited), exchange direct (via FTP or API).

### Intraday History

Intraday historical data provides sub-daily granularity:

- **Tick-level**: Every trade and quote change, timestamped to nanosecond precision.
- **Bar-level**: Pre-aggregated OHLCV bars at standard intervals (1m, 5m, 15m, 1h).
- **Depth-of-book snapshots**: Periodic snapshots of the full order book at regular intervals (e.g., every second or every 100ms).

Intraday history is essential for:
- Backtesting intraday trading strategies.
- Transaction cost analysis (TCA).
- Regulatory surveillance and reconstruction.
- Model training for machine learning strategies.

### Replay Capabilities

Market data replay reconstructs the exact sequence of market events as they occurred:

- **Full-fidelity replay**: Replays raw exchange messages at their original timestamps. Used for strategy backtesting with realistic fill simulation.
- **Time-scaled replay**: Replay at faster or slower than real time. Useful for development and debugging.
- **Filtered replay**: Replay only specific instruments or message types. Reduces data volume for focused analysis.
- **Multi-venue synchronized replay**: Replay data from multiple exchanges simultaneously, maintaining correct temporal ordering across venues. Essential for strategies that trade across venues.

Implementation considerations:

- **Timestamp precision**: Replay timestamps should preserve the original exchange timestamps (nanosecond precision) separately from the receipt timestamps (when the firm's feed handler received the message) and the replay timestamp.
- **Gap handling**: Replay systems must handle and flag gaps in the original data.
- **Message rate smoothing**: During replay, burst periods may produce message rates that overwhelm consumers if replayed at full speed. Rate governors may be needed.

### Backtesting Data Requirements

Realistic backtesting requires:

- **Survivorship-bias-free universes**: Include delisted, merged, and bankrupt instruments. Point-in-time constituent lists for indices.
- **Point-in-time data**: Corporate action adjustments must be applied as they were known at the time, not retroactively. Split-adjusted vs unadjusted prices.
- **Accurate trade conditions**: Filter trades by condition code (regular vs off-exchange, block, etc.) as appropriate for the strategy.
- **Bid-ask spread data**: For realistic fill simulation, trade prices alone are insufficient; bid-ask data is needed to model slippage.
- **Depth-of-book data**: For market-impact-aware backtesting of strategies that trade significant volume relative to displayed liquidity.

### Major Historical Data Providers

| Provider | Coverage |
|----------|----------|
| **Bloomberg** | Comprehensive global coverage, tick + bar + EOD, via Terminal or B-PIPE historical |
| **Refinitiv Tick History (RTH)** | One of the deepest tick-level archives, covering global equities, derivatives, FX. Petabytes of data going back to 1996+ |
| **Kibot** | US equities and futures, intraday and daily, lower cost |
| **Polygon.io** | US equities, options, FX, crypto. REST and WebSocket APIs. Tick-level and aggregated. |
| **Databento** | Normalized historical and real-time market data, high performance, modern API |
| **Algoseek** | US equities and options, TAQ-equivalent data |
| **TickData (NovusNorth)** | Clean, corporate-action-adjusted tick data, global coverage |
| **Quandl (Nasdaq Data Link)** | EOD and alternative data, wide variety of datasets |
| **FirstRate Data** | US equities and ETFs, intraday |

---

## Market Data Entitlements and Licensing

### Exchange Data Licensing

Exchanges are significant revenue generators from market data licensing. Each exchange has its own fee schedule and usage policies. Firms must execute data agreements with each exchange whose data they consume.

#### Fee Structures

| Fee Type | Description |
|----------|-------------|
| **Access fee** | Monthly fee for the right to connect to and receive the feed. Applies per connection or per data center. |
| **Per-user fee (professional)** | Monthly fee per individual who can view real-time data. Ranges from $5-$150+/user/month depending on the exchange and data level. |
| **Per-user fee (non-professional)** | Reduced rate for individual retail investors. Typically $1-$20/month. Strict criteria define non-professional status. |
| **Enterprise license** | Flat fee for unlimited professional users within a legal entity. Expensive (tens of thousands to millions per year per exchange) but economical at scale. |
| **Non-display fee** | Fee for using data in automated/programmatic applications (algo trading, risk engines, pricing models) where no human views the data directly. Often usage-based or per-platform. |
| **Derived data fee** | Fee for creating and distributing data that is derived from exchange data (indices, analytics, VWAP benchmarks). Policies vary significantly by exchange. |
| **Redistribution fee** | Fee for distributing exchange data to third parties (data vendors, clients). Requires explicit redistribution agreements. |
| **Device fee** | Some exchanges charge per device (terminal, screen, application instance) rather than per user. |

#### Display vs Non-Display Usage

The distinction between display and non-display usage is critical for licensing:

- **Display usage**: A human views real-time market data on a screen. Subject to per-user or enterprise display fees.
- **Non-display usage**: Data is consumed by an automated process (trading algorithm, risk engine, smart order router, pricing model, surveillance system) without direct human viewing. Subject to non-display use fees, which can be significantly higher than display fees. Categories often include:
  - **Trading**: Automated and semi-automated order generation.
  - **Valuation/risk**: Portfolio valuation, risk calculations, margin.
  - **Surveillance**: Market abuse monitoring, compliance.

Major exchanges (NYSE, NASDAQ, CME, OPRA) have detailed non-display use policies with fee schedules that distinguish between these categories.

### Entitlement Management

A professional trading desk requires a robust entitlement management system:

- **User-level permissions**: Which users can see which exchanges' data, at which level (L1, L2, delayed, real-time).
- **Application-level permissions**: Which applications can consume which data feeds.
- **Audit trail**: Complete record of who accessed what data and when, for exchange audit compliance.
- **Vendor-of-record reporting**: Monthly reporting to exchanges of user counts, device counts, and usage categories.
- **Delayed data**: Exchanges typically allow free or low-cost distribution of data delayed by 15-20 minutes. Entitlement systems must enforce the delay.
- **Controlled distribution**: Ensuring data does not leak beyond entitled users/applications (e.g., via screen sharing, email, or data export).

Exchange audits are a real operational risk. Exchanges (particularly NYSE, NASDAQ, and CME) conduct periodic audits of data subscribers to verify compliance with licensing terms. Under-reporting user counts or misclassifying non-display usage can result in significant back-billing and penalties.

### Regulatory Considerations

- **Reg NMS (US)**: Requires that brokers protect the NBBO and route orders to venues displaying the best price. This creates a de facto mandate to consume real-time data from all NMS exchanges.
- **MiFID II/MiFIR (EU)**: Requires best execution, consolidated reporting, and transparent pre/post-trade data publication. Exchange data must be available on a "reasonable commercial basis" (RCB).
- **Market data revenue regulation**: The SEC has been examining exchange market data pricing and has proposed reforms to increase competition and reduce costs. The competing consolidator model is part of this effort.

---

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

---

## Alternative Data Integration

### News Feeds

Real-time news is critical for event-driven trading and risk management:

| Provider | Products |
|----------|---------|
| **Dow Jones Newswires** | DJ News, Dow Jones Institutional News, DJNW machine-readable feed |
| **Reuters News** (LSEG) | Reuters Real-Time News, Reuters News Feed Direct, machine-readable news |
| **Bloomberg News** | Bloomberg First Word, Bloomberg News (BN) wire |
| **RavenPack** | NLP-processed news analytics: sentiment scores, event classifications, entity recognition. Delivered as structured data with microsecond-level processing latency |
| **Benzinga** | Benzinga Pro news feed, APIs for headlines and stories |
| **PR Newswire / Business Wire / GlobeNewswire** | Press release distribution; important for earnings, M&A announcements |
| **Briefing.com** | Market commentary and analysis |

Machine-readable news (MRN) formats provide structured metadata (headline, story body, company codes, topic codes, sentiment) that can be consumed programmatically by trading algorithms.

### Social Sentiment

| Provider | Description |
|----------|-------------|
| **Twitter/X firehose** (via data partners) | Real-time social media mentions of stocks, crypto, macro events. Requires NLP processing. |
| **StockTwits** | Dedicated financial social platform with structured sentiment data (bullish/bearish). |
| **Reddit** (via API) | r/wallstreetbets and other financial subreddits; became notable after GameStop/AMC events. |
| **Quiver Quantitative** | Aggregated alternative data including social sentiment, political trading, lobbying. |
| **Sentifi** | AI-driven crowd sentiment analysis from social media and news. |
| **Brain Company** | Sentiment analytics derived from news and social media. |

### Economic Indicators

| Data Type | Sources |
|-----------|---------|
| **US macro** | Bureau of Labor Statistics (BLS: NFP, CPI, PPI, unemployment), Bureau of Economic Analysis (BEA: GDP), Federal Reserve (FOMC decisions, Beige Book), Census Bureau (retail sales, housing starts), ISM (PMI) |
| **European macro** | Eurostat, ECB, national statistics offices |
| **Global macro** | IMF, World Bank, OECD |
| **Calendars** | Bloomberg Economic Calendar, Refinitiv Economic Monitor, ForexFactory, Investing.com |
| **Real-time delivery** | Vendor terminals (Bloomberg, Refinitiv) provide instant structured delivery of economic releases with consensus estimates and actual values. Low-latency feeds available from providers like MNI, Econoday, Briefing.com. |

Economic indicator releases can cause significant market moves in milliseconds. Latency of data delivery for major releases (NFP, CPI, FOMC) is competitively important.

### Weather Data

Relevant primarily for energy and agricultural commodities trading:

| Provider | Description |
|----------|-------------|
| **DTN** | Agricultural and energy weather intelligence, forecasts, radar |
| **The Weather Company (IBM)** | High-resolution weather models, historical data, APIs |
| **Maxar** | Weather analytics for energy trading (natural gas, power) |
| **NOAA** | Official US weather data, free but higher latency |
| **Schneider Electric** | Energy weather analytics and load forecasting |

Weather data impacts natural gas (heating/cooling degree days), crude oil (hurricane disruption), agriculture (crop conditions), and electricity (demand forecasting).

### Other Alternative Data

| Category | Examples |
|----------|---------|
| **Satellite imagery** | Parking lot traffic (retail sales proxy), oil storage tank levels, crop health (NDVI). Providers: Orbital Insight, RS Metrics, Descartes Labs. |
| **Credit card / transaction data** | Consumer spending patterns. Providers: Second Measure, Earnest Research, Bloomberg Second Measure. |
| **Web scraping / app data** | Product pricing, job postings, app downloads. Providers: Thinknum, SimilarWeb. |
| **Shipping / logistics** | AIS vessel tracking (crude oil tanker movements), freight rates. Providers: MarineTraffic, Kpler, ClipperData. |
| **Patent / IP data** | Patent filings as a proxy for innovation pipeline. |
| **Government filings** | SEC EDGAR (13F holdings, insider transactions via Form 4), lobbying disclosures, political donations. Providers: Quiver Quantitative, InsiderScore. |
| **Geolocation / foot traffic** | Store visit data from mobile devices. Providers: Placer.ai, SafeGraph. |
| **ESG data** | Environmental, social, governance scores and underlying metrics. Providers: MSCI ESG, Sustainalytics, ISS ESG, Bloomberg ESG. |
| **Options flow** | Unusual options activity, dark pool prints. Providers: Unusual Whales, FlowAlgo. |

### Integration Challenges

Alternative data integration presents unique challenges compared to traditional market data:

- **Unstructured formats**: News, social media, and satellite imagery require NLP, computer vision, or other ML processing before they can be consumed by trading systems.
- **Irregular delivery**: Unlike exchange data which arrives in a continuous stream, alternative data may arrive in batches (daily, weekly) or at irregular intervals.
- **Point-in-time integrity**: For backtesting, it is critical to know exactly when each piece of alternative data became available. Lookahead bias from using data before its actual availability is a common backtesting error.
- **Quality and coverage**: Alternative datasets often have gaps, biases (survivorship, selection), and limited history. Rigorous data quality validation is essential.
- **Vendor risk**: Alternative data vendors are often small companies. Data availability, methodology changes, and vendor viability are operational risks.
- **Compliance and privacy**: Use of alternative data must comply with SEC/FCA regulations on material non-public information (MNPI), data privacy regulations (GDPR, CCPA), and exchange data derivation policies.

---

## Appendix: Key Metrics and Benchmarks

### Typical Message Rates (US Markets, 2025 Era)

| Feed | Average Daily Messages | Peak Messages/Second |
|------|----------------------|---------------------|
| NASDAQ TotalView-ITCH | ~30-50 billion/day | ~5 million/sec |
| NYSE Integrated Feed | ~15-30 billion/day | ~3 million/sec |
| OPRA (all US options) | ~150+ billion/day | ~50+ million/sec |
| CME MDP 3.0 (all channels) | ~5-10 billion/day | ~25 million/sec |
| SIP (CTS + UTP combined) | ~10-20 billion/day | ~2 million/sec |

### Typical Latency Targets

| Use Case | Target Latency (exchange to internal) |
|----------|--------------------------------------|
| Ultra-low-latency / HFT | < 5 microseconds (FPGA-based) |
| Low-latency electronic trading | 10-100 microseconds |
| Systematic / quant trading | 100 microseconds - 1 millisecond |
| Professional trading desk (display) | 1-10 milliseconds |
| Risk / middle office | 10-100 milliseconds |
| Retail / web distribution | 100 milliseconds - 1 second |

### Data Volume Estimates

| Data Type | Daily Volume (compressed) |
|-----------|--------------------------|
| Full US equities tick data (all venues) | ~500 GB - 1 TB |
| Full US options tick data (OPRA) | ~1-2 TB |
| CME futures tick data | ~50-100 GB |
| Global equities tick data | ~2-5 TB |
| EOD data (global) | ~100-500 MB |

---

## Appendix: Glossary

| Term | Definition |
|------|-----------|
| **ADNT** | Average Daily Number of Transactions |
| **ATS** | Alternative Trading System (dark pool) |
| **BBO** | Best Bid and Offer |
| **CEP** | Complex Event Processing |
| **CTA** | Consolidated Tape Association |
| **DMA** | Direct Market Access |
| **DPDK** | Data Plane Development Kit (kernel bypass) |
| **EOBI** | Enhanced Order Book Interface (Eurex) |
| **FAST** | FIX Adapted for STreaming |
| **FIGI** | Financial Instrument Global Identifier |
| **FIX** | Financial Information eXchange |
| **FPGA** | Field-Programmable Gate Array |
| **GICS** | Global Industry Classification Standard |
| **ITCH** | Exchange binary market data protocol (Nasdaq family) |
| **LULD** | Limit Up-Limit Down |
| **MBO** | Market-by-Order |
| **MBP** | Market-by-Price |
| **MDP** | Market Data Platform (CME) |
| **MIC** | Market Identifier Code (ISO 10383) |
| **MRN** | Machine-Readable News |
| **NBBO** | National Best Bid and Offer |
| **NMS** | National Market System |
| **NOII** | Net Order Imbalance Indicator |
| **OHLCV** | Open, High, Low, Close, Volume |
| **OPRA** | Options Price Reporting Authority |
| **OUCH** | Exchange order entry protocol (Nasdaq family) |
| **PTP** | Precision Time Protocol (IEEE 1588) |
| **RDB** | Real-time Database (KDB+ architecture) |
| **RIC** | Reuters Instrument Code |
| **SBE** | Simple Binary Encoding |
| **SIP** | Securities Information Processor |
| **TCA** | Transaction Cost Analysis |
| **UTP** | Unlisted Trading Privileges |
| **VWAP** | Volume-Weighted Average Price |
