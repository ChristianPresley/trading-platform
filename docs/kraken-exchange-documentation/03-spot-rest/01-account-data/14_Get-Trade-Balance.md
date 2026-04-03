# Get Trade Balance

> Source: https://docs.kraken.com/api/docs/rest-api/get-trade-balance

## Endpoint

`POST /private/TradeBalance`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/TradeBalance`

## Description

Retrieve a summary of collateral balances, margin position valuations, equity and margin level.

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
| `asset` | string | No | Base asset used to determine balance Default: `ZUSD` |
| `rebase_multiplier` | string, nullable | No | Optional parameter for viewing xstocks data.  - `rebased`: Display in terms of underlying equity. - `base`: Display in terms of SPV tokens.  Enum: `['rebased', 'base']` Default: `rebased` |

## Response Fields

**HTTP 200:** Trade balances retrieved.

| Field | Type | Description |
|-------|------|-------------|
| `result` | object | Account Balance |
| `result.eb` | string | Equivalent balance (combined balance of all currencies) |
| `result.tb` | string | Trade balance (combined balance of all equity currencies) |
| `result.m` | string | Margin amount of open positions |
| `result.n` | string | Unrealized net profit/loss of open positions |
| `result.c` | string | Cost basis of open positions |
| `result.v` | string | Current floating valuation of open positions |
| `result.e` | string | Equity: `trade balance + unrealized net profit/loss` |
| `result.mf` | string | Free margin: `Equity - initial margin (maximum margin available to open new positions)` |
| `result.ml` | string | Margin level: `(equity / initial margin) * 100` |
| `result.uv` | string | Unexecuted value: Value of unfilled and partially filled orders |
| `error` | array |  |
| `error[]` | string | Kraken API error |

## Example Response

```json
{
  "error": [],
  "result": {
    "eb": "1101.3425",
    "tb": "392.2264",
    "m": "7.0354",
    "n": "-10.0232",
    "c": "21.1063",
    "v": "31.1297",
    "e": "382.2032",
    "mf": "375.1678",
    "ml": "5432.57"
  }
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/TradeBalance" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
