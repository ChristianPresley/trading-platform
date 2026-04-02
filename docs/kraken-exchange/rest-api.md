# Kraken REST API Reference

## Base URLs

| Environment | URL |
|-------------|-----|
| **Production (Spot)** | `https://api.kraken.com` |
| **Futures** | `https://futures.kraken.com` |
| **Futures Demo** | `https://demo-futures.kraken.com` |

All spot endpoint paths are prefixed with `/0/` (current version). There is **no public sandbox/testnet** for the spot API — use the `validate` parameter on order endpoints for dry-run testing.

---

## Authentication

### API Key Generation

Keys are created in the Kraken web UI under **Settings > API**. Each key consists of:

- **API Key** — public identifier
- **API Secret** — private key (Base64-encoded)

### Key Permissions (granular)

- Query Funds
- Query Open Orders & Trades
- Query Closed Orders & Trades
- Modify Orders
- Cancel/Close Orders
- Create & Modify Orders
- Query Ledger Entries
- Export Data
- Access WebSockets API

Keys can be restricted by **IP whitelist** and optional **nonce window**.

### Request Signing (Private Endpoints)

Every private request requires:

| Component | Description |
|-----------|-------------|
| `API-Key` | HTTP header — your public API key |
| `API-Sign` | HTTP header — HMAC-SHA512 signature |
| `nonce` | POST body parameter — strictly increasing unsigned 64-bit integer |

**Signature algorithm:**

```
1. sha256_hash = SHA256(nonce + urlencoded_post_data)
2. hmac = HMAC-SHA512(Base64Decode(API_Secret), URI_path + sha256_hash)
3. API-Sign = Base64Encode(hmac)
```

Where `URI_path` is the full path, e.g., `/0/private/Balance`.

**Content-Type**: All POST requests use `application/x-www-form-urlencoded`.

**Optional `otp` parameter**: Pass one-time password if 2FA is enabled on the API key.

**Nonce management**: Nonces must be strictly increasing. Use separate API keys for concurrent clients, or coordinate nonce generation. A nonce window can be configured in key settings.

---

## Public Endpoints

All public endpoints accept **GET** (POST also accepted). No authentication required.

### Server Time

`GET /0/public/Time`

```json
{
  "error": [],
  "result": {
    "unixtime": 1688669448,
    "rfc1123": "Thu, 06 Jul 23 17:30:48 +0000"
  }
}
```

### System Status

`GET /0/public/SystemStatus`

Status values: `online`, `maintenance`, `cancel_only`, `post_only`.

```json
{
  "error": [],
  "result": {
    "status": "online",
    "timestamp": "2023-07-06T17:30:48Z"
  }
}
```

### Asset Info

`GET /0/public/Assets`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `asset` | No | Comma-delimited list (e.g., `XBT,ETH`) |
| `aclass` | No | Asset class, default `currency` |

Response includes per asset: `aclass`, `altname`, `decimals`, `display_decimals`, `collateral_value`, `status`.

### Tradable Asset Pairs

`GET /0/public/AssetPairs`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `pair` | No | Comma-delimited list (e.g., `XXBTZUSD,XETHZUSD`) |
| `info` | No | `info` (default/all), `leverage`, `margin`, `fees` |

Response includes per pair: `altname`, `wsname`, `base`, `quote`, `pair_decimals`, `lot_decimals`, `leverage_buy`, `leverage_sell`, `fees` (volume/percent arrays), `fees_maker`, `ordermin`, `costmin`, `tick_size`, `status`.

### Ticker Information

`GET /0/public/Ticker`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `pair` | **Yes** | Comma-delimited list of pairs |

Response per pair:

| Field | Description |
|-------|-------------|
| `a` | Ask — [price, whole lot volume, lot volume] |
| `b` | Bid — [price, whole lot volume, lot volume] |
| `c` | Last trade — [price, lot volume] |
| `v` | Volume — [today, last 24 hours] |
| `p` | VWAP — [today, last 24 hours] |
| `t` | Trade count — [today, last 24 hours] |
| `l` | Low — [today, last 24 hours] |
| `h` | High — [today, last 24 hours] |
| `o` | Today's opening price |

