# Get Open Positions

> Source: https://docs.kraken.com/api/docs/rest-api/get-open-positions

## Endpoint

`POST /private/OpenPositions`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/OpenPositions`

## Description

Get information about open margin positions.

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
| `txid` | string | No | Comma delimited list of txids to limit output to |
| `docalcs` | boolean | No | Whether to include P&L calculations Default: `False` |
| `consolidation` | string | No | Consolidate positions by market/pair Enum: `['market']` |
| `rebase_multiplier` | string, nullable | No | Optional parameter for viewing xstocks data.  - `rebased`: Display in terms of underlying equity. - `base`: Display in terms of SPV tokens.  Enum: `['rebased', 'base']` Default: `rebased` |

## Response Fields

**HTTP 200:** Open positions info retrieved.

| Field | Type | Description |
|-------|------|-------------|
| `result` | object |  |
| `result.txid` | object |  |
| `result.txid.ordertxid` | string | Order ID responsible for the position |
| `result.txid.posstatus` | string | Position status Enum: `['open']` |
| `result.txid.pair` | string | Asset pair |
| `result.txid.time` | number | Unix timestamp of trade |
| `result.txid.type` | string | Direction (buy/sell) of position |
| `result.txid.ordertype` | string | Order type used to open position |
| `result.txid.cost` | string | Opening cost of position (in quote currency) |
| `result.txid.fee` | string | Opening fee of position (in quote currency) |
| `result.txid.vol` | string | Position opening size (in base currency) |
| `result.txid.vol_closed` | string | Quantity closed (in base currency) |
| `result.txid.margin` | string | Initial margin consumed (in quote currency) |
| `result.txid.value` | string | Current value of remaining position (if `docalcs` requested) |
| `result.txid.net` | string | Unrealised P&L of remaining position (if `docalcs` requested) |
| `result.txid.terms` | string | Funding cost and term of position |
| `result.txid.rollovertm` | string | Timestamp of next margin rollover fee |
| `result.txid.misc` | string | Comma delimited list of add'l info |
| `result.txid.oflags` | string | Comma delimited list of opening order flags |
| `error` | array |  |
| `error[]` | string | Kraken API error |

## Example Response

```json
{
  "error": [],
  "result": {
    "TF5GVO-T7ZZ2-6NBKBI": {
      "ordertxid": "OLWNFG-LLH4R-D6SFFP",
      "posstatus": "open",
      "pair": "XXBTZUSD",
      "time": 1605280097.8294,
      "type": "buy",
      "ordertype": "limit",
      "cost": "104610.52842",
      "fee": "289.06565",
      "vol": "8.82412861",
      "vol_closed": "0.20200000",
      "margin": "20922.10568",
      "value": "258797.5",
      "net": "+154186.9728",
      "terms": "0.0100% per 4 hours",
      "rollovertm": "1616672637",
      "misc": "",
      "oflags": ""
    },
    "T24DOR-TAFLM-ID3NYP": {
      "ordertxid": "OIVYGZ-M5EHU-ZRUQXX",
      "posstatus": "open",
      "pair": "XXBTZUSD",
      "time": 1607943827.3172,
      "type": "buy",
      "ordertype": "limit",
      "cost": "145756.76856",
      "fee": "335.24057",
      "vol": "8.00000000",
      "vol_closed": "0.00000000",
      "margin": "29151.35371",
      "value": "240124.0",
      "net": "+94367.2314",
      "terms": "0.0100% per 4 hours",
      "rollovertm": "1616672637",
      "misc": "",
      "oflags": ""
    },
    "TYMRFG-URRG5-2ZTQSD": {
      "ordertxid": "OF5WFH-V57DP-QANDAC",
      "posstatus": "open",
      "pair": "XXBTZUSD",
      "time": 1610448039.8374,
      "type": "buy",
      "ordertype": "limit",
      "cost": "0.00240",
      "fee": "0.00000",
      "vol": "0.00000010",
      "vol_closed": "0.00000000",
      "margin": "0.00048",
      "value": "0",
      "net": "+0.0006",
      "terms": "0.0100% per 4 hours",
      "rollovertm": "1616672637",
      "misc": "",
      "oflags": ""
    },
    "TAFGBN-TZNFC-7CCYIM": {
      "ordertxid": "OF5WFH-V57DP-QANDAC",
      "posstatus": "open",
      "pair": "XXBTZUSD",
      "time": 1610448039.8448,
      "type": "buy",
      "ordertype": "limit",
      "cost": "2.40000",
      "fee": "0.00264",
      "vol": "0.00010000",
      "vol_closed": "0.00000000",
      "margin": "0.48000",
      "value": "3.0",
      "net": "+0.6015",
      "terms": "0.0100% per 4 hours",
      "rollovertm": "1616672637",
      "misc": "",
      "oflags": ""
    },
    "T4O5L3-4VGS4-IRU2UL": {
      "ordertxid": "OF5WFH-V57DP-QANDAC",
      "posstatus": "open",
      "pair": "XXBTZUSD",
      "time": 1610448040.7722,
      "type": "buy",
      "ordertype": "limit",
      "cost": "21.59760",
      "fee": "0.02376",
      "vol": "0.00089990",
      "vol_closed": "0.00000000",
      "margin": "4.31952",
      "value": "27.0",
      "net": "+5.4133",
      "terms": "0.0100% per 4 hours",
      "rollovertm": "1616672637",
      "misc": "",
      "oflags": ""
    }
  }
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/OpenPositions" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
