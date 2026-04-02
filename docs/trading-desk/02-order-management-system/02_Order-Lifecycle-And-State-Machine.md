## 2. Order Lifecycle and State Machine

### 2.1 FIX-Standard Order States

The canonical order states, based on FIX protocol OrdStatus (tag 39):

```
                    +-----------+
                    | PendingNew|  (OrdStatus = A)
                    +-----+-----+
                          |
                    +-----v-----+
               +--->|    New     |  (OrdStatus = 0)
               |    +-----+-----+
               |          |
               |    +-----v-----------+
               |    | PartiallyFilled |  (OrdStatus = 1)
               |    +-----+-----------+
               |          |
               |    +-----v-----+
               |    |  Filled   |  (OrdStatus = 2) [Terminal]
               |    +-----------+
               |
  +------------+----+
  | PendingCancel   |  (OrdStatus = 6)
  +--------+--------+
           |
  +--------v--------+
  |    Cancelled     |  (OrdStatus = 4) [Terminal]
  +-----------------+

  +------------------+
  | PendingReplace   |  (OrdStatus = E)
  +--------+---------+
           |
  +--------v--------+
  |    Replaced      |  (OrdStatus = 5)
  +-----------------+
           |
     (new order version created, old version -> Cancelled)

  +-----------+
  | Rejected  |  (OrdStatus = 8) [Terminal]
  +-----------+

  +-----------+
  | Expired   |  (OrdStatus = C) [Terminal]
  +-----------+

  +-----------+
  | Suspended |  (OrdStatus = 9)
  +-----------+

  +-------------+
  | DoneForDay  |  (OrdStatus = 3) [Terminal for the day]
  +-------------+
```

### 2.2 State Descriptions

| State | OrdStatus (39) | Description |
|-------|---------------|-------------|
| **PendingNew** | `A` | Order has been received by the OMS but not yet acknowledged by the venue/broker. |
| **New** | `0` | Order acknowledged and working on the venue. |
| **PartiallyFilled** | `1` | Some quantity has been executed; remainder is still working. |
| **Filled** | `2` | Entire order quantity has been executed. Terminal state. |
| **DoneForDay** | `3` | Order is no longer working for the current session but may resume next day (e.g., GTC order). |
| **Cancelled** | `4` | Order has been successfully cancelled. Terminal state. |
| **Replaced** | `5` | Order has been modified (cancel/replace). The old version is effectively cancelled; a new version is created. In FIX, this appears as an ExecutionReport with OrdStatus=Replaced, and the new order carries a new OrderID. |
| **PendingCancel** | `6` | Cancel request sent but not yet confirmed. The order may still fill during this window. |
| **Rejected** | `8` | Order was rejected by the venue or broker. Terminal state. ExecType=8, with reject reason in OrdRejReason (103) and Text (58). |
| **Suspended** | `9` | Order is on the book but not eligible for execution (e.g., halted security, circuit breaker). |
| **PendingReplace** | `E` | Replace request sent but not yet confirmed. Original order may still fill. |
| **Expired** | `C` | Order expired per its TimeInForce instructions. Terminal state. |

### 2.3 Valid State Transitions

```
PendingNew     -> New, Rejected
New            -> PartiallyFilled, Filled, Cancelled, Replaced, Expired, Suspended, DoneForDay, PendingCancel, PendingReplace
PartiallyFilled -> PartiallyFilled (additional fills), Filled, Cancelled, Replaced, Expired, Suspended, DoneForDay, PendingCancel, PendingReplace
PendingCancel  -> Cancelled, PartiallyFilled (fill arrived before cancel), Filled (fill arrived before cancel), New (cancel rejected)
PendingReplace -> Replaced, PartiallyFilled (fill arrived before replace), Filled, New (replace rejected)
Suspended      -> New, Cancelled, Expired
DoneForDay     -> New (next session), Cancelled, Expired
Replaced       -> [Replaced creates a new order version which starts at New]
```

### 2.4 Critical Race Conditions

**Fill-before-cancel:** A cancel request is in flight when a fill arrives. The OMS must process the fill first, then either:
- If the fill is a complete fill: transition to Filled, drop the pending cancel.
- If the fill is partial: remain in PartiallyFilled, continue the cancel on the leaves quantity.

**Fill-before-replace:** Similar to above. If a fill arrives while a replace is pending:
- Process the fill.
- If the order is now fully filled, the replace is moot.
- If partially filled, the replace applies to the new leaves quantity, which may now differ from what was originally requested.

**Unsolicited cancel:** The venue cancels the order without a user request (e.g., corporate action, market close, self-trade prevention). The OMS must accept this as a valid terminal transition from any non-terminal state.

### 2.5 Internal OMS States (Beyond FIX)

Production OMSs typically extend the FIX state model with internal states:

| Internal State | Description |
|---------------|-------------|
| **Staged** | Order created in the blotter but not yet submitted. Used in care-order workflows where a PM creates an order and a trader works it. |
| **Validating** | Pre-trade compliance checks are running. |
| **RoutePending** | Order has passed validation and is queued for routing. |
| **SentToAlgo** | Order has been sent to an algorithmic execution engine. |
| **AlgoWorking** | The algo has acknowledged and is actively working the order (spawning child orders). |
| **ManualReview** | Flagged for manual review (e.g., compliance hold, unusual size). |
| **CancelPending (internal)** | Internal cancel request sent to algo engine, awaiting child order cancellations. |

### 2.6 Order Versioning

When an order is amended (cancel/replace), the OMS must maintain a version history:

```
OrderID: ORD-2024-001
  Version 1: Buy 10,000 AAPL @ 185.00 Limit  [Replaced]
  Version 2: Buy 10,000 AAPL @ 186.00 Limit  [Replaced]
  Version 3: Buy  8,000 AAPL @ 186.50 Limit  [Filled]
```

Each version retains:
- Timestamp of the amendment
- User who requested the amendment
- Previous and new values for all changed fields
- FIX ClOrdID (11), OrigClOrdID (41) linkage
