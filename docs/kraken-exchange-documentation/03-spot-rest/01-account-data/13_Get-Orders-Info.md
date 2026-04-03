# Query Orders Info

> Source: https://docs.kraken.com/api/docs/rest-api/get-orders-info

## Endpoint

`POST /private/QueryOrders`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/QueryOrders`

## Description

Retrieve information about specific orders.

## Authentication

This is a private endpoint and requires authentication.

- **API Key Permissions Required:** Orders and trades - Query open orders & trades; Orders and trades - Query closed orders & trades
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
| `userref` | integer (int32) | No | Restrict results to given user reference id |
| `txid` | string | Yes | The Kraken order identifier. To query multiple orders, use comma delimited list of up to 50 ids. |
| `consolidate_taker` | boolean | No | Whether or not to consolidate trades by individual taker trades Default: `True` |
| `rebase_multiplier` | string, nullable | No | Optional parameter for viewing xstocks data.  - `rebased`: Display in terms of underlying equity. - `base`: Display in terms of SPV tokens.  Enum: `['rebased', 'base']` Default: `rebased` |

## Response Fields

**HTTP 200:** Orders info retrieved.

| Field | Type | Description |
|-------|------|-------------|
| `result` | object | txid of the order. |
| `error` | array |  |
| `error[]` | string | Kraken API error |

## Example Response

```json
{
  "error": [],
  "result": {
    "OBCMZD-JIEE7-77TH3F": {
      "refid": "None",
      "userref": 0,
      "status": "closed",
      "reason": null,
      "opentm": 1688665496.7808,
      "closetm": 1688665499.1922,
      "starttm": 0,
      "expiretm": 0,
      "descr": {
        "pair": "XBTUSD",
        "type": "buy",
        "ordertype": "stop-loss-limit",
        "price": "27500.0",
        "price2": "0",
        "leverage": "none",
        "order": "buy 1.25000000 XBTUSD @ limit 27500.0",
        "close": ""
      },
      "vol": "1.25000000",
      "vol_exec": "1.25000000",
      "cost": "27526.2",
      "fee": "26.2",
      "price": "27500.0",
      "stopprice": "0.00000",
      "limitprice": "0.00000",
      "misc": "",
      "oflags": "fciq",
      "trigger": "index",
      "trades": [
        "TZX2WP-XSEOP-FP7WYR"
      ]
    },
    "OMMDB2-FSB6Z-7W3HPO": {
      "refid": "None",
      "userref": 0,
      "status": "closed",
      "reason": null,
      "opentm": 1688592012.2317,
      "closetm": 1688592012.2335,
      "starttm": 0,
      "expiretm": 0,
      "descr": {
        "pair": "XBTUSD",
        "type": "sell",
        "ordertype": "market",
        "price": "0",
        "price2": "0",
        "leverage": "none",
        "order": "sell 0.25000000 XBTUSD @ market",
        "close": ""
      },
      "vol": "0.25000000",
      "vol_exec": "0.25000000",
      "cost": "7500.0",
      "fee": "7.5",
      "price": "30000.0",
      "stopprice": "0.00000",
      "limitprice": "0.00000",
      "misc": "",
      "oflags": "fcib",
      "trades": [
        "TJUW2K-FLX2N-AR2FLU"
      ]
    }
  }
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/QueryOrders" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
