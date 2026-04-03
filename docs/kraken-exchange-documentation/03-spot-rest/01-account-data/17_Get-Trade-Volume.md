# Get Trade Volume

> Source: https://docs.kraken.com/api/docs/rest-api/get-trade-volume

## Endpoint

`POST /private/TradeVolume`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/TradeVolume`

## Description

Returns 30 day USD trading volume and resulting fee schedule for any asset pair(s) provided. Fees will not be included if `pair` is not specified as Kraken fees differ by asset pair. Note: If an asset pair is on a maker/taker fee schedule, the taker side is given in `fees` and maker side in `fees_maker`. For pairs not on maker/taker, they will only be given in `fees`.

## Authentication

This is a private endpoint and requires authentication.

- **API Key Permissions Required:** Funds permissions - Query
- **Headers Required:**
  - `API-Key`: Your API key
  - `API-Sign`: Message signature using HMAC-SHA512
  - `Content-Type`: `application/x-www-form-urlencoded`

## Request Parameters

**Content-Type:** `application/x-www-form-urlencoded`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer (int64) | Yes | Nonce used in construction of `API-Sign` header |
| `pair` | string | No | Comma delimited list of asset pairs to get fee info on (optional, but required if any fee info is desired) |
| `rebase_multiplier` | string, nullable | No | Optional parameter for viewing xstocks data.  - `rebased`: Display in terms of underlying equity. - `base`: Display in terms of SPV tokens.  Enum: `['rebased', 'base']` Default: `rebased` |

## Response Fields

**HTTP 200:** Trade Volume retrieved.

| Field | Type | Description |
|-------|------|-------------|
| `result` | object | Trade Volume |
| `result.currency` | string | Fee volume currency (will always be USD) |
| `result.volume` | string | Current fee discount volume (in USD, breakdown by subaccount if applicable and logged in to master account) |
| `result.fees` | object | Taker fees that will be applied for each `pair` included in the request. Default `None` if `pair` is not requested. |
| `result.fees.pair` | object | Fee Tier Info |
| `result.fees.pair.fee` | string | Current fee (in percent) |
| `result.fees.pair.min_fee` | string | minimum fee for pair (if not fixed fee) |
| `result.fees.pair.max_fee` | string | maximum fee for pair (if not fixed fee) |
| `result.fees.pair.next_fee` | string, nullable | next tier's fee for pair (if not fixed fee,  null if at lowest fee tier) |
| `result.fees.pair.tier_volume` | string, nullable | volume level of current tier (if not fixed fee. null if at lowest fee tier) |
| `result.fees.pair.next_volume` | string, nullable | volume level of next tier (if not fixed fee. null if at lowest fee tier) |
| `result.fees_maker` | object | Maker fees that will be applied for this each `pair` included in the request. Default `None` if `pair` is not requested. |
| `result.fees_maker.pair` | object | Fee Tier Info |
| `result.fees_maker.pair.fee` | string | Current fee (in percent) |
| `result.fees_maker.pair.min_fee` | string | minimum fee for pair (if not fixed fee) |
| `result.fees_maker.pair.max_fee` | string | maximum fee for pair (if not fixed fee) |
| `result.fees_maker.pair.next_fee` | string, nullable | next tier's fee for pair (if not fixed fee,  null if at lowest fee tier) |
| `result.fees_maker.pair.tier_volume` | string, nullable | volume level of current tier (if not fixed fee. null if at lowest fee tier) |
| `result.fees_maker.pair.next_volume` | string, nullable | volume level of next tier (if not fixed fee. null if at lowest fee tier) |
| `error` | array |  |
| `error[]` | string | Kraken API error |

## Example Response

```json
{
  "error": [],
  "result": {
    "currency": "ZUSD",
    "volume": "200709587.4223",
    "fees": {
      "XXBTZUSD": {
        "fee": "0.1000",
        "minfee": "0.1000",
        "maxfee": "0.2600",
        "nextfee": null,
        "nextvolume": null,
        "tiervolume": "10000000.0000"
      }
    },
    "fees_maker": {
      "XXBTZUSD": {
        "fee": "0.0000",
        "minfee": "0.0000",
        "maxfee": "0.1600",
        "nextfee": null,
        "nextvolume": null,
        "tiervolume": "10000000.0000"
      }
    }
  }
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/TradeVolume" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
