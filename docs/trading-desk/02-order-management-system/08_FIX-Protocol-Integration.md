## 9. FIX Protocol Integration

### 9.1 FIX Versions

| Version | Status | Key Differences |
|---------|--------|-----------------|
| **FIX 4.2** | Legacy, still widely used | Mature, well-understood. Limited multi-leg support. |
| **FIX 4.4** | Most common in production | Added multi-leg instruments, improved party identification, position maintenance. |
| **FIX 5.0 (FIXT 1.1)** | Current standard | Separates session (FIXT) and application layers. Adds pre-trade risk, algo order support. |
| **FIX 5.0 SP2** | Latest service pack | Extended party information, better derivatives support. |

### 9.2 Session Management

FIX sessions use the FIXT (or FIX 4.x session) layer for transport reliability.

#### Session Establishment

```
Initiator                          Acceptor
    |                                  |
    |--- Logon (MsgType=A) ---------->|
    |    HeartBtInt=30                 |
    |    ResetSeqNumFlag=Y (optional) |
    |                                  |
    |<-- Logon (MsgType=A) -----------|
    |                                  |
    |<-> Heartbeat (MsgType=0) <----->|  (every HeartBtInt seconds)
    |                                  |
```

Key session fields:

| Field | FIX Tag | Description |
|-------|---------|-------------|
| SenderCompID | 49 | Sender's firm identifier |
| TargetCompID | 56 | Receiver's firm identifier |
| SenderSubID | 50 | Trader/desk identifier |
| MsgSeqNum | 34 | Message sequence number |
| SendingTime | 52 | UTC timestamp |
| HeartBtInt | 108 | Heartbeat interval in seconds |
| EncryptMethod | 98 | `0` (None), `1`-`6` (various encryption) |
| ResetSeqNumFlag | 141 | Reset sequence numbers on logon |
| Username | 553 | Authentication username |
| Password | 554 | Authentication password |

#### Sequence Number Management

- Each side maintains independent outgoing sequence numbers.
- If a gap is detected, the receiver sends a ResendRequest (MsgType=2) specifying the range.
- The sender responds with SequenceReset-GapFill (MsgType=4) for admin messages or retransmits application messages.
- PossDupFlag (43) = `Y` on retransmitted messages to prevent double-processing.
- PossResend (97) = `Y` on messages that may have been previously sent.

#### Session Recovery

```
After reconnection:
    |
    |--- Logon (A) ------------------>|
    |    MsgSeqNum=1001               |   (last sent was 1000)
    |                                  |
    |<-- Logon (A) --------------------|
    |    MsgSeqNum=2501               |   (acceptor expected 2001)
    |                                  |
    |<-- ResendRequest (2) -----------|
    |    BeginSeqNo=1001              |
    |    EndSeqNo=0 (infinity)        |
    |                                  |
    |--- SequenceReset-GapFill (4) -->|  (for admin msgs in gap)
    |--- Retransmit app msgs -------->|  (with PossDupFlag=Y)
    |                                  |
    |--- ResendRequest (2) ---------->|  (if initiator has gap too)
    |    BeginSeqNo=2001              |
    |    EndSeqNo=2500                |
    |                                  |
```

### 9.3 Core Order Messages

#### NewOrderSingle (MsgType = D)

| Field | FIX Tag | Required | Description |
|-------|---------|----------|-------------|
| ClOrdID | 11 | Y | Client-assigned unique order ID |
| Account | 1 | N | Trading account |
| HandlInst | 21 | Y | `1` Auto-private, `2` Auto-public, `3` Manual |
| Symbol | 55 | Y | Instrument identifier |
| Side | 54 | Y | `1` Buy, `2` Sell, `5` Sell Short, `6` Sell Short Exempt |
| TransactTime | 60 | Y | Order creation timestamp (UTC) |
| OrdType | 40 | Y | See order types section |
| OrderQty | 38 | Y | Order quantity |
| Price | 44 | C | Required for limit orders |
| StopPx | 99 | C | Required for stop orders |
| TimeInForce | 59 | N | Default is Day |
| ExDestination | 100 | N | Target venue |
| MinQty | 110 | N | Minimum fill quantity |
| MaxFloor | 111 | N | Display quantity (iceberg) |
| ExecInst | 18 | N | Execution instructions |
| Currency | 15 | N | Order currency |
| SecurityID | 48 | N | Alternative security identifier |
| SecurityIDSource | 22 | N | Source of SecurityID |
| Text | 58 | N | Free-form text |
| TargetStrategy | 847 | N | Algo strategy code |

#### ExecutionReport (MsgType = 8)

The primary response message for all order events.

