## Private / Authenticated Channels

All private channels require the `token` in params and must connect to `wss://ws-auth.kraken.com/v2`.

### Executions (`executions`)

Unified channel combining own trades and order lifecycle events (replaces v1's separate `ownTrades` and `openOrders` channels).

```json
{
  "method": "subscribe",
  "params": {
    "channel": "executions",
    "token": "your-ws-token",
    "snap_orders": true,
    "snap_trades": true
  }
}
```

- **`snap_orders: true`**: Snapshot of all open orders on subscription.
- **`snap_trades: true`**: Snapshot of recent trade history (~last 50 trades).
- **Updates include**: order creation, status changes (pending → open → closed/canceled/expired), partial fills, full fills with execution details.
- **Fields**: `order_id`, `order_status`, `exec_type` (`new`, `filled`, `canceled`, `trade`), `side`, `symbol`, `order_type`, `limit_price`, `qty`, `filled_qty`, `avg_price`, `fee`, timestamps.

### Balances (`balances`)

Real-time balance and ledger updates.

```json
{
  "method": "subscribe",
  "params": {
    "channel": "balances",
    "token": "your-ws-token",
    "snap_balances": true
  }
}
```

- Snapshot of all asset balances on subscription.
- Updates when balances change (trades, deposits, withdrawals, staking).
- **Fields**: asset name, balance, wallets/hold amounts.

---

## WebSocket Trading

Kraken v2 WebSocket supports **full trading operations** on the authenticated endpoint — you can build a complete trading system without REST API calls for order management.

### Add Order

```json
{
  "method": "add_order",
  "params": {
    "order_type": "limit",
    "side": "buy",
    "symbol": "BTC/USD",
    "limit_price": 25000.00,
    "order_qty": 0.01,
    "token": "your-ws-token",
    "time_in_force": "GTC",
    "post_only": false,
    "reduce_only": false,
    "cl_ord_id": "my-client-id-123"
  },
  "req_id": 1
}
```

**Supported order types**: `limit`, `market`, `stop-loss`, `take-profit`, `stop-loss-limit`, `take-profit-limit`, `trailing-stop`, `trailing-stop-limit`, `settle-position`, `iceberg`.

**Key parameters**:

| Parameter | Description |
|-----------|-------------|
| `time_in_force` | `GTC` (good till cancelled), `IOC` (immediate or cancel), `GTD` (good till date) |
| `post_only` | Ensures limit order is maker only |
| `reduce_only` | Only reduce existing position |
| `cl_ord_id` | Client-assigned order ID for tracking (up to 18 chars) |
| `deadline` | RFC3339 timestamp — reject if not processed by this time (latency-sensitive strategies) |
| `conditional` | Attached stop-loss / take-profit parameters |
| `fee_preference` | Pay fee in base or quote currency |

### Cancel Order

```json
{
  "method": "cancel_order",
  "params": {
    "order_id": ["OXXXX-XXXXX-XXXXXX"],
    "token": "your-ws-token"
  },
  "req_id": 2
}
```

Can cancel by `order_id` (array) or `cl_ord_id` (client order IDs).

### Cancel All Orders

```json
{
  "method": "cancel_all",
  "params": {
    "token": "your-ws-token"
  },
  "req_id": 3
}
```

### Dead Man's Switch (Cancel All Orders After)

```json
{
  "method": "cancel_all_orders_after",
  "params": {
    "timeout": 60,
    "token": "your-ws-token"
  },
  "req_id": 4
}
```

Sets a countdown timer (seconds). If not refreshed before expiry, all open orders are cancelled. Set `timeout: 0` to disable. **Critical for automated trading** — protects against connectivity loss.

### Edit Order

```json
{
  "method": "edit_order",
  "params": {
    "order_id": "OXXXX-XXXXX-XXXXXX",
    "symbol": "BTC/USD",
    "limit_price": 25500.00,
    "order_qty": 0.02,
    "token": "your-ws-token"
  },
  "req_id": 5
}
```

Edits are **atomic** (cancel + replace under the hood, but guaranteed atomic on the matching engine).

### Batch Add Orders

```json
{
  "method": "batch_add",
  "params": {
    "symbol": "BTC/USD",
    "token": "your-ws-token",
    "orders": [
      {
        "order_type": "limit",
        "side": "buy",
        "limit_price": 24000.00,
        "order_qty": 0.01
      },
      {
        "order_type": "limit",
        "side": "buy",
        "limit_price": 23500.00,
        "order_qty": 0.01
      }
    ]
  },
  "req_id": 6
}
```

- Up to **15 orders** per batch.
- All orders must be for the **same symbol**.
- `batch_cancel` also available.
- Batch operations count as a **single rate-limit event**.

---
