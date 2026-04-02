## Private Endpoints — Account Data

All private endpoints use **POST** with authentication headers. `nonce` is always required.

> **Note**: Trading endpoints (AddOrder, EditOrder, CancelOrder, CancelAll, CancelAllOrdersAfter) are omitted — use WebSocket v2 for all order operations. The dead man's switch (`cancel_all_orders_after`) is also available via WebSocket.

### Account Balance

`POST /0/private/Balance`

Response: object mapping asset names to balance strings.

```json
{"ZUSD": "1234.5678", "XXBT": "0.1234000000"}
```

### Extended Balance

`POST /0/private/BalanceEx`

Per asset returns: `balance`, `hold_trade`, `credit`, `credit_used`.

### Trade Balance

`POST /0/private/TradeBalance`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `asset` | No | Base asset for calculations, default `ZUSD` |

Response fields:

| Field | Description |
|-------|-------------|
| `eb` | Equivalent balance (total) |
| `tb` | Trade balance |
| `m` | Margin used |
| `n` | Unrealized net P/L of open positions |
| `c` | Cost basis of open positions |
| `v` | Current floating value of open positions |
| `e` | Equity (tb + n) |
| `mf` | Free margin (e - m) |
| `ml` | Margin level (e / m × 100) |

### Open Orders

`POST /0/private/OpenOrders`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `trades` | No | Include related trades (boolean) |
| `userref` | No | Filter by user reference ID |

### Closed Orders

`POST /0/private/ClosedOrders`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `trades` | No | Include related trades |
| `userref` | No | Filter by user reference |
| `start` | No | Starting timestamp or txid |
| `end` | No | Ending timestamp or txid |
| `ofs` | No | Result offset (pagination) |
| `closetime` | No | `open`, `close`, or `both` (default) |

### Query Orders

`POST /0/private/QueryOrders`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `txid` | **Yes** | Comma-delimited txids (max 50) |
| `trades` | No | Include related trades |

### Trades History

`POST /0/private/TradesHistory`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `type` | No | `all` (default), `any position`, `closed position`, `closing position`, `no position` |
| `start` / `end` | No | Time range |
| `ofs` | No | Pagination offset |

### Query Trades

`POST /0/private/QueryTrades`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `txid` | **Yes** | Comma-delimited trade txids (max 20) |

### Open Positions

`POST /0/private/OpenPositions`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `txid` | No | Filter by txids |
| `docalcs` | No | Include P/L calculations |
| `consolidation` | No | `market` to consolidate by pair |

### Ledgers

`POST /0/private/Ledgers`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `asset` | No | Comma-delimited assets, default `all` |
| `type` | No | `all`, `trade`, `deposit`, `withdrawal`, `transfer`, `margin`, `adjustment`, `rollover`, `credit`, `settled`, `staking`, `dividend`, `sale`, `nft_rebate` |
| `start` / `end` | No | Time range |
| `ofs` | No | Pagination offset |

### Query Ledgers

`POST /0/private/QueryLedgers`

- `id` (required) — comma-delimited ledger IDs (max 20)

### Trade Volume

`POST /0/private/TradeVolume`

- `pair` (optional) — comma-delimited pairs for fee info

Response: `currency`, `volume` (30-day USD), `fees` / `fees_maker` per pair with `fee`, `minfee`, `maxfee`, `nextfee`, `nextvolume`, `tiervolume`.

### Export Reports

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/0/private/AddExport` | POST | Request report (`trades` or `ledgers`) |
| `/0/private/ExportStatus` | POST | Check report status |
| `/0/private/RetrieveExport` | POST | Download report (binary zip) |
| `/0/private/RemoveExport` | POST | Cancel or delete report |

---