| Field | FIX Tag | Required | Description |
|-------|---------|----------|-------------|
| OrderID | 37 | Y | Venue-assigned order ID |
| ClOrdID | 11 | Y | Client order ID from the request |
| OrigClOrdID | 41 | C | For cancel/replace responses |
| ExecID | 17 | Y | Unique execution report ID |
| ExecType | 150 | Y | `0` New, `1` PartialFill (FIX4.2), `4` Cancelled, `5` Replaced, `8` Rejected, `F` Trade, `C` Expired |
| OrdStatus | 39 | Y | Current order status |
| Side | 54 | Y | Order side |
| LeavesQty | 151 | Y | Remaining quantity |
| CumQty | 14 | Y | Total filled quantity |
| AvgPx | 6 | Y | Average fill price |
| LastQty | 32 | C | Quantity of last fill (if ExecType=Trade) |
| LastPx | 31 | C | Price of last fill |
| LastMkt | 30 | N | Execution venue |
| Text | 58 | N | Free text (reject reasons, etc.) |
| OrdRejReason | 103 | C | Reason code when ExecType=Rejected |
| ExecRestatementReason | 378 | C | Reason for unsolicited state change |

ExecType values (FIX 4.4+):

| ExecType | Value | Meaning |
|----------|-------|---------|
| New | `0` | Order accepted |
| Trade | `F` | Fill or partial fill |
| DoneForDay | `3` | Not working for rest of day |
| Cancelled | `4` | Order cancelled |
| Replaced | `5` | Order replaced |
| PendingCancel | `6` | Cancel request received |
| Rejected | `8` | Order rejected |
| Suspended | `9` | Order suspended |
| PendingNew | `A` | Order received, not yet accepted |
| Expired | `C` | Order expired |
| PendingReplace | `E` | Replace request received |
| TradeCorrect | `G` | Trade correction (bust/correct) |
| OrderStatus | `I` | Status request response |

#### OrderCancelRequest (MsgType = F)

| Field | FIX Tag | Required |
|-------|---------|----------|
| OrigClOrdID | 41 | Y |
| ClOrdID | 11 | Y |
| Side | 54 | Y |
| Symbol | 55 | Y |
| TransactTime | 60 | Y |
| OrderQty | 38 | Y |

#### OrderCancelReplaceRequest (MsgType = G)

Same as NewOrderSingle, plus:

| Field | FIX Tag | Required |
|-------|---------|----------|
| OrigClOrdID | 41 | Y |

All order fields must be resent, not just the changed ones.

#### OrderCancelReject (MsgType = 9)

| Field | FIX Tag | Description |
|-------|---------|-------------|
| OrderID | 37 | Venue order ID |
| ClOrdID | 11 | ClOrdID from the cancel/replace request |
| OrigClOrdID | 41 | Original order's ClOrdID |
| OrdStatus | 39 | Current status of the order |
| CxlRejResponseTo | 434 | `1` (Cancel), `2` (Cancel/Replace) |
| CxlRejReason | 102 | `0` TooLate, `1` Unknown, `2` BrokerOption, `3` AlreadyPending, `99` Other |
| Text | 58 | Human-readable reason |

### 9.4 Party Identification

FIX uses the Parties repeating group for multi-party identification:

| Field | FIX Tag | Description |
|-------|---------|-------------|
| NoPartyIDs | 453 | Number of party entries |
| PartyID | 448 | Party identifier value |
| PartyIDSource | 447 | `B` (BIC), `C` (Proprietary), `D` (ISO Country Code) |
| PartyRole | 452 | `1` (Executing Firm), `3` (Client ID), `4` (Investor ID), `7` (Entering Firm), `11` (Order Origination Trader), `12` (Executing Trader), `13` (Order Origination Firm), `36` (Entering Trader) |
| PartySubID | 523 | Sub-identifier |

### 9.5 Algo Order Parameters in FIX

Standard strategy parameters (FIX 5.0):

| Field | FIX Tag | Description |
|-------|---------|-------------|
| TargetStrategy | 847 | Strategy code (e.g., `1000` = VWAP) |
| TargetStrategyParameters | 848 | Algo parameters string |
| NoStrategyParameters | 957 | Number of strategy parameter entries |
| StrategyParameterName | 958 | Parameter name (e.g., `StartTime`) |
| StrategyParameterType | 959 | Data type |
| StrategyParameterValue | 960 | Parameter value |

Common FIXatdl parameters (FIX Algorithmic Trading Definition Language):

```xml
<Strategy name="VWAP" fixTag="847" uiRep="VWAP">
  <Parameter name="StartTime" fixTag="958" use="required" type="UTCTimestamp"/>
  <Parameter name="EndTime" fixTag="958" use="required" type="UTCTimestamp"/>
  <Parameter name="MaxPctVolume" fixTag="958" use="optional" type="Percentage"/>
  <Parameter name="Urgency" fixTag="958" use="optional" type="Int" minValue="1" maxValue="5"/>
  <Parameter name="WouldStyle" fixTag="958" use="optional" type="String" enumValues="Passive|Neutral|Aggressive"/>
</Strategy>
```
