## 10. Drop Copy and Order Audit Trails

### 10.1 Drop Copy

A drop copy is a real-time, read-only copy of all execution reports sent to a secondary FIX session. Used for:
- Independent risk monitoring
- Compliance surveillance
- Middle/back office reconciliation
- Disaster recovery

Architecture:

```
Trader -> OMS -> Venue
                   |
                   +---> Drop Copy Session -> Risk System
                   +---> Drop Copy Session -> Compliance System
                   +---> Drop Copy Session -> Middle Office
```

Drop copy implementation:
- Separate FIX session with its own SenderCompID/TargetCompID
- Receives all ExecutionReport (8) messages in real time
- May also receive OrderCancelReject (9) messages
- Must not send orders (read-only session)
- Must handle gap-fill and retransmission independently
- Some venues provide drop copy as a separate service (e.g., CME iLink drop copy)

FIX tags relevant to drop copy:

| Field | FIX Tag | Description |
|-------|---------|-------------|
| CopyMsgIndicator | 797 | `Y` indicates this is a drop copy message |
| SecondaryExecID | 527 | Secondary execution ID for cross-referencing |

### 10.2 Order Audit Trail

Regulatory requirements mandate comprehensive order audit trails:

#### SEC Rule 17a-25 / CAT (Consolidated Audit Trail)

The CAT NMS Plan requires reporting of:
- Order receipt or origination
- Order routing
- Order modification (cancel/replace)
- Order cancellation
- Order execution

CAT reporting fields:
| Field | Description |
|-------|-------------|
| senderIMID | Sender's Industry Member ID |
| routedOrderID | Unique routed order identifier |
| symbol | Security symbol |
| eventTimestamp | Timestamp in nanosecond precision |
| side | Buy/Sell/Short/ShortExempt |
| price | Order price |
| quantity | Order quantity |
| orderType | Market/Limit/Stop/etc. |
| timeInForce | TIF code |
| tradingSession | Regular/PreMarket/PostMarket |
| handlingInstructions | Algo, DMA, care, etc. |
| routeRejectedFlag | Whether the route was rejected |
| firmDesignatedID | Customer account identifier |

#### OATS (Order Audit Trail System) -- Replaced by CAT

Legacy FINRA system, now superseded by CAT. Documented here for historical context.

#### MiFID II (European Markets)

Transaction reporting requirements under MiFID II RTS 25:
- Timestamps must have microsecond precision for high-frequency systems
- Client identification (LEI, national ID)
- Decision maker identification (trader ID)
- Algo identification (algo ID tag)
- Short selling flag
- Waiver indicators for dark pool trades

### 10.3 Internal Audit Trail

Beyond regulatory requirements, the OMS should maintain an internal audit trail with:

| Event | Data Captured |
|-------|---------------|
| Order created | Full order snapshot, user, timestamp, source system |
| Order validated | Validation results (pass/fail), which checks ran |
| Order routed | Destination, routing decision rationale |
| Order acknowledged | Venue order ID, venue timestamp |
| Fill received | Fill details, venue, liquidity indicator |
| Order amended | Previous values, new values, user, reason |
| Order cancelled | Cancellation source (user, system, venue), reason |
| Order rejected | Rejection reason, rejecting entity |
| State transition | Previous state, new state, triggering event |
| Allocation | Post-trade allocation details |

Implementation requirements:
- Append-only storage (immutable audit log)
- Cryptographic chaining or checksums to detect tampering
- Minimum 7-year retention (SEC), 5-year retention (MiFID II)
- Microsecond-precision timestamps, synchronized via PTP or NTP
- Correlation IDs linking related events across systems

---

## 11. Care vs DMA Orders

### 11.1 Care Orders

A care order is given to a broker or sales trader who uses discretion to work the order. The broker "takes care" of the order.

Workflow:
```
Portfolio Manager                  Sales Trader / Broker
      |                                    |
      |--- "Buy 50k AAPL around here" --->|
      |    (phone, chat, or staged order)  |
      |                                    |
      |    [Broker works the order using   |
      |     their judgment, algo, or       |
      |     manual execution]              |
      |                                    |
      |<-- Fill reports over time ---------|
      |                                    |
      |<-- "Done, avg 185.23" ------------|
```

FIX representation:

| Field | FIX Tag | Value |
|-------|---------|-------|
| HandlInst | 21 | `3` (Manual) or `2` (Automated, broker can intervene) |
| ExecInst | 18 | `1` (Not Held) |

Care order characteristics:
- The broker has discretion over timing, price, venue, and execution method.
- The broker is "not held" to a specific price or time benchmark.
- Common for large institutional orders where information leakage is a concern.
- The broker may use algorithms, work the order on the phone, or cross it internally.
- Commissions are typically higher to compensate for the broker's service.
- The OMS tracks the parent care order and receives fill reports but does not control child order generation.

### 11.2 DMA Orders

Direct Market Access orders go directly to the venue without broker intermediation.

| Field | FIX Tag | Value |
|-------|---------|-------|
| HandlInst | 21 | `1` (Automated execution, no broker intervention) |

DMA characteristics:
- The buy-side firm controls routing, timing, and price.
- The firm's OMS or EMS generates and routes orders directly to venues.
- Lower commission costs (execution-only, no advisory service).
- The firm is responsible for all pre-trade risk controls (SEC 15c3-5).
- Requires sponsored access agreement with the broker providing market access.
- Lower latency since there is no broker intermediation.

### 11.3 Sponsored Access vs. Direct Access

| Model | Description |
|-------|-------------|
| **Sponsored access** | The buy-side connects through the broker's infrastructure. The broker's MPID is on the order. Broker provides pre-trade risk controls. |
| **Direct access (naked)** | Largely prohibited after SEC 15c3-5. The buy-side connected directly to the exchange with minimal broker oversight. |
| **Co-located DMA** | The buy-side's trading engine runs in the exchange's co-location facility, connected through the broker's gateway. |

### 11.4 Hybrid Workflows

In practice, many orders start as care and transition:

1. PM creates a care order in the OMS.
2. Trader receives the order on the blotter.
3. Trader decides to work it via a broker algo (semi-DMA).
4. Or trader sends it DMA to a specific venue.
5. The OMS tracks both the parent care order and the child DMA/algo orders.
