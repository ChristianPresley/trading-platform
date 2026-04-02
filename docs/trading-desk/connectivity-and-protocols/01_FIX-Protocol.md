## FIX Protocol

### Overview

The **Financial Information eXchange (FIX)** protocol is the dominant electronic messaging standard for pre-trade, trade, and post-trade communication in financial markets. Governed by FIX Trading Community (fixtrading.org), it is used by virtually every major exchange, broker, buy-side firm, and execution venue globally.

### Version History

| Version | Year | Key Additions |
|---------|------|---------------|
| FIX 4.0 | 1996 | Foundational order and execution messages |
| FIX 4.1 | 1998 | Allocation, settlement instructions |
| FIX 4.2 | 2000 | Multi-leg orders, broader market data |
| FIX 4.3 | 2002 | Cross orders, trade capture reports |
| FIX 4.4 | 2003 | Collateral management, position reports, enhanced algo trading tags |
| FIX 5.0 | 2006 | Separated transport (FIXT) from application layer; parties component block |
| FIX 5.0 SP1 | 2009 | Application-level sequencing, enhanced risk management |
| FIX 5.0 SP2 | 2011+ | Ongoing extension packs (EP); currently the dominant version for new implementations |

**FIX 4.2 and FIX 4.4** remain the most widely deployed versions across the industry due to entrenchment. New exchange integrations increasingly mandate **FIX 5.0 SP2** with relevant Extension Packs.

### Protocol Architecture

#### Session Layer (FIXT 1.1)

The session (or transport) layer handles connection lifecycle, sequencing, and reliability. Beginning with FIX 5.0, the session layer was separated into the **FIXT 1.1** specification to allow independent versioning.

**Session-level message types:**

| MsgType | Name | Purpose |
|---------|------|---------|
| `A` | Logon | Initiates a FIX session; includes SenderCompID, TargetCompID, HeartBtInt, optional encryption, optional credentials |
| `5` | Logout | Graceful session termination |
| `0` | Heartbeat | Keep-alive; sent at the agreed HeartBtInt interval (typically 30s) |
| `1` | TestRequest | Probes the counterparty when a heartbeat is overdue |
| `2` | ResendRequest | Requests retransmission of messages in a sequence range (BeginSeqNo to EndSeqNo) |
| `4` | SequenceReset | Two modes: GapFill (skip administrative messages) and Reset (hard sequence reset) |
| `3` | Reject | Session-level rejection for malformed messages |

**Session identification** is established by the tuple:

- `SenderCompID` (tag 49)
- `TargetCompID` (tag 56)
- Optionally: `SenderSubID` (tag 50), `TargetSubID` (tag 57), `SenderLocationID` (tag 142)

**Sequence number management** is fundamental to FIX reliability:

- Each side maintains an independent outbound sequence counter.
- Both sides persist expected inbound and outbound sequence numbers across disconnections.
- On reconnection, the Logon message carries `MsgSeqNum` and optionally `ResetSeqNumFlag` (tag 141).
- If a gap is detected, a `ResendRequest` is issued automatically by conforming engines.
- `PossDupFlag` (tag 43) and `PossResend` (tag 97) mark retransmitted messages.

#### Application Layer

The application layer carries the business messages. In FIX 5.0+, each message declares its own `ApplVerID` (tag 1128), allowing different application versions on the same FIXT session.

### Common Message Types

#### Order Flow

| MsgType | Name | Direction | Description |
|---------|------|-----------|-------------|
| `D` | NewOrderSingle | Buy-side to Sell-side | Submit a new order. Core tags: ClOrdID (11), Symbol (55), Side (54), OrderQty (38), OrdType (40), Price (44), TimeInForce (59), TransactTime (60) |
| `G` | OrderCancelReplaceRequest | Buy-side to Sell-side | Modify an existing order (price, quantity). References OrigClOrdID (41) |
| `F` | OrderCancelRequest | Buy-side to Sell-side | Cancel an existing order. References OrigClOrdID (41) |
| `8` | ExecutionReport | Sell-side to Buy-side | The workhorse response: acknowledgments, fills, partial fills, cancellations, rejects. ExecType (150) and OrdStatus (39) drive the state machine |
| `9` | OrderCancelReject | Sell-side to Buy-side | Reject of a cancel or cancel/replace request |
| `AB` | NewOrderMultileg | Buy-side to Sell-side | Multi-leg (spread, combo) order submission |
| `E` | NewOrderList | Buy-side to Sell-side | Basket/list order |
| `s` | NewOrderCross | Venue | Cross orders (matching internal flow) |

