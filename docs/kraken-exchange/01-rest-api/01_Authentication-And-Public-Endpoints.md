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

## Public Endpoints (Reference Data Only)

All public endpoints accept **GET** (POST also accepted). No authentication required.

> **Note**: Market data endpoints (Ticker, OHLC, Depth, Trades, Spreads) are omitted — use WebSocket v2 channels for all real-time and streaming market data.

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

---

## WebSocket Token

`POST /0/private/GetWebSocketsToken`

**Required before any authenticated WebSocket connection.** Returns a short-lived token (~15 min) for WebSocket v2 private channels and trading.

```json
{
  "error": [],
  "result": {
    "token": "1Dwc4lzSwNWOAwkMdqhssNNFhs1ed606d1WcF3XfEMw",
    "expires": 900
  }
}
```

The token must be refreshed periodically. The WebSocket connection itself does not expire, but reconnections require a fresh token.

---

## Asset Naming Conventions

- Legacy crypto names use `X` prefix: `XXBT` (Bitcoin), `XETH` (Ether)
- Legacy fiat names use `Z` prefix: `ZUSD`, `ZEUR`
- Newer assets have no prefix: `SOL`, `DOT`, `AVAX`
- Pairs combine these: `XXBTZUSD` (canonical), `XBTUSD` (altname)
- WebSocket v2 uses cleaner names: `BTC/USD`

Use the `AssetPairs` endpoint to get the full name mapping.
