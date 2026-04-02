## Direct Market Access (DMA)

### 4.1 Overview

DMA allows buy-side firms to send orders directly to exchange matching engines using the broker's market participant ID (MPID), while maintaining the broker's pre-trade risk controls.

### 4.2 Types of DMA

**Sponsored Access**:
- The client's order flow passes through the broker's infrastructure (risk checks, compliance filters) before reaching the exchange
- Latency: 50-200 microseconds added by broker's risk gateway
- The broker maintains pre-trade risk controls: credit limits, fat-finger checks, position limits, restricted list checks
- Most common form of DMA

**Naked / Unfiltered Access** (largely prohibited post-2010 SEC Rule 15c3-5):
- Historically, the client's orders bypassed the broker's risk controls entirely
- SEC Rule 15c3-5 (Market Access Rule, November 2010) requires broker-dealers to implement risk controls and supervisory procedures for all market access
- "Naked access" is effectively banned in US markets
- Some implementations now use FPGA-based or hardware-accelerated risk checks that add minimal latency (single-digit microseconds) while satisfying the regulatory requirement

**Co-Location**:
- The client's trading servers are physically located in the same data center as the exchange's matching engine
- Major co-location facilities: Mahwah, NJ (NYSE), Carteret, NJ (NASDAQ), Secaucus, NJ (BATS/Cboe)
- Latency advantage: sub-10 microsecond round-trip to the matching engine
- Equalizing measures: some exchanges (e.g., IEX) intentionally add latency to reduce co-location advantages

**Proximity Hosting**:
- Servers located in a data center near (but not in) the exchange's co-location facility
- Slightly higher latency than co-location (10-100 microseconds) but lower cost
- Connected via dedicated cross-connects or dark fiber

### 4.3 DMA Risk Controls

Required under SEC Rule 15c3-5 and MiFID II:

| Control | Description |
|---------|-------------|
| Credit/Capital Limits | Maximum notional exposure per account, per symbol, per day |
| Fat-Finger Checks | Maximum single order size (shares and notional), maximum price deviation from reference |
| Rate Limits | Maximum orders per second, maximum messages per second |
| Position Limits | Maximum net position per symbol |
| Restricted List | Block orders in restricted securities (insider trading compliance) |
| Duplicates | Detect and reject duplicate orders |
| Price Collars | Reject orders with limit prices far from NBBO |
| Kill Switch | Ability to cancel all open orders and block new orders immediately |

### 4.4 DMA Order Flow

```
Client OMS -> FIX Connection -> Broker Risk Gateway -> Exchange Matching Engine
                                      |
                                 Pre-trade risk checks
                                 (credit, fat-finger, position,
                                  restricted list, rate limit)
```

Latency budget (co-located):
- Client OMS to broker gateway: 5-20 microseconds
- Broker risk check: 1-10 microseconds (hardware-accelerated)
- Broker gateway to exchange: 1-5 microseconds
- Exchange matching: 10-50 microseconds
- Total tick-to-trade: 20-100 microseconds