### OHLC Data

`GET /0/public/OHLC`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `pair` | **Yes** | Single asset pair |
| `interval` | No | Minutes: `1` (default), `5`, `15`, `30`, `60`, `240`, `1440`, `10080`, `21600` |
| `since` | No | Return data since Unix timestamp (exclusive) |

Returns up to **720 entries**. Each entry: `[time, open, high, low, close, vwap, volume, count]`.

### Order Book (Depth)

`GET /0/public/Depth`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `pair` | **Yes** | Single asset pair |
| `count` | No | Max asks/bids: 1–500, default 100 |

Response: `asks` and `bids` arrays, each entry `[price, volume, timestamp]`.

### Recent Trades

`GET /0/public/Trades`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `pair` | **Yes** | Single asset pair |
| `since` | No | Nanosecond Unix timestamp |
| `count` | No | Number of trades (default 1000) |

Each entry: `[price, volume, time, buy/sell, market/limit, miscellaneous, trade_id]`.

### Recent Spreads

`GET /0/public/Spread`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `pair` | **Yes** | Single asset pair |
| `since` | No | Unix timestamp |

Each entry: `[time, bid, ask]`.

---

## Private Endpoints — Account Data

All private endpoints use **POST** with authentication headers. `nonce` is always required.

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

## Trading Endpoints

### Add Order

`POST /0/private/AddOrder`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `pair` | **Yes** | Asset pair |
| `type` | **Yes** | `buy` or `sell` |
| `ordertype` | **Yes** | See order types table below |
| `volume` | Conditional | Volume in base currency (can omit for market buy if `cost` specified) |
| `price` | Conditional | Depends on order type |
| `price2` | No | Secondary price (depends on order type) |
| `trigger` | No | `last` (default) or `index` |
| `leverage` | No | e.g., `2:1`, `3:1`, `5:1`; `none` for no leverage |
| `reduce_only` | No | Boolean |
| `stptype` | No | Self-trade prevention: `cancel-newest` (default), `cancel-oldest`, `cancel-both` |
| `oflags` | No | Comma-delimited: `post`, `fcib`, `fciq`, `nompp`, `viqc` |
| `timeinforce` | No | `GTC` (default), `IOC`, `GTD` |
| `starttm` | No | Scheduled start time |
| `expiretm` | No | Expiration time |
| `close[ordertype]` | No | Conditional close order type |
| `close[price]` | No | Conditional close price |
| `deadline` | No | RFC3339 — reject if not processed by this time |
| `validate` | No | Boolean — validate only, do not submit |
| `cost` | No | Total cost for market buy (instead of volume) |
| `displayvol` | No | Iceberg visible volume |
| `userref` | No | User reference ID (int32) |

#### Order Types

| `ordertype` | `price` meaning | `price2` meaning |
|-------------|-----------------|-------------------|
| `market` | n/a | n/a |
| `limit` | Limit price | n/a |
| `stop-loss` | Stop price | n/a |
| `take-profit` | Take-profit price | n/a |
| `stop-loss-limit` | Stop price | Limit price |
| `take-profit-limit` | Take-profit trigger | Limit price |
| `trailing-stop` | Trailing offset (`+100` absolute or `10%` percentage) | n/a |
| `trailing-stop-limit` | Trailing offset | Limit offset (same +/% notation) |
| `settle-position` | n/a | n/a |

#### Order Flags (`oflags`)

| Flag | Description |
|------|-------------|
| `post` | Post-only — reject if would be taker |
| `fcib` | Prefer fee in base currency |
| `fciq` | Prefer fee in quote currency |
| `nompp` | No market price protection |
| `viqc` | Volume in quote currency |

