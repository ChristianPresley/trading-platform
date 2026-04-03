# Connectivity and Protocols

Comprehensive reference for network connectivity, messaging protocols, data feeds, and integration patterns found in professional trading desk applications.

## Contents

1. [FIX Protocol](01_FIX-Protocol.md) — FIX version history, session layer (FIXT 1.1) and application layer architecture, message types for order flow / market data / post-trade, key tag reference, and tag=value wire format
   - `NewOrderSingle`, `ExecutionReport`, `OrderCancelReplaceRequest`, `MarketDataRequest`, `TradeCaptureReport`, `SenderCompID`, `MsgSeqNum`, `ResendRequest`, `ClOrdID`

2. [FIX Engines and Session Management](02_FIX-Engines-And-Session-Management.md) — Major FIX engines (QuickFIX family, commercial, FPGA-accelerated), session configuration, lifecycle (logon through logout), sequence number persistence and gap recovery, and production monitoring
   - `FIXEngine`, `SessionConfig`, `SequenceNumber`, `ResendRequest`, `GapFill`, `HeartBtInt`, `PossDupFlag`, `ResetSeqNumFlag`

3. [Market Data Protocols](03_Market-Data-Protocols.md) — Binary market data protocols (FAST, SBE, ITCH, OUCH, PITCH), proprietary exchange protocols, UDP multicast architecture, recovery mechanisms, and consolidated vs. direct feeds
   - `FAST`, `SBE`, `ITCH`, `OUCH`, `PITCH`, `MoldUDP64`, `MulticastPublisher`, `LineArbitration`, `SIP`, `DirectFeed`

4. [Network Connectivity](04_Network-Connectivity.md) — Dedicated lines, cross-connects, co-location and proximity hosting, microwave/millimeter-wave/laser links, and key low-latency network routes
   - `CrossConnect`, `CoLocation`, `ProximityHosting`, `DarkFiber`, `DWDM`, `MicrowaveLink`, `FreqSpaceLaser`

5. [Message Queuing and Middleware](05_Message-Queuing-And-Middleware.md) — Messaging platforms (Solace, TIBCO RV, Kafka, ZeroMQ, Aeron, Chronicle Queue, LMAX Disruptor), pub/sub patterns, guaranteed delivery, and topic hierarchies
   - `PubSub`, `GuaranteedDelivery`, `TopicHierarchy`, `Aeron`, `ZeroMQ`, `Kafka`, `Solace`, `ChronicleQueue`, `LMAXDisruptor`

6. [API Integrations](06_API-Integrations.md) — REST, WebSocket, and gRPC integration patterns; Bloomberg BLPAPI (B-PIPE, Desktop API, EMSX); Refinitiv/LSEG real-time APIs (Elektron, RDP); and other vendor data APIs
   - `BLPAPI`, `BPIPE`, `EMSX`, `WebSocketAPI`, `gRPC`, `ElektronSDK`, `RefinitivDataPlatform`, `RESTEndpoint`

7. [Drop Copy and Trade Reporting](07_Drop-Copy-And-Trade-Reporting.md) — Drop copy sessions for independent execution monitoring, and regulatory trade reporting (TRACE, CAT, MiFID II APA/ARM, FpML, ISO 20022)
   - `DropCopy`, `ExecutionReport`, `TradeCaptureReport`, `TRACE`, `CAT`, `APA`, `ARM`, `FpML`

8. [SWIFT Messaging](08_SWIFT-Messaging.md) — MT message categories (securities settlement MT5xx, payments MT1xx/2xx, treasury MT3xx), ISO 20022 MX migration, and SWIFT infrastructure (SWIFTNet, Alliance, gpi)
   - `MT540`, `MT535`, `MT103`, `MT300`, `MX_sese023`, `MX_pacs008`, `ISO20022`, `SWIFTNet`, `UETR`

9. [Data Feeds and Vendors](09_Data-Feeds-And-Vendors.md) — Major data vendors (Bloomberg, Refinitiv/LSEG, ICE, FactSet, S&P), specialized providers, and data quality management (symbology mapping, corporate actions, entitlements)
   - `BloombergTerminal`, `BPIPE`, `ElektronFeed`, `ICEConsolidatedFeed`, `SymbologyMapping`, `ReferenceDataMastering`, `EntitlementManagement`

10. [Straight Through Processing](10_Straight-Through-Processing.md) — End-to-end trade automation from execution through settlement: trade capture, confirmation/matching (DTCC CTM), allocation, clearing (CCP), settlement (CSD), and STP rate targets
    - `STPWorkflow`, `TradeConfirmation`, `DTCC_CTM`, `SettlementInstruction`, `SSI`, `CCP`, `CSD`, `STPRate`

11. [Gateway and Adapter Architecture](11_Gateway-And-Adapter-Architecture.md) — Gateway/adapter abstraction layer, protocol translation, DMA vs. sponsored access, broker adapters for algo routing/SOR, feed handler architecture (line arbitration, book building), and multi-venue connectivity management
    - `ExchangeGateway`, `BrokerAdapter`, `ProtocolTranslation`, `SymbolMapping`, `OrderIdMapping`, `FeedHandler`, `LineArbitrator`, `BookBuilder`, `CircuitBreaker`
