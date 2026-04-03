# Get Open Orders

> Source: https://docs.kraken.com/api/docs/rest-api/get-open-orders

## Endpoint

`POST /private/OpenOrders`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/OpenOrders`

## Description

Retrieve information about currently open orders.

## Authentication

This is a private endpoint and requires authentication.

- **API Key Permissions Required:** Orders and trades - Query open orders & trades
- **Headers Required:**
  - `API-Key`: Your API key
  - `API-Sign`: Message signature using HMAC-SHA512
  - `Content-Type`: `application/x-www-form-urlencoded`

## Request Parameters

**Content-Type:** `application/x-www-form-urlencoded`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer (int64) | Yes | Nonce used in construction of `API-Sign` header |
| `trades` | boolean | No | Whether or not to include trades related to position in output Default: `False` |
| `userref` | integer (int32) | No | Restrict results to given user reference |
| `cl_ord_id` | string | No | Restrict results to given client order id |
| `rebase_multiplier` | string, nullable | No | Optional parameter for viewing xstocks data.  - `rebased`: Display in terms of underlying equity. - `base`: Display in terms of SPV tokens.  Enum: `['rebased', 'base']` Default: `rebased` |

## Response Fields

**HTTP 200:** Open orders info retrieved.

| Field | Type | Description |
|-------|------|-------------|
| `result` | object | Open Orders |
| `result.open` | object |  |
| `result.open.txid` | object | Open Order |
| `result.open.txid.refid` | string, nullable | Referral order transaction ID that created this order |
| `result.open.txid.userref` | integer, nullable | Optional numeric, client identifier associated with one or more orders. |
| `result.open.txid.cl_ord_id` | string, nullable | Optional alphanumeric, client identifier associated with the order. |
| `result.open.txid.status` | string | Status of order   * pending = order pending book entry   * open = open order   * closed = closed order   * canceled = order canceled   * expired = order expired  Enum: `['pending', 'open', 'closed', 'canceled', 'expired']` |
| `result.open.txid.opentm` | number | Unix timestamp of when order was placed |
| `result.open.txid.starttm` | number | Unix timestamp of order start time (or 0 if not set) |
| `result.open.txid.expiretm` | number | Unix timestamp of order end time (or 0 if not set) |
| `result.open.txid.descr` | object | Order description info |
| `result.open.txid.descr.pair` | string | Asset pair |
| `result.open.txid.descr.type` | string | Type of order (buy/sell) Enum: `['buy', 'sell']` |
| `result.open.txid.descr.ordertype` | string | The execution model of the order.  Enum: `['market', 'limit', 'iceberg', 'stop-loss', 'take-profit', 'stop-loss-limit', 'take-profit-limit', 'trailing-stop', 'trailing-stop-limit', 'settle-position']` |
| `result.open.txid.descr.price` | string | primary price |
| `result.open.txid.descr.price2` | string | Secondary price |
| `result.open.txid.descr.leverage` | string | Amount of leverage |
| `result.open.txid.descr.order` | string | Order description |
| `result.open.txid.descr.close` | string | Conditional close order description (if conditional close set) |
| `result.open.txid.vol` | string | Volume of order (base currency) |
| `result.open.txid.vol_exec` | string | Volume executed (base currency) |
| `result.open.txid.cost` | string | Total cost (quote currency unless) |
| `result.open.txid.fee` | string | Total fee (quote currency) |
| `result.open.txid.price` | string | Average price (quote currency) |
| `result.open.txid.stopprice` | string | Stop price (quote currency) |
| `result.open.txid.limitprice` | string | Triggered limit price (quote currency, when limit based order type triggered) |
| `result.open.txid.trigger` | string | Price signal used to trigger "stop-loss" "take-profit" "stop-loss-limit" "take-profit-limit" orders.   * `last` is the implied trigger if this field is not set.  Enum: `['last', 'index']` Default: `last` |
| `result.open.txid.margin` | boolean | Indicates if the order is funded on margin. |
| `result.open.txid.misc` | string | Comma delimited list of miscellaneous info    * `stopped` triggered by stop price   * `touched` triggered by touch price   * `liquidated` liquidation   * `partial` partial fill   * `amended` order parameters modified |
| `result.open.txid.sender_sub_id` | string, nullable | For institutional accounts, identifies underlying sub-account/trader for Self Trade Prevention (STP). |
| `result.open.txid.oflags` | string | Comma delimited list of order flags    * &bull; `post` post-only order (available when ordertype = limit)   * &bull; `fcib` prefer fee in base currency (default if selling)   * &bull; `fciq` prefer fee in quote currency (default if buying, mutually exclusive with `fcib`)   * &bull; `nompp` (DEPRECATED) — disabling Market Price Protection for market orders is no longer supported. If supplied, the flag is accepted but ignored.   * &bull; `viqc`  order volume expressed in quote currency. This option is supported only for buy market orders. Also not available on margin orders. |
| `result.open.txid.trades` | array | List of trade IDs related to order (if trades info requested and data available) |
| `result.open.txid.trades[]` | string |  |
| `error` | array |  |
| `error[]` | string | Kraken API error |

## Example Response

```json
{
  "error": [],
  "result": {
    "open": {
      "OQCLML-BW3P3-BUCMWZ": {
        "refid": "None",
        "userref": 0,
        "status": "open",
        "opentm": 1688666559.8974,
        "starttm": 0,
        "expiretm": 0,
        "descr": {
          "pair": "XBTUSD",
          "type": "buy",
          "ordertype": "limit",
          "price": "30010.0",
          "price2": "0",
          "leverage": "none",
          "order": "buy 1.25000000 XBTUSD @ limit 30010.0",
          "close": ""
        },
        "vol": "1.25000000",
        "vol_exec": "0.37500000",
        "cost": "11253.7",
        "fee": "0.00000",
        "price": "30010.0",
        "stopprice": "0.00000",
        "limitprice": "0.00000",
        "misc": "",
        "oflags": "fciq",
        "trades": [
          "TCCCTY-WE2O6-P3NB37"
        ]
      },
      "OB5VMB-B4U2U-DK2WRW": {
        "refid": "None",
        "userref": 45326,
        "status": "open",
        "opentm": 1688665899.5699,
        "starttm": 0,
        "expiretm": 0,
        "descr": {
          "pair": "XBTUSD",
          "type": "buy",
          "ordertype": "limit",
          "price": "14500.0",
          "price2": "0",
          "leverage": "5:1",
          "order": "buy 0.27500000 XBTUSD @ limit 14500.0 with 5:1 leverage",
          "close": ""
        },
        "vol": "0.27500000",
        "vol_exec": "0.00000000",
        "cost": "0.00000",
        "fee": "0.00000",
        "price": "0.00000",
        "stopprice": "0.00000",
        "limitprice": "0.00000",
        "misc": "",
        "oflags": "fciq"
      }
    }
  }
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/OpenOrders" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
