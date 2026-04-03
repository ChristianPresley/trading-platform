# Get Trades History

> Source: https://docs.kraken.com/api/docs/rest-api/get-trade-history

## Endpoint

`POST /private/TradesHistory`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/TradesHistory`

## Description

Retrieve information about trades/fills. 50 results are returned at a time, the most recent by default.

## Authentication

This is a private endpoint and requires authentication.

- **API Key Permissions Required:** Orders and trades - Query closed orders & trades
- **Headers Required:**
  - `API-Key`: Your API key
  - `API-Sign`: Message signature using HMAC-SHA512
  - `Content-Type`: `application/x-www-form-urlencoded`

## Request Parameters

**Content-Type:** `application/x-www-form-urlencoded`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer (int64) | Yes | Nonce used in construction of `API-Sign` header |
| `type` | string | No | Type of trade Enum: `['all', 'any position', 'closed position', 'closing position', 'no position']` Default: `all` |
| `trades` | boolean | No | Whether or not to include trades related to position in output Default: `False` |
| `start` | integer | No | Starting unix timestamp or trade tx ID of results (exclusive) |
| `end` | integer | No | Ending unix timestamp or trade tx ID of results (inclusive) |
| `ofs` | integer | No | Result offset for pagination |
| `without_count` | boolean | No | If true, does not retrieve count of ledger entries. Request can be noticeably faster for users with many ledger entries as this avoids an extra database query. Default: `False` |
| `consolidate_taker` | boolean | No | Whether or not to consolidate trades by individual taker trades Default: `True` |
| `ledgers` | boolean | No | Whether or not to include related ledger ids for given trade <br><sub><sup>Note that setting this to true will slow request performance</sub></sup>  Default: `False` |
| `rebase_multiplier` | string, nullable | No | Optional parameter for viewing xstocks data.  - `rebased`: Display in terms of underlying equity. - `base`: Display in terms of SPV tokens.  Enum: `['rebased', 'base']` Default: `rebased` |

## Response Fields

**HTTP 200:** Trade history retrieved.

| Field | Type | Description |
|-------|------|-------------|
| `result` | object | Trade History |
| `result.count` | integer | Amount of available trades matching criteria |
| `result.trades` | object | Trade info |
| `result.trades.txid` | object | Trade Info |
| `result.trades.txid.ordertxid` | string | Order responsible for execution of trade |
| `result.trades.txid.postxid` | string | Position responsible for execution of trade |
| `result.trades.txid.pair` | string | Asset pair |
| `result.trades.txid.time` | number | Unix timestamp of trade |
| `result.trades.txid.type` | string | Type of order (buy/sell) |
| `result.trades.txid.ordertype` | string | Order type |
| `result.trades.txid.price` | string | Average price order was executed at (quote currency) |
| `result.trades.txid.cost` | string | Total cost of order (quote currency) |
| `result.trades.txid.fee` | string | Total fee (quote currency) |
| `result.trades.txid.vol` | string | Volume (base currency) |
| `result.trades.txid.margin` | string | Initial margin (quote currency) |
| `result.trades.txid.leverage` | string | Amount of leverage used in trade |
| `result.trades.txid.misc` | string | Comma delimited list of miscellaneous info: * `closing` &mdash; Trade closes all or part of a position |
| `result.trades.txid.ledgers` | array | List of ledger ids for entries associated with trade |
| `result.trades.txid.ledgers[]` | string |  |
| `result.trades.txid.trade_id` | integer | Unique identifier of trade executed |
| `result.trades.txid.maker` | boolean | `true` if trade was executed with user as the maker, `false` if taker |
| `result.trades.txid.posstatus` | string | Position status (open/closed) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.trades.txid.cprice` | number | Average price of closed portion of position (quote currency) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.trades.txid.ccost` | number | Total cost of closed portion of position (quote currency) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.trades.txid.cfee` | number | Total fee of closed portion of position (quote currency) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.trades.txid.cvol` | number | Total fee of closed portion of position (quote currency) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.trades.txid.cmargin` | number | Total margin freed in closed portion of position (quote currency) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.trades.txid.net` | number | Net profit/loss of closed portion of position (quote currency, quote currency scale) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.trades.txid.trades` | array | List of closing trades for position (if available) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.trades.txid.trades[]` | string |  |
| `error` | array |  |
| `error[]` | string | Kraken API error |

## Example Response

```json
{
  "error": [],
  "result": {
    "trades": {
      "THVRQM-33VKH-UCI7BS": {
        "ordertxid": "OQCLML-BW3P3-BUCMWZ",
        "postxid": "TKH2SE-M7IF5-CFI7LT",
        "pair": "XXBTZUSD",
        "time": 1688667796.8802,
        "type": "buy",
        "ordertype": "limit",
        "price": "30010.00000",
        "cost": "600.20000",
        "fee": "0.00000",
        "vol": "0.02000000",
        "margin": "0.00000",
        "misc": "",
        "trade_id": 40274859,
        "maker": true
      },
      "TCWJEG-FL4SZ-3FKGH6": {
        "ordertxid": "OQCLML-BW3P3-BUCMWZ",
        "postxid": "TKH2SE-M7IF5-CFI7LT",
        "pair": "XXBTZUSD",
        "time": 1688667769.6396,
        "type": "buy",
        "ordertype": "limit",
        "price": "30010.00000",
        "cost": "300.10000",
        "fee": "0.00000",
        "vol": "0.01000000",
        "margin": "0.00000",
        "misc": "",
        "trade_id": 39482674,
        "maker": true
      }
    }
  }
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/TradesHistory" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