#### Response

```json
{
  "error": [],
  "result": {
    "descr": {
      "order": "buy 1.00000000 XBTUSD @ limit 45000.0",
      "close": ""
    },
    "txid": ["OABC12-DEFGH-IJKLMN"]
  }
}
```

### Add Order Batch

`POST /0/private/AddOrderBatch`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `pair` | **Yes** | Single asset pair (all orders must share it) |
| `orders` | **Yes** | JSON array of order objects (max **15**) |
| `deadline` | No | RFC3339 timestamp |
| `validate` | No | Boolean |

### Edit Order

`POST /0/private/EditOrder`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `txid` | **Yes** | Original order txid or userref |
| `pair` | **Yes** | Asset pair |
| `volume` | No | New volume |
| `price` | No | New price |
| `price2` | No | New secondary price |
| `oflags` | No | New order flags |
| `cancel_response` | No | Boolean — respond immediately on cancel leg |
| `validate` | No | Boolean |

Response: `status`, `txid` (new), `originaltxid`, `orders_cancelled`, `descr`.

### Cancel Order

`POST /0/private/CancelOrder`

- `txid` (required) — order txid or userref

Response: `count` (cancelled), `pending` (if cancellation pending).

### Cancel All Orders

`POST /0/private/CancelAll`

Response: `count`.

### Cancel All Orders After X (Dead Man's Switch)

`POST /0/private/CancelAllOrdersAfter`

- `timeout` (required) — seconds until all orders cancelled (`0` to disable)

Response: `currentTime`, `triggerTime`.

Must be called repeatedly to keep orders alive — **critical safety mechanism** for automated trading.

---

## Rate Limits

Kraken uses a **call counter** system. Each call has a cost; the counter decays over time. Exceeding the max returns `EAPI:Rate limit exceeded`.

### Account Tier Limits

| Tier | Max Counter | Decay Rate |
|------|-------------|------------|
| Starter | 15 | -0.33/sec (1 every 3s) |
| Intermediate | 20 | -0.5/sec (1 every 2s) |
| Pro | 20 | -1/sec |

### Endpoint Costs

| Category | Cost |
|----------|------|
| Public endpoints | 1 |
| Most private endpoints | 1 |
| Ledgers / QueryLedgers | 2 |
| TradesHistory | 2 |
| Order operations (AddOrder, EditOrder, CancelOrder) | 0 (separate matching engine limit) |

### Matching Engine Rate Limits (Orders)

Separate penalty system for order operations:

| Metric | Value |
|--------|-------|
| Max penalties | 60 (all tiers) |
| Penalty decay | 1/sec (Starter/Intermediate), 2.34/sec (Pro) |
| AddOrder cost | ~1 penalty |
| EditOrder cost | ~6 penalties |
| CancelOrder cost | ~8 penalties |
| Batch | Individual orders carry own penalty |

---

## Error Handling

- All responses include an `error` array — empty means success.
- HTTP status is typically **200 even for API errors** — always check `error` array.

### Common Errors

| Error | Description |
|-------|-------------|
| `EAPI:Invalid nonce` | Nonce is not increasing |
| `EAPI:Rate limit exceeded` | Call counter exceeded |
| `EOrder:Insufficient funds` | Not enough balance |
| `EGeneral:Invalid arguments` | Bad parameters |
| `EOrder:Order minimum not met` | Below minimum order size |

## Asset Naming Conventions

- Legacy crypto names use `X` prefix: `XXBT` (Bitcoin), `XETH` (Ether)
- Legacy fiat names use `Z` prefix: `ZUSD`, `ZEUR`
- Newer assets have no prefix: `SOL`, `DOT`, `AVAX`
- Pairs combine these: `XXBTZUSD` (canonical), `XBTUSD` (altname)
- WebSocket v2 uses cleaner names: `BTC/USD`

Use the `AssetPairs` endpoint to get the full name mapping.
