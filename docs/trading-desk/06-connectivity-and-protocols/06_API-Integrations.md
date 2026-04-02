## API Integrations

### REST APIs

Used for less latency-sensitive operations and third-party platform integrations:

- **Brokerage APIs**: Interactive Brokers Client Portal API, Alpaca, Tradier, TD Ameritrade (Schwab)
- **Exchange APIs**: Some exchange reference data and historical data services
- **Vendor APIs**: Risk system configuration, compliance system queries
- **Characteristics**: JSON/XML payloads, HTTP/HTTPS, rate-limited, suitable for reference data, position queries, account management

### WebSocket APIs

Real-time streaming over persistent TCP connections:

- **Use cases**: Browser-based trading UIs, lightweight market data streaming, real-time P&L updates
- **Crypto exchanges**: Binance, Coinbase, Kraken, FTX (defunct) all standardized on WebSocket for both market data and order entry
- **Equity/derivatives**: Some venues offer WebSocket as an alternative to FIX for lighter integrations
- **Protocols**: Native WebSocket, Socket.IO, SignalR (.NET ecosystem)

### gRPC

- **Design**: Google's high-performance RPC framework; Protocol Buffers (protobuf) serialization; HTTP/2 transport
- **Strengths**: Strongly typed contracts; bi-directional streaming; efficient binary serialization; polyglot code generation
- **Usage in trading**: Internal microservice communication; some modern exchange APIs; risk service calls; pricing engine interfaces
- **Latency**: Lower than REST (binary, persistent connections, multiplexing); higher than native binary protocols

### Bloomberg API (BLPAPI)

The **Bloomberg API** (also called B-PIPE for server-side, Desktop API for terminal-side) is the primary programmatic interface to Bloomberg data:

#### Data Services

| Service | Description |
|---------|-------------|
| `//blp/refdata` | Reference data: security fundamentals, corporate actions, index constituents |
| `//blp/mktdata` | Real-time market data: last price, bid/ask, volume |
| `//blp/mktbar` | Real-time OHLCV bars |
| `//blp/mktdepthdata` | Level 2 order book data |
| `//blp/tasvc` | Technical analysis service |
| `//blp/apiflds` | Field search and metadata |

#### Access Modes

- **Desktop API (DAPI)**: Runs on a Bloomberg Terminal desktop; limited to 1 connection; uses Desktop COM or BLPAPI SDK
- **Server API (SAPI)**: Runs on a server connecting to Bloomberg Appliance (B-PIPE); supports many concurrent sessions; requires B-PIPE license
- **B-PIPE**: Bloomberg's managed, server-side real-time data feed; co-located infrastructure; entitlement-managed; supports thousands of simultaneous subscriptions

#### SDK Support

BLPAPI SDKs available for: **C++, Java, .NET (C#), Python**, and COM (legacy). The .NET SDK integrates naturally with this platform.

#### Key Concepts

- **Topic subscriptions**: Subscribe to `//blp/mktdata` with topic strings like `MSFT US Equity` and field lists like `LAST_PRICE, BID, ASK, VOLUME`
- **Request/Response**: Historical data, reference data, and field search use request/response pattern
- **Entitlements**: Bloomberg enforces per-user, per-data entitlements; the API includes an entitlement management framework
- **EMSX API**: Bloomberg's Execution Management System API for order routing through Bloomberg

### Refinitiv/LSEG APIs

#### Refinitiv Eikon and Workspace API

- **Eikon Data API (Python)**: `eikon` Python library for desktop data access
- **Refinitiv Data Platform (RDP)**: Cloud-based REST and streaming APIs; successor to Eikon API
- **Elektron (now LSEG Real-Time)**: Enterprise-grade real-time data distribution; uses RSSL/RWF wire protocol
- **Elektron SDK (EMA/ETA)**: High-performance C++ and Java APIs for real-time data
- **Side-by-side server**: Managed, co-located market data infrastructure

#### LSEG Real-Time (formerly Refinitiv Real-Time)

- **TREP (Thomson Reuters Enterprise Platform)**: On-premise market data platform with ADS (Advanced Distribution Server), ADH (Advanced Data Hub), and ATS (Advanced Transformation Server)
- **Wire protocol**: RSSL (Reuters SSL) with RWF (Reuters Wire Format) binary encoding
- **Data model**: OMM (Open Message Model) with domain types (Market Price, Market By Order, Market By Price, etc.)

### Other Vendor APIs

| Vendor | API/Product | Notes |
|--------|-------------|-------|
| ICE Data Services | ICE Connect, Consolidated Feed | Managed data distribution |
| FactSet | FactSet SDK, FDS API | Research data, analytics, real-time quotes |
| S&P Capital IQ | Xpressfeed, Capital IQ API | Fundamentals, reference data |
| Morningstar | Morningstar API | Fund data, research, ratings |
| Quandl (Nasdaq) | Quandl API | Alternative data, economic data |
| IEX Cloud | IEX API | US equity data; REST/SSE |
