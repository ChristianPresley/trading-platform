# Query Trades Info

> Source: https://docs.kraken.com/api/docs/rest-api/get-trades-info

## Endpoint

`POST /private/QueryTrades`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/QueryTrades`

## Description

Retrieve information about specific trades/fills.

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
| `txid` | string | Yes | Comma delimited list of transaction IDs to query info about (20 maximum) |
| `trades` | boolean | No | Whether or not to include trades related to position in output Default: `False` |
| `rebase_multiplier` | string, nullable | No | Optional parameter for viewing xstocks data.  - `rebased`: Display in terms of underlying equity. - `base`: Display in terms of SPV tokens.  Enum: `['rebased', 'base']` Default: `rebased` |

## Response Fields

**HTTP 200:** Trades info retrieved.

| Field | Type | Description |
|-------|------|-------------|
| `result` | object | Trade info |
| `result.<key>` | object | Trade Info |
| `result.<key>.ordertxid` | string | Order responsible for execution of trade |
| `result.<key>.postxid` | string | Position responsible for execution of trade |
| `result.<key>.pair` | string | Asset pair |
| `result.<key>.time` | number | Unix timestamp of trade |
| `result.<key>.type` | string | Type of order (buy/sell) |
| `result.<key>.ordertype` | string | Order type |
| `result.<key>.price` | string | Average price order was executed at (quote currency) |
| `result.<key>.cost` | string | Total cost of order (quote currency) |
| `result.<key>.fee` | string | Total fee (quote currency) |
| `result.<key>.vol` | string | Volume (base currency) |
| `result.<key>.margin` | string | Initial margin (quote currency) |
| `result.<key>.leverage` | string | Amount of leverage used in trade |
| `result.<key>.misc` | string | Comma delimited list of miscellaneous info: * `closing` &mdash; Trade closes all or part of a position |
| `result.<key>.ledgers` | array | List of ledger ids for entries associated with trade |
| `result.<key>.ledgers[]` | string |  |
| `result.<key>.trade_id` | integer | Unique identifier of trade executed |
| `result.<key>.maker` | boolean | `true` if trade was executed with user as the maker, `false` if taker |
| `result.<key>.posstatus` | string | Position status (open/closed) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.<key>.cprice` | number | Average price of closed portion of position (quote currency) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.<key>.ccost` | number | Total cost of closed portion of position (quote currency) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.<key>.cfee` | number | Total fee of closed portion of position (quote currency) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.<key>.cvol` | number | Total fee of closed portion of position (quote currency) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.<key>.cmargin` | number | Total margin freed in closed portion of position (quote currency) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.<key>.net` | number | Net profit/loss of closed portion of position (quote currency, quote currency scale) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.<key>.trades` | array | List of closing trades for position (if available) <br><sub><sup>Only present if trade opened a position</sub></sup> |
| `result.<key>.trades[]` | string |  |
| `error` | array |  |
| `error[]` | array |  |

## Example Response

```json
{
  "error": [],
  "result": {
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
      "trade_id": 93748276,
      "maker": true
    },
    "TTEUX3-HDAAA-RC2RUO": {
      "ordertxid": "OH76VO-UKWAD-PSBDX6",
      "postxid": "TKH2SE-M7IF5-CFI7LT",
      "pair": "XXBTZEUR",
      "time": 1688082549.3138,
      "type": "buy",
      "ordertype": "limit",
      "price": "27732.00000",
      "cost": "0.20020",
      "fee": "0.00000",
      "vol": "0.00020000",
      "margin": "0.00000",
      "misc": "",
      "trade_id": 74625834,
      "maker": true
    }
  }
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/QueryTrades" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
