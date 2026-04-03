# Get Credit Lines

> Source: https://docs.kraken.com/api/docs/rest-api/get-credit-lines

## Endpoint

`POST /private/CreditLines`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/CreditLines`

## Description

Retrieve all credit line details for VIPs with this functionality.

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

**HTTP 200:** Credit line details retrieved.

| Field | Type | Description |
|-------|------|-------------|
| `result` | object, nullable | Credit Line Details |
| `result.asset_details` | object | Balances by asset |
| `result.asset_details.<key>` | object | Credit line details for a specific asset |
| `result.asset_details.<key>.balance` | string | Current balance for the asset |
| `result.asset_details.<key>.credit_limit` | string | Credit limit for the asset |
| `result.asset_details.<key>.credit_used` | string | Currently used credit for the asset |
| `result.asset_details.<key>.available_credit` | string | Available credit for the asset |
| `result.limits_monitor` | object | Credit monitor |
| `result.limits_monitor.total_credit_usd` | string, nullable | Total credit across all assets represented in USD |
| `result.limits_monitor.total_credit_used_usd` | string, nullable | Total credit used across all assets represented in USD |
| `result.limits_monitor.total_collateral_value_usd` | string, nullable | Sum of asset balance in USD * collateral |
| `result.limits_monitor.equity_usd` | string, nullable | Total collateral - total credit (in USD) |
| `result.limits_monitor.ongoing_balance` | string, nullable | Total collateral / total credit (in USD) |
| `result.limits_monitor.debt_to_equity` | string, nullable | Total credit used / equity (in USD) |
| `error` | array |  |
| `error[]` | string | Kraken API error |

## Example Response

```json
{
  "error": [],
  "result": {
    "asset_details": {
      "USD": {
        "balance": "1000.5000",
        "credit_limit": "50000.0000",
        "credit_used": "12500.0000",
        "available_credit": "37500.0000"
      },
      "EUR": {
        "balance": "500.2500",
        "credit_limit": "25000.0000",
        "credit_used": "5000.0000",
        "available_credit": "20000.0000"
      }
    },
    "limits_monitor": {
      "total_credit_usd": "100000.0000",
      "total_credit_used_usd": "25000.0000",
      "total_collateral_value_usd": "150000.0000",
      "equity_usd": "125000.0000",
      "ongoing_balance": "1.5000",
      "debt_to_equity": "0.2000"
    }
  }
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/CreditLines" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