#### Market Data

| MsgType | Name | Description |
|---------|------|-------------|
| `V` | MarketDataRequest | Subscribe/unsubscribe to market data; specifies symbols, depth, update type (full refresh vs. incremental) |
| `W` | MarketDataSnapshotFullRefresh | Full order book snapshot or top-of-book |
| `X` | MarketDataIncrementalRefresh | Delta updates to a previously subscribed book |
| `Y` | MarketDataRequestReject | Rejection of a market data subscription |

#### Post-Trade

| MsgType | Name | Description |
|---------|------|-------------|
| `AE` | TradeCaptureReport | Reports executed trades for clearing, settlement, regulatory reporting |
| `J` | Allocation | Allocate fills across sub-accounts |
| `AK` | Confirmation | Confirms allocation to a particular account |
| `AP` | PositionReport | Current position details |

#### Reference Data and Security Definition

| MsgType | Name | Description |
|---------|------|-------------|
| `c` | SecurityDefinitionRequest | Request instrument details |
| `d` | SecurityDefinition | Response with instrument attributes |
| `e` | SecurityStatusRequest | Request trading status |
| `f` | SecurityStatus | Trading status/halts |
| `x` | SecurityListRequest | Request list of tradeable instruments |
| `y` | SecurityList | Response with instrument list |

### Key FIX Tags Reference

| Tag | Name | Typical Values |
|-----|------|----------------|
| 11 | ClOrdID | Client-assigned order identifier (unique per session or globally) |
| 37 | OrderID | Broker/exchange-assigned order identifier |
| 17 | ExecID | Unique execution identifier |
| 35 | MsgType | Message type discriminator |
| 38 | OrderQty | Order quantity |
| 39 | OrdStatus | 0=New, 1=PartiallyFilled, 2=Filled, 4=Canceled, 8=Rejected, C=Expired |
| 40 | OrdType | 1=Market, 2=Limit, 3=Stop, 4=StopLimit, K=MarketWithLeftover |
| 44 | Price | Limit price |
| 54 | Side | 1=Buy, 2=Sell, 5=SellShort, 6=SellShortExempt |
| 55 | Symbol | Ticker symbol |
| 59 | TimeInForce | 0=Day, 1=GTC, 2=AtOpen, 3=IOC, 4=FOK, 6=GTD |
| 150 | ExecType | 0=New, 4=Canceled, 5=Replace, 8=Rejected, F=Trade, H=TradeCorrect |
| 167 | SecurityType | CS (Common Stock), FUT, OPT, MLEG, etc. |
| 207 | SecurityExchange | MIC code of the destination exchange |
| 448 | PartyID | Identifies a party (firm, trader, etc.) |
| 1 | Account | Account identifier for routing and allocation |
| 6 | AvgPx | Average fill price |
| 14 | CumQty | Cumulative filled quantity |
| 151 | LeavesQty | Remaining open quantity |
| 847 | TargetStrategy | Algo strategy identifier (VWAP, TWAP, etc.) |
| 848 | TargetStrategyParameters | Algo parameter string |

### FIX Message Format (Tag=Value)

FIX messages use a flat tag=value format with SOH (0x01) delimiters:

```
8=FIX.4.4|9=176|35=D|49=SENDER|56=TARGET|34=12|52=20260401-14:30:00.000|
11=ORD0001|1=ACCT001|55=MSFT|54=1|38=1000|40=2|44=425.50|59=0|
60=20260401-14:30:00.000|10=128|
```

Key structural tags:
- **Tag 8** (`BeginString`): Protocol version, always first
- **Tag 9** (`BodyLength`): Message body length, always second
- **Tag 35** (`MsgType`): Message type discriminator, always third
- **Tag 10** (`CheckSum`): Three-character checksum, always last

### FIXT Transport Independence

FIX 5.0+ with FIXT 1.1 decouples transport from application, enabling:

- Multiple application message versions on a single session
- Alternative transports beyond classic TCP (FIX-over-TLS, FIXP binary, FIX over messaging bus)
- **FIXP** (FIX Performance Session Layer): binary session protocol designed for low-latency environments, supporting both ordered and unordered delivery
