## 7. Order Book Management

### 7.1 Blotter Views

The order blotter is the trader's primary interface to the OMS. Standard blotter views:

#### Working Orders (Live Blotter)
Shows all orders in a non-terminal state.

| Column | Source | Description |
|--------|--------|-------------|
| Order ID | ClOrdID (11) | Unique order identifier |
| Account | Account (1) | Trading account |
| Symbol | Symbol (55) | Instrument identifier |
| Side | Side (54) | Buy/Sell/Short |
| Qty | OrderQty (38) | Total order quantity |
| Filled | CumQty (14) | Quantity filled so far |
| Remaining | LeavesQty (151) | Quantity still working |
| Limit | Price (44) | Limit price |
| Avg Price | AvgPx (6) | Average fill price |
| Status | OrdStatus (39) | Current order state |
| Route | ExDestination (100) | Venue or algo |
| Time | TransactTime (60) | Order entry time |
| TIF | TimeInForce (59) | Time in force |
| Trader | SenderSubID (50) | Trader who entered the order |

#### Filled Orders (Execution Blotter)
Shows all fills for the current session.

Additional columns:
| Column | Source | Description |
|--------|--------|-------------|
| Exec ID | ExecID (17) | Unique execution identifier |
| Exec Qty | LastQty (32) | Fill quantity |
| Exec Price | LastPx (31) | Fill price |
| Exec Time | TransactTime (60) | Fill timestamp |
| Exec Venue | LastMkt (30) | Venue where fill occurred |
| Liquidity | LastLiquidityInd (851) | `1` (Added), `2` (Removed), `3` (Routed), `4` (Auction) |

#### Order History / Audit Trail
Complete chronological history of all order events. Every state transition, amendment, and fill is recorded.

### 7.2 Blotter Functionality

| Feature | Description |
|---------|-------------|
| **Real-time updates** | Blotter updates in real time as execution reports arrive. Typically uses a reactive/push model (event bus, WebSocket). |
| **Filtering** | Filter by symbol, account, status, side, desk, trader, strategy, date range. |
| **Sorting** | Sort by any column, with multi-column sort support. |
| **Grouping** | Group by symbol, account, status, strategy. Show subtotals per group. |
| **Quick actions** | Right-click or button to cancel, amend, or duplicate an order. |
| **Alert/highlight rules** | Color-code rows based on conditions (e.g., red for rejected, yellow for partially filled, green for filled). |
| **Export** | Export to CSV/Excel for post-trade analysis. |
| **Linked views** | Click an order to see its execution details, child orders, allocation, audit trail. |

### 7.3 Position View

Real-time position view derived from orders and fills:

| Column | Description |
|--------|-------------|
| Symbol | Instrument |
| Net Qty | Current net position (long positive, short negative) |
| Avg Cost | Average entry cost |
| Market Price | Current market price |
| Unrealized P&L | (Market - AvgCost) x NetQty |
| Realized P&L | Sum of closed trade P&L |
| Notional | Market price x abs(NetQty) |
| % of NAV | Position as percentage of portfolio |
| Day Volume | Shares traded today |
| VWAP | Volume-weighted average price of today's executions |

### 7.4 Order Book Aggregation

For multi-venue, multi-strategy environments, the OMS must aggregate:
- Orders across all venues into a single blotter
- Fills from DMA, algo, and care order workflows
- Positions across prime broker accounts, custodians, and clearing firms
- Cross-asset exposure (equity + derivatives + FX hedges)
