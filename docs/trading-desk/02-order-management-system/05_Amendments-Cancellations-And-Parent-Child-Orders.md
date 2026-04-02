## 5. Order Amendments and Cancellations

### 5.1 Cancel Request

FIX message type: `F` (OrderCancelRequest)

| Field | FIX Tag | Description |
|-------|---------|-------------|
| OrigClOrdID | 41 | ClOrdID of the order to cancel |
| ClOrdID | 11 | New unique identifier for the cancel request |
| OrderID | 37 | Venue-assigned order ID (if available) |
| Side | 54 | Must match original order |
| Symbol | 55 | Must match original order |
| TransactTime | 60 | Timestamp of the cancel request |

Cancel outcomes:
- **Cancel accepted:** ExecutionReport with OrdStatus=4 (Cancelled), ExecType=4
- **Cancel rejected:** OrderCancelReject (MsgType=9) with CxlRejReason (102):
  - `0` = Too late to cancel
  - `1` = Unknown order
  - `2` = Broker option
  - `3` = Already pending cancel or replace
  - `99` = Other

### 5.2 Cancel/Replace Request (Order Amendment)

FIX message type: `G` (OrderCancelReplaceRequest)

| Field | FIX Tag | Description |
|-------|---------|-------------|
| OrigClOrdID | 41 | ClOrdID of the order to replace |
| ClOrdID | 11 | New unique identifier for the replacement |
| OrderQty | 38 | New quantity (can increase or decrease) |
| Price | 44 | New limit price |
| OrdType | 40 | Usually must remain the same |
| Side | 54 | Must match original (cannot flip side) |
| TimeInForce | 59 | Can be changed |

Cancel/replace semantics:
- Atomically cancels the old order and submits a new one.
- The replacement order may or may not retain time priority depending on the venue and the nature of the change:
  - Price improvement (more aggressive): retains priority on most venues.
  - Price deterioration (less aggressive): loses priority.
  - Quantity decrease: typically retains priority.
  - Quantity increase: typically loses priority.
- If the original order fills between the cancel and replace, the replace is rejected, and the OMS must reconcile.

### 5.3 Mass Cancel

Cancel all orders matching a filter criteria. Not a standard FIX message but commonly implemented as a custom message or via loops.

Common mass cancel filters:
- All orders for a symbol
- All orders for an account
- All orders on a specific venue
- All orders for a trader/desk
- All orders (emergency kill switch)

Implementation approaches:
1. **Iterative cancel:** Loop through all matching orders and send individual cancel requests. Simple but slow for large order counts.
2. **Venue mass cancel:** Some venues support mass cancel messages (e.g., CME Mass Quote Cancel). Much faster.
3. **Kill switch:** Emergency mechanism that cancels all orders and disables new order submission. Required by SEC 15c3-5.

### 5.4 Cancel-on-Disconnect (COD)

Orders are automatically cancelled when the FIX session disconnects.

| Field | FIX Tag | Value |
|-------|---------|-------|
| CancelOnDisconnect | 8013 (custom) | `Y` / `N` |

Implementation notes:
- Typically configured at the session level, not per-order.
- Most exchanges support COD as a session-level setting.
- The OMS must track which orders were submitted on COD-enabled sessions and update their state if the session drops.
- For algo orders, COD on the parent should cascade to all child orders.
- Some venues distinguish between clean disconnect (Logout) and dirty disconnect (TCP drop). COD typically applies to dirty disconnects only.

---

## 6. Parent/Child Order Relationships

### 6.1 Algorithmic Order Decomposition

A parent (algo) order is worked by an execution algorithm that spawns one or more child orders.

```
Parent Order: Buy 100,000 MSFT @ 420.00 Limit (VWAP, 09:30-16:00)
  |
  +-- Child 1: Buy 500 MSFT @ 419.85 Limit -> XNAS   [Filled 500 @ 419.82]
  +-- Child 2: Buy 300 MSFT @ 419.90 Limit -> BATS    [Filled 300 @ 419.90]
  +-- Child 3: Buy 800 MSFT @ 420.00 Limit -> ARCX    [Working]
  +-- Child 4: Buy 400 MSFT @ Midpoint Peg  -> DARK1  [Working]
  ...
  +-- Child N: (to be generated as algo progresses)
```

Key invariants:
- Sum of child order quantities must not exceed parent order quantity.
- Sum of child fills rolls up to parent fills.
- Parent CumQty (14) = sum of all child CumQty values.
- Parent AvgPx (6) = quantity-weighted average of all child fill prices.
- Cancelling the parent must cancel all working children.
- Amending the parent may require amending or cancelling children.

FIX linkage fields:

| Field | FIX Tag | Description |
|-------|---------|-------------|
| ClOrdLinkID | 583 | Links related orders |
| ParentOrderID | (custom) | OMS-internal parent reference |
| ChildOrderCount | (custom) | Number of active children |

### 6.2 Bracket Orders

A bracket order consists of a primary order with two contingent orders (take-profit and stop-loss) that activate when the primary fills.

```
Primary:     Buy 1,000 AAPL @ 185.00 Limit
Take-Profit: Sell 1,000 AAPL @ 195.00 Limit   (activates on primary fill)
Stop-Loss:   Sell 1,000 AAPL @ 180.00 Stop     (activates on primary fill)
```

The take-profit and stop-loss form an OCO pair: when one fills, the other is cancelled.

### 6.3 OCO (One-Cancels-Other) Orders

Two or more orders linked such that when one fills (or partially fills), the other(s) are automatically cancelled.

| Field | FIX Tag | Description |
|-------|---------|-------------|
| ContingencyType | 1385 | `1` (OCO) |
| ClOrdLinkID | 583 | Shared link ID across OCO group |

Implementation notes:
- OCO cancellation should be immediate upon fill of the sibling.
- Partial fill handling: if one side partially fills, should the OCO sibling be reduced proportionally or cancelled entirely? This must be configurable.
- Race condition: both sides could theoretically fill simultaneously on different venues. The OMS must handle this gracefully (potentially allowing both fills and flagging for manual review).

### 6.4 Contingent Orders (If-Then)

A contingent order becomes active only when a specified condition is met.

Common contingency types:
| Type | Description |
|------|-------------|
| **If-touched** | Activate when a price level is touched |
| **If-done** | Activate when a linked order fills |
| **If-filled** | Synonym for if-done |
| **Conditional on market data** | Activate when a market data condition is met (e.g., spread narrows) |

Implementation notes:
- The OMS must maintain a contingency evaluation engine that monitors relevant triggers.
- Pending contingent orders exist in a "Staged" or "Held" state until their condition triggers.
- Conditions may be complex: composite conditions involving multiple instruments, spreads, or portfolio-level metrics.

### 6.5 Multi-Leg / List Orders

Multiple orders submitted as a group, potentially with inter-order dependencies.

FIX message type: `E` (NewOrderList)

| Field | FIX Tag | Description |
|-------|---------|-------------|
| ListID | 66 | Unique list identifier |
| TotNoOrders | 68 | Total number of orders in the list |
| ListSeqNo | 67 | Sequence number within the list |
| BidType | 394 | `1` (NonDisclosed), `2` (Disclosed), `3` (NoBiddingProcess) |

Used for:
- Program trading (basket orders)
- Portfolio rebalances
- Pairs/spread trades
