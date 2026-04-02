## FIX Engines and Session Management

A **FIX engine** is a software component that manages FIX session lifecycle, message parsing, validation, sequence number management, and persistence. It is the foundational building block of any FIX-based trading system.

### Major FIX Engines

#### QuickFIX Family

| Product | Language | License | Notes |
|---------|----------|---------|-------|
| QuickFIX | C++ | Open Source (BSD-like) | The original; widely used in hedge funds and prop shops |
| QuickFIX/J | Java | Open Source | Java port; most popular open-source FIX engine |
| QuickFIX/N | C#/.NET | Open Source | .NET port; suitable for this platform |
| QuickFIX/Go | Go | Open Source | Go implementation |

QuickFIX strengths: zero cost, large community, extensive documentation, battle-tested. Weaknesses: not optimized for ultra-low-latency (microsecond) requirements; single-threaded session processing.

#### Commercial FIX Engines

| Product | Vendor | Strengths |
|---------|--------|-----------|
| **LSEG FIX Engine** (formerly Exactpro/OnixS) | LSEG | Certified with dozens of exchanges; managed connectivity service; .NET and C++ SDKs |
| **B2BITS FIX Antenna** | EPAM/B2BITS | High-performance C++ and Java; comprehensive admin tools; exchange certification support |
| **Chronicle FIX** | Chronicle Software | Ultra-low-latency Java; off-heap memory; designed for HFT |
| **Rapid Addition RA-FIX** | Rapid Addition | FPGA-accelerated FIX parsing; sub-microsecond latency |
| **Cameron FIX** | Finastra | Enterprise FIX engine with extensive routing and transformation |
| **TransFIX** | Transact Tools | .NET-native FIX engine; strong exchange certification coverage |
| **Itiviti NYFIX** | Broadridge | Managed FIX network; hub connectivity to 1,800+ counterparties |

#### Managed FIX Networks

- **Broadridge NYFIX**: Hub-and-spoke FIX connectivity network connecting buy-side to sell-side
- **TNS (Transaction Network Services)**: Managed extranet for FIX and market data
- **IPC/Connexus**: Financial extranet with managed FIX services

### Session Management Details

#### Session Configuration

A FIX session requires the following configuration:

```ini
# QuickFIX-style configuration
[SESSION]
BeginString=FIX.4.4
SenderCompID=BUYSIDE_FIRM
TargetCompID=BROKER_DMA
SocketConnectHost=fix.broker.com
SocketConnectPort=9876
HeartBtInt=30
StartTime=00:00:00
EndTime=23:59:59
ReconnectInterval=30
FileStorePath=/var/fix/store
FileLogPath=/var/fix/log
DataDictionary=FIX44.xml
ResetOnLogon=N
ResetOnLogout=N
ResetOnDisconnect=N
PersistMessages=Y
```

#### Session Lifecycle

1. **TCP Connection**: Initiator connects to acceptor on configured host:port (TLS 1.2/1.3 recommended)
2. **Logon Exchange**: Initiator sends Logon (MsgType=A) with credentials, HeartBtInt, optional ResetSeqNumFlag
3. **Sequence Synchronization**: If the acceptor detects a sequence gap, it issues a ResendRequest
4. **Steady State**: Heartbeats exchanged at HeartBtInt intervals; application messages flow
5. **Disconnection Handling**: TestRequest sent when heartbeat is overdue; if no response within HeartBtInt + "reasonable transmission time," the session is disconnected
6. **Logout**: Graceful shutdown via Logout message exchange

#### Sequence Number Management

Sequence numbers are the backbone of FIX message reliability:

- **Persistence**: Both sides must persist their outbound sequence number and the expected inbound sequence number. Storage options include flat files, databases, or memory-mapped files.
- **Gap Detection**: On Logon, if the incoming MsgSeqNum exceeds the expected value, a gap exists. The receiver sends `ResendRequest(BeginSeqNo, EndSeqNo=0)` to request all missing messages.
- **Gap Fill**: The sender retransmits missing application messages with `PossDupFlag=Y`. Administrative messages (Logon, Logout, Heartbeat, etc.) are not retransmitted; instead, a `SequenceReset-GapFill` message skips over them.
- **Hard Reset**: `SequenceReset-Reset` (GapFillFlag=N) forces sequence numbers to a new value. Used only in exceptional circumstances (e.g., disaster recovery).
- **Daily Reset**: Many counterparties agree to reset sequence numbers at a defined time (often UTC midnight or market open). This simplifies operations but requires coordinated timing.

#### Monitoring and Alerting

Production FIX sessions require:

- **Sequence number monitoring**: Alert if gaps exceed thresholds
- **Heartbeat monitoring**: Alert on missed heartbeats before disconnection
- **Message rate monitoring**: Alert on unusual throughput (both too high and too low)
- **Reject rate monitoring**: Alert on elevated Reject (35=3) or BusinessMessageReject (35=j) rates
- **Latency monitoring**: Measure time between NewOrderSingle and first ExecutionReport
