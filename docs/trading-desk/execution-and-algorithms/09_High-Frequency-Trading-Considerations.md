## High-Frequency Trading Considerations

### 8.1 Latency Measurement

**Tick-to-Trade Latency**: Total time from receiving a market data event to the resulting order reaching the exchange matching engine.

```
Tick-to-Trade = Market Data Receive
              + Market Data Parse
              + Signal/Strategy Compute
              + Order Generation
              + Risk Check
              + Network to Exchange
              + Exchange Matching Engine
```

**Competitive Latency Ranges** (as of mid-2020s):
| Component | Range |
|-----------|-------|
| Market data receive (co-located) | < 1 microsecond |
| Market data parse | 0.5 - 5 microseconds |
| Strategy compute | 1 - 50 microseconds (software) or 0.5 - 5 microseconds (FPGA) |
| Risk check | 1 - 10 microseconds |
| Network to exchange (co-located) | 1 - 5 microseconds |
| Exchange matching | 10 - 100 microseconds |
| **Total (competitive HFT)** | **< 10 microseconds (internal) + exchange** |
| **Total (typical algo desk)** | **50 - 500 microseconds + exchange** |

### 8.2 Co-Location

Physical placement of trading servers in the same data center as the exchange matching engine:

| Exchange | Co-Location Facility | Location |
|----------|---------------------|----------|
| NYSE | NYSE Data Center | Mahwah, NJ |
| NASDAQ | NASDAQ Data Center | Carteret, NJ |
| Cboe (BATS) | Cboe Data Center | Secaucus, NJ |
| CME | CME Data Center | Aurora, IL |
| LSE / Turquoise | Interxion LD4 | Basildon, UK (migrating to London) |
| Eurex / Xetra | Equinix FR2 | Frankfurt, Germany |

**Co-Location Services**:
- Cabinet/rack space with controlled power and cooling
- Direct cross-connects to exchange matching engine (copper or fiber)
- Exchange-provided market data feeds (raw/binary, lowest latency)
- Equalized cable lengths: some exchanges ensure all co-located participants have the same cable length to the matching engine

### 8.3 FPGA / Hardware Acceleration

**FPGA (Field-Programmable Gate Array)**:
- Custom hardware logic for market data parsing, signal generation, order construction, and risk checks
- Deterministic latency (no operating system jitter, no garbage collection pauses)
- Latency: sub-microsecond for market data parsing, 1-5 microseconds for full tick-to-trade
- Vendors: Xilinx (AMD), Intel (Altera), specialized by firms like Algo-Logic, Enyx, Exegy

**ASIC (Application-Specific Integrated Circuit)**:
- Purpose-built chips for specific trading functions
- Even lower latency than FPGA but no reconfigurability
- Used by the most latency-sensitive firms

### 8.4 Kernel Bypass and Network Optimization

**Kernel Bypass**:
- Standard network stacks (Linux kernel) add 10-50 microseconds of latency per packet
- Kernel bypass technologies remove the OS from the data path:
  - **Solarflare OpenOnload**: user-space TCP/UDP stack using Solarflare NICs, reduces latency to 1-5 microseconds
  - **DPDK (Data Plane Development Kit)**: Intel's user-space packet processing framework
  - **Mellanox VMA**: Verbs Messaging Accelerator for Mellanox NICs
  - **Netmap**: lightweight user-space networking
  - **ef_vi**: Solarflare's low-level API for direct NIC access (lowest latency)

**Network Interface Cards (NICs)**:
- Solarflare (AMD/Xilinx) X2522, X3522: industry standard for low-latency trading
- Mellanox ConnectX-6/7 (NVIDIA): alternative for RDMA and kernel bypass
- Hardware timestamping: NICs provide nanosecond-precision timestamps for latency measurement

**Time Synchronization**:
- PTP (Precision Time Protocol, IEEE 1588): synchronize clocks across the trading infrastructure to sub-microsecond accuracy
- GPS-synchronized clocks: provide absolute time reference
- Critical for latency measurement, regulatory timestamping (MiFID II requires microsecond-precision timestamps), and multi-venue event ordering

### 8.5 Market Data Infrastructure

**Direct Feeds**:
- Exchange-provided binary/native protocol feeds (e.g., NYSE Integrated Feed, NASDAQ TotalView-ITCH, BATS PITCH)
- Lowest latency, uncompressed, full depth of book
- Require per-exchange parsing infrastructure

**Consolidated Feeds**:
- SIP (Securities Information Processor): CTA/UTP for US equities
- Higher latency (typically 10-100 microseconds slower than direct feeds)
- Consolidated across all venues, simpler to consume
- Sufficient for non-latency-sensitive strategies

**Multicast vs. TCP**:
- Direct feeds typically delivered via UDP multicast (lowest latency, no connection overhead)
- Recovery via TCP retransmission on packet loss
