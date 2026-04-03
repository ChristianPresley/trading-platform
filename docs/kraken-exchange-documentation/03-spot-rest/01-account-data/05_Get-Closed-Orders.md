# Get Closed Orders

> Source: https://docs.kraken.com/api/docs/rest-api/get-closed-orders

## Endpoint

`POST /private/ClosedOrders`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/ClosedOrders`

## Description

Retrieve information about orders that have been closed (filled or cancelled). 50 results are returned at a time, the most recent by default.

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
| `trades` | boolean | No | Whether or not to include trades related to position in output Default: `False` |
| `userref` | integer (int32) | No | Restrict results to given user reference |
| `cl_ord_id` | string | No | Restrict results to given client order id |
| `start` | integer | No | Starting unix timestamp or order tx ID of results (exclusive) |
| `end` | integer | No | Ending unix timestamp or order tx ID of results (inclusive) |
| `ofs` | integer | No | Result offset for pagination |
| `closetime` | string | No | Which time to use to search Enum: `['open', 'close', 'both']` Default: `both` |
| `consolidate_taker` | boolean | No | Whether or not to consolidate trades by individual taker trades Default: `True` |
| `without_count` | boolean | No | Whether or not to include page count in result (`true` is much faster for users with many closed orders) Default: `False` |
| `rebase_multiplier` | string, nullable | No | Optional parameter for viewing xstocks data.  - `rebased`: Display in terms of underlying equity. - `base`: Display in terms of SPV tokens.  Enum: `['rebased', 'base']` Default: `rebased` |

## Response Fields

**HTTP 200:** Closed orders info retrieved.

| Field | Type | Description |
|-------|------|-------------|
| `result` | object | Closed Orders |
| `result.closed` | object |  |
| `result.closed.txid` | object | Closed Order |
| `result.closed.txid.refid` | string, nullable | Referral order transaction ID that created this order |
| `result.closed.txid.userref` | integer, nullable | Optional numeric, client identifier associated with one or more orders. |
| `result.closed.txid.cl_ord_id` | string, nullable | Optional alphanumeric, client identifier associated with the order. |
| `result.closed.txid.status` | string | Status of order   * pending = order pending book entry   * open = open order   * closed = closed order   * canceled = order canceled   * expired = order expired  Enum: `['pending', 'open', 'closed', 'canceled', 'expired']` |
| `result.closed.txid.opentm` | number | Unix timestamp of when order was placed |
| `result.closed.txid.starttm` | number | Unix timestamp of order start time (or 0 if not set) |
| `result.closed.txid.expiretm` | number | Unix timestamp of order end time (or 0 if not set) |
| `result.closed.txid.descr` | object | Order description info |
| `result.closed.txid.descr.pair` | string | Asset pair |
| `result.closed.txid.descr.type` | string | Type of order (buy/sell) Enum: `['buy', 'sell']` |
| `result.closed.txid.descr.ordertype` | string | Order type  Enum: `['market', 'limit', 'iceberg', 'stop-loss', 'take-profit', 'trailing-stop', 'stop-loss-limit', 'take-profit-limit', 'trailing-stop-limit', 'settle-position']` |
| `result.closed.txid.descr.price` | string | primary price |
| `result.closed.txid.descr.price2` | string | Secondary price |
| `result.closed.txid.descr.leverage` | string | Amount of leverage |
| `result.closed.txid.descr.order` | string | Order description |
| `result.closed.txid.descr.close` | string | Conditional close order description (if conditional close set) |
| `result.closed.txid.vol` | string | Volume of order (base currency) |
| `result.closed.txid.vol_exec` | string | Volume executed (base currency) |
| `result.closed.txid.cost` | string | Total cost (quote currency unless) |
| `result.closed.txid.fee` | string | Total fee (quote currency) |
| `result.closed.txid.price` | string | Average price (quote currency) |
| `result.closed.txid.stopprice` | string | Stop price (quote currency) |
| `result.closed.txid.limitprice` | string | Triggered limit price (quote currency, when limit based order type triggered) |
| `result.closed.txid.trigger` | string | Price signal used to trigger "stop-loss" "take-profit" "stop-loss-limit" "take-profit-limit" orders.   * `last` is the implied trigger if this field is not set.  Enum: `['last', 'index']` Default: `last` |
| `result.closed.txid.margin` | boolean | Indicates if the order is funded on margin. |
| `result.closed.txid.misc` | string | Comma delimited list of miscellaneous info:   * `stopped` triggered by stop price   * `touched` triggered by touch price   * `liquidated` liquidation   * `partial` partial fill   * `amended` order parameters modified |
| `result.closed.txid.oflags` | string | Comma delimited list of order flags:   * `post` post-only order (available when ordertype = limit)   * `fcib` prefer fee in base currency (default if selling)   * `fciq` prefer fee in quote currency (default if buying, mutually exclusive with `fcib`)   * `nompp` disable [market price protection](https://support.kraken.com/hc/en-us/articles/201648183-Market-Price-Protection) for market orders   * `viqc`  order volumes expressed in quote currency. |
| `result.closed.txid.trades` | array | List of trade IDs related to order (if trades info requested and data available) |
| `result.closed.txid.trades[]` | string |  |
| `result.closed.txid.sender_sub_id` | string, nullable | For institutional accounts, identifies underlying sub-account/trader for Self Trade Prevention (STP). |
| `result.closed.txid.closetm` | number | Unix timestamp of when order was closed |
| `result.closed.txid.reason` | string | Additional info on status (if any) |
| `result.count` | integer | Amount of available order info matching criteria |
| `error` | array |  |
| `error[]` | string | Kraken API error |

## Example Response

```json
{
  "error": [],
  "result": {
    "closed": {
      "O37652-RJWRT-IMO74O": {
        "refid": "None",
        "userref": 1,
        "status": "canceled",
        "reason": "User requested",
        "opentm": 1688148493.7708,
        "closetm": 1688148610.0482,
        "starttm": 0,
        "expiretm": 0,
        "descr": {
          "pair": "XBTGBP",
          "type": "buy",
          "ordertype": "stop-loss-limit",
          "price": "23667.0",
          "price2": "0",
          "leverage": "none",
          "order": "buy 0.00100000 XBTGBP @ limit 23667.0",
          "close": ""
        },
        "vol": "0.00100000",
        "vol_exec": "0.00000000",
        "cost": "0.00000",
        "fee": "0.00000",
        "price": "0.00000",
        "stopprice": "0.00000",
        "limitprice": "0.00000",
        "misc": "",
        "oflags": "fciq",
        "trigger": "index"
      },
      "O6YDQ5-LOMWU-37YKEE": {
        "refid": "None",
        "userref": 36493663,
        "status": "canceled",
        "reason": "User requested",
        "opentm": 1688148493.7708,
        "closetm": 1688148610.0477,
        "starttm": 0,
        "expiretm": 0,
        "descr": {
          "pair": "XBTEUR",
          "type": "buy",
          "ordertype": "take-profit-limit",
          "price": "27743.0",
          "price2": "0",
          "leverage": "none",
          "order": "buy 0.00100000 XBTEUR @ limit 27743.0",
          "close": ""
        },
        "vol": "0.00100000",
        "vol_exec": "0.00000000",
        "cost": "0.00000",
        "fee": "0.00000",
        "price": "0.00000",
        "stopprice": "0.00000",
        "limitprice": "0.00000",
        "misc": "",
        "oflags": "fciq",
        "trigger": "index"
      }
    },
    "count": 2
  }
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/ClosedOrders" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
