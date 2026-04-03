# Get Account Balance

> Source: https://docs.kraken.com/api/docs/rest-api/get-account-balance

## Endpoint

`POST /private/Balance`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/Balance`

## Description

Retrieve all cash balances, net of pending withdrawals.

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
| `rebase_multiplier` | string, nullable | No | Optional parameter for viewing xstocks data.  - `rebased`: Display in terms of underlying equity. - `base`: Display in terms of SPV tokens.  Enum: `['rebased', 'base']` Default: `rebased` |

## Response Fields

**HTTP 200:** Account balances retrieved.

| Field | Type | Description |
|-------|------|-------------|
| `result` | object | Account Balance |
| `result.asset` | string | balance |
| `error` | array |  |
| `error[]` | string | Kraken API error |

## Example Response

```json
{
  "error": [],
  "result": {
    "ZUSD": "171288.6158",
    "ZEUR": "504861.8946",
    "XXBT": "1011.1908877900",
    "XETH": "818.5500000000",
    "USDT": "500000.00000000",
    "DAI": "9999.9999999999",
    "DOT": "2.5000000000",
    "ETH2.S": "198.3970800000",
    "ETH2": "2.5885574330",
    "USD.M": "1213029.2780"
  }
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/Balance" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

### Note on Staking/Earn Assets

Kraken has begun migrating assets from the legacy Staking system to a new Earn system. The following asset symbol extensions may appear in balances and ledger entries:

| Extension | Description |
|-----------|-------------|
| `.S` | Staked assets (legacy, read-only) |
| `.M` | Opt-in rewards balances (legacy, read-only) |
| `.B` | Balances in new yield-bearing products |
| `.F` | Balances earning automatically in Kraken Rewards |
| `.T` | Tokenized assets |

**Note:** Assets with `.S` and `.M` extensions are read-only. To interact with these balances, use the base asset (e.g., `USDT` to transact with `USDT` and `USDT.F` balances).

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
